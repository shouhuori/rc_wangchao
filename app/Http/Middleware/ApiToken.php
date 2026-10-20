<?php

namespace App\Http\Middleware;

use App\Models\EventSource;
use Closure;
use Illuminate\Http\Request;

class ApiToken
{
    public function handle(Request $request, Closure $next)
    {
        $token = (string) $request->bearerToken();
        abort_if($token === '' || strlen($token) > 256, 401);
        $source = EventSource::where('token_hash', hash('sha256', $token))->where('enabled', true)->first();
        abort_unless($source, 401);
        $request->attributes->set('event_source', $source);
        abort_if(strlen($request->getContent()) > config('dispatch.max_body_bytes'), 413);

        return $next($request);
    }
}
