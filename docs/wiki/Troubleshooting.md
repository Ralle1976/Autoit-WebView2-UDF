# Troubleshooting

Solutions for common WebView2 UDF issues.

---

## Installation Issues

### WebView2Loader.dll not found (Error 1)

**Symptoms:**
- `@error = 1` when calling `_WebView2_Create()`
- "DLL not found" error

**Causes:**
- DLL files missing from Include folder
- Wrong architecture (x86 vs x64)

**Solutions:**

1. Verify DLLs exist:
   ```
   Include/
   ├── WebView2Loader_x64.dll
   ├── WebView2Loader_x86.dll
   ├── WebView2Helper_x64.dll
   └── WebView2Helper_x86.dll
   ```

2. Check AutoIt architecture:
   ```autoit
   If @AutoItX64 Then
       ConsoleWrite("Using 64-bit AutoIt" & @CRLF)
   Else
       ConsoleWrite("Using 32-bit AutoIt" & @CRLF)
   EndIf
   ```

3. Copy DLLs to script directory as fallback

---

### WebView2 Runtime not installed (Error 2)

**Symptoms:**
- `@error = 2` when calling `_WebView2_Create()`
- `_WebView2Runtime_IsInstalled()` returns False

**Solutions:**

1. **Automatic installation:**
   ```autoit
   If Not _WebView2Runtime_IsInstalled() Then
       _WebView2Runtime_CheckAndPromptInstall()
   EndIf
   ```

2. **Manual installation:**
   - Download from: https://developer.microsoft.com/microsoft-edge/webview2/
   - Run: `MicrosoftEdgeWebview2Setup.exe /silent /install`

3. **Verify installation:**
   - Windows Settings → Apps → Search "WebView2"

---

### Environment creation failed (Error 3)

**Symptoms:**
- `@error = 3` when calling `_WebView2_Create()`

**Causes:**
- User data folder permissions
- Corrupted WebView2 installation
- Antivirus blocking

**Solutions:**

1. **Use custom user data folder:**
   ```autoit
   Local $sUserData = @TempDir & "\WebView2Data"
   DirCreate($sUserData)
   Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600, $sUserData)
   ```

2. **Run as administrator** (for testing)

3. **Check antivirus** - Add exclusion for your script folder

4. **Reinstall WebView2 Runtime:**
   ```batch
   MicrosoftEdgeWebview2Setup.exe /uninstall
   MicrosoftEdgeWebview2Setup.exe /install
   ```

---

### Controller creation timeout (Error 4)

**Symptoms:**
- `@error = 4` when calling `_WebView2_Create()`
- "Controller creation timed out"

**Causes:**
- Callback issues
- COM initialization problems
- System resource issues

**Solutions:**

1. **Ensure all includes are present:**
   ```autoit
   #include "Include\WebView2_Native.au3"
   #include "Include\WebView2_Callbacks.au3"
   #include "Include\WebView2_COM.au3"
   ```

2. **Check for COM conflicts:**
   ```autoit
   ; Add at script start
   ObjCreate("WScript.Shell")  ; Test COM
   If @error Then MsgBox(16, "Error", "COM not working")
   ```

3. **Increase timeout** (if supported in your UDF version)

4. **Restart computer** - clears any stuck COM objects

---

## Runtime Issues

### Page doesn't load

**Symptoms:**
- Blank WebView2 control
- No error but no content

**Solutions:**

1. **Check URL format:**
   ```autoit
   ; Correct
   _WebView2_Navigate($aWebView, "https://www.example.com")

   ; For local files (note the three slashes)
   _WebView2_Navigate($aWebView, "file:///" & @ScriptDir & "/index.html")
   ```

2. **Wait for navigation to complete:**
   ```autoit
   _WebView2_Navigate($aWebView, "https://example.com")
   Sleep(2000)  ; Give time to load
   ```

3. **Check for JavaScript errors:**
   ```autoit
   _WebView2_OpenDevTools($aWebView)  ; Press F12
   ```

---

### JavaScript execution returns empty/null

**Symptoms:**
- `_WebView2_ExecuteScript()` returns "null" or ""
- Expected data not received

