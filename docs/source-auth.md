# 业务来源接入说明

每个业务系统对应一个来源和一个当前有效 Token，例如商城、销售系统、项目管理系统。统一调用 `POST /api/events`，不需要先登录。

## 配置

1. 管理员登录后台，在“业务来源”创建系统。
2. 填写稳定的来源标识与名称，例如 `shop` / 商城。来源标识创建后不能修改。
3. 保存生成的 Token，将其配置到对应业务系统的服务端。Token 仅在生成时显示。
4. 每次通过 `Authorization: Bearer <Token>` 请求头发送，正式环境使用 HTTPS。

Token 由 32 字节随机数据生成，数据库只保存 SHA-256 摘要。后台支持停用和重新生成；重新生成后旧 Token 立即失效，不自动启用停用来源。已经通过鉴权的在途请求、已经接收的事件继续处理。

当前没有按来源限制事件类型，每个启用来源均可提交已发布的事件类型。

## 请求

```json
{
  "id": "payment-20261020-001",
  "type": "order.paid.v1",
  "occurred_at": "2026-10-20T09:30:00.123+08:00",
  "payload": {
    "order_id": "42",
    "contact_id": "contact-7"
  }
}
```

- `id`：上游事件 ID，必填，同一来源内唯一。
- `type`：已发布的事件类型，必填。
- `occurred_at`：事件发生时间，选填，必须包含时区，最多 6 位小数秒。
- `payload`：业务数据，必填。订单号等业务对象标识放在这里。
- `predecessor_id`：前置事件的上游 ID，选填，仅在同一来源内查找。

请求体不再允许 `source` 和 `business_key`，即使为 null 也返回 422。内部事件保留 `source`，由 Token 对应的来源写入。它用于追踪、去重和依赖隔离。

首次接收返回 202；同来源、同事件 ID、相同内容返回 200 和 `duplicate: true`；内容不同返回 409。不同来源可使用相同事件 ID。Token 轮换不改变事件身份。缺失、错误或停用的 Token 返回 401。后台登录 Session 不能代替接口 Token。

## 旧环境升级

- 备份数据库，检查模板和历史步骤是否引用 `$event.business_key`。迁移将移除事件表的该字段；业务信息继续保留在原始 payload 中。
- 执行迁移。历史来源保留，但默认停用且没有 Token，不自动开放接入。
- 在后台为每个来源生成凭证并启用。旧共享 `.env` 的 `DISPATCH_API_TOKEN` 不再生效。
- 更新调用方，使用对应来源的 Token，删除请求体的 source 和 business_key。
- 旧事件保留原指纹，重试时按新协议兼容比较，不会重复生成已接收事件。
- 重启应用监听器和 Worker。

本地已完成迁移。迁移前数据库备份在 `storage/app/before-source-tokens.sql`，权限 0600。商城演示来源 `shop.demo` 的新 Token 保存在 `storage/app/local-access.json` 的 `source_tokens["shop.demo"]` 中。其他历史来源默认停用。

## 存储

新增 `event_sources` 表：

| 字段 | 类型 | 用途 |
|---|---|---|
| id | VARCHAR(100)，主键 | 来源的语义标识 |
| name | VARCHAR(150) | 系统显示名称 |
| token_hash | VARCHAR(64)，可空，唯一 | 当前 Token 的 SHA-256 摘要 |
| enabled | BOOLEAN | 是否允许新请求 |
| token_issued_at | TIMESTAMP，可空 | Token 生成时间 |
| created_at / updated_at | TIMESTAMP | 配置创建、修改时间 |

事件表新增 `fingerprint_version`，区分旧请求格式与新请求格式的去重处理。`event_streams` 中原名 business_key 的列只保存内部锁名，现更名为 `lock_key`。
