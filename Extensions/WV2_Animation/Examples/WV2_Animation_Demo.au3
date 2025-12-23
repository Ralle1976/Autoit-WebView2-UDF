#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\Include\WV2_Animation.au3"

; ===============================================================================================================================
; WV2_Animation Demo - Umfassendes Showcase aller Animation-Features
; ===============================================================================================================================
;
; Dieses Beispiel demonstriert:
; - Basic Property Animations (translate, rotate, scale)
; - Timeline mit mehreren sequenziellen Schritten
; - Stagger Effects (gestaffelte Animationen)
; - Verschiedene Easing-Funktionen
; - SVG Path Drawing Animation
; - Helper-Animationen (shake, pulse, bounce, fade, slide)
; - Playback Controls (play, pause, restart, reverse)
;
; ===============================================================================================================================

; GUI erstellen
Global $hGUI = GUICreate("WV2 Animation Framework - Anime.js Showcase", 1200, 800, -1, -1, $WS_OVERLAPPEDWINDOW)

; Control Panel (rechts)
Global $btnBasic = GUICtrlCreateButton("1. Basic Animations", 1020, 20, 160, 30)
Global $btnTimeline = GUICtrlCreateButton("2. Timeline Demo", 1020, 60, 160, 30)
Global $btnStagger = GUICtrlCreateButton("3. Stagger Effect", 1020, 100, 160, 30)
Global $btnEasing = GUICtrlCreateButton("4. Easing Demo", 1020, 140, 160, 30)
Global $btnSVG = GUICtrlCreateButton("5. SVG Path Draw", 1020, 180, 160, 30)
Global $btnHelpers = GUICtrlCreateButton("6. Helper Animations", 1020, 220, 160, 30)
Global $btnCounter = GUICtrlCreateButton("7. Number Counter", 1020, 260, 160, 30)
Global $btnMorph = GUICtrlCreateButton("8. SVG Morph", 1020, 300, 160, 30)

GUICtrlCreateLabel("Controls:", 1020, 350, 160, 20)
Global $btnPlayTimeline = GUICtrlCreateButton("Play Timeline", 1020, 370, 75, 25)
Global $btnPauseTimeline = GUICtrlCreateButton("Pause", 1100, 370, 80, 25)
Global $btnRestartTimeline = GUICtrlCreateButton("Restart", 1020, 400, 75, 25)
Global $btnReverseTimeline = GUICtrlCreateButton("Reverse", 1100, 400, 80, 25)
Global $btnStopAll = GUICtrlCreateButton("Stop All", 1020, 440, 160, 30)
Global $btnReset = GUICtrlCreateButton("Reset View", 1020, 480, 160, 30)

GUICtrlCreateLabel("Info:", 1020, 530, 160, 20)
Global $lblInfo = GUICtrlCreateLabel("Klicken Sie auf einen Button" & @CRLF & "um die Animation zu starten.", 1020, 550, 160, 200)

GUISetState(@SW_SHOW, $hGUI)

; WebView2 mit Animation-Framework initialisieren
Global $aWebView = _WV2Anim_Init($hGUI, 10, 10, 1000, 780, __GenerateDemoHTML())
If @error Then
    MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!" & @CRLF & "Error: " & @error)
    Exit
EndIf

; Timeline fuer Timeline-Demo
Global $sTimeline = ""

