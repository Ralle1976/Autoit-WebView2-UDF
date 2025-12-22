// WV2TreeView - Baumstruktur Komponente
class WV2TreeView {
  constructor(id, o) {
    this.id = id;
    this.nodes = o.nodes || [];
    this.expandedIds = o.expandedIds || [];
    this.selectedId = o.selectedId || '';
  }

  update(p) {
    if (p.nodes) this.nodes = p.nodes;
    this.rerender();
  }

  getState() {
    return { selectedId: this.selectedId, expandedIds: this.expandedIds };
  }

  rerender() {
    const el = document.getElementById('tree-' + this.id);
    if (el) {
      el.innerHTML = '';
      el.appendChild(this.renderNodes(this.nodes, 0));
    }
  }

  renderNodes(nodes, level) {
    const ul = document.createElement('ul');
    ul.className = (level > 0 ? 'ml-4 ' : '') + 'list-none';

    const self = this;
    nodes.forEach(n => {
      const hasChildren = n.children && n.children.length > 0;
      const expanded = this.expandedIds.includes(n.id);
      const selected = this.selectedId === n.id;

      const li = document.createElement('li');
      li.className = 'py-1';

      const row = document.createElement('div');
      row.className = 'flex items-center gap-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 rounded px-2 py-1 ' +
        (selected ? 'bg-blue-100 dark:bg-blue-900' : '');

      row.onclick = function(e) {
        self.selectedId = n.id;
        self.rerender();
        WV2Bridge.sendEvent('onSelect', self.id, { id: n.id });
      };

      // Toggle icon
      const toggle = document.createElement('span');
      if (hasChildren) {
        toggle.innerHTML = expanded ? '&#9660;' : '&#9654;';
        toggle.onclick = function(e) {
          e.stopPropagation();
          const idx = self.expandedIds.indexOf(n.id);
          if (idx > -1) {
            self.expandedIds.splice(idx, 1);
          } else {
            self.expandedIds.push(n.id);
          }
          self.rerender();
        };
      } else {
        toggle.className = 'w-4';
      }

      const label = document.createElement('span');
      label.textContent = n.label;

      row.appendChild(toggle);
      row.appendChild(label);
      li.appendChild(row);

      if (hasChildren && expanded) {
        li.appendChild(this.renderNodes(n.children, level + 1));
      }

      ul.appendChild(li);
    });

    return ul;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';
    c.id = 'tree-' + this.id;
    c.appendChild(this.renderNodes(this.nodes, 0));
    return c;
  }
}
