// WV2React Showcase - Alle Komponenten Demo
// Generiert automatisch, nicht manuell bearbeiten!

(function() {
  'use strict';
  console.log('Showcase JS gestartet');

  const root = document.getElementById('root');
  root.innerHTML = '';
  root.className = 'flex h-screen bg-gray-100 dark:bg-gray-900';

  // Sidebar
  const sidebar = document.createElement('div');
  sidebar.className = 'w-72 bg-white dark:bg-gray-800 shadow-xl flex flex-col';
  sidebar.innerHTML = `
    <div class="p-5 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-blue-600 to-blue-800">
      <h1 class="text-2xl font-bold text-white">WV2React</h1>
      <p class="text-blue-200 text-sm">Komponenten Showcase</p>
    </div>
    <nav class="flex-1 p-4 space-y-2 overflow-auto" id="nav"></nav>
    <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900">
      <div class="text-xs font-mono">
        <div class="flex justify-between">
          <span class="text-gray-500">Events:</span>
          <span id="evt-count" class="text-blue-600 font-bold">0</span>
        </div>
      </div>
    </div>
  `;
  root.appendChild(sidebar);

  // Content Area
  const content = document.createElement('div');
  content.className = 'flex-1 flex flex-col overflow-hidden';
  content.innerHTML = `
    <div class="flex-1 overflow-auto p-6" id="main"></div>
    <div class="h-40 bg-gray-900 border-t-4 border-blue-500 flex flex-col">
      <div class="flex items-center justify-between px-4 py-2 bg-gray-800">
        <span class="text-green-400 font-mono text-sm">Event Log</span>
        <button onclick="document.getElementById('log').innerHTML=''" class="text-gray-400 hover:text-white text-xs">Clear</button>
      </div>
      <div id="log" class="flex-1 overflow-auto p-3 font-mono text-xs text-green-300 space-y-1"></div>
    </div>
  `;
  root.appendChild(content);

  // Event Counter und Log Funktion
  window.evtCount = 0;
  window.log = function(msg, type) {
    window.evtCount++;
    document.getElementById('evt-count').textContent = window.evtCount;
    const log = document.getElementById('log');
    const time = new Date().toLocaleTimeString();
    const colors = { info: 'text-blue-400', success: 'text-green-400', warn: 'text-yellow-400', event: 'text-purple-400' };
    const entry = document.createElement('div');
    entry.className = colors[type] || 'text-gray-300';
    entry.innerHTML = '<span class="text-gray-500">[' + time + ']</span> ' + msg;
    log.appendChild(entry);
    log.scrollTop = log.scrollHeight;
  };

  // Tab System
  const tabs = [
    { id: 'basis', name: 'Basis-Eingabe (7)' },
    { id: 'erweitert', name: 'Erweitert (5)' },
    { id: 'navigation', name: 'Navigation (4)' },
    { id: 'feedback', name: 'Feedback (5)' },
    { id: 'anzeige', name: 'Anzeige & Layout (6)' }
  ];

  // Navigation Buttons erstellen
  const nav = document.getElementById('nav');
  tabs.forEach((tab, i) => {
    const btn = document.createElement('button');
    btn.id = 'tab-' + tab.id;
    btn.className = 'tab-btn w-full text-left px-4 py-3 rounded-lg transition-colors ' +
      (i === 0 ? 'bg-blue-600 text-white font-semibold shadow-lg' : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700');
    btn.textContent = tab.name;
    btn.onclick = function() { showTab(tab.id); };
    nav.appendChild(btn);
  });

  // ShowTab Funktion
  function showTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(b => {
      b.className = 'tab-btn w-full text-left px-4 py-3 rounded-lg transition-colors text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700';
    });
    document.getElementById('tab-' + tabId).className = 'tab-btn w-full text-left px-4 py-3 rounded-lg transition-colors bg-blue-600 text-white font-semibold shadow-lg';
    renderContent(tabId);
    window.log('Tab: ' + tabId, 'info');
  }

  // RenderContent Funktion
  function renderContent(tab) {
    const main = document.getElementById('main');

    // === TAB: BASIS ===
    if(tab === 'basis') {
      main.innerHTML = `
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-6">Basis-Eingabe Komponenten</h2>
        <div class="grid grid-cols-2 gap-6">
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Button</h3>
            <div class="space-x-2">
              <button onclick="window.log('Primary Button!', 'event')" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow transition">Primary</button>
              <button onclick="window.log('Secondary Button!', 'event')" class="px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg transition">Secondary</button>
              <button onclick="window.log('Danger Button!', 'event')" class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition">Danger</button>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Input</h3>
            <input type="text" placeholder="Tippe etwas..." oninput="window.log('Input: ' + this.value, 'event')"
              class="w-full px-4 py-2 border-2 border-gray-300 rounded-lg focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white" />
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Textarea</h3>
            <textarea rows="3" placeholder="Mehrzeiliger Text..." oninput="window.log('Textarea: ' + this.value.length + ' Zeichen', 'event')"
              class="w-full px-4 py-2 border-2 border-gray-300 rounded-lg focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"></textarea>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Checkbox</h3>
            <div class="space-y-3">
              <label class="flex items-center gap-3 cursor-pointer">
                <input type="checkbox" onchange="window.log('Newsletter: ' + (this.checked ? 'AN' : 'AUS'), 'event')" class="w-5 h-5 text-blue-600 rounded" />
                <span class="text-gray-700 dark:text-gray-300">Newsletter abonnieren</span>
              </label>
              <label class="flex items-center gap-3 cursor-pointer">
                <input type="checkbox" checked onchange="window.log('Updates: ' + (this.checked ? 'AN' : 'AUS'), 'event')" class="w-5 h-5 text-blue-600 rounded" />
                <span class="text-gray-700 dark:text-gray-300">Updates erhalten (aktiv)</span>
              </label>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Radio</h3>
            <div class="space-y-3">
              <label class="flex items-center gap-3 cursor-pointer">
                <input type="radio" name="pay" value="paypal" checked onchange="window.log('Zahlung: PayPal', 'event')" class="w-5 h-5" />
                <span class="text-gray-700 dark:text-gray-300">PayPal</span>
              </label>
              <label class="flex items-center gap-3 cursor-pointer">
                <input type="radio" name="pay" value="card" onchange="window.log('Zahlung: Kreditkarte', 'event')" class="w-5 h-5" />
                <span class="text-gray-700 dark:text-gray-300">Kreditkarte</span>
              </label>
              <label class="flex items-center gap-3 cursor-pointer">
                <input type="radio" name="pay" value="bank" onchange="window.log('Zahlung: Ueberweisung', 'event')" class="w-5 h-5" />
                <span class="text-gray-700 dark:text-gray-300">Bankueberweisung</span>
              </label>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Switch / Toggle</h3>
            <div class="space-y-4">
              <label class="flex items-center justify-between cursor-pointer">
                <span class="text-gray-700 dark:text-gray-300">Benachrichtigungen</span>
                <div class="relative">
                  <input type="checkbox" class="sr-only peer" onchange="window.log('Benachrichtigungen: ' + (this.checked ? 'AN' : 'AUS'), 'event')" />
                  <div class="w-11 h-6 bg-gray-300 peer-checked:bg-blue-600 rounded-full"></div>
                  <div class="absolute left-1 top-1 w-4 h-4 bg-white rounded-full peer-checked:translate-x-5 transition"></div>
                </div>
              </label>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 col-span-2">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Select / Dropdown</h3>
            <select onchange="window.log('Land: ' + this.value, 'event')" class="w-full max-w-md px-4 py-2 border-2 border-gray-300 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white">
              <option value="">-- Land waehlen --</option>
              <option value="de">Deutschland</option>
              <option value="at">Oesterreich</option>
              <option value="ch">Schweiz</option>
            </select>
          </div>
        </div>
      `;
    }

    // === TAB: ERWEITERT ===
    if(tab === 'erweitert') {
      main.innerHTML = `
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-6">Erweiterte Eingabe</h2>
        <div class="grid grid-cols-2 gap-6">
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">DatePicker</h3>
            <input type="date" onchange="window.log('Datum: ' + this.value, 'event')" class="w-full px-4 py-2 border-2 border-gray-300 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white" />
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">TimePicker</h3>
            <input type="time" value="12:00" onchange="window.log('Zeit: ' + this.value, 'event')" class="w-full px-4 py-2 border-2 border-gray-300 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white" />
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">ColorPicker</h3>
            <div class="flex items-center gap-4">
              <input type="color" id="cpick" value="#3B82F6" onchange="window.log('Farbe: ' + this.value, 'event'); document.getElementById('cprev').style.backgroundColor = this.value; document.getElementById('cval').textContent = this.value" class="w-16 h-16 rounded-lg cursor-pointer" />
              <div id="cprev" class="w-24 h-16 rounded-lg shadow-inner" style="background:#3B82F6"></div>
              <span id="cval" class="font-mono text-gray-600 dark:text-gray-300">#3B82F6</span>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Slider / Range</h3>
            <div class="space-y-4">
              <div>
                <label class="text-sm text-gray-600 dark:text-gray-400">Lautstaerke: <span id="vol" class="font-bold text-blue-600">50</span>%</label>
                <input type="range" min="0" max="100" value="50" oninput="document.getElementById('vol').textContent=this.value; window.log('Lautstaerke: '+this.value+'%', 'event')" class="w-full h-2 bg-gray-200 rounded-lg cursor-pointer accent-blue-600" />
              </div>
              <div>
                <label class="text-sm text-gray-600 dark:text-gray-400">Helligkeit: <span id="bri" class="font-bold text-yellow-600">75</span>%</label>
                <input type="range" min="0" max="100" value="75" oninput="document.getElementById('bri').textContent=this.value; window.log('Helligkeit: '+this.value+'%', 'event')" class="w-full h-2 bg-gray-200 rounded-lg cursor-pointer accent-yellow-500" />
              </div>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 col-span-2">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">FileUpload (Drag & Drop)</h3>
            <div id="dropzone" class="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/20 transition cursor-pointer"
              onclick="document.getElementById('finput').click()"
              ondragover="event.preventDefault(); this.classList.add('border-blue-500','bg-blue-50')"
              ondragleave="this.classList.remove('border-blue-500','bg-blue-50')"
              ondrop="event.preventDefault(); this.classList.remove('border-blue-500','bg-blue-50'); window.log('Datei: ' + event.dataTransfer.files[0].name, 'event')">
              <div class="text-4xl mb-2">&#128193;</div>
              <p class="text-gray-600 dark:text-gray-400">Datei hierher ziehen oder klicken</p>
            </div>
            <input type="file" id="finput" class="hidden" onchange="if(this.files[0]) window.log('Datei: ' + this.files[0].name, 'event')" />
          </div>
        </div>
      `;
    }

    // === TAB: NAVIGATION ===
    if(tab === 'navigation') {
      main.innerHTML = `
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-6">Navigation Komponenten</h2>
        <div class="space-y-6">
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Tabs</h3>
            <div class="border-b border-gray-200 dark:border-gray-700">
              <nav class="flex gap-4" id="demotabs">
                <button onclick="switchDemoTab('home')" id="dt-home" class="dtab px-4 py-2 border-b-2 border-blue-500 text-blue-600 font-medium">Home</button>
                <button onclick="switchDemoTab('profil')" id="dt-profil" class="dtab px-4 py-2 border-b-2 border-transparent text-gray-500 hover:text-gray-700">Profil</button>
                <button onclick="switchDemoTab('settings')" id="dt-settings" class="dtab px-4 py-2 border-b-2 border-transparent text-gray-500 hover:text-gray-700">Einstellungen</button>
              </nav>
            </div>
            <div id="dtcontent" class="p-4 text-gray-600 dark:text-gray-300">Willkommen auf der Home-Seite!</div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Breadcrumb</h3>
            <nav class="flex items-center gap-2 text-sm">
              <a href="#" onclick="window.log('Breadcrumb: Home', 'event'); return false" class="text-blue-600 hover:underline">Home</a>
              <span class="text-gray-400">/</span>
              <a href="#" onclick="window.log('Breadcrumb: Produkte', 'event'); return false" class="text-blue-600 hover:underline">Produkte</a>
              <span class="text-gray-400">/</span>
              <span class="text-gray-500">Artikel</span>
            </nav>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Pagination</h3>
            <div class="flex items-center gap-2">
              <button onclick="window.log('Seite: Zurueck', 'event')" class="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 dark:bg-gray-700">&laquo;</button>
              <button onclick="window.log('Seite: 1', 'event')" class="px-3 py-1 rounded bg-blue-600 text-white">1</button>
              <button onclick="window.log('Seite: 2', 'event')" class="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 dark:bg-gray-700">2</button>
              <button onclick="window.log('Seite: 3', 'event')" class="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 dark:bg-gray-700">3</button>
              <span class="px-2 text-gray-400">...</span>
              <button onclick="window.log('Seite: 10', 'event')" class="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 dark:bg-gray-700">10</button>
              <button onclick="window.log('Seite: Weiter', 'event')" class="px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 dark:bg-gray-700">&raquo;</button>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Stepper (Wizard)</h3>
            <div class="flex items-center justify-between max-w-2xl">
              <div class="flex flex-col items-center">
                <div class="w-10 h-10 rounded-full bg-green-500 text-white flex items-center justify-center font-bold">&#10003;</div>
                <span class="text-sm mt-2 text-green-600">Warenkorb</span>
              </div>
              <div class="flex-1 h-1 bg-green-500 mx-2"></div>
              <div class="flex flex-col items-center">
                <div class="w-10 h-10 rounded-full bg-blue-600 text-white flex items-center justify-center font-bold">2</div>
                <span class="text-sm mt-2 text-blue-600 font-medium">Adresse</span>
              </div>
              <div class="flex-1 h-1 bg-gray-300 mx-2"></div>
              <div class="flex flex-col items-center">
                <div class="w-10 h-10 rounded-full bg-gray-300 text-gray-500 flex items-center justify-center font-bold">3</div>
                <span class="text-sm mt-2 text-gray-500">Zahlung</span>
              </div>
              <div class="flex-1 h-1 bg-gray-300 mx-2"></div>
              <div class="flex flex-col items-center">
                <div class="w-10 h-10 rounded-full bg-gray-300 text-gray-500 flex items-center justify-center font-bold">4</div>
                <span class="text-sm mt-2 text-gray-500">Fertig</span>
              </div>
            </div>
          </div>
        </div>
      `;
    }

    // === TAB: FEEDBACK ===
    if(tab === 'feedback') {
      main.innerHTML = `
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-6">Feedback Komponenten</h2>
        <div class="grid grid-cols-2 gap-6">
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 col-span-2">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Alerts</h3>
            <div class="space-y-3">
              <div class="flex items-center gap-3 p-4 bg-blue-50 border-l-4 border-blue-500 text-blue-700 rounded">&#8505; Info: Dies ist eine Informationsmeldung.</div>
              <div class="flex items-center gap-3 p-4 bg-green-50 border-l-4 border-green-500 text-green-700 rounded">&#10003; Erfolg: Aktion erfolgreich abgeschlossen!</div>
              <div class="flex items-center gap-3 p-4 bg-yellow-50 border-l-4 border-yellow-500 text-yellow-700 rounded">&#9888; Warnung: Bitte ueberpruefen Sie Ihre Eingaben.</div>
              <div class="flex items-center gap-3 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 rounded">&#10007; Fehler: Es ist ein Problem aufgetreten.</div>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Progress Bar</h3>
            <div class="space-y-4">
              <div>
                <div class="flex justify-between text-sm mb-1">
                  <span>Download</span>
                  <span id="pval">0%</span>
                </div>
                <div class="w-full h-3 bg-gray-200 rounded-full overflow-hidden">
                  <div id="pbar" class="h-full bg-blue-600 transition-all" style="width:0%"></div>
                </div>
              </div>
              <button onclick="animProgress()" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Progress animieren</button>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Spinner / Loading</h3>
            <div class="flex items-center gap-6">
              <div class="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
              <div class="w-12 h-12 border-4 border-green-500 border-t-transparent rounded-full animate-spin"></div>
              <div class="w-16 h-16 border-4 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Toast Notifications</h3>
            <div class="flex gap-3">
              <button onclick="showToast('Erfolgreich gespeichert!', 'success')" class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600">Success Toast</button>
              <button onclick="showToast('Ein Fehler ist aufgetreten', 'error')" class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600">Error Toast</button>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Modal / Dialog</h3>
            <button onclick="showModal()" class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700">Modal oeffnen</button>
          </div>
        </div>
      `;
    }

    // === TAB: ANZEIGE ===
    if(tab === 'anzeige') {
      main.innerHTML = `
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-6">Anzeige & Layout</h2>
        <div class="grid grid-cols-2 gap-6">
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Badges</h3>
            <div class="flex flex-wrap gap-2">
              <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">Primary</span>
              <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">Success</span>
              <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">Warning</span>
              <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm font-medium">Danger</span>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Avatars</h3>
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold">MM</div>
              <div class="w-12 h-12 rounded-full bg-green-500 flex items-center justify-center text-white font-bold text-lg">AS</div>
              <div class="w-14 h-14 rounded-full bg-purple-500 flex items-center justify-center text-white font-bold text-xl">TM</div>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Tags (entfernbar)</h3>
            <div id="tags" class="flex flex-wrap gap-2">
              <span class="inline-flex items-center gap-1 px-3 py-1 bg-gray-200 dark:bg-gray-700 rounded-full text-sm">
                AutoIt
                <button onclick="this.parentElement.remove(); window.log('Tag entfernt: AutoIt', 'event')" class="ml-1 text-gray-500 hover:text-red-500">&#10005;</button>
              </span>
              <span class="inline-flex items-center gap-1 px-3 py-1 bg-gray-200 dark:bg-gray-700 rounded-full text-sm">
                WebView2
                <button onclick="this.parentElement.remove(); window.log('Tag entfernt: WebView2', 'event')" class="ml-1 text-gray-500 hover:text-red-500">&#10005;</button>
              </span>
              <span class="inline-flex items-center gap-1 px-3 py-1 bg-gray-200 dark:bg-gray-700 rounded-full text-sm">
                React
                <button onclick="this.parentElement.remove(); window.log('Tag entfernt: React', 'event')" class="ml-1 text-gray-500 hover:text-red-500">&#10005;</button>
              </span>
            </div>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">Divider</h3>
            <p class="text-gray-600 dark:text-gray-400 mb-3">Inhalt oberhalb</p>
            <hr class="border-gray-300" />
            <p class="text-gray-600 dark:text-gray-400 my-3">Einfacher Divider</p>
            <div class="flex items-center gap-4">
              <div class="flex-1 border-t border-gray-300"></div>
              <span class="text-gray-500 text-sm">ODER</span>
              <div class="flex-1 border-t border-gray-300"></div>
            </div>
            <p class="text-gray-600 dark:text-gray-400 mt-3">Inhalt unterhalb</p>
          </div>
          <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 col-span-2">
            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-200 mb-4">StatCards (Dashboard)</h3>
            <div class="grid grid-cols-4 gap-4">
              <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-5 text-white">
                <p class="text-blue-100 text-sm">Benutzer</p>
                <p class="text-3xl font-bold mt-1">1,234</p>
                <p class="text-green-300 text-sm mt-2">&#9650; +12%</p>
              </div>
              <div class="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-5 text-white">
                <p class="text-green-100 text-sm">Umsatz</p>
                <p class="text-3xl font-bold mt-1">45.6K</p>
                <p class="text-green-200 text-sm mt-2">&#9650; +8%</p>
              </div>
              <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl p-5 text-white">
                <p class="text-purple-100 text-sm">Bestellungen</p>
                <p class="text-3xl font-bold mt-1">892</p>
                <p class="text-green-300 text-sm mt-2">&#9650; +23%</p>
              </div>
              <div class="bg-gradient-to-br from-orange-500 to-red-500 rounded-xl p-5 text-white">
                <p class="text-orange-100 text-sm">Fehler</p>
                <p class="text-3xl font-bold mt-1">23</p>
                <p class="text-red-200 text-sm mt-2">&#9660; -5%</p>
              </div>
            </div>
          </div>
        </div>
      `;
    }
  }

  // === HELPER FUNKTIONEN ===
  window.switchDemoTab = function(t) {
    document.querySelectorAll('.dtab').forEach(b => b.className = 'dtab px-4 py-2 border-b-2 border-transparent text-gray-500 hover:text-gray-700');
    document.getElementById('dt-' + t).className = 'dtab px-4 py-2 border-b-2 border-blue-500 text-blue-600 font-medium';
    const c = { home: 'Willkommen auf der Home-Seite!', profil: 'Dein Profil - Bearbeite deine Daten.', settings: 'Einstellungen - Passe die App an.' };
    document.getElementById('dtcontent').textContent = c[t];
    window.log('Demo-Tab: ' + t, 'event');
  };

  window.animProgress = function() {
    let v = 0;
    const bar = document.getElementById('pbar');
    const lbl = document.getElementById('pval');
    const i = setInterval(() => {
      v += 5;
      bar.style.width = v + '%';
      lbl.textContent = v + '%';
      if(v >= 100) {
        clearInterval(i);
        window.log('Progress: 100% - Fertig!', 'success');
      }
    }, 100);
    window.log('Progress Animation gestartet', 'event');
  };

  window.showToast = function(msg, type) {
    let c = document.getElementById('toast-container');
    if(!c) {
      c = document.createElement('div');
      c.id = 'toast-container';
      c.className = 'fixed top-4 right-4 space-y-2 z-50';
      document.body.appendChild(c);
    }
    const t = document.createElement('div');
    t.className = 'px-4 py-3 rounded-lg shadow-lg text-white ' + (type === 'success' ? 'bg-green-500' : 'bg-red-500');
    t.innerHTML = (type === 'success' ? '&#10003; ' : '&#10007; ') + msg;
    c.appendChild(t);
    window.log('Toast: ' + msg, 'event');
    setTimeout(() => {
      t.style.opacity = '0';
      setTimeout(() => t.remove(), 300);
    }, 3000);
  };

  window.showModal = function() {
    const m = document.createElement('div');
    m.id = 'modal-overlay';
    m.className = 'fixed inset-0 bg-black/50 flex items-center justify-center z-50';
    m.innerHTML = `
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-2xl p-6 max-w-md w-full mx-4">
        <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Bestaetigung</h3>
        <p class="text-gray-600 dark:text-gray-300 mb-6">Moechten Sie diese Aktion wirklich ausfuehren?</p>
        <div class="flex justify-end gap-3">
          <button onclick="closeModal('abgebrochen')" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300">Abbrechen</button>
          <button onclick="closeModal('bestaetigt')" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Bestaetigen</button>
        </div>
      </div>
    `;
    document.body.appendChild(m);
    window.log('Modal geoeffnet', 'event');
  };

  window.closeModal = function(action) {
    document.getElementById('modal-overlay').remove();
    window.log('Modal: ' + action, 'event');
  };

  // Initial laden
  renderContent('basis');
  window.log('Showcase geladen - 27 Komponenten bereit!', 'success');
})();
