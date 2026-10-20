'use strict';
document.querySelectorAll('form[data-confirm]').forEach(form => form.addEventListener('submit', e => {
  if (!window.confirm(form.dataset.confirm)) e.preventDefault();
}));
function drawFlow() {
  document.querySelectorAll('[data-flow]').forEach(canvas => {
    const svg = canvas.querySelector('svg');
    const bounds = canvas.getBoundingClientRect();
    svg.setAttribute('width', canvas.scrollWidth);
    svg.setAttribute('height', canvas.scrollHeight);
    svg.replaceChildren();
    const nodes = new Map([...canvas.querySelectorAll('[data-node]')].map(el => [el.dataset.node, el]));
    nodes.forEach(target => {
      const parents = JSON.parse(target.dataset.parents || '[]');
      parents.forEach(key => {
        const source = nodes.get(key); if (!source) return;
        const a = source.getBoundingClientRect(), b = target.getBoundingClientRect();
        const x1 = a.left + a.width / 2 - bounds.left, y1 = a.bottom - bounds.top;
        const x2 = b.left + b.width / 2 - bounds.left, y2 = b.top - bounds.top;
        const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        if (y2 >= y1) {
          const mid = y1 + (y2 - y1) / 2;
          path.setAttribute('d', `M ${x1} ${y1} V ${mid} H ${x2} V ${y2}`);
        } else {
          const side = (a.right + b.left) / 2 - bounds.left;
          path.setAttribute('d', `M ${x1} ${y1} v 12 H ${side} V ${y2 - 15} H ${x2} V ${y2}`);
        }
        svg.append(path);
      });
    });
  });
}
window.addEventListener('resize', drawFlow);
window.addEventListener('load', drawFlow);
