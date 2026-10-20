<?php

namespace Tests\Feature;

use App\Dispatch\Converter;
use App\Dispatch\Coordinator;
use App\Dispatch\Executor;
use App\Dispatch\Publisher;
use App\Dispatch\Recovery;
use App\Dispatch\TargetGuard;
use App\Jobs\ExecuteStep;
use App\Models\NotificationEvent;
use App\Models\Provider;
use App\Models\RequestStep;
use App\Models\Workflow;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class SafetyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->createSource('shop', 'test');
        config(['dispatch.allow_local_targets' => true]);
        $this->seed();
    }

    private function event(): NotificationEvent
    {
        $r = $this->withToken('test')->postJson('/api/events', ['id' => 'test', 'type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c']])->assertStatus(202);
        $e = NotificationEvent::findOrFail($r->json('id'));
        app(Converter::class)->convert($e->id);
        app(Coordinator::class)->refresh($e->id);

        return $e;
    }

    public function test_due_scanner_does_not_enqueue_busy_or_rate_limited_suppliers(): void
    {
        $this->event();
        Provider::find('demo.inventory')->update(['next_request_at' => now()->addHour()]);
        Bus::fake();
        app(Recovery::class)->tick();
        Bus::assertDispatched(ExecuteStep::class, 1);
        $crm = RequestStep::where('key', 'create')->first();
        $inventory = RequestStep::where('key', 'reserve')->first();
        $this->assertNotNull($crm->enqueued_until);
        $this->assertNull($inventory->enqueued_until);
    }

    public function test_queue_outage_keeps_durable_work_and_releases_reservation(): void
    {
        $e = $this->event();
        Bus::shouldReceive('dispatch')->once()->andThrow(new \RuntimeException('queue unavailable'));
        app(Recovery::class)->tick();
        $this->assertDatabaseCount('request_steps', 4);
        $this->assertSame(0, RequestStep::whereNotNull('enqueued_until')->count());
        $this->assertSame('converted', $e->fresh()->conversion_status);
    }

    public function test_publish_rejects_disabled_dependencies_and_invalid_output_reference(): void
    {
        $w = Workflow::first();
        $d = $w->draft;
        $d['tasks'][0]['enabled'] = false;
        try {
            app(Publisher::class)->validate($d);
            $this->fail('Disabled dependency accepted');
        } catch (ValidationException $e) {
            $this->assertNotEmpty($e->errors());
        }
        $d = $w->draft;
        $d['tasks'][0]['steps'][0]['input'] = ['id' => '$steps.missing.output.id'];
        try {
            app(Publisher::class)->validate($d);
            $this->fail('Unknown output reference accepted');
        } catch (ValidationException $e) {
            $this->assertNotEmpty($e->errors());
        }
    }

    public function test_private_target_is_rejected_without_network_access(): void
    {
        $e = $this->event();
        $step = RequestStep::where('key', 'reserve')->first();
        $ep = $step->endpoint_snapshot;
        $ep['base_url'] = 'https://169.254.169.254';
        $step->update(['endpoint_snapshot' => $ep]);
        Http::preventStrayRequests();
        app(Executor::class)->execute($step->id);
        $this->assertSame('dead', $step->fresh()->status);
        Http::assertNothingSent();
    }

    public function test_missing_input_is_a_permanent_visible_failure(): void
    {
        $this->event();
        $step = RequestStep::where('key', 'reserve')->first();
        $step->update(['input_mapping' => ['id' => '$event.payload.does_not_exist']]);
        Http::preventStrayRequests();
        app(Executor::class)->execute($step->id);
        $this->assertSame('dead', $step->fresh()->status);
        $this->assertSame(1, $step->attempts()->count());
        Http::assertNothingSent();
    }

    public function test_shared_and_multicast_addresses_cannot_be_targets(): void
    {
        config(['dispatch.allow_local_targets' => false]);
        foreach (['https://100.64.0.1', 'https://224.0.0.1', 'https://[::ffff:127.0.0.1]'] as $url) {
            try {
                app(TargetGuard::class)->curlOptions($url, '/');
                $this->fail('Restricted target accepted: '.$url);
            } catch (ValidationException $e) {
                $this->assertNotEmpty($e->errors());
            }
        }
    }

    public function test_zero_string_is_a_real_predecessor_identifier(): void
    {
        $r = $this->withToken('test')->postJson('/api/events', ['id' => 'child', 'type' => 'order.paid.v1', 'predecessor_id' => '0', 'payload' => ['order_id' => '42']])->assertStatus(202);
        app(Converter::class)->convert($r->json('id'));
        app(Coordinator::class)->refresh($r->json('id'));
        $this->assertSame('waiting', RequestStep::where('key', 'reserve')->first()->status);
        $this->postJson('/api/events', ['id' => '0', 'type' => 'order.paid.v1', 'predecessor_id' => 'child', 'payload' => ['order_id' => '42']])->assertUnprocessable();
    }
}
