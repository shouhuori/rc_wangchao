'use strict';
(() => {
  const catalogNode = document.getElementById('supplier-catalog');
  if (!catalogNode) return;
  const catalog = new Map(JSON.parse(catalogNode.textContent).map(driver => [driver.id, driver]));
  const driverSelect = document.getElementById('supplier-driver');
  if (driverSelect) {
    const describe = () => {
      const driver = catalog.get(driverSelect.value);
      document.getElementById('supplier-details').textContent = driver
        ? `${driver.description} 必要凭证：${driver.credentials.join('、') || '无'}。支持操作：${Object.keys(driver.operations).join('、')}。`
        : '历史通用 Driver 仅保留旧任务执行和密钥轮换。新流程请创建使用供应商专用实现的连接。';
    };
    driverSelect.addEventListener('change', describe);
    describe();
  }
  const providerSelect = document.getElementById('endpoint-provider');
  const operationSelect = document.getElementById('endpoint-operation');
  if (!providerSelect || !operationSelect) return;
  const driver = () => catalog.get(providerSelect.selectedOptions[0]?.dataset.driver);
  const describe = () => {
    const operation = driver()?.operations[operationSelect.value];
    document.getElementById('operation-details').textContent = operation
      ? `${operation.method} ${operation.path} ｜ 必要输入：${operation.required_inputs.join('、')} ｜ ${operation.idempotent ? '供应商支持幂等重发' : '不保证幂等，未知结果需核对'}。以上协议由供应商类定义。`
      : '请选择该供应商已实现的操作。旧通用 Driver 不提供新操作，请先创建供应商专用连接。';
  };
  const populate = (selected = '') => {
    operationSelect.replaceChildren(new Option('请选择操作', ''));
    Object.entries(driver()?.operations || {}).forEach(([id, operation]) => {
      operationSelect.add(new Option(`${operation.name} (${id})`, id, false, id === selected));
    });
    describe();
  };
  providerSelect.addEventListener('change', () => populate());
  operationSelect.addEventListener('change', describe);
  populate(operationSelect.dataset.selected);
})();
