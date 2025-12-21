# Quick Start Guide

Get started with WebView2 UDF in 5 minutes!

---

## Prerequisites

- AutoIt 3.3.16.1 or higher installed
- WebView2 UDF files copied to your project
- Windows 10/11 (or WebView2 Runtime installed)

---

## Step 1: Create Your First WebView2 App

Create a new file `MyBrowser.au3`:

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

; Check WebView2 Runtime
If Not _WebView2Runtime_IsInstalled() Then
    _WebView2Runtime_CheckAndPromptInstall()
EndIf

; Create main window
Local $hGUI = GUICreate("My First Browser", 1200, 800)
GUISetState(@SW_SHOW)

; Create WebView2 control
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 1200, 800)
If @error Then
    MsgBox(16, "Error", "Failed to create WebView2: " & @error)
    Exit
EndIf

; Navigate to a website
_WebView2_Navigate($aWebView, "https://www.google.com")

; Main event loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

; Cleanup
_WebView2_Close($aWebView)
```

Run it and you have a working browser!

---

## Step 2: Add Navigation Controls

```autoit
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

; Check Runtime
If Not _WebView2Runtime_IsInstalled() Then
    _WebView2Runtime_CheckAndPromptInstall()
EndIf

; Create GUI with toolbar
Local $hGUI = GUICreate("Browser with Controls", 1200, 850)

; Toolbar
Local $btnBack = GUICtrlCreateButton("<", 10, 10, 40, 30)
Local $btnForward = GUICtrlCreateButton(">", 55, 10, 40, 30)
Local $btnReload = GUICtrlCreateButton("R", 100, 10, 40, 30)
Local $inputURL = GUICtrlCreateInput("https://www.google.com", 150, 10, 900, 30)
Local $btnGo = GUICtrlCreateButton("Go", 1055, 10, 60, 30)

GUISetState(@SW_SHOW)

; Create WebView2 below toolbar
Local $aWebView = _WebView2_Create($hGUI, 0, 50, 1200, 800)
If @error Then Exit MsgBox(16, "Error", "WebView2 failed")

_WebView2_Navigate($aWebView, "https://www.google.com")

; Event loop
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $btnBack
            _WebView2_GoBack($aWebView)
        Case $btnForward
            _WebView2_GoForward($aWebView)
        Case $btnReload
            _WebView2_Reload($aWebView)
        Case $btnGo
            _WebView2_Navigate($aWebView, GUICtrlRead($inputURL))
    EndSwitch
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

---

## Step 3: Load Local HTML

Create `ui/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>My App</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 20px;
            text-align: center;
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        button {
            background: white;
            color: #667eea;
            border: none;
            padding: 15px 40px;
            font-size: 1.2em;
            border-radius: 30px;
            cursor: pointer;
        }
        button:hover { transform: scale(1.05); }
    </style>
</head>
<body>
    <div class="card">
        <h1>Welcome!</h1>
        <p>This is a local HTML file in WebView2</p>
        <button onclick="alert('Hello from JavaScript!')">Click Me</button>
    </div>
</body>
</html>
```

Load it in AutoIt:

```autoit
; Navigate to local file
_WebView2_Navigate($aWebView, "file:///" & @ScriptDir & "/ui/index.html")
```

---

## Step 4: Execute JavaScript

```autoit
; Change page background
_WebView2_ExecuteScript($aWebView, "document.body.style.background = 'red'")

; Get page title
Local $sTitle = _WebView2_ExecuteScript($aWebView, "document.title")
MsgBox(64, "Page Title", $sTitle)

; Call a JavaScript function
_WebView2_ExecuteScript($aWebView, "showMessage('Hello from AutoIt!')")

; Get form values
Local $sName = _WebView2_ExecuteScript($aWebView, "document.getElementById('name').value")
```

---

## Step 5: Two-Way Communication

### JavaScript (in your HTML):
```javascript
var pendingAction = null;

function sendToAutoIt(action, data) {
    pendingAction = JSON.stringify({action: action, data: data});
}

function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;
    return action;
}

// Button click handler
document.getElementById('saveBtn').onclick = function() {
    sendToAutoIt('save', {name: 'John', age: 30});
};
```

### AutoIt:
```autoit
Global $g_iLastPoll = TimerInit()

While GUIGetMsg() <> $GUI_EVENT_CLOSE
    ; Poll every 100ms
    If TimerDiff($g_iLastPoll) > 100 Then
        $g_iLastPoll = TimerInit()

        Local $sResult = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
        If $sResult <> "null" And $sResult <> "" Then
            ; Handle the action
            ConsoleWrite("Received: " & $sResult & @CRLF)
        EndIf
    EndIf
    Sleep(10)
WEnd
```

---

## Next Steps

- [[Examples]] - More detailed examples
- [[API Reference]] - All available functions
- [[JavaScript Communication]] - Advanced communication patterns
- [[SQLiteManager]] - Full application example
