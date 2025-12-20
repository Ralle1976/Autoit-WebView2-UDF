#include "..\Include\WebView2.au3"

; Advanced WebView2 Example
; This example demonstrates advanced features like zoom control and dynamic content

; Initialize WebView2
_WebView2_Startup()

; Create GUI
Local $hGUI = GUICreate("WebView2 - Advanced Features", 1200, 800)
Local $oWebView = _WebView2_Create($hGUI, 0, 100, 1200, 700)

; Create controls - Navigation bar
Local $idInputURL = GUICtrlCreateInput("https://www.github.com", 10, 10, 700, 25)
Local $idBtnGo = GUICtrlCreateButton("Go", 720, 10, 60, 25)
Local $idBtnBack = GUICtrlCreateButton("<", 790, 10, 40, 25)
Local $idBtnForward = GUICtrlCreateButton(">", 835, 10, 40, 25)
Local $idBtnReload = GUICtrlCreateButton("⟳", 880, 10, 40, 25)
Local $idBtnStop = GUICtrlCreateButton("■", 925, 10, 40, 25)

; Zoom controls
Local $idLabelZoom = GUICtrlCreateLabel("Zoom:", 10, 45, 40, 20)
Local $idBtnZoomOut = GUICtrlCreateButton("-", 55, 40, 30, 25)
Local $idLabelZoomValue = GUICtrlCreateLabel("100%", 90, 45, 50, 20)
Local $idBtnZoomIn = GUICtrlCreateButton("+", 145, 40, 30, 25)
Local $idBtnZoomReset = GUICtrlCreateButton("Reset", 180, 40, 50, 25)

; Script execution
Local $idBtnInjectCSS = GUICtrlCreateButton("Inject Dark Mode", 250, 40, 120, 25)
Local $idBtnHighlight = GUICtrlCreateButton("Highlight Links", 380, 40, 100, 25)
Local $idBtnScreenshot = GUICtrlCreateButton("Get Info", 490, 40, 80, 25)

; Status bar
Local $idStatusBar = GUICtrlCreateLabel("Ready", 10, 75, 1180, 20)

GUISetState(@SW_SHOW, $hGUI)

; Navigate to initial URL
_WebView2_Navigate($oWebView, "https://www.github.com")

; Zoom factor
Local $fZoom = 1.0

; Main event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnGo
            Local $sURL = GUICtrlRead($idInputURL)
            If $sURL <> "" Then
                _WebView2_Navigate($oWebView, $sURL)
                GUICtrlSetData($idStatusBar, "Navigating to: " & $sURL)
            EndIf

        Case $idBtnBack
            _WebView2_GoBack($oWebView)
            GUICtrlSetData($idStatusBar, "Navigated back")

        Case $idBtnForward
            _WebView2_GoForward($oWebView)
            GUICtrlSetData($idStatusBar, "Navigated forward")

        Case $idBtnReload
            _WebView2_Reload($oWebView)
            GUICtrlSetData($idStatusBar, "Page reloaded")

        Case $idBtnStop
            _WebView2_Stop($oWebView)
            GUICtrlSetData($idStatusBar, "Loading stopped")

        Case $idBtnZoomIn
            $fZoom += 0.1
            If $fZoom > 3.0 Then $fZoom = 3.0
            _WebView2_SetZoomFactor($oWebView, $fZoom)
            GUICtrlSetData($idLabelZoomValue, Round($fZoom * 100) & "%")
            GUICtrlSetData($idStatusBar, "Zoom: " & Round($fZoom * 100) & "%")

        Case $idBtnZoomOut
            $fZoom -= 0.1
            If $fZoom < 0.5 Then $fZoom = 0.5
            _WebView2_SetZoomFactor($oWebView, $fZoom)
            GUICtrlSetData($idLabelZoomValue, Round($fZoom * 100) & "%")
            GUICtrlSetData($idStatusBar, "Zoom: " & Round($fZoom * 100) & "%")

        Case $idBtnZoomReset
            $fZoom = 1.0
            _WebView2_SetZoomFactor($oWebView, $fZoom)
            GUICtrlSetData($idLabelZoomValue, "100%")
            GUICtrlSetData($idStatusBar, "Zoom reset to 100%")

        Case $idBtnInjectCSS
            ; Inject dark mode CSS
            Local $sScript = _
                "var style = document.createElement('style');" & _
                "style.innerHTML = 'body { background-color: #1e1e1e !important; color: #d4d4d4 !important; } " & _
                "a { color: #569cd6 !important; } " & _
                "div, p, span { background-color: transparent !important; }';" & _
                "document.head.appendChild(style);"
            _WebView2_ExecuteScript($oWebView, $sScript)
            GUICtrlSetData($idStatusBar, "Dark mode injected")

        Case $idBtnHighlight
            ; Highlight all links
            Local $sScript = _
                "var links = document.getElementsByTagName('a');" & _
                "for(var i=0; i<links.length; i++) {" & _
                "  links[i].style.backgroundColor = 'yellow';" & _
                "  links[i].style.color = 'black';" & _
                "  links[i].style.padding = '2px';" & _
                "}"
            _WebView2_ExecuteScript($oWebView, $sScript)
            GUICtrlSetData($idStatusBar, "Links highlighted")

        Case $idBtnScreenshot
            ; Get page information
            Local $sTitle = _WebView2_GetTitle($oWebView)
            Local $sURL = _WebView2_GetURL($oWebView)
            Local $sInfo = "Title: " & $sTitle & @CRLF & "URL: " & $sURL
            MsgBox(64, "Page Information", $sInfo)
            GUICtrlSetData($idStatusBar, "Page info retrieved")
    EndSwitch

    ; Update URL bar with current URL
    Sleep(10)
WEnd

; Cleanup
_WebView2_Shutdown()
GUIDelete($hGUI)
