# API Reference

Complete documentation of all WebView2 UDF functions.

---

## Runtime Functions (WebView2_Runtime.au3)

Functions for detecting and installing the WebView2 Runtime.

### _WebView2Runtime_GetVersion

Returns the installed WebView2 Runtime version.

```autoit
#include "Include\WebView2_Runtime.au3"
Local $sVersion = _WebView2Runtime_GetVersion()
```

**Parameters:** None

**Return Value:**
- Success: Version string (e.g., "119.0.2151.72")
- Failure: Empty string ""

**Example:**
```autoit
Local $sVersion = _WebView2Runtime_GetVersion()
If $sVersion <> "" Then
    ConsoleWrite("WebView2 Runtime: v" & $sVersion & @CRLF)
Else
    ConsoleWrite("Runtime not installed" & @CRLF)
EndIf
```

---

### _WebView2Runtime_IsInstalled

Checks if WebView2 Runtime is installed.

```autoit
Local $bInstalled = _WebView2Runtime_IsInstalled()
```

**Parameters:** None

**Return Value:**
- `True` - Runtime is installed
- `False` - Runtime is not installed

**Example:**
```autoit
If _WebView2Runtime_IsInstalled() Then
    ; Proceed with WebView2
Else
    ; Handle missing runtime
EndIf
```

---

### _WebView2Runtime_CheckAndPromptInstall

Checks for Runtime and prompts user to install if missing.

```autoit
Local $bSuccess = _WebView2Runtime_CheckAndPromptInstall()
```

**Parameters:** None

**Return Value:**
- `True` - Runtime is available (was installed or already present)
- `False` - User cancelled or installation failed

**Behavior:**
1. Checks if Runtime is installed
2. If missing, shows confirmation dialog
3. Downloads Evergreen Bootstrapper
4. Runs installer silently
5. Waits for completion

**Example:**
```autoit
If Not _WebView2Runtime_IsInstalled() Then
    If Not _WebView2Runtime_CheckAndPromptInstall() Then
        MsgBox(16, "Error", "WebView2 Runtime required!")
        Exit
    EndIf
EndIf
```

---

## Core Functions (WebView2_Native.au3)

Main functions for creating and controlling WebView2 instances.

### _WebView2_Create

Creates a new WebView2 control in a GUI window.

```autoit
Local $aWebView = _WebView2_Create($hWnd, $iX, $iY, $iWidth, $iHeight [, $sUserDataFolder [, $bCheckRuntime]])
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $hWnd | Handle | Parent window handle |
| $iX | Integer | X position in pixels |
| $iY | Integer | Y position in pixels |
| $iWidth | Integer | Width in pixels |
| $iHeight | Integer | Height in pixels |
| $sUserDataFolder | String | (Optional) Custom user data folder. Default: @LocalAppDataDir |
| $bCheckRuntime | Boolean | (Optional) Check runtime on create. Default: True |

**Return Value:**
- Success: Array with WebView2 handles
  - `$aWebView[0]` = Environment handle
  - `$aWebView[1]` = Controller handle
  - `$aWebView[2]` = WebView handle
- Failure: Sets @error
  - 1 = WebView2Loader.dll not found
  - 2 = Runtime not installed
  - 3 = Environment creation failed
  - 4 = Controller creation timeout

**Example:**
```autoit
Local $hGUI = GUICreate("Browser", 1024, 768)
GUISetState(@SW_SHOW)

Local $aWebView = _WebView2_Create($hGUI, 0, 0, 1024, 768)
If @error Then
    MsgBox(16, "Error", "WebView2 creation failed: " & @error)
    Exit
EndIf
```

---

### _WebView2_Navigate

Navigates to a URL.

```autoit
_WebView2_Navigate($aWebView, $sURL)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array from _WebView2_Create |
| $sURL | String | URL to navigate to |

**Return Value:** None

**Example:**
```autoit
_WebView2_Navigate($aWebView, "https://www.google.com")
_WebView2_Navigate($aWebView, "file:///C:/myapp/index.html")
```

---

### _WebView2_NavigateToString

Loads HTML content from a string.

```autoit
_WebView2_NavigateToString($aWebView, $sHTML)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |
| $sHTML | String | HTML content to display |

**Return Value:** None

**Example:**
```autoit
Local $sHTML = '<!DOCTYPE html><html><body><h1>Hello World!</h1></body></html>'
_WebView2_NavigateToString($aWebView, $sHTML)
```

---

### _WebView2_ExecuteScript

Executes JavaScript and returns the result (synchronous).

```autoit
Local $sResult = _WebView2_ExecuteScript($aWebView, $sScript)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |
| $sScript | String | JavaScript code to execute |

