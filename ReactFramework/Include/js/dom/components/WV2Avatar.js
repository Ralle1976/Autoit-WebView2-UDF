// WV2Avatar - Avatar/Profilbild Komponente
class WV2Avatar {
  constructor(id, o) {
    this.id = id;
    this.src = o.src || '';
    this.name = o.name || '';
    this.size = o.size || 'md';
  }

  update(p) {
    if (p.src) this.src = p.src;
  }

  getState() {
    return {};
  }

  render() {
    const sizes = {
      'sm': 'w-8 h-8 text-xs',
      'md': 'w-12 h-12 text-sm',
      'lg': 'w-16 h-16 text-lg'
    };

    const c = document.createElement('div');
    c.className = 'component-container inline-block';

    if (this.src) {
      const img = document.createElement('img');
      img.src = this.src;
      img.className = sizes[this.size] + ' rounded-full object-cover';
      c.appendChild(img);
    } else {
      const initials = this.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
      const div = document.createElement('div');
      div.className = sizes[this.size] + ' rounded-full bg-blue-600 text-white flex items-center justify-center font-medium';
      div.textContent = initials;
      c.appendChild(div);
    }

    return c;
  }
}
