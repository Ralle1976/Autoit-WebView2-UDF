# WebView2 UDF - Installation Guide

This guide covers the setup of the WebView2 UDF for AutoIt3 using the native COM implementation.

## System Requirements

**Operating System:**
- Windows 7 SP1 or later (32-bit or 64-bit)
- Windows Server 2008 R2 or later
- Recommended: Windows 10/11 (WebView2 Runtime pre-installed)

**AutoIt:**
- AutoIt v3.3.16.1 or higher
- Download: https://www.autoitscript.com/

**Disk Space:**
- ~150 MB for WebView2 Runtime (Evergreen)
- ~5 MB for UDF files and DLLs

## Installation Steps

### Step 1: Install WebView2 Runtime

**Automatic Installation (Recommended):**

```autoit
#include "Include\WebView2_Runtime.au3"

If Not _WebView2Runtime_IsInstalled() Then
    If Not _WebView2Runtime_CheckAndPromptInstall() Then
        MsgBox(16, "Error", "WebView2 Runtime is required!")
        Exit
    EndIf
EndIf
```

**Manual Installation:**

1. Check if already installed (Windows 10/11 usually have it pre-installed)
2. Download Evergreen Bootstrapper from: https://developer.microsoft.com/microsoft-edge/webview2/
3. Install silently:
   ```batch
   MicrosoftEdgeWebview2Setup.exe /silent /install
   ```

### Step 2: Copy UDF Files

Copy the Include folder to your project:

```
Include/
    WebView2_Native.au3       ; Native COM implementation
    WebView2_Runtime.au3      ; Runtime detection/installation
    WebView2_Callbacks.au3    ; COM callback handlers
    WebView2_COM.au3          ; COM interface definitions
    WebView2Helper_x64.dll    ; Helper DLL (64-bit)
    WebView2Helper_x86.dll    ; Helper DLL (32-bit)
    WebView2Loader_x64.dll    ; Microsoft loader (64-bit)
    WebView2Loader_x86.dll    ; Microsoft loader (32-bit)
```

**Important:** The correct architecture DLL (x86 or x64) is automatically selected based on your AutoIt version.

### Step 3: Verification

Run this test script:

```autoit
#include "Include\WebView2_Runtime.au3"
#include "Include\WebView2_Native.au3"
#include <GUIConstantsEx.au3>

; Check Runtime
Local $sVersion = _WebView2Runtime_GetVersion()
If $sVersion <> "" Then
    ConsoleWrite("Runtime installed: v" & $sVersion & @CRLF)
Else
    ConsoleWrite("Runtime NOT installed!" & @CRLF)
    Exit
EndIf

; Test WebView2 creation
Local $hGUI = GUICreate("WebView2 Test", 800, 600)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600)
If @error Then
    MsgBox(16, "Error", "Failed to create WebView2: " & @error)
    Exit
Else
    ConsoleWrite("WebView2 created successfully!" & @CRLF)
    _WebView2_Navigate($aWebView, "https://www.autoitscript.com")
EndIf

While GUIGetMsg() <> -3
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

## Troubleshooting

### WebView2 Runtime not installed

**Symptom:** Error 2 when calling `_WebView2_Create()`

**Solution:**
```autoit
_WebView2Runtime_CheckAndPromptInstall()
```

Or download manually from Microsoft: https://developer.microsoft.com/microsoft-edge/webview2/

### WebView2Loader.dll not found

**Symptom:** Error 1 when calling `_WebView2_Create()`

**Solution:**
- Verify WebView2Loader_x64.dll or WebView2Loader_x86.dll exists in Include folder
- Check that the architecture matches your AutoIt version (x86 or x64)
- Copy the correct DLL to your script directory or Include folder

### Controller creation timeout

**Symptom:** Error 4 from `_WebView2_Create()`, "Controller creation timed out"

**Possible causes:**
- Insufficient permissions
- Invalid user data folder path
- Callback handles not persisting

**Solution:**
```autoit
; Ensure all callback handles are global
; These are automatically managed by WebView2_Callbacks.au3
; but verify they are included at the top of your script
#include "Include\WebView2_Callbacks.au3"
```

### JavaScript communication fails

**Symptom:** `_WebView2_ExecuteScript()` returns empty or null

**Solution:** Use polling-based pattern:

**JavaScript:**
```javascript
var pendingAction = null;

function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;
    return action;
}
```

**AutoIt:**
```autoit
; In event loop
Local $sResult = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
If $sResult <> "null" And $sResult <> "" Then
    ; Process result
EndIf
```

### Modern website doesn't render

**Symptom:** Website shows compatibility errors or blank page

**Solution:**
- Verify WebView2 Runtime is up-to-date
- Check if website requires specific browser features
- Enable DevTools to inspect console errors: `_WebView2_OpenDevTools($aWebView)`

### Environment creation fails

**Symptom:** Error 3 from `_WebView2_Create()`

**Possible causes:**
- User data folder permissions
- Corrupted WebView2 installation

**Solution:**
```autoit
; Specify custom user data folder with write permissions
Local $sUserDataFolder = @TempDir & "\WebView2Data"
DirCreate($sUserDataFolder)
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600, $sUserDataFolder)
```

## Deployment Checklist

When distributing your application:

- [ ] Include WebView2_Native.au3
- [ ] Include WebView2_Runtime.au3
- [ ] Include WebView2_Callbacks.au3
- [ ] Include WebView2_COM.au3
- [ ] Include WebView2Loader_x64.dll and WebView2Loader_x86.dll
- [ ] Include WebView2Helper_x64.dll and WebView2Helper_x86.dll
- [ ] Add Runtime check on application startup
- [ ] Test on Windows 7, 10, and 11
- [ ] Handle missing Runtime gracefully
- [ ] Verify user data folder has write permissions

## Advanced Configuration

### Custom User Data Folder

```autoit
; Use custom folder for browser data (cookies, cache, etc.)
Local $sUserDataFolder = @AppDataDir & "\MyApp\WebView2"
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600, $sUserDataFolder)
```

### Multiple WebView2 Instances

```autoit
; Create multiple instances with separate user data
Local $aWebView1 = _WebView2_Create($hGUI1, 0, 0, 800, 600, @AppDataDir & "\App1")
Local $aWebView2 = _WebView2_Create($hGUI2, 0, 0, 800, 600, @AppDataDir & "\App2")
```

### Disable Runtime Check

```autoit
; Skip runtime check (for controlled environments)
Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600, Default, False)
```

## Resources

**Microsoft:**
- WebView2 Homepage: https://developer.microsoft.com/microsoft-edge/webview2/
- Documentation: https://learn.microsoft.com/microsoft-edge/webview2/
- Release Notes: https://developer.microsoft.com/microsoft-edge/webview2/releasenotes

**AutoIt Community:**
- Forums: https://www.autoitscript.com/forum/
- Documentation: https://www.autoitscript.com/autoit3/docs/

## Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| AutoIt | 3.3.16.1+ | Required |
| WebView2 Runtime | Latest Evergreen | Auto-updates, backward compatible |
| Windows | 7 SP1 - 11 | Windows 10/11 recommended |
| WebView2Loader.dll | From Microsoft WebView2 SDK | Included in package |
