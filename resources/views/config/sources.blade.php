@extends('layout')
@section('title','业务来源')
@section('content')
<div class="page-heading"><div><h1>业务来源</h1><p>每个业务系统使用独立 Token。接收事件时自动识别来源。</p></div><a class="button primary" href="/sources/create">添加业务来源</a></div>
<div class="panel table-scroll"><table><thead><tr><th>业务系统</th><th>接入状态</th><th>事件数</th><th>Token 生成时间</th><th>操作</th></tr></thead><tbody>
@forelse($sources as $source)<tr><td><a class="cell-title" href="/sources/{{ $source->id }}/edit">{{ $source->name }}</a><small class="mono">{{ $source->id }}</small></td><td><span class="badge {{ $source->enabled && $source->token_issued_at ? 'succeeded':'waiting' }}">{{ !$source->token_issued_at ? '未生成 Token' : ($source->enabled?'已启用':'已停用') }}</span></td><td>{{ $source->events_count }}</td><td>{{ \App\Support\Ui::date($source->token_issued_at) }}</td><td><a href="/sources/{{ $source->id }}/edit">管理</a></td></tr>
@empty<tr><td colspan="5"><div class="empty">添加业务来源，生成该系统专用的接入 Token。</div></td></tr>@endforelse
</tbody></table></div>
<p class="muted">Token 仅在生成时显示。停用或重新生成后，后续鉴权将拒绝旧凭证；已经接收的事件继续处理。</p>
@endsection
