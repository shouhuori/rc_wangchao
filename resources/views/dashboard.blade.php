@extends('layout')
@section('title','运行总览')
@section('content')
<div class="page-heading"><div><h1>分发运行总览</h1><p>查看事件流转、投递状态和需要介入的异常。</p></div><a class="button" href="/events">查看全部事件</a></div>
<div class="overview-strip">@foreach(['events'=>['已接收事件','/events'],'active'=>['待完成请求','/requests'],'success'=>['已成功请求','/requests?status=succeeded'],'attention'=>['需要处理','/dead-letters']] as $key=>[$label,$link])<a href="{{ $link }}" class="overview-item {{ $key==='attention'&&$counts[$key]?'attention':'' }}"><span>{{ $label }}</span><strong>{{ number_format($counts[$key]) }}</strong></a>@endforeach</div>
<div class="section-heading"><h2>事件流入</h2><span class="muted">最近 8 条</span></div>
<div class="panel">@include('events.table',['events'=>$events])</div>
<div class="two-columns"><section><div class="section-heading"><h2>供应商运行状态</h2><a href="/providers">管理供应商</a></div><div class="panel">@forelse($providers as $p)<div class="provider-row"><div><strong>{{ $p->name }}</strong><small class="mono">{{ $p->id }}</small></div><span class="badge {{ !$p->enabled?'waiting':($p->circuit_until?->isFuture()?'dead':'succeeded') }}">{{ !$p->enabled?'已暂停':($p->circuit_until?->isFuture()?'熔断保护':'可调度') }}</span></div>@empty<div class="empty">尚未配置供应商。<a href="/providers/create">添加供应商</a></div>@endforelse</div></section>
<section><div class="section-heading"><h2>等待人工处理</h2><a href="/dead-letters">异常与死信</a></div><div class="panel">@forelse($recentFailures as $s)<a href="/requests/{{ $s->id }}" class="failure-row"><span class="badge {{ $s->status }}">{{ \App\Support\Ui::status($s->status) }}</span><div><strong>{{ $s->name }}</strong><small>{{ $s->last_error }}</small></div></a>@empty<div class="empty"><span class="empty-symbol">✓</span>当前没有最终失败或结果未知的请求。</div>@endforelse</div></section></div>
@endsection