; Hauptschleife
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $btnBasic
            Demo_BasicAnimations()
            UpdateInfo("Basic Animations" & @CRLF & "- Translate (bewegen)" & @CRLF & "- Rotate (drehen)" & @CRLF & "- Scale (skalieren)" & @CRLF & "- Opacity (transparenz)")

        Case $btnTimeline
            Demo_Timeline()
            UpdateInfo("Timeline Animation" & @CRLF & "Sequenzielle Animationen" & @CRLF & "mit verschiedenen Timings" & @CRLF & "und Offsets")

        Case $btnStagger
            Demo_Stagger()
            UpdateInfo("Stagger Effect" & @CRLF & "Gestaffelte Animationen" & @CRLF & "fuer mehrere Elemente" & @CRLF & "mit zeitlichen Verzoegerungen")

        Case $btnEasing
            Demo_Easing()
            UpdateInfo("Easing Functions" & @CRLF & "- Linear" & @CRLF & "- EaseInOutQuad" & @CRLF & "- EaseOutElastic" & @CRLF & "- Spring")

        Case $btnSVG
            Demo_SVGPath()
            UpdateInfo("SVG Path Drawing" & @CRLF & "Zeichnet SVG-Pfade" & @CRLF & "mit strokeDashoffset" & @CRLF & "Animation")

        Case $btnHelpers
            Demo_Helpers()
            UpdateInfo("Helper Animations" & @CRLF & "- Shake" & @CRLF & "- Pulse" & @CRLF & "- Bounce" & @CRLF & "- Fade In/Out" & @CRLF & "- Slide In")

        Case $btnCounter
            Demo_Counter()
            UpdateInfo("Number Counter" & @CRLF & "Animiert numerische Werte" & @CRLF & "von 0 bis 100" & @CRLF & "mit smooth transition")

        Case $btnMorph
            Demo_SVGMorph()
            UpdateInfo("SVG Path Morph" & @CRLF & "Morphing zwischen" & @CRLF & "zwei SVG-Pfaden" & @CRLF & "(Kreis zu Quadrat)")

        Case $btnPlayTimeline
            If $sTimeline <> "" Then
                _WV2Anim_TimelinePlay($sTimeline)
                UpdateInfo("Timeline: Play")
            EndIf

        Case $btnPauseTimeline
            If $sTimeline <> "" Then
                _WV2Anim_TimelinePause($sTimeline)
                UpdateInfo("Timeline: Pause")
            EndIf

        Case $btnRestartTimeline
            If $sTimeline <> "" Then
                _WV2Anim_TimelineRestart($sTimeline)
                UpdateInfo("Timeline: Restart")
            EndIf

        Case $btnReverseTimeline
            If $sTimeline <> "" Then
                _WV2Anim_TimelineReverse($sTimeline)
                UpdateInfo("Timeline: Reverse")
            EndIf

        Case $btnStopAll
            _WV2Anim_StopAll()
            UpdateInfo("Alle Animationen gestoppt")

        Case $btnReset
            _WV2Anim_SetHTML(__GenerateDemoHTML())
            Sleep(100)
            UpdateInfo("View zurueckgesetzt")
    EndSwitch
WEnd

GUIDelete($hGUI)
Exit

; ===============================================================================================================================
; Demo-Funktionen
; ===============================================================================================================================

Func Demo_BasicAnimations()
    ; Reset
    _WV2Anim_SetHTML(__GenerateDemoHTML())
    Sleep(100)

    ; Translate (Box 1)
    Local $aProps1[2] = ["translateX", "400px"]
    _WV2Anim_Animate(".box1", $aProps1, 1500, $WV2ANIM_EASE_OUTQUAD)

    ; Rotate (Box 2)
    Local $aProps2[2] = ["rotate", "360deg"]
    _WV2Anim_Animate(".box2", $aProps2, 1500, $WV2ANIM_EASE_INOUTQUAD)

    ; Scale (Box 3)
    Local $aProps3[2] = ["scale", "1.5"]
    _WV2Anim_Animate(".box3", $aProps3, 1500, $WV2ANIM_EASE_OUTELASTIC)

    ; Opacity (Box 4)
    Local $aProps4[2] = ["opacity", "0.2"]
    _WV2Anim_Animate(".box4", $aProps4, 1500, $WV2ANIM_EASE_LINEAR)
EndFunc

