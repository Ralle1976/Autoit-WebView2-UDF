#include "..\Include\WebView2.au3"

; WebView2 HTML String Example
; This example demonstrates how to load HTML content from a string

; Initialize WebView2
_WebView2_Startup()

; Create GUI
Local $hGUI = GUICreate("WebView2 - HTML String", 800, 600)
Local $oWebView = _WebView2_Create($hGUI, 0, 40, 800, 560)

; Create controls
Local $idBtnExample1 = GUICtrlCreateButton("Example 1: Simple HTML", 10, 10, 120, 25)
Local $idBtnExample2 = GUICtrlCreateButton("Example 2: Styled HTML", 140, 10, 120, 25)
Local $idBtnExample3 = GUICtrlCreateButton("Example 3: Interactive", 270, 10, 120, 25)
Local $idBtnExample4 = GUICtrlCreateButton("Example 4: Chart", 400, 10, 120, 25)

GUISetState(@SW_SHOW, $hGUI)

; Example HTML strings
Local $sHTML1 = _
    '<!DOCTYPE html>' & @CRLF & _
    '<html>' & @CRLF & _
    '<head><title>Simple HTML</title></head>' & @CRLF & _
    '<body>' & @CRLF & _
    '<h1>Hello from WebView2!</h1>' & @CRLF & _
    '<p>This is a simple HTML page loaded from a string.</p>' & @CRLF & _
    '</body>' & @CRLF & _
    '</html>'

Local $sHTML2 = _
    '<!DOCTYPE html>' & @CRLF & _
    '<html>' & @CRLF & _
    '<head>' & @CRLF & _
    '<title>Styled HTML</title>' & @CRLF & _
    '<style>' & @CRLF & _
    'body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 50px; }' & @CRLF & _
    'h1 { font-size: 3em; text-shadow: 2px 2px 4px rgba(0,0,0,0.5); }' & @CRLF & _
    'p { font-size: 1.2em; line-height: 1.6; }' & @CRLF & _
    '.card { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin-top: 20px; }' & @CRLF & _
    '</style>' & @CRLF & _
    '</head>' & @CRLF & _
    '<body>' & @CRLF & _
    '<h1>Styled WebView2 Content</h1>' & @CRLF & _
    '<div class="card">' & @CRLF & _
    '<h2>Beautiful Design</h2>' & @CRLF & _
    '<p>This demonstrates how you can create beautiful, styled HTML content directly in AutoIt!</p>' & @CRLF & _
    '</div>' & @CRLF & _
    '</body>' & @CRLF & _
    '</html>'

Local $sHTML3 = _
    '<!DOCTYPE html>' & @CRLF & _
    '<html>' & @CRLF & _
    '<head>' & @CRLF & _
    '<title>Interactive HTML</title>' & @CRLF & _
    '<style>' & @CRLF & _
    'body { font-family: Arial, sans-serif; padding: 50px; background: #f0f0f0; }' & @CRLF & _
    'button { background: #4CAF50; color: white; padding: 15px 32px; border: none; cursor: pointer; font-size: 16px; border-radius: 5px; margin: 5px; }' & @CRLF & _
    'button:hover { background: #45a049; }' & @CRLF & _
    '#counter { font-size: 2em; color: #333; margin: 20px 0; }' & @CRLF & _
    '</style>' & @CRLF & _
    '</head>' & @CRLF & _
    '<body>' & @CRLF & _
    '<h1>Interactive Counter</h1>' & @CRLF & _
    '<div id="counter">Count: 0</div>' & @CRLF & _
    '<button onclick="increment()">Increment</button>' & @CRLF & _
    '<button onclick="decrement()">Decrement</button>' & @CRLF & _
    '<button onclick="reset()">Reset</button>' & @CRLF & _
    '<script>' & @CRLF & _
    'let count = 0;' & @CRLF & _
    'function increment() { count++; updateDisplay(); }' & @CRLF & _
    'function decrement() { count--; updateDisplay(); }' & @CRLF & _
    'function reset() { count = 0; updateDisplay(); }' & @CRLF & _
    'function updateDisplay() { document.getElementById("counter").innerHTML = "Count: " + count; }' & @CRLF & _
    '</script>' & @CRLF & _
    '</body>' & @CRLF & _
    '</html>'

Local $sHTML4 = _
    '<!DOCTYPE html>' & @CRLF & _
    '<html>' & @CRLF & _
    '<head>' & @CRLF & _
    '<title>Chart Example</title>' & @CRLF & _
    '<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>' & @CRLF & _
    '<style>body { font-family: Arial, sans-serif; padding: 20px; } canvas { max-width: 600px; }</style>' & @CRLF & _
    '</head>' & @CRLF & _
    '<body>' & @CRLF & _
    '<h1>Data Visualization</h1>' & @CRLF & _
    '<canvas id="myChart"></canvas>' & @CRLF & _
    '<script>' & @CRLF & _
    'const ctx = document.getElementById("myChart");' & @CRLF & _
    'new Chart(ctx, {' & @CRLF & _
    '  type: "bar",' & @CRLF & _
    '  data: {' & @CRLF & _
    '    labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],' & @CRLF & _
    '    datasets: [{' & @CRLF & _
    '      label: "# of Votes",' & @CRLF & _
    '      data: [12, 19, 3, 5, 2, 3],' & @CRLF & _
    '      borderWidth: 1' & @CRLF & _
    '    }]' & @CRLF & _
    '  }' & @CRLF & _
    '});' & @CRLF & _
    '</script>' & @CRLF & _
    '</body>' & @CRLF & _
    '</html>'

; Load first example
_WebView2_NavigateToString($oWebView, $sHTML1)

; Main event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnExample1
            _WebView2_NavigateToString($oWebView, $sHTML1)

        Case $idBtnExample2
            _WebView2_NavigateToString($oWebView, $sHTML2)

        Case $idBtnExample3
            _WebView2_NavigateToString($oWebView, $sHTML3)

        Case $idBtnExample4
            _WebView2_NavigateToString($oWebView, $sHTML4)
    EndSwitch
WEnd

; Cleanup
_WebView2_Shutdown()
GUIDelete($hGUI)
