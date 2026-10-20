<?php

// Local-only fixture. Never use this server as a production provider.
header('Content-Type: application/json');
$raw = file_get_contents('php://input');
if (str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/x-www-form-urlencoded')) {
    parse_str($raw, $input);
} else {
    $input = json_decode($raw, true) ?? [];
}
$key = $_SERVER['HTTP_IDEMPOTENCY_KEY'] ?? '';
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$cache = __DIR__.'/../storage/app/mock-state.json';
$handle = fopen($cache, 'c+');
flock($handle, LOCK_EX);
$state = json_decode(stream_get_contents($handle), true) ?? [];
$attempt = ($state['attempts'][$key] ?? 0) + 1;
$state['attempts'][$key] = $attempt;
$order = $input['order_id'] ?? '';
$code = 200;
$body = ['ok' => true, 'id' => $input['contact_id'] ?? $input['external_id'] ?? 'contact-'.substr(hash('sha256', $key), 0, 8), 'operation' => $path];
if ($order === 'demo-dead' && $path === '/reserve') {
    $code = 400;
    $body = ['error' => '演示：商品不可售'];
} elseif ($order === 'demo-retry' && $path === '/reserve' && $attempt === 1) {
    $code = 503;
    $body = ['error' => '演示：临时不可用'];
} elseif ($order === 'demo-unknown' && $path === '/reserve') {
    $code = 202;
    $body = ['accepted' => true];
}
if (isset($state['results'][$key])) {
    $body = $state['results'][$key];
} elseif ($code === 200) {
    $state['results'][$key] = $body;
}
rewind($handle);
ftruncate($handle, 0);
fwrite($handle, json_encode($state));
flock($handle, LOCK_UN);
fclose($handle);
http_response_code($code);
echo json_encode($body, JSON_UNESCAPED_UNICODE);