Func Demo_Timeline()
    ; Reset
    _WV2Anim_SetHTML(__GenerateDemoHTML())
    Sleep(100)

    ; Timeline erstellen
    $sTimeline = _WV2Anim_Timeline(True)

    ; Schritt 1: Alle Boxen fade in
    Local $aProps1[2] = ["opacity", "1"]
    _WV2Anim_TimelineAdd($sTimeline, ".box", $aProps1, 500, "easeInQuad", 0)

    ; Schritt 2: Box 1 bewegen
    Local $aProps2[2] = ["translateX", "200px"]
    _WV2Anim_TimelineAdd($sTimeline, ".box1", $aProps2, 800, "easeOutQuad", "+=200")

    ; Schritt 3: Box 2 drehen (gleichzeitig mit Box 1)
    Local $aProps3[2] = ["rotate", "180deg"]
    _WV2Anim_TimelineAdd($sTimeline, ".box2", $aProps3, 800, "easeOutQuad", "-=800")

    ; Schritt 4: Box 3 skalieren
    Local $aProps4[2] = ["scale", "2"]
    _WV2Anim_TimelineAdd($sTimeline, ".box3", $aProps4, 600, "easeOutBack", "+=100")

    ; Schritt 5: Box 4 nach oben bewegen
    Local $aProps5[2] = ["translateY", "-100px"]
    _WV2Anim_TimelineAdd($sTimeline, ".box4", $aProps5, 700, "easeOutBounce", "+=50")
EndFunc

Func Demo_Stagger()
    ; Reset mit mehreren Boxen
    Local $sHTML = '<div style="display:flex;flex-wrap:wrap;padding:50px;gap:20px;">'
    For $i = 1 To 12
        $sHTML &= '<div class="stagger-box" style="width:80px;height:80px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:12px;opacity:0;"></div>'
    Next
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Stagger Animation
    Local $aProps[6] = ["translateY", "0", "opacity", "1", "scale", "1"]
    _WV2Anim_Stagger(".stagger-box", $aProps, 80, 800, "easeOutExpo")
EndFunc

Func Demo_Easing()
    ; Reset mit 4 Labels
    Local $sHTML = '<div style="padding:50px;">'
    $sHTML &= '<div style="margin-bottom:30px;"><span style="color:#888;margin-right:20px;">Linear:</span><div class="ease1" style="display:inline-block;width:50px;height:50px;background:#f093fb;border-radius:8px;"></div></div>'
    $sHTML &= '<div style="margin-bottom:30px;"><span style="color:#888;margin-right:20px;">EaseInOutQuad:</span><div class="ease2" style="display:inline-block;width:50px;height:50px;background:#4facfe;border-radius:8px;"></div></div>'
    $sHTML &= '<div style="margin-bottom:30px;"><span style="color:#888;margin-right:20px;">EaseOutElastic:</span><div class="ease3" style="display:inline-block;width:50px;height:50px;background:#43e97b;border-radius:8px;"></div></div>'
    $sHTML &= '<div style="margin-bottom:30px;"><span style="color:#888;margin-right:20px;">Spring:</span><div class="ease4" style="display:inline-block;width:50px;height:50px;background:#fa709a;border-radius:8px;"></div></div>'
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Verschiedene Easing Functions
    Local $aProps[2] = ["translateX", "700px"]
    _WV2Anim_Animate(".ease1", $aProps, 2000, $WV2ANIM_EASE_LINEAR)
    _WV2Anim_Animate(".ease2", $aProps, 2000, $WV2ANIM_EASE_INOUTQUAD)
    _WV2Anim_Animate(".ease3", $aProps, 2000, $WV2ANIM_EASE_OUTELASTIC)
    _WV2Anim_Animate(".ease4", $aProps, 2000, $WV2ANIM_EASE_SPRING)
EndFunc

Func Demo_SVGPath()
    ; SVG mit Pfad erstellen
    Local $sHTML = '<div style="padding:50px;text-align:center;">'
    $sHTML &= '<svg width="400" height="400" viewBox="0 0 400 400">'
    $sHTML &= '<path id="myPath" d="M 50 200 Q 100 50 200 100 T 350 200 Q 300 350 200 300 T 50 200 Z" '
    $sHTML &= 'fill="none" stroke="#667eea" stroke-width="4" stroke-linecap="round" />'
    $sHTML &= '</svg>'
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Path drawing starten
    _WV2Anim_ExecuteJS("WV2Anim.drawPath('#myPath', 3000, 'easeInOutSine');")
EndFunc

