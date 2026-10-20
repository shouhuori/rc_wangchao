<?php

namespace App\Drivers\Suppliers;

use App\Drivers\DeliveryResult;
use App\Drivers\FormHttpDriver;
use App\Drivers\PreparedRequest;
use App\Drivers\SupplierDriver;
use Illuminate\Http\Client\Response;

final class DemoSmsDriver extends SupplierDriver
{
    public function manifest(): array
    {
        return ['id' => 'demo.sms.v1', 'name' => '演示短信系统', 'credentials' => ['api_key'], 'description' => '短信协议示例：表单请求、X-Api-Key 认证和订单确认模板。'];
    }

    public function operations(): array
    {
        return ['order.confirm' => ['name' => '发送订单确认短信', 'method' => 'POST', 'path' => '/sms', 'idempotent' => true, 'required_inputs' => ['order_id']]];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        $id = $this->validateInput($endpoint, $input);
        $r = (new FormHttpDriver)->prepare($this->operation($id), [], ['template' => 'order.confirmed', 'order_id' => $input['order_id'], 'request_id' => $key], $key);

        return new PreparedRequest($r->method, $r->path, $r->headers + ['X-Api-Key' => $credentials['api_key']], $r->body);
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
