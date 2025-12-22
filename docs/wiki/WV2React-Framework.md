# WV2React Framework

Das WV2React Framework ist eine Erweiterung fuer die WebView2 UDF, die moderne UI-Komponenten und ein React-inspiriertes Programmiermodell bereitstellt.

## Ueberblick

WV2React ermoeglicht die Erstellung moderner Web-basierter Benutzeroberflaechen in AutoIt-Anwendungen. Das Framework bietet:

- **27 vorgefertigte UI-Komponenten**
- **Light/Dark Mode Theming**
- **Bidirektionales Event-System**
- **Grid mit Sortierung, Filterung, Paginierung**
- **Leaflet.js Kartenintegration**

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
; Parameter: $hGUI, $x, $y, $width, $height, $theme, $primaryColor
Local $oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6")
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

## API-Referenz

### Core-Funktionen

#### _WV2React_Init
Initialisiert das Framework.

```autoit
$oWebView = _WV2React_Init($hGUI, $iX, $iY, $iWidth, $iHeight, $sTheme = "light", $sPrimaryColor = "#3B82F6")
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| $hGUI | Handle | GUI-Handle |
| $iX, $iY | Integer | Position |
| $iWidth, $iHeight | Integer | Groesse |
| $sTheme | String | "light" oder "dark" |
| $sPrimaryColor | String | Hex-Farbe (z.B. "#3B82F6") |

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

### Basis-Eingabe

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Button | Schaltflaeche | text, variant, disabled |
| WV2Input | Textfeld | placeholder, value, type |
| WV2Textarea | Mehrzeiliges Textfeld | placeholder, rows |
| WV2Checkbox | Ankreuzfeld | label, checked |
| WV2Radio | Auswahlfeld | name, options, selected |
| WV2Switch | Toggle-Schalter | label, checked |
| WV2Select | Dropdown | options, selected |

### Erweiterte Eingabe

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2DatePicker | Datumsauswahl | value, min, max |
| WV2TimePicker | Zeitauswahl | value |
| WV2ColorPicker | Farbauswahl | value |
| WV2Slider | Schieberegler | min, max, value, step |
| WV2FileUpload | Datei-Upload | accept, multiple |

### Navigation

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Tabs | Tab-Navigation | tabs, active |
| WV2Breadcrumb | Brotkrumen-Navigation | items |
| WV2Pagination | Seitennavigation | total, current, perPage |
| WV2Stepper | Schritt-Anzeige | steps, current |

### Feedback

| Komponente | Beschreibung | Optionen |
|------------|--------------|----------|
| WV2Alert | Hinweismeldung | type, message |
| WV2Progress | Fortschrittsbalken | value, max |
| WV2Spinner | Ladeanimation | size |
| WV2Toast | Benachrichtigung | message, type, duration |
| WV2Modal | Dialog-Fenster | title, content |

### Anzeige

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