Func Demo_Helpers()
    ; Reset
    _WV2Anim_SetHTML(__GenerateDemoHTML())
    Sleep(100)

    ; Helper Animationen nacheinander
    _WV2Anim_ExecuteJS("WV2Anim.shake('.box1', 15, 500);")
    Sleep(600)
    _WV2Anim_ExecuteJS("WV2Anim.pulse('.box2', 1.3, 600);")
    Sleep(700)
    _WV2Anim_ExecuteJS("WV2Anim.bounce('.box3', 80, 1000);")
    Sleep(1100)
    _WV2Anim_ExecuteJS("WV2Anim.fadeOut('.box4', 800);")
EndFunc

Func Demo_Counter()
    ; Counter HTML
    Local $sHTML = '<div style="padding:100px;text-align:center;">'
    $sHTML &= '<div id="counter" style="font-size:120px;font-weight:bold;color:#667eea;">0</div>'
    $sHTML &= '<div style="margin-top:20px;font-size:24px;color:#888;">Animated Counter</div>'
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Number Animation
    _WV2Anim_ExecuteJS("WV2Anim.animateNumber('#counter', 0, 100, 3000, 0);")
EndFunc

Func Demo_SVGMorph()
    ; SVG mit zwei Pfaden (Kreis und Quadrat)
    Local $sHTML = '<div style="padding:50px;text-align:center;">'
    $sHTML &= '<svg width="400" height="400" viewBox="0 0 200 200">'
    $sHTML &= '<path id="morphPath" d="M 100 20 A 80 80 0 1 1 99.9 20 Z" '
    $sHTML &= 'fill="#667eea" stroke="none" />'
    $sHTML &= '</svg>'
    $sHTML &= '<div style="margin-top:20px;color:#888;">Kreis morpht zu Quadrat</div>'
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Morph zu Quadrat
    Local $sSquarePath = "M 40 40 L 160 40 L 160 160 L 40 160 Z"
    _WV2Anim_ExecuteJS("WV2Anim.morphPath('#morphPath', '" & $sSquarePath & "', 2000, 'easeInOutQuad');")
EndFunc

; ===============================================================================================================================
; Helper-Funktionen
; ===============================================================================================================================

Func __GenerateDemoHTML()
    Local $sHTML = '<div style="padding:50px;">'
    $sHTML &= '<h1 style="color:#667eea;margin-bottom:30px;">WV2 Animation Framework - Anime.js Integration</h1>'
    $sHTML &= '<div style="display:flex;gap:30px;flex-wrap:wrap;">'

    ; Box 1
    $sHTML &= '<div class="box box1" style="width:120px;height:120px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:16px;display:flex;align-items:center;justify-content:center;color:white;font-weight:bold;box-shadow:0 10px 30px rgba(102,126,234,0.3);">Box 1</div>'

    ; Box 2
    $sHTML &= '<div class="box box2" style="width:120px;height:120px;background:linear-gradient(135deg,#f093fb,#f5576c);border-radius:16px;display:flex;align-items:center;justify-content:center;color:white;font-weight:bold;box-shadow:0 10px 30px rgba(240,147,251,0.3);">Box 2</div>'

    ; Box 3
    $sHTML &= '<div class="box box3" style="width:120px;height:120px;background:linear-gradient(135deg,#4facfe,#00f2fe);border-radius:16px;display:flex;align-items:center;justify-content:center;color:white;font-weight:bold;box-shadow:0 10px 30px rgba(79,172,254,0.3);">Box 3</div>'

    ; Box 4
    $sHTML &= '<div class="box box4" style="width:120px;height:120px;background:linear-gradient(135deg,#43e97b,#38f9d7);border-radius:16px;display:flex;align-items:center;justify-content:center;color:white;font-weight:bold;box-shadow:0 10px 30px rgba(67,233,123,0.3);">Box 4</div>'

    $sHTML &= '</div>'
    $sHTML &= '</div>'

    Return $sHTML
EndFunc

Func UpdateInfo($sText)
    GUICtrlSetData($lblInfo, $sText)
EndFunc

; ===============================================================================================================================
; End of WV2_Animation_Demo.au3
; ===============================================================================================================================
