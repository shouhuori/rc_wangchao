<?php

namespace Tests\Feature;

use App\Dispatch\Redactor;
use App\Drivers\Registry;
use Illuminate\Http\Client\Response;
use Tests\TestCase;

class SupplierProtocolTest extends TestCase
{
    private function response(int $code, array $body): Response
    {
        return new Response(new \GuzzleHttp\Psr7\Response($code, ['Content-Type' => 'application/json'], json_encode($body)));
    }

    public function test_crm_class_builds_different_operations_and_controls_business_success(): void
    {
        $driver = app(Registry::class)->get('demo.crm.v1');
        $create = $driver->prepare(['operation' => 'contact.create'], ['token' => 'crm-token'], ['contact_id' => 'external-7'], 'key-1');
        $paid = $driver->prepare(['operation' => 'contact.mark-paid', 'method' => 'DELETE', 'path' => '/wrong'], ['token' => 'crm-token'], ['contact_id' => 'c/7', 'order_id' => 'o-1'], 'key-2');
        $this->assertSame('POST', $create->method);
        $this->assertSame(['external_id' => 'external-7'], json_decode($create->body, true));
        $this->assertSame('PATCH', $paid->method);
        $this->assertSame('/contacts/c%2F7/paid', $paid->path);
        $this->assertSame('paid', json_decode($paid->body, true)['status']);
        $this->assertSame('Bearer crm-token', $paid->headers['Authorization']);
        $this->assertSame('dead', $driver->interpret(['operation' => 'contact.create'], $this->response(200, ['error' => 'invalid']))->status);
        $this->assertSame('succeeded', $driver->interpret(['operation' => 'contact.create'], $this->response(201, ['id' => 'new-c']))->status);
        $this->assertSame('dead', $driver->interpret(['operation' => 'contact.mark-paid'], $this->response(200, ['ok' => false]))->status);
        $this->assertSame('unknown', $driver->interpret(['operation' => 'contact.mark-paid'], $this->response(202, ['ok' => true]))->status);
    }

    public function test_inventory_signs_actual_payload_and_sms_encodes_its_own_form(): void
    {
        $inventory = app(Registry::class)->get('demo.inventory.v1')->prepare(['operation' => 'stock.reserve'], ['key_id' => 'client', 'secret' => 'private'], ['order_id' => 'o-1'], 'key');
        $this->assertSame('/reserve', $inventory->path);
        $this->assertSame(hash_hmac('sha256', $inventory->headers['X-Timestamp']."\n".$inventory->body, 'private'), $inventory->headers['X-Signature']);
        $sms = app(Registry::class)->get('demo.sms.v1')->prepare(['operation' => 'order.confirm'], ['api_key' => 'private'], ['order_id' => 'a & b'], 'key');
        $this->assertSame('application/x-www-form-urlencoded', $sms->headers['Content-Type']);
        $this->assertSame('private', $sms->headers['X-Api-Key']);
        $this->assertSame('template=order.confirmed&order_id=a%20%26%20b&request_id=key', $sms->body);
    }

    public function test_unknown_supplier_operation_is_not_sent_as_a_generic_http_request(): void
    {
        $driver = app(Registry::class)->get('demo.crm.v1');
        $this->expectException(\InvalidArgumentException::class);
        $driver->prepare(['operation' => 'stock.reserve', 'method' => 'POST', 'path' => '/reserve'], ['token' => 'x'], ['order_id' => '1'], 'k');
    }

    public function test_supplier_api_credentials_are_redacted_from_request_history(): void
    {
        $safe = Redactor::clean(['headers' => ['X-Api-Key' => 'private'], 'nested' => ['api_key' => 'private']]);
        $this->assertSame('[已隐藏]', $safe['headers']['X-Api-Key']);
        $this->assertSame('[已隐藏]', $safe['nested']['api_key']);
    }
}
