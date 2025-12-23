# WebView2 UDF for AutoIt3

Native Microsoft Edge WebView2 integration for AutoIt3 applications using direct COM interface.

[![WebView2](https://img.shields.io/badge/WebView2-Native%20COM-blue?style=flat-square&logo=microsoft-edge)](https://developer.microsoft.com/microsoft-edge/webview2/)
[![AutoIt](https://img.shields.io/badge/AutoIt-3.3.16+-green?style=flat-square)](https://www.autoitscript.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

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

---

## Extensions

### WV2React Framework (27 UI Components)

A powerful extension providing **27 ready-to-use UI components** with **Dual-Mode Rendering**:

| Render Mode | Description | Overhead |
|-------------|-------------|----------|
| **DOM** (Default) | Vanilla JavaScript with DOM API | 0 KB |
| **React** | React 18 with Virtual DOM | ~130 KB |

**Component Categories:**
- **Basic Input (7)**: Button, Input, Textarea, Checkbox, Radio, Switch, Select
- **Extended (5)**: DatePicker, TimePicker, ColorPicker, Slider, FileUpload
- **Navigation (4)**: Tabs, Breadcrumb, Pagination, Stepper
- **Feedback (5)**: Alert, Progress, Spinner, Toast, Modal
- **Display (6)**: Badge, Avatar, Tag, Divider, StatCard, Accordion

**Quick Example:**
```autoit
#include "ReactFramework\Include\WV2React_Core.au3"

; Initialize with DOM mode (0 KB overhead)
$oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "dom")

; Or use React mode (Virtual DOM)
$oWebView = _WV2React_Init($hGUI, 0, 0, 800, 600, "light", "#3B82F6", "react")

; Create a button
Local $aOptions[2] = ["text", "Click me!"]
_WV2React_CreateComponent("btn1", "button", $aOptions)
```

See [ReactFramework/README.md](ReactFramework/README.md) for full documentation.

### SQLiteManager (Showcase Application)

Full-featured SQLite database manager demonstrating advanced WebView2 usage with:
- Modern web UI with Tailwind CSS
- ERD visualization
- Query execution and result display
- Table management

See [SQLiteManager/](SQLiteManager/) for details.

### WV2_Chart (Chart.js Integration)

Data visualization with Chart.js:
- Line, Bar, Pie, Doughnut, Radar, Polar Area Charts
- Real-time data updates
- Light/Dark theme support
- Click event callbacks

```autoit
#include "Extensions\WV2_Chart\Include\WV2_Chart.au3"

$aWebView = _WV2Chart_Init($hGUI, 0, 0, 800, 600)
_WV2Chart_Create("chart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)
```

See [Extensions/WV2_Chart/](Extensions/WV2_Chart/) for details.

### WV2_Animation (Anime.js Integration)

Powerful animations with Anime.js:
- Property animations (translate, rotate, scale, opacity)
- Timeline system for sequences
- Stagger effects for multiple elements
- SVG path drawing and morphing
- 30+ easing functions

```autoit
#include "Extensions\WV2_Animation\Include\WV2_Animation.au3"

$aWebView = _WV2Anim_Init($hGUI, 0, 0, 800, 600)
_WV2Anim_Animate(".box", "translateX", 250, 1000, $WV2ANIM_EASE_OUT_ELASTIC)
```

See [Extensions/WV2_Animation/](Extensions/WV2_Animation/) for details.

---

## Requirements

**System:**
- Windows 7 SP1 or later (Windows 10/11 recommended)
- AutoIt v3.3.16.1 or higher

**WebView2 Runtime:**
- Usually pre-installed on Windows 10/11
- Download: https://developer.microsoft.com/microsoft-edge/webview2/
- Auto-check via `_WebView2Runtime_CheckAndPromptInstall()`

## Installation

See [INSTALL.md](INSTALL.md) for detailed instructions.

**Quick Steps:**
1. Install WebView2 Runtime (if not present)
2. Copy Include folder to your project
3. Copy DLLs from `bin/` to your script directory (or use relative paths)
4. Test with example scripts

## File Structure

```
WebView2-UDF/
├── Include/                      ; Core UDF files
│   ├── WebView2_Native.au3       ; Native COM implementation
│   ├── WebView2_Runtime.au3      ; Runtime detection/installation
│   ├── WebView2_Callbacks.au3    ; COM callback handlers
│   └── WebView2_COM.au3          ; COM interface definitions
│
├── bin/                          ; All DLLs (central location)
│   ├── WebView2Loader_x64.dll    ; Microsoft loader (64-bit)
│   ├── WebView2Loader_x86.dll    ; Microsoft loader (32-bit)
│   ├── WebView2Helper_x64.dll    ; Helper DLL (64-bit)
│   └── WebView2Helper_x86.dll    ; Helper DLL (32-bit)
│
├── ReactFramework/               ; WV2React UI Framework
│   ├── Include/
│   │   ├── WV2React_Core.au3     ; Core with Dual-Mode
│   │   ├── WV2React_Grid.au3     ; Data Grid component
│   │   ├── WV2React_Map.au3      ; Leaflet.js maps
│   │   └── js/
│   │       ├── dom/              ; DOM API components
│   │       └── react/            ; React components
│   └── Examples/
│       └── ReactFramework_Showcase.au3
│
├── SQLiteManager/                ; SQLite Manager showcase
│
├── Extensions/                   ; Additional Extensions
│   ├── WV2_Chart/                ; Chart.js integration
│   │   ├── Include/WV2_Chart.au3
│   │   └── Examples/
│   └── WV2_Animation/            ; Anime.js integration
│       ├── Include/WV2_Animation.au3
│       └── Examples/
│
└── Examples/                     ; Basic examples
    ├── Example_NativeWebView2_Basic.au3
    ├── Example_ExecuteScript.au3
    └── Example_HTMLString.au3
```

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

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Runtime not installed | Use `_WebView2Runtime_CheckAndPromptInstall()` |
| WebView2Loader.dll not found | Check `bin/` folder or copy DLLs to script directory |
| Controller creation timeout | Ensure callback handles are global variables |
| JavaScript communication fails | Use polling method with `getPendingAction()` |
| Modern website doesn't render | Verify Runtime is installed and up-to-date |

## Deployment Checklist

- [ ] Include WebView2_Native.au3, WebView2_Runtime.au3
- [ ] Include WebView2Loader.dll and Helper DLLs (from `bin/`)
- [ ] Include WebView2_Callbacks.au3, WebView2_COM.au3
- [ ] Add Runtime check on application startup
- [ ] Test on target Windows versions
- [ ] Handle missing Runtime gracefully

## Resources

- **Microsoft WebView2**: https://developer.microsoft.com/microsoft-edge/webview2/
- **WebView2 Documentation**: https://learn.microsoft.com/microsoft-edge/webview2/
- **AutoIt Forums**: https://www.autoitscript.com/forum/
- **Wiki**: https://github.com/Ralle1976/Autoit-WebView2-UDF/wiki

## License

MIT License - See LICENSE file for details.
