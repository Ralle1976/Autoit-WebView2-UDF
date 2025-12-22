#include-once
#include "..\..\Include\WebView2_Native.au3"

; #INDEX# =======================================================================================================================
; Title .........: WV2React_Core
; AutoIt Version : 3.3.16.1+
; Language ......: English/German
; Description ...: High-Level React Wrapper for WebView2 - Core Module
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Dieses Modul ermoeglicht die einfache Nutzung moderner React-UI-Komponenten
; in AutoIt-Anwendungen ohne JavaScript-Kenntnisse.
;
; FEATURES:
; - Automatisches Laden von React, Tailwind CSS via CDN
; - High-Level Funktionen fuer Grids, Karten, Dashboards
; - Bidirektionales JSON-Kommunikationsprotokoll
; - Event-Callbacks fuer Benutzerinteraktionen
; - Theming-System mit Primaerfarben-Konfiguration
;
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $WV2REACT_VERSION = "1.0.0"
Global Const $WV2REACT_DEFAULT_THEME = "light"
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_oWV2React_WebView = 0           ; WebView2 Instanz
Global $__g_sWV2React_Theme = "light"       ; Aktuelles Theme
Global $__g_sWV2React_PrimaryColor = "#3B82F6"  ; Tailwind Blue-500
Global $__g_aWV2React_Components[1][4]      ; [n][0]=ID, [n][1]=Type, [n][2]=State, [n][3]=Callback
$__g_aWV2React_Components[0][0] = 0         ; Count
Global $__g_aWV2React_EventQueue[1]         ; Event-Queue
$__g_aWV2React_EventQueue[0] = 0            ; Count
Global $__g_fWV2React_OnEvent = 0           ; Globaler Event-Callback
Global $__g_bWV2React_Initialized = False   ; Init-Status
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WV2React_Init
; _WV2React_SetTheme
; _WV2React_SetPrimaryColor
; _WV2React_CreateComponent
; _WV2React_UpdateComponent
; _WV2React_GetComponentState
; _WV2React_DestroyComponent
; _WV2React_OnEvent
; _WV2React_ProcessEvents
; _WV2React_SendCommand
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_Init
; Description ...: Initialisiert das React Framework in WebView2
; Syntax ........: _WV2React_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sTheme = "light"], [$sPrimaryColor = ""])
; Parameters ....: $hWnd          - Handle des Parent-Fensters
;                  $iLeft/Top     - Position
;                  $iWidth/Height - Groesse
;                  $sTheme        - [optional] "light" oder "dark"
;                  $sPrimaryColor - [optional] Hex-Farbcode (z.B. "#3B82F6")
; Return values .: Success - WebView2 Array
;                  Failure - 0 und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, $sTheme = "light", $sPrimaryColor = "")
    ; Theme speichern
    $__g_sWV2React_Theme = $sTheme
    If $sPrimaryColor <> "" Then $__g_sWV2React_PrimaryColor = $sPrimaryColor

    ; WebView2 erstellen
    Local $aWebView = _WebView2_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight)
    If @error Then Return SetError(1, @extended, 0)

    $__g_oWV2React_WebView = $aWebView

    ; Message-Callback registrieren
    _WebView2_SetMessageCallback($aWebView, __WV2React_OnMessage)

    ; Framework-HTML laden
    Local $sHtml = __WV2React_GenerateHTML()
    _WebView2_NavigateToString($aWebView, $sHtml)

    ; Warten bis geladen
    Sleep(500)

    ; Theme anwenden
    __WV2React_ApplyTheme()

    $__g_bWV2React_Initialized = True
    Return $aWebView
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SetTheme
; Description ...: Setzt das globale Theme (light/dark)
; Syntax ........: _WV2React_SetTheme($sTheme)
; Parameters ....: $sTheme - "light" oder "dark"
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SetTheme($sTheme)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)
    If $sTheme <> "light" And $sTheme <> "dark" Then Return SetError(2, 0, False)

    $__g_sWV2React_Theme = $sTheme
    __WV2React_ApplyTheme()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SetPrimaryColor
; Description ...: Setzt die Primaerfarbe fuer alle Komponenten
; Syntax ........: _WV2React_SetPrimaryColor($sColor)
; Parameters ....: $sColor - Hex-Farbcode (z.B. "#3B82F6")
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SetPrimaryColor($sColor)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)
    If Not StringRegExp($sColor, "^#[0-9A-Fa-f]{6}$") Then Return SetError(2, 0, False)

    $__g_sWV2React_PrimaryColor = $sColor

    Local $sCmd = '{"action":"setTheme","payload":{"primaryColor":"' & $sColor & '"}}'
    _WV2React_SendCommand($sCmd)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_CreateComponent
