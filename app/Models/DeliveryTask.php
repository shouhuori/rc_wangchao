<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class DeliveryTask extends Model
{
    use HasUuids;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['depends_on' => 'array', 'paused' => 'boolean'];
    }

    public function event()
    {
        return $this->belongsTo(NotificationEvent::class, 'event_id');
    }

    public function steps()
    {
        return $this->hasMany(RequestStep::class, 'task_id');
    }
}
