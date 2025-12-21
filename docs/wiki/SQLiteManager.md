# SQLiteManager - Showcase Application

SQLite Manager Pro is a full-featured database management application built with the WebView2 UDF, demonstrating advanced integration patterns.

---

## Overview

| Aspect | Details |
|--------|---------|
| **Purpose** | SQLite database management |
| **Technology** | AutoIt3 + WebView2 + SQLite |
| **Lines of Code** | ~1100 (AutoIt) + ~800 (JavaScript) |
| **Features** | Query editor, Schema browser, ERD visualization |

---

## Screenshots

### Main Interface
![Main Interface](https://raw.githubusercontent.com/Ralle1976/Autoit-WebView2-UDF/main/docs/wiki/Bilder/MainInterface.jpg)

*SQLite Manager Pro - Hauptansicht mit Schema-Browser, SQL-Editor und Ergebnisbereich*

### Schema Browser
![Schema Browser](https://raw.githubusercontent.com/Ralle1976/Autoit-WebView2-UDF/main/docs/wiki/Bilder/Schema.jpg)

*Schema-Panel mit Tabellen, Spalten und Datentypen*

### Query Wizard
![Query Wizard](https://raw.githubusercontent.com/Ralle1976/Autoit-WebView2-UDF/main/docs/wiki/Bilder/QuerryWizard.jpg)

*Query Wizard fuer einfache SQL-Erstellung*

### SQL Templates
![Templates](https://raw.githubusercontent.com/Ralle1976/Autoit-WebView2-UDF/main/docs/wiki/Bilder/Templates.jpg)

*Vorgefertigte SQL-Vorlagen fuer haeufige Abfragen*

---

## Features

### SQL Editor
- **Syntax Highlighting**: Keywords, functions, strings, numbers, comments
- **Auto-Completion**: Tables, columns, SQL keywords, functions
- **Line Numbers**: Synchronized scrolling
- **Format Button**: Auto-format SQL for readability
- **History**: Last 50 queries saved

### Schema Browser
- **Table/View List**: Expandable tree view
- **Column Details**: Types, PK, NOT NULL indicators
- **Quick Actions**:
  - SELECT button for instant query
  - Info button for detailed table info
- **Search Filter**: Find tables quickly

### ERD Visualization
- **Mermaid.js Rendering**: Visual database diagrams
- **Relationship Lines**: Foreign key connections
- **Zoom Controls**: +/- and reset
- **Column Details**: PK/FK/NOT NULL markers

### Query Wizard
- **SELECT Builder**: Tables, columns, WHERE, ORDER BY, LIMIT
- **JOIN Builder**: Auto-detect FK relationships
- **INSERT/UPDATE/DELETE**: Form-based query generation

### Result Display
- **Tabular Output**: Sortable, scrollable tables
- **Pagination**: 500 rows per chunk, "Load More" button
- **NULL Styling**: Italicized NULL values
- **Statistics**: Row count, execution time

### Additional Tools
- **EXPLAIN QUERY PLAN**: Query optimization analysis
- **Query Templates**: Common SQL patterns
- **Dark/Light Theme**: Eye-friendly modes

---

## Architecture

### File Structure
```
SQLiteManager/
├── SQLiteManager.au3      # Main application (1107 lines)
├── HANDBUCH.md            # User manual
├── sqlite3.dll            # SQLite library
└── ui/
    ├── template.html      # HTML structure (110 lines)
    ├── styles.css         # Styling (740 lines)
    └── scripts.js         # JavaScript logic (965 lines)
```

### Communication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        AutoIt (Backend)                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ SQLiteManager.au3                                    │   │
│  │ - _DoExecute(): Run SQL, format results              │   │
│  │ - _RefreshSchema(): PRAGMA queries for metadata      │   │
│  │ - _CheckPendingAction(): Poll JS every 100ms         │   │
│  │ - _UpdateJS(): Send data to JavaScript               │   │
│  └─────────────────────────────────────────────────────┘   │
│              │                         ▲                    │
│              │ _WebView2_ExecuteScript │ getPendingAction() │
│              ▼                         │                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ WebView2 (Frontend)                                  │   │
│  │ - setSchema(): Render table tree                     │   │
│  │ - setResults(): Display query results                │   │
│  │ - showERD(): Generate Mermaid diagram                │   │
│  │ - pendingAction: Queue actions for AutoIt            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     sqlite3.dll                              │
│                   (Database Engine)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Implementation Details

### Schema Extraction

```autoit
; Get all tables and views
_SQLite_Query($g_hDB, "SELECT name, type FROM sqlite_master WHERE type IN ('table', 'view')", $hQuery)

; For each table, get columns
_SQLite_Query($g_hDB, "PRAGMA table_info('" & $sTableName & "')", $hColQuery)

; Get foreign keys
_SQLite_Query($g_hDB, "PRAGMA foreign_key_list('" & $sTableName & "')", $hFKQuery)

; Get indexes
_SQLite_Query($g_hDB, "PRAGMA index_list('" & $sTableName & "')", $hIdxQuery)
```

### JSON Data Format

Schema data sent to JavaScript:
```json
{
  "n": "orders",
  "t": "table",
  "cols": [
    {"n": "id", "t": "INTEGER", "pk": 1, "nn": 1},
    {"n": "user_id", "t": "INTEGER", "pk": 0, "nn": 0},
    {"n": "total", "t": "REAL", "pk": 0, "nn": 0}
  ],
  "fk": [
    {"from": "user_id", "to": "users.id"}
  ],
  "idx": [
    {"n": "idx_orders_user", "u": 0}
  ]
}
```

### Pagination System

```autoit
Global Const $CHUNK_SIZE = 500
Global $g_aLastResult[0][0]  ; Cached full result
Global $g_iDisplayed = 0      ; Currently displayed rows

Func _ShowResults($aResult)
    ; Cache full result
    $g_aLastResult = $aResult

    ; Show first chunk
    Local $iEnd = _Min(UBound($aResult) - 1, $CHUNK_SIZE)
    ; ... send to JS with hasMore flag
EndFunc

Func _LoadMoreResults()
    ; Send next chunk from cache
    Local $iStart = $g_iDisplayed
    Local $iEnd = _Min($g_iDisplayed + $CHUNK_SIZE, UBound($g_aLastResult) - 1)
    ; ... append to JS results
EndFunc
```

### ERD Generation (JavaScript)

```javascript
function generateMermaidERD() {
    var lines = ['erDiagram'];

    // Add relationships
    tables.forEach(function(table) {
        table.fk.forEach(function(fk) {
            var parts = fk.to.split('.');
            lines.push('    ' + parts[0] + ' ||--o{ ' + table.n + ' : "' + fk.from + '"');
        });
    });

    // Add table definitions
    tables.forEach(function(table) {
        lines.push('    ' + table.n + ' {');
        table.cols.forEach(function(col) {
            var type = sanitizeType(col.t);
            var markers = col.pk ? ' "PK"' : '';
            lines.push('        ' + type + ' ' + col.n + markers);
        });
        lines.push('    }');
    });

    return lines.join('\n');
}
```

---

## Running SQLiteManager

1. Ensure WebView2 Runtime is installed
2. Place `sqlite3.dll` in the SQLiteManager folder
3. Run:
```batch
"C:\Program Files (x86)\AutoIt3\AutoIt3.exe" SQLiteManager.au3
```

4. Open a SQLite database via File → Open
5. Execute queries with F5

---

## Learn More

- [[JavaScript Communication]] - Communication patterns used
- [[API Reference]] - WebView2 functions used
- [[ERD Visualization]] - ERD implementation details
