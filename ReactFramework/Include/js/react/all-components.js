/**
 * WV2React - React UI Components
 * React 18 Version mit React.createElement()
 * Kein JSX, kein Build-System erforderlich
 */

// ============================================================================
// REACT COMPONENT FACTORY
// Wrapper-Klassen fuer AutoIt-Kompatibilitaet (gleiche API wie DOM-Version)
// ============================================================================

// WV2Button - Button Komponente (React)
class WV2Button {
  constructor(id, o) {
    this.id = id;
    this.props = { text: o.text || '', variant: o.variant || 'primary', size: o.size || 'md', icon: o.icon || '', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    this._render();
  }
  getState() { return { text: this.props.text, disabled: this.props.disabled }; }
  _render() {
    if (!this.container) return;
    var variants = {
      'primary': 'bg-blue-600 hover:bg-blue-700 text-white',
      'secondary': 'bg-gray-600 hover:bg-gray-700 text-white',
      'success': 'bg-green-600 hover:bg-green-700 text-white',
      'danger': 'bg-red-600 hover:bg-red-700 text-white',
      'warning': 'bg-yellow-500 hover:bg-yellow-600 text-black',
      'outline': 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50',
      'ghost': 'text-blue-600 hover:bg-blue-50'
    };
    var sizes = { 'sm': 'px-3 py-1 text-sm', 'md': 'px-4 py-2', 'lg': 'px-6 py-3 text-lg' };
    var self = this;
    var element = React.createElement('button', {
      id: 'btn-' + this.id,
      className: variants[this.props.variant] + ' ' + sizes[this.props.size] + ' rounded-lg font-semibold transition-colors shadow-md ' + (this.props.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'),
      disabled: this.props.disabled,
      onClick: function() { WV2Bridge.sendEvent('onClick', self.id, {}); }
    }, (this.props.icon ? this.props.icon + ' ' : '') + this.props.text);
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container inline-block';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Input - Eingabefeld (React)
class WV2Input {
  constructor(id, o) {
    this.id = id;
    this.props = { type: o.type || 'text', placeholder: o.placeholder || '', label: o.label || '', value: o.value || '', disabled: o.disabled || false, required: o.required || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('input-' + this.id);
    if (el && p.value !== undefined) el.value = p.value;
  }
  getState() { var el = document.getElementById('input-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', {
        key: 'label',
        className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'
      }, this.props.label, this.props.required ? React.createElement('span', { className: 'text-red-500' }, '*') : null));
    }
    children.push(React.createElement('input', {
      key: 'input',
      id: 'input-' + this.id,
      type: this.props.type,
      defaultValue: this.props.value,
      placeholder: this.props.placeholder,
      disabled: this.props.disabled,
      className: 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent',
      onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value }); },
      onInput: function(e) { WV2Bridge.sendEvent('onInput', self.id, { value: e.target.value }); }
    }));
    ReactDOM.render(React.createElement('div', { className: 'w-full' }, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Textarea - Mehrzeiliges Textfeld (React)
class WV2Textarea {
  constructor(id, o) {
    this.id = id;
    this.props = { placeholder: o.placeholder || '', label: o.label || '', value: o.value || '', rows: o.rows || 4, disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('ta-' + this.id);
    if (el && p.value !== undefined) el.value = p.value;
  }
  getState() { var el = document.getElementById('ta-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    children.push(React.createElement('textarea', {
      key: 'textarea',
      id: 'ta-' + this.id,
      rows: this.props.rows,
      placeholder: this.props.placeholder,
      defaultValue: this.props.value,
      disabled: this.props.disabled,
      className: 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500',
      onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value }); }
    }));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Checkbox (React)
class WV2Checkbox {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', checked: o.checked || false, disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('cb-' + this.id);
    if (el && p.checked !== undefined) el.checked = p.checked;
  }
  getState() { var el = document.getElementById('cb-' + this.id); return { checked: el ? el.checked : this.props.checked }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var element = React.createElement('label', { className: 'flex items-center gap-2 cursor-pointer' },
      React.createElement('input', {
        id: 'cb-' + this.id,
        type: 'checkbox',
        defaultChecked: this.props.checked,
        disabled: this.props.disabled,
        className: 'w-5 h-5 text-blue-600 rounded focus:ring-blue-500',
        onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { checked: e.target.checked }); }
      }),
      React.createElement('span', { className: 'text-gray-700 dark:text-gray-300' }, this.props.label)
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-2';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Radio (React)
class WV2Radio {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', options: o.options || [], value: o.value || '', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { var el = document.querySelector('input[name="radio-' + this.id + '"]:checked'); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('div', { key: 'label', className: 'text-sm font-medium text-gray-700 dark:text-gray-300 mb-2' }, this.props.label));
    }
    this.props.options.forEach(function(opt, i) {
      children.push(React.createElement('label', { key: i, className: 'flex items-center gap-2 mb-1 cursor-pointer' },
        React.createElement('input', {
          type: 'radio',
          name: 'radio-' + self.id,
          value: opt.value,
          defaultChecked: self.props.value === opt.value,
          className: 'w-4 h-4 text-blue-600',
          onChange: function() { WV2Bridge.sendEvent('onChange', self.id, { value: opt.value }); }
        }),
        React.createElement('span', { className: 'text-gray-700 dark:text-gray-300' }, opt.label)
      ));
    });
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Switch (React)
class WV2Switch {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', checked: o.checked || false, disabled: o.disabled || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { checked: this.props.checked }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var element = React.createElement('label', { className: 'flex items-center gap-3 cursor-pointer' },
      React.createElement('div', { className: 'relative' },
        React.createElement('input', {
          id: 'sw-' + this.id,
          type: 'checkbox',
          className: 'sr-only peer',
          defaultChecked: this.props.checked,
          onChange: function(e) { self.props.checked = e.target.checked; WV2Bridge.sendEvent('onChange', self.id, { checked: e.target.checked }); }
        }),
        React.createElement('div', { className: 'w-11 h-6 bg-gray-300 peer-checked:bg-blue-600 rounded-full transition-colors' }),
        React.createElement('div', { className: 'absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition-transform peer-checked:translate-x-5' })
      ),
      React.createElement('span', { className: 'text-gray-700 dark:text-gray-300' }, this.props.label)
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-2';
    c.id = 'sw-container-' + this.id;
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Select (React)
class WV2Select {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', options: o.options || [], value: o.value || '', placeholder: o.placeholder || '', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('sel-' + this.id);
    if (el && p.value !== undefined) el.value = p.value;
  }
  getState() { var el = document.getElementById('sel-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    var optionElements = [];
    if (this.props.placeholder) {
      optionElements.push(React.createElement('option', { key: 'placeholder', value: '' }, this.props.placeholder));
    }
    this.props.options.forEach(function(o, i) {
      optionElements.push(React.createElement('option', { key: i, value: o.value }, o.label));
    });
    children.push(React.createElement('select', {
      key: 'select',
      id: 'sel-' + this.id,
      defaultValue: this.props.value,
      disabled: this.props.disabled,
      className: 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500',
      onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value }); }
    }, optionElements));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// PHASE 2: ERWEITERTE EINGABE
// ============================================================================

// WV2DatePicker (React)
class WV2DatePicker {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', value: o.value || '', min: o.min || '', max: o.max || '', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); var el = document.getElementById('dp-' + this.id); if (el && p.value !== undefined) el.value = p.value; }
  getState() { var el = document.getElementById('dp-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    children.push(React.createElement('input', {
      key: 'input',
      id: 'dp-' + this.id,
      type: 'date',
      defaultValue: this.props.value,
      min: this.props.min || undefined,
      max: this.props.max || undefined,
      disabled: this.props.disabled,
      className: 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500',
      onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value }); }
    }));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2TimePicker (React)
