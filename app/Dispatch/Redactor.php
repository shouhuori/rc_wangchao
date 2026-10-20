<?php

namespace App\Dispatch;

class Redactor
{
    public static function clean(mixed $value): mixed
    {
        if (! is_array($value)) {
            return is_string($value) ? mb_substr($value, 0, 4000) : $value;
        }
        $out = [];
        foreach ($value as $key => $item) {
            $out[$key] = preg_match('/authorization|api[-_]?key|cookie|token|secret|password|signature|phone|email|address/i', (string) $key)
                ? '[已隐藏]' : self::clean($item);
        }

        return $out;
    }
}
