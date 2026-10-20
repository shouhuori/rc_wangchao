# 2026-10-20：按业务来源独立鉴权，精简接入字段

- 新增 event_sources：来源标识、名称、Token 摘要、启用状态和生成时间。后台支持创建、停用和重新生成，Token 仅生成时显示。
- API 从 Token 获取 source；拒绝请求体中的 source/business_key。移除事件表 business_key，内部锁字段更名 lock_key。
- 同来源事件去重和跨事件依赖继续有效，不同来源互相隔离。fingerprint_version 兼容旧事件重试。
- 迁移前完整备份本地数据库到 storage/app/before-source-tokens.sql（0600）；历史来源默认停用。shop.demo 新凭证保存到受保护的 local-access.json source_tokens 中，旧共享凭证移除。
- 验证：SQLite、MySQL 各 62 个测试 / 289 个断言通过，Pint 与 Blade 编译通过；3 组 MySQL 并发测试通过。真实 HTTP 新请求、重复请求、非法旧字段、旧事件重试分别返回 202/200/422/200，模拟供应商的 4 个步骤均成功。
- 独立代码审查发现来源标识 0 的表单判断问题，补充失败测试后已修复，全部回归通过。

# Implementation ledger
Plan: docs/implementation-plan.md
Ruling: direct implementation request authorizes local scaffold, dependency installation and tests; no extra confirmation gate.
Ruling: no existing project at requested destination; create a new standalone checkout, no worktree needed.
Ruling: cross-event order is explicit predecessor_id, not arrival time. Daily schedule means individual scheduled requests, not aggregation.
Ruling: built-in generic drivers demonstrate extensibility; supplier-specific business completion queries require a custom Driver.
Task 1 complete: authenticated durable intake, 5 tests passed.
Task 2 complete: conversion transaction, task/step DAG, per-step retry, bounded budgets, lease fencing and unknown-state recovery. Found Laravel Http::fake merges stubs; isolated HTTP factories in tests. Fixed Chinese punctuation interpolation in error text.
Task 3 complete: authenticated Blade console, config forms and visual workflow editor. Full suite currently 24 tests. Local MySQL+Redis end-to-end exposed queue reservation retention after rate limiting; added failing regression and released reservation for rescheduling.
Review fixes: source-scope intake lock prevents concurrent cross-business dependency races; MySQL subprocess barrier test proved 202/422 and 202/409 outcomes. Explicit null checks preserve predecessor ID "0". Credentials excluded from flashed validation input. TargetGuard rejects shared, multicast and IPv4-mapped private addresses. Provider-aware scheduler prevents one backlog starving other providers.
Added declared payload requirements, simple equality subscription filters, true Driver request construction (JSON/Form/HMAC), template URL parameters, and pending-work backpressure. PHPUnit: 38 tests on SQLite and MySQL. Browser verified login, trace graph, template editor and draft save.

Final verification (2026-10-20): SQLite and native MySQL each passed 40 tests / 137 assertions. Dedicated MySQL concurrency cases passed [202,422], [202,409], [202,503]. Pint, Blade compilation, JavaScript syntax and Composer validation passed. Native MySQL/Redis HTTP end-to-end passed success, transient retry, permanent rejection and HTTP 202 unknown cases. Health returned Redis available, scanner heartbeat current, zero pending conversions and zero open circuits; dead/unknown demo records intentionally remain.
Browser: verified login, trace, template editing/save and AJAX validation. Browser automation stalled on the native publish confirmation; browser publish/manual-confirm interaction was not completed. Authenticated route tests cover immutable publishing and verified manual confirmation, including dependency release and no re-send.
Review findings addressed: capacity lock before first consistent read and dot-segment path rejection. The capacity mutation experiment did not reproduce the old-order failure; only the final concurrent behavior is claimed verified.
Docker not executed (no Docker installed). Real supplier protocols/secrets were not provided; generic JSON/Form/example HMAC drivers and local mock are delivered.

Supplier Driver correction: implemented distinct DemoCrmDriver, DemoInventoryDriver and DemoSmsDriver, operation contracts, code-owned HTTP protocol/idempotency, full-response interpretation, registry compatibility for old snapshots, endpoint operation migration and dependent configuration UI. Existing connections cannot change supplier class. Local demo upgraded to workflow v2; v1 snapshots preserved. SQLite and MySQL suites: 51 tests /178 assertions. Three concurrent MySQL intake cases passed. Native HTTP v2 cases success/retry/dead/unknown passed, including PATCH CRM, form SMS, signature and secret redaction checks. Browser verified API operation filtering and save.
# 2026-10-20：区分事件发生时间和接收时间

- 接口增加选填 `occurred_at`，严格校验带时区的时间，最多 6 位小数秒。
- 新增可空 `DATETIME(6)` 字段，统一保存 UTC；旧记录不回填，保留原请求指纹兼容。
- 时间规范化后参加重复提交校验，模板可通过 `$event.occurred_at` 映射。
- 事件详情分别展示发生时间与接收时间，并标注 UTC+08:00。
- 显式依赖、调度和过期策略保持原有语义，时间戳不隐式决定执行顺序。
- 验证：SQLite 与 MySQL 各 55 个测试、227 个断言通过；Pint、Blade 编译通过；本地迁移已执行，真实 HTTP 请求返回 202，数据库保留 6 位小数秒，后台显示发生与接收时间，模拟投递完成。

