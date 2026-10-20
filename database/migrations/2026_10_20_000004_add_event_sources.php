<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('event_sources', function (Blueprint $table) {
            $table->string('id', 100)->primary();
            $table->string('name', 150);
            $table->string('token_hash', 64)->nullable()->unique();
            $table->boolean('enabled')->default(false);
            $table->timestamp('token_issued_at')->nullable();
            $table->timestamps();
        });
        // Historical identities remain visible but receive no credential automatically.
        foreach (DB::table('notification_events')->distinct()->pluck('source') as $source) {
            DB::table('event_sources')->insert([
                'id' => $source, 'name' => $source, 'enabled' => false,
                'created_at' => now(), 'updated_at' => now(),
            ]);
        }
        Schema::table('notification_events', function (Blueprint $table) {
            $table->unsignedTinyInteger('fingerprint_version')->default(1);
            $table->dropIndex(['source', 'business_key']);
            $table->dropColumn('business_key');
        });
        // This column has always held internal lock names, not business object identifiers.
        Schema::table('event_streams', fn (Blueprint $table) => $table->renameColumn('business_key', 'lock_key'));
    }

    public function down(): void
    {
        Schema::table('event_streams', fn (Blueprint $table) => $table->renameColumn('lock_key', 'business_key'));
        Schema::table('notification_events', function (Blueprint $table) {
            $table->string('business_key', 150)->nullable();
            $table->index(['source', 'business_key']);
            $table->dropColumn('fingerprint_version');
        });
        Schema::dropIfExists('event_sources');
    }
};
