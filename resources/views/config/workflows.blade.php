@extends('layout')
@section('title','事件与任务模板')
@section('content')
<div class="page-heading"><div><h1>事件与任务模板</h1><p>配置事件如何转换为任务，以及供应商与接口之间的成功依赖。</p></div><a class="button primary" href="/workflows/create">新建事件模板</a></div><div class="panel table-scroll"><table><thead><tr><th>事件定义</th><th>模板标识</th><th>发布版本</th><th>接收开关</th><th></th></tr></thead><tbody>@forelse($workflows as $w)<tr><td><a href="/workflows/{{ $w->id }}/edit" class="cell-title">{{ $w->name }}</a><small class="mono">{{ $w->event_type }}</small></td><td><code>{{ $w->id }}</code></td><td>{{ $w->activeVersion?'v'.$w->activeVersion->number:'尚未发布' }}</td><td><span class="badge {{ $w->enabled?'succeeded':'waiting' }}">{{ $w->enabled?'启用':'关闭' }}</span></td><td><a href="/workflows/{{ $w->id }}/edit">编辑任务流程</a></td></tr>@empty<tr><td colspan="5"><div class="empty">新建模板，定义事件类型与投递任务。</div></td></tr>@endforelse</tbody></table></div>
@endsection
