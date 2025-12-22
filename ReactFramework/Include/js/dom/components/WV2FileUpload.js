// WV2FileUpload - Datei-Upload Komponente
class WV2FileUpload {
  constructor(id, o) {
    this.id = id;
    this.label = o.label || 'Datei auswaehlen';
    this.accept = o.accept || '*';
    this.multiple = o.multiple || false;
    this.disabled = o.disabled || false;
  }

  update(p) { }

  getState() {
    return {};
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-4';

    const lbl = document.createElement('label');
    lbl.className = 'flex flex-col items-center px-4 py-6 bg-white dark:bg-gray-700 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-600';

    // SVG Icon
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('class', 'w-8 h-8 text-gray-400');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke', 'currentColor');
    svg.setAttribute('viewBox', '0 0 24 24');
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('stroke-linecap', 'round');
    path.setAttribute('stroke-linejoin', 'round');
    path.setAttribute('stroke-width', '2');
    path.setAttribute('d', 'M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12');
    svg.appendChild(path);

    const span = document.createElement('span');
    span.className = 'mt-2 text-sm text-gray-600 dark:text-gray-300';
    span.textContent = this.label;

    const inp = document.createElement('input');
    inp.type = 'file';
    inp.id = 'fu-' + this.id;
    inp.accept = this.accept;
    inp.multiple = this.multiple;
    inp.className = 'hidden';

    const self = this;
    inp.onchange = function() {
      const files = Array.from(this.files).map(f => ({
        name: f.name,
        size: f.size,
        type: f.type
      }));
      WV2Bridge.sendEvent('onFileSelect', self.id, { files: files });
    };

    lbl.appendChild(svg);
    lbl.appendChild(span);
    lbl.appendChild(inp);
    c.appendChild(lbl);
    return c;
  }
}
