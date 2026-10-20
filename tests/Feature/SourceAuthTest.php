<?php

namespace Tests\Feature;

use App\Dispatch\Converter;
use App\Dispatch\Coordinator;
use App\Dispatch\EventFingerprint;
use App\Models\AuditEntry;
use App\Models\EventSource;
use App\Models\NotificationEvent;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SourceAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_identity_replaces_caller_supplied_source_and_business_key(): void
    {
        $this->seed();
        $this->createSource();
        $this->withToken('test-token')->postJson('/api/events', [
            'id' => 'event-1', 'type' => 'order.paid.v1',
            'payload' => ['order_id' => '42', 'contact_id' => 'c'],
        ])->assertStatus(202);
        $this->assertSame('shop', NotificationEvent::firstOrFail()->source);
    }

    public function test_retired_body_fields_are_rejected_instead_of_trusted(): void
    {
        $this->seed();
        $this->createSource();
        $this->withToken('test-token')->postJson('/api/events', [
            'id' => 'event-1', 'source' => 'spoofed', 'business_key' => '42', 'type' => 'order.paid.v1',
            'payload' => ['order_id' => '42', 'contact_id' => 'c'],
        ])->assertUnprocessable()->assertJsonValidationErrors(['source', 'business_key']);
        $this->assertDatabaseCount('notification_events', 0);
    }

    public function test_source_tokens_isolate_deduplication_and_predecessors(): void
    {
        $this->seed();
        $this->createSource();
        $this->createSource('crm', 'crm-token');
        $body = ['id' => 'parent', 'type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c']];
        $shop = $this->withToken('test-token')->postJson('/api/events', $body)->assertStatus(202);
        $crm = $this->withToken('crm-token')->postJson('/api/events', $body)->assertStatus(202);
        $this->assertNotSame($shop->json('id'), $crm->json('id'));
        $this->postJson('/api/events', $body)->assertOk()->assertJson(['id' => $crm->json('id'), 'duplicate' => true]);
        $this->postJson('/api/events', array_replace($body, ['payload' => ['order_id' => 'different']]))->assertStatus(409);
        $parent = $this->withToken('test-token')->postJson('/api/events', array_replace($body, ['id' => 'shop-only']))->assertStatus(202);
        app(Converter::class)->convert($parent->json('id'));
        NotificationEvent::findOrFail($parent->json('id'))->tasks()->update(['status' => 'succeeded']);
        $child = $this->withToken('crm-token')->postJson('/api/events', array_replace($body, ['id' => 'child', 'predecessor_id' => 'shop-only']))->assertStatus(202);
        app(Converter::class)->convert($child->json('id'));
        app(Coordinator::class)->refresh($child->json('id'));
        $this->assertSame(['waiting'], NotificationEvent::findOrFail($child->json('id'))->tasks()->pluck('status')->unique()->values()->all());
        $this->actingAs(User::factory()->create())->get('/events/'.$child->json('id'))->assertSee('尚未收到');
    }

    public function test_invalid_disabled_and_old_shared_tokens_are_rejected(): void
    {
        $source = $this->createSource();
        config(['dispatch.api_token' => 'old-shared-token']);
        $this->postJson('/api/events', [])->assertUnauthorized();
        $this->withToken('old-shared-token')->postJson('/api/events', [])->assertUnauthorized();
        $this->withToken('wrong')->postJson('/api/events', [])->assertUnauthorized();
        $source->update(['enabled' => false]);
        $this->withToken('test-token')->postJson('/api/events', [])->assertUnauthorized();
    }

    public function test_legacy_events_still_deduplicate_after_removing_business_key(): void
    {
        $this->seed();
        $this->createSource();
        $body = ['id' => 'legacy', 'type' => 'order.paid.v1', 'occurred_at' => '2026-10-19T09:30:00.123+08:00',
            'payload' => ['order_id' => '42', 'contact_id' => 'c']];
        $r = $this->withToken('test-token')->postJson('/api/events', $body)->assertStatus(202);
        $event = NotificationEvent::findOrFail($r->json('id'));
        $legacyFingerprint = EventFingerprint::make($body + ['source' => 'shop', 'business_key' => 'old-order', 'predecessor_id' => null]);
        $event->update(['fingerprint_version' => 1, 'fingerprint' => $legacyFingerprint]);
        $this->postJson('/api/events', $body)->assertOk()->assertJson(['id' => $event->id, 'duplicate' => true]);
        $this->postJson('/api/events', array_replace($body, ['payload' => ['order_id' => 'different']]))->assertStatus(409);
        $this->assertSame($legacyFingerprint, $event->fresh()->fingerprint);
        $this->assertDatabaseCount('notification_events', 1);
    }

    public function test_admin_issues_rotates_and_disables_source_tokens_without_exposing_them_again(): void
    {
        $this->seed();
        $this->get('/sources')->assertRedirect('/login');
        $this->post('/sources', [])->assertRedirect('/login');
        $this->actingAs(User::factory()->create());
        $r = $this->post('/sources', ['id' => 'shop', 'name' => '商城', 'enabled' => '1'])->assertCreated();
        $token = $r->viewData('token');
        $this->assertGreaterThanOrEqual(64, strlen($token));
        $this->assertStringContainsString('no-store', $r->headers->get('Cache-Control'));
        $source = EventSource::findOrFail('shop');
        $this->assertSame(hash('sha256', $token), $source->token_hash);
        $this->assertArrayNotHasKey('token_hash', $source->toArray());
        $this->get('/sources')->assertOk()->assertDontSee($token)->assertDontSee($source->token_hash);
        $this->get('/sources/shop/edit')->assertOk()->assertDontSee($token);
        $r = $this->post('/sources/shop/rotate')->assertOk();
        $new = $r->viewData('token');
        $this->assertNotSame($token, $new);
        $body = ['id' => 'event', 'type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c']];
        $this->withToken($token)->postJson('/api/events', $body)->assertUnauthorized();
        $this->withToken($new)->postJson('/api/events', $body)->assertStatus(202);
        $this->post('/sources/shop', ['name' => '商城停用'])->assertRedirect('/sources');
        $this->postJson('/api/events', $body)->assertUnauthorized();
        $this->post('/sources/shop', ['name' => '商城恢复', 'enabled' => '1'])->assertRedirect('/sources');
        $this->postJson('/api/events', $body)->assertOk();
        $this->assertDatabaseHas('audit_entries', ['action' => 'source.rotate', 'subject' => 'shop']);
        $this->assertStringNotContainsString($new, json_encode(AuditEntry::all()));
        $this->assertStringNotContainsString($new, json_encode(session()->all()));
    }

    public function test_zero_source_identifier_can_be_managed(): void
    {
        $this->actingAs(User::factory()->create());
        $this->post('/sources', ['id' => '0', 'name' => '数字来源', 'enabled' => '1'])->assertCreated();
        $response = $this->get('/sources/0/edit')->assertOk();
        $this->assertTrue($response->viewData('source')->exists);
        $this->assertSame('0', $response->viewData('source')->id);
        $this->post('/sources/0', ['name' => '数字来源'])->assertRedirect('/sources');
        $this->assertFalse(EventSource::findOrFail('0')->enabled);
    }
}
