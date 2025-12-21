# Examples

Practical code examples for common WebView2 use cases.

---

## Basic Examples

### Minimal Browser

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

If Not _WebView2Runtime_IsInstalled() Then
    _WebView2Runtime_CheckAndPromptInstall()
EndIf

Local $hGUI = GUICreate("Minimal Browser", 1024, 768)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 1024, 768)
_WebView2_Navigate($aWebView, "https://www.autoitscript.com")

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

---

### Display Local HTML

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"

Local $hGUI = GUICreate("Local HTML", 800, 600)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600)

; HTML as string
Local $sHTML = '<!DOCTYPE html>' & @CRLF
$sHTML &= '<html><head><style>'
$sHTML &= 'body { font-family: Arial; background: #1a1a2e; color: #eee; padding: 40px; }'
$sHTML &= 'h1 { color: #0f9; }'
$sHTML &= '</style></head><body>'
$sHTML &= '<h1>Hello from AutoIt!</h1>'
$sHTML &= '<p>This HTML was generated in AutoIt and displayed in WebView2.</p>'
$sHTML &= '</body></html>'

_WebView2_NavigateToString($aWebView, $sHTML)

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

---

### Resizable WebView2

```autoit
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "Include\WebView2_Native.au3"

Global $g_aWebView, $g_hGUI

$g_hGUI = GUICreate("Resizable Browser", 1024, 768, -1, -1, BitOR($WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_MINIMIZEBOX))
GUISetState(@SW_SHOW)

$g_aWebView = _WebView2_Create($g_hGUI, 0, 0, 1024, 768)
_WebView2_Navigate($g_aWebView, "https://www.google.com")

GUIRegisterMsg($WM_SIZE, "_WM_SIZE")

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($g_aWebView)

Func _WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
    If $hWnd = $g_hGUI Then
        Local $iWidth = BitAND($lParam, 0xFFFF)
        Local $iHeight = BitShift($lParam, 16)
        _WebView2_SetBounds($g_aWebView, 0, 0, $iWidth, $iHeight)
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc
```

---

## JavaScript Integration

### Execute JavaScript and Get Results

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"

Local $hGUI = GUICreate("JS Examples", 800, 600)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600)
_WebView2_Navigate($aWebView, "https://www.example.com")

Sleep(2000)  ; Wait for page to load

; Get document title
Local $sTitle = _WebView2_ExecuteScript($aWebView, "document.title")
ConsoleWrite("Title: " & $sTitle & @CRLF)

; Get current URL
Local $sURL = _WebView2_ExecuteScript($aWebView, "window.location.href")
ConsoleWrite("URL: " & $sURL & @CRLF)

; Count all links
Local $sLinkCount = _WebView2_ExecuteScript($aWebView, "document.querySelectorAll('a').length")
ConsoleWrite("Links: " & $sLinkCount & @CRLF)

; Get all link texts
Local $sLinks = _WebView2_ExecuteScript($aWebView, _
    "Array.from(document.querySelectorAll('a')).map(a => a.textContent).join(', ')")
ConsoleWrite("Link texts: " & $sLinks & @CRLF)

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

---

### Manipulate DOM

```autoit
; After page loads...

; Change background color
_WebView2_ExecuteScript($aWebView, "document.body.style.backgroundColor = '#333'")

; Add custom CSS
Local $sCSS = "* { font-family: 'Comic Sans MS' !important; }"
_WebView2_ExecuteScript($aWebView, _
    "var style = document.createElement('style');" & _
    "style.textContent = '" & $sCSS & "';" & _
    "document.head.appendChild(style)")

; Hide all images
_WebView2_ExecuteScript($aWebView, _
    "document.querySelectorAll('img').forEach(i => i.style.display = 'none')")

; Add a banner at the top
_WebView2_ExecuteScript($aWebView, _
    "var banner = document.createElement('div');" & _
    "banner.style = 'background: red; color: white; padding: 10px; text-align: center';" & _
    "banner.textContent = 'Added by AutoIt!';" & _
    "document.body.insertBefore(banner, document.body.firstChild)")
```

---

## Forms and User Input

### Form Data Extraction

