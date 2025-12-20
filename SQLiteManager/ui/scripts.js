// SQLite Manager Pro v3.5 - JavaScript
// Keine Quote-Escaping-Probleme mehr!

var D = null;
var schema = [];
var acItems = [];
var acIndex = -1;
var wizardType = 'select';
var resizing = null;
var startX = 0;
var startW = 0;

// SQL Keywords und Funktionen
var KEYWORDS = [
    'SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT', 'IN', 'LIKE', 'BETWEEN', 'IS', 'NULL',
    'AS', 'ON', 'JOIN', 'LEFT', 'RIGHT', 'INNER', 'OUTER', 'CROSS', 'FULL', 'NATURAL',
    'USING', 'GROUP', 'BY', 'HAVING', 'ORDER', 'ASC', 'DESC', 'LIMIT', 'OFFSET',
    'UNION', 'ALL', 'INTERSECT', 'EXCEPT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET',
    'DELETE', 'CREATE', 'TABLE', 'VIEW', 'INDEX', 'UNIQUE', 'PRIMARY', 'KEY', 'FOREIGN',
    'REFERENCES', 'DROP', 'ALTER', 'ADD', 'COLUMN', 'RENAME', 'TO', 'IF', 'EXISTS',
    'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'DISTINCT', 'COUNT', 'SUM', 'AVG', 'MIN', 'MAX',
    'COALESCE', 'NULLIF', 'CAST', 'SUBSTR', 'LENGTH', 'UPPER', 'LOWER', 'TRIM', 'REPLACE',
    'INSTR', 'ABS', 'ROUND', 'DATE', 'TIME', 'DATETIME', 'STRFTIME'
];

var FUNCTIONS = [
    'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'COALESCE', 'NULLIF', 'CAST', 'SUBSTR', 'LENGTH',
    'UPPER', 'LOWER', 'TRIM', 'REPLACE', 'INSTR', 'ABS', 'ROUND', 'DATE', 'TIME', 'DATETIME',
    'STRFTIME', 'TYPEOF', 'IFNULL', 'IIF', 'PRINTF', 'RANDOM', 'TOTAL', 'GROUP_CONCAT',
    'HEX', 'QUOTE', 'ZEROBLOB'
];

// Themes
var THEMES = {
    dark: {
        bg: '#0d1117', bg2: '#161b22', bg3: '#21262d',
        border: '#30363d', text: '#c9d1d9', text2: '#8b949e', accent: '#58a6ff'
    },
    light: {
        bg: '#ffffff', bg2: '#f6f8fa', bg3: '#e1e4e8',
        border: '#d1d5da', text: '#24292e', text2: '#586069', accent: '#0366d6'
    }
};

// API Functions (called from AutoIt)
function getSQL() { return document.getElementById('sql').value; }
function hasData() { return D && D.r && D.r.length > 0; }

function getCSV() {
    if (!D) return '';
    var s = D.c.join(';') + '\n';
    for (var i = 0; i < D.r.length; i++) {
        s += D.r[i].join(';') + '\n';
    }
    return s;
}

function setSchema(a) {
    schema = a || [];
    renderSchema();
    updateAutocomplete();
}

function setResults(d) {
    D = d;
    var e = document.getElementById('output');
    var h = '<table id="resultsTable"><thead><tr>';
    for (var i = 0; i < d.c.length; i++) {
        h += '<th>' + esc(d.c[i]) + '</th>';
    }
    h += '</tr></thead><tbody id="resultsBody">';
    for (var i = 0; i < d.r.length; i++) {
        h += '<tr>';
        for (var j = 0; j < d.r[i].length; j++) {
            var v = d.r[i][j];
            h += v === '' ? '<td class="null">NULL</td>' : '<td>' + esc(v) + '</td>';
        }
        h += '</tr>';
    }
    h += '</tbody></table>';

    // Stats and Load More button
    var stats = d.displayed + ' von ' + d.n + ' Zeilen (' + d.t + ' ms)';
    h += '<div class="result-stats">' + stats + '</div>';

    if (d.hasMore) {
        h += '<div class="load-more-container">';
        h += '<button class="load-more-btn" onclick="loadMore()">&#9660; Weitere ' + d.chunkSize + ' Zeilen laden (' + (d.n - d.displayed) + ' verbleibend)</button>';
        h += '</div>';
    }

    e.innerHTML = h;
}

