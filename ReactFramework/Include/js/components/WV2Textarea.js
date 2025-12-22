// WV2Textarea - Mehrzeiliges Textfeld
class WV2Textarea {
  constructor(id, o) {
    this.id = id;
    this.placeholder = o.placeholder || '';
    this.label = o.label || '';
    this.value = o.value || '';
    this.rows = o.rows || 4;
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.value !== undefined) {
      this.value = p.value;
      const el = document.getElementById('ta-' + this.id);
      if (el) el.value = p.value;
    }
  }

  getState() {
    const el = document.getElementById('ta-' + this.id);
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

    const ta = document.createElement('textarea');
    ta.id = 'ta-' + this.id;
    ta.rows = this.rows;
    ta.placeholder = this.placeholder;
    ta.value = this.value;
    ta.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';

    if (this.disabled) ta.disabled = true;

    const self = this;
    ta.onchange = function() {
      WV2Bridge.sendEvent('onChange', self.id, { value: this.value });
    };

    c.appendChild(ta);
    return c;
  }
}
