#include <GUIConstantsEx.au3>
#include "..\Include\WebView2_Setup.au3"
#include "..\Include\WebView2_OrdoControl.au3"

; ====================================================================================================================
; Example 3: Modern HTML Dashboard
; ====================================================================================================================
; Demonstrates embedding a modern, responsive HTML dashboard in AutoIt.
;
; Features:
; - Modern CSS3 with gradients and animations
; - Responsive design
; - Real-time data updates from AutoIt
; - Chart visualization (Chart.js)
; - Interactive UI with JavaScript
;
; This shows how you can create beautiful UIs with HTML/CSS/JavaScript
; while controlling everything from AutoIt!
; ====================================================================================================================

; Auto-setup if needed
If Not _WebView2Setup_CheckAll() Then
    If Not _WebView2Setup_ShowSetupWizard() Then
        MsgBox(16, "Setup Required", "Please run Example_01_SetupWizard.au3 first!")
        Exit
    EndIf
EndIf

; Create GUI
Local $hGUI = GUICreate("System Dashboard - WebView2", 1200, 800)

; Control buttons
Local $idBtnRefresh = GUICtrlCreateButton("Refresh Data", 10, 10, 100, 30)
Local $idBtnAlert = GUICtrlCreateButton("Show Alert", 120, 10, 100, 30)
Local $idBtnToggleTheme = GUICtrlCreateButton("Toggle Theme", 230, 10, 100, 30)

; Create WebView2
Local $oWebView = _WebView2Ordo_Create($hGUI, 0, 50, 1200, 750, Default, True)

If Not IsObj($oWebView) Then
    MsgBox(16, "Error", "Failed to create WebView2 control!")
    Exit
EndIf

GUISetState(@SW_SHOW, $hGUI)