function appendResults(d) {
    var tbody = document.getElementById('resultsBody');
    if (!tbody) return;

    var h = '';
    for (var i = 0; i < d.r.length; i++) {
        h += '<tr>';
        for (var j = 0; j < d.r[i].length; j++) {
            var v = d.r[i][j];
            h += v === '' ? '<td class="null">NULL</td>' : '<td>' + esc(v) + '</td>';
        }
        h += '</tr>';
    }
    tbody.insertAdjacentHTML('beforeend', h);

    // Stats aktualisieren
    var stats = d.displayed + ' von ' + d.total + ' Zeilen';
    var statsDiv = document.querySelector('.result-stats');
    if (statsDiv) statsDiv.innerHTML = stats;

    // Load More Button aktualisieren oder entfernen
    var container = document.querySelector('.load-more-container');
    if (container) {
        if (d.hasMore) {
            var remaining = d.total - d.displayed;
            container.innerHTML = '<button class="load-more-btn" onclick="loadMore()">&#9660; Weitere Zeilen laden (' + remaining + ' verbleibend)</button>';
        } else {
            container.innerHTML = '<div class="all-loaded">Alle ' + d.total + ' Zeilen geladen</div>';
        }
    }
}

// Pending action for AutoIt polling
var pendingAction = null;

function loadMore() {
    pendingAction = 'loadMore';
}

// Called by AutoIt to check for pending actions
function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;
    return action;
}

function setMsg(m) {
    D = null;
    document.getElementById('output').innerHTML = '<div class="msg">' + esc(m) + '</div>';
}

function setErr(m) {
    D = null;
    document.getElementById('output').innerHTML = '<div class="err">' + esc(m) + '</div>';
}

function setTheme(t) {
    var th = THEMES[t];
    if (!th) return;
    var r = document.documentElement;
    r.style.setProperty('--bg', th.bg);
    r.style.setProperty('--bg2', th.bg2);
    r.style.setProperty('--bg3', th.bg3);
    r.style.setProperty('--border', th.border);
    r.style.setProperty('--text', th.text);
    r.style.setProperty('--text2', th.text2);
    r.style.setProperty('--accent', th.accent);
    toast(t === 'dark' ? 'Dark Theme' : 'Light Theme');
}

// Schema Rendering
function renderSchema() {
    var e = document.getElementById('schema');
    var f = document.getElementById('schemaSearch').value.toLowerCase();

    if (!schema.length) {
        e.innerHTML = '<div class="empty">Keine Tabellen</div>';
        return;
    }

    var h = '';
    schema.forEach(function(t) {
        if (f && t.n.toLowerCase().indexOf(f) < 0) return;

        h += '<div class="table-item">';
        h += '<div class="table-header" onclick="toggleTable(this)" data-name="' + t.n + '">';
        h += '<span class="table-icon ' + (t.t === 'table' ? 't' : 'v') + '">' + (t.t === 'table' ? 'T' : 'V') + '</span>';
        h += '<span class="table-name">' + t.n + '</span>';
        h += '<div class="table-actions">';
        h += '<button onclick="event.stopPropagation();selectTable(\'' + t.n + '\')">SELECT</button>';
        h += '<button onclick="event.stopPropagation();showTableInfo(\'' + t.n + '\')">Info</button>';
        h += '</div></div>';
        h += '<div class="table-cols" id="cols_' + t.n + '">';

        t.cols.forEach(function(c) {
            h += '<div class="col-item" onclick="insertColumn(\'' + c.n + '\')">';
            h += (c.pk ? '<span class="col-pk">PK</span>' : '');
            h += '<span>' + c.n + '</span>';
            h += '<span class="col-type">' + c.t + '</span>';
            h += '</div>';
        });

        h += '</div></div>';
    });

    e.innerHTML = h;
}

