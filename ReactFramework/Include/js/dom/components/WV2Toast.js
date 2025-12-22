// WV2Toast - Toast Benachrichtigung Komponente
class WV2Toast {
  constructor(id, o) {
    this.id = id;
    this.message = o.message || '';
    this.type = o.type || 'info';
    this.duration = o.duration || 3000;

    // Auto-Remove nach duration
    const self = this;
    setTimeout(function() { self.remove(); }, this.duration);
  }

  update(p) { }

  getState() {
    return {};
  }

  remove() {
    const el = document.getElementById('toast-' + this.id);
    if (el) el.remove();
    WV2Bridge.components.delete(this.id);
  }

  render() {
    const colors = {
      'success': 'bg-green-500',
      'error': 'bg-red-500',
      'warning': 'bg-yellow-500',
      'info': 'bg-blue-500'
    };
    const icons = {
      'success': '&#10003;',
      'error': '&#10007;',
      'warning': '&#9888;',
      'info': '&#8505;'
    };

    const c = document.createElement('div');
    c.id = 'toast-' + this.id;
    c.className = 'fixed top-4 right-4 z-50 animate-pulse';

    const inner = document.createElement('div');
    inner.className = colors[this.type] + ' text-white px-4 py-3 rounded-lg shadow-lg flex items-center gap-2';

    const iconSpan = document.createElement('span');
    iconSpan.innerHTML = icons[this.type];

    const msgSpan = document.createElement('span');
    msgSpan.textContent = this.message;

    inner.appendChild(iconSpan);
    inner.appendChild(msgSpan);
    c.appendChild(inner);

    return c;
  }
}
