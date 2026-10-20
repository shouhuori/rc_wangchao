<?php

namespace App\Drivers;

final readonly class DeliveryResult
{
    public function __construct(public string $status, public array $output = [])
    {
        if (! in_array($status, ['succeeded', 'retry', 'dead', 'unknown'], true)) {
            throw new \InvalidArgumentException('未知的供应商结果状态。');
        }
    }
}