; Description ...: Erstellt eine neue UI-Komponente
; Syntax ........: _WV2React_CreateComponent($sType, $sId, $aOptions)
; Parameters ....: $sType    - Komponenten-Typ ("grid", "map", "card", "dashboard")
;                  $sId      - Eindeutige ID
;                  $aOptions - Array mit Optionen (typ-abhaengig)
; Return values .: Success - Component ID
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_CreateComponent($sType, $sId, $aOptions = Default)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, "")

    ; Komponente registrieren
    Local $iIndex = $__g_aWV2React_Components[0][0] + 1
    ReDim $__g_aWV2React_Components[$iIndex + 1][4]
    $__g_aWV2React_Components[0][0] = $iIndex
    $__g_aWV2React_Components[$iIndex][0] = $sId
    $__g_aWV2React_Components[$iIndex][1] = $sType
    $__g_aWV2React_Components[$iIndex][2] = "created"
    $__g_aWV2React_Components[$iIndex][3] = 0

    ; Command erstellen
    Local $sPayload = "{}"
    If IsArray($aOptions) Then
        $sPayload = __WV2React_ArrayToJson($aOptions)
    ElseIf IsString($aOptions) And StringLeft($aOptions, 1) = "{" Then
        ; JSON-String direkt verwenden
        $sPayload = $aOptions
    EndIf

    Local $sCmd = '{"action":"createComponent","componentId":"' & $sId & '","componentType":"' & $sType & '","payload":' & $sPayload & '}'
    _WV2React_SendCommand($sCmd)

    Return $sId
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_UpdateComponent
; Description ...: Aktualisiert eine Komponente mit neuen Daten
; Syntax ........: _WV2React_UpdateComponent($sId, $aData)
; Parameters ....: $sId   - Komponenten-ID
;                  $aData - Neue Daten (Array oder JSON-String)
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_UpdateComponent($sId, $aData)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sPayload
    If IsArray($aData) Then
        $sPayload = __WV2React_ArrayToJson($aData)
    ElseIf IsString($aData) Then
        $sPayload = $aData
    Else
        Return SetError(2, 0, False)
    EndIf

    Local $sCmd = '{"action":"updateComponent","componentId":"' & $sId & '","payload":' & $sPayload & '}'
    _WV2React_SendCommand($sCmd)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_GetComponentState
; Description ...: Ruft den aktuellen Status einer Komponente ab
; Syntax ........: _WV2React_GetComponentState($sId)
; Parameters ....: $sId - Komponenten-ID
; Return values .: Success - JSON-String mit Status
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_GetComponentState($sId)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, "")

    Local $sScript = "WV2Bridge.getComponentState('" & $sId & "')"
    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)

    If @error Then Return SetError(2, @error, "")
    Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_DestroyComponent
