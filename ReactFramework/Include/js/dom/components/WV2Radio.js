// WV2Radio - Radio Button Gruppe
class WV2Radio {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.options = o.options || [];
    this.value = o.value || '';
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.value !== undefined) this.value = p.value;
  }

  getState() {
    const el = document.querySelector('input[name="radio-' + this.id + '"]:checked');
    return { value: el ? el.value : this.value };
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';

    if (this.label) {
      const lblDiv = document.createElement('div');
      lblDiv.className = 'text-sm font-medium text-gray-700 dark:text-gray-300 mb-2';
      lblDiv.textContent = this.label;
      c.appendChild(lblDiv);
    }

    const self = this;
    this.options.forEach((opt) => {
      const lbl = document.createElement('label');
      lbl.className = 'flex items-center gap-2 mb-1 cursor-pointer';

      const inp = document.createElement('input');
      inp.type = 'radio';
      inp.name = 'radio-' + this.id;
      inp.value = opt.value;
      inp.checked = (this.value === opt.value);
      inp.className = 'w-4 h-4 text-blue-600';

      inp.onchange = function() {
        WV2Bridge.sendEvent('onChange', self.id, { value: this.value });
      };

      const span = document.createElement('span');
      span.className = 'text-gray-700 dark:text-gray-300';
      span.textContent = opt.label;

      lbl.appendChild(inp);
      lbl.appendChild(span);
      c.appendChild(lbl);
    });

    return c;
  }
}
