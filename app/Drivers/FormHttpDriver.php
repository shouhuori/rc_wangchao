<?php

namespace App\Drivers;

class FormHttpDriver extends JsonHttpDriver
{
    public function manifest(): array
    {
        return ['id' => 'form-http.v1', 'name' => 'Form HTTP / Bearer', 'credentials' => [], 'description' => 'application/x-www-form-urlencoded 请求，支持路径参数与可选 Bearer Token。'];
    }

    public function prepare(array $endpoint, array $credentials, array $input, string $key): PreparedRequest
    {
        $r = parent::prepare($endpoint, $credentials, $input, $key);
        $headers = $r->headers;
        $headers['Content-Type'] = 'application/x-www-form-urlencoded';

        return new PreparedRequest($r->method, $r->path, $headers, $r->method === 'GET' ? null : http_build_query($input, '', '&', PHP_QUERY_RFC3986), $r->query);
    }
}
