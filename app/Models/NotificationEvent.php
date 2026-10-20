<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class NotificationEvent extends Model
{
    use HasUuids;

    protected $guarded = [];

    protected $dateFormat = 'Y-m-d H:i:s.u';

    protected function casts(): array
    {
        return ['payload' => 'array', 'occurred_at' => 'immutable_datetime'];
    }

    public function tasks()
    {
        return $this->hasMany(DeliveryTask::class, 'event_id');
    }

    public function version()
    {
        return $this->belongsTo(WorkflowVersion::class);
    }
}
