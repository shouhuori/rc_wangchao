<?php

namespace App\Drivers\Suppliers;

use App\Drivers\DeliveryResult;
use App\Drivers\JsonHttpDriver;
use App\Drivers\PreparedRequest;
use App\Drivers\SupplierDriver;
use Illuminate\Http\Client\Response;

final class DemoCrmDriver extends SupplierDriver
{
    public function manifest(): array
    {
        return ['id' => 'demo.crm.v1', 'name' => '演示 CRM 系统', 'credentials' => ['token'], 'description' => '独立 CRM 协议示例：创建联系人和更新付费状态。真实 CRM 需按官方协议另写供应商类。'];
    }

    public function operations(): array
    {
        return [
            'contact.create' => ['name' => '创建联系人', 'method' => 'POST', 'path' => '/contacts', 'idempotent' => true, 'required_inputs' => ['contact_id']],
            'contact.mark-paid' => ['name' => '更新付费状态', 'method' => 'PATCH', 'path' => '/contacts/{contact_id}/paid', 'idempotent' => true, 'required_inputs' => ['contact_id', 'order_id']],
        ];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        $id = $this->validateInput($endpoint, $input);

        return match ($id) {
            'contact.create' => $this->createContact($credentials, $input, $key),
            'contact.mark-paid' => $this->markContactPaid($credentials, $input, $key),
        };
    }

    private function createContact(array $credentials, array $input, string $key): PreparedRequest
    {
        return (new JsonHttpDriver)->prepare($this->operation('contact.create'), $credentials, ['external_id' => $input['contact_id']], $key);
    }

    private function markContactPaid(array $credentials, array $input, string $key): PreparedRequest
    {
        return (new JsonHttpDriver)->prepare($this->operation('contact.mark-paid'), $credentials,
            ['contact_id' => $input['contact_id'], 'order_id' => $input['order_id'], 'status' => 'paid'], $key);
    }

    public function interpret(array $endpoint, Response $response): DeliveryResult
    {
        $id = $endpoint['operation'] ?? '';
        $this->operation($id);
        $body = $response->json();
        $body = is_array($body) ? $body : [];
        $status = $this->httpStatus($response->status());
        if ($status === 'succeeded') {
            $ok = match ($id) {
                'contact.create' => isset($body['id']) && is_scalar($body['id']) && (string) $body['id'] !== '',
                'contact.mark-paid' => ($body['ok'] ?? false) === true,
            };
            $status = $ok ? 'succeeded' : 'dead';
        }

        return new DeliveryResult($status, $body);
    }
}