function filterSchema() { renderSchema(); }

function toggleTable(el) {
    var cols = document.getElementById('cols_' + el.dataset.name);
    document.querySelectorAll('.table-cols').forEach(function(c) {
        if (c !== cols) c.classList.remove('open');
    });
    document.querySelectorAll('.table-header').forEach(function(h) {
        if (h !== el) h.classList.remove('active');
    });
    cols.classList.toggle('open');
    el.classList.toggle('active');
}

function selectTable(n) {
    document.getElementById('sql').value = 'SELECT * FROM ' + n + ' LIMIT 100;';
    onSQLInput();
}

function insertColumn(n) {
    var ta = document.getElementById('sql');
    var p = ta.selectionStart;
    var v = ta.value;
    ta.value = v.slice(0, p) + n + v.slice(p);
    ta.selectionStart = ta.selectionEnd = p + n.length;
    ta.focus();
    onSQLInput();
}

function showTableInfo(n) {
    var t = schema.find(function(x) { return x.n === n; });
    if (!t) return;

    var h = '<div class="ip-section"><h4>Spalten</h4>';
    t.cols.forEach(function(c) {
        h += '<div class="ip-row"><span>' + c.n;
        h += (c.pk ? ' <span class="col-pk">PK</span>' : '');
        h += (c.nn ? ' NOT NULL' : '');
        h += '</span><span class="col-type">' + c.t + '</span></div>';
    });
    h += '</div>';

    if (t.fk.length) {
        h += '<div class="ip-section"><h4>Foreign Keys</h4>';
        t.fk.forEach(function(f) {
            h += '<div class="ip-row"><span>' + f.from + '</span><span class="col-fk">' + f.to + '</span></div>';
        });
        h += '</div>';
    }

    if (t.idx.length) {
        h += '<div class="ip-section"><h4>Indizes</h4>';
        t.idx.forEach(function(i) {
            h += '<div class="ip-row"><span>' + i.n + '</span><span>' + (i.u ? 'UNIQUE' : '') + '</span></div>';
        });
        h += '</div>';
    }

    document.getElementById('ipTitle').textContent = n;
    document.getElementById('ipContent').innerHTML = h;
    document.querySelector('.layout').classList.add('info-open');
    document.getElementById('resizerRight').style.display = 'block';
}

function closeInfoPanel() {
    document.querySelector('.layout').classList.remove('info-open');
    document.getElementById('resizerRight').style.display = 'none';
}

// SQL Editor
function onSQLInput() {
    highlightSQL();
    updateLineNumbers();
    checkAutocomplete();
}