class WV2TimePicker {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', value: o.value || '', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); var el = document.getElementById('tp-' + this.id); if (el && p.value !== undefined) el.value = p.value; }
  getState() { var el = document.getElementById('tp-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    children.push(React.createElement('input', {
      key: 'input',
      id: 'tp-' + this.id,
      type: 'time',
      defaultValue: this.props.value,
      disabled: this.props.disabled,
      className: 'w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-white focus:ring-2 focus:ring-blue-500',
      onChange: function(e) { WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value }); }
    }));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2ColorPicker (React)
class WV2ColorPicker {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', value: o.value || '#3B82F6', disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('cp-' + this.id);
    if (el && p.value !== undefined) el.value = p.value;
    var v = document.getElementById('cpv-' + this.id);
    if (v && p.value !== undefined) v.textContent = p.value;
  }
  getState() { var el = document.getElementById('cp-' + this.id); return { value: el ? el.value : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    children.push(React.createElement('div', { key: 'wrapper', className: 'flex items-center gap-2' },
      React.createElement('input', {
        id: 'cp-' + this.id,
        type: 'color',
        defaultValue: this.props.value,
        disabled: this.props.disabled,
        className: 'w-12 h-10 rounded cursor-pointer',
        onChange: function(e) {
          var v = document.getElementById('cpv-' + self.id);
          if (v) v.textContent = e.target.value;
          WV2Bridge.sendEvent('onChange', self.id, { value: e.target.value });
        }
      }),
      React.createElement('span', { id: 'cpv-' + this.id, className: 'text-gray-600 dark:text-gray-400 font-mono' }, this.props.value)
    ));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Slider (React)
class WV2Slider {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || '', value: o.value || 50, min: o.min || 0, max: o.max || 100, step: o.step || 1, disabled: o.disabled || false };
    this.container = null;
  }
  update(p) {
    Object.assign(this.props, p);
    var el = document.getElementById('sl-' + this.id);
    if (el && p.value !== undefined) el.value = p.value;
    var v = document.getElementById('slv-' + this.id);
    if (v && p.value !== undefined) v.textContent = p.value;
  }
  getState() { var el = document.getElementById('sl-' + this.id); return { value: el ? Number(el.value) : this.props.value }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var children = [];
    if (this.props.label) {
      children.push(React.createElement('label', { key: 'label', className: 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1' }, this.props.label));
    }
    children.push(React.createElement('div', { key: 'wrapper', className: 'flex items-center gap-3' },
      React.createElement('input', {
        id: 'sl-' + this.id,
        type: 'range',
        defaultValue: this.props.value,
        min: this.props.min,
        max: this.props.max,
        step: this.props.step,
        disabled: this.props.disabled,
        className: 'flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer',
        onInput: function(e) {
          var v = document.getElementById('slv-' + self.id);
          if (v) v.textContent = e.target.value;
          WV2Bridge.sendEvent('onChange', self.id, { value: Number(e.target.value) });
        }
      }),
      React.createElement('span', { id: 'slv-' + this.id, className: 'w-12 text-center text-gray-700 dark:text-gray-300 font-mono' }, this.props.value)
    ));
    ReactDOM.render(React.createElement('div', null, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2FileUpload (React)
class WV2FileUpload {
  constructor(id, o) {
    this.id = id;
    this.props = { label: o.label || 'Datei auswaehlen', accept: o.accept || '*', multiple: o.multiple || false, disabled: o.disabled || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); }
  getState() { return {}; }
  _render() {
    if (!this.container) return;
    var self = this;
    var element = React.createElement('label', {
      className: 'flex flex-col items-center px-4 py-6 bg-white dark:bg-gray-700 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-600'
    },
      React.createElement('svg', {
        className: 'w-8 h-8 text-gray-400',
        fill: 'none',
        stroke: 'currentColor',
        viewBox: '0 0 24 24'
      },
        React.createElement('path', {
          strokeLinecap: 'round',
          strokeLinejoin: 'round',
          strokeWidth: '2',
          d: 'M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12'
        })
      ),
      React.createElement('span', { className: 'mt-2 text-sm text-gray-600 dark:text-gray-300' }, this.props.label),
      React.createElement('input', {
        id: 'fu-' + this.id,
        type: 'file',
        accept: this.props.accept,
        multiple: this.props.multiple,
        className: 'hidden',
        onChange: function(e) {
          var files = Array.from(e.target.files).map(function(f) { return { name: f.name, size: f.size, type: f.type }; });
          WV2Bridge.sendEvent('onFileSelect', self.id, { files: files });
        }
      })
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// PHASE 3: NAVIGATION
// ============================================================================

// WV2Tabs (React)
class WV2Tabs {
  constructor(id, o) {
    this.id = id;
    this.props = { tabs: o.tabs || [], active: o.active || (o.tabs && o.tabs.length > 0 ? o.tabs[0].id : '') };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { active: this.props.active }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var tabButtons = this.props.tabs.map(function(t) {
      return React.createElement('button', {
        key: t.id,
        className: 'px-4 py-2 font-medium ' + (self.props.active === t.id ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500 hover:text-gray-700'),
        onClick: function() { self.props.active = t.id; self._render(); WV2Bridge.sendEvent('onTabChange', self.id, { active: t.id }); }
      }, t.label);
    });
    var activeTab = this.props.tabs.find(function(t) { return t.id === self.props.active; });
    var element = React.createElement('div', { id: 'tabs-' + this.id, className: 'w-full' },
      React.createElement('div', { className: 'flex border-b border-gray-200 dark:border-gray-700' }, tabButtons),
      React.createElement('div', { className: 'p-4', dangerouslySetInnerHTML: { __html: activeTab ? activeTab.content : '' } })
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Breadcrumb (React)
class WV2Breadcrumb {
  constructor(id, o) {
    this.id = id;
    this.props = { items: o.items || [] };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { items: this.props.items }; }
  _render() {
    if (!this.container) return;
    var listItems = [];
    var self = this;
    this.props.items.forEach(function(item, i) {
      if (i > 0) {
        listItems.push(React.createElement('li', { key: 'sep-' + i, className: 'text-gray-400' }, '/'));
      }
      listItems.push(React.createElement('li', { key: i },
        React.createElement('a', {
          className: i === self.props.items.length - 1 ? 'text-gray-600 dark:text-gray-300' : 'text-blue-600 hover:underline',
          href: item.href || '#'
        }, item.label)
      ));
    });
    var element = React.createElement('nav', { className: 'mb-4' },
      React.createElement('ol', { className: 'flex items-center space-x-2' }, listItems)
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Pagination (React)
class WV2Pagination {
  constructor(id, o) {
    this.id = id;
    this.props = { total: o.total || 0, perPage: o.perPage || 10, current: o.current || 1 };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { current: this.props.current, total: this.props.total, perPage: this.props.perPage }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var pages = Math.ceil(this.props.total / this.props.perPage);
    var buttons = [];
    buttons.push(React.createElement('button', {
      key: 'prev',
      className: 'px-3 py-1 rounded ' + (this.props.current === 1 ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50'),
      disabled: this.props.current === 1,
      onClick: function() { if (self.props.current > 1) { self.props.current--; self._render(); WV2Bridge.sendEvent('onPageChange', self.id, { page: self.props.current }); } }
    }, '\u2190'));
    for (var i = 1; i <= pages; i++) {
      (function(page) {
        buttons.push(React.createElement('button', {
          key: page,
          className: 'px-3 py-1 rounded ' + (self.props.current === page ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'),
          onClick: function() { self.props.current = page; self._render(); WV2Bridge.sendEvent('onPageChange', self.id, { page: page }); }
        }, page));
      })(i);
    }
    buttons.push(React.createElement('button', {
      key: 'next',
      className: 'px-3 py-1 rounded ' + (this.props.current >= pages ? 'text-gray-400' : 'text-blue-600 hover:bg-blue-50'),
      disabled: this.props.current >= pages,
      onClick: function() { if (self.props.current < pages) { self.props.current++; self._render(); WV2Bridge.sendEvent('onPageChange', self.id, { page: self.props.current }); } }
    }, '\u2192'));
    ReactDOM.render(React.createElement('div', { id: 'pg-' + this.id, className: 'flex items-center gap-1' }, buttons), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Stepper (React)
class WV2Stepper {
  constructor(id, o) {
    this.id = id;
    this.props = { steps: o.steps || [], current: o.current || 0 };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { current: this.props.current }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var stepElements = this.props.steps.map(function(s, i) {
      var isActive = i === self.props.current;
      var isComplete = i < self.props.current;
      return React.createElement('div', { key: i, className: 'flex items-center' },
        React.createElement('div', {
          className: 'w-8 h-8 rounded-full flex items-center justify-center font-bold ' +
            (isComplete ? 'bg-green-600 text-white' : isActive ? 'bg-blue-600 text-white' : 'bg-gray-300 text-gray-600')
        }, isComplete ? '\u2713' : i + 1),
        React.createElement('span', { className: 'ml-2 mr-4 ' + (isActive ? 'font-semibold text-blue-600' : 'text-gray-600') }, s.label),
        i < self.props.steps.length - 1 ? React.createElement('div', { className: 'flex-1 h-1 mx-2 ' + (isComplete ? 'bg-green-600' : 'bg-gray-300') }) : null
      );
    });
    ReactDOM.render(React.createElement('div', { id: 'stepper-' + this.id, className: 'flex items-center' }, stepElements), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// PHASE 4: FEEDBACK
// ============================================================================

// WV2Alert (React)
class WV2Alert {
  constructor(id, o) {
    this.id = id;
    this.props = { type: o.type || 'info', message: o.message || '', title: o.title || '', dismissible: o.dismissible || false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { type: this.props.type, message: this.props.message }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var types = {
      'info': { bg: 'bg-blue-100 dark:bg-blue-900', border: 'border-blue-500', text: 'text-blue-700 dark:text-blue-300', icon: '\u2139' },
      'success': { bg: 'bg-green-100 dark:bg-green-900', border: 'border-green-500', text: 'text-green-700 dark:text-green-300', icon: '\u2713' },
      'warning': { bg: 'bg-yellow-100 dark:bg-yellow-900', border: 'border-yellow-500', text: 'text-yellow-700 dark:text-yellow-300', icon: '\u26A0' },
      'error': { bg: 'bg-red-100 dark:bg-red-900', border: 'border-red-500', text: 'text-red-700 dark:text-red-300', icon: '\u2717' }
    };
    var t = types[this.props.type] || types.info;
    var children = [
      React.createElement('span', { key: 'icon', className: 'text-xl mr-3' }, t.icon),
      React.createElement('div', { key: 'content', className: 'flex-1' },
        this.props.title ? React.createElement('strong', { className: 'block' }, this.props.title) : null,
        this.props.message
      )
    ];
    if (this.props.dismissible) {
      children.push(React.createElement('button', {
        key: 'close',
        className: 'ml-3 hover:opacity-70',
        onClick: function() { self.container.remove(); WV2Bridge.sendEvent('onDismiss', self.id, {}); }
      }, '\u00D7'));
    }
    ReactDOM.render(React.createElement('div', {
      id: 'alert-' + this.id,
      className: t.bg + ' ' + t.text + ' border-l-4 ' + t.border + ' p-4 rounded-r-lg flex items-start'
    }, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Progress (React)
class WV2Progress {
  constructor(id, o) {
    this.id = id;
    this.props = { value: o.value || 0, max: o.max || 100, label: o.label || '', showValue: o.showValue !== false };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { value: this.props.value, max: this.props.max }; }
  _render() {
    if (!this.container) return;
    var percent = Math.min(100, Math.max(0, (this.props.value / this.props.max) * 100));
    var children = [];
    if (this.props.label || this.props.showValue) {
      children.push(React.createElement('div', { key: 'header', className: 'flex justify-between mb-1 text-sm text-gray-600 dark:text-gray-400' },
        React.createElement('span', null, this.props.label),
        this.props.showValue ? React.createElement('span', null, Math.round(percent) + '%') : null
      ));
    }
    children.push(React.createElement('div', { key: 'bar', className: 'w-full h-4 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden' },
      React.createElement('div', {
        className: 'h-full bg-blue-600 transition-all duration-300',
        style: { width: percent + '%' }
      })
    ));
    ReactDOM.render(React.createElement('div', { id: 'progress-' + this.id }, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container mb-4';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Spinner (React)
class WV2Spinner {
  constructor(id, o) {
    this.id = id;
    this.props = { size: o.size || 'md', color: o.color || 'blue' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return {}; }
  _render() {
    if (!this.container) return;
    var sizes = { 'sm': 'w-4 h-4', 'md': 'w-8 h-8', 'lg': 'w-12 h-12' };
    ReactDOM.render(React.createElement('div', {
      id: 'spinner-' + this.id,
      className: sizes[this.props.size] + ' border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin'
    }), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container inline-block';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Toast (React)
class WV2Toast {
  constructor(id, o) {
    this.id = id;
    this.props = { message: o.message || '', type: o.type || 'info', duration: o.duration || 3000 };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return {}; }
  _render() {
    if (!this.container) return;
    var self = this;
    var types = {
      'info': 'bg-blue-600',
      'success': 'bg-green-600',
      'warning': 'bg-yellow-500',
      'error': 'bg-red-600'
    };
    ReactDOM.render(React.createElement('div', {
      id: 'toast-' + this.id,
      className: types[this.props.type] + ' text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-3 animate-slide-in'
    },
      React.createElement('span', null, this.props.message),
      React.createElement('button', {
        className: 'hover:opacity-70',
        onClick: function() { self.remove(); }
      }, '\u00D7')
    ), this.container);
    if (this.props.duration > 0) {
      setTimeout(function() { self.remove(); }, this.props.duration);
    }
  }
  remove() {
    if (this.container) this.container.remove();
    WV2Bridge.components.delete(this.id);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container fixed top-4 right-4 z-50';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Modal (React)
class WV2Modal {
  constructor(id, o) {
    this.id = id;
    this.props = { title: o.title || '', content: o.content || '', open: o.open !== false, size: o.size || 'md' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { open: this.props.open }; }
  close() { this.props.open = false; this._render(); WV2Bridge.sendEvent('onClose', this.id, {}); }
  _render() {
    if (!this.container) return;
    var self = this;
    if (!this.props.open) {
      ReactDOM.render(null, this.container);
      return;
    }
    var sizes = { 'sm': 'max-w-sm', 'md': 'max-w-md', 'lg': 'max-w-lg', 'xl': 'max-w-xl' };
    var element = React.createElement('div', {
      id: 'modal-' + this.id,
      className: 'fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50',
      onClick: function(e) { if (e.target.id === 'modal-' + self.id) self.close(); }
    },
      React.createElement('div', {
        className: 'bg-white dark:bg-gray-800 rounded-lg shadow-xl ' + sizes[this.props.size] + ' w-full mx-4'
      },
        React.createElement('div', { className: 'flex justify-between items-center p-4 border-b border-gray-200 dark:border-gray-700' },
          React.createElement('h3', { className: 'text-lg font-semibold text-gray-800 dark:text-white' }, this.props.title),
          React.createElement('button', {
            className: 'text-gray-400 hover:text-gray-600',
            onClick: function() { self.close(); }
          }, '\u00D7')
        ),
        React.createElement('div', {
          className: 'p-4 text-gray-600 dark:text-gray-300',
          dangerouslySetInnerHTML: { __html: this.props.content }
        })
      )
    );
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// PHASE 5: ANZEIGE
// ============================================================================

// WV2Badge (React)
class WV2Badge {
  constructor(id, o) {
    this.id = id;
    this.props = { text: o.text || '', variant: o.variant || 'primary' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { text: this.props.text }; }
  _render() {
    if (!this.container) return;
    var variants = {
      'primary': 'bg-blue-100 text-blue-800',
      'secondary': 'bg-gray-100 text-gray-800',
      'success': 'bg-green-100 text-green-800',
      'danger': 'bg-red-100 text-red-800',
      'warning': 'bg-yellow-100 text-yellow-800'
    };
    ReactDOM.render(React.createElement('span', {
      id: 'badge-' + this.id,
      className: variants[this.props.variant] + ' px-2 py-1 rounded-full text-xs font-semibold'
    }, this.props.text), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container inline-block';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Avatar (React)
class WV2Avatar {
  constructor(id, o) {
    this.id = id;
    this.props = { src: o.src || '', initials: o.initials || '', size: o.size || 'md' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return {}; }
  _render() {
    if (!this.container) return;
    var sizes = { 'sm': 'w-8 h-8 text-sm', 'md': 'w-12 h-12 text-lg', 'lg': 'w-16 h-16 text-xl' };
    var element;
    if (this.props.src) {
      element = React.createElement('img', {
        id: 'avatar-' + this.id,
        src: this.props.src,
        className: sizes[this.props.size] + ' rounded-full object-cover'
      });
    } else {
      element = React.createElement('div', {
        id: 'avatar-' + this.id,
        className: sizes[this.props.size] + ' rounded-full bg-blue-600 text-white flex items-center justify-center font-semibold'
      }, this.props.initials);
    }
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container inline-block';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Tag (React)
class WV2Tag {
  constructor(id, o) {
    this.id = id;
    this.props = { text: o.text || '', removable: o.removable || false, color: o.color || 'blue' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { text: this.props.text }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var colors = {
      'blue': 'bg-blue-100 text-blue-800',
      'green': 'bg-green-100 text-green-800',
      'red': 'bg-red-100 text-red-800',
      'yellow': 'bg-yellow-100 text-yellow-800',
      'gray': 'bg-gray-100 text-gray-800'
    };
    var children = [React.createElement('span', { key: 'text' }, this.props.text)];
    if (this.props.removable) {
      children.push(React.createElement('button', {
        key: 'remove',
        className: 'ml-1 hover:text-red-600',
        onClick: function() { WV2Bridge.sendEvent('onRemove', self.id, {}); }
      }, '\u00D7'));
    }
    ReactDOM.render(React.createElement('span', {
      id: 'tag-' + this.id,
      className: colors[this.props.color] + ' px-3 py-1 rounded-full text-sm inline-flex items-center'
    }, children), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container inline-block';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Divider (React)
class WV2Divider {
  constructor(id, o) {
    this.id = id;
    this.props = { text: o.text || '' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return {}; }
  _render() {
    if (!this.container) return;
    var element;
    if (this.props.text) {
      element = React.createElement('div', { className: 'flex items-center my-4' },
        React.createElement('div', { className: 'flex-1 h-px bg-gray-300 dark:bg-gray-600' }),
        React.createElement('span', { className: 'px-3 text-gray-500 text-sm' }, this.props.text),
        React.createElement('div', { className: 'flex-1 h-px bg-gray-300 dark:bg-gray-600' })
      );
    } else {
      element = React.createElement('hr', { className: 'my-4 border-gray-300 dark:border-gray-600' });
    }
    ReactDOM.render(element, this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2StatCard (React)
class WV2StatCard {
  constructor(id, o) {
    this.id = id;
    this.props = { title: o.title || '', value: o.value || '0', change: o.change || null, icon: o.icon || '' };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { value: this.props.value }; }
  _render() {
    if (!this.container) return;
    var changeEl = null;
    if (this.props.change !== null) {
      var isPositive = this.props.change >= 0;
      changeEl = React.createElement('span', {
        className: 'text-sm ' + (isPositive ? 'text-green-600' : 'text-red-600')
      }, (isPositive ? '\u2191' : '\u2193') + ' ' + Math.abs(this.props.change) + '%');
    }
    ReactDOM.render(React.createElement('div', {
      id: 'stat-' + this.id,
      className: 'bg-white dark:bg-gray-800 rounded-lg p-4 shadow-md'
    },
      React.createElement('div', { className: 'flex justify-between items-start' },
        React.createElement('div', null,
          React.createElement('p', { className: 'text-sm text-gray-500 dark:text-gray-400' }, this.props.title),
          React.createElement('p', { className: 'text-2xl font-bold text-gray-800 dark:text-white' }, this.props.value),
          changeEl
        ),
        this.props.icon ? React.createElement('div', { className: 'text-3xl' }, this.props.icon) : null
      )
    ), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// WV2Accordion (React)
class WV2Accordion {
  constructor(id, o) {
    this.id = id;
    this.props = { items: o.items || [], openIndex: o.openIndex !== undefined ? o.openIndex : -1 };
    this.container = null;
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { openIndex: this.props.openIndex }; }
  _render() {
    if (!this.container) return;
    var self = this;
    var items = this.props.items.map(function(item, i) {
      var isOpen = self.props.openIndex === i;
      return React.createElement('div', { key: i, className: 'border-b border-gray-200 dark:border-gray-700' },
        React.createElement('button', {
          className: 'w-full flex justify-between items-center py-3 text-left font-medium text-gray-700 dark:text-gray-300',
          onClick: function() { self.props.openIndex = isOpen ? -1 : i; self._render(); WV2Bridge.sendEvent('onToggle', self.id, { index: self.props.openIndex }); }
        },
          item.title,
          React.createElement('span', { className: 'transform transition-transform ' + (isOpen ? 'rotate-180' : '') }, '\u25BC')
        ),
        isOpen ? React.createElement('div', { className: 'pb-3 text-gray-600 dark:text-gray-400' }, item.content) : null
      );
    });
    ReactDOM.render(React.createElement('div', { id: 'accordion-' + this.id, className: 'divide-y divide-gray-200 dark:divide-gray-700' }, items), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// PHASE 6: SPEZIAL (Komplexe Komponenten)
// ============================================================================

// WV2TreeView (React)
class WV2TreeView {
  constructor(id, o) {
    this.id = id;
    this.props = { nodes: o.nodes || [], selectedId: o.selectedId || null };
    this.container = null;
    this.expandedNodes = new Set();
  }
  update(p) { Object.assign(this.props, p); this._render(); }
  getState() { return { selectedId: this.props.selectedId }; }
  _renderNode(node, level) {
    var self = this;
    var hasChildren = node.children && node.children.length > 0;
    var isExpanded = this.expandedNodes.has(node.id);
    var isSelected = this.props.selectedId === node.id;
    var childrenElements = hasChildren && isExpanded ? node.children.map(function(child) { return self._renderNode(child, level + 1); }) : null;
    return React.createElement('div', { key: node.id, style: { marginLeft: level * 16 + 'px' } },
      React.createElement('div', {
        className: 'flex items-center py-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 rounded ' + (isSelected ? 'bg-blue-100 dark:bg-blue-900' : ''),
        onClick: function() {
          if (hasChildren) {
            if (isExpanded) self.expandedNodes.delete(node.id);
            else self.expandedNodes.add(node.id);
          }
          self.props.selectedId = node.id;
          self._render();
          WV2Bridge.sendEvent('onSelect', self.id, { id: node.id });
        }
      },
        hasChildren ? React.createElement('span', { className: 'mr-1 text-gray-400' }, isExpanded ? '\u25BC' : '\u25B6') : React.createElement('span', { className: 'mr-1 w-3' }),
        React.createElement('span', { className: 'text-gray-700 dark:text-gray-300' }, node.label)
      ),
      childrenElements
    );
  }
  _render() {
    if (!this.container) return;
    var self = this;
    var elements = this.props.nodes.map(function(node) { return self._renderNode(node, 0); });
    ReactDOM.render(React.createElement('div', { id: 'tree-' + this.id, className: 'p-2' }, elements), this.container);
  }
  render() {
    var c = document.createElement('div');
    c.className = 'component-container';
    this.container = c;
    this._render();
    return c;
  }
}

// ============================================================================
// COMPONENT REGISTRY - Registriert alle Komponenten fuer WV2Bridge
// ============================================================================

var WV2Components = {
  // Phase 1: Basis
  'button': WV2Button,
  'input': WV2Input,
  'textarea': WV2Textarea,
  'checkbox': WV2Checkbox,
  'radio': WV2Radio,
  'switch': WV2Switch,
  'select': WV2Select,
  // Phase 2: Erweitert
  'datepicker': WV2DatePicker,
  'timepicker': WV2TimePicker,
  'colorpicker': WV2ColorPicker,
  'slider': WV2Slider,
  'fileupload': WV2FileUpload,
  // Phase 3: Navigation
  'tabs': WV2Tabs,
  'breadcrumb': WV2Breadcrumb,
  'pagination': WV2Pagination,
  'stepper': WV2Stepper,
  // Phase 4: Feedback
  'alert': WV2Alert,
  'progress': WV2Progress,
  'spinner': WV2Spinner,
  'toast': WV2Toast,
  'modal': WV2Modal,
  // Phase 5: Anzeige
  'badge': WV2Badge,
  'avatar': WV2Avatar,
  'tag': WV2Tag,
  'divider': WV2Divider,
  'statcard': WV2StatCard,
  'accordion': WV2Accordion,
  // Phase 6: Spezial
  'treeview': WV2TreeView
};

console.log('WV2React UI Components (React Mode) loaded - ' + Object.keys(WV2Components).length + ' components available');
