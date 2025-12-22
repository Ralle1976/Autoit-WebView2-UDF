// WV2Slider - Schieberegler Komponente
class WV2Slider {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.value = o.value || 50;
    this.min = o.min || 0;
    this.max = o.max || 100;
    this.step = o.step || 1;
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.value !== undefined) {
      this.value = p.value;
      const el = document.getElementById('sl-' + this.id);
      if (el) el.value = p.value;
      const valEl = document.getElementById('slv-' + this.id);
      if (valEl) valEl.textContent = p.value;
    }
  }

  getState() {
    const el = document.getElementById('sl-' + this.id);
    return { value: el ? Number(el.value) : this.value };
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
    wrapper.className = 'flex items-center gap-3';

    const inp = document.createElement('input');
    inp.type = 'range';
    inp.id = 'sl-' + this.id;
    inp.value = this.value;
    inp.min = this.min;
    inp.max = this.max;
    inp.step = this.step;
    inp.className = 'flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer';
    inp.disabled = this.disabled;

    const valSpan = document.createElement('span');
    valSpan.id = 'slv-' + this.id;
    valSpan.className = 'w-12 text-center text-gray-700 dark:text-gray-300 font-mono';
    valSpan.textContent = this.value;

    const self = this;
    inp.oninput = function() {
      valSpan.textContent = this.value;
      WV2Bridge.sendEvent('onChange', self.id, { value: Number(this.value) });
    };

    wrapper.appendChild(inp);
    wrapper.appendChild(valSpan);
    c.appendChild(wrapper);
    return c;
  }
}
