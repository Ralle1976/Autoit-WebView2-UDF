#include-once
#include "..\..\..\Include\WebView2_Native.au3"

; #INDEX# =======================================================================================================================
; Title .........: WV2_Animation
; AutoIt Version : 3.3.16.1+
; Language ......: German/English
; Description ...: Anime.js Animation Framework Integration fuer WebView2
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Diese Extension integriert Anime.js (https://animejs.com) in WebView2
; und ermoeglicht hochwertige CSS/SVG/DOM Animationen direkt aus AutoIt.
;
; FEATURES:
; - Property Animations (translate, rotate, scale, opacity, color, etc.)
; - Timeline-basierte sequenzielle Animationen
; - Stagger Effects (gestaffelte Animationen fuer mehrere Elemente)
; - SVG Path Animations (morphing, drawing)
; - Easing Functions (easeInOutQuad, spring, elastic, etc.)
; - Playback Controls (play, pause, restart, reverse)
; - Callbacks (onComplete, onUpdate)
;
; VERWENDUNG:
; 1. _WV2Anim_Init() - WebView2 mit Anime.js initialisieren
; 2. Elemente mit IDs/Classes im HTML erstellen
; 3. _WV2Anim_Animate() - Einzelne Animationen
; 4. _WV2Anim_Timeline() - Komplexe Animationssequenzen
; 5. _WV2Anim_Stagger() - Gestaffelte Animationen
;
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $WV2ANIM_VERSION = "1.0.0"
Global Const $WV2ANIM_CDN = "https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.min.js"

; Easing Presets
Global Const $WV2ANIM_EASE_LINEAR = "linear"
Global Const $WV2ANIM_EASE_INQUAD = "easeInQuad"
Global Const $WV2ANIM_EASE_OUTQUAD = "easeOutQuad"
Global Const $WV2ANIM_EASE_INOUTQUAD = "easeInOutQuad"
Global Const $WV2ANIM_EASE_INCUBIC = "easeInCubic"
Global Const $WV2ANIM_EASE_OUTCUBIC = "easeOutCubic"
Global Const $WV2ANIM_EASE_INOUTCUBIC = "easeInOutCubic"
Global Const $WV2ANIM_EASE_INEXPO = "easeInExpo"
Global Const $WV2ANIM_EASE_OUTEXPO = "easeOutExpo"
Global Const $WV2ANIM_EASE_INOUTEXPO = "easeInOutExpo"
Global Const $WV2ANIM_EASE_INELASTIC = "easeInElastic"
Global Const $WV2ANIM_EASE_OUTELASTIC = "easeOutElastic"
Global Const $WV2ANIM_EASE_INOUTELASTIC = "easeInOutElastic"
Global Const $WV2ANIM_EASE_SPRING = "spring(1, 80, 10, 0)"
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_aWV2Anim_WebView = 0             ; WebView2 Instanz
Global $__g_aWV2Anim_Timelines[1][2]         ; [n][0]=ID, [n][1]=Status
$__g_aWV2Anim_Timelines[0][0] = 0            ; Count
Global $__g_iWV2Anim_TimelineCounter = 0     ; Timeline ID Counter
Global $__g_bWV2Anim_Initialized = False     ; Init-Status
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WV2Anim_Init
; _WV2Anim_Animate
; _WV2Anim_AnimateEx
; _WV2Anim_Timeline
; _WV2Anim_TimelineAdd
; _WV2Anim_TimelinePlay
; _WV2Anim_TimelinePause
; _WV2Anim_TimelineRestart
; _WV2Anim_TimelineReverse
; _WV2Anim_Stagger
; _WV2Anim_Stop
; _WV2Anim_StopAll
; _WV2Anim_SetHTML
; _WV2Anim_ExecuteJS
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_Init
; Description ...: Initialisiert WebView2 mit Anime.js Animation Framework
; Syntax ........: _WV2Anim_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sInitialHTML = ""])
; Parameters ....: $hWnd         - Handle des Parent-Fensters
;                  $iLeft/Top    - Position
;                  $iWidth/Height- Groesse
;                  $sInitialHTML - [optional] Initiales HTML (wenn leer, wird Demo-HTML geladen)
; Return values .: Success - WebView2 Array
;                  Failure - 0 und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, $sInitialHTML = "")
    ; WebView2 erstellen
    Local $aWebView = _WebView2_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight)
    If @error Then Return SetError(1, @extended, 0)

    $__g_aWV2Anim_WebView = $aWebView

    ; Framework-HTML generieren
    Local $sHtml = __WV2Anim_GenerateHTML($sInitialHTML)
    _WebView2_NavigateToString($aWebView, $sHtml)

    ; Warten bis Anime.js geladen ist (max 5 Sekunden)
    Local $iTimeout = 5000
    Local $iStart = TimerInit()
    Local $bAnimeLoaded = False

    While TimerDiff($iStart) < $iTimeout
        Sleep(100)
        Local $sResult = _WebView2_ExecuteScript($aWebView, "typeof anime !== 'undefined' ? 'loaded' : 'waiting'", 500)
        If $sResult = '"loaded"' Or $sResult = "loaded" Then
            $bAnimeLoaded = True
            ConsoleWrite("[WV2_Animation] Anime.js loaded successfully!" & @CRLF)
            ExitLoop
        EndIf
    WEnd

    If Not $bAnimeLoaded Then
        ConsoleWrite("[WV2_Animation] WARNING: Anime.js may not have loaded from CDN!" & @CRLF)
    EndIf

    $__g_bWV2Anim_Initialized = True
    ConsoleWrite("[WV2_Animation] Initialized with Anime.js v3.2.1" & @CRLF)

    Return $aWebView
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_Animate
; Description ...: Animiert ein oder mehrere DOM-Elemente (einfache Syntax)
; Syntax ........: _WV2Anim_Animate($sSelector, $aProperties, [$iDuration = 1000], [$sEasing = "easeOutQuad"])
; Parameters ....: $sSelector   - CSS-Selektor (".box", "#myElement", "div", etc.)
;                  $aProperties - Array mit [Property, Value] Paaren:
;                                 ["translateX", "250px", "rotate", "360deg", "scale", "1.5"]
;                  $iDuration   - [optional] Dauer in ms (Standard: 1000)
;                  $sEasing     - [optional] Easing-Funktion (Standard: "easeOutQuad")
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_Animate($sSelector, $aProperties, $iDuration = 1000, $sEasing = "easeOutQuad")
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    If Not IsArray($aProperties) Then Return SetError(2, 0, False)

    ; Properties zu JSON konvertieren
    Local $sProps = "{"
    For $i = 0 To UBound($aProperties) - 1 Step 2
        If $i > 0 Then $sProps &= ","
        Local $sKey = $aProperties[$i]
        Local $sVal = $aProperties[$i + 1]

        ; Numerische Werte ohne Quotes
        If StringIsFloat($sVal) Or StringIsInt($sVal) Then
            $sProps &= '"' & $sKey & '":' & $sVal
        Else
            ; String-Werte mit Quotes
            $sProps &= '"' & $sKey & '":"' & $sVal & '"'
        EndIf
    Next
    $sProps &= "}"

    ; JavaScript Command
    Local $sScript = "WV2Anim.animate('" & $sSelector & "', " & $sProps & ", " & $iDuration & ", '" & $sEasing & "');"
    _WV2Anim_ExecuteJS($sScript)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_AnimateEx