**Return Value:**
- Success: JSON-encoded result string
- Failure: Empty string or "null"

**Notes:**
- Result is JSON-encoded (strings include quotes)
- Use `Json_Decode()` for complex objects
- For async operations, use polling pattern

**Examples:**
```autoit
; Get page title
Local $sTitle = _WebView2_ExecuteScript($aWebView, "document.title")
ConsoleWrite("Title: " & $sTitle & @CRLF)  ; Output: "My Page Title"

; Get element value
Local $sValue = _WebView2_ExecuteScript($aWebView, "document.getElementById('myInput').value")

; Call JavaScript function
_WebView2_ExecuteScript($aWebView, "showAlert('Hello from AutoIt!')")

; Get complex data
Local $sData = _WebView2_ExecuteScript($aWebView, "JSON.stringify({name: 'Test', value: 42})")
```

---

### _WebView2_ExecuteScriptAsync

Executes JavaScript asynchronously (fire-and-forget).

```autoit
_WebView2_ExecuteScriptAsync($aWebView, $sScript)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |
| $sScript | String | JavaScript code to execute |

**Return Value:** None

**Use Cases:**
- UI updates that don't need a return value
- Event triggers
- DOM manipulation

**Example:**
```autoit
; Change page content (no return needed)
_WebView2_ExecuteScriptAsync($aWebView, "document.body.style.backgroundColor = 'red'")
```

---

### _WebView2_GetSource

Gets the current URL.

```autoit
Local $sURL = _WebView2_GetSource($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** Current URL string

**Example:**
```autoit
Local $sCurrentURL = _WebView2_GetSource($aWebView)
ConsoleWrite("Current URL: " & $sCurrentURL & @CRLF)
```

---

### _WebView2_GetTitle

Gets the document title.

```autoit
Local $sTitle = _WebView2_GetTitle($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** Document title string

---

### _WebView2_GoBack

Navigates back in history.

```autoit
_WebView2_GoBack($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

---

### _WebView2_GoForward

Navigates forward in history.

```autoit
_WebView2_GoForward($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

---

### _WebView2_Reload

Reloads the current page.

```autoit
_WebView2_Reload($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

---

### _WebView2_Stop

Stops loading the current page.

```autoit
_WebView2_Stop($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

---

### _WebView2_OpenDevTools

Opens Chrome DevTools for debugging.

```autoit
_WebView2_OpenDevTools($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

**Notes:**
- Opens DevTools in a separate window
- Useful for debugging JavaScript
- Shows Console, Elements, Network, etc.

---

### _WebView2_SetZoomFactor

Sets the zoom level.

```autoit
_WebView2_SetZoomFactor($aWebView, $fZoom)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |
| $fZoom | Float | Zoom factor (1.0 = 100%) |

**Return Value:** None

**Example:**
```autoit
_WebView2_SetZoomFactor($aWebView, 1.5)  ; 150% zoom
_WebView2_SetZoomFactor($aWebView, 0.75) ; 75% zoom
```

---

### _WebView2_SetBounds

Sets the position and size of the WebView2 control.

```autoit
_WebView2_SetBounds($aWebView, $iX, $iY, $iWidth, $iHeight)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |
| $iX | Integer | X position |
| $iY | Integer | Y position |
| $iWidth | Integer | Width |
| $iHeight | Integer | Height |

**Return Value:** None

**Use Case:** Resize WebView2 when parent window is resized.

**Example:**
```autoit
; Handle window resize
Case $GUI_EVENT_RESIZED
    Local $aPos = WinGetClientSize($hGUI)
    _WebView2_SetBounds($aWebView, 0, 0, $aPos[0], $aPos[1])
```

---

### _WebView2_Close

Closes and cleans up a WebView2 instance.

```autoit
_WebView2_Close($aWebView)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| $aWebView | Array | WebView2 handle array |

**Return Value:** None

**Important:** Always call this before closing your application to properly release resources.

**Example:**
```autoit
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
GUIDelete($hGUI)
```

---

## Error Codes Summary

| Code | Constant | Description |
|------|----------|-------------|
| 1 | ERR_DLL_NOT_FOUND | WebView2Loader.dll not found |
| 2 | ERR_RUNTIME_NOT_INSTALLED | WebView2 Runtime not installed |
| 3 | ERR_ENVIRONMENT_FAILED | Environment creation failed |
| 4 | ERR_CONTROLLER_TIMEOUT | Controller creation timeout |

---

## See Also

- [[JavaScript Communication]] - Communication patterns
- [[Examples]] - Code examples
- [[Troubleshooting]] - Common issues
