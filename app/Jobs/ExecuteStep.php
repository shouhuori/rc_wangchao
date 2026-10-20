<?php

namespace App\Jobs;

use App\Dispatch\Executor;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ExecuteStep implements ShouldQueue
{
    use Queueable;

    public int $tries = 1;

    public int $timeout = 45;

    public function __construct(public string $stepId) {}

    public function handle(Executor $executor): void
    {
        $executor->execute($this->stepId);
    }
}
