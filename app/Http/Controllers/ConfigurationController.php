<?php

namespace App\Http\Controllers;

use App\Dispatch\Audit;
use App\Dispatch\Publisher;
use App\Dispatch\TargetGuard;
use App\Drivers\Registry;
use App\Models\Endpoint;
use App\Models\Provider;
use App\Models\Workflow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class ConfigurationController extends Controller
{
    private function json(Request $r, string $field, array $default = []): array
    {
        if (! $r->filled($field)) {
            return $default;
        }
        try {
            $data = json_decode($r->input($field), true, 64, JSON_THROW_ON_ERROR);
        } catch (\Throwable) {
            throw ValidationException::withMessages([$field => 'JSON 格式无效。']);
        }
        if (! is_array($data)) {
            throw ValidationException::withMessages([$field => '请输入 JSON 对象或数组。']);
        }

        return $data;
    }

    public function providers()
    {
        return view('config.providers', ['providers' => Provider::withCount('endpoints')->get(), 'drivers' => app(Registry::class)->all()]);
    }

    public function providerForm(?string $id = null)
    {
        return view('config.provider-form', ['provider' => $id ? Provider::findOrFail($id) : new Provider, 'drivers' => app(Registry::class)->all()]);
    }

    public function saveProvider(Request $r, ?string $id = null)
    {
        $data = $r->validate(['id' => 'required|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/', 'name' => 'required|string|max:150', 'driver' => 'required|string', 'base_url' => 'required|url|max:255']);
        $provider = $id ? Provider::findOrFail($id) : new Provider;
        if (! $id && Provider::whereKey($data['id'])->exists()) {
            throw ValidationException::withMessages(['id' => '标识已存在。']);
        }
        if ($id) {
            $data['id'] = $id;
        }
        app(TargetGuard::class)->validate($data['base_url']);
        if ($provider->exists && $provider->driver !== $data['driver']) {
            throw ValidationException::withMessages(['driver' => '已有连接不能切换供应商实现。请创建新连接并发布模板。']);
        }
        $driver = $provider->exists ? app(Registry::class)->get($data['driver']) : app(Registry::class)->supplier($data['driver']);
        $credentials = $this->json($r, 'credentials', $provider->credentials ?? []);
        foreach ($driver->manifest()['credentials'] as $key) {
            if (empty($credentials[$key])) {
                throw ValidationException::withMessages(['credentials' => '缺少凭证字段：'.$key]);
            }
        }
        $settings = $this->json($r, 'settings');
        Validator::make($settings, ['interval_ms' => 'sometimes|integer|min:0|max:3600000', 'circuit_threshold' => 'sometimes|integer|min:1|max:100', 'circuit_seconds' => 'sometimes|integer|min:1|max:86400'])->validate();
        DB::transaction(function () use ($r, $provider, $data, $credentials, $settings) {
            $provider->fill($data + ['credentials' => $credentials, 'settings' => $settings, 'enabled' => $r->boolean('enabled')])->save();
            Audit::record($r->user()->email, 'provider.save', $provider->id, ['driver' => $provider->driver]);
        });

        return redirect('/providers')->with('success', '供应商配置已保存。');
    }

    public function endpoints()
    {
        return view('config.endpoints', ['endpoints' => Endpoint::with('provider')->get()]);
    }

    public function endpointForm(?string $id = null)
    {
        return view('config.endpoint-form', ['endpoint' => $id ? Endpoint::findOrFail($id) : new Endpoint, 'providers' => Provider::all(), 'drivers' => app(Registry::class)->all()]);
    }

    public function saveEndpoint(Request $r, ?string $id = null)
    {
        $data = $r->validate(['id' => 'required|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/', 'name' => 'required|string|max:150', 'provider_id' => 'required|exists:providers,id', 'operation' => 'required|string|max:100']);
        $endpoint = $id ? Endpoint::findOrFail($id) : new Endpoint;
        if (! $id && Endpoint::whereKey($data['id'])->exists()) {
            throw ValidationException::withMessages(['id' => '标识已存在。']);
        }
        if ($id) {
            $data['id'] = $id;
        }
        $provider = Provider::findOrFail($data['provider_id']);
        $operation = app(Registry::class)->operation($provider->driver, $data['operation']);
        $data['method'] = $operation['method'];
        $data['path'] = $operation['path'];
        app(TargetGuard::class)->validate($provider->base_url, $data['path']);
        $options = $this->json($r, 'options');
        Validator::make($options, ['timeout' => 'required|integer|min:1|max:30'])->validate();
        $options = ['timeout' => (int) $options['timeout'], 'idempotent' => $operation['idempotent']];
        DB::transaction(function () use ($r, $endpoint, $data, $options) {
            $endpoint->fill($data + ['options' => $options, 'enabled' => $r->boolean('enabled')])->save();
            Audit::record($r->user()->email, 'endpoint.save', $endpoint->id);
        });

        return redirect('/endpoints')->with('success', '接口已保存。已发布模板保持原快照；需要发布新版本才能使用改动。');
    }

    public function workflows()
    {
        return view('config.workflows', ['workflows' => Workflow::with('activeVersion')->get()]);
    }

    public function workflowForm(?string $id = null)
    {
        return view('config.workflow-form', [
            'workflow' => $id ? Workflow::with('versions')->findOrFail($id) : new Workflow(['draft' => ['tasks' => []]]),
            'endpoints' => Endpoint::with('provider')->get(),
        ]);
    }

    public function saveWorkflow(Request $r, ?string $id = null)
    {
        $data = $r->validate(['id' => 'required|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/', 'name' => 'required|string|max:150', 'event_type' => 'required|regex:/^[a-z0-9][a-z0-9._-]{0,99}$/']);
        $w = $id ? Workflow::findOrFail($id) : new Workflow;
        if (! $id && Workflow::whereKey($data['id'])->exists()) {
            throw ValidationException::withMessages(['id' => '标识已存在。']);
        }
        if (Workflow::where('event_type', $data['event_type'])->when($id, fn ($q) => $q->where('id', '!=', $id))->exists()) {
            throw ValidationException::withMessages(['event_type' => '该事件类型已有模板。']);
        }
        if ($id) {
            $data['id'] = $id;
            $data['event_type'] = $w->event_type;
        }
        $draft = $this->json($r, 'definition');
        DB::transaction(function () use ($r, $w, $data, $draft) {
            $w->fill($data + ['draft' => $draft, 'enabled' => $r->boolean('enabled')])->save();
            Audit::record($r->user()->email, 'workflow.save-draft', $w->id);
        });

        return redirect('/workflows/'.$w->id.'/edit')->with('success', '草稿已保存，发布后对新事件生效。');
    }

    public function publish(Request $r, string $id)
    {
        app(Publisher::class)->publish($id, $r->user()->email);

        return back()->with('success', '已发布新版本。已有事件继续使用原版本。');
    }

    public function validateDraft(Request $r)
    {
        $definition = $this->json($r, 'definition');
        app(Publisher::class)->validate($definition);

        return response()->json(['message' => '校验通过：Driver、引用、依赖与映射有效。']);
    }

    public function rollback(Request $r, string $id)
    {
        $r->validate(['version_id' => 'required|uuid']);
        DB::transaction(function () use ($r, $id) {
            $w = Workflow::lockForUpdate()->findOrFail($id);
            $version = $w->versions()->findOrFail($r->string('version_id'));
            // Revalidate the selected definition, then publish a new immutable version.
            $w->update(['draft' => $version->definition]);
            app(Publisher::class)->publish($id, $r->user()->email);
            Audit::record($r->user()->email, 'workflow.rollback', $id, ['from_version' => $version->number]);
        });

        return back()->with('success', '历史定义已重新校验并发布为新版本。');
    }
}
