#include "..\Include\WebView2.au3"

; Basic WebView2 Navigation Example
; This example demonstrates how to create a WebView2 control and navigate to a URL

; Initialize WebView2
_WebView2_Startup()

; Create GUI
Local $hGUI = GUICreate("WebView2 - Basic Navigation", 1024, 768)
Local $oWebView = _WebView2_Create($hGUI, 0, 50, 1024, 718)

; Create navigation controls
Local $idInputURL = GUICtrlCreateInput("https://www.autoitscript.com", 10, 10, 800, 25)
Local $idBtnGo = GUICtrlCreateButton("Go", 820, 10, 60, 25)
Local $idBtnBack = GUICtrlCreateButton("<", 890, 10, 40, 25)
Local $idBtnForward = GUICtrlCreateButton(">", 935, 10, 40, 25)
Local $idBtnReload = GUICtrlCreateButton("⟳", 980, 10, 40, 25)

GUISetState(@SW_SHOW, $hGUI)

; Navigate to initial URL
_WebView2_Navigate($oWebView, "https://www.autoitscript.com")

; Main event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnGo
            Local $sURL = GUICtrlRead($idInputURL)
            If $sURL <> "" Then _WebView2_Navigate($oWebView, $sURL)

        Case $idBtnBack
            _WebView2_GoBack($oWebView)

        Case $idBtnForward
            _WebView2_GoForward($oWebView)

        Case $idBtnReload
            _WebView2_Reload($oWebView)
    EndSwitch
WEnd

; Cleanup
_WebView2_Shutdown()
GUIDelete($hGUI)
