<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateAdmin extends Command
{
    protected $signature = 'dispatch:admin {email}';

    protected $description = 'Create or reset an internal operator account with an interactive password';

    public function handle(): int
    {
        if (! filter_var($this->argument('email'), FILTER_VALIDATE_EMAIL)) {
            $this->error('Invalid email.');

            return self::FAILURE;
        }
        $password = $this->secret('Password (at least 12 characters)');
        if (strlen($password ?? '') < 12) {
            $this->error('Password too short.');

            return self::FAILURE;
        }
        User::updateOrCreate(['email' => $this->argument('email')], ['name' => '管理员', 'password' => Hash::make($password)]);
        $this->info('Operator saved.');

        return self::SUCCESS;
    }
}
