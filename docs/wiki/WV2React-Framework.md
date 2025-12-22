# WV2React Framework

Das WV2React Framework ist eine Erweiterung fuer die WebView2 UDF, die moderne UI-Komponenten und ein React-inspiriertes Programmiermodell bereitstellt.

## Ueberblick

WV2React ermoeglicht die Erstellung moderner Web-basierter Benutzeroberflaechen in AutoIt-Anwendungen. Das Framework bietet:

- **27 vorgefertigte UI-Komponenten**
- **Dual-Mode Rendering** (DOM API oder React 18)
- **Light/Dark Mode Theming**
- **Bidirektionales Event-System**
- **Grid mit Sortierung, Filterung, Paginierung**
- **Leaflet.js Kartenintegration**

## Render-Modi

Das Framework unterstuetzt zwei Rendering-Engines:

| Modus | Beschreibung | Vorteile |
|-------|--------------|----------|
| **dom** (Standard) | Vanilla JavaScript mit DOM API | 0 KB Overhead, schnellerer Load |
| **react** | React 18 mit Virtual DOM | Deklarativ, effiziente Updates |

### Wann welchen Modus verwenden?

- **DOM-Modus**: Einfache UIs, Performance-kritische Anwendungen, wenige dynamische Updates
- **React-Modus**: Komplexe UIs, viele dynamische Updates, deklarative Programmierung bevorzugt

## Installation

### 1. Framework kopieren

Kopieren Sie den `ReactFramework` Ordner in Ihr Projekt:

```
MeinProjekt/
├── MeinScript.au3
└── ReactFramework/
    ├── Include/
    │   ├── WV2React_Core.au3
    │   ├── WV2React_Grid.au3
    │   ├── WV2React_Map.au3
    │   └── js/
    │       ├── dom/           ; DOM API Komponenten
    │       └── react/         ; React Komponenten
    └── Examples/
```

### 2. DLLs kopieren

Kopieren Sie die 4 WebView2-DLLs aus dem `bin/` Verzeichnis in Ihr Skript-Verzeichnis:

- `WebView2Loader_x64.dll`
- `WebView2Loader_x86.dll`
- `WebView2Helper_x64.dll`
- `WebView2Helper_x86.dll`

### 3. Framework einbinden

```autoit
#include "ReactFramework\Include\WV2React_Core.au3"
```

## Grundlegende Verwendung

### Minimales Beispiel

```autoit
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include "ReactFramework\Include\WV2React_Core.au3"

; GUI erstellen
Local $hGUI = GUICreate("WV2React Demo", 800, 600)
GUISetState(@SW_SHOW)

; Framework initialisieren
; Parameter: $hGUI, $x, $y, $width, $height, $theme, $primaryColor, $renderMode
; $renderMode: "dom" (Standard, 0 KB Overhead) oder "react" (React 18)
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "dom")
If @error Then Exit MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden")

; Event-Handler registrieren
_WV2React_OnEvent(_OnComponentEvent)

; Button erstellen
Local $aOptions[2] = ["text", "Klick mich!"]
_WV2React_CreateComponent("myButton", "WV2Button", $aOptions)

; Hauptschleife (WICHTIG: Mit Message-Pump!)
Local $tMSG = DllStructCreate("hwnd;uint;wparam;lparam;dword;int[2]")
While True
    If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop

    ; Windows Messages verarbeiten (KRITISCH fuer WebView2!)
    While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
        DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
        DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
    WEnd

    _WV2React_ProcessEvents()
    Sleep(10)
WEnd

_WebView2_Close($oWebView)

Func _OnComponentEvent($sType, $sComponentId, $sData)
    ConsoleWrite("Event: " & $sType & " von " & $sComponentId & @CRLF)
EndFunc
```

### React-Modus aktivieren

```autoit
; React-Modus - laedt React 18 CDN (~130 KB)
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "react")
```

## API-Referenz

### Core-Funktionen

#### _WV2React_Init
Initialisiert das Framework.

```autoit
$oWebView = _WV2React_Init($hGUI, $iX, $iY, $iWidth, $iHeight, $sTheme = "light", $sPrimaryColor = "#3B82F6", $sRenderMode = "dom")
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| $hGUI | Handle | GUI-Handle |
| $iX, $iY | Integer | Position |
| $iWidth, $iHeight | Integer | Groesse |
| $sTheme | String | "light" oder "dark" |
| $sPrimaryColor | String | Hex-Farbe (z.B. "#3B82F6") |
| $sRenderMode | String | "dom" (Standard) oder "react" |

#### _WV2React_CreateComponent
Erstellt eine UI-Komponente.

```autoit
_WV2React_CreateComponent($sId, $sType, $aOptions)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| $sId | String | Eindeutige ID |
| $sType | String | Komponententyp (z.B. "WV2Button") |
| $aOptions | Array | Key-Value Paare fuer Optionen |