function highlightSQL() {
    var sql = document.getElementById('sql').value;
    var h = esc(sql);

    // Comments
    h = h.replace(/--.*$/gm, '<span class="hl-comment">$&</span>');

    // Strings
    h = h.replace(/('[^']*'|"[^"]*")/g, '<span class="hl-string">$&</span>');

    // Numbers
    h = h.replace(/\b(\d+\.?\d*)\b/g, '<span class="hl-number">$1</span>');

    // Keywords
    var kwRe = new RegExp('\\b(' + KEYWORDS.join('|') + ')\\b', 'gi');
    h = h.replace(kwRe, '<span class="hl-keyword">$1</span>');

    // Functions
    var fnRe = new RegExp('\\b(' + FUNCTIONS.join('|') + ')\\s*\\(', 'gi');
    h = h.replace(fnRe, '<span class="hl-function">$1</span>(');

    // Table names
    schema.forEach(function(t) {
        var re = new RegExp('\\b' + t.n + '\\b', 'gi');
        h = h.replace(re, '<span class="hl-table">' + t.n + '</span>');
    });

    document.getElementById('highlight').innerHTML = h;
}

function updateLineNumbers() {
    var sql = document.getElementById('sql').value;
    var lines = sql.split('\n').length;
    var nums = '';
    for (var i = 1; i <= lines; i++) nums += i + '\n';
    document.getElementById('lineNumbers').textContent = nums;
}

function syncScroll() {
    var ta = document.getElementById('sql');
    document.getElementById('highlight').scrollTop = ta.scrollTop;
    document.getElementById('highlight').scrollLeft = ta.scrollLeft;
    document.getElementById('lineNumbers').scrollTop = ta.scrollTop;
}

function formatSQL() {
    var ta = document.getElementById('sql');
    var sql = ta.value.replace(/\s+/g, ' ').trim();
    var kws = ['SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'ORDER BY', 'GROUP BY', 'HAVING',
               'LIMIT', 'OFFSET', 'JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'INNER JOIN', 'ON',
               'SET', 'VALUES', 'INTO'];
    kws.forEach(function(k) {
        sql = sql.replace(new RegExp('\\s*\\b' + k + '\\b\\s*', 'gi'), '\n' + k + ' ');
    });
    ta.value = sql.trim();
    onSQLInput();
}

function clearEditor() {
    document.getElementById('sql').value = '';
    onSQLInput();
}

// Autocomplete
function checkAutocomplete() {
    var ta = document.getElementById('sql');
    var p = ta.selectionStart;
    var v = ta.value;
    var before = v.slice(0, p);
    var match = before.match(/[a-zA-Z_]\w*$/);

    if (!match) { hideAC(); return; }

    var word = match[0].toUpperCase();
    acItems = [];

    KEYWORDS.forEach(function(k) {
        if (k.indexOf(word) === 0) acItems.push({ t: 'kw', n: k, h: 'Keyword' });
    });

    FUNCTIONS.forEach(function(f) {
        if (f.indexOf(word) === 0 && !acItems.find(function(x) { return x.n === f; })) {
            acItems.push({ t: 'fn', n: f, h: 'Function' });
        }
    });

    schema.forEach(function(tb) {
        if (tb.n.toUpperCase().indexOf(word) === 0) {
            acItems.push({ t: 'tb', n: tb.n, h: 'Table' });
        }
        tb.cols.forEach(function(c) {
            if (c.n.toUpperCase().indexOf(word) === 0) {
                acItems.push({ t: 'cl', n: c.n, h: tb.n + '.' + c.t });
            }
        });
    });

    if (acItems.length === 0 || (acItems.length === 1 && acItems[0].n.toUpperCase() === word)) {
        hideAC();
        return;
    }

    acIndex = 0;
    showAC();
}

function showAC() {
    var ac = document.getElementById('autocomplete');
    var h = '';
    acItems.slice(0, 10).forEach(function(it, i) {
        h += '<div class="ac-item' + (i === acIndex ? ' selected' : '') + '" onclick="selectAC(' + i + ')">';
        h += '<span class="ac-icon ' + it.t + '">' + it.t.toUpperCase() + '</span>';
        h += '<span class="ac-text">' + it.n + '</span>';
        h += '<span class="ac-hint">' + it.h + '</span>';
        h += '</div>';
    });
    ac.innerHTML = h;
    ac.style.display = 'block';
}

function hideAC() {
    document.getElementById('autocomplete').style.display = 'none';
    acIndex = -1;
}

function selectAC(i) {
    var it = acItems[i];
    if (!it) return;

    var ta = document.getElementById('sql');
    var p = ta.selectionStart;
    var v = ta.value;
    var before = v.slice(0, p);
    var after = v.slice(p);
    var match = before.match(/[a-zA-Z_]\w*$/);

    if (match) before = before.slice(0, -match[0].length);

    ta.value = before + it.n + after;
    ta.selectionStart = ta.selectionEnd = before.length + it.n.length;
    ta.focus();
    onSQLInput();
    hideAC();
}

function onKeyDown(e) {
    var ac = document.getElementById('autocomplete');
    if (ac.style.display === 'block') {
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            acIndex = Math.min(acIndex + 1, acItems.length - 1);
            showAC();
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            acIndex = Math.max(acIndex - 1, 0);
            showAC();
        } else if (e.key === 'Enter' || e.key === 'Tab') {
            if (acIndex >= 0) {
                e.preventDefault();
                selectAC(acIndex);
            }
        } else if (e.key === 'Escape') {
            hideAC();
        }
    }
}

