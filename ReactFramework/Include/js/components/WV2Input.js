// WV2Input - Eingabefeld Komponente
class WV2Input {
  constructor(id, o) {
    this.id = id;
    this.type = o.type || 'text';
    this.placeholder = o.placeholder || '';
    this.label = o.label || '';
    this.value = o.value || '';
    this.disabled = o.disabled || false;
    this.required = o.required || false;
  }

  update(p) {
    if (p.value !== undefined) {
      this.value = p.value;
      const el = document.getElementById('input-' + this.id);
      if (el) el.value = p.value;
    }
    if (p.disabled !== undefined) this.disabled = p.disabled;
  }

  getState() {
    const el = document.getElementById('input-' + this.id);
    return { value: el ? el.value : this.value };
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';

    if (this.label) {
      const lbl = document.createElement('label');
      lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1';
      lbl.textContent = this.label;
      if (this.required) {
        const sp = document.createElement('span');
        sp.className = 'text-red-500';
        sp.textContent = '*';
        lbl.appendChild(sp);
      }
      c.appendChild(lbl);
    }

    const inp = document.createElement('input');
    inp.type = this.type;
    inp.id = 'input-' + this.id;
    inp.value = this.value;
    inp.placeholder = this.placeholder;
    inp.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent';

    if (this.disabled) inp.disabled = true;

    const self = this;
    inp.onchange = function() {
      WV2Bridge.sendEvent('onChange', self.id, { value: this.value });
    };
    inp.oninput = function() {
      WV2Bridge.sendEvent('onInput', self.id, { value: this.value });
    };

    c.appendChild(inp);
    return c;
  }
}
