<?php

namespace App\Drivers\Suppliers;

use App\Drivers\DeliveryResult;
use App\Drivers\HmacJsonDriver;
use App\Drivers\PreparedRequest;
use App\Drivers\SupplierDriver;
use Illuminate\Http\Client\Response;

final class DemoInventoryDriver extends SupplierDriver
{
    public function manifest(): array
    {
        return ['id' => 'demo.inventory.v1', 'name' => '演示库存系统', 'credentials' => ['key_id', 'secret'], 'description' => '库存协议示例：JSON 请求；签名为 HMAC-SHA256(timestamp + 换行 + 请求体)。'];
    }

    public function operations(): array
    {
        return ['stock.reserve' => ['name' => '预留库存', 'method' => 'POST', 'path' => '/reserve', 'idempotent' => true, 'required_inputs' => ['order_id']]];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        $id = $this->validateInput($endpoint, $input);

        return (new HmacJsonDriver)->prepare($this->operation($id), $credentials, ['order_id' => $input['order_id']], $key);
    }

    public function interpret(array $endpoint, Response $response): DeliveryResult
    {
        $this->operation($endpoint['operation'] ?? '');
        $body = $response->json();
        $body = is_array($body) ? $body : [];
        $status = $this->httpStatus($response->status());
        if ($status === 'succeeded' && ($body['ok'] ?? false) !== true) {
            $status = 'dead';
        }

        return new DeliveryResult($status, $body);
    }
}
