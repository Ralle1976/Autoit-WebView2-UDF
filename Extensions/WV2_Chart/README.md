# WV2_Chart Extension

**Chart.js Integration für WebView2 UDF**

Moderne, interaktive Diagramme für AutoIt-Anwendungen mit Chart.js 4.4.1 via WebView2.

---

## Features

- **6 Chart-Typen**: Line, Bar, Pie, Doughnut, Radar, Polar Area
- **Echtzeit-Updates**: Schnelle Datenaktualisierung für Live-Visualisierungen
- **Light/Dark Theme**: Automatische Anpassung an helle und dunkle Modi
- **Event-System**: Click-Events für Interaktivität
- **Responsive Design**: Passt sich an Fenstergröße an
- **Zero Dependencies**: Chart.js wird via CDN geladen - keine lokalen Dateien nötig

---

## Installation

1. Kopiere den `WV2_Chart` Ordner nach `WebView2UDF/Extensions/`
2. Stelle sicher, dass WebView2 Runtime installiert ist
3. Include die Extension in deinem Script:

```autoit
#include "Extensions\WV2_Chart\Include\WV2_Chart.au3"
```

---

## Quick Start

```autoit
#include <GUIConstantsEx.au3>
#include "Extensions\WV2_Chart\Include\WV2_Chart.au3"

$hGUI = GUICreate("Chart Demo", 800, 600)
GUISetState(@SW_SHOW)

; WebView2 mit Chart.js initialisieren
$aWebView = _WV2Chart_Init($hGUI, 10, 10, 780, 580)

; Labels definieren
Local $aLabels[5] = ["Jan", "Feb", "Mar", "Apr", "May"]

; Dataset erstellen (2D-Array)
Local $aDatasets[1][2]
$aDatasets[0][0] = "Sales"  ; Label
Local $aData[5] = [65, 59, 80, 81, 56]
$aDatasets[0][1] = $aData   ; Daten

; Line Chart erstellen
_WV2Chart_Create("chart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)

While GUIGetMsg() <> -3
    Sleep(10)
WEnd
```

---

## API Reference

### Initialisierung

#### `_WV2Chart_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sTheme])`

Initialisiert WebView2 mit Chart.js.

**Parameter:**
- `$hWnd` - Handle des Parent-Fensters
- `$iLeft`, `$iTop`, `$iWidth`, `$iHeight` - Position und Größe
- `$sTheme` - Optional: `"light"` oder `"dark"` (Default: `"light"`)

**Returns:** WebView2 Array oder 0 bei Fehler

---

### Chart-Erstellung

#### `_WV2Chart_Create($sId, $sType, $aLabels, $aDatasets, [$aOptions])`

Erstellt ein neues Chart.

**Parameter:**
- `$sId` - Eindeutige Chart-ID
- `$sType` - Chart-Typ (Konstanten):
  - `$WV2CHART_TYPE_LINE`
  - `$WV2CHART_TYPE_BAR`
  - `$WV2CHART_TYPE_PIE`
  - `$WV2CHART_TYPE_DOUGHNUT`
  - `$WV2CHART_TYPE_RADAR`
  - `$WV2CHART_TYPE_POLAR`
- `$aLabels` - 1D-Array mit X-Achsen-Labels
- `$aDatasets` - 2D-Array: `[n][0]` = Label, `[n][1]` = Daten-Array, `[n][2]` = Farbe (optional)
- `$aOptions` - Optional: JSON-String mit Chart.js Optionen

**Beispiel:**

```autoit
Local $aLabels[3] = ["A", "B", "C"]
Local $aDatasets[2][2]
$aDatasets[0][0] = "Series 1"
$aDatasets[0][1] = [10, 20, 30]
$aDatasets[1][0] = "Series 2"
$aDatasets[1][1] = [15, 25, 35]

_WV2Chart_Create("myChart", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets)
```

---

### Daten-Updates

#### `_WV2Chart_Update($sId, $aLabels, $aDatasets)`

