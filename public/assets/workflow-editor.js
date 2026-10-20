'use strict';
(() => {
  const form = document.querySelector('#workflow-editor'); if (!form) return;
  const raw = document.querySelector('#definition-json');
  const hidden = document.querySelector('#definition-value');
  const root = document.querySelector('#task-editor');
  const result = document.querySelector('#validation-result');
  const catalog = JSON.parse(document.querySelector('#endpoint-catalog').textContent);
  let definition;
  try { definition = JSON.parse(raw.value); } catch { definition = { tasks: [] }; }
  const el = (tag, text, cls) => { const n = document.createElement(tag); if (text !== undefined) n.textContent = text; if (cls) n.className = cls; return n; };
  function sync() { hidden.value = JSON.stringify(definition); raw.value = JSON.stringify(definition, null, 2); }
  function button(text, action, cls = 'button') { const b = el('button', text, cls); b.type = 'button'; b.addEventListener('click', action); return b; }
  function field(parent, label, value, change, options = {}) {
    const wrap = el('label', label); let control;
    if (options.select) {
      control = el('select');
      control.append(new Option('请选择接口', ''));
      options.select.forEach(o => control.append(new Option(o.name, o.id)));
      control.value = value;
    } else {
      control = el(options.area ? 'textarea' : 'input');
      control.value = value ?? '';
      if (options.area) { control.rows = options.rows || 3; control.spellcheck = false; }
      else control.type = options.type || 'text';
      if (options.min !== undefined) control.min = options.min;
    }
    control.addEventListener('change', () => { change(options.type === 'number' ? Number(control.value) : control.value); sync(); });
    wrap.append(control); parent.append(wrap); return control;
  }
  function checkbox(parent, label, checked, change) {
    const wrap = el('label', undefined, 'check'); const control = el('input'); control.type = 'checkbox'; control.checked = checked;
    control.addEventListener('change', () => { change(control.checked); sync(); });
    wrap.append(control, document.createTextNode(label)); parent.append(wrap);
  }
  function dependencies(parent, title, node, choices) {
    parent.append(el('label', title)); const group = el('div', undefined, 'dependency-options');
    choices.forEach(choice => checkbox(group, choice.name || choice.key, (node.depends_on || []).includes(choice.key), checked => {
      const set = new Set(node.depends_on || []); checked ? set.add(choice.key) : set.delete(choice.key); node.depends_on = [...set];
    }));
    if (!choices.length) group.append(el('small', '没有其他可选节点。'));
    const unknown = (node.depends_on || []).filter(k => !choices.some(c => c.key === k));
    if (unknown.length) group.append(el('small', `无效依赖：${unknown.join('、')}。请通过高级 JSON 修正。`));
    parent.append(group);
  }
  function swap(items, index, delta) { const j = index + delta; if (j < 0 || j >= items.length) return; [items[index], items[j]] = [items[j], items[index]]; render(); }
  function newStep(task) {
    let n = task.steps.length + 1; while (task.steps.some(s => s.key === `step-${n}`)) n++;
    return { key: `step-${n}`, name: '新的请求步骤', endpoint_id: catalog[0]?.id || '', enabled: true, depends_on: [], input: { order_id: '$event.payload.order_id' }, max_attempts: 5, ttl_seconds: 86400 };
  }
  function render() {
    root.replaceChildren();
    if (!Array.isArray(definition.tasks)) definition.tasks = [];
    definition.tasks.forEach((task, ti) => {
      task.steps ||= []; task.depends_on ||= [];
      const card = el('section', undefined, 'editor-task'); const head = el('div', undefined, 'editor-task-header');
      head.append(el('strong', task.name || task.key)); const controls = el('div');
      controls.append(button('上移', () => swap(definition.tasks, ti, -1)), button('下移', () => swap(definition.tasks, ti, 1)), button('移除任务', () => {
        if (confirm('移除此任务？引用它的依赖需要一并调整。')) { definition.tasks.splice(ti, 1); render(); }
      })); head.append(controls); card.append(head);
      const fields = el('div', undefined, 'form-grid');
      field(fields, '任务语义标识', task.key, v => {
        const old = task.key; task.key = v;
        definition.tasks.forEach(t => { t.depends_on = (t.depends_on || []).map(k => k === old ? v : k); }); render();
      });
      field(fields, '任务名称', task.name, v => { task.name = v; }); card.append(fields);
      checkbox(card, '启用此任务', task.enabled !== false, v => { task.enabled = v; });
      dependencies(card, '必须先成功的任务', task, definition.tasks.filter(t => t !== task));
      const condition = field(card, '触发条件 JSON（所有字段必须相等；{} 表示始终触发）', JSON.stringify(task.when || {}, null, 2), v => {
        try { const parsed = JSON.parse(v); if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw Error(); task.when = parsed; condition.setCustomValidity(''); }
        catch { condition.setCustomValidity('请输入 JSON 对象，例如 {"payload.channel":"ads"}。'); condition.reportValidity(); }
      }, { area: true, rows: 2 });

      task.steps.forEach((step, si) => {
        step.depends_on ||= []; step.input ||= {};
        const box = el('section', undefined, 'editor-step'); const sh = el('div', undefined, 'editor-task-header');
        sh.append(el('strong', `请求步骤 ${si + 1}`)); const sc = el('div');
        sc.append(button('上移', () => swap(task.steps, si, -1)), button('下移', () => swap(task.steps, si, 1)), button('移除', () => { task.steps.splice(si, 1); render(); })); sh.append(sc); box.append(sh);
        const grid = el('div', undefined, 'form-grid');
        field(grid, '步骤标识', step.key, v => { const old = step.key; step.key = v; task.steps.forEach(s => { s.depends_on = (s.depends_on || []).map(k => k === old ? v : k); }); render(); });
        field(grid, '步骤名称', step.name, v => { step.name = v; });
        field(grid, '供应商 API', step.endpoint_id, v => { step.endpoint_id = v; delete step.endpoint_snapshot; }, { select: catalog.map(c => ({ id: c.id, name: `${c.provider} / ${c.name} (${c.id})` })) });
        field(grid, '自动尝试上限', step.max_attempts ?? 5, v => { step.max_attempts = v; }, { type: 'number', min: 1 });
        field(grid, '延迟执行（秒）', step.delay_seconds ?? 0, v => { step.delay_seconds = v; }, { type: 'number', min: 0 });
        field(grid, '投递有效期（秒，从计划执行开始）', step.ttl_seconds ?? 86400, v => { step.ttl_seconds = v; }, { type: 'number', min: 60 });
        field(grid, '每日发送时刻（可选）', step.daily_at ?? '', v => { if (v) { step.daily_at = v; step.timezone ||= 'Asia/Shanghai'; } else { delete step.daily_at; delete step.timezone; } }, { type: 'time' });
        box.append(grid); checkbox(box, '启用此步骤', step.enabled !== false, v => { step.enabled = v; });
        dependencies(box, '必须先成功的步骤', step, task.steps.filter(s => s !== step));
        const input = field(box, '请求参数映射 JSON', JSON.stringify(step.input, null, 2), v => {
          try { const parsed = JSON.parse(v); if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) throw Error(); step.input = parsed; input.setCustomValidity(''); }
          catch { input.setCustomValidity('请输入有效的 JSON 对象。'); input.reportValidity(); }
        }, { area: true });
        card.append(box);
      });
      card.append(button('添加 HTTP 请求步骤', () => { task.steps.push(newStep(task)); render(); })); root.append(card);
    });
    if (!definition.tasks.length) root.append(el('div', '添加第一个投递任务，选择供应商接口并配置输入映射。', 'panel empty'));
    sync();
  }
  document.querySelector('#add-task').addEventListener('click', () => {
    let n = definition.tasks.length + 1; while (definition.tasks.some(t => t.key === `task-${n}`)) n++;
    definition.tasks.push({ key: `task-${n}`, name: '新的投递任务', enabled: true, depends_on: [], steps: [] }); render();
  });
  document.querySelector('#apply-json').addEventListener('click', () => {
    try { const next = JSON.parse(raw.value); if (!next || !Array.isArray(next.tasks)) throw Error('必须包含 tasks 数组。'); definition = next; render(); result.className = 'notice success'; result.textContent = '已应用 JSON，请校验并保存草稿。'; }
    catch (error) { result.className = 'notice error'; result.textContent = `导入失败：${error.message}`; }
  });
  document.querySelector('#validate-workflow').addEventListener('click', async () => {
    if (!form.reportValidity()) return; sync(); result.className = 'notice'; result.textContent = '正在校验…';
    try {
      const response = await fetch('/workflow-validation', { method: 'POST', headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-TOKEN': document.querySelector('meta[name=csrf-token]').content }, body: JSON.stringify({ definition: hidden.value }) });
      const data = await response.json(); result.className = `notice ${response.ok ? 'success' : 'error'}`;
      result.textContent = response.ok ? data.message : Object.values(data.errors || { error: data.message }).flat().join('；');
    } catch { result.className = 'notice error'; result.textContent = '校验请求失败，请检查网络或重新登录。'; }
  });
  form.addEventListener('submit', () => sync()); render();
})();
