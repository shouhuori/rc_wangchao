<?php

namespace App\Rules;

use Closure;
use DateTimeImmutable;
use DateTimeZone;
use Illuminate\Contracts\Validation\ValidationRule;
use InvalidArgumentException;

class EventTimestamp implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        try {
            if (! is_string($value)) {
                throw new InvalidArgumentException;
            }
            self::normalize($value);
        } catch (InvalidArgumentException) {
            $fail('事件发生时间须包含日期、时间和时区，例如 2026-10-20T09:30:00+08:00，最多支持 6 位小数秒。');
        }
    }

    public static function normalize(string $value): string
    {
        if (! preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-](?:[01]\d|2[0-3]):[0-5]\d)$/D', $value)) {
            throw new InvalidArgumentException;
        }
        $format = str_contains($value, '.') ? '!Y-m-d\TH:i:s.uP' : '!Y-m-d\TH:i:sP';
        $time = DateTimeImmutable::createFromFormat($format, $value);
        $errors = DateTimeImmutable::getLastErrors();
        if ($time === false || ($errors !== false && ($errors['warning_count'] || $errors['error_count']))) {
            throw new InvalidArgumentException;
        }
        $time = $time->setTimezone(new DateTimeZone('UTC'));
        if ((int) $time->format('Y') < 1000 || (int) $time->format('Y') > 9999) {
            throw new InvalidArgumentException;
        }

        return $time->format('Y-m-d\TH:i:s.u\Z');
    }
}