HTML file (`form.html`):
```html
<!DOCTYPE html>
<html>
<head><title>Form Example</title></head>
<body>
    <h1>Registration Form</h1>
    <form id="regForm">
        <input type="text" id="username" placeholder="Username"><br><br>
        <input type="email" id="email" placeholder="Email"><br><br>
        <select id="country">
            <option value="DE">Germany</option>
            <option value="AT">Austria</option>
            <option value="CH">Switzerland</option>
        </select><br><br>
        <input type="checkbox" id="newsletter"> Subscribe to newsletter<br><br>
        <button type="button" onclick="submitForm()">Submit</button>
    </form>
    <script>
        var pendingAction = null;

        function submitForm() {
            var data = {
                username: document.getElementById('username').value,
                email: document.getElementById('email').value,
                country: document.getElementById('country').value,
                newsletter: document.getElementById('newsletter').checked
            };
            pendingAction = JSON.stringify({action: 'submit', data: data});
        }

        function getPendingAction() {
            var a = pendingAction;
            pendingAction = null;
            return a;
        }

        function showResult(msg) {
            alert(msg);
        }
    </script>
</body>
</html>
```

AutoIt:
```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"

Global $g_aWebView, $g_iLastPoll

Local $hGUI = GUICreate("Form Example", 600, 500)
GUISetState(@SW_SHOW)

$g_aWebView = _WebView2_Create($hGUI, 0, 0, 600, 500)
_WebView2_Navigate($g_aWebView, "file:///" & @ScriptDir & "/form.html")

$g_iLastPoll = TimerInit()

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    If TimerDiff($g_iLastPoll) > 100 Then
        $g_iLastPoll = TimerInit()
        _CheckAction()
    EndIf
    Sleep(10)
WEnd

_WebView2_Close($g_aWebView)

Func _CheckAction()
    Local $sResult = _WebView2_ExecuteScript($g_aWebView, "getPendingAction()")
    If $sResult = "null" Or $sResult = "" Then Return

    ; Parse JSON (simplified)
    If StringInStr($sResult, '"action":"submit"') Then
        Local $sUsername = StringRegExpReplace($sResult, '.*"username":"([^"]*)".*', '$1')
        Local $sEmail = StringRegExpReplace($sResult, '.*"email":"([^"]*)".*', '$1')

        ConsoleWrite("Registration: " & $sUsername & " / " & $sEmail & @CRLF)

        ; Save to file
        FileWrite(@ScriptDir & "\registrations.txt", $sUsername & "|" & $sEmail & @CRLF)

        ; Confirm to user
        _WebView2_ExecuteScript($g_aWebView, "showResult('Registration successful!')")
    EndIf
EndFunc
```

---

## DevTools Integration

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"

Local $hGUI = GUICreate("DevTools Demo", 1200, 800)
Local $btnDevTools = GUICtrlCreateButton("Open DevTools (F12)", 10, 10, 150, 30)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 50, 1200, 750)
_WebView2_Navigate($aWebView, "https://www.example.com")

Local $hAccel = _CreateAccelerators()
GUISetAccelerators($hAccel)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $btnDevTools
            _WebView2_OpenDevTools($aWebView)
    EndSwitch
    Sleep(10)
WEnd

_WebView2_Close($aWebView)

Func _CreateAccelerators()
    Local $aAccel[1][2] = [["{F12}", $btnDevTools]]
    Return $aAccel
EndFunc
```

---

## Multiple WebView2 Instances

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"

; Create main window with two panes
Local $hGUI = GUICreate("Dual Browser", 1400, 700)
GUISetState(@SW_SHOW)

; Left WebView2 (separate user data folder)
Local $aWebView1 = _WebView2_Create($hGUI, 0, 0, 695, 700, @TempDir & "\WebView2_Left")
_WebView2_Navigate($aWebView1, "https://www.google.com")

; Right WebView2 (separate user data folder)
Local $aWebView2 = _WebView2_Create($hGUI, 705, 0, 695, 700, @TempDir & "\WebView2_Right")
_WebView2_Navigate($aWebView2, "https://www.bing.com")

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView1)
_WebView2_Close($aWebView2)
```

---

## See Also

- [[Quick Start]] - Getting started guide
- [[API Reference]] - Complete function list
- [[JavaScript Communication]] - JS ↔ AutoIt patterns
- [[SQLiteManager]] - Full application example
