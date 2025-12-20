# WebView2 UDF - Installation Guide

This guide covers the setup of the WebView2 UDF for AutoIt3.

## Automatic Setup (Recommended)

Run the setup wizard for one-click installation:

```autoit
#include "Include\WebView2_Setup.au3"
_WebView2Setup_ShowSetupWizard()
```

Or run: `Examples\Example_01_SetupWizard.au3`

The wizard handles:
- WebView2 Runtime detection and installation
- OrdoWebView2.ocx download and registration
- Installation verification

---

## System Requirements

### Operating System
- Windows 7 SP1 or later (32-bit or 64-bit)
- Windows Server 2008 R2 or later
- Recommended: Windows 10/11 (WebView2 Runtime pre-installed)

### AutoIt
- AutoIt v3.3.16.1 or higher
- Download: https://www.autoitscript.com/

### Disk Space
- ~150 MB for WebView2 Runtime (Evergreen)
- ~50 MB for OrdoWebView2.ocx (if using OrdoControl)

---

## Installation Options

### Option 1: OrdoControl (Simple)

Uses OrdoWebView2.ocx ActiveX control. Best for quick integration.

**Requirements:**
- WebView2 Runtime
- OrdoWebView2.ocx (free)

### Option 2: Native COM (Advanced)

Direct COM interface via WebView2Loader.dll. Best for complex applications.

**Requirements:**
- WebView2 Runtime
- WebView2Loader.dll (included)
- WebView2Helper DLLs (included)

**Advantages:**
- No third-party ActiveX dependencies
- Full control over WebView2 configuration
- Polling-based communication (more reliable)

---

## Manual Installation Steps

### Step 1: Install WebView2 Runtime

#### Automatic Installation

```autoit
#include "Include\WebView2_Runtime.au3"

If Not _WebView2Runtime_CheckAndPromptInstall() Then
    MsgBox(16, "Error", "WebView2 Runtime is required!")
    Exit
EndIf
```

#### Manual Installation

1. Check if already installed (Windows 10/11 usually have it pre-installed)
2. Download from: https://developer.microsoft.com/microsoft-edge/webview2/
3. Install:
   ```batch
   MicrosoftEdgeWebview2Setup.exe /silent /install
   ```

### Step 2: For OrdoControl - Install OrdoWebView2.ocx

1. Download from: https://freeware.ordoconcept.net/OrdoWebview2.php
2. Run the installer or manually register:
   ```batch
   regsvr32 OrdoWebView2.ocx
   ```

### Step 3: Copy UDF Files

Copy the Include folder to your project:

```
Include/
    WebView2.au3              ; Legacy IE control
    WebView2_Native.au3       ; Direct COM implementation
    WebView2_OrdoControl.au3  ; OrdoWebView2.ocx wrapper
    WebView2_Runtime.au3      ; Runtime detection
    WebView2_Setup.au3        ; Setup wizard
    WebView2_Callbacks.au3    ; COM callback handlers
    WebView2_COM.au3          ; COM interface definitions
    WebView2Helper_x64.dll    ; Helper DLL (64-bit)
    WebView2Helper_x86.dll    ; Helper DLL (32-bit)
    WebView2Loader.dll        ; Microsoft loader
```

---

## Verification

Run this test script:

```autoit
#include "Include\WebView2_Runtime.au3"
#include "Include\WebView2_OrdoControl.au3"

; Check Runtime
Local $sVersion = _WebView2Runtime_GetVersion()
If $sVersion <> "" Then
    ConsoleWrite("Runtime: v" & $sVersion & @CRLF)
Else
    ConsoleWrite("Runtime NOT installed!" & @CRLF)
EndIf

; Check OrdoWebView2.ocx
If _WebView2Ordo_IsOCXRegistered() Then
    ConsoleWrite("OrdoWebView2.ocx: Registered" & @CRLF)
Else
    ConsoleWrite("OrdoWebView2.ocx: NOT registered" & @CRLF)
EndIf
```

---

## Troubleshooting

### OrdoWebView2.ocx not registered

Run as Administrator:
```batch
regsvr32 "C:\Windows\System32\OrdoWebView2.ocx"
```

### WebView2 Runtime not installed

Use automatic installation:
```autoit
_WebView2Runtime_CheckAndPromptInstall()
```

Or download manually from Microsoft.

### Failed to create WebView2 control

Possible causes:
- OrdoWebView2.ocx not registered
- WebView2 Runtime not installed
- Insufficient permissions
- Invalid user data folder path

### Controller creation timeout (Native)

Ensure callback handles are stored in global variables:
```autoit
Global $__g_hWV2_CB_Env_QI = 0
Global $__g_hWV2_CB_Env_Invoke = 0
; All callback handles must be global
```

### JavaScript communication fails

Use polling method instead of WebMessage callbacks:
```autoit
; Poll every 100ms in event loop
Local $sAction = _WebView2_ExecuteScript($oWebView, "getPendingAction()")
If $sAction <> "null" Then
    ; Handle action
EndIf
```

---

## Deployment Checklist

When distributing your application:

- [ ] Include all UDF files from Include folder
- [ ] Include WebView2Loader.dll and Helper DLLs
- [ ] For OrdoControl: Include OCX installer
- [ ] Add Runtime check on application startup
- [ ] Test on Windows 7, 10, and 11
- [ ] Handle missing dependencies gracefully

---

## Resources

### Microsoft
- WebView2: https://developer.microsoft.com/microsoft-edge/webview2/
- Documentation: https://learn.microsoft.com/en-us/microsoft-edge/webview2/

### OrdoWebView2
- Official: https://freeware.ordoconcept.net/OrdoWebview2.php

### AutoIt Community
- Forums: https://www.autoitscript.com/forum/

---

## Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| AutoIt | 3.3.16.1+ | Required |
| WebView2 Runtime | Latest Evergreen | Auto-updates |
| OrdoWebView2.ocx | 2.0.9+ | December 2024 |
| Windows | 7 SP1 - 11 | Windows 10/11 recommended |
