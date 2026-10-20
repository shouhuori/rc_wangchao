@extends('layout')
@section('title','接口配置')
@section('content')
<a class="back-link" href="/endpoints">返回供应商接口</a>
<div class="page-heading"><div><h1>{{ $endpoint->exists?'编辑接口':'添加接口' }}</h1><p>选择供应商类已实现的业务操作。请求格式、认证和成功判定由供应商代码负责。</p></div></div>
<form class="panel padded editor-form" method="post" action="/endpoints{{ $endpoint->exists?'/'.$endpoint->id:'' }}">
@csrf
<div class="form-grid">
<label>接口标识<input name="id" value="{{ old('id',$endpoint->id) }}" required placeholder="crm.contact.mark-paid" @readonly($endpoint->exists)></label>
<label>显示名称<input name="name" value="{{ old('name',$endpoint->name) }}" required></label>
<label>供应商连接<select name="provider_id" id="endpoint-provider" required>@foreach($providers as $p)<option value="{{ $p->id }}" data-driver="{{ $p->driver }}" @selected(old('provider_id',$endpoint->provider_id)===$p->id)>{{ $p->name }}</option>@endforeach</select></label>
<label>供应商 API 操作<select name="operation" id="endpoint-operation" data-selected="{{ old('operation',$endpoint->operation) }}" required><option value="">请选择操作</option></select></label>
</div>
<div class="notice" id="operation-details" role="status"></div>
<label>执行策略 JSON<textarea name="options" rows="4" spellcheck="false">{{ old('options',json_encode(['timeout'=>$endpoint->options['timeout'] ?? 10],JSON_PRETTY_PRINT)) }}</textarea><small>timeout 为请求超时秒数（1–30）。幂等能力、请求方式和成功条件由供应商类声明，后台不能覆盖。</small></label>
<label class="check"><input type="checkbox" name="enabled" value="1" @checked(old('enabled',$endpoint->exists?$endpoint->enabled:true))>允许新模板引用此接口</label>
<p class="muted">保存后需发布事件模板新版本。已有事件继续使用原版本和原供应商操作。</p>
<div class="form-actions"><button class="button primary">保存接口</button><a href="/endpoints">取消</a></div>
</form>
@endsection
@push('scripts')
<script type="application/json" id="supplier-catalog">{!! json_encode($drivers, JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE) !!}</script>
<script src="/assets/supplier-config.js" defer></script>
@endpush
