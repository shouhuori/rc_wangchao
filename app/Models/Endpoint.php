<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Endpoint extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    protected function casts(): array
    {
        return ['options' => 'array', 'enabled' => 'boolean'];
    }

    public function provider()
    {
        return $this->belongsTo(Provider::class);
    }
}
