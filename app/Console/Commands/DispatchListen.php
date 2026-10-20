<?php

namespace App\Console\Commands;

use App\Dispatch\Recovery;
use Illuminate\Console\Command;

class DispatchListen extends Command
{
    protected $signature = 'dispatch:listen';

    protected $description = 'Continuously reconcile durable events and queue due HTTP steps';

    public function handle(Recovery $recovery): int
    {
        $running = true;
        if (function_exists('pcntl_async_signals')) {
            pcntl_async_signals(true);
            pcntl_signal(SIGTERM, function () use (&$running) {
                $running = false;
            });
            pcntl_signal(SIGINT, function () use (&$running) {
                $running = false;
            });
        }
        $this->info('Persistent dispatcher listening. Ctrl+C to stop.');
        while ($running) {
            try {
                $recovery->tick();
            } catch (\Throwable $e) {
                report($e);
                $this->error('调度异常：'.class_basename($e).'；下一轮重试。');
            }
            if ($running) {
                sleep(1);
            }
        }

        return self::SUCCESS;
    }
}
