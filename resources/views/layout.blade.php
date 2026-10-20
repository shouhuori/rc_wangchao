<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="csrf-token" content="{{ csrf_token() }}"><title>@yield('title','分发工作台') · Relay</title><link rel="stylesheet" href="/assets/app.css"><script src="/assets/app.js" defer></script></head>
<body><aside class="sidebar"><a class="brand" href="/"><span class="brand-mark">↗</span><span>Relay<small>事件分发工作台</small></span></a><nav aria-label="主导航">
@foreach(['运行观察'=>['/'=>'运行总览','/events'=>'业务事件','/tasks'=>'投递任务','/requests'=>'HTTP 请求','/dead-letters'=>'异常与死信'],'分发配置'=>['/sources'=>'业务来源','/providers'=>'供应商','/endpoints'=>'供应商接口','/workflows'=>'事件与任务模板'],'系统'=>['/audit'=>'操作审计']] as $group=>$links)
<div class="nav-group">{{ $group }}</div>@foreach($links as $url=>$label)<a class="nav-link {{ ($url==='/'?request()->path()==='/':request()->is(ltrim($url,'/').'*'))?'active':'' }}" href="{{ $url }}"><span class="nav-dot"></span>{{ $label }}</a>@endforeach
@endforeach</nav><div class="sidebar-footer"><span class="dot online"></span> {{ app()->environment() }}<small>MySQL 持久化 · 异步分发</small></div></aside>
<div class="app"><header class="topbar"><span>通知分发 / @yield('title','运行总览')</span><div class="top-actions"><span>UTC+8</span><form method="post" action="/logout">@csrf<button class="text-button">{{ auth()->user()->name ?? '管理员' }} · 退出</button></form></div></header><main>
@if(session('success'))<div class="notice success" role="status">{{ session('success') }}</div>@endif
@if($errors->any())<div class="notice error" role="alert">@foreach($errors->all() as $error)<p>{{ $error }}</p>@endforeach</div>@endif
@yield('content')</main><footer class="page-footer">Relay / 可靠接收，可追溯执行 <span>所有时间以北京时间显示</span></footer></div>@stack('scripts')</body></html>
