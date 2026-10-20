<?php

namespace App\Drivers;

use Illuminate\Http\Client\Response;

class JsonHttpDriver implements Driver
{
    public function manifest(): array
    {
        return ['id' => 'json-http.v1', 'name' => 'JSON HTTP / Bearer', 'credentials' => [], 'description' => 'JSON 请求，可选 Bearer Token；以状态码和可选业务字段判定成功。'];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        $path = preg_replace_callback('/\{([a-zA-Z0-9_.-]+)\}/', function ($match) use ($input) {
            $value = data_get($input, $match[1]);
            if (! is_scalar($value)) {
                throw new \InvalidArgumentException('URL 路径参数缺失。');
            }

            $value = (string) $value;
            foreach (explode('/', str_replace('\\', '/', $value)) as $segment) {
                if ($segment === '.' || $segment === '..') {
                    throw new \InvalidArgumentException('路径参数不能包含点路径段。');
                }
            }
            if ($value === '') {
                throw new \InvalidArgumentException('路径参数不能为空。');
            }

            return rawurlencode($value);
        }, $endpoint['path']);
        $body = json_encode($input, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        return new PreparedRequest($endpoint['method'], $path, $this->headers($credentials, $body, $key), $endpoint['method'] === 'GET' ? null : $body, $endpoint['method'] === 'GET' ? $input : []);
    }

    public function headers(array $credentials, string $body, string $key): array
    {
        return ['Accept' => 'application/json', 'Content-Type' => 'application/json', 'Idempotency-Key' => $key]
            + (! empty($credentials['token']) ? ['Authorization' => 'Bearer '.$credentials['token']] : []);
    }

    public function interpret(array $endpoint, Response $response): DeliveryResult
    {
        $body = $response->json();
        $body = is_array($body) ? $body : [];

        return new DeliveryResult($this->classify($response->status(), $body, $endpoint['options'] ?? []), $body);
    }

    public function classify(int $status, array $body, array $options): string
    {
        // A transport acknowledgement is not proof that dependent operations can proceed.
        if ($status === 202) {
            return 'unknown';
        }
        if (in_array($status, $options['success_codes'] ?? [200, 201, 204], true)) {
            if (isset($options['success_path']) && data_get($body, $options['success_path']) !== ($options['success_value'] ?? true)) {
                return 'dead';
            }

            return 'succeeded';
        }

        return ($status === 408 || $status === 429 || $status >= 500) ? 'retry' : 'dead';
    }
}
