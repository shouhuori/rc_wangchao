<?php

$env = file_get_contents(__DIR__.'/../../.env');
preg_match('/^DB_PASSWORD=(.*)$/m', $env, $m);
putenv('DB_CONNECTION=mysql');
putenv('DB_HOST=127.0.0.1');
putenv('DB_PORT=3307');
putenv('DB_DATABASE=notification_dispatcher_test');
putenv('DB_USERNAME=dispatcher');
putenv('DB_PASSWORD='.$m[1]);
$cmd = escapeshellarg(PHP_BINARY).' '.escapeshellarg(__DIR__.'/../../vendor/bin/phpunit');
passthru($cmd, $exit);
exit($exit);
