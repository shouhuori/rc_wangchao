<?php

namespace Tests\Feature;

use App\Dispatch\Converter;
use App\Dispatch\Coordinator;
use App\Dispatch\Executor;
use App\Dispatch\ManualActions;
use App\Dispatch\Publisher;
use App\Dispatch\Recovery;
use App\Models\Attempt;
use App\Models\NotificationEvent;
use App\Models\Provider;
use App\Models\RequestStep;
use App\Models\User;
use App\Models\Workflow;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Factory;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class DispatchTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->createSource();
        config(['dispatch.allow_local_targets' => true]);
        $this->seed();
        Http::preventStrayRequests();
        $this->fakeHttp(['*' => Http::response(['id' => 'contact-9', 'ok' => true], 200)]);
    }

    private function fakeHttp(array $responses): void
    {
        Http::swap(new Factory);
        Http::preventStrayRequests();
        Http::fake($responses);
    }

    private function accepted(array $extra = []): NotificationEvent
    {
        $r = $this->withToken('test-token')->postJson('/api/events', array_replace(['id' => 'evt-1', 'type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c-7']], $extra))->assertStatus(202);

        return NotificationEvent::findOrFail($r->json('id'));
    }

    private function converted(array $extra = []): NotificationEvent
    {
        $e = $this->accepted($extra);
        app(Converter::class)->convert($e->id);
        app(Coordinator::class)->refresh($e->id);

        return $e->fresh();
    }

    private function step(NotificationEvent $e, string $key): RequestStep
    {
        return RequestStep::whereHas('task', fn ($q) => $q->where('event_id', $e->id))->where('key', $key)->firstOrFail();
    }

    private function executeStep(RequestStep $step): void
    {
        Provider::query()->update(['next_request_at' => null]);
        app(Executor::class)->execute($step->id);
    }

    public function test_conversion_is_idempotent_and_dependencies_release_only_after_success(): void
    {
        $e = $this->converted();
        app(Converter::class)->convert($e->id);
        $this->assertSame(3, $e->tasks()->count());
        $this->assertDatabaseCount('request_steps', 4);
        $this->assertSame('waiting', $this->step($e, 'send')->status);
        $this->assertSame('waiting', $this->step($e, 'mark-paid')->status);
        $this->executeStep($this->step($e, 'reserve'));
        $this->assertSame('ready', $this->step($e, 'send')->status);
        $this->executeStep($this->step($e, 'create'));
        $this->executeStep($this->step($e, 'mark-paid'));
        $attempt = $this->step($e, 'mark-paid')->attempts()->first();
        $this->assertSame('contact-9', $attempt->request['body']['contact_id']);
    }

    public function test_retry_keeps_key_and_history_without_repeating_successful_steps(): void
    {
        $e = $this->converted();
        $this->fakeHttp(['*' => Http::sequence()->push(['error' => 'unavailable'], 503)->push(['id' => 'ok', 'ok' => true], 200)]);
        $step = $this->step($e, 'reserve');
        $this->executeStep($step);
        $this->assertSame('retry', $step->fresh()->status);
        $this->assertSame('waiting', $this->step($e, 'send')->status);
        $this->travel(600)->seconds();
        $this->executeStep($step);
        $this->assertSame('succeeded', $step->fresh()->status);
        $this->executeStep($step);
        $attempts = $step->attempts()->get();
        $this->assertCount(2, $attempts);
        $this->assertSame($attempts[0]->request['headers']['Idempotency-Key'], $attempts[1]->request['headers']['Idempotency-Key']);
    }

    public function test_permanent_failure_blocks_descendants_but_not_other_suppliers(): void
    {
        $e = $this->converted();
        $this->fakeHttp(['*' => Http::response(['error' => 'bad request'], 400)]);
        $this->executeStep($this->step($e, 'reserve'));
        $this->assertSame('dead', $this->step($e, 'reserve')->status);
        $this->assertSame('blocked', $this->step($e, 'send')->status);
        $this->assertSame('ready', $this->step($e, 'create')->status);
    }

    public function test_exhausted_retries_become_dead_letters(): void
    {
        $e = $this->converted();
        $this->fakeHttp(['*' => Http::response([], 503)]);
        $s = $this->step($e, 'reserve');
        $s->update(['max_attempts' => 2]);
        $this->executeStep($s);
        $this->travel(600)->seconds();
        $this->executeStep($s);
        $this->travel(600)->seconds();
        $this->executeStep($s);
        $this->assertSame('dead', $s->fresh()->status);
        $this->assertSame(2, $s->attempts()->count());
    }

    public function test_disabled_provider_does_not_consume_attempt(): void
    {
        $e = $this->converted();
        Provider::find('demo.inventory')->update(['enabled' => false]);
        $s = $this->step($e, 'reserve');
        $this->executeStep($s);
        $this->assertSame(0, $s->fresh()->attempt_count);
        $this->assertSame('ready', $s->fresh()->status);
    }

    public function test_expired_lease_recovers_unknown_attempt_and_preserves_budget(): void
    {
        $e = $this->converted();
        $s = $this->step($e, 'reserve');
        $s->update(['status' => 'running', 'lease_token' => 'old', 'lease_until' => now()->subMinute(), 'attempt_count' => 1, 'cycle_attempts' => 1]);
        Attempt::create(['step_id' => $s->id, 'number' => 1, 'token' => 'old', 'status' => 'running']);
        app(Recovery::class)->recover();
        $this->assertSame('retry', $s->fresh()->status);
        $this->assertSame('unknown', $s->attempts()->first()->status);
        $this->assertSame(1, $s->fresh()->cycle_attempts);
    }

    public function test_accepted_but_incomplete_response_does_not_release_dependency(): void
    {
        $e = $this->converted();
        $this->fakeHttp(['*' => Http::response(['pending' => true], 202)]);
        $this->executeStep($this->step($e, 'reserve'));
        $this->assertSame('unknown', $this->step($e, 'reserve')->status);
        $this->assertSame('blocked', $this->step($e, 'send')->status);
    }

    public function test_cross_event_predecessor_can_arrive_later(): void
    {
        $child = $this->converted(['id' => 'child', 'predecessor_id' => 'parent']);
        $this->assertSame('waiting', $this->step($child, 'reserve')->status);
        $parent = $this->converted(['id' => 'parent']);
        foreach (['reserve', 'create', 'mark-paid', 'send'] as $key) {
            $this->executeStep($this->step($parent, $key));
        }
        app(Coordinator::class)->refresh($child->id);
        $this->assertSame('ready', $this->step($child, 'reserve')->status);
    }

    public function test_conversion_failure_is_atomic_and_visible(): void
    {
        $e = $this->accepted();
        $v = $e->version;
        $d = $v->definition;
        $d['tasks'][1]['steps'][0]['endpoint_snapshot'] = null;
        $v->update(['definition' => $d]);
        app(Converter::class)->convert($e->id);
        $this->assertSame('failed', $e->fresh()->conversion_status);
        $this->assertSame(0, $e->tasks()->count());
    }

    public function test_publisher_rejects_cycles_and_snapshots_versions(): void
    {
        $w = Workflow::first();
        $d = $w->draft;
        $d['tasks'][0]['depends_on'] = ['sms.confirm'];
        $w->update(['draft' => $d]);
        try {
            app(Publisher::class)->publish($w->id, 'test');
            $this->fail('Cycle accepted');
        } catch (ValidationException $e) {
            $this->assertNotEmpty($e->errors());
        }
        $this->assertSame(1, $w->versions()->count());
    }

    public function test_manual_retry_preserves_successful_steps_and_is_audited(): void
    {
        $e = $this->converted();
        $this->executeStep($this->step($e, 'create'));
        $this->fakeHttp(['*' => Http::response([], 400)]);
        $s = $this->step($e, 'mark-paid');
        $this->executeStep($s);
        app(ManualActions::class)->retry($s->id, 'operator', '已修复参数并核对目标状态');
        $this->assertSame('succeeded', $this->step($e, 'create')->status);
        $this->assertSame('ready', $s->fresh()->status);
        $this->assertDatabaseHas('audit_entries', ['action' => 'step.retry', 'subject' => $s->id]);
    }

    public function test_rate_limited_job_releases_queue_reservation_for_prompt_rescheduling(): void
    {
        $e = $this->converted();
        $step = $this->step($e, 'reserve');
        $step->update(['enqueued_until' => now()->addSeconds(120)]);
        Provider::find('demo.inventory')->update(['next_request_at' => now()->addSeconds(5)]);
        app(Executor::class)->execute($step->id);
        $this->assertNull($step->fresh()->enqueued_until);
        $this->assertSame(0, $step->fresh()->attempt_count);
    }

    public function test_stale_attempt_result_cannot_overwrite_a_recovered_step(): void
    {
        $e = $this->converted();
        $step = $this->step($e, 'reserve');
        $step->update(['status' => 'running', 'lease_token' => 'new-token', 'lease_until' => now()->addMinute()]);
        app(Executor::class)->finish($step->id, 'old-token', 'succeeded', 200, ['id' => 'wrong'], null, 5);
        $this->assertSame('running', $step->fresh()->status);
        $this->assertNull($step->fresh()->output);
    }

    public function test_non_idempotent_timeout_requires_manual_reconciliation(): void
    {
        $e = $this->converted();
        $step = $this->step($e, 'reserve');
        $snapshot = $step->endpoint_snapshot;
        $snapshot['options']['idempotent'] = false;
        $step->update(['endpoint_snapshot' => $snapshot]);
        Http::swap(new Factory);
        Http::fake(fn () => throw new ConnectionException('timeout'));
        $this->executeStep($step);
        $this->assertSame('unknown', $step->fresh()->status);
        try {
            app(ManualActions::class)->retry($step->id, 'operator', 'retry', false);
            $this->fail('Unknown result retried without confirmation');
        } catch (ValidationException $error) {
            $this->assertNotEmpty($error->errors());
        }
    }

    public function test_subscription_filter_skips_unmatched_task_and_blocks_its_dependents(): void
    {
        $w = Workflow::first();
        $d = $w->activeVersion->definition;
        $d['tasks'][0]['when'] = ['payload.channel' => 'ads'];
        $w->activeVersion->update(['definition' => $d]);
        $e = $this->converted();
        $this->assertSame('skipped', $e->tasks()->where('key', 'inventory.reserve')->first()->status);
        $this->assertSame('blocked', $this->step($e, 'send')->status);
        $this->assertSame('ready', $this->step($e, 'create')->status);
    }

    public function test_operator_confirmation_requires_verification_and_releases_dependencies_without_resending(): void
    {
        $e = $this->converted();
        $this->fakeHttp(['*' => Http::response(['accepted' => true], 202)]);
        $step = $this->step($e, 'reserve');
        $this->executeStep($step);
        $this->actingAs(User::factory()->create());
        $url = '/requests/'.$step->id.'/confirm';
        $this->post($url, ['reason' => '模拟供应商已完成', 'output' => '{}'])->assertSessionHasErrors('verified');
        $this->assertSame('unknown', $step->fresh()->status);
        $this->post($url, ['reason' => '模拟供应商已完成', 'output' => '{"id":"verified-reservation"}', 'verified' => '1'])->assertRedirect();
        $this->assertSame('succeeded', $step->fresh()->status);
        $this->assertSame('ready', $this->step($e, 'send')->status);
        $this->assertSame(1, $step->attempts()->count());
        $this->assertDatabaseHas('audit_entries', ['action' => 'step.confirm-success', 'subject' => $step->id]);
    }
}
