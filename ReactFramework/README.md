# WV2React Framework

Ein modulares AutoIt-WebView2 Hybrid-Framework mit modernen UI-Komponenten und Dual-Mode Rendering.

## Uebersicht

WV2React ermoeglicht die Erstellung moderner Web-basierter Benutzeroberflaechen in AutoIt-Anwendungen unter Verwendung von WebView2 und Tailwind CSS.

### Features

- **27 UI-Komponenten** - Buttons, Inputs, Modals, Toasts, Charts und mehr
- **Dual-Mode Rendering** - Waehlbar zwischen DOM API und React 18
- **Theming** - Light/Dark Mode mit anpassbarer Primaerfarbe
- **Event-System** - Bidirektionale Kommunikation zwischen AutoIt und JavaScript
- **Grid-Komponente** - Sortierung, Filterung, Paginierung
- **Map-Komponente** - Leaflet.js Integration mit Markern

## Render-Modi

Das Framework unterstuetzt zwei Rendering-Engines:

| Modus | Beschreibung | Vorteile |
|-------|--------------|----------|
| **dom** (Standard) | Vanilla JavaScript mit DOM API | 0 KB Overhead, schnellerer Load |
| **react** | React 18 mit Virtual DOM | Deklarativ, effiziente Updates |

### Wann welchen Modus verwenden?

- **DOM-Modus**: Einfache UIs, Performance-kritische Anwendungen, wenige dynamische Updates
- **React-Modus**: Komplexe UIs, viele dynamische Updates, deklarative Programmierung bevorzugt

## Verzeichnisstruktur

```
ReactFramework/
├── Include/
│   ├── WV2React_Core.au3      ; Kern-Framework mit Mode-Switch
│   ├── WV2React_Grid.au3      ; Grid-Erweiterung
│   ├── WV2React_Map.au3       ; Map-Erweiterung
│   ├── WV2React_UI.au3        ; UI-Komponenten-Wrapper
│   └── js/
│       ├── dom/               ; DOM API Komponenten
│       │   ├── all-components.js
│       │   └── components/
│       └── react/             ; React Komponenten
│           ├── all-components.js
│           └── components/
├── Examples/
│   ├── ReactFramework_Showcase.au3  ; Vollstaendige Demo
│   ├── StandortManager.au3          ; Praxis-Beispiel
│   ├── showcase.js                  ; JavaScript fuer Showcase
│   └── WebView2*.dll                ; Erforderliche DLLs
└── README.md
```

## Installation

1. **Voraussetzungen**
   - AutoIt 3.3.16+
   - WebView2 Runtime (automatisch mit Edge installiert)
   - Windows 10/11

2. **Framework einbinden**
   ```autoit
   #include "ReactFramework\Include\WV2React_Core.au3"
   ```

3. **DLLs kopieren**
   Kopieren Sie die 4 WebView2-DLLs in Ihr Skript-Verzeichnis:
   - `WebView2Loader_x64.dll`
   - `WebView2Loader_x86.dll`
   - `WebView2Helper_x64.dll`
   - `WebView2Helper_x86.dll`

## Schnellstart

```autoit
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include "ReactFramework\Include\WV2React_Core.au3"

; GUI erstellen
Local $hGUI = GUICreate("Meine App", 800, 600)
GUISetState(@SW_SHOW)

; WebView2 initialisieren
; Parameter: $hGUI, $x, $y, $w, $h, $sTheme, $sColor, $sRenderMode
; $sRenderMode: "dom" (Standard) oder "react"
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "dom")

; Event-Handler registrieren
_WV2React_OnEvent(_MeinEventHandler)

; Komponente erstellen
Local $aOptions[2] = ["text", "Klick mich!"]
_WV2React_CreateComponent("btn1", "WV2Button", $aOptions)

; Hauptschleife mit Message-Pump
Local $tMSG = DllStructCreate("hwnd;uint;wparam;lparam;dword;int[2]")
While True
    If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop

    ; KRITISCH: Windows Messages verarbeiten
    While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
        DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
        DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
    WEnd

    _WV2React_ProcessEvents()
    Sleep(10)
WEnd

_WebView2_Close($oWebView)

Func _MeinEventHandler($sType, $sId, $sData)
    ConsoleWrite("Event: " & $sType & " von " & $sId & @CRLF)
EndFunc
```

## API-Referenz

