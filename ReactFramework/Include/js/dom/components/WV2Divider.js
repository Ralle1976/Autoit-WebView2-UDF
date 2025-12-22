// WV2Divider - Trennlinie Komponente
class WV2Divider {
  constructor(id, o) {
    this.id = id;
    this.text = o.text || '';
    this.orientation = o.orientation || 'horizontal';
  }

  update(p) { }

  getState() {
    return {};
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container my-4';

    if (this.text) {
      const wrapper = document.createElement('div');
      wrapper.className = 'flex items-center';

      const line1 = document.createElement('div');
      line1.className = 'flex-1 border-t border-gray-300';

      const textSpan = document.createElement('span');
      textSpan.className = 'px-3 text-gray-500 text-sm';
      textSpan.textContent = this.text;

      const line2 = document.createElement('div');
      line2.className = 'flex-1 border-t border-gray-300';

      wrapper.appendChild(line1);
      wrapper.appendChild(textSpan);
      wrapper.appendChild(line2);
      c.appendChild(wrapper);
    } else {
      const hr = document.createElement('hr');
      hr.className = 'border-gray-300';
      c.appendChild(hr);
    }

    return c;
  }
}