#### _WV2React_UpdateComponent
Aktualisiert eine Komponente.

```autoit
_WV2React_UpdateComponent($sId, $aProperties)
```

#### _WV2React_DestroyComponent
Entfernt eine Komponente.

```autoit
_WV2React_DestroyComponent($sId)
```

#### _WV2React_SetTheme
Wechselt zwischen Light und Dark Mode.

```autoit
_WV2React_SetTheme("dark")  ; oder "light"
```

#### _WV2React_SetPrimaryColor
Setzt die Primaerfarbe fuer alle Komponenten.

```autoit
_WV2React_SetPrimaryColor("#10B981")  ; Gruen
```

## Verfuegbare Komponenten

### Basis-Eingabe (7)

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Button | Schaltflaeche | text, variant, disabled |
| WV2Input | Textfeld | placeholder, value, type |
| WV2Textarea | Mehrzeiliges Textfeld | placeholder, rows |
| WV2Checkbox | Ankreuzfeld | label, checked |
| WV2Radio | Auswahlfeld | name, options, selected |
| WV2Switch | Toggle-Schalter | label, checked |
| WV2Select | Dropdown | options, selected |

### Erweiterte Eingabe (5)

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2DatePicker | Datumsauswahl | value, min, max |
| WV2TimePicker | Zeitauswahl | value |
| WV2ColorPicker | Farbauswahl | value |
| WV2Slider | Schieberegler | min, max, value, step |
| WV2FileUpload | Datei-Upload | accept, multiple |

### Navigation (4)

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Tabs | Tab-Navigation | tabs, active |
| WV2Breadcrumb | Brotkrumen-Navigation | items |
| WV2Pagination | Seitennavigation | total, current, perPage |
| WV2Stepper | Schritt-Anzeige | steps, current |

### Feedback (5)

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Alert | Hinweismeldung | type, message |
| WV2Progress | Fortschrittsbalken | value, max |
| WV2Spinner | Ladeanimation | size |
| WV2Toast | Benachrichtigung | message, type, duration |
| WV2Modal | Dialog-Fenster | title, content |

### Anzeige (6)

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Badge | Kennzeichnung | text, variant |
| WV2Avatar | Benutzer-Avatar | initials, size |
| WV2Tag | Entfernbares Tag | text |
| WV2Divider | Trennlinie | text |
| WV2StatCard | Statistik-Karte | title, value, change |
| WV2Accordion | Aufklappbereich | items |

### Spezial

| Komponente | Beschreibung |
|------------|--------------|
| WV2Grid | Daten-Tabelle mit Sortierung/Filterung |
| WV2Map | Leaflet.js Karte |
| WV2Chart | Chart.js Diagramme |
| WV2TreeView | Baumansicht |

## Grid-Komponente

Die Grid-Komponente bietet erweiterte Funktionen fuer tabellarische Daten.

### Grid erstellen

```autoit
#include "ReactFramework\Include\WV2React_Grid.au3"

; Spalten definieren
Local $aColumns[3][2] = [ _
    ["id", "ID"], _
    ["name", "Name"], _
    ["email", "E-Mail"] _
]

; Daten
Local $aData[2][3] = [ _
    [1, "Max Mustermann", "max@example.com"], _
    [2, "Anna Schmidt", "anna@example.com"] _
]

; Grid erstellen
_WV2React_CreateGrid("myGrid", $aColumns, $aData)
```

### Grid-Funktionen

```autoit
; Daten aktualisieren
_WV2React_UpdateGridData("myGrid", $aNewData)

; Auswahl abrufen
Local $aSelection = _WV2React_GetGridSelection("myGrid")

; Filtern
_WV2React_SetGridFilter("myGrid", "Suchbegriff")

; Sortieren
_WV2React_SortGrid("myGrid", "name", "asc")
```

## Map-Komponente

Integration von Leaflet.js fuer interaktive Karten.

### Karte erstellen

