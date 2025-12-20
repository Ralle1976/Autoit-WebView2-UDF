# WebView2 UDF for AutoIt3

A comprehensive User Defined Function (UDF) library for integrating **Microsoft Edge WebView2** control into AutoIt3 applications.

## Overview

This UDF enables you to embed modern web content into AutoIt3 GUI applications using the Microsoft Edge WebView2 control (Chromium engine). Create powerful hybrid applications that combine the simplicity of AutoIt with full modern web capabilities.

---

## Implementation Options

This UDF provides **three implementations**:

### 1. WebView2_Native.au3 - Direct COM Implementation
- Direct COM interface to WebView2 via WebView2Loader.dll
- Full control over environment and controller creation
- Polling-based JavaScript communication (reliable)
- No third-party ActiveX controls required
- Ideal for complex applications and custom integrations

### 2. WebView2_OrdoControl.au3 - ActiveX Wrapper (Recommended for Quick Start)
- Uses OrdoWebView2.ocx ActiveX control
- Simple API for quick WebView2 integration
- Automatic initialization and cleanup
- Best for straightforward web display scenarios

### 3. WebView2.au3 - Internet Explorer Control (Legacy)
- Uses deprecated Internet Explorer ActiveX
- For legacy compatibility only
- Not recommended for new projects

---

## Features

- **Chromium Engine**: Full Microsoft Edge rendering with HTML5, CSS3, ES6+
- **Modern Framework Support**: React, Vue, Angular work out of the box
- **JavaScript Bridge**: Bidirectional AutoIt-JavaScript communication
- **Developer Tools**: Chrome DevTools (F12) for debugging
- **GPU Acceleration**: Fast, hardware-accelerated rendering
- **Security**: Process isolation and regular security updates
- **Multiple Instances**: Support for multiple WebView2 controls
- **Automatic Setup**: One-click installation of all components

---

## Quick Start

### Step 1: Run Setup Wizard (First Time)

```autoit
#include "Include\WebView2_Setup.au3"

_WebView2Setup_ShowSetupWizard()
```

### Step 2: Use WebView2

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Setup.au3"
#include "Include\WebView2_OrdoControl.au3"

If Not _WebView2Setup_CheckAll() Then _WebView2Setup_RunCompleteSetup()

Local $hGUI = GUICreate("WebView2 App", 1024, 768)
Local $oWebView = _WebView2Ordo_Create($hGUI, 0, 0, 1024, 768)
GUISetState(@SW_SHOW, $hGUI)

_WebView2Ordo_Navigate($oWebView, "https://github.com")

While GUIGetMsg() <> -3
    Sleep(10)
WEnd
```

---

## Requirements

### System
- Windows 7 SP1 or later (Windows 10/11 recommended)
- AutoIt v3.3.16.1 or higher

### WebView2 Runtime
- Usually pre-installed on Windows 10/11
- Download: https://developer.microsoft.com/microsoft-edge/webview2/
- Auto-installable via `_WebView2Runtime_CheckAndPromptInstall()`

### For OrdoControl Implementation
- OrdoWebView2.ocx (free ActiveX control)
- Download: https://freeware.ordoconcept.net/OrdoWebview2.php

### For Native Implementation
- WebView2Loader.dll (included in this package)
- WebView2Helper DLLs (included for callback handling)

---

## Installation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

**Quick Steps:**

1. Install WebView2 Runtime (if not present)
2. For OrdoControl: Install and register OrdoWebView2.ocx
3. Copy Include folder to your project
4. Test with example scripts

---

## Architecture

### Message Loop Considerations

AutoIt's event-driven model requires special handling for WebView2 callbacks:

**Polling-Based Communication (Recommended)**

The Native implementation uses a polling mechanism for JavaScript-to-AutoIt communication. This is more reliable than COM callbacks in AutoIt's single-threaded environment:

```autoit
; In your event loop
If TimerDiff($iLastPoll) > 100 Then
    $iLastPoll = TimerInit()
    Local $sAction = _WebView2_ExecuteScript($oWebView, "getPendingAction()")
    If $sAction <> "null" Then
        ; Handle action
    EndIf
EndIf
```

**Callback System**

For COM callbacks, all DllCallback handles must be stored in global variables to prevent scope issues:

```autoit
; Global callback handles - MUST persist!
Global $__g_hWV2_CB_Env_QI = 0
Global $__g_hWV2_CB_Env_Invoke = 0
; ... etc.
```

### File Structure

```
Include/
    WebView2.au3              ; Legacy IE control
    WebView2_Native.au3       ; Direct COM implementation
    WebView2_OrdoControl.au3  ; OrdoWebView2.ocx wrapper
    WebView2_Runtime.au3      ; Runtime detection/installation
    WebView2_Setup.au3        ; Setup wizard
    WebView2_Callbacks.au3    ; COM callback handlers
    WebView2_COM.au3          ; COM interface definitions
    WebView2Helper_x64.dll    ; Helper DLL (64-bit)
    WebView2Helper_x86.dll    ; Helper DLL (32-bit)
    WebView2Loader.dll        ; Microsoft WebView2Loader