; Description ...: Erweiterte Animation mit allen Anime.js Optionen (JSON-basiert)
; Syntax ........: _WV2Anim_AnimateEx($sSelector, $sJsonOptions)
; Parameters ....: $sSelector    - CSS-Selektor
;                  $sJsonOptions - JSON-String mit Anime.js Optionen:
;                                  '{"translateX": 250, "duration": 1000, "easing": "easeOutQuad", "delay": 500}'
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_AnimateEx($sSelector, $sJsonOptions)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)

    Local $sScript = "WV2Anim.animateEx('" & $sSelector & "', " & $sJsonOptions & ");"
    _WV2Anim_ExecuteJS($sScript)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_Timeline
; Description ...: Erstellt eine neue Animations-Timeline (fuer sequenzielle Animationen)
; Syntax ........: _WV2Anim_Timeline([$bAutoplay = True])
; Parameters ....: $bAutoplay - [optional] Timeline automatisch starten (Standard: True)
; Return values .: Success - Timeline ID
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_Timeline($bAutoplay = True)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, "")

    ; Neue Timeline ID
    $__g_iWV2Anim_TimelineCounter += 1
    Local $sTimelineID = "timeline_" & $__g_iWV2Anim_TimelineCounter

    ; Registrieren
    Local $iIndex = $__g_aWV2Anim_Timelines[0][0] + 1
    ReDim $__g_aWV2Anim_Timelines[$iIndex + 1][2]
    $__g_aWV2Anim_Timelines[0][0] = $iIndex
    $__g_aWV2Anim_Timelines[$iIndex][0] = $sTimelineID
    $__g_aWV2Anim_Timelines[$iIndex][1] = "created"

    ; Timeline im Browser erstellen
    Local $sAutoplay = $bAutoplay ? "true" : "false"
    Local $sScript = "WV2Anim.createTimeline('" & $sTimelineID & "', " & $sAutoplay & ");"
    _WV2Anim_ExecuteJS($sScript)

    Return $sTimelineID
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_TimelineAdd
; Description ...: Fuegt einer Timeline eine Animation hinzu
; Syntax ........: _WV2Anim_TimelineAdd($sTimelineID, $sSelector, $aProperties, [$iDuration = 1000], [$sEasing = "easeOutQuad"], [$iOffset = 0])
; Parameters ....: $sTimelineID - Timeline ID (von _WV2Anim_Timeline)
;                  $sSelector   - CSS-Selektor
;                  $aProperties - Array mit Property/Value Paaren
;                  $iDuration   - [optional] Dauer in ms
;                  $sEasing     - [optional] Easing-Funktion
;                  $iOffset     - [optional] Offset in ms (relativ zum vorherigen Step)
;                                 "+=500" = 500ms nach vorherigem
;                                 "-=200" = 200ms overlap mit vorherigem
;                                 "1000"  = bei absoluter Position 1000ms
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_TimelineAdd($sTimelineID, $sSelector, $aProperties, $iDuration = 1000, $sEasing = "easeOutQuad", $iOffset = 0)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    If Not IsArray($aProperties) Then Return SetError(2, 0, False)

    ; Properties zu JSON
    Local $sProps = "{"
    For $i = 0 To UBound($aProperties) - 1 Step 2
        If $i > 0 Then $sProps &= ","
        Local $sKey = $aProperties[$i]
        Local $sVal = $aProperties[$i + 1]

        If StringIsFloat($sVal) Or StringIsInt($sVal) Then
            $sProps &= '"' & $sKey & '":' & $sVal
        Else
            $sProps &= '"' & $sKey & '":"' & $sVal & '"'
        EndIf
    Next
    $sProps &= "}"

    ; Offset formatieren
    Local $sOffsetStr = ""
    If IsString($iOffset) Then
        $sOffsetStr = '"' & $iOffset & '"'
    Else
        $sOffsetStr = $iOffset
    EndIf

    Local $sScript = "WV2Anim.timelineAdd('" & $sTimelineID & "', '" & $sSelector & "', " & $sProps & ", " & $iDuration & ", '" & $sEasing & "', " & $sOffsetStr & ");"
    _WV2Anim_ExecuteJS($sScript)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_TimelinePlay
