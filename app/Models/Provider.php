<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Provider extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    protected $hidden = ['credentials'];

    protected function casts(): array
    {
        return ['credentials' => 'encrypted:array', 'settings' => 'array', 'enabled' => 'boolean', 'circuit_until' => 'datetime', 'busy_until' => 'datetime', 'next_request_at' => 'datetime'];
    }

    public function endpoints()
    {
        return $this->hasMany(Endpoint::class);
    }
}
