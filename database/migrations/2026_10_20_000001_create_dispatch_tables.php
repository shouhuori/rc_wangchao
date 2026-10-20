<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('providers', function (Blueprint $t) {
            $t->string('id', 100)->primary();
            $t->string('name');
            $t->string('driver');
            $t->string('base_url');
            $t->text('credentials')->nullable();
            $t->json('settings');
            $t->boolean('enabled')->default(true);
            $t->unsignedInteger('failure_streak')->default(0);
            $t->timestamp('circuit_until')->nullable();
            $t->uuid('busy_token')->nullable();
            $t->timestamp('busy_until')->nullable();
            $t->timestamp('next_request_at')->nullable();
            $t->timestamps();
        });
        Schema::create('endpoints', function (Blueprint $t) {
            $t->string('id', 100)->primary();
            $t->string('provider_id', 100);
            $t->foreign('provider_id')->references('id')->on('providers');
            $t->string('name');
            $t->string('method', 10);
            $t->string('path');
            $t->json('options');
            $t->boolean('enabled')->default(true);
            $t->timestamps();
        });
        Schema::create('workflows', function (Blueprint $t) {
            $t->string('id', 100)->primary();
            $t->string('name');
            $t->string('event_type', 100)->unique();
            $t->json('draft');
            $t->uuid('active_version_id')->nullable();
            $t->boolean('enabled')->default(true);
            $t->timestamps();
        });
        Schema::create('workflow_versions', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('workflow_id', 100);
            $t->foreign('workflow_id')->references('id')->on('workflows');
            $t->unsignedInteger('number');
            $t->json('definition');
            $t->timestamps();
            $t->unique(['workflow_id', 'number']);
        });
        Schema::create('event_streams', function (Blueprint $t) {
            $t->id();
            $t->string('source', 100);
            $t->string('business_key', 150);
            $t->unique(['source', 'business_key']);
        });
        Schema::create('notification_events', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('external_id', 150);
            $t->string('source', 100);
            $t->string('type', 100);
            $t->string('business_key', 150);
            $t->string('predecessor_id', 150)->nullable();
            $t->json('payload');
            $t->string('fingerprint', 64);
            $t->foreignUuid('version_id')->constrained('workflow_versions');
            $t->string('conversion_status', 24)->default('pending')->index();
            $t->text('conversion_error')->nullable();
            $t->timestamps();
            $t->unique(['source', 'external_id']);
            $t->index(['source', 'business_key']);
        });
        Schema::create('delivery_tasks', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('event_id')->constrained('notification_events');
            $t->string('key', 100);
            $t->string('name');
            $t->string('status', 24)->default('waiting')->index();
            $t->json('depends_on');
            $t->boolean('paused')->default(false);
            $t->timestamps();
            $t->unique(['event_id', 'key']);
        });
        Schema::create('request_steps', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('task_id')->constrained('delivery_tasks');
            $t->string('key', 100);
            $t->string('name');
            $t->string('provider_id', 100);
            $t->foreign('provider_id')->references('id')->on('providers');
            $t->json('endpoint_snapshot');
            $t->json('input_mapping');
            $t->json('depends_on');
            $t->string('status', 24)->default('waiting');
            $t->unsignedInteger('attempt_count')->default(0);
            $t->unsignedInteger('cycle_attempts')->default(0);
            $t->unsignedInteger('max_attempts')->default(5);
            $t->timestamp('available_at');
            $t->timestamp('expires_at');
            $t->timestamp('enqueued_until')->nullable();
            $t->uuid('lease_token')->nullable();
            $t->timestamp('lease_until')->nullable();
            $t->string('idempotency_key', 64)->unique();
            $t->text('last_error')->nullable();
            $t->longText('output')->nullable();
            $t->timestamps();
            $t->unique(['task_id', 'key']);
            $t->index(['status', 'available_at']);
            $t->index(['status', 'lease_until']);
        });
        Schema::create('attempts', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('step_id')->constrained('request_steps');
            $t->unsignedInteger('number');
            $t->uuid('token');
            $t->string('status', 24);
            $t->json('request')->nullable();
            $t->json('response')->nullable();
            $t->unsignedInteger('status_code')->nullable();
            $t->unsignedInteger('duration_ms')->nullable();
            $t->text('error')->nullable();
            $t->timestamp('finished_at')->nullable();
            $t->timestamps();
            $t->unique(['step_id', 'number']);
        });
        Schema::create('audit_entries', function (Blueprint $t) {
            $t->id();
            $t->string('actor');
            $t->string('action');
            $t->string('subject');
            $t->json('details');
            $t->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['audit_entries', 'attempts', 'request_steps', 'delivery_tasks', 'notification_events', 'event_streams', 'workflow_versions', 'workflows', 'endpoints', 'providers'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
