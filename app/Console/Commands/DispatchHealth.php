<?php

namespace App\Console\Commands;

use App\Models\NotificationEvent;
use App\Models\Provider;
use App\Models\RequestStep;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Redis;

class DispatchHealth extends Command
{
    protected $signature = 'dispatch:health';

    protected $description = 'Print queue, backlog and terminal-failure metrics for monitoring';

    public function handle(): int
    {
        $redis = true;
        try {
            Redis::ping();
        } catch (\Throwable) {
            $redis = false;
        }
        $heartbeat = Cache::get('dispatch.last_tick');
        $this->line(json_encode(['redis' => $redis, 'last_tick' => $heartbeat, 'pending_events' => NotificationEvent::where('conversion_status', 'pending')->count(),
            'failed_conversions' => NotificationEvent::where('conversion_status', 'failed')->count(),
            'step_statuses' => RequestStep::selectRaw('status, count(*) as total')->groupBy('status')->pluck('total', 'status'),
            'oldest_due' => RequestStep::whereIn('status', ['ready', 'retry'])->min('available_at'),
            'open_circuits' => Provider::where('circuit_until', '>', now())->count()], JSON_UNESCAPED_UNICODE));

        return $redis && $heartbeat && strtotime($heartbeat) > time() - 30 ? self::SUCCESS : self::FAILURE;
    }
}