Examples/
    Example_01_SetupWizard.au3
    Example_02_SimpleBrowser.au3
    Example_03_ModernDashboard.au3
    Example_04_AutoItJavaScriptBridge.au3
    Example_NativeWebView2_Basic.au3

SQLiteManager/                ; Showcase application
    SQLiteManager.au3
    ui/

docs/
    WebView2_UDF_Manual.html

src/                          ; Helper DLL source code
```

---

## API Reference

### Runtime Detection (WebView2_Runtime.au3)

| Function | Description |
|----------|-------------|
| `_WebView2Runtime_GetVersion()` | Get installed Runtime version |
| `_WebView2Runtime_IsInstalled()` | Check if Runtime is installed |
| `_WebView2Runtime_CheckAndPromptInstall()` | Check and prompt for installation |
| `_WebView2Runtime_DownloadAndInstall()` | Download and install Runtime |

### Native WebView2 (WebView2_Native.au3)

| Function | Description |
|----------|-------------|
| `_WV2_Startup()` | Initialize WebView2 system |
| `_WV2_CreateBrowser()` | Create WebView2 browser instance |
| `_WV2_Navigate()` | Navigate to URL |
| `_WV2_NavigateToString()` | Load HTML from string |
| `_WV2_ExecuteScript()` | Execute JavaScript (sync) |
| `_WV2_ExecuteScriptAsync()` | Execute JavaScript (async) |
| `_WV2_Shutdown()` | Cleanup WebView2 resources |

### OrdoControl (WebView2_OrdoControl.au3)

| Function | Description |
|----------|-------------|
| `_WebView2Ordo_Create()` | Create WebView2 control |
| `_WebView2Ordo_Navigate()` | Navigate to URL |
| `_WebView2Ordo_ExecuteScript()` | Execute JavaScript |
| `_WebView2Ordo_GetTitle()` | Get page title |
| `_WebView2Ordo_GetURL()` | Get current URL |
| `_WebView2Ordo_GoBack()` / `GoForward()` | History navigation |
| `_WebView2Ordo_OpenDevTools()` | Open Chrome DevTools |

---

## Examples

### Example_01_SetupWizard.au3
Complete automatic setup for first-time installation. Run this first!

### Example_02_SimpleBrowser.au3
Fully functional web browser with navigation, bookmarks, and DevTools.

### Example_03_ModernDashboard.au3
HTML5/CSS3 dashboard with real-time AutoIt data integration.

### Example_04_AutoItJavaScriptBridge.au3
Bidirectional AutoIt-JavaScript communication examples.

### SQLiteManager (Showcase)
Full-featured SQLite database manager demonstrating advanced WebView2 usage with polling-based communication and pagination.

---

## JavaScript-AutoIt Communication

### From AutoIt to JavaScript

```autoit
; Call JavaScript function
_WebView2_ExecuteScript($oWebView, "showMessage('Hello from AutoIt')")

; Send data as JSON
Local $sJSON = '{"name":"Test","value":42}'
_WebView2_ExecuteScript($oWebView, "processData(" & $sJSON & ")")
```

### From JavaScript to AutoIt (Polling Method)

```javascript
// JavaScript side
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

```autoit
; AutoIt side - poll in event loop
Func _CheckPendingAction()
    Local $sResult = _WebView2_ExecuteScript($oWebView, "getPendingAction()")
    If $sResult <> "null" And $sResult <> "" Then
        Local $oJSON = Json_Decode($sResult)
        ; Process action
    EndIf
EndFunc
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| OrdoWebView2.ocx not registered | Run `regsvr32 OrdoWebView2.ocx` as Administrator |
| Runtime not installed | Use `_WebView2Runtime_CheckAndPromptInstall()` |
| Modern website doesn't render | Ensure you're using OrdoControl or Native, not legacy IE |
| Controller creation timeout | Check that callback handles are stored in global variables |
| JavaScript communication fails | Use polling method instead of callbacks |

---

## Deployment Checklist

- [ ] Include all UDF files from Include folder
- [ ] Include WebView2Loader.dll and Helper DLLs
- [ ] Include OrdoWebView2.ocx installer (if using OrdoControl)
- [ ] Add Runtime check on application startup
- [ ] Test on Windows 7, 10, and 11
- [ ] Handle missing dependencies gracefully

---

## Version History

### v2.0.0 (December 2024)
- Added Native COM implementation (WebView2_Native.au3)
- Added polling-based JavaScript communication
- Added WebView2Helper DLLs for reliable callbacks
- Added SQLiteManager showcase application
- Complete callback system with global handle management

### v1.0.0 (Initial Release)
- WebView2 support via OrdoWebView2.ocx
- Runtime detection and auto-installation
- JavaScript execution
- Navigation controls

---

## Resources

- **Microsoft WebView2**: https://developer.microsoft.com/microsoft-edge/webview2/
- **WebView2 Documentation**: https://learn.microsoft.com/microsoft-edge/webview2/
- **OrdoWebView2.ocx**: https://freeware.ordoconcept.net/OrdoWebview2.php
- **AutoIt Forums**: https://www.autoitscript.com/forum/

---

## License

MIT License - See LICENSE file for details.

---

## Contributing

Contributions are welcome! Please test on multiple Windows versions, follow AutoIt coding standards, and document new functions.
