// WV2Stepper - Fortschrittsanzeige/Wizard Komponente
class WV2Stepper {
  constructor(id, o) {
    this.id = id;
    this.steps = o.steps || [];
    this.active = o.active || 0;
  }

  update(p) {
    if (p.active !== undefined) {
      this.active = p.active;
      this.rerender();
    }
  }

  getState() {
    return { active: this.active };
  }

  rerender() {
    const el = document.getElementById('step-' + this.id);
    if (el) {
      const newEl = this.createInner();
      el.parentNode.replaceChild(newEl, el);
    }
  }

  createInner() {
    const container = document.createElement('div');
    container.id = 'step-' + this.id;
    container.className = 'flex items-center';

    this.steps.forEach((s, i) => {
      const done = i < this.active;
      const curr = i === this.active;

      // Connector line (except for first)
      if (i > 0) {
        const line = document.createElement('div');
        line.className = 'flex-1 h-0.5 ' + (done ? 'bg-blue-600' : 'bg-gray-300');
        container.appendChild(line);
      }

      // Step circle and label
      const stepDiv = document.createElement('div');
      stepDiv.className = 'flex flex-col items-center';

      const circle = document.createElement('div');
      circle.className = 'w-8 h-8 rounded-full flex items-center justify-center ' +
        (done ? 'bg-blue-600 text-white' : curr ? 'border-2 border-blue-600 text-blue-600' : 'bg-gray-300 text-gray-600');
      circle.innerHTML = done ? '&#10003;' : (i + 1);

      const label = document.createElement('div');
      label.className = 'mt-1 text-xs ' + (curr ? 'text-blue-600 font-medium' : 'text-gray-500');
      label.textContent = s.title;

      stepDiv.appendChild(circle);
      stepDiv.appendChild(label);
      container.appendChild(stepDiv);
    });

    return container;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container mb-6';
    c.appendChild(this.createInner());
    return c;
  }
}
