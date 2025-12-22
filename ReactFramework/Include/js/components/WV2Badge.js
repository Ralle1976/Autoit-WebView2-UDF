// WV2Badge - Badge/Label Komponente
class WV2Badge {
  constructor(id, o) {
    this.id = id;
    this.text = o.text || '';
    this.variant = o.variant || 'primary';
  }

  update(p) {
    if (p.text !== undefined) {
      this.text = p.text;
      this.rerender();
    }
  }

  getState() {
    return { text: this.text };
  }

  rerender() {
    const el = document.getElementById('badge-' + this.id);
    if (el) el.textContent = this.text;
  }

  render() {
    const colors = {
      'primary': 'bg-blue-100 text-blue-800',
      'secondary': 'bg-gray-100 text-gray-800',
      'success': 'bg-green-100 text-green-800',
      'danger': 'bg-red-100 text-red-800',
      'warning': 'bg-yellow-100 text-yellow-800'
    };

    const c = document.createElement('span');
    c.id = 'badge-' + this.id;
    c.className = colors[this.variant] + ' text-xs font-medium px-2.5 py-0.5 rounded-full';
    c.textContent = this.text;

    return c;
  }
}
