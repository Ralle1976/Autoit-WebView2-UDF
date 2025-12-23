#include <GUIConstantsEx.au3>
#include "..\Include\WV2_Chart.au3"

; ===============================================================================================================================
; WV2_Chart Quick Start - Minimales Beispiel
; ===============================================================================================================================

; GUI erstellen
$hGUI = GUICreate("WV2_Chart Quick Start", 800, 600)
GUISetState(@SW_SHOW)

; WebView2 mit Chart.js initialisieren
$aWebView = _WV2Chart_Init($hGUI, 10, 10, 780, 580)
If @error Then Exit MsgBox(16, "Error", "WebView2 initialization failed!")

; Labels definieren
Local $aLabels[5] = ["January", "February", "March", "April", "May"]

; Dataset erstellen
Local $aDatasets[1][2]
$aDatasets[0][0] = "Monthly Sales"
Local $aData[5] = [65, 59, 80, 81, 56]
$aDatasets[0][1] = $aData

; Line Chart erstellen
_WV2Chart_Create("salesChart", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)

; Message-Loop
While GUIGetMsg() <> -3
	Sleep(10)
WEnd

GUIDelete($hGUI)
