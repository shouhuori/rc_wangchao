<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('endpoints', fn (Blueprint $t) => $t->string('operation', 100)->nullable()->after('provider_id'));
    }

    public function down(): void
    {
        Schema::table('endpoints', fn (Blueprint $t) => $t->dropColumn('operation'));
    }
};
