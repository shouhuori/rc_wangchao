<?php

namespace Tests;

use App\Models\EventSource;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function createSource(string $id = 'shop', string $token = 'test-token'): EventSource
    {
        return EventSource::create([
            'id' => $id, 'name' => $id, 'enabled' => true, 'token_hash' => hash('sha256', $token),
        ]);
    }
}
