@extends('layout')
@section('title','业务事件')
@section('content')
<div class="page-heading"><div><h1>业务事件</h1><p>从事件入口追踪任务生成和完整调用链。</p></div><span class="count-label">{{ $events->total() }} 条事件</span></div>
<form class="filters"><input name="q" placeholder="事件 ID 或来源" value="{{ request('q') }}" aria-label="搜索事件"><select name="status" aria-label="转换状态"><option value="">全部转换状态</option>@foreach(['pending','converted','failed'] as $s)<option value="{{ $s }}" @selected(request('status')===$s)>{{ \App\Support\Ui::status($s) }}</option>@endforeach</select><button class="button">查询</button><a href="/events">重置</a></form>
<div class="panel">@include('events.table')</div>{{ $events->links('pagination') }}
@endsection
