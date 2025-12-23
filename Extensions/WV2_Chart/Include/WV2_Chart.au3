#include-once
#include "..\..\..\Include\WebView2_Native.au3"

; #INDEX# =======================================================================================================================
; Title .........: WV2_Chart
; AutoIt Version : 3.3.16.1+
; Language ......: English/German
; Description ...: Chart.js Integration fuer WebView2 - Moderne Diagramme und Visualisierungen
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Diese Extension ermoeglicht die einfache Erstellung von interaktiven Diagrammen
; in AutoIt-Anwendungen mit Chart.js via WebView2.
;
; FEATURES:
; - 6 Chart-Typen: Line, Bar, Pie, Doughnut, Radar, Polar
; - Echtzeit-Updates fuer Live-Daten
; - Light/Dark Theme-Unterstuetzung
; - Animationen und Interaktivitaet
; - Responsive Design
; - Bidirektionale Kommunikation
; - Event-Callbacks fuer Clicks
;
; REQUIREMENTS:
; - WebView2 Runtime (wird automatisch geprueft)
; - Chart.js wird via CDN geladen (keine lokalen Dateien noetig)
;
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $WV2CHART_VERSION = "1.0.0"

; Chart-Typen
Global Const $WV2CHART_TYPE_LINE = "line"
Global Const $WV2CHART_TYPE_BAR = "bar"
Global Const $WV2CHART_TYPE_PIE = "pie"
Global Const $WV2CHART_TYPE_DOUGHNUT = "doughnut"
Global Const $WV2CHART_TYPE_RADAR = "radar"
Global Const $WV2CHART_TYPE_POLAR = "polarArea"

