// WV2StatCard - Statistik-Karte Komponente
class WV2StatCard {
  constructor(id, o) {
    this.id = id;
    this.title = o.title || '';
    this.value = o.value || '';
    this.icon = o.icon || '';
    this.change = o.change || '';
    this.positive = o.positive !== false;
  }

  update(p) {
    if (p.value !== undefined) this.value = p.value;
    if (p.change !== undefined) this.change = p.change;
    this.rerender();
  }

  getState() {
    return { value: this.value, change: this.change };
  }

  rerender() {
    const el = document.getElementById('stat-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'stat-' + this.id;
    container.className = 'bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6';

    const row = document.createElement('div');
    row.className = 'flex items-center justify-between';

    // Left side: text content
    const left = document.createElement('div');

    const title = document.createElement('p');
    title.className = 'text-sm font-medium text-gray-500 dark:text-gray-400';
    title.textContent = this.title;

    const value = document.createElement('p');
    value.className = 'text-2xl font-bold text-gray-800 dark:text-white mt-1';
    value.textContent = this.value;

    left.appendChild(title);
    left.appendChild(value);

    if (this.change) {
      const change = document.createElement('p');
      change.className = 'text-sm mt-1 ' + (this.positive ? 'text-green-600' : 'text-red-600');
      change.innerHTML = (this.positive ? '&#9650;' : '&#9660;') + ' ' + this.change;
      left.appendChild(change);
    }

    row.appendChild(left);

    // Right side: icon
    if (this.icon) {
      const iconDiv = document.createElement('div');
      iconDiv.className = 'text-4xl text-blue-500';
      iconDiv.innerHTML = this.icon;
      row.appendChild(iconDiv);
    }

    container.appendChild(row);
    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';
    c.appendChild(this.createInner());
    return c;
  }
}
