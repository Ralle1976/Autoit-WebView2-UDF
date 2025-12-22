// WV2Progress - Fortschrittsbalken Komponente
class WV2Progress {
  constructor(id, o) {
    this.id = id;
    this.value = o.value || 0;
    this.label = o.label || '';
    this.color = o.color || '';
    this.showValue = o.showValue !== false;
  }

  update(p) {
    if (p.value !== undefined) this.value = p.value;
    if (p.label !== undefined) this.label = p.label;
    this.rerender();
  }

  getState() {
    return { value: this.value };
  }

  rerender() {
    const el = document.getElementById('prog-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'prog-' + this.id;

    const header = document.createElement('div');
    header.className = 'flex justify-between mb-1';

    const label = document.createElement('span');
    label.className = 'text-sm font-medium text-gray-700 dark:text-gray-300';
    label.textContent = this.label;
    header.appendChild(label);

    if (this.showValue) {
      const value = document.createElement('span');
      value.className = 'text-sm font-medium text-gray-700 dark:text-gray-300';
      value.textContent = this.value + '%';
      header.appendChild(value);
    }

    const track = document.createElement('div');
    track.className = 'w-full bg-gray-200 rounded-full h-2.5 dark:bg-gray-700';

    const bar = document.createElement('div');
    bar.className = (this.color || 'bg-blue-600') + ' h-2.5 rounded-full transition-all';
    bar.style.width = this.value + '%';

    track.appendChild(bar);
    container.appendChild(header);
    container.appendChild(track);

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';
    c.appendChild(this.createInner());
    return c;
  }
}
