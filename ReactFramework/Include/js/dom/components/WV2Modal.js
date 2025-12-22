// WV2Modal - Dialog/Modal Komponente
class WV2Modal {
  constructor(id, o) {
    this.id = id;
    this.title = o.title || '';
    this.content = o.content || '';
    this.showClose = o.showClose !== false;
    this.open = o.open || false;
  }

  update(p) {
    if (p.open !== undefined) this.open = p.open;
    if (p.title !== undefined) this.title = p.title;
    if (p.content !== undefined) this.content = p.content;
    this.rerender();
  }

  getState() {
    return { open: this.open };
  }

  rerender() {
    const el = document.getElementById('modal-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  close() {
    this.open = false;
    this.rerender();
    WV2Bridge.sendEvent('onClose', this.id, {});
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'modal-' + this.id;

    if (!this.open) return container;

    container.className = 'fixed inset-0 z-50 flex items-center justify-center';

    const self = this;

    // Backdrop
    const backdrop = document.createElement('div');
    backdrop.className = 'absolute inset-0 bg-black/50';
    backdrop.onclick = function() { self.close(); };

    // Modal
    const modal = document.createElement('div');
    modal.className = 'relative bg-white dark:bg-gray-800 rounded-xl shadow-2xl max-w-lg w-full mx-4 max-h-[90vh] overflow-auto';

    // Header
    const header = document.createElement('div');
    header.className = 'flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700';

    const title = document.createElement('h3');
    title.className = 'text-lg font-semibold text-gray-800 dark:text-white';
    title.textContent = this.title;
    header.appendChild(title);

    if (this.showClose) {
      const closeBtn = document.createElement('button');
      closeBtn.className = 'text-gray-400 hover:text-gray-600';
      closeBtn.innerHTML = '&#10005;';
      closeBtn.onclick = function() { self.close(); };
      header.appendChild(closeBtn);
    }

    // Content
    const content = document.createElement('div');
    content.className = 'p-4 text-gray-600 dark:text-gray-300';
    content.innerHTML = this.content;

    modal.appendChild(header);
    modal.appendChild(content);
    container.appendChild(backdrop);
    container.appendChild(modal);

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.appendChild(this.createInner());
    return c;
  }
}
