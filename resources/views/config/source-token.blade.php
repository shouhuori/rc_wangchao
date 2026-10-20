@extends('layout')
@section('title','接入 Token 已生成')
@section('content')
<div class="page-heading"><div><h1>接入 Token 已生成</h1><p>{{ $source->name }} · {{ $source->id }}</p></div></div>
<section class="panel padded"><p>请现在保存到该业务系统的服务端配置。离开页面后无法再次查看；数据库只保存摘要。</p>
<pre aria-label="新接入 Token">{{ $token }}</pre>
<p>请求头：<code>Authorization: Bearer &lt;Token&gt;</code></p>
@unless($source->enabled)<div class="notice">该来源当前停用。启用后才可提交事件。</div>@endunless
<a class="button primary" href="/sources">已保存，返回业务来源</a></section>
@endsection
