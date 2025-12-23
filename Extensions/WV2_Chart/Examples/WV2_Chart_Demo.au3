#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include "..\Include\WV2_Chart.au3"

; ===============================================================================================================================
; WV2_Chart Demo - Chart.js Integration Showcase
;
; Demonstriert:
; - Line Chart mit Echtzeit-Updates
; - Bar Chart
; - Pie/Doughnut Chart
; - Theme-Wechsel (Light/Dark)
; - Click-Events
; ===============================================================================================================================

Global $g_hGUI, $g_aWebView
Global $g_idBtnLine, $g_idBtnBar, $g_idBtnPie, $g_idBtnDoughnut, $g_idBtnUpdate, $g_idBtnClear, $g_idBtnTheme
Global $g_sCurrentTheme = "light"
Global $g_iUpdateCounter = 0

Example()

Func Example()
	; GUI erstellen
	$g_hGUI = GUICreate("WV2_Chart Demo - Chart.js Integration", 1200, 800, -1, -1, $WS_OVERLAPPEDWINDOW)

	; Buttons
	$g_idBtnLine = GUICtrlCreateButton("Line Chart", 10, 10, 100, 30)
	$g_idBtnBar = GUICtrlCreateButton("Bar Chart", 120, 10, 100, 30)
	$g_idBtnPie = GUICtrlCreateButton("Pie Chart", 230, 10, 100, 30)
	$g_idBtnDoughnut = GUICtrlCreateButton("Doughnut Chart", 340, 10, 120, 30)
	$g_idBtnUpdate = GUICtrlCreateButton("Update Data", 470, 10, 100, 30)
	$g_idBtnClear = GUICtrlCreateButton("Clear All", 580, 10, 100, 30)
	$g_idBtnTheme = GUICtrlCreateButton("Toggle Theme", 690, 10, 120, 30)

	GUISetState(@SW_SHOW, $g_hGUI)

	; WebView2 mit Chart.js initialisieren
	ConsoleWrite("[Demo] Initializing WV2_Chart..." & @CRLF)
	$g_aWebView = _WV2Chart_Init($g_hGUI, 10, 50, 1180, 740, $g_sCurrentTheme)
	If @error Then
		MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!" & @CRLF & "Error: " & @error)
		Exit
	EndIf
	ConsoleWrite("[Demo] WV2_Chart initialized successfully!" & @CRLF)

	; Click-Callback registrieren
	_WV2Chart_OnClick(OnChartClick)

	; Initial Chart erstellen
	CreateLineChart()

	; Message-Loop
	While True
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $g_idBtnLine
				_WV2Chart_Clear()
				CreateLineChart()

			Case $g_idBtnBar
				_WV2Chart_Clear()
				CreateBarChart()

			Case $g_idBtnPie
				_WV2Chart_Clear()
				CreatePieChart()

			Case $g_idBtnDoughnut
				_WV2Chart_Clear()
				CreateDoughnutChart()

			Case $g_idBtnUpdate
				UpdateLiveData()

			Case $g_idBtnClear
				_WV2Chart_Clear()

			Case $g_idBtnTheme
				ToggleTheme()
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($g_hGUI)
EndFunc

; ===============================================================================================================================
; Chart-Erstellungs-Funktionen
; ===============================================================================================================================