; Themes
Global Const $WV2CHART_THEME_LIGHT = "light"
Global Const $WV2CHART_THEME_DARK = "dark"
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_aWV2Chart_WebView = 0              ; WebView2 Instanz
Global $__g_sWV2Chart_Theme = "light"          ; Aktuelles Theme
Global $__g_aWV2Chart_Charts[1][3]             ; [n][0]=ID, [n][1]=Type, [n][2]=Data
$__g_aWV2Chart_Charts[0][0] = 0                ; Count
Global $__g_fWV2Chart_OnClick = 0              ; Click-Callback
Global $__g_bWV2Chart_Initialized = False      ; Init-Status
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WV2Chart_Init
; _WV2Chart_Create
; _WV2Chart_Update
; _WV2Chart_UpdateDataset
; _WV2Chart_Destroy
; _WV2Chart_SetTheme
; _WV2Chart_OnClick
; _WV2Chart_Clear
; _WV2Chart_GetChartData
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_Init
; Description ...: Initialisiert WebView2 mit Chart.js
; Syntax ........: _WV2Chart_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sTheme])
; Parameters ....: $hWnd          - Handle des Parent-Fensters
;                  $iLeft/Top     - Position
;                  $iWidth/Height - Groesse
;                  $sTheme        - [optional] "light" oder "dark" (Standard: "light")
; Return values .: Success - WebView2 Array
;                  Failure - 0 und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, $sTheme = "light")
	; Theme speichern
	$__g_sWV2Chart_Theme = $sTheme

	; WebView2 erstellen
	Local $aWebView = _WebView2_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight)
	If @error Then Return SetError(1, @extended, 0)

	$__g_aWV2Chart_WebView = $aWebView

	; Message-Callback registrieren
	_WebView2_SetMessageCallback($aWebView, __WV2Chart_OnMessage)

	; HTML mit Chart.js laden
	Local $sHtml = __WV2Chart_GenerateHTML()
	_WebView2_NavigateToString($aWebView, $sHtml)

	; Warten bis Chart.js geladen ist (max 5 Sekunden)
	Local $iTimeout = 5000
	Local $iStart = TimerInit()
	Local $bChartJsLoaded = False

	While TimerDiff($iStart) < $iTimeout
		Sleep(100)
		Local $sResult = _WebView2_ExecuteScript($aWebView, "typeof Chart !== 'undefined' ? 'loaded' : 'waiting'", 500)
		If $sResult = '"loaded"' Or $sResult = "loaded" Then
			$bChartJsLoaded = True
			ConsoleWrite("[WV2_Chart] Chart.js loaded successfully!" & @CRLF)
			ExitLoop
		EndIf
	WEnd

	If Not $bChartJsLoaded Then
		ConsoleWrite("[WV2_Chart] WARNING: Chart.js may not have loaded from CDN!" & @CRLF)
	EndIf

	; Theme anwenden
	__WV2Chart_ApplyTheme()

	$__g_bWV2Chart_Initialized = True
	Return $aWebView
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_Create
; Description ...: Erstellt ein neues Chart
; Syntax ........: _WV2Chart_Create($sId, $sType, $aLabels, $aDatasets, [$aOptions])
; Parameters ....: $sId       - Eindeutige Chart-ID
;                  $sType     - Chart-Typ (Konstanten verwenden: $WV2CHART_TYPE_*)
;                  $aLabels   - Array mit Labels (z.B. ["Jan", "Feb", "Mar"])
;                  $aDatasets - 2D-Array: [n][0]=Label, [n][1]=Data-Array, [n][2]=Color (optional)
;                               Beispiel: [["Sales", [10,20,30], "#3B82F6"], ["Profit", [5,15,25], "#10B981"]]
;                  $aOptions  - [optional] JSON-String mit Chart.js Optionen
; Return values .: Success - Chart ID
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_Create($sId, $sType, $aLabels, $aDatasets, $aOptions = Default)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, "")
	If Not IsArray($aLabels) Then Return SetError(2, 0, "")
	If Not IsArray($aDatasets) Then Return SetError(3, 0, "")

	; Chart registrieren
	Local $iIndex = $__g_aWV2Chart_Charts[0][0] + 1
	ReDim $__g_aWV2Chart_Charts[$iIndex + 1][3]
	$__g_aWV2Chart_Charts[0][0] = $iIndex
	$__g_aWV2Chart_Charts[$iIndex][0] = $sId
	$__g_aWV2Chart_Charts[$iIndex][1] = $sType
	$__g_aWV2Chart_Charts[$iIndex][2] = ""

	; JSON-Command erstellen
	Local $sLabelsJson = __WV2Chart_ArrayToJson($aLabels)
	Local $sDatasetsJson = __WV2Chart_DatasetsToJson($aDatasets)

	Local $sOptionsJson = "{}"
	If $aOptions <> Default And $aOptions <> "" Then
		$sOptionsJson = $aOptions
	EndIf

	Local $sCmd = '{"action":"createChart","chartId":"' & $sId & '","chartType":"' & $sType & '",' & _
				  '"labels":' & $sLabelsJson & ',"datasets":' & $sDatasetsJson & ',"options":' & $sOptionsJson & '}'

	__WV2Chart_SendCommand($sCmd)
	Return $sId
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_Update
; Description ...: Aktualisiert ein Chart komplett (Labels + Datasets)
; Syntax ........: _WV2Chart_Update($sId, $aLabels, $aDatasets)
; Parameters ....: $sId       - Chart-ID
;                  $aLabels   - Neue Labels
;                  $aDatasets - Neue Datasets
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_Update($sId, $aLabels, $aDatasets)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)
	If Not IsArray($aLabels) Then Return SetError(2, 0, False)
	If Not IsArray($aDatasets) Then Return SetError(3, 0, False)

	Local $sLabelsJson = __WV2Chart_ArrayToJson($aLabels)
	Local $sDatasetsJson = __WV2Chart_DatasetsToJson($aDatasets)

	Local $sCmd = '{"action":"updateChart","chartId":"' & $sId & '",' & _
				  '"labels":' & $sLabelsJson & ',"datasets":' & $sDatasetsJson & '}'

	__WV2Chart_SendCommand($sCmd)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_UpdateDataset
; Description ...: Aktualisiert nur die Daten eines spezifischen Datasets (schneller fuer Live-Updates)
; Syntax ........: _WV2Chart_UpdateDataset($sId, $iDatasetIndex, $aData)
; Parameters ....: $sId           - Chart-ID
;                  $iDatasetIndex - Index des Datasets (0-basiert)
;                  $aData         - Neue Daten-Array
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_UpdateDataset($sId, $iDatasetIndex, $aData)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)
	If Not IsArray($aData) Then Return SetError(2, 0, False)

	Local $sDataJson = __WV2Chart_ArrayToJson($aData)
	Local $sCmd = '{"action":"updateDataset","chartId":"' & $sId & '",' & _
				  '"datasetIndex":' & $iDatasetIndex & ',"data":' & $sDataJson & '}'

	__WV2Chart_SendCommand($sCmd)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_Destroy
