#include <GUIConstantsEx.au3>
#include "..\Include\WebView2_Setup.au3"
#include "..\Include\WebView2_OrdoControl.au3"

; ====================================================================================================================
; Example 4: AutoIt ↔ JavaScript Communication Bridge
; ====================================================================================================================
; Demonstrates bidirectional communication between AutoIt and JavaScript.
;
; AutoIt → JavaScript:
; - Call JavaScript functions from AutoIt
; - Pass data to JavaScript
; - Update UI elements
;
; JavaScript → AutoIt:
; - Get data from JavaScript (via ExecuteScript)
; - Read form values, DOM content, etc.
;
; Use Cases:
; - Form processing
; - Interactive UIs
; - Data validation
; - Real-time updates
; ====================================================================================================================

; Auto-setup if needed
If Not _WebView2Setup_CheckAll() Then
    If Not _WebView2Setup_ShowSetupWizard() Then
        MsgBox(16, "Setup Required", "Please run Example_01_SetupWizard.au3 first!")
        Exit
    EndIf
EndIf

; Create GUI
Local $hGUI = GUICreate("AutoIt ↔ JavaScript Bridge", 1000, 700)

; AutoIt Controls
GUICtrlCreateLabel("AutoIt Controls:", 10, 10, 200, 20)
GUICtrlSetFont(-1, 10, 800)

GUICtrlCreateLabel("Your Name:", 10, 40, 80, 20)
Local $idInputName = GUICtrlCreateInput("John Doe", 100, 35, 150, 25)

GUICtrlCreateLabel("Your Age:", 10, 75, 80, 20)
Local $idInputAge = GUICtrlCreateInput("25", 100, 70, 150, 25)

Local $idBtnSendToJS = GUICtrlCreateButton("Send to JavaScript →", 10, 105, 240, 30)
Local $idBtnGetFromJS = GUICtrlCreateButton("← Get from JavaScript", 10, 140, 240, 30)
Local $idBtnCalculate = GUICtrlCreateButton("Calculate Sum (JS)", 10, 175, 240, 30)

GUICtrlCreateLabel("JavaScript Result:", 10, 220, 200, 20)
GUICtrlSetFont(-1, 10, 800)
Local $idLabelResult = GUICtrlCreateLabel("(waiting...)", 10, 245, 240, 60)
GUICtrlSetBkColor($idLabelResult, 0xF0F0F0)

; Create WebView2
Local $oWebView = _WebView2Ordo_Create($hGUI, 260, 10, 730, 680, Default, True)

If Not IsObj($oWebView) Then
    MsgBox(16, "Error", "Failed to create WebView2 control!")
    Exit
EndIf

GUISetState(@SW_SHOW, $hGUI)

