<?php

namespace App\Console\Commands;

use App\Dispatch\Recovery;
use Illuminate\Console\Command;

class DispatchTick extends Command
{
    protected $signature = 'dispatch:tick';

    protected $description = 'Recover durable work, convert events and wake due HTTP steps';

    public function handle(Recovery $recovery): int
    {
        $this->info(json_encode($recovery->tick()));

        return self::SUCCESS;
    }
}
