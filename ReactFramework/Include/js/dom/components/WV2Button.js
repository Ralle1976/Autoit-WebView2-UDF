// WV2Button - Button Komponente
class WV2Button {
  constructor(id, o) {
    this.id = id;
    this.text = o.text || '';
    this.variant = o.variant || 'primary';
    this.size = o.size || 'md';
    this.icon = o.icon || '';
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.text !== undefined) this.text = p.text;
    if (p.disabled !== undefined) this.disabled = p.disabled;
    this.rerender();
  }

  getState() {
    return { text: this.text, disabled: this.disabled };
  }

  rerender() {
    const el = document.getElementById('btn-' + this.id);
    if (el) el.outerHTML = this.renderInner();
  }

  renderInner() {
    const variants = {
      'primary': 'bg-blue-600 hover:bg-blue-700 text-white',
      'secondary': 'bg-gray-600 hover:bg-gray-700 text-white',
      'success': 'bg-green-600 hover:bg-green-700 text-white',
      'danger': 'bg-red-600 hover:bg-red-700 text-white',
      'warning': 'bg-yellow-500 hover:bg-yellow-600 text-black',
      'outline': 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50',
      'ghost': 'text-blue-600 hover:bg-blue-50'
    };
    const sizes = {
      'sm': 'px-3 py-1 text-sm',
      'md': 'px-4 py-2',
      'lg': 'px-6 py-3 text-lg'
    };
    const cls = variants[this.variant] + ' ' + sizes[this.size] +
      ' rounded-lg font-semibold transition-colors shadow-md ' +
      (this.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer');

    const btn = document.createElement('button');
    btn.id = 'btn-' + this.id;
    btn.className = cls;
    if (this.disabled) btn.disabled = true;
    btn.innerHTML = (this.icon ? this.icon + ' ' : '') + this.text;

    const self = this;
    btn.onclick = function() {
      WV2Bridge.sendEvent('onClick', self.id, {});
    };

    const temp = document.createElement('div');
    temp.appendChild(btn);
    return temp.innerHTML;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container inline-block';

    const btn = document.createElement('button');
    btn.id = 'btn-' + this.id;

    const variants = {
      'primary': 'bg-blue-600 hover:bg-blue-700 text-white',
      'secondary': 'bg-gray-600 hover:bg-gray-700 text-white',
      'success': 'bg-green-600 hover:bg-green-700 text-white',
      'danger': 'bg-red-600 hover:bg-red-700 text-white',
      'warning': 'bg-yellow-500 hover:bg-yellow-600 text-black',
      'outline': 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50',
      'ghost': 'text-blue-600 hover:bg-blue-50'
    };
    const sizes = {
      'sm': 'px-3 py-1 text-sm',
      'md': 'px-4 py-2',
      'lg': 'px-6 py-3 text-lg'
    };

    btn.className = variants[this.variant] + ' ' + sizes[this.size] +
      ' rounded-lg font-semibold transition-colors shadow-md ' +
      (this.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer');

    if (this.disabled) btn.disabled = true;
    btn.innerHTML = (this.icon ? this.icon + ' ' : '') + this.text;

    const self = this;
    btn.onclick = function() {
      WV2Bridge.sendEvent('onClick', self.id, {});
    };

    c.appendChild(btn);
    return c;
  }
}