```autoit
#include "ReactFramework\Include\WV2React_Map.au3"

; Karte erstellen (Berlin, Zoom 12)
_WV2React_CreateMap("myMap", 52.52, 13.405, 12)

; Marker hinzufuegen
_WV2React_AddMapMarker("myMap", "marker1", 52.52, 13.405, "Berlin")

; Marker entfernen
_WV2React_RemoveMapMarker("myMap", "marker1")

; Alle Marker loeschen
_WV2React_ClearMapMarkers("myMap")

; Kartenzentrum setzen
_WV2React_SetMapCenter("myMap", 48.137, 11.576)  ; Muenchen
```

## Theming

### Theme wechseln

```autoit
; Dark Mode aktivieren
_WV2React_SetTheme("dark")

; Light Mode aktivieren
_WV2React_SetTheme("light")
```

### Primaerfarbe aendern

```autoit
; Blau (Standard)
_WV2React_SetPrimaryColor("#3B82F6")

; Gruen
_WV2React_SetPrimaryColor("#10B981")

; Rot
_WV2React_SetPrimaryColor("#EF4444")

; Lila
_WV2React_SetPrimaryColor("#8B5CF6")
```

## Event-Handling

### Event-Handler registrieren

```autoit
_WV2React_OnEvent(_MeinEventHandler)

Func _MeinEventHandler($sEventType, $sComponentId, $sData)
    Switch $sEventType
        Case "click"
            ConsoleWrite("Klick auf: " & $sComponentId & @CRLF)
        Case "change"
            ConsoleWrite("Aenderung: " & $sData & @CRLF)
        Case "select"
            ConsoleWrite("Auswahl: " & $sData & @CRLF)
    EndSwitch
EndFunc
```

### Verfuegbare Events

| Event | Beschreibung | Komponenten |
|-------|--------------|-------------|
| click | Klick-Ereignis | Button, Badge, etc. |
| change | Wert geaendert | Input, Select, Checkbox, etc. |
| select | Element ausgewaehlt | Grid, Tabs |
| submit | Formular abgesendet | Form |
| close | Geschlossen | Modal, Toast |

## Technische Details

### Architektur

```
┌─────────────────────────────────────────────────────────────────┐
│                    AutoIt Anwendung                             │
├─────────────────────────────────────────────────────────────────┤
│                    WV2React_Core.au3                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ _WV2React_Init($renderMode = "dom" | "react")           │    │
│  └─────────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                    WebView2                                      │
│  ┌─────────────────────┐  ┌─────────────────────────────────┐   │
│  │ DOM-Modus           │  │ React-Modus                     │   │
│  │ js/dom/             │  │ js/react/                       │   │
│  │ - Vanilla JS        │  │ - React 18 CDN                  │   │
│  │ - 0 KB Overhead     │  │ - React.createElement()         │   │
│  │ - document.create() │  │ - Virtual DOM                   │   │
│  └─────────────────────┘  └─────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                    Tailwind CSS (CDN)                            │
└─────────────────────────────────────────────────────────────────┘
```

### Komponenten-Ordnerstruktur

```
Include/js/
├── dom/                    ; DOM API Variante (Standard)
│   ├── all-components.js   ; Alle Komponenten gebundelt
│   └── components/         ; Einzelne Komponenten-Dateien
└── react/                  ; React Variante
    ├── all-components.js   ; React.createElement() Komponenten
    └── components/         ; Einzelne Komponenten-Dateien
```

## Wichtige Hinweise

### Message-Pump erforderlich

WebView2 benoetigt eine korrekte Windows Message-Verarbeitung. Ohne die `PeekMessageW`-Schleife funktionieren Maus- und Tastatur-Events nicht!

```autoit
Local $tMSG = DllStructCreate("hwnd;uint;wparam;lparam;dword;int[2]")
While True
    ; GUI-Events
    If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop

    ; KRITISCH: Windows Messages verarbeiten
    While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
        DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
        DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
    WEnd

    _WV2React_ProcessEvents()
    Sleep(10)
WEnd
```

### DLLs erforderlich

Alle 4 WebView2-DLLs muessen im Skript-Verzeichnis vorhanden sein:

- `WebView2Loader_x64.dll`
- `WebView2Loader_x86.dll`
- `WebView2Helper_x64.dll`
- `WebView2Helper_x86.dll`

## Beispiele

### Showcase

Die vollstaendige Showcase-Demo zeigt alle 27 Komponenten:

```
ReactFramework\Examples\ReactFramework_Showcase.au3
```

Startet im Vollbildmodus. Beenden mit ESC oder ueber das Menue.

### StandortManager

Ein Praxis-Beispiel mit Grid und Map:

```
ReactFramework\Examples\StandortManager.au3
```

## Siehe auch

- [[API Reference]]
- [[JavaScript Communication]]
- [[Examples]]
