<?php

namespace App\Dispatch;

use App\Drivers\Registry;
use App\Models\Endpoint;
use App\Models\Workflow;
use App\Models\WorkflowVersion;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class Publisher
{
    public function publish(string $id, string $actor): WorkflowVersion
    {
        return DB::transaction(function () use ($id, $actor) {
            $workflow = Workflow::lockForUpdate()->findOrFail($id);
            $definition = $this->validate($workflow->draft);
            $v = WorkflowVersion::create(['workflow_id' => $id, 'number' => ($workflow->versions()->max('number') ?? 0) + 1, 'definition' => $definition]);
            $workflow->update(['active_version_id' => $v->id]);
            Audit::record($actor, 'workflow.publish', $id, ['version' => $v->number]);

            return $v;
        });
    }

    public function validate(array $d): array
    {
        Validator::make($d, [
            'required_payload_fields' => 'sometimes|array|max:100', 'required_payload_fields.*' => 'string|regex:/^[a-zA-Z0-9_.-]+$/',
            'tasks.*.when' => 'sometimes|array',
            'tasks' => 'required|array|min:1|max:50', 'tasks.*.key' => 'required|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/',
            'tasks.*.name' => 'required|string|max:150', 'tasks.*.depends_on' => 'present|array', 'tasks.*.enabled' => 'sometimes|boolean',
            'tasks.*.steps' => 'required|array|min:1|max:30', 'tasks.*.steps.*.key' => 'required|regex:/^[a-z0-9][a-z0-9_-]{0,79}$/',
            'tasks.*.steps.*.name' => 'required|string|max:150', 'tasks.*.steps.*.endpoint_id' => 'required|string',
            'tasks.*.steps.*.depends_on' => 'present|array', 'tasks.*.steps.*.input' => 'present|array', 'tasks.*.steps.*.enabled' => 'sometimes|boolean',
            'tasks.*.steps.*.max_attempts' => 'sometimes|integer|min:1|max:20',
            'tasks.*.steps.*.ttl_seconds' => 'sometimes|integer|min:60|max:604800',
            'tasks.*.steps.*.delay_seconds' => 'sometimes|integer|min:0|max:604800',
            'tasks.*.steps.*.daily_at' => 'sometimes|date_format:H:i',
            'tasks.*.steps.*.timezone' => 'sometimes|timezone',
        ])->validate();
        $this->graph($d['tasks']);
        foreach ($d['tasks'] as &$task) {
            $this->graph($task['steps']);
            foreach ($task['when'] ?? [] as $path => $value) {
                if (! preg_match('/^payload\.[a-zA-Z0-9_.-]+$/', (string) $path) || (! is_scalar($value) && $value !== null)) {
                    $this->error('触发条件必须使用 payload 字段路径和标量值。');
                }
            }

            foreach ($task['steps'] as &$step) {
                if (($task['enabled'] ?? true) === false || ($step['enabled'] ?? true) === false) {
                    continue;
                }
                $ep = Endpoint::with('provider')->find($step['endpoint_id']);
                if (! $ep || ! $ep->enabled || ! $ep->provider->enabled) {
                    $this->error('接口不存在或供应商/接口已关闭：'.$step['endpoint_id']);
                }
                $registry = app(Registry::class);
                $driver = $registry->supplier($ep->provider->driver);
                $operation = $registry->operation($ep->provider->driver, $ep->operation);
                foreach ($operation['required_inputs'] as $field) {
                    if (! Arr::has($step['input'], $field)) {
                        $this->error('操作 '.$ep->operation.' 缺少输入映射：'.$field);
                    }
                }
                foreach ($driver->manifest()['credentials'] as $field) {
                    if (empty($ep->provider->credentials[$field])) {
                        $this->error('供应商缺少凭证字段：'.$field);
                    }
                }
                app(TargetGuard::class)->validate($ep->provider->base_url, $operation['path']);
                $step['endpoint_snapshot'] = ['id' => $ep->id, 'name' => $ep->name, 'provider_id' => $ep->provider_id, 'driver' => $ep->provider->driver,
                    'base_url' => $ep->provider->base_url, 'operation' => $ep->operation, 'method' => $operation['method'], 'path' => $operation['path'], 'options' => ['timeout' => min(30, max(1, (int) ($ep->options['timeout'] ?? 10))), 'idempotent' => $operation['idempotent']]];
                $this->checkMappings($step['input'], $task, $step, $d['tasks']);
            }
            unset($step);
        }
        unset($task);

        return $d;
    }

    private function graph(array $nodes): void
    {
        $map = [];
        foreach ($nodes as $n) {
            if (isset($map[$n['key']])) {
                $this->error('标识重复：'.$n['key']);
            } $map[$n['key']] = $n;
        }
        $done = [];
        $visit = function ($key, array $path = []) use (&$visit, &$done, $map) {
            if (isset($done[$key])) {
                return;
            }
            if (in_array($key, $path, true)) {
                $this->error('依赖关系形成循环：'.$key);
            }
            if (! isset($map[$key]) || ! ($map[$key]['enabled'] ?? true)) {
                $this->error('依赖节点不存在或已关闭：'.$key);
            }
            foreach ($map[$key]['depends_on'] as $parent) {
                if (! is_string($parent)) {
                    $this->error('依赖标识必须是字符串。');
                } $visit($parent, [...$path, $key]);
            }
            $done[$key] = true;
        };
        foreach ($nodes as $node) {
            if ($node['enabled'] ?? true) {
                $visit($node['key']);
            }
        }
    }

    private function ancestors(string $key, array $nodes): array
    {
        $map = array_column($nodes, null, 'key');
        $result = [];
        $walk = function ($k) use (&$walk, &$result, $map) {
            foreach ($map[$k]['depends_on'] ?? [] as $p) {
                if (! in_array($p, $result, true)) {
                    $result[] = $p;
                    $walk($p);
                }
            }
        };
        $walk($key);

        return $result;
    }

    private function checkMappings(array $input, array $task, array $step, array $tasks): void
    {
        array_walk_recursive($input, function ($value) use ($task, $step, $tasks) {
            if (! is_string($value) || ! str_starts_with($value, '$')) {
                return;
            }
            if (str_starts_with($value, '$event.')) {
                return;
            }
            if (preg_match('/^\$steps\.([a-z0-9_-]+)\.output(?:\.|$)/', $value, $m) && in_array($m[1], $this->ancestors($step['key'], $task['steps']), true)) {
                return;
            }
            if (preg_match('/^\$tasks\.(.+)\.steps\.([a-z0-9_-]+)\.output(?:\.|$)/', $value, $m) && in_array($m[1], $this->ancestors($task['key'], $tasks), true)) {
                foreach ($tasks as $t) {
                    if ($t['key'] === $m[1]) {
                        foreach ($t['steps'] as $s) {
                            if ($s['key'] === $m[2] && ($s['enabled'] ?? true)) {
                                return;
                            }
                        }
                    }
                }
            }
            $this->error('映射必须引用事件或已声明的前置步骤：'.$value);
        });
    }

    private function error(string $message): never
    {
        throw ValidationException::withMessages(['definition' => $message]);
    }
}
