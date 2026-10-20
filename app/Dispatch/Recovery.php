<?php

namespace App\Dispatch;

use App\Jobs\ExecuteStep;
use App\Models\Attempt;
use App\Models\NotificationEvent;
use App\Models\Provider;
use App\Models\RequestStep;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class Recovery
{
    public function recover(): void
    {
        RequestStep::where('status', 'running')->where('lease_until', '<=', now())->orderBy('id')->chunkById(100, function ($steps) {
            foreach ($steps as $candidate) {
                DB::transaction(function () use ($candidate) {
                    $step = RequestStep::lockForUpdate()->findOrFail($candidate->id);
                    if ($step->status !== 'running' || $step->lease_until->isFuture()) {
                        return;
                    }
                    Attempt::where('step_id', $step->id)->where('token', $step->lease_token)->where('status', 'running')
                        ->update(['status' => 'unknown', 'error' => '执行租约过期，结果未知。', 'finished_at' => now()]);
                    Provider::whereKey($step->provider_id)->where('busy_token', $step->lease_token)->update(['busy_token' => null, 'busy_until' => null]);
                    $status = ($step->endpoint_snapshot['options']['idempotent'] ?? false) ? 'retry' : 'unknown';
                    if ($status === 'retry' && ($step->cycle_attempts >= $step->max_attempts || $step->expires_at->isPast())) {
                        $status = 'dead';
                    }
                    $step->update(['status' => $status, 'lease_token' => null, 'lease_until' => null, 'enqueued_until' => null, 'available_at' => now(), 'last_error' => '执行中断，已回收过期租约。']);
                }, 3);
            }
        });
    }

    public function tick(bool $enqueue = true): array
    {
        $this->recover();
        $converted = 0;
        $queued = 0;
        foreach (NotificationEvent::where('conversion_status', 'pending')->oldest()->limit(100)->get() as $e) {
            app(Converter::class)->convert($e->id);
            $converted++;
        }
        // Cursor traversal prevents a permanently blocked early event starving newer events.
        NotificationEvent::where('conversion_status', 'converted')->whereHas('tasks', fn ($q) => $q->whereNotIn('status', ['succeeded', 'dead', 'unknown', 'skipped']))
            ->chunkById(100, function ($events) {
                foreach ($events as $e) {
                    app(Coordinator::class)->refresh($e->id);
                }
            });
        RequestStep::whereIn('status', ['ready', 'retry', 'waiting', 'blocked'])->where('expires_at', '<=', now())
            ->update(['status' => 'dead', 'last_error' => '投递期限已到，停止自动执行。']);
        if (! $enqueue) {
            return compact('converted', 'queued');
        }
        // Each eligible supplier gets one slot per scan. One busy backlog cannot monopolize the batch.
        Provider::where('enabled', true)
            ->where(fn ($q) => $q->whereNull('circuit_until')->orWhere('circuit_until', '<=', now()))
            ->where(fn ($q) => $q->whereNull('busy_until')->orWhere('busy_until', '<=', now()))
            ->where(fn ($q) => $q->whereNull('next_request_at')->orWhere('next_request_at', '<=', now()))
            ->chunkById(100, function ($providers) use (&$queued) {
                foreach ($providers as $provider) {
                    $step = RequestStep::where('provider_id', $provider->id)->whereIn('status', ['ready', 'retry'])
                        ->where('available_at', '<=', now())
                        ->where(fn ($q) => $q->whereNull('enqueued_until')->orWhere('enqueued_until', '<=', now()))
                        ->whereHas('task', fn ($q) => $q->where('paused', false))->orderBy('available_at')->orderBy('id')->first();
                    if (! $step) {
                        continue;
                    }
                    $claimed = RequestStep::whereKey($step->id)->whereIn('status', ['ready', 'retry'])
                        ->where(fn ($q) => $q->whereNull('enqueued_until')->orWhere('enqueued_until', '<=', now()))
                        ->update(['enqueued_until' => now()->addSeconds(120)]);
                    if (! $claimed) {
                        continue;
                    }
                    try {
                        ExecuteStep::dispatch($step->id)->onQueue('supplier.'.$step->provider_id);
                        $queued++;
                    } catch (\Throwable $e) {
                        RequestStep::whereKey($step->id)->update(['enqueued_until' => null]);
                        report($e);

                        return false;
                    }
                }
            });
        Cache::put('dispatch.last_tick',now()->toIso8601String(),300);

        return compact('converted','queued');
    }
}
