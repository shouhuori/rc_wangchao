<?php

namespace Tests\Feature;

use App\Dispatch\Converter;
use App\Dispatch\InputMapper;
use App\Models\NotificationEvent;
use App\Models\User;
use App\Models\Workflow;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class IntakeTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->createSource();
        $this->seed();
    }

    private function event(array $changes = []): array
    {
        return array_replace(['id' => 'evt-1', 'type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c-7']], $changes);
    }

    public function test_intake_is_authenticated(): void
    {
        $this->postJson('/api/events', $this->event())->assertUnauthorized();
    }

    public function test_acceptance_is_durable_and_identical_retries_are_deduplicated(): void
    {
        $first = $this->withToken('test-token')->postJson('/api/events', $this->event())->assertStatus(202);
        $second = $this->withToken('test-token')->postJson('/api/events', $this->event())->assertStatus(200);
        $this->assertSame($first->json('id'), $second->json('id'));
        $this->assertDatabaseCount('notification_events', 1);
        $this->assertDatabaseHas('notification_events', ['external_id' => 'evt-1', 'conversion_status' => 'pending']);
    }

    public function test_duplicate_id_with_different_payload_is_a_conflict(): void
    {
        $this->withToken('test-token')->postJson('/api/events', $this->event())->assertStatus(202);
        $this->postJson('/api/events', $this->event(['payload' => ['order_id' => 'different']]))->assertStatus(409);
    }

    public function test_unknown_event_type_is_rejected(): void
    {
        $this->withToken('test-token')->postJson('/api/events', $this->event(['type' => 'unknown.v1']))->assertUnprocessable();
    }

    public function test_predecessor_cycle_is_rejected(): void
    {
        $this->withToken('test-token')->postJson('/api/events', $this->event(['id' => 'a', 'predecessor_id' => 'b']))->assertStatus(202);
        $this->postJson('/api/events', $this->event(['id' => 'b', 'predecessor_id' => 'a']))->assertUnprocessable();
    }

    public function test_published_payload_contract_is_validated_before_acceptance(): void
    {
        $w = Workflow::first();
        $d = $w->activeVersion->definition;
        $d['required_payload_fields'] = ['customer.email'];
        $w->activeVersion->update(['definition' => $d]);
        $this->withToken('test-token')->postJson('/api/events', $this->event())->assertUnprocessable();
        $this->assertDatabaseCount('notification_events', 0);
    }

    public function test_backpressure_counts_converted_but_unfinished_events(): void
    {
        config(['dispatch.max_pending' => 1]);
        $r = $this->withToken('test-token')->postJson('/api/events', $this->event())->assertStatus(202);
        app(Converter::class)->convert($r->json('id'));
        $this->postJson('/api/events', $this->event(['id' => 'evt-2']))->assertStatus(503);
        $this->postJson('/api/events', $this->event())->assertOk();
    }

    public function test_occurrence_time_survives_conversion_and_is_available_to_supplier_mapping(): void
    {
        $this->travelTo(now()->setDate(2026, 10, 20)->setTime(4, 0));
        $r = $this->withToken('test-token')->postJson('/api/events', $this->event([
            'occurred_at' => '2026-10-19T09:30:00.123456+08:00',
        ]))->assertStatus(202);
        $event = NotificationEvent::findOrFail($r->json('id'));
        $this->assertSame('2026-10-19T01:30:00.123456Z', $event->toArray()['occurred_at'] ?? null);
        $this->assertSame('2026-10-20 04:00:00', $event->created_at->format('Y-m-d H:i:s'));
        app(Converter::class)->convert($event->id);
        $step = $event->tasks()->firstOrFail()->steps()->firstOrFail();
        $step->update(['input_mapping' => ['event_time' => '$event.occurred_at']]);
        $this->assertSame(['event_time' => '2026-10-19T01:30:00.123456Z'], app(InputMapper::class)->resolve($step));
        $this->actingAs(User::factory()->create())->get('/events/'.$event->id)
            ->assertOk()->assertSee('2026-10-19 09:30:00.123456')->assertSee('2026-10-20 12:00:00');
    }

    public function test_equivalent_timezone_retries_deduplicate_but_changed_occurrence_time_conflicts(): void
    {
        $r = $this->withToken('test-token')->postJson('/api/events', $this->event([
            'occurred_at' => '2026-10-19T09:30:00.123+08:00',
        ]))->assertStatus(202);
        $this->postJson('/api/events', $this->event(['occurred_at' => '2026-10-19T01:30:00.123000Z']))
            ->assertOk()->assertJson(['id' => $r->json('id'), 'duplicate' => true]);
        $this->postJson('/api/events', $this->event(['occurred_at' => '2026-10-19T01:30:00.124Z']))
            ->assertStatus(409);
    }

    public function test_missing_occurrence_time_does_not_invent_a_time(): void
    {
        $r = $this->withToken('test-token')->postJson('/api/events', $this->event())->assertStatus(202);
        // Missing time and explicit null have the same identity.
        $old = $this->event(['source' => 'shop', 'predecessor_id' => null]);
        ksort($old);
        ksort($old['payload']);
        $event = NotificationEvent::findOrFail($r->json('id'));
        $this->assertSame(hash('sha256', json_encode($old)), $event->fingerprint);
        $this->assertArrayHasKey('occurred_at', $event->toArray());
        $this->assertNull($event->occurred_at);
        $this->postJson('/api/events', $this->event())->assertOk();
        $this->postJson('/api/events', $this->event(['occurred_at' => null]))->assertOk();
        $this->postJson('/api/events', $this->event(['occurred_at' => '2026-10-19T01:30:00Z']))->assertStatus(409);
    }

    public function test_invalid_or_timezone_free_occurrence_times_are_rejected_without_persistence(): void
    {
        foreach (['2026-10-19 09:30:00', '2026-10-19T09:30:00', '2026-02-30T09:30:00Z',
            '2026-10-19T25:30:00Z', '2026-10-19T09:30:00+25:00', 'yesterday',
            1792373400, [], '2026-10-19T09:30:00.1234567Z', '0999-10-19T09:30:00Z'] as $time) {
            $this->withToken('test-token')->postJson('/api/events', $this->event(['occurred_at' => $time]))
                ->assertUnprocessable()->assertJsonValidationErrors('occurred_at');
        }
        $this->assertDatabaseCount('notification_events', 0);
    }
}
