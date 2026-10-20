<?php

namespace App\Http\Controllers;

use App\Dispatch\Audit;
use App\Dispatch\ManualActions;
use App\Models\DeliveryTask;
use App\Models\Provider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OperationsController extends Controller
{
    public function retry(Request $r, string $id)
    {
        $r->validate(['reason' => 'required|string|min:3|max:500']);
        app(ManualActions::class)->retry($id, $r->user()->email, $r->string('reason'), $r->boolean('verified'));

        return back()->with('success', '已恢复请求，等待调度。历史执行和幂等键保持不变。');
    }

    public function confirm(Request $r, string $id)
    {
        $r->validate(['reason' => 'required|string|min:3|max:500', 'output' => 'required|json', 'verified' => 'accepted']);
        $output = json_decode($r->input('output'), true);
        abort_unless(is_array($output), 422, '输出必须为 JSON 对象。');
        app(ManualActions::class)->confirmSuccess($id, $r->user()->email, $r->string('reason'), $output);

        return back()->with('success', '已记录人工核对结果并释放依赖。');
    }

    public function reconvert(Request $r, string $id)
    {
        $r->validate(['reason' => 'required|string|min:3|max:500']);
        app(ManualActions::class)->reconvert($id, $r->user()->email, $r->string('reason'));

        return back()->with('success', '已安排重新转换，继续使用原配置版本。');
    }

    public function pause(Request $r, string $id)
    {
        DB::transaction(function () use ($r, $id) {
            $t = DeliveryTask::lockForUpdate()->findOrFail($id);
            $t->update(['paused' => ! $t->paused]);
            Audit::record($r->user()->email, $t->paused ? 'task.pause' : 'task.resume', $id);
        });

        return back()->with('success', '运行开关已更新。已发出的 HTTP 请求会完成本次执行。');
    }

    public function resetCircuit(Request $r, string $id)
    {
        DB::transaction(function () use ($r, $id) {
            Provider::findOrFail($id)->update(['circuit_until' => null, 'failure_streak' => 0]);
            Audit::record($r->user()->email, 'provider.reset-circuit', $id);
        });

        return back()->with('success','熔断已重置。');
    }
}
