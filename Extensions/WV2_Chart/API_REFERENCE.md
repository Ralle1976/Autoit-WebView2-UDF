# WV2_Chart API Reference

Vollständige API-Dokumentation für die WV2_Chart Extension.

---

## Konstanten

### Chart-Typen

```autoit
$WV2CHART_TYPE_LINE      = "line"
$WV2CHART_TYPE_BAR       = "bar"
$WV2CHART_TYPE_PIE       = "pie"
$WV2CHART_TYPE_DOUGHNUT  = "doughnut"
$WV2CHART_TYPE_RADAR     = "radar"
$WV2CHART_TYPE_POLAR     = "polarArea"
```

### Themes

```autoit
$WV2CHART_THEME_LIGHT = "light"
$WV2CHART_THEME_DARK  = "dark"
```

---

## Funktionen

### Initialisierung

#### `_WV2Chart_Init`

```autoit
_WV2Chart_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sTheme = "light"])
```

Initialisiert WebView2 mit Chart.js CDN.

**Parameter:**
- `$hWnd` (handle) - Handle des Parent-Fensters
- `$iLeft` (int) - X-Position
- `$iTop` (int) - Y-Position
- `$iWidth` (int) - Breite
- `$iHeight` (int) - Höhe
- `$sTheme` (string, optional) - Theme: `"light"` oder `"dark"` (Default: `"light"`)

**Returns:**
- Success: WebView2 Array `[Environment, Controller, WebView2, Settings]`
- Failure: `0` und setzt `@error`

**Error Codes:**
- `1` - WebView2 konnte nicht erstellt werden

**Beispiel:**
```autoit
$hGUI = GUICreate("Test", 800, 600)
$aWebView = _WV2Chart_Init($hGUI, 0, 0, 800, 600, "dark")
If @error Then Exit
```

---

### Chart-Erstellung

#### `_WV2Chart_Create`

```autoit
_WV2Chart_Create($sId, $sType, $aLabels, $aDatasets, [$aOptions = Default])
```

Erstellt ein neues Chart.

**Parameter:**
- `$sId` (string) - Eindeutige Chart-ID
- `$sType` (string) - Chart-Typ (siehe Konstanten)
- `$aLabels` (array) - 1D-Array mit X-Achsen-Labels
- `$aDatasets` (array) - 2D-Array mit Datasets:
  - `[n][0]` = Label (string)
  - `[n][1]` = Daten (1D-Array)
  - `[n][2]` = Farbe (string, optional)
- `$aOptions` (string, optional) - JSON-String mit Chart.js Optionen

**Returns:**
- Success: Chart-ID (string)
- Failure: `""` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert
- `2` - Labels-Array ungültig
- `3` - Datasets-Array ungültig

**Beispiel:**
```autoit
Local $aLabels[3] = ["A", "B", "C"]
Local $aDatasets[1][2]
$aDatasets[0][0] = "Series 1"
Local $aData[3] = [10, 20, 30]
$aDatasets[0][1] = $aData

_WV2Chart_Create("chart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)
```

**Beispiel mit Custom Color:**
```autoit
Local $aDatasets[1][3]
$aDatasets[0][0] = "Sales"
$aDatasets[0][1] = [65, 59, 80]
$aDatasets[0][2] = "#3B82F6"  ; Blaue Farbe

_WV2Chart_Create("colorChart", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets)
```

**Beispiel mit Custom Options:**
```autoit
Local $sOptions = '{"responsive":true,"plugins":{"title":{"display":true,"text":"My Chart"}}}'
_WV2Chart_Create("customChart", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets, $sOptions)
```

---

### Daten-Updates

#### `_WV2Chart_Update`

```autoit
_WV2Chart_Update($sId, $aLabels, $aDatasets)
```

Aktualisiert ein Chart komplett (Labels + alle Datasets).

**Parameter:**
- `$sId` (string) - Chart-ID
- `$aLabels` (array) - Neue Labels
- `$aDatasets` (array) - Neue Datasets (Format wie bei `_WV2Chart_Create`)

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert
- `2` - Labels-Array ungültig
- `3` - Datasets-Array ungültig

**Beispiel:**
```autoit
Local $aNewLabels[4] = ["Q1", "Q2", "Q3", "Q4"]
Local $aNewDatasets[1][2]
$aNewDatasets[0][0] = "Quarterly"
$aNewDatasets[0][1] = [100, 200, 150, 250]

_WV2Chart_Update("chart1", $aNewLabels, $aNewDatasets)
```

---

#### `_WV2Chart_UpdateDataset`

```autoit
_WV2Chart_UpdateDataset($sId, $iDatasetIndex, $aData)
```

Aktualisiert nur die Daten eines spezifischen Datasets (optimiert für Live-Updates).

**Parameter:**
- `$sId` (string) - Chart-ID
- `$iDatasetIndex` (int) - Index des Datasets (0-basiert)
- `$aData` (array) - Neue Daten (1D-Array)

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert
- `2` - Daten-Array ungültig

**Verwendung für Live-Updates:**
```autoit
AdlibRegister(UpdateLiveData, 500)

Func UpdateLiveData()
    Local $aNewData[5]
    For $i = 0 To 4
        $aNewData[$i] = Random(0, 100, 1)
    Next
    _WV2Chart_UpdateDataset("liveChart", 0, $aNewData)
EndFunc
```

---

### Chart-Verwaltung

#### `_WV2Chart_Destroy`

```autoit
_WV2Chart_Destroy($sId)
```

Entfernt ein Chart und gibt Ressourcen frei.

**Parameter:**
- `$sId` (string) - Chart-ID

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert

