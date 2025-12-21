# JavaScript Communication

This guide explains how to communicate between AutoIt and JavaScript in WebView2 applications.

---

## Overview

WebView2 UDF uses a **polling-based communication pattern** which is more reliable than COM callbacks in AutoIt's single-threaded environment.

```
┌─────────────────┐                    ┌─────────────────┐
│     AutoIt      │                    │   JavaScript    │
│    (Backend)    │                    │   (Frontend)    │
├─────────────────┤                    ├─────────────────┤
│                 │  ExecuteScript()   │                 │
│  Call JS ───────┼───────────────────►│  Function runs  │
│                 │                    │                 │
│                 │  getPendingAction()│                 │
│  Poll ◄─────────┼────────────────────┤  Return action  │
│  (every 100ms)  │                    │                 │
└─────────────────┘                    └─────────────────┘
```

---

## AutoIt → JavaScript

### Direct Function Calls

Use `_WebView2_ExecuteScript()` to call JavaScript functions:

```autoit
; Call a simple function
_WebView2_ExecuteScript($aWebView, "showMessage('Hello from AutoIt!')")

; Pass data as JSON
Local $sJSON = '{"name": "Test", "value": 42}'
_WebView2_ExecuteScript($aWebView, "processData(" & $sJSON & ")")

; Get return values
Local $sResult = _WebView2_ExecuteScript($aWebView, "calculateSum(10, 20)")
ConsoleWrite("Result: " & $sResult & @CRLF)  ; Output: 30
```

### Passing Complex Data

```autoit
; Build JSON data
Local $sData = '{"users": ['
$sData &= '{"id": 1, "name": "Max"},'
$sData &= '{"id": 2, "name": "Anna"}'
$sData &= ']}'

; Send to JavaScript
_WebView2_ExecuteScript($aWebView, "loadUsers(" & $sData & ")")
```

### Escaping Strings

When passing strings that may contain special characters:

```autoit
Func _JSEscape($sString)
    $sString = StringReplace($sString, '\', '\\')
    $sString = StringReplace($sString, '"', '\"')
    $sString = StringReplace($sString, @CR, '\r')
    $sString = StringReplace($sString, @LF, '\n')
    $sString = StringReplace($sString, @TAB, '\t')
    Return $sString
EndFunc

; Usage
Local $sUserInput = 'Line 1' & @CRLF & 'Line 2 with "quotes"'
_WebView2_ExecuteScript($aWebView, 'setText("' & _JSEscape($sUserInput) & '")')
```

---

## JavaScript → AutoIt (Polling Pattern)

Since JavaScript cannot directly call AutoIt functions, we use a polling mechanism.

### JavaScript Side

```javascript
// Global variable to store pending actions
var pendingAction = null;

// Function to queue an action for AutoIt
function sendToAutoIt(action, data) {
    pendingAction = JSON.stringify({
        action: action,
        data: data
    });
}

// Function called by AutoIt to check for pending actions
function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;  // Clear after reading
    return action;
}

// Example: Button click sends action to AutoIt
function onSaveClick() {
    var formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value
    };
    sendToAutoIt('save', formData);
}

function onExitClick() {
    sendToAutoIt('exit', null);
}
```

### AutoIt Side

```autoit
Global $g_iLastPoll = TimerInit()
Global Const $POLL_INTERVAL = 100  ; 100ms

; Main loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    ; Poll for JavaScript actions every 100ms
    If TimerDiff($g_iLastPoll) > $POLL_INTERVAL Then
        $g_iLastPoll = TimerInit()
        _CheckPendingAction()
    EndIf
    Sleep(10)
WEnd

Func _CheckPendingAction()
    Local $sResult = _WebView2_ExecuteScript($g_aWebView, "getPendingAction()")

    ; Skip if no action pending
    If $sResult = "null" Or $sResult = "" Then Return

    ; Parse JSON result (remove surrounding quotes if present)
    $sResult = StringTrimLeft($sResult, 1)
    $sResult = StringTrimRight($sResult, 1)
    $sResult = StringReplace($sResult, '\"', '"')

    ; Decode JSON (using simple parsing or JSON UDF)
    Local $oData = Json_Decode($sResult)
    Local $sAction = Json_Get($oData, '.action')
    Local $vData = Json_Get($oData, '.data')

    ; Handle actions
    Switch $sAction
        Case "save"
            _DoSave($vData)
        Case "exit"
            _DoExit()
        Case "refresh"
            _DoRefresh()
    EndSwitch
EndFunc
```

---

## Complete Example

### HTML/JavaScript (ui/app.html)

