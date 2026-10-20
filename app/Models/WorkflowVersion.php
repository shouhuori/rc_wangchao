<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class WorkflowVersion extends Model
{
    use HasUuids;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['definition' => 'array'];
    }

    public function workflow()
    {
        return $this->belongsTo(Workflow::class);
    }
}
