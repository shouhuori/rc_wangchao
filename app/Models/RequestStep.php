<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class RequestStep extends Model
{
    use HasUuids;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['endpoint_snapshot' => 'array', 'input_mapping' => 'array', 'depends_on' => 'array', 'output' => 'encrypted:array', 'available_at' => 'datetime', 'expires_at' => 'datetime', 'enqueued_until' => 'datetime', 'lease_until' => 'datetime'];
    }

    public function task()
    {
        return $this->belongsTo(DeliveryTask::class, 'task_id');
    }

    public function attempts()
    {
        return $this->hasMany(Attempt::class, 'step_id')->orderBy('number');
    }

    public function provider()
    {
        return $this->belongsTo(Provider::class);
    }
}
