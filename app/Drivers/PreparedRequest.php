<?php

namespace App\Drivers;

final readonly class PreparedRequest
{
    public function __construct(public string $method, public string $path, public array $headers, public ?string $body = null, public array $query = []) {}

    public function observableBody(): array
    {
        if ($this->method === 'GET') {
            return $this->query;
        }
        if (str_contains($this->headers['Content-Type'] ?? '', 'application/json')) {
            return json_decode($this->body ?? '', true) ?: [];
        }
        if (str_contains($this->headers['Content-Type'] ?? '', 'application/x-www-form-urlencoded')) {
            parse_str($this->body ?? '', $value);

            return $value;
        }

        return ['content' => '原始请求内容未记录，请查看 Driver 定义。'];
    }
}
