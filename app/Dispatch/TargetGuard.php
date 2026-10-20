<?php

namespace App\Dispatch;

use Illuminate\Validation\ValidationException;

class TargetGuard
{
    public function validate(string $base, string $path = '/'): array
    {
        $url = parse_url($base);
        $host = trim($url['host'] ?? '', '[]');
        $scheme = $url['scheme'] ?? '';
        $local = in_array($host, ['127.0.0.1', 'localhost', '[::1]', '::1'], true) && config('dispatch.allow_local_targets');
        if (! $host || isset($url['user']) || isset($url['pass']) || isset($url['query']) || isset($url['fragment']) ||
            ! in_array($scheme, $local ? ['http', 'https'] : ['https'], true) || ! str_starts_with($path, '/') || str_starts_with($path, '//') || preg_match('/[\r\n\\\\]/', $path)) {
            throw ValidationException::withMessages(['base_url' => '目标必须是 HTTPS 地址；路径必须以单个 / 开头。仅本地开发可允许回环地址。']);
        }

        return [$host, $scheme, $url['port'] ?? ($scheme === 'https' ? 443 : 80), $local];
    }

    public function curlOptions(string $base, string $path): array
    {
        [$host,$scheme,$port,$local] = $this->validate($base, $path);
        if ($local) {
            return [];
        }
        $ips = filter_var($host, FILTER_VALIDATE_IP) ? [$host] : array_values(array_filter(array_merge(
            array_column(dns_get_record($host, DNS_A) ?: [], 'ip'), array_column(dns_get_record($host, DNS_AAAA) ?: [], 'ipv6'))));
        if (! $ips) {
            throw new \RuntimeException('无法解析目标域名。');
        }
        foreach ($ips as $ip) {
            if (! $this->isPublicUnicast($ip)) {
                throw ValidationException::withMessages(['base_url' => '目标地址解析到受限网络。']);
            }
        }
        // Pin the checked address to prevent DNS rebinding between validation and connection.
        $ip = $ips[0];
        if (str_contains($ip, ':')) {
            $ip = "[$ip]";
        }

        return [CURLOPT_RESOLVE => ["$host:$port:$ip"]];
    }

    private function isPublicUnicast(string $ip): bool
    {
        if (! filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_GLOBAL_RANGE)) {
            return false;
        }
        $packed = inet_pton($ip);
        if ($packed === false) {
            return false;
        }
        if (strlen($packed) === 4) {
            return ord($packed[0]) < 224;
        }
        if (ord($packed[0]) === 255) {
            return false;
        }
        // IPv4-mapped and transition ranges must not tunnel around the IPv4 check.
        if (substr($packed, 0, 12) === str_repeat("\0", 10)."\xff\xff") {
            return false;
        }

        return true;
    }
}
