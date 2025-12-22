// WV2Pagination - Seitennummerierung Komponente
class WV2Pagination {
  constructor(id, o) {
    this.id = id;
    this.total = o.total || 0;
    this.perPage = o.perPage || 10;
    this.current = o.current || 1;
  }

  update(p) {
    if (p.current !== undefined) this.current = p.current;
    if (p.total !== undefined) this.total = p.total;
    this.rerender();
  }

  getState() {
    return { current: this.current, total: this.total, perPage: this.perPage };
  }

  rerender() {
    const el = document.getElementById('pg-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const pages = Math.ceil(this.total / this.perPage);
    const container = document.createElement('div');
    container.id = 'pg-' + this.id;
    container.className = 'flex items-center gap-1';

    const self = this;

    // Prev Button
    const prevBtn = document.createElement('button');
    prevBtn.className = 'px-3 py-1 rounded ' +
      (this.current <= 1 ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50');
    prevBtn.disabled = this.current <= 1;
    prevBtn.textContent = 'Prev';
    prevBtn.onclick = function() {
      if (self.current > 1) {
        self.current--;
        self.rerender();
        WV2Bridge.sendEvent('onPageChange', self.id, { page: self.current });
      }
    };
    container.appendChild(prevBtn);

    // Page Buttons
    for (let i = 1; i <= pages; i++) {
      const btn = document.createElement('button');
      btn.className = 'px-3 py-1 rounded ' +
        (i === this.current ? 'bg-blue-600 text-white' : 'text-gray-700 hover:bg-gray-100');
      btn.textContent = i;
      (function(page) {
        btn.onclick = function() {
          self.current = page;
          self.rerender();
          WV2Bridge.sendEvent('onPageChange', self.id, { page: page });
        };
      })(i);
      container.appendChild(btn);
    }

    // Next Button
    const nextBtn = document.createElement('button');
    nextBtn.className = 'px-3 py-1 rounded ' +
      (this.current >= pages ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50');
    nextBtn.disabled = this.current >= pages;
    nextBtn.textContent = 'Next';
    nextBtn.onclick = function() {
      if (self.current < pages) {
        self.current++;
        self.rerender();
        WV2Bridge.sendEvent('onPageChange', self.id, { page: self.current });
      }
    };
    container.appendChild(nextBtn);

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';
    c.appendChild(this.createInner());
    return c;
  }
}
