<?php

return [
    'admin_email' => env('DISPATCH_ADMIN_EMAIL', 'admin@localhost'),
    'allow_local_targets' => env('DISPATCH_ALLOW_LOCAL_TARGETS', false),
    'lease_seconds' => 90,
    'max_pending' => (int) env('DISPATCH_MAX_PENDING', 100000),
    'max_body_bytes' => 1048576,
];