; Interactive HTML with JavaScript
Local $sHTML = _
'<!DOCTYPE html>' & @CRLF & _
'<html>' & @CRLF & _
'<head>' & @CRLF & _
'<meta charset="UTF-8">' & @CRLF & _
'<style>' & @CRLF & _
'body {' & @CRLF & _
'    font-family: "Segoe UI", Arial, sans-serif;' & @CRLF & _
'    padding: 30px;' & @CRLF & _
'    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);' & @CRLF & _
'}' & @CRLF & _
'h1 { color: #333; margin-bottom: 20px; }' & @CRLF & _
'.card {' & @CRLF & _
'    background: white;' & @CRLF & _
'    padding: 30px;' & @CRLF & _
'    border-radius: 10px;' & @CRLF & _
'    box-shadow: 0 4px 6px rgba(0,0,0,0.1);' & @CRLF & _
'    margin-bottom: 20px;' & @CRLF & _
'}' & @CRLF & _
'input {' & @CRLF & _
'    padding: 10px;' & @CRLF & _
'    font-size: 16px;' & @CRLF & _
'    border: 2px solid #ddd;' & @CRLF & _
'    border-radius: 5px;' & @CRLF & _
'    width: 200px;' & @CRLF & _
'    margin-right: 10px;' & @CRLF & _
'}' & @CRLF & _
'button {' & @CRLF & _
'    padding: 10px 20px;' & @CRLF & _
'    font-size: 16px;' & @CRLF & _
'    background: #667eea;' & @CRLF & _
'    color: white;' & @CRLF & _
'    border: none;' & @CRLF & _
'    border-radius: 5px;' & @CRLF & _
'    cursor: pointer;' & @CRLF & _
'}' & @CRLF & _
'button:hover { background: #5568d3; }' & @CRLF & _
'.result {' & @CRLF & _
'    background: #f0f8ff;' & @CRLF & _
'    padding: 15px;' & @CRLF & _
'    border-left: 4px solid #667eea;' & @CRLF & _
'    margin-top: 15px;' & @CRLF & _
'    font-size: 18px;' & @CRLF & _
'}' & @CRLF & _
'</style>' & @CRLF & _
'</head>' & @CRLF & _
'<body>' & @CRLF & _
'<h1>JavaScript Side 🌐</h1>' & @CRLF & _
'' & @CRLF & _
'<div class="card">' & @CRLF & _
'    <h2>Received from AutoIt:</h2>' & @CRLF & _
'    <div class="result" id="fromAutoIt">(waiting for data from AutoIt...)</div>' & @CRLF & _
'</div>' & @CRLF & _
'' & @CRLF & _
'<div class="card">' & @CRLF & _
'    <h2>JavaScript Form:</h2>' & @CRLF & _
'    <label>Number 1: <input type="number" id="num1" value="10"></label><br><br>' & @CRLF & _
'    <label>Number 2: <input type="number" id="num2" value="20"></label><br><br>' & @CRLF & _
'    <label>Message: <input type="text" id="message" value="Hello from JavaScript!"></label>' & @CRLF & _
'</div>' & @CRLF & _
'' & @CRLF & _
'<div class="card">' & @CRLF & _
'    <h2>JavaScript Functions:</h2>' & @CRLF & _
'    <button onclick="calculate()">Calculate Sum</button>' & @CRLF & _
'    <button onclick="showGreeting()">Show Greeting</button>' & @CRLF & _
'    <div class="result" id="jsResult" style="display:none;"></div>' & @CRLF & _
'</div>' & @CRLF & _
'' & @CRLF & _
'<script>' & @CRLF & _
'// Function called from AutoIt' & @CRLF & _
'function receiveFromAutoIt(name, age) {' & @CRLF & _
'    document.getElementById("fromAutoIt").innerHTML = ' & @CRLF & _
'        "Name: <b>" + name + "</b><br>Age: <b>" + age + "</b> years old";' & @CRLF & _
'}' & @CRLF & _
'' & @CRLF & _
'// Get form data (AutoIt will call this)' & @CRLF & _
'function getFormData() {' & @CRLF & _
'    return {' & @CRLF & _
'        num1: parseInt(document.getElementById("num1").value) || 0,' & @CRLF & _
'        num2: parseInt(document.getElementById("num2").value) || 0,' & @CRLF & _
'        message: document.getElementById("message").value' & @CRLF & _
'    };' & @CRLF & _
'}' & @CRLF & _
'' & @CRLF & _
'// Calculate sum' & @CRLF & _
'function calculateSum() {' & @CRLF & _
'    const data = getFormData();' & @CRLF & _
'    return data.num1 + data.num2;' & @CRLF & _
'}' & @CRLF & _
'' & @CRLF & _
'function calculate() {' & @CRLF & _
'    const result = calculateSum();' & @CRLF & _
'    document.getElementById("jsResult").style.display = "block";' & @CRLF & _
'    document.getElementById("jsResult").innerHTML = "Sum = " + result;' & @CRLF & _
'}' & @CRLF & _
'' & @CRLF & _
'function showGreeting() {' & @CRLF & _
'    const data = getFormData();' & @CRLF & _
'    alert(data.message);' & @CRLF & _
'}' & @CRLF & _
'</script>' & @CRLF & _
'</body>' & @CRLF & _
'</html>'

; Load HTML
_WebView2Ordo_NavigateToString($oWebView, $sHTML)
Sleep(1000)

ConsoleWrite("Bridge ready! Try the buttons to communicate between AutoIt and JavaScript." & @CRLF)

; Event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnSendToJS
            ; Get data from AutoIt controls
            Local $sName = GUICtrlRead($idInputName)
            Local $iAge = GUICtrlRead($idInputAge)

            ; Send to JavaScript
            Local $sScript = StringFormat('receiveFromAutoIt("%s", %d);', $sName, $iAge)
            _WebView2Ordo_ExecuteScriptAsync($oWebView, $sScript)

            GUICtrlSetData($idLabelResult, "✓ Data sent to JavaScript!" & @CRLF & _
                "Name: " & $sName & @CRLF & "Age: " & $iAge)

            ConsoleWrite("Sent to JavaScript: " & $sName & ", " & $iAge & @CRLF)

        Case $idBtnGetFromJS
            ; Get data FROM JavaScript
            Local $sJSResult = _WebView2Ordo_ExecuteScript($oWebView, "JSON.stringify(getFormData());")

            ; Parse JSON result (remove quotes)
            $sJSResult = StringTrimLeft(StringTrimRight($sJSResult, 1), 1)
            $sJSResult = StringReplace($sJSResult, '\"', '"')

            GUICtrlSetData($idLabelResult, "✓ Data received from JavaScript!" & @CRLF & $sJSResult)

            ConsoleWrite("Received from JavaScript: " & $sJSResult & @CRLF)

        Case $idBtnCalculate
            ; Call JavaScript function and get result
            Local $sSum = _WebView2Ordo_ExecuteScript($oWebView, "calculateSum();")

            GUICtrlSetData($idLabelResult, "✓ Calculation result from JavaScript:" & @CRLF & _
                "Sum = " & $sSum)

            ConsoleWrite("JavaScript calculated sum: " & $sSum & @CRLF)
    EndSwitch

    Sleep(10)
WEnd

; Cleanup
$oWebView = 0
GUIDelete($hGUI)
