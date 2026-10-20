@extends('layout')
@section('title','操作审计')
@section('content')
<div class="page-heading"><div><h1>操作审计</h1><p>记录配置变更、发布和人工恢复。</p></div></div><div class="panel table-scroll"><table><thead><tr><th>时间</th><th>操作人</th><th>操作</th><th>对象</th><th>详情</th></tr></thead><tbody>@forelse($entries as $e)<tr><td class="nowrap">{{ \App\Support\Ui::date($e->created_at) }}</td><td>{{ $e->actor }}</td><td><code>{{ $e->action }}</code></td><td class="mono">{{ $e->subject }}</td><td><details><summary>查看</summary><pre>{{ \App\Support\Ui::json($e->details) }}</pre></details></td></tr>@empty<tr><td colspan="5"><div class="empty">尚无管理操作记录。</div></td></tr>@endforelse</tbody></table></div>{{ $entries->links('pagination') }}
@endsection