function updateAutocomplete() {}

// Wizard
function showWizard() {
    document.getElementById('wizardModal').classList.add('open');
    renderWizard();
}

function closeWizard() {
    document.getElementById('wizardModal').classList.remove('open');
}

function renderWizard() {
    var h = '<div class="wizard-tabs">';
    ['select', 'join', 'insert', 'update', 'delete'].forEach(function(t) {
        h += '<div class="wizard-tab' + (t === wizardType ? ' active' : '') + '" ';
        h += 'onclick="setWizardType(\'' + t + '\')">' + t.toUpperCase() + '</div>';
    });
    h += '</div><div id="wizardForm"></div>';
    h += '<div class="wizard-section"><label>Vorschau</label>';
    h += '<div class="wizard-preview" id="wizardPreview"></div></div>';
    document.getElementById('wizardBody').innerHTML = h;
    renderWizardForm();
}

function setWizardType(t) {
    wizardType = t;
    renderWizard();
}

function renderWizardForm() {
    var f = document.getElementById('wizardForm');
    var tbOpts = '<option value="">Tabelle waehlen...</option>';
    schema.filter(function(t) { return t.t === 'table'; }).forEach(function(t) {
        tbOpts += '<option value="' + t.n + '">' + t.n + '</option>';
    });

    var h = '';

    if (wizardType === 'select') {
        h = '<div class="wizard-row">' +
            '<div class="wizard-section"><label>Tabelle</label>' +
            '<select id="wTable" onchange="updateWizardPreview()">' + tbOpts + '</select></div>' +
            '<div class="wizard-section"><label>Spalten (* fuer alle)</label>' +
            '<input id="wCols" value="*" oninput="updateWizardPreview()"></div></div>' +
            '<div class="wizard-row">' +
            '<div class="wizard-section"><label>WHERE</label>' +
            '<input id="wWhere" placeholder="z.B. id > 10" oninput="updateWizardPreview()"></div>' +
            '<div class="wizard-section"><label>ORDER BY</label>' +
            '<input id="wOrder" oninput="updateWizardPreview()"></div></div>' +
            '<div class="wizard-row">' +
            '<div class="wizard-section"><label>LIMIT</label>' +
            '<input id="wLimit" type="number" value="100" oninput="updateWizardPreview()"></div>' +
            '<div class="wizard-section"><label>OFFSET</label>' +
            '<input id="wOffset" type="number" value="0" oninput="updateWizardPreview()"></div></div>';
    } else if (wizardType === 'join') {
        h = '<div class="wizard-row">' +
            '<div class="wizard-section"><label>Tabelle 1</label>' +
            '<select id="wTable1" onchange="autoDetectJoin()">' + tbOpts + '</select></div>' +
            '<div class="wizard-section"><label>Tabelle 2</label>' +
            '<select id="wTable2" onchange="autoDetectJoin()">' + tbOpts + '</select></div></div>' +
            '<div id="joinHint" style="padding:8px 0;color:var(--accent);font-size:12px"></div>' +
            '<div class="wizard-row">' +
            '<div class="wizard-section"><label>JOIN Typ</label>' +
            '<select id="wJoinType" onchange="updateWizardPreview()">' +
            '<option>INNER JOIN</option><option>LEFT JOIN</option>' +
            '<option>RIGHT JOIN</option><option>CROSS JOIN</option></select></div>' +
            '<div class="wizard-section"><label>ON (auto-erkannt)</label>' +
            '<input id="wJoinOn" placeholder="wird automatisch erkannt" oninput="updateWizardPreview()"></div></div>' +
            '<div class="wizard-section"><label>Spalten</label>' +
            '<input id="wJoinCols" value="*" oninput="updateWizardPreview()"></div>';
    } else if (wizardType === 'insert') {
        h = '<div class="wizard-section"><label>Tabelle</label>' +
            '<select id="wTable" onchange="updateInsertCols();updateWizardPreview()">' + tbOpts + '</select></div>' +
            '<div class="wizard-section"><label>Spalten</label>' +
            '<input id="wInsCols" readonly></div>' +
            '<div class="wizard-section"><label>Werte (kommagetrennt)</label>' +
            '<input id="wInsVals" placeholder="\'Wert1\', \'Wert2\', ..." oninput="updateWizardPreview()"></div>';
    } else if (wizardType === 'update') {
        h = '<div class="wizard-section"><label>Tabelle</label>' +
            '<select id="wTable" onchange="updateWizardPreview()">' + tbOpts + '</select></div>' +
            '<div class="wizard-section"><label>SET (spalte = wert, ...)</label>' +
            '<input id="wUpdSet" placeholder="name = \'Neu\', active = 1" oninput="updateWizardPreview()"></div>' +
            '<div class="wizard-section"><label>WHERE</label>' +
            '<input id="wUpdWhere" placeholder="id = 1" oninput="updateWizardPreview()"></div>';
    } else if (wizardType === 'delete') {
        h = '<div class="wizard-section"><label>Tabelle</label>' +
            '<select id="wTable" onchange="updateWizardPreview()">' + tbOpts + '</select></div>' +
            '<div class="wizard-section"><label>WHERE (PFLICHT!)</label>' +
            '<input id="wDelWhere" placeholder="id = 1" oninput="updateWizardPreview()"></div>';
    }

    f.innerHTML = h;
    updateWizardPreview();
}

