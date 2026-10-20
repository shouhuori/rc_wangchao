<?php

namespace App\Dispatch;

use App\Models\RequestStep;

class InputMapper
{
    public function resolve(RequestStep $step): array
    {
        $event = $step->task->event;
        $tasks = $event->tasks()->with('steps')->get()->keyBy('key');
        $map = function ($value) use (&$map, $event, $tasks, $step) {
            if (is_array($value)) {
                return array_map($map, $value);
            }
            if (! is_string($value) || ! str_starts_with($value, '$')) {
                return $value;
            }
            $missing = new \stdClass;
            $result = $missing;
            if (str_starts_with($value, '$event.')) {
                $result = data_get($event->toArray(), substr($value, 7), $missing);
            } elseif (preg_match('/^\$steps\.([a-z0-9_-]+)\.output(?:\.(.*))?$/', $value, $m)) {
                $source = $tasks[$step->task->key]->steps->firstWhere('key', $m[1]);
                if ($source?->status === 'succeeded') {
                    $result = isset($m[2]) ? data_get($source->output, $m[2], $missing) : $source->output;
                }
            } elseif (preg_match('/^\$tasks\.(.+)\.steps\.([a-z0-9_-]+)\.output(?:\.(.*))?$/', $value, $m)) {
                $source = $tasks->get($m[1])?->steps->firstWhere('key', $m[2]);
                if ($source?->status === 'succeeded') {
                    $result = isset($m[3]) ? data_get($source->output, $m[3], $missing) : $source->output;
                }
            }
            if ($result === $missing) {
                throw new \InvalidArgumentException('映射字段不存在：'.$value);
            }

            return $result;
        };

        return $map($step->input_mapping);
    }
}
