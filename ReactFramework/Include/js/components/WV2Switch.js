// WV2Switch - Toggle Switch Komponente
class WV2Switch {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || '';
    this.checked = o.checked || false;
    this.disabled = o.disabled || false;
  }

  update(p) {
    if (p.checked !== undefined) {
      this.checked = p.checked;
      this.rerender();
    }
  }

  getState() {
    return { checked: this.checked };
  }

  rerender() {
    const el = document.getElementById('sw-container-' + this.id);
    if (el) {
      const newEl = this.render();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-2';
    c.id = 'sw-container-' + this.id;

    const lbl = document.createElement('label');
    lbl.className = 'flex items-center gap-3 cursor-pointer';

    const wrapper = document.createElement('div');
    wrapper.className = 'relative';

    const inp = document.createElement('input');
    inp.type = 'checkbox';
    inp.id = 'sw-' + this.id;
    inp.className = 'sr-only peer';
    inp.checked = this.checked;

    const self = this;
    inp.onchange = function() {
      self.checked = this.checked;
      WV2Bridge.sendEvent('onChange', self.id, { checked: this.checked });
    };

    const track = document.createElement('div');
    track.className = 'w-11 h-6 bg-gray-300 peer-checked:bg-blue-600 rounded-full transition-colors';

    const thumb = document.createElement('div');
    thumb.className = 'absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition-transform peer-checked:translate-x-5';

    wrapper.appendChild(inp);
    wrapper.appendChild(track);
    wrapper.appendChild(thumb);

    const span = document.createElement('span');
    span.className = 'text-gray-700 dark:text-gray-300';
    span.textContent = this.label;

    lbl.appendChild(wrapper);
    lbl.appendChild(span);
    c.appendChild(lbl);
    return c;
  }
}
