<?php

namespace App\Dispatch;

use App\Models\NotificationEvent;

class EventFingerprint
{
    public static function make(array $data): string
    {
        $canonical = function ($value) use (&$canonical) {
            if (! is_array($value)) {
                return $value;
            }
            if (! array_is_list($value)) {
                ksort($value);
            }

            return array_map($canonical, $value);
        };

        return hash('sha256', json_encode($canonical($data), JSON_THROW_ON_ERROR));
    }

    public static function stored(NotificationEvent $event): string
    {
        if ($event->fingerprint_version >= 2) {
            return $event->fingerprint;
        }
        // Compare old events using the current contract without changing their history.
        $data = ['id' => $event->external_id, 'source' => $event->source, 'type' => $event->type,
            'predecessor_id' => $event->predecessor_id, 'payload' => $event->payload];
        if ($event->occurred_at !== null) {
            $data['occurred_at'] = $event->occurred_at->utc()->format('Y-m-d\TH:i:s.u\Z');
        }

        return self::make($data);
    }
}
