<?php

namespace App\Support;

use App\Dispatch\Redactor;

class Ui
{
    public static function status(?string $value): string
    {
        return [
            'pending' => '待转换', 'converted' => '转换完成', 'failed' => '转换失败', 'waiting' => '等待依赖', 'ready' => '待执行',
            'running' => '执行中', 'retry' => '等待重试', 'succeeded' => '成功', 'dead' => '最终失败', 'unknown' => '结果未知',
            'blocked' => '依赖阻塞', 'skipped' => '未触发 / 无须投递', 'processing' => '处理中', 'attention' => '需要处理',
        ][$value] ?? ($value ?? '—');
    }

    public static function date($value): string
    {
        return $value?->copy()->timezone('Asia/Shanghai')->format('m-d H:i:s') ?? '—';
    }

    public static function json($value): string
    {
        return json_encode(Redactor::clean($value), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '{}';
    }
}
