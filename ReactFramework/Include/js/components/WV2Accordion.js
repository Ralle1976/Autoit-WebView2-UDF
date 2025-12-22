// WV2Accordion - Akkordeon/Klappbare Bereiche Komponente
class WV2Accordion {
  constructor(id, o) {
    this.id = id;
    this.items = o.items || [];
    this.multiple = o.multiple || false;
    this.openIds = o.openIds || [];
  }

  update(p) {
    if (p.openIds) this.openIds = p.openIds;
    this.rerender();
  }

  getState() {
    return { openIds: this.openIds };
  }

  rerender() {
    const el = document.getElementById('acc-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'acc-' + this.id;
    container.className = 'border border-gray-200 dark:border-gray-700 rounded-lg divide-y divide-gray-200 dark:divide-gray-700';

    const self = this;
    this.items.forEach(item => {
      const open = this.openIds.includes(item.id);

      const itemDiv = document.createElement('div');

      const btn = document.createElement('button');
      btn.className = 'w-full px-4 py-3 text-left font-medium flex justify-between items-center hover:bg-gray-50 dark:hover:bg-gray-700';
      btn.onclick = function() {
        const idx = self.openIds.indexOf(item.id);
        if (idx > -1) {
          self.openIds.splice(idx, 1);
        } else {
          if (!self.multiple) self.openIds = [];
          self.openIds.push(item.id);
        }
        self.rerender();
      };

      const title = document.createTextNode(item.title);
      const icon = document.createElement('span');
      icon.innerHTML = open ? '&#9650;' : '&#9660;';

      btn.appendChild(title);
      btn.appendChild(icon);
      itemDiv.appendChild(btn);

      if (open) {
        const content = document.createElement('div');
        content.className = 'px-4 py-3 text-gray-600 dark:text-gray-300';
        content.innerHTML = item.content;
        itemDiv.appendChild(content);
      }

      container.appendChild(itemDiv);
    });

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';
    c.appendChild(this.createInner());
    return c;
  }
}
