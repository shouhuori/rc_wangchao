@extends('layout')
@section('title',$dead?'异常与死信':'HTTP 请求')
@section('content')
<div class="page-heading"><div><h1>{{ $dead?'异常与死信':'HTTP 请求' }}</h1><p>{{ $dead?'最终失败、结果未知与依赖阻塞需要分别处理。':'查看每个逻辑请求及其全部执行尝试。' }}</p></div><span>{{ $steps->total() }} 个请求</span></div>
@if(!$dead)@include('status-filter',['base'=>'/requests'])@endif
@if($dead && $failedEvents->isNotEmpty())<div class="notice error"><strong>事件转换失败</strong>@foreach($failedEvents as $e)<p><a href="/events/{{ $e->id }}">{{ $e->external_id }}</a> · {{ $e->conversion_error }}</p>@endforeach</div>@endif
<div class="panel table-scroll"><table><thead><tr><th>请求步骤</th><th>供应商</th><th>状态</th><th>尝试次数</th><th>{{ $dead?'异常原因':'计划执行时间' }}</th><th></th></tr></thead><tbody>@forelse($steps as $s)<tr><td><a class="cell-title" href="/requests/{{ $s->id }}">{{ $s->name }}</a><small>{{ $s->task->event->external_id }} / {{ $s->task->name }}</small></td><td>{{ $s->provider->name }}</td><td><span class="badge {{ $s->status }}">{{ \App\Support\Ui::status($s->status) }}</span></td><td>{{ $s->attempt_count }}<small>本轮 {{ $s->cycle_attempts }} / {{ $s->max_attempts }}</small></td><td class="error-cell">{{ $dead?($s->last_error ?: '等待前置步骤恢复'): \App\Support\Ui::date($s->available_at) }}</td><td><a href="/requests/{{ $s->id }}">{{ $dead?'查看与处理':'执行记录' }}</a></td></tr>@empty<tr><td colspan="6"><div class="empty">{{ $dead?'当前没有需要处理的异常。':'没有匹配的 HTTP 请求。' }}</div></td></tr>@endforelse</tbody></table></div>{{ $steps->links('pagination') }}
@endsection
