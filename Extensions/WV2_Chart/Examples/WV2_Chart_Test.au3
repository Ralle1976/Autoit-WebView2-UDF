#include <GUIConstantsEx.au3>
#include "..\..\..\Include\WebView2_Native.au3"

; Einfacher Test - prüft ob NavigateToString funktioniert

Global $g_hGUI, $g_aWebView

$g_hGUI = GUICreate("WebView2 NavigateToString Test", 800, 600)
GUISetState(@SW_SHOW)

ConsoleWrite("[Test] Creating WebView2..." & @CRLF)
$g_aWebView = _WebView2_Create($g_hGUI, 10, 10, 780, 580)
If @error Then
    MsgBox(16, "Error", "WebView2 creation failed: " & @error)
    Exit
EndIf
ConsoleWrite("[Test] WebView2 created!" & @CRLF)

; Einfache Test-HTML
Local $sHtml = '<!DOCTYPE html>' & @CRLF
$sHtml &= '<html><head><title>Test</title></head>' & @CRLF
$sHtml &= '<body style="background:#3B82F6;color:white;font-size:48px;display:flex;justify-content:center;align-items:center;height:100vh;">' & @CRLF
$sHtml &= '<div id="msg">WebView2 NavigateToString funktioniert!</div>' & @CRLF
$sHtml &= '<script>console.log("JS loaded"); window.testVar = "success";</script>' & @CRLF
$sHtml &= '</body></html>'

ConsoleWrite("[Test] HTML length: " & StringLen($sHtml) & " chars" & @CRLF)
ConsoleWrite("[Test] Calling NavigateToString..." & @CRLF)

Local $bResult = _WebView2_NavigateToString($g_aWebView, $sHtml)
ConsoleWrite("[Test] NavigateToString result: " & $bResult & " @error=" & @error & @CRLF)

Sleep(2000)

ConsoleWrite("[Test] Testing ExecuteScript..." & @CRLF)
Local $sResult = _WebView2_ExecuteScript($g_aWebView, "document.getElementById('msg').innerText", 2000)
ConsoleWrite("[Test] Script result: " & $sResult & @CRLF)

Local $sResult2 = _WebView2_ExecuteScript($g_aWebView, "window.testVar", 2000)
ConsoleWrite("[Test] testVar result: " & $sResult2 & @CRLF)

; Main loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($g_aWebView)
