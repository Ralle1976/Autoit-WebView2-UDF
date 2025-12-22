/**
 * WV2React - All UI Components
 * Automatisch generierte kombinierte Datei
 * Wird von AutoIt geladen
 */

// ============================================================================
// PHASE 1: BASIS-EINGABE
// ============================================================================

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
  getState() { return { text: this.text, disabled: this.disabled }; }
  rerender() {
    const el = document.getElementById('btn-' + this.id);
    if (el) { const newEl = this.createButton(); el.parentNode.replaceChild(newEl, el); }
  }
  createButton() {
    const variants = {
      'primary': 'bg-blue-600 hover:bg-blue-700 text-white',
      'secondary': 'bg-gray-600 hover:bg-gray-700 text-white',
      'success': 'bg-green-600 hover:bg-green-700 text-white',
      'danger': 'bg-red-600 hover:bg-red-700 text-white',
      'warning': 'bg-yellow-500 hover:bg-yellow-600 text-black',
      'outline': 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50',
      'ghost': 'text-blue-600 hover:bg-blue-50'
    };
    const sizes = { 'sm': 'px-3 py-1 text-sm', 'md': 'px-4 py-2', 'lg': 'px-6 py-3 text-lg' };
    const btn = document.createElement('button');
    btn.id = 'btn-' + this.id;
    btn.className = variants[this.variant] + ' ' + sizes[this.size] + ' rounded-lg font-semibold transition-colors shadow-md ' + (this.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer');
    if (this.disabled) btn.disabled = true;
    btn.innerHTML = (this.icon ? this.icon + ' ' : '') + this.text;
    const self = this;
    btn.onclick = function() { WV2Bridge.sendEvent('onClick', self.id, {}); };
    return btn;
  }
  render() {
    const c = document.createElement('div');
    c.className = 'component-container inline-block';
    c.appendChild(this.createButton());
    return c;
  }
}

// WV2Input - Eingabefeld
class WV2Input {
  constructor(id, o) {
    this.id = id; this.type = o.type || 'text'; this.placeholder = o.placeholder || '';
    this.label = o.label || ''; this.value = o.value || ''; this.disabled = o.disabled || false;
    this.required = o.required || false;
  }
  update(p) {
    if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('input-' + this.id); if (el) el.value = p.value; }
    if (p.disabled !== undefined) this.disabled = p.disabled;
  }
  getState() { const el = document.getElementById('input-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) {
      const lbl = document.createElement('label');
      lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1';
      lbl.textContent = this.label;
      if (this.required) { const sp = document.createElement('span'); sp.className = 'text-red-500'; sp.textContent = '*'; lbl.appendChild(sp); }
      c.appendChild(lbl);
    }
    const inp = document.createElement('input');
    inp.type = this.type; inp.id = 'input-' + this.id; inp.value = this.value; inp.placeholder = this.placeholder;
    inp.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent';
    if (this.disabled) inp.disabled = true;
    const self = this;
    inp.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    inp.oninput = function() { WV2Bridge.sendEvent('onInput', self.id, { value: this.value }); };
    c.appendChild(inp);
    return c;
  }
}

// WV2Textarea - Mehrzeiliges Textfeld
class WV2Textarea {
  constructor(id, o) {
    this.id = id; this.placeholder = o.placeholder || ''; this.label = o.label || '';
    this.value = o.value || ''; this.rows = o.rows || 4; this.disabled = o.disabled || false;
  }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('ta-' + this.id); if (el) el.value = p.value; } }
  getState() { const el = document.getElementById('ta-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const ta = document.createElement('textarea');
    ta.id = 'ta-' + this.id; ta.rows = this.rows; ta.placeholder = this.placeholder; ta.value = this.value;
    ta.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';
    if (this.disabled) ta.disabled = true;
    const self = this; ta.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    c.appendChild(ta);
    return c;
  }
}

// WV2Checkbox
class WV2Checkbox {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.checked = o.checked || false; this.disabled = o.disabled || false; }
  update(p) { if (p.checked !== undefined) { this.checked = p.checked; const el = document.getElementById('cb-' + this.id); if (el) el.checked = p.checked; } }
  getState() { const el = document.getElementById('cb-' + this.id); return { checked: el ? el.checked : this.checked }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-2';
    const lbl = document.createElement('label'); lbl.className = 'flex items-center gap-2 cursor-pointer';
    const inp = document.createElement('input'); inp.type = 'checkbox'; inp.id = 'cb-' + this.id; inp.checked = this.checked; inp.disabled = this.disabled;
    inp.className = 'w-5 h-5 text-blue-600 rounded focus:ring-blue-500';
    const self = this; inp.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { checked: this.checked }); };
    const span = document.createElement('span'); span.className = 'text-gray-700 dark:text-gray-300'; span.textContent = this.label;
    lbl.appendChild(inp); lbl.appendChild(span); c.appendChild(lbl);
    return c;
  }
}