; Description ...: Entfernt ein Chart
; Syntax ........: _WV2Chart_Destroy($sId)
; Parameters ....: $sId - Chart-ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_Destroy($sId)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)

	Local $sCmd = '{"action":"destroyChart","chartId":"' & $sId & '"}'
	__WV2Chart_SendCommand($sCmd)

	; Aus lokalem Array entfernen
	For $i = 1 To $__g_aWV2Chart_Charts[0][0]
		If $__g_aWV2Chart_Charts[$i][0] = $sId Then
			$__g_aWV2Chart_Charts[$i][0] = ""
			ExitLoop
		EndIf
	Next

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_SetTheme
; Description ...: Setzt das globale Theme (light/dark)
; Syntax ........: _WV2Chart_SetTheme($sTheme)
; Parameters ....: $sTheme - "light" oder "dark"
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_SetTheme($sTheme)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)
	If $sTheme <> "light" And $sTheme <> "dark" Then Return SetError(2, 0, False)

	$__g_sWV2Chart_Theme = $sTheme
	__WV2Chart_ApplyTheme()
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_OnClick
; Description ...: Registriert einen Callback fuer Chart-Clicks
; Syntax ........: _WV2Chart_OnClick($fCallback)
; Parameters ....: $fCallback - Callback-Funktion: Func($sChartId, $iDatasetIndex, $iDataIndex)
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_OnClick($fCallback)
	If Not IsFunc($fCallback) Then Return SetError(1, 0, False)
	$__g_fWV2Chart_OnClick = $fCallback
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_Clear
; Description ...: Entfernt alle Charts
; Syntax ........: _WV2Chart_Clear()
; Return values .: Success - True
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_Clear()
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)

	Local $sCmd = '{"action":"clearAll"}'
	__WV2Chart_SendCommand($sCmd)

	; Array zuruecksetzen
	ReDim $__g_aWV2Chart_Charts[1][3]
	$__g_aWV2Chart_Charts[0][0] = 0

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Chart_GetChartData
; Description ...: Ruft die aktuellen Chart-Daten ab (experimentell)
; Syntax ........: _WV2Chart_GetChartData($sId)
; Parameters ....: $sId - Chart-ID
; Return values .: Success - JSON-String mit Chart-Daten
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Chart_GetChartData($sId)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, "")

	Local $sScript = "WV2Chart.getChartData('" & $sId & "')"
	Local $sResult = _WebView2_ExecuteScript($__g_aWV2Chart_WebView, $sScript, 1000)
	If @error Then Return SetError(2, @error, "")

	Return $sResult
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Message-Handler fuer Events vom Frontend
Func __WV2Chart_OnMessage($sMessage)
	; JSON parsen (vereinfacht)
	If StringLeft($sMessage, 1) = '"' Then
		$sMessage = StringTrimLeft(StringTrimRight($sMessage, 1), 1)
	EndIf

	; Event-Type extrahieren
	Local $sEventType = __WV2Chart_JsonGetValue($sMessage, "event")

	If $sEventType = "chartClick" And IsFunc($__g_fWV2Chart_OnClick) Then
		Local $sChartId = __WV2Chart_JsonGetValue($sMessage, "chartId")
		Local $sDatasetIndex = __WV2Chart_JsonGetValue($sMessage, "datasetIndex")
		Local $sDataIndex = __WV2Chart_JsonGetValue($sMessage, "dataIndex")

		Call($__g_fWV2Chart_OnClick, $sChartId, Number($sDatasetIndex), Number($sDataIndex))
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert das HTML mit Chart.js
Func __WV2Chart_GenerateHTML()
	Local $sThemeClass = ($__g_sWV2Chart_Theme = "dark") ? "dark" : ""
	Local $sBgColor = ($__g_sWV2Chart_Theme = "dark") ? "#1f2937" : "#f9fafb"

	Local $sHtml = '<!DOCTYPE html>' & @CRLF
	$sHtml &= '<html lang="de" class="' & $sThemeClass & '">' & @CRLF
	$sHtml &= '<head>' & @CRLF
	$sHtml &= '  <meta charset="UTF-8">' & @CRLF
	$sHtml &= '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' & @CRLF
	$sHtml &= '  <title>WV2_Chart - Chart.js Extension</title>' & @CRLF
	$sHtml &= '' & @CRLF
	$sHtml &= '  <!-- Chart.js CDN -->' & @CRLF
	$sHtml &= '  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>' & @CRLF
	$sHtml &= '' & @CRLF
	$sHtml &= '  <style>' & @CRLF
	$sHtml &= '    * { margin: 0; padding: 0; box-sizing: border-box; }' & @CRLF
	$sHtml &= '    body {' & @CRLF
	$sHtml &= '      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;' & @CRLF
	$sHtml &= '      background: ' & $sBgColor & ';' & @CRLF
	$sHtml &= '      padding: 16px;' & @CRLF
	$sHtml &= '      transition: background 0.3s;' & @CRLF
	$sHtml &= '    }' & @CRLF
	$sHtml &= '    body.dark { background: #1f2937; }' & @CRLF
	$sHtml &= '    .chart-container {' & @CRLF
	$sHtml &= '      position: relative;' & @CRLF
	$sHtml &= '      margin-bottom: 24px;' & @CRLF
	$sHtml &= '      padding: 20px;' & @CRLF
	$sHtml &= '      background: white;' & @CRLF
	$sHtml &= '      border-radius: 12px;' & @CRLF
	$sHtml &= '      box-shadow: 0 2px 8px rgba(0,0,0,0.1);' & @CRLF
	$sHtml &= '    }' & @CRLF
	$sHtml &= '    body.dark .chart-container {' & @CRLF
	$sHtml &= '      background: #374151;' & @CRLF
	$sHtml &= '      box-shadow: 0 2px 8px rgba(0,0,0,0.3);' & @CRLF
	$sHtml &= '    }' & @CRLF
	$sHtml &= '    canvas { max-height: 400px; }' & @CRLF
	$sHtml &= '  </style>' & @CRLF
	$sHtml &= '</head>' & @CRLF
	$sHtml &= '<body>' & @CRLF
	$sHtml &= '  <div id="root"></div>' & @CRLF
	$sHtml &= '' & @CRLF
	$sHtml &= '  <script>' & @CRLF
	$sHtml &= __WV2Chart_GenerateJS()
	$sHtml &= '  </script>' & @CRLF
	$sHtml &= '</body>' & @CRLF
	$sHtml &= '</html>'

	Return $sHtml
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert das JavaScript
Func __WV2Chart_GenerateJS()
	Local $sJs = ""

	$sJs &= "// WV2Chart - Chart.js Wrapper" & @CRLF
	$sJs &= "const WV2Chart = {" & @CRLF
	$sJs &= "  charts: new Map()," & @CRLF
	$sJs &= "  theme: '" & $__g_sWV2Chart_Theme & "'," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Color palettes" & @CRLF
	$sJs &= "  colors: {" & @CRLF
	$sJs &= "    light: ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316']," & @CRLF
	$sJs &= "    dark: ['#60A5FA', '#34D399', '#FBBF24', '#F87171', '#A78BFA', '#F472B6', '#2DD4BF', '#FB923C']" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Handle commands from AutoIt" & @CRLF
	$sJs &= "  handleCommand: function(jsonStr) {" & @CRLF
	$sJs &= "    try {" & @CRLF
	$sJs &= "      const cmd = JSON.parse(jsonStr);" & @CRLF
	$sJs &= "      console.log('Command:', cmd);" & @CRLF
	$sJs &= "      switch(cmd.action) {" & @CRLF
	$sJs &= "        case 'createChart': this.createChart(cmd); break;" & @CRLF
	$sJs &= "        case 'updateChart': this.updateChart(cmd); break;" & @CRLF
	$sJs &= "        case 'updateDataset': this.updateDataset(cmd); break;" & @CRLF
	$sJs &= "        case 'destroyChart': this.destroyChart(cmd); break;" & @CRLF
	$sJs &= "        case 'setTheme': this.setTheme(cmd.theme); break;" & @CRLF
	$sJs &= "        case 'clearAll': this.clearAll(); break;" & @CRLF
	$sJs &= "        default: console.warn('Unknown action:', cmd.action);" & @CRLF
	$sJs &= "      }" & @CRLF
	$sJs &= "    } catch(e) { console.error('Command parse error:', e); }" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Create new chart" & @CRLF
	$sJs &= "  createChart: function(cmd) {" & @CRLF
	$sJs &= "    const { chartId, chartType, labels, datasets, options } = cmd;" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Create container" & @CRLF
	$sJs &= "    const container = document.createElement('div');" & @CRLF
	$sJs &= "    container.className = 'chart-container';" & @CRLF
	$sJs &= "    container.id = 'chart-container-' + chartId;" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Create canvas" & @CRLF
	$sJs &= "    const canvas = document.createElement('canvas');" & @CRLF
	$sJs &= "    canvas.id = 'chart-' + chartId;" & @CRLF
	$sJs &= "    container.appendChild(canvas);" & @CRLF
	$sJs &= "    document.getElementById('root').appendChild(container);" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Apply colors to datasets" & @CRLF
	$sJs &= "    const colors = this.colors[this.theme];" & @CRLF
	$sJs &= "    datasets.forEach((ds, idx) => {" & @CRLF
	$sJs &= "      if (!ds.backgroundColor) {" & @CRLF
	$sJs &= "        const color = colors[idx % colors.length];" & @CRLF
	$sJs &= "        if (chartType === 'line' || chartType === 'radar') {" & @CRLF
	$sJs &= "          ds.borderColor = color;" & @CRLF
	$sJs &= "          ds.backgroundColor = color + '20'; // 20% opacity" & @CRLF
	$sJs &= "        } else {" & @CRLF
	$sJs &= "          ds.backgroundColor = color;" & @CRLF
	$sJs &= "        }" & @CRLF
	$sJs &= "      }" & @CRLF
	$sJs &= "    });" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Default options" & @CRLF
	$sJs &= "    const defaultOptions = {" & @CRLF
	$sJs &= "      responsive: true," & @CRLF
	$sJs &= "      maintainAspectRatio: true," & @CRLF
	$sJs &= "      plugins: {" & @CRLF
	$sJs &= "        legend: {" & @CRLF
	$sJs &= "          labels: { color: this.theme === 'dark' ? '#F3F4F6' : '#1F2937' }" & @CRLF
	$sJs &= "        }" & @CRLF
	$sJs &= "      }," & @CRLF
	$sJs &= "      scales: this.getScaleOptions(chartType)," & @CRLF
	$sJs &= "      onClick: (e, activeEls) => this.onChartClick(chartId, e, activeEls)" & @CRLF
	$sJs &= "    };" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Merge with user options" & @CRLF
	$sJs &= "    const finalOptions = Object.assign({}, defaultOptions, options || {});" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Create Chart.js instance" & @CRLF
	$sJs &= "    const chart = new Chart(canvas, {" & @CRLF
	$sJs &= "      type: chartType," & @CRLF
	$sJs &= "      data: { labels: labels, datasets: datasets }," & @CRLF
	$sJs &= "      options: finalOptions" & @CRLF
	$sJs &= "    });" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    this.charts.set(chartId, chart);" & @CRLF
	$sJs &= "    console.log('Chart created:', chartId);" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Get scale options based on chart type" & @CRLF
	$sJs &= "  getScaleOptions: function(chartType) {" & @CRLF
	$sJs &= "    if (['pie', 'doughnut', 'polarArea'].includes(chartType)) return {};" & @CRLF
	$sJs &= "    const textColor = this.theme === 'dark' ? '#F3F4F6' : '#1F2937';" & @CRLF
	$sJs &= "    const gridColor = this.theme === 'dark' ? '#4B5563' : '#E5E7EB';" & @CRLF
	$sJs &= "    return {" & @CRLF
	$sJs &= "      x: { ticks: { color: textColor }, grid: { color: gridColor } }," & @CRLF
	$sJs &= "      y: { ticks: { color: textColor }, grid: { color: gridColor } }" & @CRLF
	$sJs &= "    };" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Update chart (full update)" & @CRLF
	$sJs &= "  updateChart: function(cmd) {" & @CRLF
	$sJs &= "    const chart = this.charts.get(cmd.chartId);" & @CRLF
	$sJs &= "    if (!chart) { console.error('Chart not found:', cmd.chartId); return; }" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    if (cmd.labels) chart.data.labels = cmd.labels;" & @CRLF
	$sJs &= "    if (cmd.datasets) chart.data.datasets = cmd.datasets;" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    chart.update('active');" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Update single dataset (fast update for live data)" & @CRLF
	$sJs &= "  updateDataset: function(cmd) {" & @CRLF
	$sJs &= "    const chart = this.charts.get(cmd.chartId);" & @CRLF
	$sJs &= "    if (!chart) { console.error('Chart not found:', cmd.chartId); return; }" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    if (chart.data.datasets[cmd.datasetIndex]) {" & @CRLF
	$sJs &= "      chart.data.datasets[cmd.datasetIndex].data = cmd.data;" & @CRLF
	$sJs &= "      chart.update('active');" & @CRLF
	$sJs &= "    }" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Destroy chart" & @CRLF
	$sJs &= "  destroyChart: function(cmd) {" & @CRLF
	$sJs &= "    const chart = this.charts.get(cmd.chartId);" & @CRLF
	$sJs &= "    if (chart) {" & @CRLF
	$sJs &= "      chart.destroy();" & @CRLF
	$sJs &= "      this.charts.delete(cmd.chartId);" & @CRLF
	$sJs &= "      const container = document.getElementById('chart-container-' + cmd.chartId);" & @CRLF
	$sJs &= "      if (container) container.remove();" & @CRLF
	$sJs &= "    }" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Clear all charts" & @CRLF
	$sJs &= "  clearAll: function() {" & @CRLF
	$sJs &= "    this.charts.forEach(chart => chart.destroy());" & @CRLF
	$sJs &= "    this.charts.clear();" & @CRLF
	$sJs &= "    document.getElementById('root').innerHTML = '';" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Set theme" & @CRLF
	$sJs &= "  setTheme: function(theme) {" & @CRLF
	$sJs &= "    this.theme = theme;" & @CRLF
	$sJs &= "    document.body.className = theme === 'dark' ? 'dark' : '';" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    // Update all charts" & @CRLF
	$sJs &= "    this.charts.forEach((chart, id) => {" & @CRLF
	$sJs &= "      // Update colors" & @CRLF
	$sJs &= "      const textColor = theme === 'dark' ? '#F3F4F6' : '#1F2937';" & @CRLF
	$sJs &= "      const gridColor = theme === 'dark' ? '#4B5563' : '#E5E7EB';" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "      if (chart.options.plugins && chart.options.plugins.legend) {" & @CRLF
	$sJs &= "        chart.options.plugins.legend.labels.color = textColor;" & @CRLF
	$sJs &= "      }" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "      if (chart.options.scales) {" & @CRLF
	$sJs &= "        if (chart.options.scales.x) {" & @CRLF
	$sJs &= "          chart.options.scales.x.ticks.color = textColor;" & @CRLF
	$sJs &= "          chart.options.scales.x.grid.color = gridColor;" & @CRLF
	$sJs &= "        }" & @CRLF
	$sJs &= "        if (chart.options.scales.y) {" & @CRLF
	$sJs &= "          chart.options.scales.y.ticks.color = textColor;" & @CRLF
	$sJs &= "          chart.options.scales.y.grid.color = gridColor;" & @CRLF
	$sJs &= "        }" & @CRLF
	$sJs &= "      }" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "      chart.update();" & @CRLF
	$sJs &= "    });" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Chart click handler" & @CRLF
	$sJs &= "  onChartClick: function(chartId, event, activeElements) {" & @CRLF
	$sJs &= "    if (activeElements.length === 0) return;" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    const firstElement = activeElements[0];" & @CRLF
	$sJs &= "    const datasetIndex = firstElement.datasetIndex;" & @CRLF
	$sJs &= "    const dataIndex = firstElement.index;" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    const event = {" & @CRLF
	$sJs &= "      event: 'chartClick'," & @CRLF
	$sJs &= "      chartId: chartId," & @CRLF
	$sJs &= "      datasetIndex: datasetIndex," & @CRLF
	$sJs &= "      dataIndex: dataIndex" & @CRLF
	$sJs &= "    };" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "    if (window.chrome && window.chrome.webview) {" & @CRLF
	$sJs &= "      window.chrome.webview.postMessage(JSON.stringify(event));" & @CRLF
	$sJs &= "    }" & @CRLF
	$sJs &= "  }," & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "  // Get chart data (for AutoIt to retrieve)" & @CRLF
	$sJs &= "  getChartData: function(chartId) {" & @CRLF
	$sJs &= "    const chart = this.charts.get(chartId);" & @CRLF
	$sJs &= "    if (!chart) return null;" & @CRLF
	$sJs &= "    return JSON.stringify({ labels: chart.data.labels, datasets: chart.data.datasets });" & @CRLF
	$sJs &= "  }" & @CRLF
	$sJs &= "};" & @CRLF
	$sJs &= "" & @CRLF
	$sJs &= "console.log('WV2Chart v" & $WV2CHART_VERSION & " initialized');" & @CRLF

	Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Theme anwenden
Func __WV2Chart_ApplyTheme()
	Local $sCmd = '{"action":"setTheme","theme":"' & $__g_sWV2Chart_Theme & '"}'
	__WV2Chart_SendCommand($sCmd)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Command senden
Func __WV2Chart_SendCommand($sJson)
	If Not $__g_bWV2Chart_Initialized Then Return SetError(1, 0, False)

	; Escape fuer JavaScript
	$sJson = StringReplace($sJson, "\", "\\")
	$sJson = StringReplace($sJson, "'", "\'")

	Local $sScript = "WV2Chart.handleCommand('" & $sJson & "')"
	_WebView2_ExecuteScriptAsync($__g_aWV2Chart_WebView, $sScript)

	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Einfacher JSON-Value-Extraktor
Func __WV2Chart_JsonGetValue($sJson, $sKey)
	Local $sPattern = '"' & $sKey & '"\s*:\s*"([^"]*)"'
	Local $aMatch = StringRegExp($sJson, $sPattern, 1)
	If @error Then
		; Versuche numerischen Wert
		$sPattern = '"' & $sKey & '"\s*:\s*([0-9]+)'
		$aMatch = StringRegExp($sJson, $sPattern, 1)
		If @error Then Return ""
	EndIf
	Return $aMatch[0]
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Array zu JSON konvertieren (1D)
Func __WV2Chart_ArrayToJson($aData)
	If Not IsArray($aData) Then Return "[]"

	Local $sJson = "["
	For $i = 0 To UBound($aData) - 1
		If $i > 0 Then $sJson &= ","
		If IsString($aData[$i]) Then
			$sJson &= '"' & StringReplace($aData[$i], '"', '\"') & '"'
		ElseIf IsNumber($aData[$i]) Then
			$sJson &= $aData[$i]
		Else
			$sJson &= "null"
		EndIf
	Next
	$sJson &= "]"

	Return $sJson
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Datasets zu JSON konvertieren
; $aDatasets Format: [n][0]=Label, [n][1]=Data-Array, [n][2]=Color (optional)
Func __WV2Chart_DatasetsToJson($aDatasets)
	If Not IsArray($aDatasets) Or UBound($aDatasets, 0) <> 2 Then Return "[]"

	Local $sJson = "["
	For $i = 0 To UBound($aDatasets) - 1
		If $i > 0 Then $sJson &= ","
		$sJson &= "{"

		; Label
		$sJson &= '"label":"' & StringReplace($aDatasets[$i][0], '"', '\"') & '",'

		; Data
		If IsArray($aDatasets[$i][1]) Then
			$sJson &= '"data":' & __WV2Chart_ArrayToJson($aDatasets[$i][1])
		Else
			$sJson &= '"data":[]'
		EndIf

		; Optional: Color
		If UBound($aDatasets, 2) > 2 And $aDatasets[$i][2] <> "" Then
			$sJson &= ',"backgroundColor":"' & $aDatasets[$i][2] & '"'
		EndIf

		$sJson &= "}"
	Next
	$sJson &= "]"

	Return $sJson
EndFunc

; ===============================================================================================================================
; End of WV2_Chart.au3
; ===============================================================================================================================