**Beispiel:**
```autoit
_WV2Chart_Destroy("chart1")
```

---

#### `_WV2Chart_Clear`

```autoit
_WV2Chart_Clear()
```

Entfernt alle Charts.

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert

**Beispiel:**
```autoit
_WV2Chart_Clear()
```

---

### Theme & Styling

#### `_WV2Chart_SetTheme`

```autoit
_WV2Chart_SetTheme($sTheme)
```

Setzt das globale Theme. Alle Charts werden automatisch neu gerendert.

**Parameter:**
- `$sTheme` (string) - Theme: `"light"` oder `"dark"`

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert
- `2` - Ungültiges Theme

**Beispiel:**
```autoit
_WV2Chart_SetTheme("dark")
```

---

### Events

#### `_WV2Chart_OnClick`

```autoit
_WV2Chart_OnClick($fCallback)
```

Registriert einen Callback für Chart-Clicks.

**Parameter:**
- `$fCallback` (function) - Callback-Funktion mit Signatur:
  ```autoit
  Func MyCallback($sChartId, $iDatasetIndex, $iDataIndex)
  ```
  - `$sChartId` (string) - ID des geklickten Charts
  - `$iDatasetIndex` (int) - Index des Datasets
  - `$iDataIndex` (int) - Index des Datenpunkts

**Returns:**
- Success: `True`
- Failure: `False` und setzt `@error`

**Error Codes:**
- `1` - Callback ist keine Funktion

**Beispiel:**
```autoit
_WV2Chart_OnClick(OnChartClick)

Func OnChartClick($sChartId, $iDatasetIndex, $iDataIndex)
    ConsoleWrite("Chart: " & $sChartId & @CRLF)
    ConsoleWrite("Dataset: " & $iDatasetIndex & @CRLF)
    ConsoleWrite("Point: " & $iDataIndex & @CRLF)
EndFunc
```

---

### Experimentelle Funktionen

#### `_WV2Chart_GetChartData`

```autoit
_WV2Chart_GetChartData($sId)
```

Ruft die aktuellen Chart-Daten ab (experimentell).

**Parameter:**
- `$sId` (string) - Chart-ID

**Returns:**
- Success: JSON-String mit Chart-Daten
- Failure: `""` und setzt `@error`

**Error Codes:**
- `1` - Nicht initialisiert
- `2` - Script-Ausführung fehlgeschlagen

**Hinweis:** Diese Funktion ist experimentell und kann in zukünftigen Versionen geändert werden.

---

## Interne Funktionen

Diese Funktionen sind für die interne Verwendung und sollten nicht direkt aufgerufen werden:

- `__WV2Chart_OnMessage($sMessage)`
- `__WV2Chart_GenerateHTML()`
- `__WV2Chart_GenerateJS()`
- `__WV2Chart_ApplyTheme()`
- `__WV2Chart_SendCommand($sJson)`
- `__WV2Chart_JsonGetValue($sJson, $sKey)`
- `__WV2Chart_ArrayToJson($aData)`
- `__WV2Chart_DatasetsToJson($aDatasets)`

---

## Color Palettes

Die Extension verwendet automatisch eine vordefinierte Farbpalette basierend auf dem Theme:

**Light Theme:**
- `#3B82F6` (Blue)
- `#10B981` (Green)
- `#F59E0B` (Amber)
- `#EF4444` (Red)
- `#8B5CF6` (Purple)
- `#EC4899` (Pink)
- `#14B8A6` (Teal)
- `#F97316` (Orange)

**Dark Theme:**
- `#60A5FA` (Light Blue)
- `#34D399` (Light Green)
- `#FBBF24` (Light Amber)
- `#F87171` (Light Red)
- `#A78BFA` (Light Purple)
- `#F472B6` (Light Pink)
- `#2DD4BF` (Light Teal)
- `#FB923C` (Light Orange)

Farben können mit dem optionalen `[n][2]` Parameter in `$aDatasets` überschrieben werden.

---

## Chart.js Optionen

Erweiterte Chart.js Optionen können über den `$aOptions` Parameter als JSON-String übergeben werden.

**Beispiel - Titel hinzufügen:**
```autoit
Local $sOptions = '{"plugins":{"title":{"display":true,"text":"Sales Report"}}}'
_WV2Chart_Create("chart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets, $sOptions)
```

**Beispiel - Y-Achse Minimum/Maximum:**
```autoit
Local $sOptions = '{"scales":{"y":{"min":0,"max":100}}}'
_WV2Chart_Create("chart1", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets, $sOptions)
```

**Beispiel - Legende ausblenden:**
```autoit
Local $sOptions = '{"plugins":{"legend":{"display":false}}}'
_WV2Chart_Create("chart1", $WV2CHART_TYPE_PIE, $aLabels, $aDatasets, $sOptions)
```

Für alle verfügbaren Optionen siehe: [Chart.js Documentation](https://www.chartjs.org/docs/latest/configuration/)

---

## Best Practices

1. **Eindeutige Chart-IDs verwenden**: Jede Chart-ID muss unique sein
2. **Arrays validieren**: Immer mit `IsArray()` prüfen bevor übergeben wird
3. **Echtzeit-Updates**: `_WV2Chart_UpdateDataset()` für schnelle Updates verwenden
4. **Theme-Wechsel**: Charts werden automatisch neu gerendert
5. **Fehlerbehandlung**: Immer `@error` nach Funktionsaufrufen prüfen
6. **Memory Management**: `_WV2Chart_Destroy()` verwenden wenn Charts nicht mehr benötigt werden

---

## Version

API Version: 1.0.0
Chart.js Version: 4.4.1