// WV2Radio
class WV2Radio {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.options = o.options || []; this.value = o.value || ''; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) this.value = p.value; }
  getState() { const el = document.querySelector('input[name="radio-' + this.id + '"]:checked'); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lblDiv = document.createElement('div'); lblDiv.className = 'text-sm font-medium text-gray-700 dark:text-gray-300 mb-2'; lblDiv.textContent = this.label; c.appendChild(lblDiv); }
    const self = this;
    this.options.forEach(opt => {
      const lbl = document.createElement('label'); lbl.className = 'flex items-center gap-2 mb-1 cursor-pointer';
      const inp = document.createElement('input'); inp.type = 'radio'; inp.name = 'radio-' + this.id; inp.value = opt.value;
      inp.checked = (this.value === opt.value); inp.className = 'w-4 h-4 text-blue-600';
      inp.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
      const span = document.createElement('span'); span.className = 'text-gray-700 dark:text-gray-300'; span.textContent = opt.label;
      lbl.appendChild(inp); lbl.appendChild(span); c.appendChild(lbl);
    });
    return c;
  }
}

// WV2Switch
class WV2Switch {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.checked = o.checked || false; this.disabled = o.disabled || false; }
  update(p) { if (p.checked !== undefined) { this.checked = p.checked; this.rerender(); } }
  getState() { return { checked: this.checked }; }
  rerender() { const el = document.getElementById('sw-container-' + this.id); if (el) { const newEl = this.render(); el.parentNode.replaceChild(newEl, el); } }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-2'; c.id = 'sw-container-' + this.id;
    const lbl = document.createElement('label'); lbl.className = 'flex items-center gap-3 cursor-pointer';
    const wrapper = document.createElement('div'); wrapper.className = 'relative';
    const inp = document.createElement('input'); inp.type = 'checkbox'; inp.id = 'sw-' + this.id; inp.className = 'sr-only peer'; inp.checked = this.checked;
    const self = this; inp.onchange = function() { self.checked = this.checked; WV2Bridge.sendEvent('onChange', self.id, { checked: this.checked }); };
    const track = document.createElement('div'); track.className = 'w-11 h-6 bg-gray-300 peer-checked:bg-blue-600 rounded-full transition-colors';
    const thumb = document.createElement('div'); thumb.className = 'absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition-transform peer-checked:translate-x-5';
    wrapper.appendChild(inp); wrapper.appendChild(track); wrapper.appendChild(thumb);
    const span = document.createElement('span'); span.className = 'text-gray-700 dark:text-gray-300'; span.textContent = this.label;
    lbl.appendChild(wrapper); lbl.appendChild(span); c.appendChild(lbl);
    return c;
  }
}

// WV2Select
class WV2Select {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.options = o.options || []; this.value = o.value || ''; this.placeholder = o.placeholder || ''; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('sel-' + this.id); if (el) el.value = p.value; } }
  getState() { const el = document.getElementById('sel-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const sel = document.createElement('select'); sel.id = 'sel-' + this.id;
    sel.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';
    sel.disabled = this.disabled;
    if (this.placeholder) { const opt = document.createElement('option'); opt.value = ''; opt.textContent = this.placeholder; sel.appendChild(opt); }
    this.options.forEach(o => { const opt = document.createElement('option'); opt.value = o.value; opt.textContent = o.label; if (this.value === o.value) opt.selected = true; sel.appendChild(opt); });
    const self = this; sel.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    c.appendChild(sel);
    return c;
  }
}

// ============================================================================
// PHASE 2: ERWEITERTE EINGABE
// ============================================================================

// WV2DatePicker
class WV2DatePicker {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.value = o.value || ''; this.min = o.min || ''; this.max = o.max || ''; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('dp-' + this.id); if (el) el.value = p.value; } }
  getState() { const el = document.getElementById('dp-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const inp = document.createElement('input'); inp.type = 'date'; inp.id = 'dp-' + this.id; inp.value = this.value;
    if (this.min) inp.min = this.min; if (this.max) inp.max = this.max;
    inp.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';
    inp.disabled = this.disabled;
    const self = this; inp.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    c.appendChild(inp);
    return c;
  }
}

