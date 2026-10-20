<?php

namespace App\Dispatch;

use App\Drivers\Registry;
use App\Models\Attempt;
use App\Models\Provider;
use App\Models\RequestStep;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class Executor
{
    public function execute(string $id): void
    {
        $original = RequestStep::find($id);
        if (! $original) {
            return;
        }
        app(Coordinator::class)->refresh($original->task->event_id);
        $claim = DB::transaction(function () use ($id) {
            $step = RequestStep::lockForUpdate()->findOrFail($id);
            if (! in_array($step->status, ['ready', 'retry']) || $step->available_at->isFuture() || $step->task->paused) {
                return null;
            }
            if ($step->expires_at->isPast() || $step->cycle_attempts >= $step->max_attempts) {
                $step->update(['status' => 'dead', 'last_error' => '投递期限或重试次数已耗尽。']);

                return null;
            }
            $provider = Provider::lockForUpdate()->findOrFail($step->provider_id);
            if (! $provider->enabled || $provider->circuit_until?->isFuture() || $provider->busy_until?->isFuture() || $provider->next_request_at?->isFuture()) {
                return null;
            }
            $token = (string) Str::uuid();
            $until = now()->addSeconds(config('dispatch.lease_seconds'));
            $provider->update(['busy_token' => $token, 'busy_until' => $until]);
            $step->update(['status' => 'running', 'lease_token' => $token, 'lease_until' => $until, 'enqueued_until' => null,
                'attempt_count' => $step->attempt_count + 1, 'cycle_attempts' => $step->cycle_attempts + 1]);
            $attempt = Attempt::create(['step_id' => $id, 'number' => $step->attempt_count, 'token' => $token, 'status' => 'running']);

            return [$step, $provider, $attempt, $token];
        }, 3);
        if (! $claim) {
            RequestStep::whereKey($id)->whereIn('status', ['ready', 'retry'])->update(['enqueued_until' => null]);
            app(Coordinator::class)->refresh($original->task->event_id);

            return;
        }
        [$step,$provider,$attempt,$token] = $claim;
        $started = microtime(true);
        $code = null;
        $output = [];
        $error = null;
        $retryAfter = 0;
        try {
            $ep = $step->endpoint_snapshot;
            $driver = app(Registry::class)->get($ep['driver']);
            foreach ($driver->manifest()['credentials'] as $field) {
                if (empty($provider->credentials[$field])) {
                    throw new \InvalidArgumentException('缺少凭证字段。');
                }
            }
            $input = app(InputMapper::class)->resolve($step);
            $prepared = $driver->prepare($ep, $provider->credentials ?? [], $input, $step->idempotency_key);
            if (strlen($prepared->body ?? json_encode($prepared->query)) > config('dispatch.max_body_bytes')) {
                throw new \InvalidArgumentException('请求内容过大。');
            }
            $url = rtrim($ep['base_url'], '/').$prepared->path;
            $attempt->update(['request' => Redactor::clean(['method' => $prepared->method, 'url' => strtok($url, '?'), 'headers' => $prepared->headers, 'body' => $prepared->observableBody()])]);
            $curl = app(TargetGuard::class)->curlOptions($ep['base_url'], $prepared->path);
            $limit = config('dispatch.max_body_bytes');
            $request = Http::withHeaders($prepared->headers)->connectTimeout(5)->timeout(min(30, max(1, $ep['options']['timeout'] ?? 10)))
                ->withoutRedirecting()->withOptions(['curl' => $curl, 'proxy' => '',
                    'on_headers' => function ($response) use ($limit) {
                        if ((int) $response->getHeaderLine('Content-Length') > $limit) {
                            throw new \RuntimeException('响应过大。');
                        }
                    },
                    'progress' => function ($total, $received) use ($limit) {
                        if ($received > $limit) {
                            throw new \RuntimeException('响应过大。');
                        }
                    },
                ]);
            $response = $prepared->method === 'GET' ? $request->get($url, $prepared->query) : $request->withBody($prepared->body ?? '', $prepared->headers['Content-Type'] ?? 'application/octet-stream')->send($prepared->method, $url);
            $code = $response->status();
            if (strlen($response->body()) > $limit) {
                throw new \RuntimeException('响应过大。');
            }
            $result = $driver->interpret($ep, $response);
            $output = $result->output;
            $status = $result->status;
            if ($status !== 'succeeded') {
                $error = "HTTP {$code}：".match ($status) {
                    'retry' => '可重试错误。','unknown' => '仅确认受理，需核对完成状态。',default => '请求被拒绝或业务结果未满足成功条件。'
                };
            }
            if ($status === 'retry' && ! ($ep['options']['idempotent'] ?? false) && $code !== 429) {
                $status = 'unknown';
            }
            $retryHeader = $response->header('Retry-After');
            if ($retryHeader) {
                $retryAfter = ctype_digit($retryHeader) ? (int) $retryHeader : max(0, (strtotime($retryHeader) ?: time()) - time());
            }
        } catch (\InvalidArgumentException|ValidationException $e) {
            $status = 'dead';
            $error = '配置或输入校验失败，请核对 Driver、映射与目标地址。';
        } catch (\Throwable $e) {
            $status = ($step->endpoint_snapshot['options']['idempotent'] ?? false) ? 'retry' : 'unknown';
            $error = '发送中断或执行异常，目标结果可能未知（'.class_basename($e).'）。';
        }
        $duration = (int) round((microtime(true) - $started) * 1000);
        $this->finish($step->id, $token, $status, $code, $output, $error, $duration, $retryAfter);
        app(Coordinator::class)->refresh($step->task->event_id);
    }

    public function finish(string $id, string $token, string $status, ?int $code, array $output, ?string $error, int $duration, int $retryAfter = 0): void
    {
        DB::transaction(function () use ($id, $token, $status, $code, $output, $error, $duration, $retryAfter) {
            $step = RequestStep::lockForUpdate()->findOrFail($id);
            if ($step->status !== 'running' || $step->lease_token !== $token || $step->lease_until->isPast()) {
                return;
            }
            $attempt = Attempt::where('step_id', $id)->where('token', $token)->firstOrFail();
            $attempt->update(['status' => $status, 'status_code' => $code, 'response' => Redactor::clean($output), 'error' => $error, 'duration_ms' => $duration, 'finished_at' => now()]);
            $next = now()->addSeconds(max(min(3600, 5 * (2 ** min($step->cycle_attempts, 10))) + random_int(0, 5), $retryAfter));
            if ($status === 'retry' && ($step->cycle_attempts >= $step->max_attempts || $next->gt($step->expires_at))) {
                $status = 'dead';
                $error = ($error ?? '').' 自动重试预算已耗尽。';
            }
            if (in_array($status, ['dead', 'unknown'])) {
                Audit::record('system', 'step.'.$status, $id, ['http_status' => $code, 'reason' => $error]);
                Log::warning('dispatch.requires_attention', ['step_id' => $id, 'provider_id' => $step->provider_id, 'status' => $status]);
            }
            $step->update(['status' => $status, 'last_error' => $error, 'output' => $status === 'succeeded' ? $output : null,
                'available_at' => $status === 'retry' ? $next : $step->available_at, 'lease_token' => null, 'lease_until' => null, 'enqueued_until' => null]);
            $provider = Provider::lockForUpdate()->findOrFail($step->provider_id);
            if ($provider->busy_token === $token) {
                $failures = $status === 'succeeded' ? 0 : $provider->failure_streak + 1;
                $settings = $provider->settings;
                $provider->update(['busy_token' => null, 'busy_until' => null, 'failure_streak' => $failures,
                    'next_request_at' => now()->addSeconds(max(1, (int) ceil(($settings['interval_ms'] ?? 1000) / 1000))),
                    'circuit_until' => $status === 'succeeded' ? null : ($failures >= ($settings['circuit_threshold'] ?? 5) ? now()->addSeconds($settings['circuit_seconds'] ?? 60) : $provider->circuit_until)]);
            }
        }, 3);
    }
}
