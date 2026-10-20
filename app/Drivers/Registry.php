<?php

namespace App\Drivers;

use App\Drivers\Suppliers\DemoCrmDriver;
use App\Drivers\Suppliers\DemoInventoryDriver;
use App\Drivers\Suppliers\DemoSmsDriver;
use Illuminate\Validation\ValidationException;

class Registry
{
    private const SUPPLIERS = ['demo.crm.v1' => DemoCrmDriver::class, 'demo.inventory.v1' => DemoInventoryDriver::class, 'demo.sms.v1' => DemoSmsDriver::class];

    // Execution compatibility only. Never offer transports as new supplier implementations.
    private const LEGACY = ['json-http.v1' => JsonHttpDriver::class, 'hmac-json.v1' => HmacJsonDriver::class, 'form-http.v1' => FormHttpDriver::class];

    public function get(string $id): Driver
    {
        $class = self::SUPPLIERS[$id] ?? self::LEGACY[$id] ?? null;
        if (! $class) {
            throw ValidationException::withMessages(['driver' => "Driver 不存在：$id"]);
        }

        return app($class);
    }

    public function supplier(string $id): SupplierDriver
    {
        if (! isset(self::SUPPLIERS[$id])) {
            throw ValidationException::withMessages(['driver' => '请选择已部署的供应商实现类。旧通用 Driver 仅用于历史任务兼容。']);
        }

        return app(self::SUPPLIERS[$id]);
    }

    public function operation(string $driver, ?string $operation): array
    {
        $supplier = $this->supplier($driver);
        if (! $operation || ! isset($supplier->operations()[$operation])) {
            throw ValidationException::withMessages(['operation' => '该供应商类不支持此 API 操作。请检查部署版本与配置。']);
        }

        return $supplier->operation($operation);
    }

    public function all(): array
    {
        return array_map(fn ($class) => app($class)->manifest() + ['operations' => app($class)->operations(), 'class' => $class], array_values(self::SUPPLIERS));
    }
}