Func CreateLineChart()
	ConsoleWrite("[Demo] Creating Line Chart..." & @CRLF)

	; Labels
	Local $aLabels[12] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

	; Datasets (2D-Array: [n][0]=Label, [n][1]=Data, [n][2]=Color optional)
	Local $aDatasets[2][2]
	$aDatasets[0][0] = "Sales 2023"
	Local $aData1[12] = [65, 59, 80, 81, 56, 55, 70, 65, 75, 85, 90, 95]
	$aDatasets[0][1] = $aData1

	$aDatasets[1][0] = "Sales 2024"
	Local $aData2[12] = [45, 69, 90, 71, 76, 85, 80, 75, 95, 105, 110, 115]
	$aDatasets[1][1] = $aData2

	; Chart erstellen
	_WV2Chart_Create("lineChart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)
	ConsoleWrite("[Demo] Line Chart created!" & @CRLF)
EndFunc

Func CreateBarChart()
	ConsoleWrite("[Demo] Creating Bar Chart..." & @CRLF)

	Local $aLabels[6] = ["Q1", "Q2", "Q3", "Q4", "Q5", "Q6"]

	Local $aDatasets[3][2]
	$aDatasets[0][0] = "Product A"
	Local $aData1[6] = [120, 150, 180, 170, 190, 200]
	$aDatasets[0][1] = $aData1

	$aDatasets[1][0] = "Product B"
	Local $aData2[6] = [80, 100, 95, 110, 105, 120]
	$aDatasets[1][1] = $aData2

	$aDatasets[2][0] = "Product C"
	Local $aData3[6] = [60, 70, 85, 90, 95, 100]
	$aDatasets[2][1] = $aData3

	_WV2Chart_Create("barChart1", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets)
	ConsoleWrite("[Demo] Bar Chart created!" & @CRLF)
EndFunc

Func CreatePieChart()
	ConsoleWrite("[Demo] Creating Pie Chart..." & @CRLF)

	Local $aLabels[5] = ["Chrome", "Firefox", "Safari", "Edge", "Other"]

	Local $aDatasets[1][2]
	$aDatasets[0][0] = "Browser Usage"
	Local $aData[5] = [45, 20, 15, 12, 8]
	$aDatasets[0][1] = $aData

	_WV2Chart_Create("pieChart1", $WV2CHART_TYPE_PIE, $aLabels, $aDatasets)
	ConsoleWrite("[Demo] Pie Chart created!" & @CRLF)
EndFunc

Func CreateDoughnutChart()
	ConsoleWrite("[Demo] Creating Doughnut Chart..." & @CRLF)

	Local $aLabels[4] = ["Desktop", "Mobile", "Tablet", "Other"]

	Local $aDatasets[1][2]
	$aDatasets[0][0] = "Device Usage"
	Local $aData[4] = [55, 30, 12, 3]
	$aDatasets[0][1] = $aData

	_WV2Chart_Create("doughnutChart1", $WV2CHART_TYPE_DOUGHNUT, $aLabels, $aDatasets)
	ConsoleWrite("[Demo] Doughnut Chart created!" & @CRLF)
EndFunc

; ===============================================================================================================================
; Live-Update Funktion
; ===============================================================================================================================

Func UpdateLiveData()
	ConsoleWrite("[Demo] Updating live data..." & @CRLF)
	$g_iUpdateCounter += 1

	; Generiere neue Zufallsdaten
	Local $aNewData[12]
	For $i = 0 To 11
		$aNewData[$i] = Random(40, 120, 1)
	Next

	; Aktualisiere nur das erste Dataset (schneller als komplettes Update)
	_WV2Chart_UpdateDataset("lineChart1", 0, $aNewData)

	ConsoleWrite("[Demo] Data updated! (Counter: " & $g_iUpdateCounter & ")" & @CRLF)
EndFunc

; ===============================================================================================================================
; Theme-Toggle
; ===============================================================================================================================

Func ToggleTheme()
	If $g_sCurrentTheme = "light" Then
		$g_sCurrentTheme = "dark"
	Else
		$g_sCurrentTheme = "light"
	EndIf

	_WV2Chart_SetTheme($g_sCurrentTheme)
	ConsoleWrite("[Demo] Theme changed to: " & $g_sCurrentTheme & @CRLF)
EndFunc

; ===============================================================================================================================
; Event-Callback
; ===============================================================================================================================

Func OnChartClick($sChartId, $iDatasetIndex, $iDataIndex)
	ConsoleWrite("[Demo] Chart clicked!" & @CRLF)
	ConsoleWrite("  Chart ID: " & $sChartId & @CRLF)
	ConsoleWrite("  Dataset Index: " & $iDatasetIndex & @CRLF)
	ConsoleWrite("  Data Index: " & $iDataIndex & @CRLF)

	; Zeige Info-Popup
	Local $sMsg = "Chart Click Event" & @CRLF & @CRLF
	$sMsg &= "Chart: " & $sChartId & @CRLF
	$sMsg &= "Dataset: " & $iDatasetIndex & @CRLF
	$sMsg &= "Data Point: " & $iDataIndex
	MsgBox(64, "Chart Event", $sMsg, 2)
EndFunc
