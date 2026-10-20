<?php

namespace App\Console\Commands;

use App\Models\Provider;
use Illuminate\Console\Command;
use Symfony\Component\Process\Process;

class DispatchWorkers extends Command
{
    protected $signature = 'dispatch:workers';

    protected $description = 'Run an isolated queue worker per provider and discover new providers';

    public function handle(): int
    {
        $running = true;
        $workers = [];
        if (function_exists('pcntl_async_signals')) {
            pcntl_async_signals(true);
            pcntl_signal(SIGTERM, function () use (&$running) {
                $running = false;
            });
            pcntl_signal(SIGINT, function () use (&$running) {
                $running = false;
            });
        }
        $this->info('Per-provider worker supervisor running.');
        try {
            while ($running) {
                try {
                    foreach (Provider::pluck('id') as $id) {
                        if (isset($workers[$id]) && $workers[$id]->isRunning()) {
                            continue;
                        }
                        $p = new Process([PHP_BINARY, base_path('artisan'), 'queue:work', '--queue=supplier.'.$id, '--sleep=1', '--tries=1', '--timeout=45', '--max-time=3600'], base_path());
                        $p->setTimeout(null);
                        $p->disableOutput();
                        $p->start();
                        $workers[$id] = $p;
                    }
                } catch (\Throwable $e) {
                    report($e);
                }
                if ($running) {
                    sleep(3);
                }
            }
        } finally {
            foreach ($workers as $p) {
                if ($p->isRunning()) {
                    $p->stop(50);
                }
            }
        }

        return self::SUCCESS;
    }
}
