@extends('layout')
@section('title','投递任务')
@section('content')
<div class="page-heading"><div><h1>投递任务</h1><p>一个任务对应一个业务目标；每个请求步骤独立重试。</p></div><span>{{ $tasks->total() }} 个任务</span></div>
@include('status-filter',['base'=>'/tasks'])
<div class="panel table-scroll"><table><thead><tr><th>任务</th><th>事件 / 来源</th><th>状态</th><th>请求步骤</th><th>前置任务</th><th>运行控制</th></tr></thead><tbody>@forelse($tasks as $t)<tr><td><a class="cell-title" href="/events/{{ $t->event_id }}#task-{{ $t->id }}">{{ $t->name }}</a><small class="mono">{{ $t->key }}</small></td><td>{{ $t->event->external_id }}<small>{{ $t->event->source }}</small></td><td><span class="badge {{ $t->status }}">{{ \App\Support\Ui::status($t->status) }}</span>@if($t->paused)<small>已暂停</small>@endif</td><td>{{ $t->steps_count }}</td><td>{{ implode('、',$t->depends_on) ?: '无' }}</td><td><form action="/tasks/{{ $t->id }}/pause" method="post">@csrf<button class="text-button">{{ $t->paused?'恢复':'暂停' }}</button></form></td></tr>@empty<tr><td colspan="6"><div class="empty">没有匹配的任务。</div></td></tr>@endforelse</tbody></table></div>{{ $tasks->links('pagination') }}
@endsection
