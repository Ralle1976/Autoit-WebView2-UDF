// WV2Tabs - Tab Navigation Komponente
class WV2Tabs {
  constructor(id, o) {
    this.id = id;
    this.tabs = o.tabs || [];
    this.active = o.active || (this.tabs.length > 0 ? this.tabs[0].id : '');
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
    const el = document.getElementById('tabs-' + this.id);
    if (el) el.outerHTML = this.renderInner();
  }

  renderInner() {
    const container = document.createElement('div');
    container.id = 'tabs-' + this.id;
    container.className = 'w-full';

    const tabBar = document.createElement('div');
    tabBar.className = 'flex border-b border-gray-200 dark:border-gray-700';

    const self = this;
    this.tabs.forEach(t => {
      const btn = document.createElement('button');
      btn.className = 'px-4 py-2 font-medium ' +
        (this.active === t.id
          ? 'text-blue-600 border-b-2 border-blue-600'
          : 'text-gray-500 hover:text-gray-700');
      btn.textContent = t.label;
      btn.onclick = function() {
        self.active = t.id;
        self.rerender();
        WV2Bridge.sendEvent('onTabChange', self.id, { active: t.id });
      };
      tabBar.appendChild(btn);
    });

    const content = document.createElement('div');
    content.className = 'p-4';

    const activeTab = this.tabs.find(t => t.id === this.active);
    if (activeTab) content.innerHTML = activeTab.content;

    container.appendChild(tabBar);
    container.appendChild(content);

    const temp = document.createElement('div');
    temp.appendChild(container);
    return temp.innerHTML;
  }

  render() {
    const c = document.createElement('div');
    c.className = 'component-container';
    c.innerHTML = this.renderInner();
    return c;
  }
}
