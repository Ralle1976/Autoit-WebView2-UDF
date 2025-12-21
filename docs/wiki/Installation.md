# Installation Guide

This guide covers the complete setup of the WebView2 UDF for AutoIt3.

---

## System Requirements

### Operating System

| OS | Support | Notes |
|----|---------|-------|
| Windows 11 | ✅ Full | WebView2 pre-installed |
| Windows 10 | ✅ Full | WebView2 usually pre-installed |
| Windows 8.1 | ✅ Supported | Manual Runtime install required |
| Windows 7 SP1 | ✅ Supported | Manual Runtime install required |
| Windows Server 2019+ | ✅ Supported | Manual Runtime install may be required |

### Software Requirements

| Component | Minimum Version | Download |
|-----------|-----------------|----------|
| AutoIt | 3.3.16.1 | [autoitscript.com](https://www.autoitscript.com/) |
| WebView2 Runtime | Latest Evergreen | [Microsoft](https://developer.microsoft.com/microsoft-edge/webview2/) |

### Disk Space

| Component | Size |
|-----------|------|
| WebView2 Runtime | ~150 MB |
| UDF Files + DLLs | ~5 MB |

---

## Step 1: Install WebView2 Runtime

### Check if Already Installed

**Windows 10/11** usually have WebView2 pre-installed. Check via:

1. Settings → Apps → Installed Apps
2. Search for "WebView2"

Or use this AutoIt code:
```autoit
#include "Include\WebView2_Runtime.au3"

If _WebView2Runtime_IsInstalled() Then
    MsgBox(64, "Info", "WebView2 Runtime v" & _WebView2Runtime_GetVersion() & " installed")
Else
    MsgBox(48, "Warning", "WebView2 Runtime not found!")
EndIf
```

### Automatic Installation (Recommended)

Use the built-in installation helper:

```autoit
#include "Include\WebView2_Runtime.au3"

If Not _WebView2Runtime_IsInstalled() Then
    If Not _WebView2Runtime_CheckAndPromptInstall() Then
        MsgBox(16, "Error", "WebView2 Runtime is required!")
        Exit
    EndIf
EndIf
```

This will:
1. Detect missing Runtime
2. Show a dialog asking to install
3. Download and run the Evergreen Bootstrapper
4. Wait for installation to complete

### Manual Installation

1. Download the Evergreen Bootstrapper:
   https://developer.microsoft.com/microsoft-edge/webview2/

2. Run with administrator privileges:
   ```batch
   MicrosoftEdgeWebview2Setup.exe /silent /install
   ```

3. Verify installation in Apps settings

---

## Step 2: Download UDF Files

### Option A: Clone Repository

```bash
git clone https://github.com/Ralle1976/Autoit-WebView2-UDF.git
```

### Option B: Download ZIP

1. Go to [Releases](https://github.com/Ralle1976/Autoit-WebView2-UDF/releases)
2. Download the latest release ZIP
3. Extract to your project folder

---

## Step 3: Copy Include Files

Copy the `Include` folder to your project:

```
YourProject/
├── Include/
│   ├── WebView2_Native.au3       # Core functions
│   ├── WebView2_Runtime.au3      # Runtime detection
│   ├── WebView2_Callbacks.au3    # COM callbacks
│   ├── WebView2_COM.au3          # COM interfaces
│   ├── WebView2Helper_x64.dll    # 64-bit helper
│   ├── WebView2Helper_x86.dll    # 32-bit helper
│   ├── WebView2Loader_x64.dll    # 64-bit loader
│   └── WebView2Loader_x86.dll    # 32-bit loader
└── YourScript.au3
```

**Important:** The correct architecture DLL is automatically selected based on your AutoIt version.

---

## Step 4: Verification

Run this test script to verify everything works:

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Runtime.au3"
#include "Include\WebView2_Native.au3"

; Step 1: Check Runtime
ConsoleWrite("=== WebView2 Installation Test ===" & @CRLF)

Local $sVersion = _WebView2Runtime_GetVersion()
If $sVersion <> "" Then
    ConsoleWrite("[OK] Runtime installed: v" & $sVersion & @CRLF)
Else
    ConsoleWrite("[ERROR] Runtime NOT installed!" & @CRLF)
    Exit 1
EndIf

; Step 2: Test WebView2 Creation
Local $hGUI = GUICreate("WebView2 Test", 800, 600)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600)
If @error Then
    ConsoleWrite("[ERROR] WebView2 creation failed: " & @error & @CRLF)
    Exit 2
Else
    ConsoleWrite("[OK] WebView2 created successfully!" & @CRLF)
EndIf

; Step 3: Test Navigation
_WebView2_Navigate($aWebView, "https://www.autoitscript.com")
ConsoleWrite("[OK] Navigation started" & @CRLF)

ConsoleWrite("=== All tests passed! ===" & @CRLF)

; Event loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

### Expected Output

```
=== WebView2 Installation Test ===
[OK] Runtime installed: v119.0.2151.72
[OK] WebView2 created successfully!
[OK] Navigation started
=== All tests passed! ===
```

---

## Troubleshooting Installation

### Error 1: WebView2Loader.dll not found

**Symptoms:**
- `@error = 1` from `_WebView2_Create()`
- "DLL not found" message

**Solution:**
1. Verify DLLs exist in Include folder:
   - `WebView2Loader_x64.dll` (for 64-bit AutoIt)
   - `WebView2Loader_x86.dll` (for 32-bit AutoIt)
2. Check file permissions
3. Copy DLL to script directory if needed

### Error 2: Runtime not installed

**Symptoms:**
- `@error = 2` from `_WebView2_Create()`
- `_WebView2Runtime_IsInstalled()` returns False

**Solution:**
```autoit
_WebView2Runtime_CheckAndPromptInstall()
```

Or download manually from Microsoft.

### Error 3: Environment creation failed

**Symptoms:**
- `@error = 3` from `_WebView2_Create()`

**Possible Causes:**
- User data folder permissions
- Corrupted WebView2 installation

**Solution:**
```autoit
; Use custom user data folder
Local $sUserDataFolder = @TempDir & "\WebView2Data"
DirCreate($sUserDataFolder)
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600, $sUserDataFolder)
```

### Error 4: Controller creation timeout

**Symptoms:**
- `@error = 4` from `_WebView2_Create()`
- "Controller creation timed out"

**Solution:**
1. Ensure all include files are present
2. Check antivirus isn't blocking
3. Try running as administrator

---

## Next Steps

- [[Quick Start]] - Create your first WebView2 application
- [[API Reference]] - Explore all available functions
- [[Examples]] - Learn from code examples