; Modern Dashboard HTML
Local $sHTML = _
'<!DOCTYPE html>' & @CRLF & _
'<html lang="en">' & @CRLF & _
'<head>' & @CRLF & _
'<meta charset="UTF-8">' & @CRLF & _
'<meta name="viewport" content="width=device-width, initial-scale=1.0">' & @CRLF & _
'<title>System Dashboard</title>' & @CRLF & _
'<style>' & @CRLF & _
'* { margin: 0; padding: 0; box-sizing: border-box; }' & @CRLF & _
'body {' & @CRLF & _
'    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;' & @CRLF & _
'    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);' & @CRLF & _
'    padding: 20px;' & @CRLF & _
'    color: #fff;' & @CRLF & _
'    transition: background 0.3s;' & @CRLF & _
'}' & @CRLF & _
'body.dark {' & @CRLF & _
'    background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);' & @CRLF & _
'}' & @CRLF & _
'.container { max-width: 1400px; margin: 0 auto; }' & @CRLF & _
'h1 {' & @CRLF & _
'    text-align: center;' & @CRLF & _
'    font-size: 3em;' & @CRLF & _
'    margin-bottom: 30px;' & @CRLF & _
'    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);' & @CRLF & _
'    animation: fadeIn 1s;' & @CRLF & _
'}' & @CRLF & _
'.stats {' & @CRLF & _
'    display: grid;' & @CRLF & _
'    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));' & @CRLF & _
'    gap: 20px;' & @CRLF & _
'    margin-bottom: 30px;' & @CRLF & _
'}' & @CRLF & _
'.stat-card {' & @CRLF & _
'    background: rgba(255,255,255,0.1);' & @CRLF & _
'    backdrop-filter: blur(10px);' & @CRLF & _
'    padding: 30px;' & @CRLF & _
'    border-radius: 15px;' & @CRLF & _
'    box-shadow: 0 8px 32px rgba(0,0,0,0.1);' & @CRLF & _
'    border: 1px solid rgba(255,255,255,0.2);' & @CRLF & _
'    transition: transform 0.3s, box-shadow 0.3s;' & @CRLF & _
'    animation: slideIn 0.5s;' & @CRLF & _
'}' & @CRLF & _
'.stat-card:hover {' & @CRLF & _
'    transform: translateY(-5px);' & @CRLF & _
'    box-shadow: 0 12px 48px rgba(0,0,0,0.2);' & @CRLF & _
'}' & @CRLF & _
'.stat-label {' & @CRLF & _
'    font-size: 0.9em;' & @CRLF & _
'    opacity: 0.8;' & @CRLF & _
'    margin-bottom: 10px;' & @CRLF & _
'}' & @CRLF & _
'.stat-value {' & @CRLF & _
'    font-size: 2.5em;' & @CRLF & _
'    font-weight: bold;' & @CRLF & _
'}' & @CRLF & _
'.chart-container {' & @CRLF & _
'    background: rgba(255,255,255,0.1);' & @CRLF & _
'    backdrop-filter: blur(10px);' & @CRLF & _
'    padding: 30px;' & @CRLF & _
'    border-radius: 15px;' & @CRLF & _
'    box-shadow: 0 8px 32px rgba(0,0,0,0.1);' & @CRLF & _
'    border: 1px solid rgba(255,255,255,0.2);' & @CRLF & _
'}' & @CRLF & _
'.info {' & @CRLF & _
'    text-align: center;' & @CRLF & _
'    margin-top: 20px;' & @CRLF & _
'    font-size: 0.9em;' & @CRLF & _
'    opacity: 0.8;' & @CRLF & _
'}' & @CRLF & _
'@keyframes fadeIn {' & @CRLF & _
'    from { opacity: 0; }' & @CRLF & _
'    to { opacity: 1; }' & @CRLF & _
'}' & @CRLF & _
'@keyframes slideIn {' & @CRLF & _
'    from { transform: translateY(20px); opacity: 0; }' & @CRLF & _
'    to { transform: translateY(0); opacity: 1; }' & @CRLF & _
'}' & @CRLF & _
'</style>' & @CRLF & _
'</head>' & @CRLF & _
'<body>' & @CRLF & _
'<div class="container">' & @CRLF & _
'    <h1>🖥️ System Dashboard</h1>' & @CRLF & _
'    ' & @CRLF & _
'    <div class="stats">' & @CRLF & _
'        <div class="stat-card">' & @CRLF & _
'            <div class="stat-label">CPU Usage</div>' & @CRLF & _
'            <div class="stat-value" id="cpu">0%</div>' & @CRLF & _
'        </div>' & @CRLF & _
'        <div class="stat-card">' & @CRLF & _
'            <div class="stat-label">Memory Usage</div>' & @CRLF & _
'            <div class="stat-value" id="memory">0 MB</div>' & @CRLF & _
'        </div>' & @CRLF & _
'        <div class="stat-card">' & @CRLF & _
'            <div class="stat-label">Disk Space</div>' & @CRLF & _
'            <div class="stat-value" id="disk">0 GB</div>' & @CRLF & _
'        </div>' & @CRLF & _
'        <div class="stat-card">' & @CRLF & _
'            <div class="stat-label">Uptime</div>' & @CRLF & _
'            <div class="stat-value" id="uptime">0h</div>' & @CRLF & _
'        </div>' & @CRLF & _
'    </div>' & @CRLF & _
'    ' & @CRLF & _
'    <div class="chart-container">' & @CRLF & _
'        <h2 style="margin-bottom: 20px;">📊 Performance Graph</h2>' & @CRLF & _
'        <canvas id="perfChart" width="400" height="200"></canvas>' & @CRLF & _
'    </div>' & @CRLF & _
'    ' & @CRLF & _
'    <div class="info">' & @CRLF & _
'        This is a modern HTML5/CSS3/JavaScript dashboard running in native Edge WebView2!<br>' & @CRLF & _
'        Click "Refresh Data" to update values from AutoIt.' & @CRLF & _
'    </div>' & @CRLF & _
'</div>' & @CRLF & _
'' & @CRLF & _
'<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>' & @CRLF & _
'<script>' & @CRLF & _
'// Create chart' & @CRLF & _
'const ctx = document.getElementById("perfChart").getContext("2d");' & @CRLF & _
'const chart = new Chart(ctx, {' & @CRLF & _
'    type: "line",' & @CRLF & _
'    data: {' & @CRLF & _
'        labels: ["1m", "2m", "3m", "4m", "5m", "6m", "7m"],' & @CRLF & _
'        datasets: [{' & @CRLF & _
'            label: "CPU %",' & @CRLF & _
'            data: [12, 19, 15, 25, 22, 30, 28],' & @CRLF & _
'            borderColor: "rgba(255,255,255,0.8)",' & @CRLF & _
'            backgroundColor: "rgba(255,255,255,0.1)",' & @CRLF & _
'            tension: 0.4' & @CRLF & _
'        }]' & @CRLF & _
'    },' & @CRLF & _
'    options: {' & @CRLF & _
'        responsive: true,' & @CRLF & _
'        plugins: { legend: { labels: { color: "white" } } },' & @CRLF & _
'        scales: {' & @CRLF & _
'            y: { ticks: { color: "white" }, grid: { color: "rgba(255,255,255,0.1)" } },' & @CRLF & _
'            x: { ticks: { color: "white" }, grid: { color: "rgba(255,255,255,0.1)" } }' & @CRLF & _
'        }' & @CRLF & _
'    }' & @CRLF & _
'});' & @CRLF & _
'' & @CRLF & _
'// Function to update data (called from AutoIt)' & @CRLF & _
'function updateData(cpu, memory, disk, uptime) {' & @CRLF & _
'    document.getElementById("cpu").textContent = cpu + "%";' & @CRLF & _
'    document.getElementById("memory").textContent = memory + " MB";' & @CRLF & _
'    document.getElementById("disk").textContent = disk + " GB";' & @CRLF & _
'    document.getElementById("uptime").textContent = uptime + "h";' & @CRLF & _
'}' & @CRLF & _
'' & @CRLF & _
'// Toggle theme' & @CRLF & _
'function toggleTheme() {' & @CRLF & _
'    document.body.classList.toggle("dark");' & @CRLF & _
'}' & @CRLF & _
'</script>' & @CRLF & _
'</body>' & @CRLF & _
'</html>'