// WV2TimePicker
class WV2TimePicker {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.value = o.value || ''; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('tp-' + this.id); if (el) el.value = p.value; } }
  getState() { const el = document.getElementById('tp-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const inp = document.createElement('input'); inp.type = 'time'; inp.id = 'tp-' + this.id; inp.value = this.value;
    inp.className = 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500';
    inp.disabled = this.disabled;
    const self = this; inp.onchange = function() { WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    c.appendChild(inp);
    return c;
  }
}

// WV2ColorPicker
class WV2ColorPicker {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.value = o.value || '#3B82F6'; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('cp-' + this.id); if (el) el.value = p.value; const v = document.getElementById('cpv-' + this.id); if (v) v.textContent = p.value; } }
  getState() { const el = document.getElementById('cp-' + this.id); return { value: el ? el.value : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const wrapper = document.createElement('div'); wrapper.className = 'flex items-center gap-2';
    const inp = document.createElement('input'); inp.type = 'color'; inp.id = 'cp-' + this.id; inp.value = this.value;
    inp.className = 'w-12 h-10 rounded cursor-pointer'; inp.disabled = this.disabled;
    const valSpan = document.createElement('span'); valSpan.id = 'cpv-' + this.id; valSpan.className = 'text-gray-600 dark:text-gray-400 font-mono'; valSpan.textContent = this.value;
    const self = this; inp.onchange = function() { valSpan.textContent = this.value; WV2Bridge.sendEvent('onChange', self.id, { value: this.value }); };
    wrapper.appendChild(inp); wrapper.appendChild(valSpan); c.appendChild(wrapper);
    return c;
  }
}

