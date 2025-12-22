// WV2Chart - Chart.js Diagramm Komponente
class WV2Chart {
  constructor(id, o) {
    this.id = id;
    this.type = o.type || 'bar';
    this.data = o.data || {};
    this.options = o.options || {};
    this.chart = null;
  }

  update(p) {
    if (p.data && this.chart) {
      this.chart.data = p.data;
      this.chart.update();
    }
  }

  getState() {
    return { type: this.type };
  }

  initChart(canvas) {
    if (typeof Chart === 'undefined') {
      console.warn('Chart.js not loaded');
      return;
    }
    this.chart = new Chart(canvas, {
      type: this.type,
      data: this.data,
      options: this.options
    });
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';

    const canvas = document.createElement('canvas');
    canvas.id = 'chart-' + this.id;

    c.appendChild(canvas);

    const self = this;
    setTimeout(function() { self.initChart(canvas); }, 100);

    return c;
  }
}
