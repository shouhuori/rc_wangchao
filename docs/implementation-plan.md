# Notification dispatcher implementation plan

> Inline execution using executing-plans and test-driven-development. User explicitly requested immediate local implementation; no further design approval is required.

**Goal:** runnable Laravel notification dispatcher with persistent recovery and an operational UI.
**Architecture:** MySQL owns all state; Redis wakes per-provider workers; immutable workflow snapshots create task/step graphs. Driver registry builds HTTP calls; attempt records retain history.
**Tech Stack:** PHP 8.4, Laravel 12, MySQL 8.4, Redis, Blade, PHPUnit.
**Spec:** docs/design.md

## Global constraints
- Work only in /Users/chao/dev/notification-dispatcher.
- Semantic definitions, UUID instance IDs, stable step idempotency keys.
- No real supplier secrets or outbound business notifications in demo.
- No automatic migration of running tasks to new templates.

## Review focus
- Conflicting duplicate intake must return 409, not silently accept another payload.
- Expired leases and duplicate jobs must not re-run successful steps or commit stale results.
- Dependencies must stay blocked during retry, unknown outcomes, and missing predecessor events.
- Retry budgets, disabled providers, circuit breaker and Redis loss must not lose durable work.
- Auth, config publishing and credential redaction must fail closed.

## Task 1: scaffold and persistence
Files: migrations, app/Models, config/dispatch.php, tests/Feature/IntakeTest.php.
- [x] Scaffold Laravel and add behavioral intake tests; run to observe missing API.
- [x] Implement schemas and authenticated intake, fixed revisions, deduplication/conflict handling.
- [x] Run intake tests and fix failures.

## Task 2: workflow and execution
Files: app/Dispatch/{WorkflowValidator,Converter,Coordinator,Executor,Recovery}.php, app/Drivers/*, app/Jobs/*; tests/Feature/DispatchTest.php.
- [x] Add failing dependency, retry, lease, disabled-provider, unknown-result and recovery tests.
- [x] Implement driver manifests, publishing snapshots, atomic conversion, request-level execution and scanner.
- [x] Run suite on SQLite; run integration on MySQL and Redis.

## Task 3: configuration and UI
Files: controllers, routes, resources/views, public/assets; tests/Feature/AdminTest.php.
- [x] Add failing authentication, publishing validation, audit and manual retry tests.
- [x] Implement supplier/API/template editors, events/tasks/attempts/dead-letter views and trace.
- [x] Verify browser login, trace, template editing/save and validation; verify publish and manual recovery through authenticated HTTP feature tests.

## Task 4: operability and delivery
Files: README.md, compose.yaml, Dockerfile, bin/*, database/seeders.
- [x] Seed safe demonstration flows and provide local mock supplier.
- [x] Run full tests, lint, MySQL/Redis e2e, browser smoke and independent review.
- [x] Document startup, extension, recovery, configuration and limitations.
