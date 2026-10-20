<?php

namespace App\Drivers;

use Illuminate\Http\Client\Response;

interface Driver
{
    public function manifest(): array;

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest;

    // Full response is available for supplier-specific JSON/XML/text and header parsing.
    public function interpret(array $endpoint, Response $response): DeliveryResult;
}