### Core-Funktionen

| Funktion | Beschreibung |
|----------|--------------|
| `_WV2React_Init($hGUI, $x, $y, $w, $h, $sTheme, $sColor, $sRenderMode)` | Framework initialisieren |
| `_WV2React_SetTheme($sTheme)` | Theme wechseln ("light"/"dark") |
| `_WV2React_SetPrimaryColor($sColor)` | Primaerfarbe setzen (Hex) |
| `_WV2React_CreateComponent($sId, $sType, $aOptions)` | Komponente erstellen |
| `_WV2React_UpdateComponent($sId, $aProps)` | Komponente aktualisieren |
| `_WV2React_DestroyComponent($sId)` | Komponente entfernen |
| `_WV2React_GetComponentState($sId)` | Status abfragen |
| `_WV2React_OnEvent($funcCallback)` | Event-Handler registrieren |
| `_WV2React_ProcessEvents()` | Events verarbeiten |

### Neuer Parameter: $sRenderMode

```autoit
; DOM-Modus (Standard) - Schnell, 0 KB Overhead
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "dom")

; React-Modus - Virtual DOM, deklarativ
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "react")
```

### Grid-Funktionen

| Funktion | Beschreibung |
|----------|--------------|
| `_WV2React_CreateGrid($sId, $aColumns, $aData)` | Grid erstellen |
| `_WV2React_CreateGridFromArray($sId, $aData)` | Grid aus 2D-Array |
| `_WV2React_UpdateGridData($sId, $aData)` | Daten aktualisieren |
| `_WV2React_GetGridSelection($sId)` | Auswahl abrufen |
| `_WV2React_SetGridFilter($sId, $sFilter)` | Filter setzen |
| `_WV2React_SortGrid($sId, $sColumn, $sDir)` | Sortierung |

### Map-Funktionen

| Funktion | Beschreibung |
|----------|--------------|
| `_WV2React_CreateMap($sId, $fLat, $fLng, $iZoom)` | Karte erstellen |
| `_WV2React_AddMapMarker($sMapId, $sMkrId, $fLat, $fLng, $sTitle)` | Marker hinzufuegen |
| `_WV2React_RemoveMapMarker($sMapId, $sMkrId)` | Marker entfernen |
| `_WV2React_SetMapCenter($sId, $fLat, $fLng)` | Zentrum setzen |
| `_WV2React_ClearMapMarkers($sId)` | Alle Marker loeschen |

## Verfuegbare Komponenten

### Basis-Eingabe (7)
- WV2Button, WV2Input, WV2Textarea, WV2Checkbox, WV2Radio, WV2Switch, WV2Select

### Erweiterte Eingabe (5)
- WV2DatePicker, WV2TimePicker, WV2ColorPicker, WV2Slider, WV2FileUpload

### Navigation (4)
- WV2Tabs, WV2Breadcrumb, WV2Pagination, WV2Stepper

### Feedback (5)
- WV2Alert, WV2Progress, WV2Spinner, WV2Toast, WV2Modal

### Anzeige & Layout (6)
- WV2Badge, WV2Avatar, WV2Tag, WV2Divider, WV2StatCard, WV2Accordion

### Spezial
- WV2Grid, WV2Map, WV2Chart, WV2TreeView

## Wichtige Hinweise

### Message-Pump erforderlich

WebView2 benoetigt eine korrekte Windows Message-Verarbeitung. Ohne die PeekMessageW-Schleife funktionieren Maus- und Tastatur-Events nicht!

### DLLs erforderlich

Alle 4 WebView2-DLLs muessen im gleichen Verzeichnis wie das AutoIt-Skript liegen.

### Theming

Das Framework unterstuetzt Light/Dark Mode und eine anpassbare Primaerfarbe:

```autoit
_WV2React_SetTheme("dark")
_WV2React_SetPrimaryColor("#10B981")  ; Gruen
```

## Beispiele

### Showcase starten
```
ReactFramework\Examples\ReactFramework_Showcase.au3
```
Startet im Vollbildmodus. Beenden mit ESC oder ueber das Menue.

### StandortManager
```
ReactFramework\Examples\StandortManager.au3
```
Praxis-Beispiel mit Grid und Map-Komponenten.

## Lizenz

MIT License - Freie Verwendung in privaten und kommerziellen Projekten.

## Autor

Ralle1976
