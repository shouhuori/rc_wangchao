<?php

namespace App\Drivers;

class HmacJsonDriver extends JsonHttpDriver
{
    public function manifest(): array
    {
        return ['id' => 'hmac-json.v1', 'name' => 'JSON + HMAC SHA-256', 'credentials' => ['key_id', 'secret'], 'description' => '示例签名协议：HMAC(timestamp + newline + JSON body)。真实供应商可新增专用 Driver。'];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        if ($endpoint['method'] === 'GET') {
            throw new \InvalidArgumentException('此示例签名协议仅支持带 JSON Body 的请求。');
        }

        return parent::prepare($endpoint, $credentials, $input, $key);
    }

    public function headers(array $credentials, string $body, string $key): array
    {
        $time = (string) time();

        return parent::headers([], $body, $key) + ['X-Key-Id' => $credentials['key_id'], 'X-Timestamp' => $time,
            'X-Signature' => hash_hmac('sha256', $time."\n".$body, $credentials['secret'])];
    }
}
