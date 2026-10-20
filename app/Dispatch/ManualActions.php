<?php

namespace App\Dispatch;

use App\Models\NotificationEvent;
use App\Models\RequestStep;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ManualActions
{
    public function retry(string $id, string $actor, string $reason, bool $verified = false): void
    {
        DB::transaction(function () use ($id, $actor, $reason, $verified) {
            $step = RequestStep::lockForUpdate()->findOrFail($id);
            if (! in_array($step->status, ['dead', 'unknown'])) {
                throw ValidationException::withMessages(['step' => '只能恢复最终失败或结果未知的请求。']);
            }
            if ($step->status === 'unknown' && ! $verified) {
                throw ValidationException::withMessages(['verified' => '请先核对供应商状态，再确认允许重试。']);
            }
            $step->update(['status' => 'waiting', 'cycle_attempts' => 0, 'available_at' => now(), 'expires_at' => now()->addDay(), 'last_error' => null, 'enqueued_until' => null]);
            Audit::record($actor, 'step.retry', $id, ['reason' => $reason, 'verified' => $verified]);
        });
        app(Coordinator::class)->refresh(RequestStep::findOrFail($id)->task->event_id);
    }

    public function confirmSuccess(string $id, string $actor, string $reason, array $output): void
    {
        DB::transaction(function () use ($id, $actor, $reason, $output) {
            $step = RequestStep::lockForUpdate()->findOrFail($id);
            if ($step->status !== 'unknown') {
                throw ValidationException::withMessages(['step' => '只能核对结果未知的请求。']);
            }
            $step->update(['status' => 'succeeded', 'output' => $output, 'last_error' => null]);
            Audit::record($actor, 'step.confirm-success', $id, ['reason' => $reason, 'output' => Redactor::clean($output)]);
        });
        app(Coordinator::class)->refresh(RequestStep::findOrFail($id)->task->event_id);
    }

    public function reconvert(string $id, string $actor, string $reason): void
    {
        DB::transaction(function () use ($id, $actor, $reason) {
            $event = NotificationEvent::lockForUpdate()->findOrFail($id);
            if ($event->conversion_status !== 'failed') {
                throw ValidationException::withMessages(['event' => '只能恢复转换失败的事件。']);
            }
            $event->update(['conversion_status' => 'pending', 'conversion_error' => null]);
            Audit::record($actor,'event.reconvert',$id,['reason' => $reason]);
        });
    }
}