**Causes:**
- Page not fully loaded
- JavaScript error
- Wrong function name

**Solutions:**

1. **Wait for page load:**
   ```autoit
   _WebView2_Navigate($aWebView, $sURL)
   Sleep(2000)  ; Wait for load

   ; Or check document.readyState
   Local $sState = ""
   While $sState <> '"complete"'
       $sState = _WebView2_ExecuteScript($aWebView, "document.readyState")
       Sleep(100)
   WEnd
   ```

2. **Verify function exists:**
   ```autoit
   Local $sCheck = _WebView2_ExecuteScript($aWebView, "typeof myFunction")
   If $sCheck = '"undefined"' Then
       ConsoleWrite("Function not found!" & @CRLF)
   EndIf
   ```

3. **Use try-catch in JavaScript:**
   ```javascript
   function safeGetData() {
       try {
           return JSON.stringify(myData);
       } catch(e) {
           return JSON.stringify({error: e.message});
       }
   }
   ```

---

### Polling pattern not working

**Symptoms:**
- `getPendingAction()` always returns "null"
- JavaScript events not reaching AutoIt

**Solutions:**

1. **Verify polling is running:**
   ```autoit
   Global $g_iLastPoll = TimerInit()
   Global $g_iPollCount = 0

   While GUIGetMsg() <> $GUI_EVENT_CLOSE
       If TimerDiff($g_iLastPoll) > 100 Then
           $g_iLastPoll = TimerInit()
           $g_iPollCount += 1
           If Mod($g_iPollCount, 100) = 0 Then
               ConsoleWrite("Poll count: " & $g_iPollCount & @CRLF)
           EndIf
           _CheckPendingAction()
       EndIf
       Sleep(10)
   WEnd
   ```

2. **Check JavaScript side:**
   ```javascript
   // Add debug logging
   function sendToAutoIt(action, data) {
       console.log('Sending to AutoIt:', action, data);
       pendingAction = JSON.stringify({action: action, data: data});
   }

   function getPendingAction() {
       var action = pendingAction;
       if (action) console.log('Returning action:', action);
       pendingAction = null;
       return action;
   }
   ```

3. **Ensure pendingAction is global:**
   ```javascript
   // At top of script, NOT inside a function
   var pendingAction = null;
   ```

---

### WebView2 not visible

**Symptoms:**
- GUI shows but WebView2 is invisible
- Control exists but nothing displayed

**Solutions:**

1. **Check dimensions:**
   ```autoit
   ; Make sure width and height are positive
   Local $aWebView = _WebView2_Create($hGUI, 0, 0, 800, 600)
   ```

2. **Ensure GUI is visible:**
   ```autoit
   GUISetState(@SW_SHOW, $hGUI)
   ; Create WebView2 AFTER showing GUI
   ```

3. **Check Z-order:**
   ```autoit
   ; WebView2 might be behind other controls
   ; Create it last or bring to front
   ```

---

## Performance Issues

### Slow page loading

**Solutions:**

1. **Use separate user data folders** for multiple instances
2. **Disable GPU acceleration** (if causing issues):
   ```autoit
   ; In WebView2 settings (if available)
   ```
3. **Minimize DOM manipulation** from AutoIt

### Memory usage increasing

**Solutions:**

1. **Always call `_WebView2_Close()`:**
   ```autoit
   While GUIGetMsg() <> $GUI_EVENT_CLOSE
       Sleep(10)
   WEnd
   _WebView2_Close($aWebView)  ; Important!
   ```

2. **Avoid memory leaks in JavaScript**
3. **Limit cached data size**

---

## Getting Help

If these solutions don't help:

1. **Enable console output:**
   ```autoit
   ConsoleWrite("Step 1 completed" & @CRLF)
   ```

2. **Check DevTools console:**
   ```autoit
   _WebView2_OpenDevTools($aWebView)
   ```

3. **Create minimal reproduction case**

4. **Report issue on GitHub:**
   https://github.com/Ralle1976/Autoit-WebView2-UDF/issues

---

## See Also

- [[Installation]] - Setup instructions
- [[FAQ]] - Frequently asked questions
- [[API Reference]] - Function documentation
