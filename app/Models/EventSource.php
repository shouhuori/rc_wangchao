<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventSource extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    protected $hidden = ['token_hash'];

    protected function casts(): array
    {
        return ['enabled' => 'boolean', 'token_issued_at' => 'datetime'];
    }

    public function events()
    {
        return $this->hasMany(NotificationEvent::class, 'source');
    }

    public function issueToken(): string
    {
        $token = 'relay_'.bin2hex(random_bytes(32));
        $this->forceFill(['token_hash' => hash('sha256', $token), 'token_issued_at' => now()])->save();

        return $token;
    }
}