function updateInsertCols() {
    var t = document.getElementById('wTable').value;
    if (!t) return;
    var tb = schema.find(function(x) { return x.n === t; });
    if (!tb) return;
    document.getElementById('wInsCols').value = tb.cols.map(function(c) { return c.n; }).join(', ');
}

function updateWizardPreview() {
    var sql = '';

    if (wizardType === 'select') {
        var t = gv('wTable'), c = gv('wCols') || '*', w = gv('wWhere'), o = gv('wOrder'), l = gv('wLimit'), off = gv('wOffset');
        if (t) {
            sql = 'SELECT ' + c + ' FROM ' + t;
            if (w) sql += ' WHERE ' + w;
            if (o) sql += ' ORDER BY ' + o;
            if (l) sql += ' LIMIT ' + l;
            if (off && off !== '0') sql += ' OFFSET ' + off;
        }
    } else if (wizardType === 'join') {
        var t1 = gv('wTable1'), t2 = gv('wTable2'), jt = gv('wJoinType'), jo = gv('wJoinOn'), jc = gv('wJoinCols') || '*';
        if (t1 && t2) {
            var order = getTableOrder(t1, t2);
            sql = 'SELECT ' + jc + ' FROM ' + order.main + ' ' + jt + ' ' + order.join;
            if (jo) sql += ' ON ' + jo;
        }
    } else if (wizardType === 'insert') {
        var t = gv('wTable'), c = gv('wInsCols'), v = gv('wInsVals');
        if (t && v) {
            sql = 'INSERT INTO ' + t;
            if (c) sql += ' (' + c + ')';
            sql += ' VALUES (' + v + ')';
        }
    } else if (wizardType === 'update') {
        var t = gv('wTable'), s = gv('wUpdSet'), w = gv('wUpdWhere');
        if (t && s) {
            sql = 'UPDATE ' + t + ' SET ' + s;
            if (w) sql += ' WHERE ' + w;
        }
    } else if (wizardType === 'delete') {
        var t = gv('wTable'), w = gv('wDelWhere');
        if (t && w) {
            sql = 'DELETE FROM ' + t + ' WHERE ' + w;
        }
    }

    document.getElementById('wizardPreview').textContent = sql || '(Bitte Felder ausfuellen)';
}

