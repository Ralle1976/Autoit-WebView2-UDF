// WV2Breadcrumb - Breadcrumb Navigation
class WV2Breadcrumb {
  constructor(id, o) {
    this.id = id;
    this.items = o.items || [];
  }

  update(p) {
    if (p.items) this.items = p.items;
  }

  getState() {
    return { items: this.items };
  }

  render() {
    const c = document.createElement('nav');
    c.className = 'component-container mb-4';

    const ol = document.createElement('ol');
    ol.className = 'flex items-center space-x-2';

    this.items.forEach((item, i) => {
      if (i > 0) {
        const sep = document.createElement('li');
        sep.className = 'text-gray-400';
        sep.textContent = '/';
        ol.appendChild(sep);
      }

      const li = document.createElement('li');
      const a = document.createElement('a');
      a.className = (i === this.items.length - 1)
        ? 'text-gray-600 dark:text-gray-300'
        : 'text-blue-600 hover:underline';
      if (item.href) a.href = item.href;
      a.textContent = item.label;
      li.appendChild(a);
      ol.appendChild(li);
    });

    c.appendChild(ol);
    return c;
  }
}
