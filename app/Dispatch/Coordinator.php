<?php

namespace App\Dispatch;

use App\Models\NotificationEvent;
use Illuminate\Support\Facades\DB;

class Coordinator
{
    public function summary(NotificationEvent $event): string
    {
        if ($event->conversion_status !== 'converted') {
            return $event->conversion_status;
        }
        $statuses = $event->tasks()->pluck('status');
        if ($statuses->isEmpty() || $statuses->every(fn ($s) => $s === 'skipped')) {
            return 'skipped';
        }
        if ($statuses->every(fn ($s) => in_array($s, ['succeeded', 'skipped']))) {
            return 'succeeded';
        }
        if ($statuses->contains(fn ($s) => in_array($s, ['dead', 'unknown', 'blocked']))) {
            return 'attention';
        }

        return 'processing';
    }

    public function refresh(string $id): void
    {
        DB::transaction(function () use ($id) {
            $event = NotificationEvent::lockForUpdate()->findOrFail($id);
            if ($event->conversion_status !== 'converted') {
                return;
            }
            $parentState = 'succeeded';
            if ($event->predecessor_id !== null) {
                $parent = NotificationEvent::where('source', $event->source)->where('external_id', $event->predecessor_id)->first();
                $parentState = $parent ? $this->summary($parent) : 'missing';
                if ($parentState === 'skipped') {
                    $parentState = 'succeeded';
                }
            }
            $tasks = $event->tasks()->with('steps')->get()->keyBy('key');
            // Iterate to a fixed point so arbitrary DAG order is supported.
            for ($pass = 0; $pass <= $tasks->count(); $pass++) {
                foreach ($tasks as $task) {
                    if ($task->status === 'skipped') {
                        continue;
                    }
                    $dependencies = collect($task->depends_on)->map(fn ($key) => $tasks->get($key)?->status ?? 'waiting')->all();
                    $dependencies[] = $parentState;
                    $taskGate = $this->gate($dependencies);
                    $steps = $task->steps->keyBy('key');
                    foreach ($steps as $step) {
                        if (! in_array($step->status, ['waiting', 'blocked', 'ready', 'retry'])) {
                            continue;
                        }
                        $states = collect($step->depends_on)->map(fn ($key) => $steps->get($key)?->status ?? 'waiting')->all();
                        $gate = $this->gate([...$states, $taskGate]);
                        $status = $gate === 'succeeded' ? (in_array($step->status, ['ready', 'retry']) ? $step->status : 'ready') : ($gate === 'blocked' ? 'blocked' : 'waiting');
                        if ($step->status !== $status) {
                            $step->update(['status' => $status]);
                        }
                    }
                    $states = $steps->pluck('status');
                    $status = match (true) {
                        $states->every(fn ($s) => $s === 'succeeded') => 'succeeded',
                        $states->contains('unknown') => 'unknown', $states->contains('dead') => 'dead',
                        $taskGate === 'blocked' || $states->contains('blocked') => 'blocked',
                        $states->contains('running') => 'running', $states->contains('retry') => 'retry',
                        $states->contains('ready') => 'ready', default => 'waiting',
                    };
                    if ($task->status !== $status) {
                        $task->update(['status' => $status]);
                    }
                }
            }
        }, 3);
    }

    private function gate(array $statuses): string
    {
        foreach ($statuses as $status) {
            if (in_array($status, ['dead', 'unknown', 'blocked', 'attention', 'failed', 'skipped'], true)) {
                return 'blocked';
            }
        }
        foreach ($statuses as $status) {
            if ($status !== 'succeeded') {
                return 'waiting';
            }
        }

        return 'succeeded';
    }
}
