@extends('layout')
@section('title','业务来源配置')
@section('content')
<a href="/sources" class="back-link">返回业务来源</a>
<div class="page-heading"><div><h1>{{ $source->exists ? '编辑业务来源' : '添加业务来源' }}</h1><p>来源标识由服务端绑定到 Token，业务系统提交事件时无需填写。</p></div></div>
<form class="panel padded editor-form" method="post" action="/sources{{ $source->exists ? '/'.$source->id : '' }}">@csrf
<div class="form-grid">
<label>来源标识<input name="id" value="{{ $source->exists ? $source->id : old('id') }}" placeholder="shop" required @readonly($source->exists)><small>小写字母、数字、点、下划线或短横线；创建后不可修改。</small></label>
<label>系统名称<input name="name" value="{{ old('name',$source->name) }}" required maxlength="150" placeholder="商城系统"></label>
</div>
<label class="check"><input type="checkbox" name="enabled" value="1" @checked(old('enabled',$source->exists?$source->enabled:true))>允许该系统提交事件</label>
<div class="form-actions"><button class="button primary">{{ $source->exists ? '保存来源' : '创建并生成 Token' }}</button><a href="/sources">取消</a></div>
</form>
@if($source->exists)<section class="panel padded"><h2>接入 Token</h2><p>Token 不可回查。重新生成后，旧 Token 立即失效，请更新业务系统配置。</p><form method="post" action="/sources/{{ $source->id }}/rotate">@csrf<button class="button danger">重新生成 Token</button></form></section>@endif
@endsection