; Description ...: Entfernt eine Komponente
; Syntax ........: _WV2React_DestroyComponent($sId)
; Parameters ....: $sId - Komponenten-ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_DestroyComponent($sId)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sCmd = '{"action":"destroyComponent","componentId":"' & $sId & '"}'
    _WV2React_SendCommand($sCmd)

    ; Aus lokalem Array entfernen
    For $i = 1 To $__g_aWV2React_Components[0][0]
        If $__g_aWV2React_Components[$i][0] = $sId Then
            $__g_aWV2React_Components[$i][0] = ""
            $__g_aWV2React_Components[$i][2] = "destroyed"
            ExitLoop
        EndIf
    Next

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_OnEvent
; Description ...: Registriert einen globalen Event-Callback
; Syntax ........: _WV2React_OnEvent($fCallback)
; Parameters ....: $fCallback - Callback-Funktion: Func($sEventType, $sComponentId, $oData)
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_OnEvent($fCallback)
    If Not IsFunc($fCallback) Then Return SetError(1, 0, False)
    $__g_fWV2React_OnEvent = $fCallback
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_ProcessEvents
; Description ...: Verarbeitet ausstehende Events (im Hauptloop aufrufen)
; Syntax ........: _WV2React_ProcessEvents()
; Return values .: Anzahl verarbeiteter Events
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_ProcessEvents()
    ; Pruefe auf neue Events
    Local $sScript = "WV2Bridge.getPendingEvents()"
    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 100)

    If @error Or $sResult = "null" Or $sResult = "[]" Then Return 0

    ; Events verarbeiten (via Callback)
    ; Das JavaScript sendet Events ueber PostMessage
    Return 0
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SendCommand
; Description ...: Sendet einen JSON-Command an das Frontend
; Syntax ........: _WV2React_SendCommand($sJson)
; Parameters ....: $sJson - JSON-Command-String
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SendCommand($sJson)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    ; Escape fuer JavaScript
    $sJson = StringReplace($sJson, "\", "\\")
    $sJson = StringReplace($sJson, "'", "\'")

    Local $sScript = "WV2Bridge.handleCommand('" & $sJson & "')"
    _WebView2_ExecuteScriptAsync($__g_oWV2React_WebView, $sScript)

    Return True
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Message-Handler fuer Events vom Frontend
Func __WV2React_OnMessage($sMessage)
    ; JSON parsen (vereinfacht)
    If StringLeft($sMessage, 1) = '"' Then
        $sMessage = StringTrimLeft(StringTrimRight($sMessage, 1), 1)
    EndIf

    ; Event-Callback aufrufen wenn registriert
    If IsFunc($__g_fWV2React_OnEvent) Then
        ; Extrahiere Event-Typ und Komponenten-ID aus JSON
        Local $sEventType = __WV2React_JsonGetValue($sMessage, "event")
        Local $sComponentId = __WV2React_JsonGetValue($sMessage, "componentId")

        Call($__g_fWV2React_OnEvent, $sEventType, $sComponentId, $sMessage)
    EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert das Framework-HTML mit allen CDN-Includes
Func __WV2React_GenerateHTML()
    Local $sThemeClass = ($__g_sWV2React_Theme = "dark") ? "dark" : ""

    Local $sHtml = '<!DOCTYPE html>' & @CRLF
    $sHtml &= '<html lang="de" class="' & $sThemeClass & '">' & @CRLF
    $sHtml &= '<head>' & @CRLF
    $sHtml &= '  <meta charset="UTF-8">' & @CRLF
    $sHtml &= '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' & @CRLF
    $sHtml &= '  <title>WV2React Framework</title>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <!-- Tailwind CSS -->' & @CRLF
    $sHtml &= '  <script src="https://cdn.tailwindcss.com"></script>' & @CRLF
    $sHtml &= '  <script>' & @CRLF
    $sHtml &= '    tailwind.config = {' & @CRLF
    $sHtml &= '      darkMode: "class",' & @CRLF
    $sHtml &= '      theme: {' & @CRLF
    $sHtml &= '        extend: {' & @CRLF
    $sHtml &= '          colors: {' & @CRLF
    $sHtml &= '            primary: "' & $__g_sWV2React_PrimaryColor & '"' & @CRLF
    $sHtml &= '          }' & @CRLF
    $sHtml &= '        }' & @CRLF
    $sHtml &= '      }' & @CRLF
    $sHtml &= '    }' & @CRLF
    $sHtml &= '  </script>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <!-- Leaflet.js fuer Karten -->' & @CRLF
    $sHtml &= '  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />' & @CRLF
    $sHtml &= '  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <!-- React 18 -->' & @CRLF
    $sHtml &= '  <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>' & @CRLF
    $sHtml &= '  <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <style>' & @CRLF
    $sHtml &= '    body { margin: 0; padding: 0; font-family: system-ui, sans-serif; }' & @CRLF
    $sHtml &= '    .dark body { background: #1f2937; color: #f3f4f6; }' & @CRLF
    $sHtml &= '    #root { width: 100%; height: 100vh; }' & @CRLF
    $sHtml &= '    .component-container { padding: 16px; }' & @CRLF
    $sHtml &= '    .grid-container { overflow: auto; }' & @CRLF
    $sHtml &= '    .map-container { width: 100%; height: 400px; }' & @CRLF
    $sHtml &= '  </style>' & @CRLF
    $sHtml &= '</head>' & @CRLF
    $sHtml &= '<body class="bg-gray-50 dark:bg-gray-900" style="background:#f9fafb;">' & @CRLF
    $sHtml &= '  <div id="root"><p style="padding:20px;font-family:sans-serif;">Lade Framework...</p></div>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <script>' & @CRLF
    $sHtml &= '    console.log("WV2React: Script block started");' & @CRLF
    $sHtml &= __WV2React_GenerateJSCore()
    $sHtml &= '  </script>' & @CRLF
    $sHtml &= '</body>' & @CRLF
    $sHtml &= '</html>'

    Return $sHtml
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert den JavaScript-Core (Bridge + Komponenten)
Func __WV2React_GenerateJSCore()
    Local $sJs = ""

    ; WV2Bridge - Kommunikationsschicht
    $sJs &= "const WV2Bridge = {" & @CRLF
    $sJs &= "  components: new Map()," & @CRLF
    $sJs &= "  eventQueue: []," & @CRLF
    $sJs &= "  theme: { mode: '" & $__g_sWV2React_Theme & "', primary: '" & $__g_sWV2React_PrimaryColor & "' }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  init: function() {" & @CRLF
    $sJs &= "    console.log('WV2React Framework v" & $WV2REACT_VERSION & " initialized');" & @CRLF
    $sJs &= "    this.renderRoot();" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  handleCommand: function(jsonStr) {" & @CRLF
    $sJs &= "    try {" & @CRLF
    $sJs &= "      const cmd = JSON.parse(jsonStr);" & @CRLF
    $sJs &= "      console.log('Command:', cmd);" & @CRLF
    $sJs &= "      switch(cmd.action) {" & @CRLF
    $sJs &= "        case 'createComponent': this.createComponent(cmd); break;" & @CRLF
    $sJs &= "        case 'updateComponent': this.updateComponent(cmd); break;" & @CRLF
    $sJs &= "        case 'destroyComponent': this.destroyComponent(cmd); break;" & @CRLF
    $sJs &= "        case 'setTheme': this.setTheme(cmd.payload); break;" & @CRLF
    $sJs &= "        default: console.warn('Unknown action:', cmd.action);" & @CRLF
    $sJs &= "      }" & @CRLF
    $sJs &= "    } catch(e) { console.error('Command parse error:', e); }" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  sendEvent: function(eventType, componentId, data) {" & @CRLF
    $sJs &= "    const event = { event: eventType, componentId: componentId, data: data, timestamp: Date.now() };" & @CRLF
    $sJs &= "    if(window.chrome && window.chrome.webview) {" & @CRLF
    $sJs &= "      window.chrome.webview.postMessage(JSON.stringify(event));" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  createComponent: function(cmd) {" & @CRLF
    $sJs &= "    const { componentId, componentType, payload } = cmd;" & @CRLF
    $sJs &= "    let component = null;" & @CRLF
    $sJs &= "    switch(componentType) {" & @CRLF
    $sJs &= "      case 'grid': component = new WV2Grid(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'map': component = new WV2Map(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'card': component = new WV2Card(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'button': component = new WV2Button(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'input': component = new WV2Input(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'textarea': component = new WV2Textarea(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'checkbox': component = new WV2Checkbox(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'radio': component = new WV2Radio(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'switch': component = new WV2Switch(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'select': component = new WV2Select(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'datepicker': component = new WV2DatePicker(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'timepicker': component = new WV2TimePicker(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'colorpicker': component = new WV2ColorPicker(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'slider': component = new WV2Slider(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'fileupload': component = new WV2FileUpload(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'tabs': component = new WV2Tabs(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'breadcrumb': component = new WV2Breadcrumb(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'pagination': component = new WV2Pagination(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'stepper': component = new WV2Stepper(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'treeview': component = new WV2TreeView(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'accordion': component = new WV2Accordion(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'modal': component = new WV2Modal(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'toast': component = new WV2Toast(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'alert': component = new WV2Alert(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'progress': component = new WV2Progress(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'spinner': component = new WV2Spinner(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'tooltip': component = new WV2Tooltip(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'chart': component = new WV2Chart(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'badge': component = new WV2Badge(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'avatar': component = new WV2Avatar(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'tag': component = new WV2Tag(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'divider': component = new WV2Divider(componentId, payload); break;" & @CRLF
    $sJs &= "      case 'statcard': component = new WV2StatCard(componentId, payload); break;" & @CRLF
    $sJs &= "      default: console.warn('Unknown component type:', componentType); return;" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "    this.components.set(componentId, component);" & @CRLF
    $sJs &= "    // Komponente anhaengen ohne vorhandenes Layout zu zerstoeren" & @CRLF
    $sJs &= "    const root = document.getElementById('root');" & @CRLF
    $sJs &= "    if(component.render) { root.appendChild(component.render()); }" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  updateComponent: function(cmd) {" & @CRLF
    $sJs &= "    const component = this.components.get(cmd.componentId);" & @CRLF
    $sJs &= "    if(component && component.update) { component.update(cmd.payload); }" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  destroyComponent: function(cmd) {" & @CRLF
    $sJs &= "    const component = this.components.get(cmd.componentId);" & @CRLF
    $sJs &= "    if(component && component.destroy) { component.destroy(); }" & @CRLF
    $sJs &= "    // DOM Element entfernen" & @CRLF
    $sJs &= "    const el = document.getElementById('grid-' + cmd.componentId) || document.getElementById('map-' + cmd.componentId);" & @CRLF
    $sJs &= "    if(el) el.remove();" & @CRLF
    $sJs &= "    this.components.delete(cmd.componentId);" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  getComponentState: function(id) {" & @CRLF
    $sJs &= "    const component = this.components.get(id);" & @CRLF
    $sJs &= "    return component && component.getState ? JSON.stringify(component.getState()) : null;" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  setTheme: function(payload) {" & @CRLF
    $sJs &= "    if(payload.mode) {" & @CRLF
    $sJs &= "      this.theme.mode = payload.mode;" & @CRLF
    $sJs &= "      document.documentElement.classList.toggle('dark', payload.mode === 'dark');" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "    if(payload.primaryColor) {" & @CRLF
    $sJs &= "      this.theme.primary = payload.primaryColor;" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  renderRoot: function() {" & @CRLF
    $sJs &= "    const root = document.getElementById('root');" & @CRLF
    $sJs &= "    root.innerHTML = '';" & @CRLF
    $sJs &= "    this.components.forEach((comp, id) => {" & @CRLF
    $sJs &= "      if(comp.render) { root.appendChild(comp.render()); }" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "};" & @CRLF
    $sJs &= "" & @CRLF

    ; Grid-Komponente
    $sJs &= __WV2React_GenerateGridComponent()

    ; Map-Komponente
    $sJs &= __WV2React_GenerateMapComponent()

    ; Card-Komponente
    $sJs &= __WV2React_GenerateCardComponent()

    ; UI-Komponenten (Phase 1-7) - aus externer Datei laden
    $sJs &= __WV2React_LoadUIComponentsFromFile()

    ; Init
    $sJs &= "WV2Bridge.init();" & @CRLF

    Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Grid-Komponente (TanStack-inspiriert, aber vereinfacht)
Func __WV2React_GenerateGridComponent()
    Local $sJs = ""

    $sJs &= "class WV2Grid {" & @CRLF
    $sJs &= "  constructor(id, options) {" & @CRLF
    $sJs &= "    this.id = id;" & @CRLF
    $sJs &= "    this.columns = options.columns || [];" & @CRLF
    $sJs &= "    this.data = options.data || [];" & @CRLF
    $sJs &= "    this.sortColumn = null;" & @CRLF
    $sJs &= "    this.sortDir = 'asc';" & @CRLF
    $sJs &= "    this.selectedRow = null;" & @CRLF
    $sJs &= "    this.filterable = options.filterable !== false;" & @CRLF
    $sJs &= "    this.sortable = options.sortable !== false;" & @CRLF
    $sJs &= "    this.filterValue = '';" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  update(payload) {" & @CRLF
    $sJs &= "    if(payload.data) this.data = payload.data;" & @CRLF
    $sJs &= "    if(payload.columns) this.columns = payload.columns;" & @CRLF
    $sJs &= "    this.updateTableBody();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  getState() {" & @CRLF
    $sJs &= "    return { selectedRow: this.selectedRow, sortColumn: this.sortColumn, sortDir: this.sortDir };" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  sort(column) {" & @CRLF
    $sJs &= "    if(this.sortColumn === column) {" & @CRLF
    $sJs &= "      this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';" & @CRLF
    $sJs &= "    } else {" & @CRLF
    $sJs &= "      this.sortColumn = column;" & @CRLF
    $sJs &= "      this.sortDir = 'asc';" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "    this.data.sort((a, b) => {" & @CRLF
    $sJs &= "      const va = a[column], vb = b[column];" & @CRLF
    $sJs &= "      const cmp = va < vb ? -1 : va > vb ? 1 : 0;" & @CRLF
    $sJs &= "      return this.sortDir === 'asc' ? cmp : -cmp;" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "    WV2Bridge.sendEvent('onSort', this.id, { column: column, direction: this.sortDir });" & @CRLF
    $sJs &= "    this.updateTableBody();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  selectRow(index) {" & @CRLF
    $sJs &= "    this.selectedRow = index;" & @CRLF
    $sJs &= "    WV2Bridge.sendEvent('onRowSelect', this.id, { index: index, row: this.data[index] });" & @CRLF
    $sJs &= "    this.updateTableBody();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  filter(value) {" & @CRLF
    $sJs &= "    this.filterValue = value.toLowerCase();" & @CRLF
    $sJs &= "    this.updateTableBody();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  updateTableBody() {" & @CRLF
    $sJs &= "    const container = document.getElementById('grid-' + this.id);" & @CRLF
    $sJs &= "    if(!container) return;" & @CRLF
    $sJs &= "    const tbody = container.querySelector('tbody');" & @CRLF
    $sJs &= "    if(!tbody) return;" & @CRLF
    $sJs &= "    tbody.innerHTML = '';" & @CRLF
    $sJs &= "    const data = this.getFilteredData();" & @CRLF
    $sJs &= "    data.forEach((row, idx) => {" & @CRLF
    $sJs &= "      const tr = document.createElement('tr');" & @CRLF
    $sJs &= "      tr.className = 'border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer';" & @CRLF
    $sJs &= "      if(this.selectedRow === idx) tr.className += ' bg-blue-100 dark:bg-blue-900';" & @CRLF
    $sJs &= "      tr.onclick = () => this.selectRow(idx);" & @CRLF
    $sJs &= "      this.columns.forEach(col => {" & @CRLF
    $sJs &= "        const td = document.createElement('td');" & @CRLF
    $sJs &= "        td.className = 'px-4 py-3 text-gray-800 dark:text-gray-200';" & @CRLF
    $sJs &= "        td.textContent = row[col.key] !== undefined ? row[col.key] : '';" & @CRLF
    $sJs &= "        tr.appendChild(td);" & @CRLF
    $sJs &= "      });" & @CRLF
    $sJs &= "      tbody.appendChild(tr);" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "    const footer = container.querySelector('.text-gray-500');" & @CRLF
    $sJs &= "    if(footer) footer.textContent = data.length + ' Eintraege';" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  getFilteredData() {" & @CRLF
    $sJs &= "    if(!this.filterValue) return this.data;" & @CRLF
    $sJs &= "    return this.data.filter(row => {" & @CRLF
    $sJs &= "      return Object.values(row).some(v => " & @CRLF
    $sJs &= "        String(v).toLowerCase().includes(this.filterValue)" & @CRLF
    $sJs &= "      );" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  render() {" & @CRLF
    $sJs &= "    const container = document.createElement('div');" & @CRLF
    $sJs &= "    container.className = 'component-container grid-container';" & @CRLF
    $sJs &= "    container.id = 'grid-' + this.id;" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    // Filter-Input" & @CRLF
    $sJs &= "    if(this.filterable) {" & @CRLF
    $sJs &= "      const filterDiv = document.createElement('div');" & @CRLF
    $sJs &= "      filterDiv.className = 'mb-4';" & @CRLF
    $sJs &= "      const input = document.createElement('input');" & @CRLF
    $sJs &= "      input.type = 'text';" & @CRLF
    $sJs &= "      input.placeholder = 'Suchen...';" & @CRLF
    $sJs &= "      input.value = this.filterValue;" & @CRLF
    $sJs &= "      input.className = 'w-full px-3 py-2 border border-gray-300 rounded-md dark:bg-gray-800 dark:border-gray-600';" & @CRLF
    $sJs &= "      input.oninput = (e) => this.filter(e.target.value);" & @CRLF
    $sJs &= "      filterDiv.appendChild(input);" & @CRLF
    $sJs &= "      container.appendChild(filterDiv);" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    // Table" & @CRLF
    $sJs &= "    const table = document.createElement('table');" & @CRLF
    $sJs &= "    table.className = 'w-full border-collapse bg-white dark:bg-gray-800 rounded-lg overflow-hidden shadow';" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    // Header" & @CRLF
    $sJs &= "    const thead = document.createElement('thead');" & @CRLF
    $sJs &= "    thead.className = 'bg-gray-100 dark:bg-gray-700';" & @CRLF
    $sJs &= "    const headerRow = document.createElement('tr');" & @CRLF
    $sJs &= "    this.columns.forEach(col => {" & @CRLF
    $sJs &= "      const th = document.createElement('th');" & @CRLF
    $sJs &= "      th.className = 'px-4 py-3 text-left font-medium text-gray-700 dark:text-gray-200';" & @CRLF
    $sJs &= "      if(this.sortable) {" & @CRLF
    $sJs &= "        th.className += ' cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-600';" & @CRLF
    $sJs &= "        th.onclick = () => this.sort(col.key);" & @CRLF
    $sJs &= "      }" & @CRLF
    $sJs &= "      th.textContent = col.label || col.key;" & @CRLF
    $sJs &= "      if(this.sortColumn === col.key) {" & @CRLF
    $sJs &= "        th.textContent += this.sortDir === 'asc' ? ' \\u25B2' : ' \\u25BC';" & @CRLF
    $sJs &= "      }" & @CRLF
    $sJs &= "      headerRow.appendChild(th);" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "    thead.appendChild(headerRow);" & @CRLF
    $sJs &= "    table.appendChild(thead);" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    // Body" & @CRLF
    $sJs &= "    const tbody = document.createElement('tbody');" & @CRLF
    $sJs &= "    const data = this.getFilteredData();" & @CRLF
    $sJs &= "    data.forEach((row, idx) => {" & @CRLF
    $sJs &= "      const tr = document.createElement('tr');" & @CRLF
    $sJs &= "      tr.className = 'border-t border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700';" & @CRLF
    $sJs &= "      if(this.selectedRow === idx) tr.className += ' bg-blue-100 dark:bg-blue-900';" & @CRLF
    $sJs &= "      tr.onclick = () => this.selectRow(idx);" & @CRLF
    $sJs &= "      this.columns.forEach(col => {" & @CRLF
    $sJs &= "        const td = document.createElement('td');" & @CRLF
    $sJs &= "        td.className = 'px-4 py-3 text-gray-800 dark:text-gray-200';" & @CRLF
    $sJs &= "        td.textContent = row[col.key] !== undefined ? row[col.key] : '';" & @CRLF
    $sJs &= "        tr.appendChild(td);" & @CRLF
    $sJs &= "      });" & @CRLF
    $sJs &= "      tbody.appendChild(tr);" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "    table.appendChild(tbody);" & @CRLF
    $sJs &= "    container.appendChild(table);" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    // Footer mit Anzahl" & @CRLF
    $sJs &= "    const footer = document.createElement('div');" & @CRLF
    $sJs &= "    footer.className = 'mt-2 text-sm text-gray-500';" & @CRLF
    $sJs &= "    footer.textContent = data.length + ' Eintraege';" & @CRLF
    $sJs &= "    container.appendChild(footer);" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    return container;" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "}" & @CRLF
    $sJs &= "" & @CRLF

    Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Map-Komponente (Leaflet.js)
Func __WV2React_GenerateMapComponent()
    Local $sJs = ""

    $sJs &= "class WV2Map {" & @CRLF
    $sJs &= "  constructor(id, options) {" & @CRLF
    $sJs &= "    this.id = id;" & @CRLF
    $sJs &= "    this.center = options.center || [51.505, -0.09];" & @CRLF
    $sJs &= "    this.zoom = options.zoom || 13;" & @CRLF
    $sJs &= "    this.markers = options.markers || [];" & @CRLF
    $sJs &= "    this.map = null;" & @CRLF
    $sJs &= "    this.markerLayers = [];" & @CRLF
    $sJs &= "    this.draggable = options.draggable !== false;" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  update(payload) {" & @CRLF
    $sJs &= "    if(payload.markers) {" & @CRLF
    $sJs &= "      this.markers = payload.markers;" & @CRLF
    $sJs &= "      this.updateMarkers();" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "    if(payload.center) {" & @CRLF
    $sJs &= "      this.center = payload.center;" & @CRLF
    $sJs &= "      if(this.map) this.map.setView(this.center, this.zoom);" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  getState() {" & @CRLF
    $sJs &= "    return {" & @CRLF
    $sJs &= "      center: this.map ? this.map.getCenter() : this.center," & @CRLF
    $sJs &= "      zoom: this.map ? this.map.getZoom() : this.zoom," & @CRLF
    $sJs &= "      markers: this.markers" & @CRLF
    $sJs &= "    };" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  clearMarkers() {" & @CRLF
    $sJs &= "    this.markers = [];" & @CRLF
    $sJs &= "    this.updateMarkers();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  addMarker(lat, lng, popup, color, draggable) {" & @CRLF
    $sJs &= "    this.markers.push({ lat: lat, lng: lng, popup: popup || '', color: color || '#3B82F6', draggable: draggable !== false });" & @CRLF
    $sJs &= "    this.updateMarkers();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  updateMarkers() {" & @CRLF
    $sJs &= "    if(!this.map) return;" & @CRLF
    $sJs &= "    this.markerLayers.forEach(m => this.map.removeLayer(m));" & @CRLF
    $sJs &= "    this.markerLayers = [];" & @CRLF
    $sJs &= "    this.markers.forEach((m, idx) => {" & @CRLF
    $sJs &= "      const marker = L.marker([m.lat, m.lng], { draggable: this.draggable });" & @CRLF
    $sJs &= "      if(m.popup) marker.bindPopup(m.popup);" & @CRLF
    $sJs &= "      if(m.color) {" & @CRLF
    $sJs &= "        marker.setIcon(L.divIcon({" & @CRLF
    $sJs &= "          className: 'custom-marker'," & @CRLF
    $sJs &= "          html: '<div style=""background:' + m.color + ';width:24px;height:24px;border-radius:50%;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3);""></div>'," & @CRLF
    $sJs &= "          iconSize: [24, 24]," & @CRLF
    $sJs &= "          iconAnchor: [12, 12]" & @CRLF
    $sJs &= "        }));" & @CRLF
    $sJs &= "      }" & @CRLF
    $sJs &= "      marker.on('dragend', (e) => {" & @CRLF
    $sJs &= "        const pos = e.target.getLatLng();" & @CRLF
    $sJs &= "        this.markers[idx].lat = pos.lat;" & @CRLF
    $sJs &= "        this.markers[idx].lng = pos.lng;" & @CRLF
    $sJs &= "        WV2Bridge.sendEvent('onMarkerMove', this.id, {" & @CRLF
    $sJs &= "          index: idx," & @CRLF
    $sJs &= "          marker: this.markers[idx]," & @CRLF
    $sJs &= "          newCoords: { lat: pos.lat, lng: pos.lng }" & @CRLF
    $sJs &= "        });" & @CRLF
    $sJs &= "      });" & @CRLF
    $sJs &= "      marker.on('click', () => {" & @CRLF
    $sJs &= "        WV2Bridge.sendEvent('onMarkerClick', this.id, { index: idx, marker: this.markers[idx] });" & @CRLF
    $sJs &= "      });" & @CRLF
    $sJs &= "      marker.addTo(this.map);" & @CRLF
    $sJs &= "      this.markerLayers.push(marker);" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  initMap(container) {" & @CRLF
    $sJs &= "    setTimeout(() => {" & @CRLF
    $sJs &= "      const mapDiv = container.querySelector('.map-inner');" & @CRLF
    $sJs &= "      if(!mapDiv || this.map) return;" & @CRLF
    $sJs &= "      this.map = L.map(mapDiv).setView(this.center, this.zoom);" & @CRLF
    $sJs &= "      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {" & @CRLF
    $sJs &= "        attribution: '&copy; OpenStreetMap contributors'" & @CRLF
    $sJs &= "      }).addTo(this.map);" & @CRLF
    $sJs &= "      this.updateMarkers();" & @CRLF
    $sJs &= "      this.map.on('click', (e) => {" & @CRLF
    $sJs &= "        WV2Bridge.sendEvent('onMapClick', this.id, { lat: e.latlng.lat, lng: e.latlng.lng });" & @CRLF
    $sJs &= "      });" & @CRLF
    $sJs &= "    }, 100);" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  destroy() {" & @CRLF
    $sJs &= "    if(this.map) {" & @CRLF
    $sJs &= "      this.map.remove();" & @CRLF
    $sJs &= "      this.map = null;" & @CRLF
    $sJs &= "    }" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  render() {" & @CRLF
    $sJs &= "    const container = document.createElement('div');" & @CRLF
    $sJs &= "    container.className = 'component-container';" & @CRLF
    $sJs &= "    container.id = 'map-' + this.id;" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    const mapDiv = document.createElement('div');" & @CRLF
    $sJs &= "    mapDiv.className = 'map-inner map-container rounded-lg overflow-hidden shadow-lg';" & @CRLF
    $sJs &= "    container.appendChild(mapDiv);" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "    this.initMap(container);" & @CRLF
    $sJs &= "    return container;" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "}" & @CRLF
    $sJs &= "" & @CRLF

    Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Card-Komponente
Func __WV2React_GenerateCardComponent()
    Local $sJs = ""

    $sJs &= "class WV2Card {" & @CRLF
    $sJs &= "  constructor(id, options) {" & @CRLF
    $sJs &= "    this.id = id;" & @CRLF
    $sJs &= "    this.title = options.title || '';" & @CRLF
    $sJs &= "    this.content = options.content || '';" & @CRLF
    $sJs &= "    this.icon = options.icon || '';" & @CRLF
    $sJs &= "    this.color = options.color || WV2Bridge.theme.primary;" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  update(payload) {" & @CRLF
    $sJs &= "    if(payload.title !== undefined) this.title = payload.title;" & @CRLF
    $sJs &= "    if(payload.content !== undefined) this.content = payload.content;" & @CRLF
    $sJs &= "    WV2Bridge.renderRoot();" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  getState() {" & @CRLF
    $sJs &= "    return { title: this.title, content: this.content };" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  render() {" & @CRLF
    $sJs &= "    const card = document.createElement('div');" & @CRLF
    $sJs &= "    card.className = 'component-container';" & @CRLF
    $sJs &= "    let html = '<div class=""bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow"">';" & @CRLF
    $sJs &= "    html += '<div class=""flex items-center gap-4 mb-4"">';" & @CRLF
    $sJs &= "    if(this.icon) { html += '<div class=""text-3xl"" style=""color:' + this.color + '"">' + this.icon + '</div>'; }" & @CRLF
    $sJs &= "    html += '<h3 class=""text-xl font-bold text-gray-800 dark:text-white"">' + this.title + '</h3>';" & @CRLF
    $sJs &= "    html += '</div>';" & @CRLF
    $sJs &= "    html += '<div class=""text-gray-600 dark:text-gray-300"">' + this.content + '</div>';" & @CRLF
    $sJs &= "    html += '</div>';" & @CRLF
    $sJs &= "    card.innerHTML = html;" & @CRLF
    $sJs &= "    return card;" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "}" & @CRLF
    $sJs &= "" & @CRLF

    Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Theme anwenden
Func __WV2React_ApplyTheme()
    Local $sMode = ($__g_sWV2React_Theme = "dark") ? "dark" : "light"
    Local $sCmd = '{"action":"setTheme","payload":{"mode":"' & $sMode & '","primaryColor":"' & $__g_sWV2React_PrimaryColor & '"}}'
    _WV2React_SendCommand($sCmd)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Einfacher JSON-Value-Extraktor
Func __WV2React_JsonGetValue($sJson, $sKey)
    Local $sPattern = '"' & $sKey & '"\s*:\s*"([^"]*)"'
    Local $aMatch = StringRegExp($sJson, $sPattern, 1)
    If @error Then Return ""
    Return $aMatch[0]
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Array zu JSON konvertieren (vereinfacht)
Func __WV2React_ArrayToJson($aData)
    If Not IsArray($aData) Then Return "{}"

    ; 1D Array = einfaches Array
    If UBound($aData, 0) = 1 Then
        Local $sJson = "["
        For $i = 0 To UBound($aData) - 1
            If $i > 0 Then $sJson &= ","
            If IsString($aData[$i]) Then
                $sJson &= '"' & StringReplace($aData[$i], '"', '\"') & '"'
            ElseIf IsNumber($aData[$i]) Then
                $sJson &= $aData[$i]
            Else
                $sJson &= "null"
            EndIf
        Next
        $sJson &= "]"
        Return $sJson
    EndIf

    ; 2D Array = Array von Objekten (erste Zeile = Keys)
    If UBound($aData, 0) = 2 Then
        Local $sJson = "["
        Local $iCols = UBound($aData, 2)
        Local $aKeys[$iCols]

        ; Erste Zeile = Keys
        For $j = 0 To $iCols - 1
            $aKeys[$j] = $aData[0][$j]
        Next

        ; Restliche Zeilen = Daten
        For $i = 1 To UBound($aData) - 1
            If $i > 1 Then $sJson &= ","
            $sJson &= "{"
            For $j = 0 To $iCols - 1
                If $j > 0 Then $sJson &= ","
                $sJson &= '"' & $aKeys[$j] & '":'
                If IsString($aData[$i][$j]) Then
                    $sJson &= '"' & StringReplace($aData[$i][$j], '"', '\"') & '"'
                ElseIf IsNumber($aData[$i][$j]) Then
                    $sJson &= $aData[$i][$j]
                Else
                    $sJson &= "null"
                EndIf
            Next
            $sJson &= "}"
        Next
        $sJson &= "]"
        Return $sJson
    EndIf

    Return "{}"
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; UI-Komponenten aus externer Datei laden
; Diese Funktion laedt all-components.js aus dem js/ Unterverzeichnis
Func __WV2React_LoadUIComponentsFromFile()
    Local $sJs = ""

    ; Pfad zur JS-Datei ermitteln (relativ zum Include-Verzeichnis)
    Local $sScriptDir = @ScriptDir
    Local $sJsFile = ""

    ; Verschiedene Pfade versuchen
    Local $aPaths[4]
    $aPaths[0] = $sScriptDir & "\Include\js\all-components.js"
    $aPaths[1] = $sScriptDir & "\..\Include\js\all-components.js"
    $aPaths[2] = @ScriptDir & "\js\all-components.js"
    $aPaths[3] = StringReplace(@ScriptFullPath, @ScriptName, "") & "Include\js\all-components.js"

    For $i = 0 To UBound($aPaths) - 1
        If FileExists($aPaths[$i]) Then
            $sJsFile = $aPaths[$i]
            ExitLoop
        EndIf
    Next

    ; Fallback: Suche im ReactFramework Verzeichnis
    If $sJsFile = "" Then
        Local $sReactDir = StringRegExpReplace($sScriptDir, "\\Examples$|\\Beispiele$", "")
        $sJsFile = $sReactDir & "\Include\js\all-components.js"
    EndIf

    If FileExists($sJsFile) Then
        ; Datei lesen
        Local $hFile = FileOpen($sJsFile, 0) ; Read mode
        If $hFile <> -1 Then
            $sJs = FileRead($hFile)
            FileClose($hFile)
            ConsoleWrite("[WV2React] UI-Komponenten geladen aus: " & $sJsFile & @CRLF)
        Else
            ConsoleWrite("[WV2React] FEHLER: Konnte JS-Datei nicht oeffnen: " & $sJsFile & @CRLF)
        EndIf
    Else
        ConsoleWrite("[WV2React] WARNUNG: all-components.js nicht gefunden!" & @CRLF)
        ConsoleWrite("[WV2React] Gesuchte Pfade:" & @CRLF)
        For $i = 0 To UBound($aPaths) - 1
            ConsoleWrite("  - " & $aPaths[$i] & @CRLF)
        Next
        ; Minimale Fallback-Komponenten (nur fuer Notfall)
        $sJs = "console.warn('WV2React: UI-Komponenten nicht geladen - all-components.js fehlt!');" & @CRLF
    EndIf

    Return $sJs & @CRLF
EndFunc

; ===============================================================================================================================
; End of WV2React_Core.au3
; ===============================================================================================================================
