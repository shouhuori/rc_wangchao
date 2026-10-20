<?php

namespace Tests\Feature;

use App\Dispatch\Publisher;
use App\Drivers\Registry;
use App\Models\Endpoint;
use App\Models\Provider;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class SupplierDriverTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['dispatch.allow_local_targets' => true]);
        $this->seed();
        $this->actingAs(User::factory()->create());
    }

    public function test_generic_transport_cannot_be_selected_for_new_supplier(): void
    {
        $this->post('/providers', ['id' => 'new.crm', 'name' => 'CRM', 'driver' => 'json-http.v1', 'base_url' => 'https://example.com', 'credentials' => '{}', 'settings' => '{}'])->assertSessionHasErrors('driver');
        $this->assertDatabaseMissing('providers', ['id' => 'new.crm']);
    }

    public function test_supplier_operation_owns_http_protocol_and_idempotency(): void
    {
        $this->post('/endpoints', ['id' => 'crm.custom-paid', 'name' => '更新付费状态', 'provider_id' => 'demo.crm', 'operation' => 'contact.mark-paid', 'method' => 'DELETE', 'path' => '/arbitrary', 'options' => '{"timeout":7,"idempotent":false,"success_codes":[202]}', 'enabled' => '1'])->assertSessionHasNoErrors()->assertRedirect();
        $e = Endpoint::findOrFail('crm.custom-paid');
        $this->assertSame('PATCH', $e->method);
        $this->assertSame('/contacts/{contact_id}/paid', $e->path);
        $this->assertSame('contact.mark-paid', $e->operation);
        $this->assertSame(['timeout' => 7, 'idempotent' => true], $e->options);
    }

    public function test_operation_from_another_supplier_is_rejected(): void
    {
        $this->post('/endpoints', ['id' => 'wrong.operation', 'name' => 'Wrong', 'provider_id' => 'demo.crm', 'operation' => 'stock.reserve', 'options' => '{"timeout":10}', 'enabled' => '1'])->assertSessionHasErrors('operation');
        $this->assertDatabaseMissing('endpoints', ['id' => 'wrong.operation']);
    }

    public function test_existing_connection_cannot_switch_supplier_implementation(): void
    {
        $p = Provider::findOrFail('demo.crm');
        $this->post('/providers/'.$p->id, ['id' => $p->id, 'name' => $p->name, 'driver' => 'demo.sms.v1', 'base_url' => $p->base_url, 'credentials' => '{"api_key":"x"}', 'settings' => '{}'])->assertSessionHasErrors('driver');
        $this->assertSame('demo.crm.v1', $p->fresh()->driver);
    }

    public function test_publish_resolves_operation_from_code_and_pins_it(): void
    {
        $ep = Endpoint::findOrFail('crm.contact.paid');
        $ep->update(['method' => 'DELETE', 'path' => '/wrong', 'options' => ['timeout' => 8, 'idempotent' => false]]);
        $version = app(Publisher::class)->publish('order.paid', 'test');
        $snapshot = $version->definition['tasks'][1]['steps'][1]['endpoint_snapshot'];
        $this->assertSame('demo.crm.v1', $snapshot['driver']);
        $this->assertSame('contact.mark-paid', $snapshot['operation']);
        $this->assertSame('PATCH', $snapshot['method']);
        $this->assertTrue($snapshot['options']['idempotent']);
        $this->assertSame(8, $snapshot['options']['timeout']);
    }

    public function test_publish_rejects_unknown_or_removed_operation(): void
    {
        Endpoint::findOrFail('crm.contact.paid')->update(['operation' => 'removed.operation']);
        $this->expectException(ValidationException::class);
        app(Publisher::class)->publish('order.paid', 'test');
    }

    public function test_old_transport_snapshot_remains_executable_but_is_not_offered(): void
    {
        $r = app(Registry::class)->get('json-http.v1')->prepare(['method' => 'POST', 'path' => '/old'], [], ['id' => 1], 'same-key');
        $this->assertSame('/old', $r->path);
        $this->assertNotContains('json-http.v1', array_column(app(Registry::class)->all(), 'id'));
    }
}