; Description ...: Startet eine Timeline
; Syntax ........: _WV2Anim_TimelinePlay($sTimelineID)
; Parameters ....: $sTimelineID - Timeline ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_TimelinePlay($sTimelineID)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.timelinePlay('" & $sTimelineID & "');"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_TimelinePause
; Description ...: Pausiert eine Timeline
; Syntax ........: _WV2Anim_TimelinePause($sTimelineID)
; Parameters ....: $sTimelineID - Timeline ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_TimelinePause($sTimelineID)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.timelinePause('" & $sTimelineID & "');"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_TimelineRestart
; Description ...: Startet eine Timeline neu
; Syntax ........: _WV2Anim_TimelineRestart($sTimelineID)
; Parameters ....: $sTimelineID - Timeline ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_TimelineRestart($sTimelineID)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.timelineRestart('" & $sTimelineID & "');"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_TimelineReverse
; Description ...: Kehrt eine Timeline um (spielt rueckwaerts)
; Syntax ........: _WV2Anim_TimelineReverse($sTimelineID)
; Parameters ....: $sTimelineID - Timeline ID
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_TimelineReverse($sTimelineID)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.timelineReverse('" & $sTimelineID & "');"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_Stagger
; Description ...: Gestaffelte Animation fuer mehrere Elemente
; Syntax ........: _WV2Anim_Stagger($sSelector, $aProperties, [$iDelay = 100], [$iDuration = 1000], [$sEasing = "easeOutQuad"])
; Parameters ....: $sSelector   - CSS-Selektor (matcht mehrere Elemente: ".box", "li", etc.)
;                  $aProperties - Array mit Property/Value Paaren
;                  $iDelay      - [optional] Verzoegerung zwischen Elementen in ms (Standard: 100)
;                  $iDuration   - [optional] Dauer jeder Animation in ms (Standard: 1000)
;                  $sEasing     - [optional] Easing-Funktion (Standard: "easeOutQuad")
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_Stagger($sSelector, $aProperties, $iDelay = 100, $iDuration = 1000, $sEasing = "easeOutQuad")
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    If Not IsArray($aProperties) Then Return SetError(2, 0, False)

    ; Properties zu JSON
    Local $sProps = "{"
    For $i = 0 To UBound($aProperties) - 1 Step 2
        If $i > 0 Then $sProps &= ","
        Local $sKey = $aProperties[$i]
        Local $sVal = $aProperties[$i + 1]

        If StringIsFloat($sVal) Or StringIsInt($sVal) Then
            $sProps &= '"' & $sKey & '":' & $sVal
        Else
            $sProps &= '"' & $sKey & '":"' & $sVal & '"'
        EndIf
    Next
    $sProps &= "}"

    Local $sScript = "WV2Anim.stagger('" & $sSelector & "', " & $sProps & ", " & $iDelay & ", " & $iDuration & ", '" & $sEasing & "');"
    _WV2Anim_ExecuteJS($sScript)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_Stop
