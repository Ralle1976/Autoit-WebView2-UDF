// WV2Checkbox - Checkbox Komponente
class WV2Checkbox {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.checked = o.checked || false;
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.checked !== undefined) {
      this.checked = p.checked;
      const el = document.getElementById('cb-' + this.id);
      if (el) el.checked = p.checked;
    }
  }

  getState() {
    const el = document.getElementById('cb-' + this.id);
    return { checked: el ? el.checked : this.checked };
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-2';

    const lbl = document.createElement('label');
    lbl.className = 'flex items-center gap-2 cursor-pointer';

    const inp = document.createElement('input');
    inp.type = 'checkbox';
    inp.id = 'cb-' + this.id;
    inp.checked = this.checked;
    inp.disabled = this.disabled;
    inp.className = 'w-5 h-5 text-blue-600 rounded focus:ring-blue-500';

    const self = this;
    inp.onchange = function() {
      WV2Bridge.sendEvent('onChange', self.id, { checked: this.checked });
    };

    const span = document.createElement('span');
    span.className = 'text-gray-700 dark:text-gray-300';
    span.textContent = this.label;

    lbl.appendChild(inp);
    lbl.appendChild(span);
    c.appendChild(lbl);
    return c;
  }
}
