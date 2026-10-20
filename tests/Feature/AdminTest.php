<?php

namespace Tests\Feature;

use App\Models\Provider;
use App\Models\User;
use App\Models\Workflow;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['dispatch.allow_local_targets' => true]);
        $this->seed();
    }

    public function test_management_pages_require_login(): void
    {
        $this->get('/events')->assertRedirect('/login');
    }

    public function test_operator_can_view_management_pages(): void
    {
        $this->actingAs(User::factory()->create());
        foreach (['/', '/events', '/tasks', '/requests', '/dead-letters', '/providers', '/endpoints', '/workflows', '/audit'] as $path) {
            $this->get($path)->assertOk();
        }
    }

    public function test_credentials_are_not_rendered_and_blank_edit_preserves_them(): void
    {
        $this->actingAs(User::factory()->create());
        $p = Provider::findOrFail('demo.crm');
        $p->update(['credentials' => ['token' => 'SECRET-MUST-NOT-LEAK']]);
        $this->get('/providers/'.$p->id.'/edit')->assertOk()->assertDontSee('SECRET-MUST-NOT-LEAK');
        $this->post('/providers/'.$p->id, ['id' => $p->id, 'name' => 'Changed', 'driver' => $p->driver, 'base_url' => $p->base_url, 'credentials' => '', 'settings' => '{}', 'enabled' => '1'])->assertRedirect();
        $this->assertSame('SECRET-MUST-NOT-LEAK', $p->fresh()->credentials['token']);
        $this->assertDatabaseHas('audit_entries', ['action' => 'provider.save', 'subject' => $p->id]);
    }

    public function test_invalid_driver_cannot_be_saved(): void
    {
        $this->actingAs(User::factory()->create());
        $this->post('/providers', ['id' => 'bad', 'name' => 'Bad', 'driver' => 'unknown', 'base_url' => 'https://example.com', 'credentials' => '{}', 'settings' => '{}', 'enabled' => '1'])->assertSessionHasErrors('driver');
        $this->assertDatabaseMissing('providers', ['id' => 'bad']);
    }

    public function test_publishing_creates_immutable_version_and_keeps_old_snapshot(): void
    {
        $this->actingAs(User::factory()->create());
        $w = Workflow::first();
        $old = $w->active_version_id;
        $this->post('/workflows/'.$w->id.'/publish')->assertRedirect();
        $this->assertNotSame($old, $w->fresh()->active_version_id);
        $this->assertSame(2, $w->versions()->count());
    }

    public function test_invalid_provider_form_never_flashes_credentials_into_session(): void
    {
        $this->actingAs(User::factory()->create());
        $this->post('/providers', ['id' => 'test.provider', 'name' => '', 'driver' => 'json-http.v1', 'base_url' => 'https://example.com', 'credentials' => '{"token":"PRIVATE-SECRET"}', 'settings' => '{}'])->assertSessionHasErrors('name');
        $this->assertNull(session('_old_input.credentials'));
    }
}