function gv(id) {
    var e = document.getElementById(id);
    return e ? e.value.trim() : '';
}

function applyWizard() {
    var sql = document.getElementById('wizardPreview').textContent;
    if (sql && !sql.startsWith('(')) {
        document.getElementById('sql').value = sql + ';';
        onSQLInput();
        closeWizard();
    }
}

// FK Detection for JOINs
function getTableOrder(t1, t2) {
    var tb1 = schema.find(function(x) { return x.n === t1; });
    var tb2 = schema.find(function(x) { return x.n === t2; });

    if (!tb1 || !tb2) return { main: t1, join: t2, on: '', hint: '' };

    var fk1to2 = tb1.fk.find(function(f) { return f.to.startsWith(t2 + '.'); });
    var fk2to1 = tb2.fk.find(function(f) { return f.to.startsWith(t1 + '.'); });

    if (fk1to2) {
        return {
            main: t2, join: t1,
            on: t1 + '.' + fk1to2.from + ' = ' + fk1to2.to,
            hint: '(' + t1 + ' hat FK auf ' + t2 + ')'
        };
    }
    if (fk2to1) {
        return {
            main: t1, join: t2,
            on: t2 + '.' + fk2to1.from + ' = ' + fk2to1.to,
            hint: '(' + t2 + ' hat FK auf ' + t1 + ')'
        };
    }

    return { main: t1, join: t2, on: '', hint: '(keine FK-Beziehung gefunden)' };
}

function autoDetectJoin() {
    var t1 = gv('wTable1'), t2 = gv('wTable2');
    if (!t1 || !t2) {
        document.getElementById('joinHint').innerHTML = '';
        return;
    }

    var order = getTableOrder(t1, t2);
    document.getElementById('wJoinOn').value = order.on;

    var hint = '<b>Empfohlene Reihenfolge:</b> ' + order.main + ' → ' + order.join + ' ' + order.hint;
    if (order.on) {
        hint += '<br><b>Auto-erkannte Bedingung:</b> ' + order.on;
    }
    document.getElementById('joinHint').innerHTML = hint;
    updateWizardPreview();
}

// History
function showHistory(arr) {
    var h = '';
    arr.forEach(function(sql, i) {
        h += '<div class="history-item" onclick="useHistory(' + i + ')">' + esc(sql) + '</div>';
    });
    document.getElementById('historyBody').innerHTML = h;
    document.getElementById('historyModal').classList.add('open');
    window._histArr = arr;
}

function useHistory(i) {
    document.getElementById('sql').value = window._histArr[i];
    onSQLInput();
    closeHistory();
}

function closeHistory() {
    document.getElementById('historyModal').classList.remove('open');
}

// EXPLAIN
function showExplain(d) {
    var e = document.getElementById('output');
    var h = '<div class="explain-wrap"><h3 style="margin-bottom:12px;color:var(--accent)">EXPLAIN QUERY PLAN</h3>';
    h += '<div class="explain-tree">';
    d.plan.forEach(function(p) {
        h += '<div class="explain-node" style="margin-left:' + (p.id * 20) + 'px">';
        h += '<span class="explain-id">' + p.id + '</span>';
        h += '<span class="explain-detail">' + esc(p.detail) + '</span>';
        h += '</div>';
    });
    h += '</div></div>';
    e.innerHTML = h;
}

