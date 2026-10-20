<?php

namespace App\Dispatch;

use App\Models\DeliveryTask;
use App\Models\NotificationEvent;
use App\Models\RequestStep;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class Converter
{
    public function convert(string $id): void
    {
        try {
            DB::transaction(function () use ($id) {
                $event = NotificationEvent::lockForUpdate()->findOrFail($id);
                if ($event->conversion_status !== 'pending') {
                    return;
                }
                foreach ($event->version->definition['tasks'] as $definition) {
                    if (! ($definition['enabled'] ?? true)) {
                        continue;
                    }
                    $task = DeliveryTask::create(['event_id' => $id, 'key' => $definition['key'], 'name' => $definition['name'], 'depends_on' => $definition['depends_on']]);
                    $matches = true;
                    foreach ($definition['when'] ?? [] as $path => $value) {
                        if (data_get($event->toArray(), $path, new \stdClass) !== $value) {
                            $matches = false;
                        }
                    }
                    if (! $matches) {
                        $task->update(['status' => 'skipped']);

                        continue;
                    }
                    foreach ($definition['steps'] as $s) {
                        if (! ($s['enabled'] ?? true)) {
                            continue;
                        }
                        if (empty($s['endpoint_snapshot']['provider_id'])) {
                            throw new \RuntimeException('接口快照不完整。');
                        }
                        $available = now()->addSeconds($s['delay_seconds'] ?? 0);
                        if (! empty($s['daily_at'])) {
                            $available = Carbon::now($s['timezone'] ?? 'Asia/Shanghai')->setTimeFromTimeString($s['daily_at']);
                            if ($available->isPast()) {
                                $available->addDay();
                            } $available->utc();
                        }
                        RequestStep::create(['task_id' => $task->id, 'key' => $s['key'], 'name' => $s['name'],
                            'provider_id' => $s['endpoint_snapshot']['provider_id'], 'endpoint_snapshot' => $s['endpoint_snapshot'],
                            'input_mapping' => $s['input'], 'depends_on' => $s['depends_on'], 'available_at' => $available,
                            'expires_at' => $available->copy()->addSeconds($s['ttl_seconds'] ?? 86400), 'max_attempts' => $s['max_attempts'] ?? 5,
                            'idempotency_key' => (string) Str::uuid()]);
                    }
                }
                $event->update(['conversion_status' => 'converted', 'conversion_error' => null]);
            }, 3);
        } catch (\Throwable $e) {
            // The transaction rolls back all partial tasks. Operator can retry conversion after repair.
            NotificationEvent::whereKey($id)->where('conversion_status', 'pending')->update(['conversion_status' => 'failed', 'conversion_error' => '任务转换失败：'.get_class($e)]);
            report($e);
        }
    }
}
