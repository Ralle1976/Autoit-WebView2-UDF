#include "..\Include\WebView2.au3"

; WebView2 Execute JavaScript Example
; This example demonstrates how to execute JavaScript code in the WebView2 control

; Initialize WebView2
_WebView2_Startup()

; Create GUI
Local $hGUI = GUICreate("WebView2 - Execute JavaScript", 1024, 768)
Local $oWebView = _WebView2_Create($hGUI, 0, 100, 1024, 668)

; Create controls
Local $idInputScript = GUICtrlCreateInput("document.body.style.backgroundColor = 'lightblue';", 10, 10, 800, 25)
Local $idBtnExecute = GUICtrlCreateButton("Execute Script", 820, 10, 100, 25)
Local $idBtnGetTitle = GUICtrlCreateButton("Get Title", 10, 40, 100, 25)
Local $idBtnGetURL = GUICtrlCreateButton("Get URL", 120, 40, 100, 25)
Local $idBtnGetSource = GUICtrlCreateButton("Get Source", 230, 40, 100, 25)
Local $idLabelInfo = GUICtrlCreateLabel("", 10, 70, 1000, 20)

GUISetState(@SW_SHOW, $hGUI)

; Navigate to a test page
_WebView2_Navigate($oWebView, "https://www.autoitscript.com")

; Main event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnExecute
            Local $sScript = GUICtrlRead($idInputScript)
            If $sScript <> "" Then
                _WebView2_ExecuteScript($oWebView, $sScript)
                GUICtrlSetData($idLabelInfo, "Script executed successfully!")
            EndIf

        Case $idBtnGetTitle
            Local $sTitle = _WebView2_GetTitle($oWebView)
            GUICtrlSetData($idLabelInfo, "Title: " & $sTitle)
            MsgBox(64, "Page Title", $sTitle)

        Case $idBtnGetURL
            Local $sURL = _WebView2_GetURL($oWebView)
            GUICtrlSetData($idLabelInfo, "URL: " & $sURL)
            MsgBox(64, "Current URL", $sURL)

        Case $idBtnGetSource
            Local $sSource = _WebView2_GetSource($oWebView)
            GUICtrlSetData($idLabelInfo, "Source retrieved (" & StringLen($sSource) & " characters)")
            ; You could save this to a file or display in another window
            ClipPut($sSource)
            MsgBox(64, "HTML Source", "HTML source copied to clipboard! (" & StringLen($sSource) & " characters)")
    EndSwitch
WEnd

; Cleanup
_WebView2_Shutdown()
GUIDelete($hGUI)
