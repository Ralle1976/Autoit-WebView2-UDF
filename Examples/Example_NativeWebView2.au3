#include <GUIConstantsEx.au3>
#include "..\Include\WebView2_Runtime.au3"
#include "..\Include\WebView2_OrdoControl.au3"

; ====================================================================================================================
; Example: Native WebView2 with OrdoWebView2.ocx
; ====================================================================================================================
; This example demonstrates the NATIVE Microsoft Edge WebView2 using OrdoWebView2.ocx
;
; REQUIREMENTS:
; 1. WebView2 Runtime (auto-checked and installed)
; 2. OrdoWebView2.ocx (must be registered - see INSTALL.md)
;
; FEATURES:
; - Real Microsoft Edge (Chromium) rendering
; - Full modern web standards (HTML5, CSS3, ES6+)
; - Supports React, Vue, Angular frameworks
; - Chrome DevTools for debugging
; - Much faster than IE control
; ====================================================================================================================

ConsoleWrite("=== WebView2 Native Example Starting ===" & @CRLF)

; ====================================================================================================================
; STEP 1: Check and Install WebView2 Runtime
; ====================================================================================================================

ConsoleWrite("[1/3] Checking WebView2 Runtime..." & @CRLF)

If Not _WebView2Runtime_CheckAndPromptInstall() Then
    MsgBox(16, "Error", "WebView2 Runtime is required but not installed." & @CRLF & @CRLF & _
        "Please install manually from:" & @CRLF & _
        "https://developer.microsoft.com/microsoft-edge/webview2/")
    Exit
EndIf

Local $sRuntimeVersion = _WebView2Runtime_GetVersion()
ConsoleWrite("   ✓ WebView2 Runtime installed: v" & $sRuntimeVersion & @CRLF)

; ====================================================================================================================
; STEP 2: Check OrdoWebView2.ocx Registration
; ====================================================================================================================

ConsoleWrite("[2/3] Checking OrdoWebView2.ocx..." & @CRLF)

If Not _WebView2Ordo_IsOCXRegistered() Then
    MsgBox(16, "OrdoWebView2.ocx Required", _
        "OrdoWebView2.ocx is not registered on this system!" & @CRLF & @CRLF & _
        "Please download and install from:" & @CRLF & _
        "https://freeware.ordoconcept.net/OrdoWebview2.php" & @CRLF & @CRLF & _
        "Or register manually using:" & @CRLF & _
        "regsvr32 OrdoWebView2.ocx" & @CRLF & @CRLF & _
        "See INSTALL.md for detailed instructions.")
    Exit
EndIf

ConsoleWrite("   ✓ OrdoWebView2.ocx is registered" & @CRLF)

; ====================================================================================================================
; STEP 3: Create GUI and WebView2 Control
; ====================================================================================================================

ConsoleWrite("[3/3] Creating WebView2 control..." & @CRLF)

; Create main window
Local $hGUI = GUICreate("Native WebView2 Demo - Microsoft Edge Chromium", 1280, 800)

; Create controls
Local $idInputURL = GUICtrlCreateInput("https://react.dev", 10, 10, 900, 25)
Local $idBtnGo = GUICtrlCreateButton("Go", 920, 10, 60, 25)
Local $idBtnBack = GUICtrlCreateButton("◀", 990, 10, 40, 25)
Local $idBtnForward = GUICtrlCreateButton("▶", 1035, 10, 40, 25)
Local $idBtnReload = GUICtrlCreateButton("↻", 1080, 10, 40, 25)
Local $idBtnDevTools = GUICtrlCreateButton("F12", 1125, 10, 40, 25)

; Info bar
Local $idLabelInfo = GUICtrlCreateLabel("Ready - Native Edge WebView2 v" & $sRuntimeVersion, 10, 40, 1260, 20)
GUICtrlSetColor($idLabelInfo, 0x008000)

; Create native WebView2 control
Local $oWebView = _WebView2Ordo_Create($hGUI, 0, 65, 1280, 735, Default, False)

If Not IsObj($oWebView) Then
    MsgBox(16, "Error", "Failed to create WebView2 control!" & @CRLF & @CRLF & _
        "Please check:" & @CRLF & _
        "1. OrdoWebView2.ocx is registered" & @CRLF & _
        "2. WebView2 Runtime is installed" & @CRLF & _
        "3. You have write permissions for user data folder")
    Exit
EndIf

ConsoleWrite("   ✓ WebView2 control created successfully" & @CRLF)
ConsoleWrite(@CRLF & "=== Application Ready ===" & @CRLF & @CRLF)
ConsoleWrite("This is NATIVE Microsoft Edge WebView2 (Chromium)!" & @CRLF)
ConsoleWrite("Try visiting: https://react.dev or https://vuejs.org" & @CRLF)
ConsoleWrite("Modern frameworks will work perfectly!" & @CRLF & @CRLF)

GUISetState(@SW_SHOW, $hGUI)

; Navigate to initial URL
_WebView2Ordo_Navigate($oWebView, "https://react.dev")
GUICtrlSetData($idLabelInfo, "Navigating to React.dev (modern React framework site)...")

; ====================================================================================================================
; STEP 4: Event Loop
; ====================================================================================================================

While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnGo
            Local $sURL = GUICtrlRead($idInputURL)
            If $sURL <> "" Then
                _WebView2Ordo_Navigate($oWebView, $sURL)
                GUICtrlSetData($idLabelInfo, "Navigating to: " & $sURL)
            EndIf

        Case $idBtnBack
            _WebView2Ordo_GoBack($oWebView)
            Sleep(500)
            Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
            GUICtrlSetData($idInputURL, $sCurrentURL)
            GUICtrlSetData($idLabelInfo, "Back: " & $sCurrentURL)

        Case $idBtnForward
            _WebView2Ordo_GoForward($oWebView)
            Sleep(500)
            Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
            GUICtrlSetData($idInputURL, $sCurrentURL)
            GUICtrlSetData($idLabelInfo, "Forward: " & $sCurrentURL)

        Case $idBtnReload
            _WebView2Ordo_Reload($oWebView)
            GUICtrlSetData($idLabelInfo, "Reloading...")

        Case $idBtnDevTools
            ; Open Chrome Developer Tools
            _WebView2Ordo_OpenDevTools($oWebView)
            GUICtrlSetData($idLabelInfo, "DevTools opened - Use F12 panel for debugging!")
    EndSwitch

    ; Update URL bar and title periodically
    Static $iLastUpdate = 0
    If TimerDiff($iLastUpdate) > 1000 Then ; Every second
        Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
        Local $sTitle = _WebView2Ordo_GetTitle($oWebView)
        If $sCurrentURL <> "" Then
            GUICtrlSetData($idInputURL, $sCurrentURL)
            WinSetTitle($hGUI, "", $sTitle & " - Native WebView2 Demo")
        EndIf
        $iLastUpdate = TimerInit()
    EndIf

    Sleep(10)
WEnd

; ====================================================================================================================
; Cleanup
; ====================================================================================================================

ConsoleWrite(@CRLF & "=== Cleaning up ===" & @CRLF)
$oWebView = 0  ; Release COM object
GUIDelete($hGUI)
ConsoleWrite("=== Application Closed ===" & @CRLF)
