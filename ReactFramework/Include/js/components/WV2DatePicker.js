// WV2DatePicker - Datumsauswahl Komponente
class WV2DatePicker {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.value = o.value || '';
    this.min = o.min || '';
    this.max = o.max || '';
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.value !== undefined) {
      this.value = p.value;
      const el = document.getElementById('dp-' + this.id);
      if (el) el.value = p.value;
    }
  }

  getState() {
    const el = document.getElementById('dp-' + this.id);
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

    const inp = document.createElement('input');
    inp.type = 'date';
    inp.id = 'dp-' + this.id;
    inp.value = this.value;
    if (this.min) inp.min = this.min;
    if (this.max) inp.max = this.max;
    inp.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';
    inp.disabled = this.disabled;

    const self = this;
    inp.onchange = function() {
      WV2Bridge.sendEvent('onChange', self.id, { value: this.value });
    };

    c.appendChild(inp);
    return c;
  }
}