; Description ...: Stoppt alle Animationen fuer ein Element
; Syntax ........: _WV2Anim_Stop($sSelector)
; Parameters ....: $sSelector - CSS-Selektor
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_Stop($sSelector)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.stop('" & $sSelector & "');"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_StopAll
; Description ...: Stoppt alle laufenden Animationen
; Syntax ........: _WV2Anim_StopAll()
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_StopAll()
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    Local $sScript = "WV2Anim.stopAll();"
    _WV2Anim_ExecuteJS($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_SetHTML
; Description ...: Setzt den HTML-Inhalt des Body-Elements
; Syntax ........: _WV2Anim_SetHTML($sHTML)
; Parameters ....: $sHTML - HTML-Code
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_SetHTML($sHTML)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)

    ; Escape fuer JavaScript
    $sHTML = StringReplace($sHTML, "\", "\\")
    $sHTML = StringReplace($sHTML, "'", "\'")
    $sHTML = StringReplace($sHTML, @CRLF, "\n")
    $sHTML = StringReplace($sHTML, @CR, "\n")
    $sHTML = StringReplace($sHTML, @LF, "\n")

    Local $sScript = "document.body.innerHTML = '" & $sHTML & "';"
    _WV2Anim_ExecuteJS($sScript)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2Anim_ExecuteJS
; Description ...: Fuehrt beliebigen JavaScript-Code aus (fuer fortgeschrittene Nutzung)
; Syntax ........: _WV2Anim_ExecuteJS($sScript)
; Parameters ....: $sScript - JavaScript-Code
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2Anim_ExecuteJS($sScript)
    If Not $__g_bWV2Anim_Initialized Then Return SetError(1, 0, False)
    _WebView2_ExecuteScriptAsync($__g_aWV2Anim_WebView, $sScript)
    Return True
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert HTML mit Anime.js CDN und Wrapper
Func __WV2Anim_GenerateHTML($sUserHTML = "")
    Local $sHtml = '<!DOCTYPE html>' & @CRLF
    $sHtml &= '<html lang="de">' & @CRLF
    $sHtml &= '<head>' & @CRLF
    $sHtml &= '  <meta charset="UTF-8">' & @CRLF
    $sHtml &= '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' & @CRLF
    $sHtml &= '  <title>WV2 Animation Framework</title>' & @CRLF
    $sHtml &= '  <style>' & @CRLF
    $sHtml &= '    * { margin: 0; padding: 0; box-sizing: border-box; }' & @CRLF
    $sHtml &= '    body { font-family: system-ui, -apple-system, sans-serif; background: #1a1a2e; color: #eee; overflow-x: hidden; }' & @CRLF
    $sHtml &= '  </style>' & @CRLF
    $sHtml &= '</head>' & @CRLF
    $sHtml &= '<body>' & @CRLF

    ; User-HTML einfuegen (falls vorhanden)
    If $sUserHTML <> "" Then
        $sHtml &= $sUserHTML & @CRLF
    Else
        ; Fallback: Leerer Container
        $sHtml &= '  <div id="container" style="width:100%;height:100vh;"></div>' & @CRLF
    EndIf

    $sHtml &= '' & @CRLF
    $sHtml &= '  <!-- Anime.js CDN -->' & @CRLF
    $sHtml &= '  <script src="' & $WV2ANIM_CDN & '"></script>' & @CRLF
    $sHtml &= '' & @CRLF
    $sHtml &= '  <!-- WV2 Animation Wrapper -->' & @CRLF
    $sHtml &= '  <script>' & @CRLF
    $sHtml &= __WV2Anim_GenerateJSWrapper()
    $sHtml &= '  </script>' & @CRLF
    $sHtml &= '</body>' & @CRLF
    $sHtml &= '</html>'

    Return $sHtml
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Laedt das JavaScript Wrapper-Modul
Func __WV2Anim_GenerateJSWrapper()
    ; Pfad zur JS-Datei
    Local $sJsFile = @ScriptDir & "\Include\js\animation-wrapper.js"

    ; Alternative Pfade probieren
    If Not FileExists($sJsFile) Then
        $sJsFile = @ScriptDir & "\js\animation-wrapper.js"
    EndIf
    If Not FileExists($sJsFile) Then
        $sJsFile = @ScriptDir & "\..\Include\js\animation-wrapper.js"
    EndIf
    If Not FileExists($sJsFile) Then
        ; Fallback: Inline-Wrapper generieren
        ConsoleWrite("[WV2_Animation] WARNING: animation-wrapper.js nicht gefunden, verwende Inline-Fallback" & @CRLF)
        Return __WV2Anim_GenerateInlineWrapper()
    EndIf

    ; Datei lesen
    Local $hFile = FileOpen($sJsFile, 0)
    If $hFile = -1 Then Return __WV2Anim_GenerateInlineWrapper()

    Local $sJs = FileRead($hFile)
    FileClose($hFile)

    ConsoleWrite("[WV2_Animation] Loaded wrapper: " & $sJsFile & @CRLF)
    Return $sJs
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Generiert minimalen Inline-Wrapper (Fallback)
Func __WV2Anim_GenerateInlineWrapper()
    Local $sJs = ""
    $sJs &= "// WV2 Animation Wrapper (Inline Fallback)" & @CRLF
    $sJs &= "const WV2Anim = {" & @CRLF
    $sJs &= "  timelines: new Map()," & @CRLF
    $sJs &= "  activeAnimations: []," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  animate: function(selector, props, duration = 1000, easing = 'easeOutQuad') {" & @CRLF
    $sJs &= "    const anim = anime({ targets: selector, ...props, duration, easing });" & @CRLF
    $sJs &= "    this.activeAnimations.push(anim);" & @CRLF
    $sJs &= "    return anim;" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  animateEx: function(selector, options) {" & @CRLF
    $sJs &= "    const anim = anime({ targets: selector, ...options });" & @CRLF
    $sJs &= "    this.activeAnimations.push(anim);" & @CRLF
    $sJs &= "    return anim;" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  createTimeline: function(id, autoplay = true) {" & @CRLF
    $sJs &= "    const tl = anime.timeline({ autoplay });" & @CRLF
    $sJs &= "    this.timelines.set(id, tl);" & @CRLF
    $sJs &= "    return tl;" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  timelineAdd: function(id, selector, props, duration, easing, offset) {" & @CRLF
    $sJs &= "    const tl = this.timelines.get(id);" & @CRLF
    $sJs &= "    if (!tl) return;" & @CRLF
    $sJs &= "    tl.add({ targets: selector, ...props, duration, easing }, offset);" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  timelinePlay: function(id) { const tl = this.timelines.get(id); if (tl) tl.play(); }," & @CRLF
    $sJs &= "  timelinePause: function(id) { const tl = this.timelines.get(id); if (tl) tl.pause(); }," & @CRLF
    $sJs &= "  timelineRestart: function(id) { const tl = this.timelines.get(id); if (tl) tl.restart(); }," & @CRLF
    $sJs &= "  timelineReverse: function(id) { const tl = this.timelines.get(id); if (tl) tl.reverse(); }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  stagger: function(selector, props, delay, duration, easing) {" & @CRLF
    $sJs &= "    const anim = anime({" & @CRLF
    $sJs &= "      targets: selector," & @CRLF
    $sJs &= "      ...props," & @CRLF
    $sJs &= "      duration," & @CRLF
    $sJs &= "      easing," & @CRLF
    $sJs &= "      delay: anime.stagger(delay)" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "    this.activeAnimations.push(anim);" & @CRLF
    $sJs &= "    return anim;" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  stop: function(selector) {" & @CRLF
    $sJs &= "    this.activeAnimations = this.activeAnimations.filter(a => {" & @CRLF
    $sJs &= "      if (a.animatables.some(t => document.querySelector(selector).contains(t.target))) {" & @CRLF
    $sJs &= "        a.pause();" & @CRLF
    $sJs &= "        return false;" & @CRLF
    $sJs &= "      }" & @CRLF
    $sJs &= "      return true;" & @CRLF
    $sJs &= "    });" & @CRLF
    $sJs &= "  }," & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "  stopAll: function() {" & @CRLF
    $sJs &= "    this.activeAnimations.forEach(a => a.pause());" & @CRLF
    $sJs &= "    this.activeAnimations = [];" & @CRLF
    $sJs &= "    this.timelines.forEach(tl => tl.pause());" & @CRLF
    $sJs &= "  }" & @CRLF
    $sJs &= "};" & @CRLF
    $sJs &= "" & @CRLF
    $sJs &= "console.log('WV2 Animation Wrapper v" & $WV2ANIM_VERSION & " loaded (Inline)');" & @CRLF

    Return $sJs
EndFunc

; ===============================================================================================================================
; End of WV2_Animation.au3
; ===============================================================================================================================
