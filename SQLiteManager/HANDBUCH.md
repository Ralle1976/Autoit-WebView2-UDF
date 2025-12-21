# SQLite Manager Pro - Benutzerhandbuch

**Version:** 3.5
**Plattform:** Windows 7/10/11
**Technologie:** AutoIt3 + WebView2

---

## Inhaltsverzeichnis

1. [Uebersicht](#uebersicht)
2. [Installation](#installation)
3. [Benutzeroberflaeche](#benutzeroberflaeche)
4. [Funktionen im Detail](#funktionen-im-detail)
5. [SQL Editor](#sql-editor)
6. [Query Wizard](#query-wizard)
7. [Schema-Visualisierung (ERD)](#schema-visualisierung-erd)
8. [Tastenkuerzel](#tastenkuerzel)
9. [Tipps und Tricks](#tipps-und-tricks)
10. [Fehlerbehebung](#fehlerbehebung)

---

## Uebersicht

SQLite Manager Pro ist ein moderner, leichtgewichtiger Datenbank-Manager fuer SQLite-Datenbanken. Die Anwendung kombiniert die Stabilitaet von AutoIt3 mit der modernen Weboberflaeche von WebView2 (Chromium).

### Hauptmerkmale

| Feature | Beschreibung |
|---------|--------------|
| **Moderner SQL-Editor** | Syntax-Highlighting, Auto-Vervollstaendigung, Zeilennummern |
| **Schema-Browser** | Tabellen, Views, Spalten, Indizes auf einen Blick |
| **ERD-Diagramm** | Visuelle Darstellung der Datenbankstruktur |
| **Query Wizard** | Assistent fuer SELECT, JOIN, INSERT, UPDATE, DELETE |
| **Query Historie** | Die letzten 50 Abfragen gespeichert |
| **EXPLAIN QUERY PLAN** | Ausfuehrungsplan-Analyse |
| **Pagination** | Grosse Ergebnismengen in Chunks laden (500 Zeilen) |
| **Dark/Light Theme** | Augenfreundliche Darstellung |
| **Query Templates** | Vorgefertigte SQL-Vorlagen |

---

## Installation

### Systemvoraussetzungen

- Windows 7 SP1 oder hoeher (Windows 10/11 empfohlen)
- AutoIt v3.3.16.1 oder hoeher
- WebView2 Runtime (auf Windows 10/11 meist vorinstalliert)
- SQLite3.dll (im Lieferumfang enthalten)

### Dateien

```
SQLiteManager/
├── SQLiteManager.au3      # Hauptprogramm
├── HANDBUCH.md            # Diese Dokumentation
├── sqlite3.dll            # SQLite-Bibliothek
└── ui/
    ├── template.html      # HTML-Struktur
    ├── styles.css         # Styling
    └── scripts.js         # JavaScript-Logik
```

### Start

```batch
"C:\Program Files (x86)\AutoIt3\AutoIt3.exe" SQLiteManager.au3
```

Oder als kompilierte EXE:
```batch
SQLiteManager.exe
```

---

## Benutzeroberflaeche

### Layout-Uebersicht

```
┌─────────────────────────────────────────────────────────────────┐
│  Menue: Datei | Bearbeiten | Ansicht | Extras | Hilfe           │
├──────────────┬──────────────────────────────────────────────────┤
│              │  ┌─────────────────────────────────────────────┐ │
│   SCHEMA     │  │ SQL Editor                    [Format][Clear]│ │
│   [ERD][↻]   │  │ SELECT * FROM users LIMIT 100;              │ │
│              │  └─────────────────────────────────────────────┘ │
│ ▶ users      │  ═══════════════════════════════════════════════ │
│   • id       │  ┌─────────────────────────────────────────────┐ │
│   • name     │  │ Ergebnisse                                  │ │
│   • email    │  │ ┌────┬──────────┬─────────────────┐         │ │
│ ▶ orders     │  │ │ id │ name     │ email           │         │ │
│ ▶ products   │  │ ├────┼──────────┼─────────────────┤         │ │
│              │  │ │ 1  │ Max      │ max@example.com │         │ │
│              │  │ │ 2  │ Anna     │ anna@example.com│         │ │
│              │  │ └────┴──────────┴─────────────────┘         │ │
│              │  │ 2 von 2 Zeilen (15 ms)                      │ │
│              │  └─────────────────────────────────────────────┘ │
└──────────────┴──────────────────────────────────────────────────┘
```

### Bereiche

| Bereich | Beschreibung |
|---------|--------------|
| **Schema-Panel (links)** | Zeigt alle Tabellen und Views mit Spalten |
| **SQL-Editor (oben)** | Eingabe von SQL-Befehlen |
| **Ergebnis-Bereich (unten)** | Anzeige der Query-Ergebnisse |
| **Info-Panel (rechts, optional)** | Details zu Tabellen, FKs, Indizes |

### Resizer

Die Bereiche sind durch ziehbare Trennlinien getrennt:
- **Vertikaler Resizer**: Zwischen Schema und Editor
- **Horizontaler Resizer**: Zwischen Editor und Ergebnissen

---

## Funktionen im Detail

### Datei-Menue

| Funktion | Tastenkuerzel | Beschreibung |
|----------|---------------|--------------|
| Neu | Ctrl+N | Neue SQLite-Datenbank erstellen |
| Oeffnen | Ctrl+O | Bestehende Datenbank oeffnen |
| Schliessen | Ctrl+W | Aktuelle Datenbank schliessen |
| Beenden | Alt+F4 | Programm beenden |

### Bearbeiten-Menue

| Funktion | Tastenkuerzel | Beschreibung |
|----------|---------------|--------------|
| Ausfuehren | F5 | SQL-Abfrage ausfuehren |
| Format | Ctrl+Shift+F | SQL formatieren |
| Clear | - | Editor leeren |

### Ansicht-Menue

| Funktion | Beschreibung |
|----------|--------------|
| Schema aktualisieren | Schema-Baum neu laden |
| Dark Theme | Dunkles Farbschema aktivieren |
| Light Theme | Helles Farbschema aktivieren |

### Extras-Menue

| Funktion | Beschreibung |
|----------|--------------|
| Query Wizard | SQL-Assistent oeffnen |
| Query Historie | Letzte 50 Abfragen anzeigen |
| EXPLAIN | Ausfuehrungsplan anzeigen |
| Templates | SQL-Vorlagen anzeigen |
| ERD Diagramm | Schema-Visualisierung oeffnen |

---

## SQL Editor

### Syntax-Highlighting

Der Editor erkennt und faerbt automatisch:

| Element | Farbe | Beispiel |
|---------|-------|----------|
| Keywords | Blau | `SELECT`, `FROM`, `WHERE` |
| Funktionen | Magenta | `COUNT()`, `SUM()`, `AVG()` |
| Strings | Rot | `'Hallo Welt'` |
| Zahlen | Gruen | `42`, `3.14` |
| Kommentare | Gruen (kursiv) | `-- Kommentar` |
| Tabellennamen | Dunkelgruen | `users`, `orders` |

### Auto-Vervollstaendigung

Waehrend der Eingabe erscheinen Vorschlaege:

- **Keywords**: SQL-Schluesselwoerter
- **Funktionen**: SQLite-Funktionen
- **Tabellen**: Alle Tabellen der Datenbank
- **Spalten**: Spalten mit Tabellenkontext

**Navigation:**
- `↑` / `↓`: Vorschlag auswaehlen
- `Tab` / `Enter`: Vorschlag uebernehmen
- `Esc`: Vorschlaege schliessen

### Zeilennummern

Links neben dem Editor werden Zeilennummern angezeigt. Diese scrollen synchron mit dem Code.

### Format-Funktion

Der "Format"-Button formatiert SQL fuer bessere Lesbarkeit:

**Vorher:**
```sql
SELECT * FROM users WHERE active=1 ORDER BY name LIMIT 100
```

**Nachher:**
```sql
SELECT *
FROM users
WHERE active=1
ORDER BY name
LIMIT 100
```

---

## Query Wizard

Der Query Wizard hilft beim Erstellen von SQL-Abfragen ohne manuelle Eingabe.

### SELECT-Wizard

| Feld | Beschreibung |
|------|--------------|
| Tabelle | Zu selektierende Tabelle |
| Spalten | `*` fuer alle oder kommagetrennte Liste |
| WHERE | Bedingung (z.B. `id > 10`) |
| ORDER BY | Sortierung (z.B. `name ASC`) |
| LIMIT | Maximale Anzahl Zeilen |
| OFFSET | Zeilen ueberspringen |

### JOIN-Wizard

| Feld | Beschreibung |
|------|--------------|
| Tabelle 1 | Erste Tabelle |
| Tabelle 2 | Zweite Tabelle |
| JOIN Typ | INNER, LEFT, RIGHT, CROSS |
| ON | Join-Bedingung (wird automatisch erkannt bei FK) |
| Spalten | Zu selektierende Spalten |

**Automatische FK-Erkennung:**
Wenn zwischen den Tabellen eine Foreign-Key-Beziehung existiert, wird die ON-Bedingung automatisch ausgefuellt.

### INSERT-Wizard

| Feld | Beschreibung |
|------|--------------|
| Tabelle | Zieltabelle |
| Spalten | Wird automatisch ausgefuellt |
| Werte | Kommagetrennte Werte in Klammern |

### UPDATE-Wizard

| Feld | Beschreibung |
|------|--------------|
| Tabelle | Zu aktualisierende Tabelle |
| SET | Spaltenzuweisungen (z.B. `name = 'Neu'`) |
| WHERE | Bedingung (WICHTIG!) |

### DELETE-Wizard

| Feld | Beschreibung |
|------|--------------|
| Tabelle | Tabelle zum Loeschen |
| WHERE | Bedingung (PFLICHT!) |

**Warnung:** DELETE ohne WHERE loescht ALLE Zeilen!

---

## Schema-Visualisierung (ERD)

Das ERD-Diagramm (Entity-Relationship-Diagram) zeigt die Datenbankstruktur visuell.

### Oeffnen

- Klick auf das ERD-Symbol (⬛) im Schema-Header
- Oder: Menue → Extras → ERD Diagramm

### Darstellung

```
┌─────────────────┐         ┌─────────────────┐
│     users       │         │     orders      │
├─────────────────┤         ├─────────────────┤
│ int id "PK"     │◄────────│ int id "PK"     │
│ string name     │         │ int user_id "FK"│
│ string email    │         │ decimal total   │
│ datetime created│         │ datetime date   │
└─────────────────┘         └─────────────────┘
```

### Legende

| Symbol | Bedeutung |
|--------|-----------|
| **PK** | Primary Key |
| **FK** | Foreign Key |
| **NOT NULL** | Pflichtfeld |
| `──────►` | Beziehung (FK zeigt auf PK) |

### Steuerung

| Button | Funktion |
|--------|----------|
| **+** | Hineinzoomen |
| **-** | Herauszoomen |
| **↺** | Zoom zuruecksetzen |

### Unterstuetzte Datentypen

| SQLite-Typ | ERD-Darstellung |
|------------|-----------------|
| INTEGER | int |
| TEXT, VARCHAR | string |
| REAL, FLOAT | float |
| BLOB | blob |
| DATETIME | datetime |
| BOOLEAN | bool |

---

## Tastenkuerzel

### Allgemein

| Tastenkuerzel | Funktion |
|---------------|----------|
| F5 | Query ausfuehren |
| Ctrl+N | Neue Datenbank |
| Ctrl+O | Datenbank oeffnen |
| Ctrl+W | Datenbank schliessen |
| Ctrl+Shift+F | SQL formatieren |
| Esc | Dialog/Modal schliessen |

### Editor

| Tastenkuerzel | Funktion |
|---------------|----------|
| Tab | Auto-Vervollstaendigung uebernehmen |
| Enter | Auto-Vervollstaendigung uebernehmen |
| ↑ / ↓ | Vorschlag navigieren |
| Esc | Vorschlaege schliessen |

---

## Tipps und Tricks

### 1. Schnelle Tabellen-Abfrage

Klicken Sie im Schema-Panel auf den "SELECT"-Button einer Tabelle, um automatisch `SELECT * FROM tabelle LIMIT 100;` einzufuegen.

### 2. Spalten einfuegen

Klicken Sie auf einen Spaltennamen im Schema-Panel, um ihn an der Cursorposition einzufuegen.

### 3. Grosse Ergebnismengen

Bei mehr als 500 Zeilen wird ein "Weitere laden"-Button angezeigt. So bleibt die Anwendung performant.

### 4. Tabellen-Info

Der "Info"-Button zeigt detaillierte Informationen:
- Alle Spalten mit Typen
- Primary Keys
- Foreign Keys
- Indizes

### 5. EXPLAIN QUERY PLAN

Nutzen Sie EXPLAIN, um langsame Queries zu analysieren:
- Welche Indizes werden verwendet?
- Wird ein Table Scan durchgefuehrt?
- Wie ist die Ausfuehrungsreihenfolge?

### 6. Query Historie

Die letzten 50 Abfragen werden gespeichert. Klicken Sie auf eine, um sie wiederzuverwenden.

### 7. Theme wechseln

Dark Theme ist standardmaessig aktiv. Wechseln Sie zu Light Theme fuer helle Umgebungen.

---

## Fehlerbehebung

### Problem: "Datenbank kann nicht geoeffnet werden"

**Ursachen:**
- Datei existiert nicht
- Keine Leserechte
- Datei ist keine SQLite-Datenbank

**Loesung:**
- Pfad ueberpruefen
- Rechte pruefen
- Mit `file` oder HEX-Editor pruefen ob SQLite-Header vorhanden

### Problem: "Query-Fehler"

**Ursachen:**
- SQL-Syntaxfehler
- Tabelle/Spalte existiert nicht
- Typfehler

**Loesung:**
- Fehlermeldung lesen (rot markiert)
- Schema-Panel auf korrekte Namen pruefen
- SQL-Syntax ueberpruefen

### Problem: "ERD wird nicht angezeigt"

**Ursachen:**
- Keine Datenbank geoeffnet
- Keine Tabellen vorhanden
- Mermaid.js konnte nicht geladen werden (offline)

**Loesung:**
- Datenbank oeffnen
- Internetverbindung pruefen (fuer CDN)

### Problem: "Anwendung reagiert nicht"

**Ursachen:**
- Sehr grosse Abfrage
- Endlosschleife in Query

**Loesung:**
- LIMIT verwenden
- Query abbrechen (Anwendung neu starten)

### Problem: "Auto-Vervollstaendigung funktioniert nicht"

**Ursachen:**
- Keine Datenbank geoeffnet
- Zu wenig Zeichen eingegeben

**Loesung:**
- Mindestens 1 Zeichen eingeben
- Schema aktualisieren (↻)

---

## Technische Details

### Architektur

```
┌─────────────────┐     ┌─────────────────┐
│   AutoIt3       │◄───►│   WebView2      │
│  (Backend)      │     │  (Frontend)     │
├─────────────────┤     ├─────────────────┤
│ - SQLite-Zugriff│     │ - HTML/CSS/JS   │
│ - Dateisystem   │     │ - UI-Rendering  │
│ - Windows-GUI   │     │ - Mermaid.js    │
└─────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│   sqlite3.dll   │
│  (Datenbank)    │
└─────────────────┘
```

### Kommunikation

Die Kommunikation zwischen AutoIt und WebView2 erfolgt ueber Polling:

1. **JavaScript → AutoIt**:
   - JS setzt `pendingAction`
   - AutoIt pollt alle 100ms via `getPendingAction()`

2. **AutoIt → JavaScript**:
   - Direkter Funktionsaufruf via `_WebView2_ExecuteScript()`

### Pagination

Grosse Ergebnismengen werden in Chunks von 500 Zeilen geladen:
- Erste 500 Zeilen sofort
- "Weitere laden"-Button fuer naechsten Chunk
- Gesamtanzahl wird angezeigt

---

## Versionshistorie

| Version | Datum | Aenderungen |
|---------|-------|-------------|
| 3.5 | 2024-12 | ERD-Diagramm hinzugefuegt |
| 3.4 | 2024-11 | Pagination-System |
| 3.3 | 2024-10 | Query Wizard |
| 3.2 | 2024-09 | Auto-Vervollstaendigung |
| 3.1 | 2024-08 | Dark/Light Theme |
| 3.0 | 2024-07 | WebView2-Migration |

---

## Lizenz

MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files.

---

*SQLite Manager Pro - Entwickelt mit AutoIt3 und WebView2*
