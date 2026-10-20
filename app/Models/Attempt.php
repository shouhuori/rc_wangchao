<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Attempt extends Model
{
    use HasUuids;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['request' => 'array', 'response' => 'array', 'finished_at' => 'datetime'];
    }

    public function step()
    {
        return $this->belongsTo(RequestStep::class, 'step_id');
    }
}
