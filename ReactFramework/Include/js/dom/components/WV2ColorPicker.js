// WV2ColorPicker - Farbauswahl Komponente
class WV2ColorPicker {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.value = o.value || '#3B82F6';
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.value !== undefined) {
      this.value = p.value;
      const el = document.getElementById('cp-' + this.id);
      if (el) el.value = p.value;
      const valEl = document.getElementById('cpv-' + this.id);
      if (valEl) valEl.textContent = p.value;
    }
  }

  getState() {
    const el = document.getElementById('cp-' + this.id);
    return { value: el ? el.value : this.value };
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';

    if (this.label) {
      const lbl = document.createElement('label');
      lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1';
      lbl.textContent = this.label;
      c.appendChild(lbl);
    }

    const wrapper = document.createElement('div');
    wrapper.className = 'flex items-center gap-2';

    const inp = document.createElement('input');
    inp.type = 'color';
    inp.id = 'cp-' + this.id;
    inp.value = this.value;
    inp.className = 'w-12 h-10 rounded cursor-pointer';
    inp.disabled = this.disabled;

    const valSpan = document.createElement('span');
    valSpan.id = 'cpv-' + this.id;
    valSpan.className = 'text-gray-600 dark:text-gray-400 font-mono';
    valSpan.textContent = this.value;

    const self = this;
    inp.onchange = function() {
      valSpan.textContent = this.value;
      WV2Bridge.sendEvent('onChange', self.id, { value: this.value });
    };

    wrapper.appendChild(inp);
    wrapper.appendChild(valSpan);
    c.appendChild(wrapper);
    return c;
  }
}
