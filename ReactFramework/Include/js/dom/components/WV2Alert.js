// WV2Alert - Alert/Hinweis Komponente
class WV2Alert {
  constructor(id, o) {
    this.id = id;
    this.message = o.message || '';
    this.type = o.type || 'info';
    this.title = o.title || '';
    this.dismissable = o.dismissable !== false;
    this.visible = o.visible !== false;
  }

  update(p) {
    if (p.visible !== undefined) this.visible = p.visible;
    this.rerender();
  }

  getState() {
    return { visible: this.visible };
  }

  rerender() {
    const el = document.getElementById('alert-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'alert-' + this.id;

    if (!this.visible) return container;

    const colors = {
      'success': 'bg-green-100 border-green-500 text-green-700',
      'error': 'bg-red-100 border-red-500 text-red-700',
      'warning': 'bg-yellow-100 border-yellow-500 text-yellow-700',
      'info': 'bg-blue-100 border-blue-500 text-blue-700'
    };

    container.className = colors[this.type] + ' border-l-4 p-4 rounded-r-lg flex justify-between items-start';

    const content = document.createElement('div');
    if (this.title) {
      const strong = document.createElement('strong');
      strong.textContent = this.title;
      const p = document.createElement('p');
      p.textContent = this.message;
      content.appendChild(strong);
      content.appendChild(p);
    } else {
      const p = document.createElement('p');
      p.textContent = this.message;
      content.appendChild(p);
    }
    container.appendChild(content);

    if (this.dismissable) {
      const self = this;
      const closeBtn = document.createElement('button');
      closeBtn.className = 'text-gray-500 hover:text-gray-700';
      closeBtn.innerHTML = '&#10005;';
      closeBtn.onclick = function() {
        self.visible = false;
        self.rerender();
      };
      container.appendChild(closeBtn);
    }

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';
    c.appendChild(this.createInner());
    return c;
  }
}
