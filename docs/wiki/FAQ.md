# Frequently Asked Questions

---

## General Questions

### What is WebView2?

WebView2 is a Microsoft control that embeds web technologies (HTML, CSS, JavaScript) in native applications using the Microsoft Edge (Chromium) rendering engine. It's the successor to the legacy Internet Explorer WebBrowser control.

### Why use WebView2 instead of IE WebBrowser?

| Feature | IE WebBrowser | WebView2 |
|---------|---------------|----------|
| **Engine** | Trident (IE) | Chromium (Edge) |
| **HTML5** | Limited | Full support |
| **CSS3** | Partial | Full support |
| **ES6+** | No | Full support |
| **Security** | End of life | Actively updated |
| **Performance** | Slow | GPU accelerated |
| **DevTools** | Basic | Chrome DevTools |

### What Windows versions are supported?

- Windows 7 SP1 ✅ (requires Runtime install)
- Windows 8.1 ✅ (requires Runtime install)
- Windows 10 ✅ (Runtime usually pre-installed)
- Windows 11 ✅ (Runtime pre-installed)
- Windows Server 2016+ ✅ (may require Runtime install)

### Is WebView2 free to use?

Yes! WebView2 is free for commercial and personal use. The Runtime is distributed by Microsoft at no cost.

---

## Technical Questions

### Can I use React/Vue/Angular with WebView2?

Yes! WebView2 supports all modern JavaScript frameworks:

```autoit
; Load your built React app
_WebView2_Navigate($aWebView, "file:///" & @ScriptDir & "/dist/index.html")
```

Just build your framework project and load the output files.

### How do I pass data from AutoIt to JavaScript?

Use `_WebView2_ExecuteScript()`:

```autoit
; Simple value
_WebView2_ExecuteScript($aWebView, "setName('John')")

; Complex data as JSON
Local $sJSON = '{"name": "John", "age": 30}'
_WebView2_ExecuteScript($aWebView, "setData(" & $sJSON & ")")
```

### How do I get data from JavaScript to AutoIt?

Use the polling pattern:

**JavaScript:**
```javascript
var pendingAction = null;

function sendToAutoIt(data) {
    pendingAction = JSON.stringify(data);
}

function getPendingAction() {
    var action = pendingAction;
    pendingAction = null;
    return action;
}
```

**AutoIt:**
```autoit
; In your main loop
If TimerDiff($iLastPoll) > 100 Then
    $iLastPoll = TimerInit()
    Local $sResult = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
    If $sResult <> "null" Then
        ; Process $sResult
    EndIf
EndIf
```

### Can I use callbacks instead of polling?

The WebView2 UDF uses polling because:
1. AutoIt is single-threaded
2. COM callbacks in AutoIt can be unreliable
3. Polling is simpler and more predictable

Polling every 100ms provides good responsiveness with minimal CPU usage.

### How do I debug JavaScript?

Use Chrome DevTools:

```autoit
_WebView2_OpenDevTools($aWebView)
```

Or press F12 if you've set up a keyboard accelerator.

### Can I intercept network requests?

The current UDF version focuses on core functionality. Network interception would require additional WebView2 API integration.

### Can I print from WebView2?

Use JavaScript's print function:

```autoit
_WebView2_ExecuteScript($aWebView, "window.print()")
```

### How do I save page as PDF?

This requires additional WebView2 APIs not yet exposed in the UDF. As a workaround, you can use JavaScript print to PDF.

---

## Deployment Questions

### What files do I need to distribute?

```
YourApp/
├── YourApp.exe              # Compiled script
├── Include/
│   ├── WebView2Loader_x64.dll
│   ├── WebView2Loader_x86.dll
│   ├── WebView2Helper_x64.dll
│   └── WebView2Helper_x86.dll
└── ui/                       # Your HTML/CSS/JS files
```

### Do users need to install the WebView2 Runtime?

- **Windows 10/11**: Usually pre-installed
- **Windows 7/8.1**: Must be installed

Use `_WebView2Runtime_CheckAndPromptInstall()` to handle this automatically.

### What's the Evergreen vs Fixed Version Runtime?

| Type | Description | Recommended |
|------|-------------|-------------|
| **Evergreen** | Auto-updates via Windows Update | ✅ Yes |
| **Fixed** | Specific version, you control updates | Enterprise only |

Use Evergreen for most applications.

### Can I bundle the Runtime with my app?

Yes, you can use the Evergreen Bootstrapper:
1. Include `MicrosoftEdgeWebview2Setup.exe` with your app
2. Run it silently if Runtime is missing

---

## Common Issues

### Why does my app show a blank white screen?

1. Check that the HTML file path is correct
2. Verify the file exists
3. Use `file:///` with forward slashes for local files
4. Open DevTools to check for JavaScript errors

### Why is `_WebView2_Create()` returning an error?

Check the error code:
- **1**: DLL not found → Verify Include folder
- **2**: Runtime missing → Install WebView2 Runtime
- **3**: Environment failed → Check permissions
- **4**: Timeout → Restart and try again

### My events are delayed or not firing

Ensure you're:
1. Polling frequently enough (every 100ms)
2. Not blocking the message loop with Sleep()
3. Using the correct pendingAction variable name

### WebView2 is slow on first load

First-time initialization can take 2-3 seconds as WebView2 creates the browser process. Subsequent loads are faster.

---

## Feature Requests

### Will you add feature X?

Please open an issue on GitHub:
https://github.com/Ralle1976/Autoit-WebView2-UDF/issues

Include:
- What feature you need
- Use case description
- Example code if possible

### Can I contribute?

Yes! Pull requests are welcome. Please:
1. Follow existing code style
2. Test your changes
3. Update documentation if needed

---

## See Also

- [[Troubleshooting]] - Detailed problem solutions
- [[API Reference]] - Function documentation
- [[Examples]] - Code examples
