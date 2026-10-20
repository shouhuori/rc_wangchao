<?php

namespace App\Dispatch;

use App\Models\AuditEntry;

class Audit
{
    public static function record(string $actor, string $action, string $subject, array $details = []): void
    {
        AuditEntry::create(compact('actor', 'action', 'subject') + ['details' => Redactor::clean($details)]);
    }
}
