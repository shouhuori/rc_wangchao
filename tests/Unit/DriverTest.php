<?php

namespace Tests\Unit;

use App\Drivers\FormHttpDriver;
use App\Drivers\HmacJsonDriver;
use App\Drivers\JsonHttpDriver;
use PHPUnit\Framework\TestCase;

class DriverTest extends TestCase
{
    public function test_json_driver_encodes_path_fields_and_preserves_business_payload(): void
    {
        $r = (new JsonHttpDriver)->prepare(['method' => 'POST', 'path' => '/contacts/{contact_id}/paid'], ['token' => 'private'], ['contact_id' => 'x/y', 'paid' => true], 'stable-key');
        $this->assertSame('/contacts/x%2Fy/paid', $r->path);
        $this->assertSame('stable-key', $r->headers['Idempotency-Key']);
        $this->assertSame(['contact_id' => 'x/y', 'paid' => true], json_decode($r->body, true));
    }

    public function test_form_driver_uses_urlencoded_body(): void
    {
        $r = (new FormHttpDriver)->prepare(['method' => 'POST', 'path' => '/notify'], [], ['name' => 'a & b'], 'key');
        $this->assertSame('application/x-www-form-urlencoded', $r->headers['Content-Type']);
        $this->assertSame('name=a%20%26%20b', $r->body);
    }

    public function test_hmac_driver_signs_exact_transmitted_body(): void
    {
        $r = (new HmacJsonDriver)->prepare(['method' => 'POST', 'path' => '/notify'], ['key_id' => 'client', 'secret' => 'secret'], ['id' => 42], 'key');
        $this->assertSame(hash_hmac('sha256', $r->headers['X-Timestamp']."\n".$r->body, 'secret'), $r->headers['X-Signature']);
    }

    public function test_path_parameter_cannot_escape_endpoint_using_dot_segments(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        (new JsonHttpDriver)->prepare(['method' => 'POST', 'path' => '/contacts/{contact_id}/paid'], [], ['contact_id' => '..'], 'key');
    }
}