; Load dashboard
_WebView2Ordo_NavigateToString($oWebView, $sHTML)
Sleep(2000) ; Wait for Chart.js to load

ConsoleWrite("Dashboard loaded! Click buttons to interact." & @CRLF)

; Event loop
While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnRefresh
            ; Generate random data (in real app, get actual system info)
            Local $iCPU = Random(10, 80, 1)
            Local $iMemory = Random(2000, 8000, 1)
            Local $iDisk = Random(100, 500, 1)
            Local $fUptime = Round(@HOUR + @MIN / 60, 1)

            ; Update dashboard via JavaScript
            Local $sScript = StringFormat('updateData(%d, %d, %d, %.1f);', $iCPU, $iMemory, $iDisk, $fUptime)
            _WebView2Ordo_ExecuteScriptAsync($oWebView, $sScript)

            ConsoleWrite("Data refreshed: CPU=" & $iCPU & "%, Memory=" & $iMemory & "MB" & @CRLF)

        Case $idBtnAlert
            ; Show JavaScript alert
            _WebView2Ordo_ExecuteScriptAsync($oWebView, "alert('Hello from AutoIt! 👋');")

        Case $idBtnToggleTheme
            ; Toggle dark/light theme
            _WebView2Ordo_ExecuteScriptAsync($oWebView, "toggleTheme();")
    EndSwitch

    Sleep(10)
WEnd

; Cleanup
$oWebView = 0
GUIDelete($hGUI)