// Templates
function showTemplates() {
    var tpls = [
        { n: 'Basic SELECT', sql: "SELECT * FROM table_name WHERE condition LIMIT 100;" },
        { n: 'COUNT rows', sql: "SELECT COUNT(*) AS total FROM table_name;" },
        { n: 'GROUP BY with COUNT', sql: "SELECT column, COUNT(*) AS cnt FROM table_name GROUP BY column ORDER BY cnt DESC;" },
        { n: 'JOIN two tables', sql: "SELECT a.*, b.* FROM table1 a INNER JOIN table2 b ON a.id = b.fk_id;" },
        { n: 'Subquery', sql: "SELECT * FROM table_name WHERE id IN (SELECT fk_id FROM other_table);" },
        { n: 'INSERT row', sql: "INSERT INTO table_name (col1, col2) VALUES ('value1', 'value2');" },
        { n: 'UPDATE row', sql: "UPDATE table_name SET col1 = 'new_value' WHERE id = 1;" },
        { n: 'DELETE row', sql: "DELETE FROM table_name WHERE id = 1;" },
        { n: 'CREATE TABLE', sql: "CREATE TABLE new_table (id INTEGER PRIMARY KEY, name TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);" },
        { n: 'CREATE INDEX', sql: "CREATE INDEX idx_name ON table_name (column);" },
        { n: 'CASE expression', sql: "SELECT name, CASE WHEN status = 1 THEN 'Active' ELSE 'Inactive' END AS status_text FROM table_name;" },
        { n: 'Date functions', sql: "SELECT DATE('now'), TIME('now'), DATETIME('now', '-1 day');" }
    ];

    var h = '<div class="templates-grid">';
    tpls.forEach(function(t, i) {
        h += '<div class="template-item" onclick="useTemplate(' + i + ')">';
        h += '<div class="template-name">' + t.n + '</div>';
        h += '<div class="template-sql">' + esc(t.sql) + '</div>';
        h += '</div>';
    });
    h += '</div>';
    document.getElementById('output').innerHTML = h;
    window._tpls = tpls;
}

function useTemplate(i) {
    document.getElementById('sql').value = window._tpls[i].sql;
    onSQLInput();
}

// Resizing
function startResize(e, side) {
    e.preventDefault();
    resizing = side;
    startX = e.clientX;
    startW = side === 'left'
        ? document.getElementById('sidebar').offsetWidth
        : document.getElementById('infoPanel').offsetWidth;
    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    document.getElementById('resizer' + (side === 'left' ? 'Left' : 'Right')).classList.add('active');
}

function startResizeH(e) {
    e.preventDefault();
    resizing = 'h';
    startX = e.clientY;
    startW = document.querySelector('.editor-wrap').offsetHeight;
    document.body.style.cursor = 'row-resize';
    document.body.style.userSelect = 'none';
    document.getElementById('resizerH').classList.add('active');
}

document.addEventListener('mousemove', function(e) {
    if (!resizing) return;

    if (resizing === 'left') {
        var w = Math.max(180, Math.min(500, startW + (e.clientX - startX)));
        document.documentElement.style.setProperty('--sidebar-w', w + 'px');
    } else if (resizing === 'right') {
        var w = Math.max(200, Math.min(500, startW - (e.clientX - startX)));
        document.documentElement.style.setProperty('--info-w', w + 'px');
    } else if (resizing === 'h') {
        var h = Math.max(100, Math.min(500, startW + (e.clientY - startX)));
        document.documentElement.style.setProperty('--editor-h', h + 'px');
    }
});

document.addEventListener('mouseup', function() {
    if (resizing) {
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
        document.querySelectorAll('.resizer, .h-resizer').forEach(function(r) {
            r.classList.remove('active');
        });
        resizing = null;
    }
});

// Utility
function esc(s) {
    if (s == null) return '';
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function toast(msg) {
    var t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    setTimeout(function() { t.classList.remove('show'); }, 2000);
}

function requestRefresh() {
    toast('Schema wird aktualisiert...');
    pendingAction = 'refresh';
}

// Initialize
onSQLInput();
