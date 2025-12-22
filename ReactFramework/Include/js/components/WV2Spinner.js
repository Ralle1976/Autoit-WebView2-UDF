// WV2Spinner - Lade-Animation Komponente
class WV2Spinner {
  constructor(id, o) {
    this.id = id;
    this.size = o.size || 'md';
    this.color = o.color || '';
  }

  update(p) { }

  getState() {
    return {};
  }

  render() {
    const sizes = {
      'sm': 'w-4 h-4',
      'md': 'w-8 h-8',
      'lg': 'w-12 h-12'
    };

    const c = document.createElement('div');
    c.className = 'component-container flex justify-center';

    const spinner = document.createElement('div');
    spinner.className = sizes[this.size] + ' border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin';

    c.appendChild(spinner);
    return c;
  }
}
