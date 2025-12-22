// WV2Tag - Tag/Chip Komponente
class WV2Tag {
  constructor(id, o) {
    this.id = id;
    this.text = o.text || '';
    this.color = o.color || '';
    this.removable = o.removable || false;
  }

  update(p) {
    if (p.text) this.text = p.text;
  }

  getState() {
    return { text: this.text };
  }

  render() {
    const c = document.createElement('span');
    c.className = 'inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm ' +
      (this.color ? '' : 'bg-gray-200 text-gray-800');
    if (this.color) c.style.backgroundColor = this.color;

    const text = document.createTextNode(this.text);
    c.appendChild(text);

    if (this.removable) {
      const self = this;
      const btn = document.createElement('button');
      btn.className = 'ml-1 hover:text-red-600';
      btn.innerHTML = '&#10005;';
      btn.onclick = function() {
        WV2Bridge.sendEvent('onRemove', self.id, {});
      };
      c.appendChild(btn);
    }

    return c;
  }
}
