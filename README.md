# WebView2 UDF for AutoIt3

Native Microsoft Edge WebView2 integration for AutoIt3 applications using direct COM interface.

## Overview

This UDF enables embedding modern web content into AutoIt3 GUI applications using the Microsoft Edge WebView2 control (Chromium engine). The implementation uses direct COM interface to WebView2Loader.dll without third-party ActiveX dependencies.

## Features

- **Native COM Implementation**: Direct interface to WebView2 via WebView2Loader.dll
- **Chromium Engine**: Full HTML5, CSS3, ES6+ support
- **Modern Framework Support**: React, Vue, Angular compatible
- **JavaScript Integration**: Polling-based bidirectional communication
- **Developer Tools**: Chrome DevTools (F12) for debugging
- **GPU Acceleration**: Hardware-accelerated rendering
- **Multiple Instances**: Support for multiple WebView2 controls
- **No Third-Party Dependencies**: No ActiveX controls required

## Requirements

**System:**
- Windows 7 SP1 or later (Windows 10/11 recommended)
- AutoIt v3.3.16.1 or higher

**WebView2 Runtime:**
- Usually pre-installed on Windows 10/11
- Download: https://developer.microsoft.com/microsoft-edge/webview2/
- Auto-check via `_WebView2Runtime_CheckAndPromptInstall()`

**Included Components:**
- WebView2Loader.dll (Microsoft WebView2 SDK)
- WebView2Helper DLLs (x86/x64 for callback handling)

## Installation

See [INSTALL.md](INSTALL.md) for detailed instructions.

**Quick Steps:**
1. Install WebView2 Runtime (if not present)
2. Copy Include folder to your project
3. Test with example scripts

## Quick Start

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

; Check runtime
If Not _WebView2Runtime_IsInstalled() Then
    _WebView2Runtime_CheckAndPromptInstall()
    Exit
EndIf

; Create GUI
Local $hGUI = GUICreate("WebView2 Browser", 1024, 768)
GUISetState(@SW_SHOW)

; Create WebView2
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 1024, 768)
If @error Then Exit MsgBox(16, "Error", "Failed to create WebView2")

; Navigate
_WebView2_Navigate($aWebView, "https://github.com")

; Event loop
While GUIGetMsg() <> -3
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

## Architecture

### File Structure

```
Include/
    WebView2_Native.au3       ; Native COM implementation
    WebView2_Runtime.au3      ; Runtime detection/installation
    WebView2_Callbacks.au3    ; COM callback handlers
    WebView2_COM.au3          ; COM interface definitions
    WebView2Helper_x64.dll    ; Helper DLL (64-bit)
    WebView2Helper_x86.dll    ; Helper DLL (32-bit)
    WebView2Loader.dll        ; Microsoft WebView2Loader

Examples/
    Example_NativeWebView2_Basic.au3
    Example_ExecuteScript.au3
    Example_HTMLString.au3

SQLiteManager/                ; Showcase application
    SQLiteManager.au3
    ui/
```

### Communication Pattern

The implementation uses polling-based JavaScript communication, which is more reliable than COM callbacks in AutoIt's single-threaded environment:

```autoit
; In your event loop
If TimerDiff($iLastPoll) > 100 Then
    $iLastPoll = TimerInit()
    Local $sAction = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
    If $sAction <> "null" Then
        ; Handle action
    EndIf
EndIf
```

## API Reference

### Runtime Detection (WebView2_Runtime.au3)

| Function | Description |
|----------|-------------|
| `_WebView2Runtime_GetVersion()` | Get installed Runtime version |
| `_WebView2Runtime_IsInstalled()` | Check if Runtime is installed |
| `_WebView2Runtime_CheckAndPromptInstall()` | Check and prompt for installation |

### Core Functions (WebView2_Native.au3)

| Function | Description |
|----------|-------------|
| `_WebView2_Create()` | Create WebView2 instance |
| `_WebView2_Navigate()` | Navigate to URL |
| `_WebView2_NavigateToString()` | Load HTML from string |
| `_WebView2_ExecuteScript()` | Execute JavaScript (synchronous) |
| `_WebView2_ExecuteScriptAsync()` | Execute JavaScript (asynchronous) |
| `_WebView2_GetSource()` | Get current URL |
| `_WebView2_GetTitle()` | Get document title |
| `_WebView2_GoBack()` | Navigate back |
| `_WebView2_GoForward()` | Navigate forward |
| `_WebView2_Reload()` | Reload page |
| `_WebView2_OpenDevTools()` | Open Chrome DevTools |
| `_WebView2_SetZoomFactor()` | Set zoom level |
| `_WebView2_SetBounds()` | Set control bounds |
| `_WebView2_Close()` | Close WebView2 instance |

## JavaScript-AutoIt Communication

### From AutoIt to JavaScript

```autoit
; Execute JavaScript
_WebView2_ExecuteScript($aWebView, "showMessage('Hello from AutoIt')")

; Pass JSON data
Local $sJSON = '{"name":"Test","value":42}'
_WebView2_ExecuteScript($aWebView, "processData(" & $sJSON & ")")
```

### From JavaScript to AutoIt (Polling Pattern)

**JavaScript side:**
```javascript
var pendingAction = null;

function requestFromAutoIt(action, data) {
    pendingAction = JSON.stringify({action: action, data: data});
}

function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;
    return action;
}
```

**AutoIt side:**
```autoit
Func _CheckPendingAction()
    Local $sResult = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
    If $sResult <> "null" And $sResult <> "" Then
        Local $oJSON = Json_Decode($sResult)
        ; Process action
    EndIf
EndFunc
```

## Examples

**Example_NativeWebView2_Basic.au3**
Basic WebView2 setup and navigation.

**Example_ExecuteScript.au3**
JavaScript execution and data exchange.

**Example_HTMLString.au3**
Load HTML content from string.

**SQLiteManager (Showcase)**
Full-featured SQLite database manager demonstrating advanced WebView2 usage with polling-based communication and pagination.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Runtime not installed | Use `_WebView2Runtime_CheckAndPromptInstall()` |
| WebView2Loader.dll not found | Check Include folder for architecture-specific DLL |
| Controller creation timeout | Ensure callback handles are global variables |
| JavaScript communication fails | Use polling method with `getPendingAction()` |
| Modern website doesn't render | Verify Runtime is installed and up-to-date |

## Deployment Checklist

- [ ] Include WebView2_Native.au3, WebView2_Runtime.au3
- [ ] Include WebView2Loader.dll and Helper DLLs (x86/x64)
- [ ] Include WebView2_Callbacks.au3, WebView2_COM.au3
- [ ] Add Runtime check on application startup
- [ ] Test on target Windows versions
- [ ] Handle missing Runtime gracefully

## Resources

- **Microsoft WebView2**: https://developer.microsoft.com/microsoft-edge/webview2/
- **WebView2 Documentation**: https://learn.microsoft.com/microsoft-edge/webview2/
- **AutoIt Forums**: https://www.autoitscript.com/forum/

## License

MIT License - See LICENSE file for details.