Aktualisiert ein Chart komplett (Labels + alle Datasets).

**Parameter:**
- `$sId` - Chart-ID
- `$aLabels` - Neue Labels
- `$aDatasets` - Neue Datasets

---

#### `_WV2Chart_UpdateDataset($sId, $iDatasetIndex, $aData)`

Aktualisiert nur die Daten eines spezifischen Datasets (schneller für Live-Updates).

**Parameter:**
- `$sId` - Chart-ID
- `$iDatasetIndex` - Index des Datasets (0-basiert)
- `$aData` - Neue Daten

**Beispiel (Echtzeit-Updates):**

```autoit
AdlibRegister(UpdateData, 1000)

Func UpdateData()
    Local $aNewData[5]
    For $i = 0 To 4
        $aNewData[$i] = Random(0, 100, 1)
    Next
    _WV2Chart_UpdateDataset("liveChart", 0, $aNewData)
EndFunc
```

---

### Chart-Verwaltung

#### `_WV2Chart_Destroy($sId)`

Entfernt ein Chart.

#### `_WV2Chart_Clear()`

Entfernt alle Charts.

---

### Theme & Styling

#### `_WV2Chart_SetTheme($sTheme)`

Setzt das Theme (`"light"` oder `"dark"`).

Alle Charts werden automatisch neu gerendert.

---

### Events

#### `_WV2Chart_OnClick($fCallback)`

Registriert einen Callback für Chart-Clicks.

**Callback-Signatur:**

```autoit
Func OnChartClick($sChartId, $iDatasetIndex, $iDataIndex)
    ConsoleWrite("Clicked: " & $sChartId & " - Dataset " & $iDatasetIndex & " - Point " & $iDataIndex & @CRLF)
EndFunc
```

---

## Beispiele

### Multi-Dataset Line Chart

```autoit
Local $aLabels[7] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

Local $aDatasets[3][2]
$aDatasets[0][0] = "Week 1"
$aDatasets[0][1] = [12, 19, 3, 5, 2, 3, 9]
$aDatasets[1][0] = "Week 2"
$aDatasets[1][1] = [5, 10, 15, 20, 25, 30, 35]
$aDatasets[2][0] = "Week 3"
$aDatasets[2][1] = [8, 14, 18, 22, 28, 32, 38]

_WV2Chart_Create("weeklyChart", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)
```

---

### Pie Chart mit Custom Colors

```autoit
Local $aLabels[4] = ["Red", "Blue", "Yellow", "Green"]

Local $aDatasets[1][3]
$aDatasets[0][0] = "Colors"
$aDatasets[0][1] = [300, 50, 100, 75]
$aDatasets[0][2] = "#EF4444"  ; Custom color (optional)

_WV2Chart_Create("colorChart", $WV2CHART_TYPE_PIE, $aLabels, $aDatasets)
```

---

### Custom Chart Options (Advanced)

```autoit
Local $sOptions = '{"responsive":true,"plugins":{"title":{"display":true,"text":"Custom Chart"}}}'
_WV2Chart_Create("customChart", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets, $sOptions)
```

---

## Chart.js Dokumentation

Für erweiterte Konfigurationen siehe: [Chart.js Documentation](https://www.chartjs.org/docs/latest/)

---

## Technische Details

- **Chart.js Version**: 4.4.1 (via CDN)
- **CDN URL**: `https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js`
- **WebView2**: Nutzt bestehende WebView2 Infrastruktur
- **Kommunikation**: JSON-basiertes Command-Protocol

---

## Bekannte Limitierungen

- Benötigt aktive Internetverbindung für Chart.js CDN (beim ersten Laden)
- Browser-Cache wird für Offline-Nutzung verwendet
- Komplexe Chart.js Plugins müssen manuell via `$aOptions` konfiguriert werden

---

## Lizenz

Teil des WebView2 UDF Projekts - Siehe Haupt-Lizenz

---

## Autor

Ralle1976

---

## Version

1.0.0 - Initial Release