// WV2Slider
class WV2Slider {
  constructor(id, o) { this.id = id; this.label = o.label || ''; this.value = o.value || 50; this.min = o.min || 0; this.max = o.max || 100; this.step = o.step || 1; this.disabled = o.disabled || false; }
  update(p) { if (p.value !== undefined) { this.value = p.value; const el = document.getElementById('sl-' + this.id); if (el) el.value = p.value; const v = document.getElementById('slv-' + this.id); if (v) v.textContent = p.value; } }
  getState() { const el = document.getElementById('sl-' + this.id); return { value: el ? Number(el.value) : this.value }; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    if (this.label) { const lbl = document.createElement('label'); lbl.className = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'; lbl.textContent = this.label; c.appendChild(lbl); }
    const wrapper = document.createElement('div'); wrapper.className = 'flex items-center gap-3';
    const inp = document.createElement('input'); inp.type = 'range'; inp.id = 'sl-' + this.id; inp.value = this.value;
    inp.min = this.min; inp.max = this.max; inp.step = this.step;
    inp.className = 'flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer'; inp.disabled = this.disabled;
    const valSpan = document.createElement('span'); valSpan.id = 'slv-' + this.id; valSpan.className = 'w-12 text-center text-gray-700 dark:text-gray-300 font-mono'; valSpan.textContent = this.value;
    const self = this; inp.oninput = function() { valSpan.textContent = this.value; WV2Bridge.sendEvent('onChange', self.id, { value: Number(this.value) }); };
    wrapper.appendChild(inp); wrapper.appendChild(valSpan); c.appendChild(wrapper);
    return c;
  }
}

// WV2FileUpload
class WV2FileUpload {
  constructor(id, o) { this.id = id; this.label = o.label || 'Datei auswaehlen'; this.accept = o.accept || '*'; this.multiple = o.multiple || false; this.disabled = o.disabled || false; }
  update(p) { }
  getState() { return {}; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container mb-4';
    const lbl = document.createElement('label');
    lbl.className = 'flex flex-col items-center px-4 py-6 bg-white dark:bg-gray-700 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-600';
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('class', 'w-8 h-8 text-gray-400'); svg.setAttribute('fill', 'none'); svg.setAttribute('stroke', 'currentColor'); svg.setAttribute('viewBox', '0 0 24 24');
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('stroke-linecap', 'round'); path.setAttribute('stroke-linejoin', 'round'); path.setAttribute('stroke-width', '2');
    path.setAttribute('d', 'M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12');
    svg.appendChild(path);
    const span = document.createElement('span'); span.className = 'mt-2 text-sm text-gray-600 dark:text-gray-300'; span.textContent = this.label;
    const inp = document.createElement('input'); inp.type = 'file'; inp.id = 'fu-' + this.id; inp.accept = this.accept; inp.multiple = this.multiple; inp.className = 'hidden';
    const self = this; inp.onchange = function() { const files = Array.from(this.files).map(f => ({ name: f.name, size: f.size, type: f.type })); WV2Bridge.sendEvent('onFileSelect', self.id, { files: files }); };
    lbl.appendChild(svg); lbl.appendChild(span); lbl.appendChild(inp); c.appendChild(lbl);
    return c;
  }
}

// ============================================================================
// PHASE 3: NAVIGATION
// ============================================================================

// WV2Tabs
class WV2Tabs {
  constructor(id, o) { this.id = id; this.tabs = o.tabs || []; this.active = o.active || (this.tabs.length > 0 ? this.tabs[0].id : ''); }
  update(p) { if (p.active !== undefined) { this.active = p.active; this.rerender(); } }
  getState() { return { active: this.active }; }
  rerender() { const el = document.getElementById('tabs-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'tabs-' + this.id; container.className = 'w-full';
    const tabBar = document.createElement('div'); tabBar.className = 'flex border-b border-gray-200 dark:border-gray-700';
    const self = this;
    this.tabs.forEach(t => {
      const btn = document.createElement('button');
      btn.className = 'px-4 py-2 font-medium ' + (this.active === t.id ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500 hover:text-gray-700');
      btn.textContent = t.label;
      btn.onclick = function() { self.active = t.id; self.rerender(); WV2Bridge.sendEvent('onTabChange', self.id, { active: t.id }); };
      tabBar.appendChild(btn);
    });
    const content = document.createElement('div'); content.className = 'p-4';
    const activeTab = this.tabs.find(t => t.id === this.active);
    if (activeTab) content.innerHTML = activeTab.content;
    container.appendChild(tabBar); container.appendChild(content);
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container'; c.appendChild(this.createInner()); return c; }
}

// WV2Breadcrumb
class WV2Breadcrumb {
  constructor(id, o) { this.id = id; this.items = o.items || []; }
  update(p) { if (p.items) this.items = p.items; }
  getState() { return { items: this.items }; }
  render() {
    const c = document.createElement('nav'); c.className = 'component-container mb-4';
    const ol = document.createElement('ol'); ol.className = 'flex items-center space-x-2';
    this.items.forEach((item, i) => {
      if (i > 0) { const sep = document.createElement('li'); sep.className = 'text-gray-400'; sep.textContent = '/'; ol.appendChild(sep); }
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.className = (i === this.items.length - 1) ? 'text-gray-600 dark:text-gray-300' : 'text-blue-600 hover:underline';
      if (item.href) a.href = item.href; a.textContent = item.label;
      li.appendChild(a); ol.appendChild(li);
    });
    c.appendChild(ol);
    return c;
  }
}

// WV2Pagination
class WV2Pagination {
  constructor(id, o) { this.id = id; this.total = o.total || 0; this.perPage = o.perPage || 10; this.current = o.current || 1; }
  update(p) { if (p.current !== undefined) this.current = p.current; if (p.total !== undefined) this.total = p.total; this.rerender(); }
  getState() { return { current: this.current, total: this.total, perPage: this.perPage }; }
  rerender() { const el = document.getElementById('pg-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const pages = Math.ceil(this.total / this.perPage);
    const container = document.createElement('div'); container.id = 'pg-' + this.id; container.className = 'flex items-center gap-1';
    const self = this;
    const prevBtn = document.createElement('button');
    prevBtn.className = 'px-3 py-1 rounded ' + (this.current <= 1 ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50');
    prevBtn.disabled = this.current <= 1; prevBtn.textContent = 'Prev';
    prevBtn.onclick = function() { if (self.current > 1) { self.current--; self.rerender(); WV2Bridge.sendEvent('onPageChange', self.id, { page: self.current }); } };
    container.appendChild(prevBtn);
    for (let i = 1; i <= pages; i++) {
      const btn = document.createElement('button');
      btn.className = 'px-3 py-1 rounded ' + (i === this.current ? 'bg-blue-600 text-white' : 'text-gray-700 hover:bg-gray-100');
      btn.textContent = i;
      (function(page) { btn.onclick = function() { self.current = page; self.rerender(); WV2Bridge.sendEvent('onPageChange', self.id, { page: page }); }; })(i);
      container.appendChild(btn);
    }
    const nextBtn = document.createElement('button');
    nextBtn.className = 'px-3 py-1 rounded ' + (this.current >= pages ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50');
    nextBtn.disabled = this.current >= pages; nextBtn.textContent = 'Next';
    nextBtn.onclick = function() { if (self.current < pages) { self.current++; self.rerender(); WV2Bridge.sendEvent('onPageChange', self.id, { page: self.current }); } };
    container.appendChild(nextBtn);
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container'; c.appendChild(this.createInner()); return c; }
}

// WV2Stepper
class WV2Stepper {
  constructor(id, o) { this.id = id; this.steps = o.steps || []; this.active = o.active || 0; }
  update(p) { if (p.active !== undefined) { this.active = p.active; this.rerender(); } }
  getState() { return { active: this.active }; }
  rerender() { const el = document.getElementById('step-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'step-' + this.id; container.className = 'flex items-center';
    this.steps.forEach((s, i) => {
      const done = i < this.active; const curr = i === this.active;
      if (i > 0) { const line = document.createElement('div'); line.className = 'flex-1 h-0.5 ' + (done ? 'bg-blue-600' : 'bg-gray-300'); container.appendChild(line); }
      const stepDiv = document.createElement('div'); stepDiv.className = 'flex flex-col items-center';
      const circle = document.createElement('div');
      circle.className = 'w-8 h-8 rounded-full flex items-center justify-center ' + (done ? 'bg-blue-600 text-white' : curr ? 'border-2 border-blue-600 text-blue-600' : 'bg-gray-300 text-gray-600');
      circle.innerHTML = done ? '&#10003;' : (i + 1);
      const label = document.createElement('div'); label.className = 'mt-1 text-xs ' + (curr ? 'text-blue-600 font-medium' : 'text-gray-500'); label.textContent = s.title;
      stepDiv.appendChild(circle); stepDiv.appendChild(label); container.appendChild(stepDiv);
    });
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container mb-6'; c.appendChild(this.createInner()); return c; }
}

// ============================================================================
// PHASE 4: STRUKTUR
// ============================================================================

// WV2TreeView
class WV2TreeView {
  constructor(id, o) { this.id = id; this.nodes = o.nodes || []; this.expandedIds = o.expandedIds || []; this.selectedId = o.selectedId || ''; }
  update(p) { if (p.nodes) this.nodes = p.nodes; this.rerender(); }
  getState() { return { selectedId: this.selectedId, expandedIds: this.expandedIds }; }
  rerender() { const el = document.getElementById('tree-' + this.id); if (el) { el.innerHTML = ''; el.appendChild(this.renderNodes(this.nodes, 0)); } }
  renderNodes(nodes, level) {
    const ul = document.createElement('ul'); ul.className = (level > 0 ? 'ml-4 ' : '') + 'list-none';
    const self = this;
    nodes.forEach(n => {
      const hasChildren = n.children && n.children.length > 0;
      const expanded = this.expandedIds.includes(n.id); const selected = this.selectedId === n.id;
      const li = document.createElement('li'); li.className = 'py-1';
      const row = document.createElement('div');
      row.className = 'flex items-center gap-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 rounded px-2 py-1 ' + (selected ? 'bg-blue-100 dark:bg-blue-900' : '');
      row.onclick = function(e) { self.selectedId = n.id; self.rerender(); WV2Bridge.sendEvent('onSelect', self.id, { id: n.id }); };
      const toggle = document.createElement('span');
      if (hasChildren) { toggle.innerHTML = expanded ? '&#9660;' : '&#9654;'; toggle.onclick = function(e) { e.stopPropagation(); const idx = self.expandedIds.indexOf(n.id); if (idx > -1) self.expandedIds.splice(idx, 1); else self.expandedIds.push(n.id); self.rerender(); }; }
      else { toggle.className = 'w-4'; }
      const label = document.createElement('span'); label.textContent = n.label;
      row.appendChild(toggle); row.appendChild(label); li.appendChild(row);
      if (hasChildren && expanded) li.appendChild(this.renderNodes(n.children, level + 1));
      ul.appendChild(li);
    });
    return ul;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container'; c.id = 'tree-' + this.id; c.appendChild(this.renderNodes(this.nodes, 0)); return c; }
}

// WV2Accordion
class WV2Accordion {
  constructor(id, o) { this.id = id; this.items = o.items || []; this.multiple = o.multiple || false; this.openIds = o.openIds || []; }
  update(p) { if (p.openIds) this.openIds = p.openIds; this.rerender(); }
  getState() { return { openIds: this.openIds }; }
  rerender() { const el = document.getElementById('acc-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'acc-' + this.id;
    container.className = 'border border-gray-200 dark:border-gray-700 rounded-lg divide-y divide-gray-200 dark:divide-gray-700';
    const self = this;
    this.items.forEach(item => {
      const open = this.openIds.includes(item.id);
      const itemDiv = document.createElement('div');
      const btn = document.createElement('button');
      btn.className = 'w-full px-4 py-3 text-left font-medium flex justify-between items-center hover:bg-gray-50 dark:hover:bg-gray-700';
      btn.onclick = function() { const idx = self.openIds.indexOf(item.id); if (idx > -1) self.openIds.splice(idx, 1); else { if (!self.multiple) self.openIds = []; self.openIds.push(item.id); } self.rerender(); };
      const title = document.createTextNode(item.title);
      const icon = document.createElement('span'); icon.innerHTML = open ? '&#9650;' : '&#9660;';
      btn.appendChild(title); btn.appendChild(icon); itemDiv.appendChild(btn);
      if (open) { const content = document.createElement('div'); content.className = 'px-4 py-3 text-gray-600 dark:text-gray-300'; content.innerHTML = item.content; itemDiv.appendChild(content); }
      container.appendChild(itemDiv);
    });
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container'; c.appendChild(this.createInner()); return c; }
}

// ============================================================================
// PHASE 5: FEEDBACK
// ============================================================================

// WV2Modal
class WV2Modal {
  constructor(id, o) { this.id = id; this.title = o.title || ''; this.content = o.content || ''; this.showClose = o.showClose !== false; this.open = o.open || false; }
  update(p) { if (p.open !== undefined) this.open = p.open; if (p.title !== undefined) this.title = p.title; if (p.content !== undefined) this.content = p.content; this.rerender(); }
  getState() { return { open: this.open }; }
  rerender() { const el = document.getElementById('modal-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  close() { this.open = false; this.rerender(); WV2Bridge.sendEvent('onClose', this.id, {}); }
  createInner() {
    const container = document.createElement('div'); container.id = 'modal-' + this.id;
    if (!this.open) return container;
    container.className = 'fixed inset-0 z-50 flex items-center justify-center';
    const self = this;
    const backdrop = document.createElement('div'); backdrop.className = 'absolute inset-0 bg-black/50'; backdrop.onclick = function() { self.close(); };
    const modal = document.createElement('div'); modal.className = 'relative bg-white dark:bg-gray-800 rounded-xl shadow-2xl max-w-lg w-full mx-4 max-h-[90vh] overflow-auto';
    const header = document.createElement('div'); header.className = 'flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700';
    const title = document.createElement('h3'); title.className = 'text-lg font-semibold text-gray-800 dark:text-white'; title.textContent = this.title; header.appendChild(title);
    if (this.showClose) { const closeBtn = document.createElement('button'); closeBtn.className = 'text-gray-400 hover:text-gray-600'; closeBtn.innerHTML = '&#10005;'; closeBtn.onclick = function() { self.close(); }; header.appendChild(closeBtn); }
    const content = document.createElement('div'); content.className = 'p-4 text-gray-600 dark:text-gray-300'; content.innerHTML = this.content;
    modal.appendChild(header); modal.appendChild(content); container.appendChild(backdrop); container.appendChild(modal);
    return container;
  }
  render() { const c = document.createElement('div'); c.appendChild(this.createInner()); return c; }
}

// WV2Toast
class WV2Toast {
  constructor(id, o) {
    this.id = id; this.message = o.message || ''; this.type = o.type || 'info'; this.duration = o.duration || 3000;
    const self = this; setTimeout(function() { self.remove(); }, this.duration);
  }
  update(p) { }
  getState() { return {}; }
  remove() { const el = document.getElementById('toast-' + this.id); if (el) el.remove(); WV2Bridge.components.delete(this.id); }
  render() {
    const colors = { 'success': 'bg-green-500', 'error': 'bg-red-500', 'warning': 'bg-yellow-500', 'info': 'bg-blue-500' };
    const icons = { 'success': '&#10003;', 'error': '&#10007;', 'warning': '&#9888;', 'info': '&#8505;' };
    const c = document.createElement('div'); c.id = 'toast-' + this.id; c.className = 'fixed top-4 right-4 z-50 animate-pulse';
    const inner = document.createElement('div'); inner.className = colors[this.type] + ' text-white px-4 py-3 rounded-lg shadow-lg flex items-center gap-2';
    const iconSpan = document.createElement('span'); iconSpan.innerHTML = icons[this.type];
    const msgSpan = document.createElement('span'); msgSpan.textContent = this.message;
    inner.appendChild(iconSpan); inner.appendChild(msgSpan); c.appendChild(inner);
    return c;
  }
}

// WV2Alert
class WV2Alert {
  constructor(id, o) { this.id = id; this.message = o.message || ''; this.type = o.type || 'info'; this.title = o.title || ''; this.dismissable = o.dismissable !== false; this.visible = o.visible !== false; }
  update(p) { if (p.visible !== undefined) this.visible = p.visible; this.rerender(); }
  getState() { return { visible: this.visible }; }
  rerender() { const el = document.getElementById('alert-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'alert-' + this.id;
    if (!this.visible) return container;
    const colors = { 'success': 'bg-green-100 border-green-500 text-green-700', 'error': 'bg-red-100 border-red-500 text-red-700', 'warning': 'bg-yellow-100 border-yellow-500 text-yellow-700', 'info': 'bg-blue-100 border-blue-500 text-blue-700' };
    container.className = colors[this.type] + ' border-l-4 p-4 rounded-r-lg flex justify-between items-start';
    const content = document.createElement('div');
    if (this.title) { const strong = document.createElement('strong'); strong.textContent = this.title; const p = document.createElement('p'); p.textContent = this.message; content.appendChild(strong); content.appendChild(p); }
    else { const p = document.createElement('p'); p.textContent = this.message; content.appendChild(p); }
    container.appendChild(content);
    if (this.dismissable) { const self = this; const closeBtn = document.createElement('button'); closeBtn.className = 'text-gray-500 hover:text-gray-700'; closeBtn.innerHTML = '&#10005;'; closeBtn.onclick = function() { self.visible = false; self.rerender(); }; container.appendChild(closeBtn); }
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container mb-4'; c.appendChild(this.createInner()); return c; }
}

// WV2Progress
class WV2Progress {
  constructor(id, o) { this.id = id; this.value = o.value || 0; this.label = o.label || ''; this.color = o.color || ''; this.showValue = o.showValue !== false; }
  update(p) { if (p.value !== undefined) this.value = p.value; if (p.label !== undefined) this.label = p.label; this.rerender(); }
  getState() { return { value: this.value }; }
  rerender() { const el = document.getElementById('prog-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'prog-' + this.id;
    const header = document.createElement('div'); header.className = 'flex justify-between mb-1';
    const label = document.createElement('span'); label.className = 'text-sm font-medium text-gray-700 dark:text-gray-300'; label.textContent = this.label; header.appendChild(label);
    if (this.showValue) { const value = document.createElement('span'); value.className = 'text-sm font-medium text-gray-700 dark:text-gray-300'; value.textContent = this.value + '%'; header.appendChild(value); }
    const track = document.createElement('div'); track.className = 'w-full bg-gray-200 rounded-full h-2.5 dark:bg-gray-700';
    const bar = document.createElement('div'); bar.className = (this.color || 'bg-blue-600') + ' h-2.5 rounded-full transition-all'; bar.style.width = this.value + '%';
    track.appendChild(bar); container.appendChild(header); container.appendChild(track);
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container mb-4'; c.appendChild(this.createInner()); return c; }
}

// WV2Spinner
class WV2Spinner {
  constructor(id, o) { this.id = id; this.size = o.size || 'md'; this.color = o.color || ''; }
  update(p) { }
  getState() { return {}; }
  render() {
    const sizes = { 'sm': 'w-4 h-4', 'md': 'w-8 h-8', 'lg': 'w-12 h-12' };
    const c = document.createElement('div'); c.className = 'component-container flex justify-center';
    const spinner = document.createElement('div'); spinner.className = sizes[this.size] + ' border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin';
    c.appendChild(spinner);
    return c;
  }
}

// ============================================================================
// PHASE 6: DATEN
// ============================================================================

// WV2Chart
class WV2Chart {
  constructor(id, o) { this.id = id; this.type = o.type || 'bar'; this.data = o.data || {}; this.options = o.options || {}; this.chart = null; }
  update(p) { if (p.data && this.chart) { this.chart.data = p.data; this.chart.update(); } }
  getState() { return { type: this.type }; }
  initChart(canvas) { if (typeof Chart === 'undefined') { console.warn('Chart.js not loaded'); return; } this.chart = new Chart(canvas, { type: this.type, data: this.data, options: this.options }); }
  render() {
    const c = document.createElement('div'); c.className = 'component-container';
    const canvas = document.createElement('canvas'); canvas.id = 'chart-' + this.id;
    c.appendChild(canvas);
    const self = this; setTimeout(function() { self.initChart(canvas); }, 100);
    return c;
  }
}

// WV2Badge
class WV2Badge {
  constructor(id, o) { this.id = id; this.text = o.text || ''; this.variant = o.variant || 'primary'; }
  update(p) { if (p.text !== undefined) { this.text = p.text; this.rerender(); } }
  getState() { return { text: this.text }; }
  rerender() { const el = document.getElementById('badge-' + this.id); if (el) el.textContent = this.text; }
  render() {
    const colors = { 'primary': 'bg-blue-100 text-blue-800', 'secondary': 'bg-gray-100 text-gray-800', 'success': 'bg-green-100 text-green-800', 'danger': 'bg-red-100 text-red-800', 'warning': 'bg-yellow-100 text-yellow-800' };
    const c = document.createElement('span'); c.id = 'badge-' + this.id;
    c.className = colors[this.variant] + ' text-xs font-medium px-2.5 py-0.5 rounded-full'; c.textContent = this.text;
    return c;
  }
}

// WV2Avatar
class WV2Avatar {
  constructor(id, o) { this.id = id; this.src = o.src || ''; this.name = o.name || ''; this.size = o.size || 'md'; }
  update(p) { if (p.src) this.src = p.src; }
  getState() { return {}; }
  render() {
    const sizes = { 'sm': 'w-8 h-8 text-xs', 'md': 'w-12 h-12 text-sm', 'lg': 'w-16 h-16 text-lg' };
    const c = document.createElement('div'); c.className = 'component-container inline-block';
    if (this.src) { const img = document.createElement('img'); img.src = this.src; img.className = sizes[this.size] + ' rounded-full object-cover'; c.appendChild(img); }
    else { const initials = this.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2); const div = document.createElement('div'); div.className = sizes[this.size] + ' rounded-full bg-blue-600 text-white flex items-center justify-center font-medium'; div.textContent = initials; c.appendChild(div); }
    return c;
  }
}

// WV2Tag
class WV2Tag {
  constructor(id, o) { this.id = id; this.text = o.text || ''; this.color = o.color || ''; this.removable = o.removable || false; }
  update(p) { if (p.text) this.text = p.text; }
  getState() { return { text: this.text }; }
  render() {
    const c = document.createElement('span'); c.className = 'inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm ' + (this.color ? '' : 'bg-gray-200 text-gray-800');
    if (this.color) c.style.backgroundColor = this.color;
    const text = document.createTextNode(this.text); c.appendChild(text);
    if (this.removable) { const self = this; const btn = document.createElement('button'); btn.className = 'ml-1 hover:text-red-600'; btn.innerHTML = '&#10005;'; btn.onclick = function() { WV2Bridge.sendEvent('onRemove', self.id, {}); }; c.appendChild(btn); }
    return c;
  }
}

// ============================================================================
// PHASE 7: LAYOUT
// ============================================================================

// WV2Divider
class WV2Divider {
  constructor(id, o) { this.id = id; this.text = o.text || ''; this.orientation = o.orientation || 'horizontal'; }
  update(p) { }
  getState() { return {}; }
  render() {
    const c = document.createElement('div'); c.className = 'component-container my-4';
    if (this.text) {
      const wrapper = document.createElement('div'); wrapper.className = 'flex items-center';
      const line1 = document.createElement('div'); line1.className = 'flex-1 border-t border-gray-300';
      const textSpan = document.createElement('span'); textSpan.className = 'px-3 text-gray-500 text-sm'; textSpan.textContent = this.text;
      const line2 = document.createElement('div'); line2.className = 'flex-1 border-t border-gray-300';
      wrapper.appendChild(line1); wrapper.appendChild(textSpan); wrapper.appendChild(line2); c.appendChild(wrapper);
    } else { const hr = document.createElement('hr'); hr.className = 'border-gray-300'; c.appendChild(hr); }
    return c;
  }
}

// WV2StatCard
class WV2StatCard {
  constructor(id, o) { this.id = id; this.title = o.title || ''; this.value = o.value || ''; this.icon = o.icon || ''; this.change = o.change || ''; this.positive = o.positive !== false; }
  update(p) { if (p.value !== undefined) this.value = p.value; if (p.change !== undefined) this.change = p.change; this.rerender(); }
  getState() { return { value: this.value, change: this.change }; }
  rerender() { const el = document.getElementById('stat-' + this.id); if (el) { const newEl = this.createInner(); el.parentNode.replaceChild(newEl, el); } }
  createInner() {
    const container = document.createElement('div'); container.id = 'stat-' + this.id;
    container.className = 'bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6';
    const row = document.createElement('div'); row.className = 'flex items-center justify-between';
    const left = document.createElement('div');
    const title = document.createElement('p'); title.className = 'text-sm font-medium text-gray-500 dark:text-gray-400'; title.textContent = this.title;
    const value = document.createElement('p'); value.className = 'text-2xl font-bold text-gray-800 dark:text-white mt-1'; value.textContent = this.value;
    left.appendChild(title); left.appendChild(value);
    if (this.change) { const change = document.createElement('p'); change.className = 'text-sm mt-1 ' + (this.positive ? 'text-green-600' : 'text-red-600'); change.innerHTML = (this.positive ? '&#9650;' : '&#9660;') + ' ' + this.change; left.appendChild(change); }
    row.appendChild(left);
    if (this.icon) { const iconDiv = document.createElement('div'); iconDiv.className = 'text-4xl text-blue-500'; iconDiv.innerHTML = this.icon; row.appendChild(iconDiv); }
    container.appendChild(row);
    return container;
  }
  render() { const c = document.createElement('div'); c.className = 'component-container'; c.appendChild(this.createInner()); return c; }
}

// ============================================================================
// COMPONENT REGISTRY - Registriert alle Komponenten fuer WV2Bridge
// ============================================================================
const WV2Components = {
  // Phase 1
  'button': WV2Button,
  'input': WV2Input,
  'textarea': WV2Textarea,
  'checkbox': WV2Checkbox,
  'radio': WV2Radio,
  'switch': WV2Switch,
  'select': WV2Select,
  // Phase 2
  'datepicker': WV2DatePicker,
  'timepicker': WV2TimePicker,
  'colorpicker': WV2ColorPicker,
  'slider': WV2Slider,
  'fileupload': WV2FileUpload,
  // Phase 3
  'tabs': WV2Tabs,
  'breadcrumb': WV2Breadcrumb,
  'pagination': WV2Pagination,
  'stepper': WV2Stepper,
  // Phase 4
  'treeview': WV2TreeView,
  'accordion': WV2Accordion,
  // Phase 5
  'modal': WV2Modal,
  'toast': WV2Toast,
  'alert': WV2Alert,
  'progress': WV2Progress,
  'spinner': WV2Spinner,
  // Phase 6
  'chart': WV2Chart,
  'badge': WV2Badge,
  'avatar': WV2Avatar,
  'tag': WV2Tag,
  // Phase 7
  'divider': WV2Divider,
  'statcard': WV2StatCard
};

console.log('WV2React UI Components loaded - ' + Object.keys(WV2Components).length + ' components available');
