<?php

namespace App\Drivers;

abstract class SupplierDriver implements Driver
{
    /** Operation IDs map to code-owned protocol descriptions and business input contracts. */
    abstract public function operations(): array;

    public function operation(string $id): array
    {
        return $this->operations()[$id] ?? throw new \InvalidArgumentException('供应商不支持操作：'.$id);
    }

    protected function validateInput(array $endpoint, array $input): string
    {
        $id = $endpoint['operation'] ?? '';
        $operation = $this->operation($id);
        foreach ($operation['required_inputs'] as $field) {
            $value = data_get($input, $field);
            if (! is_scalar($value) || (string) $value === '') {
                throw new \InvalidArgumentException('缺少业务输入：'.$field);
            }
        }

        return $id;
    }

    protected function httpStatus(int $code): string
    {
        if ($code === 202) {
            return 'unknown';
        }
        if (in_array($code, [200, 201, 204], true)) {
            return 'succeeded';
        }

        return ($code === 408 || $code === 429 || $code >= 500) ? 'retry' : 'dead';
    }
}
