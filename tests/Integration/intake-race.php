<?php

use App\Models\EventSource;
use App\Models\NotificationEvent;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Process\Process;

// Runs ONLY against the dedicated MySQL test database. No live supplier calls.
require __DIR__.'/../../vendor/autoload.php';
$app = require __DIR__.'/../../bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
config(['database.default' => 'mysql', 'database.connections.mysql.database' => 'notification_dispatcher_test', 'dispatch.max_pending' => (int) (getenv('INTEGRATION_CAP') ?: 100000)]);
DB::purge('mysql');
if (DB::connection()->getDatabaseName() !== 'notification_dispatcher_test') {
    exit(2);
}
if (($argv[1] ?? '') === 'child') {
    $payload = json_decode(base64_decode($argv[2]), true);
    $barrier = $argv[3] ?? '';
    if ($barrier !== '') {
        NotificationEvent::creating(function () use ($barrier) {
            file_put_contents($barrier, 'creating');
            usleep(600000);
        });
    }
    $request = Request::create('/api/events', 'POST', [], [], [], ['CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => 'Bearer '.($argv[4] ?? 'integration-test-token')], json_encode($payload));
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    $response = $kernel->handle($request);
    echo $response->getStatusCode();
    $kernel->terminate($request, $response);
    exit;
}
Artisan::call('migrate:fresh', ['--force' => true]);
Artisan::call('db:seed', ['--force' => true]);
foreach (['race' => 'integration-test-token', 'source-a' => 'source-a-token', 'source-b' => 'source-b-token'] as $id => $token) {
    EventSource::create(['id' => $id, 'name' => $id, 'enabled' => true, 'token_hash' => hash('sha256', $token)]);
}
$base = ['type' => 'order.paid.v1', 'payload' => ['order_id' => '42', 'contact_id' => 'c']];
$barrier = sys_get_temp_dir().'/relay-race-'.bin2hex(random_bytes(6));
$run = function (array $a, array $b, array $expected, array $tokens = ['integration-test-token', 'integration-test-token']) use ($base, $barrier) {
    @unlink($barrier);
    $one = new Process([PHP_BINARY, __FILE__, 'child', base64_encode(json_encode(array_replace($base, $a))), $barrier, $tokens[0]]);
    $one->setEnv(['INTEGRATION_CAP' => getenv('INTEGRATION_CAP') ?: '100000']);
    $one->start();
    $limit = microtime(true) + 5;
    while (! file_exists($barrier) && microtime(true) < $limit) {
        usleep(10000);
    }
    if (! file_exists($barrier)) {
        throw new RuntimeException('First request did not reach create barrier: '.$one->getErrorOutput());
    }
    $two = new Process([PHP_BINARY, __FILE__, 'child', base64_encode(json_encode(array_replace($base, $b))), '', $tokens[1]]);
    $two->setEnv(['INTEGRATION_CAP' => getenv('INTEGRATION_CAP') ?: '100000']);
    $two->start();
    $one->wait();
    $two->wait();
    $actual = [(int) $one->getOutput(), (int) $two->getOutput()];
    if ($actual !== $expected) {
        throw new RuntimeException('Expected '.json_encode($expected).', got '.json_encode($actual).' '.$two->getErrorOutput());
    }
    echo 'PASS concurrent intake '.json_encode($actual)."\n";
};
try {
    $run(['id' => 'a', 'predecessor_id' => 'b'], ['id' => 'b', 'predecessor_id' => 'a'], [202, 422]);
    $run(['id' => 'same'], ['id' => 'same', 'payload' => ['order_id' => 'different', 'contact_id' => 'c']], [202, 409]);
    putenv('INTEGRATION_CAP=3');
    $run(['id' => 'capacity-a'], ['id' => 'capacity-b'], [202, 503], ['source-a-token', 'source-b-token']);
} finally {
    @unlink($barrier);
}
