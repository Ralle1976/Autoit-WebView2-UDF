#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\Include\WV2_Animation.au3"

; ===============================================================================================================================
; WV2_Animation Advanced Demo - Komplexe Animations-Szenarien
; ===============================================================================================================================
;
; Dieses Beispiel zeigt fortgeschrittene Techniken:
; - Interaktive Dashboards mit animierten Daten-Visualisierungen
; - Komplexe Timeline-Choreographien
; - SVG-basierte Logo-Animationen
; - Partikel-System mit Stagger
; - Loading-Animationen
; - Morphing-Transitions
;
; ===============================================================================================================================

; GUI erstellen
Global $hGUI = GUICreate("WV2 Animation - Advanced Showcase", 1400, 900, -1, -1, $WS_OVERLAPPEDWINDOW)

; Sidebar
GUISetBkColor(0x2C3E50)
Global $btnDashboard = GUICtrlCreateButton("Dashboard Animation", 20, 20, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnLogo = GUICtrlCreateButton("Logo Reveal", 20, 70, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnParticles = GUICtrlCreateButton("Particle System", 20, 120, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnLoader = GUICtrlCreateButton("Loading Animations", 20, 170, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnCards = GUICtrlCreateButton("Card Flip Gallery", 20, 220, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnWave = GUICtrlCreateButton("Wave Effect", 20, 270, 180, 40)
GUICtrlSetFont(-1, 10, 600)
Global $btnMorph = GUICtrlCreateButton("Icon Morphing", 20, 320, 180, 40)
GUICtrlSetFont(-1, 10, 600)

GUICtrlCreateLabel("___________________", 20, 380, 180, 20)
GUICtrlSetColor(-1, 0xFFFFFF)

Global $btnReset = GUICtrlCreateButton("Reset", 20, 410, 180, 35)
Global $btnStop = GUICtrlCreateButton("Stop All", 20, 455, 180, 35)

; Info Box
GUICtrlCreateLabel("Info:", 20, 520, 180, 20)
GUICtrlSetFont(-1, 9, 600)
GUICtrlSetColor(-1, 0xFFFFFF)
Global $lblInfo = GUICtrlCreateLabel("Waehlen Sie eine Demo", 20, 545, 180, 300)
GUICtrlSetColor(-1, 0xECF0F1)

GUISetState(@SW_SHOW, $hGUI)

; WebView2 initialisieren
Global $aWebView = _WV2Anim_Init($hGUI, 220, 20, 1160, 860, __GetWelcomeHTML())
If @error Then
    MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!")
    Exit
EndIf

; Hauptschleife
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $btnDashboard
            Demo_AnimatedDashboard()
            SetInfo("Animated Dashboard" & @CRLF & @CRLF & "Zeigt ein interaktives" & @CRLF & "Dashboard mit animierten" & @CRLF & "Statistiken, Balken und" & @CRLF & "Fortschrittsanzeigen.")

        Case $btnLogo
            Demo_LogoReveal()
            SetInfo("Logo Reveal" & @CRLF & @CRLF & "SVG-basierte Logo-" & @CRLF & "Animation mit Path" & @CRLF & "Drawing und Fade-In.")

        Case $btnParticles
            Demo_ParticleSystem()
            SetInfo("Particle System" & @CRLF & @CRLF & "Erstellt 100 Partikel" & @CRLF & "mit gestaffelten" & @CRLF & "Animationen in" & @CRLF & "verschiedene Richtungen.")

        Case $btnLoader
            Demo_LoadingAnimations()
            SetInfo("Loading Animations" & @CRLF & @CRLF & "Verschiedene Loader:" & @CRLF & "- Spinner" & @CRLF & "- Dots" & @CRLF & "- Progress Bar" & @CRLF & "- Skeleton")

        Case $btnCards
            Demo_CardFlipGallery()
            SetInfo("Card Flip Gallery" & @CRLF & @CRLF & "Karten-Galerie mit" & @CRLF & "3D-Flip-Animation" & @CRLF & "und Stagger-Effect.")

        Case $btnWave
            Demo_WaveEffect()
            SetInfo("Wave Effect" & @CRLF & @CRLF & "Wellen-Animation mit" & @CRLF & "gestaffelten Balken" & @CRLF & "in Loop.")

        Case $btnMorph
            Demo_IconMorphing()
            SetInfo("Icon Morphing" & @CRLF & @CRLF & "SVG-Icons morphen" & @CRLF & "zwischen verschiedenen" & @CRLF & "Formen (Play/Pause," & @CRLF & "Menu/Close).")

        Case $btnReset
            _WV2Anim_SetHTML(__GetWelcomeHTML())
            SetInfo("View zurueckgesetzt")

        Case $btnStop
            _WV2Anim_StopAll()
            SetInfo("Alle Animationen" & @CRLF & "gestoppt")
    EndSwitch
WEnd

GUIDelete($hGUI)
Exit

; ===============================================================================================================================
; Demo-Funktionen
; ===============================================================================================================================

Func Demo_AnimatedDashboard()
    Local $sHTML = '<div style="padding:40px;background:#1a1a2e;min-height:100%;">'
    $sHTML &= '<h1 style="color:#fff;margin-bottom:40px;font-size:36px;opacity:0;" class="title">Analytics Dashboard</h1>'

    ; Stat Cards
    $sHTML &= '<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:20px;margin-bottom:40px;">'
    For $i = 1 To 4
        $sHTML &= '<div class="stat-card card' & $i & '" style="background:linear-gradient(135deg,#667eea,#764ba2);padding:30px;border-radius:16px;color:#fff;opacity:0;transform:translateY(50px);">'
        $sHTML &= '<div style="font-size:14px;opacity:0.8;">Metric ' & $i & '</div>'
        $sHTML &= '<div class="counter' & $i & '" style="font-size:42px;font-weight:bold;margin:10px 0;">0</div>'
        $sHTML &= '<div style="font-size:12px;color:#b4f8c8;">+12.5% vs last month</div>'
        $sHTML &= '</div>'
    Next
    $sHTML &= '</div>'

    ; Progress Bars
    $sHTML &= '<div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">'
    For $i = 1 To 4
        $sHTML &= '<div class="progress-container bar' & $i & '" style="opacity:0;transform:translateX(-50px);">'
        $sHTML &= '<div style="color:#fff;margin-bottom:10px;font-size:14px;">Progress ' & $i & '</div>'
        $sHTML &= '<div style="background:rgba(255,255,255,0.1);height:8px;border-radius:4px;overflow:hidden;">'
        $sHTML &= '<div class="progress-bar' & $i & '" style="background:linear-gradient(90deg,#f093fb,#f5576c);height:100%;width:0;"></div>'
        $sHTML &= '</div>'
        $sHTML &= '</div>'
    Next
    $sHTML &= '</div>'

    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Animation Timeline
    Local $tl = _WV2Anim_Timeline(True)

    ; Title fade in
    Local $aProps1[2] = ["opacity", "1"]
    _WV2Anim_TimelineAdd($tl, ".title", $aProps1, 800, "easeOutQuad", 0)

    ; Cards stagger in
    Local $aProps2[4] = ["opacity", "1", "translateY", "0"]
    _WV2Anim_TimelineAdd($tl, ".stat-card", $aProps2, 800, "easeOutExpo", "+=200")
    _WV2Anim_ExecuteJS("anime({targets:'.stat-card',opacity:[0,1],translateY:[50,0],duration:800,delay:anime.stagger(100,{start:200}),easing:'easeOutExpo'});")

    ; Counter animations
    Sleep(1200)
    _WV2Anim_ExecuteJS("WV2Anim.animateNumber('.counter1', 0, 1247, 2000, 0);")
    _WV2Anim_ExecuteJS("WV2Anim.animateNumber('.counter2', 0, 856, 2000, 0);")
    _WV2Anim_ExecuteJS("WV2Anim.animateNumber('.counter3', 0, 2134, 2000, 0);")
    _WV2Anim_ExecuteJS("WV2Anim.animateNumber('.counter4', 0, 492, 2000, 0);")

    ; Progress bars
    Sleep(500)
    For $i = 1 To 4
        Local $iWidth = Random(60, 95, 1)
        _WV2Anim_ExecuteJS("anime({targets:'.progress-container.bar" & $i & "',opacity:[0,1],translateX:[-50,0],duration:600,delay:" & ($i * 100) & ",easing:'easeOutQuad'});")
        _WV2Anim_ExecuteJS("anime({targets:'.progress-bar" & $i & "',width:['0%','" & $iWidth & "%'],duration:1500,delay:" & (400 + $i * 100) & ",easing:'easeOutExpo'});")
    Next
EndFunc

Func Demo_LogoReveal()
    ; SVG Logo (abstraktes Hexagon-Logo)
    Local $sHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;background:#0f0f23;">'
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<svg width="300" height="300" viewBox="0 0 200 200">'

    ; Hexagon path
    $sHTML &= '<path id="hex" d="M 100 20 L 170 60 L 170 140 L 100 180 L 30 140 L 30 60 Z" '
    $sHTML &= 'fill="none" stroke="#667eea" stroke-width="4" stroke-linecap="round" />'

    ; Inner paths
    $sHTML &= '<path id="inner1" d="M 70 80 L 100 60 L 130 80 L 130 120 L 100 140 L 70 120 Z" '
    $sHTML &= 'fill="none" stroke="#f093fb" stroke-width="3" stroke-linecap="round" />'

    $sHTML &= '<circle id="dot" cx="100" cy="100" r="8" fill="#43e97b" opacity="0" />'

    $sHTML &= '</svg>'
    $sHTML &= '<div id="logoText" style="color:#fff;font-size:32px;font-weight:bold;margin-top:20px;opacity:0;">WEBAPP</div>'
    $sHTML &= '</div>'
    $sHTML &= '</div>'

    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Path drawing
    _WV2Anim_ExecuteJS("WV2Anim.drawPath('#hex', 2000, 'easeInOutQuad');")
    Sleep(2100)
    _WV2Anim_ExecuteJS("WV2Anim.drawPath('#inner1', 1500, 'easeInOutQuad');")

    ; Dot fade in + scale
    Sleep(1600)
    Local $aProps1[2] = ["opacity", "1"]
    _WV2Anim_Animate("#dot", $aProps1, 400, "easeOutQuad")
    _WV2Anim_ExecuteJS("WV2Anim.pulse('#dot', 1.5, 800);")

    ; Text slide in
    Sleep(500)
    _WV2Anim_ExecuteJS("WV2Anim.slideInLeft('#logoText', 100, 1000);")
EndFunc

Func Demo_ParticleSystem()
    ; Container
    Local $sHTML = '<div id="particles" style="position:relative;width:100%;height:100%;background:#0a0a1f;overflow:hidden;">'
    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; 100 Partikel erstellen und animieren
    Local $sScript = ""
    $sScript &= "const container = document.getElementById('particles');" & @CRLF
    $sScript &= "for(let i = 0; i < 100; i++) {" & @CRLF
    $sScript &= "  const particle = document.createElement('div');" & @CRLF
    $sScript &= "  particle.className = 'particle';" & @CRLF
    $sScript &= "  const size = Math.random() * 8 + 4;" & @CRLF
    $sScript &= "  const x = Math.random() * window.innerWidth;" & @CRLF
    $sScript &= "  const y = Math.random() * window.innerHeight;" & @CRLF
    $sScript &= "  particle.style.cssText = `" & @CRLF
    $sScript &= "    position:absolute;" & @CRLF
    $sScript &= "    left:${x}px;" & @CRLF
    $sScript &= "    top:${y}px;" & @CRLF
    $sScript &= "    width:${size}px;" & @CRLF
    $sScript &= "    height:${size}px;" & @CRLF
    $sScript &= "    background:hsl(${Math.random()*360}, 70%, 60%);" & @CRLF
    $sScript &= "    border-radius:50%;" & @CRLF
    $sScript &= "    opacity:0;" & @CRLF
    $sScript &= "  `;" & @CRLF
    $sScript &= "  container.appendChild(particle);" & @CRLF
    $sScript &= "}" & @CRLF

    ; Stagger Animation
    $sScript &= "anime({" & @CRLF
    $sScript &= "  targets: '.particle'," & @CRLF
    $sScript &= "  translateX: function() { return anime.random(-400, 400); }," & @CRLF
    $sScript &= "  translateY: function() { return anime.random(-400, 400); }," & @CRLF
    $sScript &= "  opacity: [0, 1, 0]," & @CRLF
    $sScript &= "  scale: [0, 1, 0.5]," & @CRLF
    $sScript &= "  duration: 3000," & @CRLF
    $sScript &= "  delay: anime.stagger(20)," & @CRLF
    $sScript &= "  easing: 'easeInOutQuad'," & @CRLF
    $sScript &= "  loop: true" & @CRLF
    $sScript &= "});" & @CRLF

    _WV2Anim_ExecuteJS($sScript)
EndFunc

Func Demo_LoadingAnimations()
    Local $sHTML = '<div style="padding:60px;background:#1a1a2e;display:grid;grid-template-columns:1fr 1fr;gap:60px;">'

    ; Spinner
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<div style="color:#fff;margin-bottom:20px;font-size:18px;">Spinner</div>'
    $sHTML &= '<div class="spinner" style="width:60px;height:60px;border:6px solid rgba(102,126,234,0.2);border-top-color:#667eea;border-radius:50%;margin:0 auto;"></div>'
    $sHTML &= '</div>'

    ; Dots
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<div style="color:#fff;margin-bottom:20px;font-size:18px;">Dots</div>'
    $sHTML &= '<div style="display:flex;gap:10px;justify-content:center;">'
    For $i = 1 To 5
        $sHTML &= '<div class="dot dot' & $i & '" style="width:16px;height:16px;background:#667eea;border-radius:50%;"></div>'
    Next
    $sHTML &= '</div>'
    $sHTML &= '</div>'

    ; Progress bar
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<div style="color:#fff;margin-bottom:20px;font-size:18px;">Progress Bar</div>'
    $sHTML &= '<div style="width:300px;height:8px;background:rgba(255,255,255,0.1);border-radius:4px;margin:0 auto;overflow:hidden;">'
    $sHTML &= '<div class="loader-bar" style="height:100%;width:0;background:linear-gradient(90deg,#667eea,#764ba2);"></div>'
    $sHTML &= '</div>'
    $sHTML &= '</div>'

    ; Skeleton
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<div style="color:#fff;margin-bottom:20px;font-size:18px;">Skeleton</div>'
    For $i = 1 To 3
        $sHTML &= '<div class="skeleton skeleton' & $i & '" style="height:20px;background:rgba(255,255,255,0.1);margin:10px auto;border-radius:4px;width:' & (300 - $i * 30) & 'px;"></div>'
    Next
    $sHTML &= '</div>'

    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Spinner rotation
    _WV2Anim_ExecuteJS("WV2Anim.rotateContinuous('.spinner', 1000, 1);")

    ; Dots bounce
    For $i = 1 To 5
        _WV2Anim_ExecuteJS("anime({targets:'.dot" & $i & "',translateY:[-20,0],duration:600,delay:" & ($i * 100) & ",loop:true,direction:'alternate',easing:'easeInOutQuad'});")
    Next

    ; Progress bar loop
    _WV2Anim_ExecuteJS("anime({targets:'.loader-bar',width:['0%','100%'],duration:2000,loop:true,easing:'easeInOutQuad'});")

    ; Skeleton pulse
    For $i = 1 To 3
        _WV2Anim_ExecuteJS("anime({targets:'.skeleton" & $i & "',opacity:[0.1,0.3,0.1],duration:1500,delay:" & ($i * 200) & ",loop:true,easing:'easeInOutQuad'});")
    Next
EndFunc

Func Demo_CardFlipGallery()
    Local $sHTML = '<div style="padding:40px;background:#1a1a2e;display:grid;grid-template-columns:repeat(4,1fr);gap:20px;">'

    For $i = 1 To 12
        $sHTML &= '<div class="card card' & $i & '" style="width:100%;height:200px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:16px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:24px;font-weight:bold;opacity:0;transform:rotateY(180deg);">'
        $sHTML &= 'Card ' & $i
        $sHTML &= '</div>'
    Next

    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Stagger flip animation
    _WV2Anim_ExecuteJS("anime({targets:'.card',rotateY:[180,0],opacity:[0,1],duration:800,delay:anime.stagger(80),easing:'easeOutExpo'});")
EndFunc

Func Demo_WaveEffect()
    Local $sHTML = '<div style="display:flex;align-items:flex-end;justify-content:center;height:100%;background:#0a0a1f;gap:4px;padding-bottom:100px;">'

    For $i = 1 To 40
        $sHTML &= '<div class="bar bar' & $i & '" style="width:20px;height:30px;background:linear-gradient(180deg,#667eea,#764ba2);border-radius:4px 4px 0 0;"></div>'
    Next

    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Wave loop
    _WV2Anim_ExecuteJS("anime({targets:'.bar',height:function(el,i){return anime.random(30,200);},duration:800,delay:anime.stagger(30),loop:true,direction:'alternate',easing:'easeInOutQuad'});")
EndFunc

Func Demo_IconMorphing()
    Local $sHTML = '<div style="display:flex;align-items:center;justify-content:center;gap:100px;height:100%;background:#1a1a2e;">'

    ; Play/Pause Icon
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<svg width="100" height="100" viewBox="0 0 100 100">'
    $sHTML &= '<path id="play" d="M 30 20 L 30 80 L 70 50 Z" fill="#667eea"/>'
    $sHTML &= '</svg>'
    $sHTML &= '<div style="color:#fff;margin-top:10px;">Click to toggle</div>'
    $sHTML &= '</div>'

    ; Menu/Close Icon
    $sHTML &= '<div style="text-align:center;">'
    $sHTML &= '<svg width="100" height="100" viewBox="0 0 100 100">'
    $sHTML &= '<path id="menu1" d="M 20 30 L 80 30" stroke="#f093fb" stroke-width="6" stroke-linecap="round"/>'
    $sHTML &= '<path id="menu2" d="M 20 50 L 80 50" stroke="#f093fb" stroke-width="6" stroke-linecap="round"/>'
    $sHTML &= '<path id="menu3" d="M 20 70 L 80 70" stroke="#f093fb" stroke-width="6" stroke-linecap="round"/>'
    $sHTML &= '</svg>'
    $sHTML &= '<div style="color:#fff;margin-top:10px;">Click to toggle</div>'
    $sHTML &= '</div>'

    $sHTML &= '</div>'
    _WV2Anim_SetHTML($sHTML)
    Sleep(100)

    ; Play <-> Pause morph
    Sleep(1000)
    _WV2Anim_ExecuteJS("WV2Anim.morphPath('#play', 'M 30 20 L 30 80 L 45 80 L 45 20 Z M 55 20 L 55 80 L 70 80 L 70 20 Z', 600, 'easeInOutQuad');")

    ; Menu <-> Close morph
    Sleep(2000)
    _WV2Anim_ExecuteJS("anime({targets:'#menu1',d:'M 25 25 L 75 75',duration:400,easing:'easeInOutQuad'});")
    _WV2Anim_ExecuteJS("anime({targets:'#menu2',opacity:0,duration:200,easing:'easeOutQuad'});")
    _WV2Anim_ExecuteJS("anime({targets:'#menu3',d:'M 25 75 L 75 25',duration:400,easing:'easeInOutQuad'});")
EndFunc

; ===============================================================================================================================
; Helper-Funktionen
; ===============================================================================================================================

Func __GetWelcomeHTML()
    Local $sHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);">'
    $sHTML &= '<div style="text-align:center;color:#fff;">'
    $sHTML &= '<h1 style="font-size:72px;margin-bottom:20px;font-weight:bold;">WV2 Animation</h1>'
    $sHTML &= '<p style="font-size:24px;opacity:0.9;">Advanced Anime.js Showcase</p>'
    $sHTML &= '<p style="font-size:16px;opacity:0.7;margin-top:40px;">Waehlen Sie eine Demo aus der Sidebar</p>'
    $sHTML &= '</div>'
    $sHTML &= '</div>'
    Return $sHTML
EndFunc

Func SetInfo($sText)
    GUICtrlSetData($lblInfo, $sText)
EndFunc

; ===============================================================================================================================
; End of WV2_Animation_Advanced.au3
; ===============================================================================================================================
