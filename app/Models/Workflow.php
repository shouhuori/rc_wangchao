<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Workflow extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    protected function casts(): array
    {
        return ['draft' => 'array', 'enabled' => 'boolean'];
    }

    public function versions()
    {
        return $this->hasMany(WorkflowVersion::class);
    }

    public function activeVersion()
    {
        return $this->belongsTo(WorkflowVersion::class, 'active_version_id');
    }
}
