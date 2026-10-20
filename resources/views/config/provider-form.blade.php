@extends('layout')
@section('title','供应商配置')
@section('content')
<a href="/providers" class="back-link">返回供应商</a>
<div class="page-heading"><div><h1>{{ $provider->exists?'编辑供应商连接':'添加供应商连接' }}</h1><p>一个供应商系统对应一个实现类。同一系统的测试、生产或不同账号可建立多个连接。</p></div></div>
<form class="panel padded editor-form" method="post" action="/providers{{ $provider->exists?'/'.$provider->id:'' }}">@csrf
<div class="form-grid">
<label>连接语义标识<input name="id" value="{{ old('id',$provider->id) }}" placeholder="crm.acme.production" required @readonly($provider->exists)></label>
<label>显示名称<input name="name" value="{{ old('name',$provider->name) }}" required placeholder="Acme CRM 生产环境"></label>
<label>供应商实现<select name="driver" id="supplier-driver" @disabled($provider->exists)>
@if($provider->exists && !in_array($provider->driver,array_column($drivers,'id')))<option value="{{ $provider->driver }}" selected>{{ $provider->driver }}（历史兼容）</option>@endif
@foreach($drivers as $d)<option value="{{ $d['id'] }}" @selected(($provider->exists?$provider->driver:old('driver'))===$d['id'])>{{ $d['name'] }}</option>@endforeach
</select>@if($provider->exists)<input type="hidden" name="driver" value="{{ $provider->driver }}">@endif</label>
<label>基础地址<input name="base_url" type="url" value="{{ old('base_url',$provider->base_url) }}" required placeholder="https://api.example.com"></label>
</div>
<div class="notice" id="supplier-details" role="status"></div>
<label>凭证 JSON<textarea name="credentials" rows="4" autocomplete="off" spellcheck="false" placeholder='{"token":"..."}'></textarea><small>加密保存，不回显。留空保留现有值；所需字段见上方供应商说明。</small></label>
<label>调度与熔断设置<textarea name="settings" rows="5" spellcheck="false">{{ old('settings', json_encode($provider->settings ?: ['interval_ms'=>1000,'circuit_threshold'=>5,'circuit_seconds'=>60],JSON_PRETTY_PRINT)) }}</textarea><small>interval_ms 为请求间隔（以秒取整）；每个连接同时最多执行一个请求。</small></label>
<label class="check"><input type="checkbox" name="enabled" value="1" @checked(old('enabled',$provider->exists?$provider->enabled:true))>启用连接。关闭后停止领取新请求，已有在途请求继续完成。</label>
@if($provider->exists)<p class="muted">已有连接不可切换供应商实现。更换供应商时，创建新连接并发布模板，避免历史任务误用其他供应商的凭证。</p>@endif
<div class="form-actions"><button class="button primary">保存供应商</button><a href="/providers">取消</a></div></form>
@endsection
@push('scripts')
<script type="application/json" id="supplier-catalog">{!! json_encode($drivers, JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE) !!}</script>
<script src="/assets/supplier-config.js" defer></script>
@endpush