```html
<!DOCTYPE html>
<html>
<head>
    <title>AutoIt-JS Bridge</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input { width: 200px; padding: 8px; }
        button { padding: 10px 20px; margin-right: 10px; }
    </style>
</head>
<body>
    <h1>Contact Form</h1>

    <div class="form-group">
        <label>Name:</label>
        <input type="text" id="name">
    </div>

    <div class="form-group">
        <label>Email:</label>
        <input type="email" id="email">
    </div>

    <button onclick="doSave()">Save</button>
    <button onclick="doCancel()">Cancel</button>

    <div id="status"></div>

    <script>
        var pendingAction = null;

        function sendToAutoIt(action, data) {
            pendingAction = JSON.stringify({action: action, data: data});
        }

        function getPendingAction() {
            var action = pendingAction;
            pendingAction = null;
            return action;
        }

        function doSave() {
            var data = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value
            };
            sendToAutoIt('save', data);
        }

        function doCancel() {
            sendToAutoIt('cancel', null);
        }

        // Called from AutoIt
        function showStatus(message) {
            document.getElementById('status').innerHTML = message;
        }

        function setFormData(data) {
            document.getElementById('name').value = data.name || '';
            document.getElementById('email').value = data.email || '';
        }
    </script>
</body>
</html>
```

### AutoIt

```autoit
#include <GUIConstantsEx.au3>
#include "Include\WebView2_Native.au3"
#include "Include\WebView2_Runtime.au3"

Global $g_aWebView
Global $g_iLastPoll

; Create GUI
Local $hGUI = GUICreate("Contact Manager", 400, 300)
GUISetState(@SW_SHOW)

; Create WebView2
$g_aWebView = _WebView2_Create($hGUI, 0, 0, 400, 300)
If @error Then Exit MsgBox(16, "Error", "WebView2 failed")

; Load HTML
_WebView2_Navigate($g_aWebView, "file:///" & @ScriptDir & "/ui/app.html")

; Pre-fill form (after page loads)
Sleep(1000)
_WebView2_ExecuteScript($g_aWebView, 'setFormData({name: "Max Mustermann", email: "max@example.com"})')

$g_iLastPoll = TimerInit()

; Main loop
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch

    ; Poll every 100ms
    If TimerDiff($g_iLastPoll) > 100 Then
        $g_iLastPoll = TimerInit()
        _CheckPendingAction()
    EndIf

    Sleep(10)
WEnd

_WebView2_Close($g_aWebView)
Exit

Func _CheckPendingAction()
    Local $sResult = _WebView2_ExecuteScript($g_aWebView, "getPendingAction()")
    If $sResult = "null" Or $sResult = "" Then Return

    ; Simple JSON parsing
    If StringInStr($sResult, '"action":"save"') Then
        ; Extract name and email
        Local $sName = _ExtractJSONValue($sResult, "name")
        Local $sEmail = _ExtractJSONValue($sResult, "email")

        ; Save to file
        FileWrite(@ScriptDir & "\contacts.txt", $sName & "|" & $sEmail & @CRLF)

        ; Notify user
        _WebView2_ExecuteScript($g_aWebView, 'showStatus("<span style=color:green>Saved successfully!</span>")')

    ElseIf StringInStr($sResult, '"action":"cancel"') Then
        Exit
    EndIf
EndFunc

Func _ExtractJSONValue($sJSON, $sKey)
    Local $aMatch = StringRegExp($sJSON, '"' & $sKey & '":"([^"]*)"', 1)
    If IsArray($aMatch) Then Return $aMatch[0]
    Return ""
EndFunc
```

---

## Best Practices

### 1. Use Consistent Action Names

```javascript
// Good - clear, consistent naming
sendToAutoIt('file_save', data);
sendToAutoIt('file_open', data);
sendToAutoIt('edit_copy', data);

// Avoid - inconsistent
sendToAutoIt('SAVE', data);
sendToAutoIt('openFile', data);
```

### 2. Always Include Action Type

```javascript
// Good - clear structure
sendToAutoIt('update', {field: 'name', value: 'John'});

// Avoid - unclear what to do
sendToAutoIt(null, 'John');
```

### 3. Handle Errors Gracefully

```autoit
Func _CheckPendingAction()
    Local $sResult = _WebView2_ExecuteScript($g_aWebView, "getPendingAction()")

    ; Validate result
    If $sResult = "null" Or $sResult = "" Then Return
    If StringLeft($sResult, 1) <> '"' Then Return  ; Invalid format

    ; Parse and handle...
EndFunc
```

### 4. Debounce Rapid Events

```javascript
var debounceTimer = null;

function onInputChange(value) {
    // Cancel previous timer
    if (debounceTimer) clearTimeout(debounceTimer);

    // Wait 300ms before sending
    debounceTimer = setTimeout(function() {
        sendToAutoIt('search', {query: value});
    }, 300);
}
```

---

## See Also

- [[API Reference]] - Function documentation
- [[Examples]] - More code examples
- [[SQLiteManager]] - Real-world example
