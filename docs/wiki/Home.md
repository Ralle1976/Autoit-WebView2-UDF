# WebView2 UDF for AutoIt3

Welcome to the official documentation for the **WebView2 UDF** - a native Microsoft Edge WebView2 integration for AutoIt3 applications.

![WebView2 Banner](https://img.shields.io/badge/WebView2-Native%20COM-blue?style=for-the-badge&logo=microsoft-edge)
![AutoIt](https://img.shields.io/badge/AutoIt-3.3.16+-green?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-7%20|%2010%20|%2011-0078D6?style=for-the-badge&logo=windows)

---

## What is WebView2?

WebView2 is a Microsoft control that allows embedding web content (HTML, CSS, JavaScript) in native applications using the Microsoft Edge (Chromium) rendering engine.

### Key Benefits

| Feature | Description |
|---------|-------------|
| **Modern Web Standards** | Full HTML5, CSS3, ES6+ support |
| **Chromium Engine** | Same engine as Microsoft Edge |
| **GPU Acceleration** | Hardware-accelerated rendering |
| **Developer Tools** | Built-in Chrome DevTools (F12) |
| **Auto-Updates** | Evergreen Runtime updates automatically |

---

## Quick Links

### Getting Started
- [[Installation]] - Setup guide for WebView2 UDF
- [[Quick Start]] - Your first WebView2 application
- [[Examples]] - Code examples and demos

### Reference
- [[API Reference]] - Complete function documentation
- [[JavaScript Communication]] - AutoIt ↔ JavaScript patterns
- [[Troubleshooting]] - Common issues and solutions

### Showcase
- [[SQLiteManager]] - Full-featured database manager demo
- [[WV2React Framework]] - Modern UI components (27 components)

### Extensions
- [[WV2_Chart]] - Chart.js data visualization
- [[WV2_Animation]] - Anime.js animations

---

## Extensions

### WV2React Framework

A powerful extension that provides **27 ready-to-use UI components** with React-inspired programming model:

| Category | Components |
|----------|------------|
| **Basic Input** | Button, Input, Textarea, Checkbox, Radio, Switch, Select |
| **Extended** | DatePicker, TimePicker, ColorPicker, Slider, FileUpload |
| **Navigation** | Tabs, Breadcrumb, Pagination, Stepper |
| **Feedback** | Alert, Progress, Spinner, Toast, Modal |
| **Display** | Badge, Avatar, Tag, Divider, StatCard, Accordion |
| **Special** | Grid (sorting/filtering), Map (Leaflet.js), Chart, TreeView |

**Features:**
- **Dual-Mode Rendering**: Choose between DOM API (0 KB overhead) or React 18
- Light/Dark mode theming
- Customizable primary color
- Bidirectional event system
- No build tools required (CDN-based)

See [[WV2React Framework]] for complete documentation.

### WV2_Chart (Chart.js)

Data visualization with Chart.js:
- Line, Bar, Pie, Doughnut, Radar, Polar Area Charts
- Real-time data updates
- Light/Dark theme support
- Click event callbacks

See [[WV2_Chart]] for complete documentation.

### WV2_Animation (Anime.js)

Powerful animations with Anime.js:
- Property animations (translate, rotate, scale, opacity)
- Timeline system for sequences
- Stagger effects for multiple elements
- SVG path drawing and morphing
- 30+ easing functions

See [[WV2_Animation]] for complete documentation.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Your AutoIt Application              │
├─────────────────────────────────────────────────────────┤
│                     WebView2 UDF Layer                  │
│  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │ WebView2_Native │  │ WebView2_Runtime            │  │
│  │ - Create        │  │ - IsInstalled               │  │
│  │ - Navigate      │  │ - GetVersion                │  │
│  │ - ExecuteScript │  │ - CheckAndPromptInstall     │  │
│  └─────────────────┘  └─────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                 WebView2Loader.dll (Microsoft)          │
├─────────────────────────────────────────────────────────┤
│              WebView2 Runtime (Chromium Engine)         │
└─────────────────────────────────────────────────────────┘
```

---

## Features

### Native COM Implementation
Direct interface to WebView2 via WebView2Loader.dll - no third-party ActiveX controls required.

### Polling-Based Communication
Reliable JavaScript-to-AutoIt communication using a polling pattern, avoiding COM callback complexity.

### Multiple Instances
Support for multiple WebView2 controls in a single application.

### Modern Framework Support
Works with React, Vue, Angular, and other modern JavaScript frameworks.

---

## Requirements

| Component | Version | Notes |
|-----------|---------|-------|
| **Windows** | 7 SP1+ | Windows 10/11 recommended |
| **AutoIt** | 3.3.16.1+ | Required |
| **WebView2 Runtime** | Latest | Usually pre-installed on Win10/11 |

---

## File Structure

```
WebView2-UDF/
├── Include/                    # Core UDF files
│   ├── WebView2_Native.au3
│   ├── WebView2_Runtime.au3
│   ├── WebView2_Callbacks.au3
│   └── WebView2_COM.au3
├── bin/                        # All DLLs (central location)
│   ├── WebView2Loader_x64.dll
│   ├── WebView2Loader_x86.dll
│   ├── WebView2Helper_x64.dll
│   └── WebView2Helper_x86.dll
├── ReactFramework/             # WV2React UI components
├── Extensions/                 # Additional extensions
│   ├── WV2_Chart/              # Chart.js integration
│   └── WV2_Animation/          # Anime.js integration
└── SQLiteManager/              # Showcase application
```

---

## Minimal Example

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

; Check runtime
If Not _WebView2Runtime_IsInstalled() Then
    _WebView2Runtime_CheckAndPromptInstall()
EndIf

; Create GUI
Local $hGUI = GUICreate("WebView2 Browser", 1024, 768)
GUISetState(@SW_SHOW)

; Create WebView2
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 1024, 768)
If @error Then Exit MsgBox(16, "Error", "WebView2 creation failed")

; Navigate
_WebView2_Navigate($aWebView, "https://www.autoitscript.com")

; Event loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

---

## Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/Ralle1976/Autoit-WebView2-UDF/issues)
- **AutoIt Forums**: [Community support](https://www.autoitscript.com/forum/)

---

## License

MIT License - See [LICENSE](https://github.com/Ralle1976/Autoit-WebView2-UDF/blob/main/LICENSE) for details.
