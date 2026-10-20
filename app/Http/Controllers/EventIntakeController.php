<?php

namespace App\Http\Controllers;

use App\Dispatch\EventFingerprint;
use App\Models\NotificationEvent;
use App\Models\Workflow;
use App\Rules\EventTimestamp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class EventIntakeController extends Controller
{
    public function __invoke(Request $request)
    {
        $data = $request->validate([
            'id' => 'required|string|max:150', 'source' => 'missing', 'business_key' => 'missing',
            'type' => 'required|string|max:100',
            'predecessor_id' => 'nullable|string|max:150|different:id', 'payload' => 'required|array',
            'occurred_at' => ['sometimes', 'nullable', new EventTimestamp],
        ]);
        $data['source'] = $request->attributes->get('event_source')->id;
        $data['predecessor_id'] = $data['predecessor_id'] ?? null;
        if (isset($data['occurred_at'])) {
            $data['occurred_at'] = EventTimestamp::normalize($data['occurred_at']);
        } else {
            // Preserve fingerprints for callers and events predating this optional field.
            unset($data['occurred_at']);
        }
        $fingerprint = EventFingerprint::make($data);

        return DB::transaction(function () use ($data, $fingerprint) {
            // All identity and predecessor checks share source scope, including forward references.
            DB::table('event_streams')->insertOrIgnore(['source' => $data['source'], 'lock_key' => '__source_lock__']);
            DB::table('event_streams')->where('source', $data['source'])->where('lock_key', '__source_lock__')->lockForUpdate()->first();
            // Acquire the admission lock before any consistent read starts a MySQL snapshot.
            DB::table('event_streams')->insertOrIgnore(['source' => '__relay_capacity__', 'lock_key' => '__capacity__']);
            DB::table('event_streams')->where('source', '__relay_capacity__')->where('lock_key', '__capacity__')->lockForUpdate()->first();
            $existing = NotificationEvent::where('source', $data['source'])->where('external_id', $data['id'])->first();
            if ($existing) {
                abort_unless(hash_equals(EventFingerprint::stored($existing), $fingerprint), 409, '同一事件 ID 对应的内容不同。');

                return response()->json(['id' => $existing->id, 'status' => 'accepted', 'duplicate' => true], 200);
            }
            $outstanding = NotificationEvent::where('conversion_status', 'pending')
                ->orWhereHas('tasks', fn ($q) => $q->whereIn('status', ['waiting', 'ready', 'running', 'retry', 'blocked', 'unknown']))->count();
            abort_if($outstanding >= config('dispatch.max_pending'), 503, '接入容量已满，请稍后重试。');
            $workflow = Workflow::where('event_type', $data['type'])->where('enabled', true)->whereNotNull('active_version_id')->first();
            if (! $workflow) {
                throw ValidationException::withMessages(['type' => '事件类型未发布或已关闭。']);
            }
            foreach ($workflow->activeVersion->definition['required_payload_fields'] ?? [] as $field) {
                if (data_get($data['payload'], $field) === null) {
                    throw ValidationException::withMessages(['payload.'.$field => '缺少事件必填字段：'.$field]);
                }
            }
            $seen = [$data['id']];
            $previous = $data['predecessor_id'];
            while ($previous !== null) {
                if (in_array($previous, $seen, true)) {
                    throw ValidationException::withMessages(['predecessor_id' => '前置事件形成循环。']);
                }
                $seen[] = $previous;
                $parent = NotificationEvent::where('source', $data['source'])->where('external_id', $previous)->first();
                $previous = $parent?->predecessor_id;
            }
            $event = NotificationEvent::create(['external_id' => $data['id'], 'source' => $data['source'], 'type' => $data['type'],
                'predecessor_id' => $data['predecessor_id'], 'payload' => $data['payload'], 'fingerprint_version' => 2,
                'occurred_at' => $data['occurred_at'] ?? null,
                'fingerprint' => $fingerprint, 'version_id' => $workflow->active_version_id, 'conversion_status' => 'pending']);

            return response()->json(['id' => $event->id, 'status' => 'accepted', 'duplicate' => false], 202);
        }, 3);
    }
}
