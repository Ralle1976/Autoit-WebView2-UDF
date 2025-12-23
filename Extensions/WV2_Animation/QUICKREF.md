# WV2_Animation - Quick Reference Card

## Initialisierung

```autoit
#include "Extensions\WV2_Animation\Include\WV2_Animation.au3"

$hGUI = GUICreate("Animation", 800, 600)
$aWebView = _WV2Anim_Init($hGUI, 0, 0, 800, 600)
```

## Basic Animations

### Property Animation
```autoit
; Array-basiert
Local $aProps[4] = ["translateX", "250px", "rotate", "360deg"]
_WV2Anim_Animate(".box", $aProps, 1500, "easeOutQuad")

; JSON-basiert (erweitert)
_WV2Anim_AnimateEx(".box", '{"translateX": 250, "duration": 1500}')
```

### Häufige Properties
```autoit
; Transform
"translateX", "translateY", "translateZ"
"rotate", "rotateX", "rotateY", "rotateZ"
"scale", "scaleX", "scaleY"
"skewX", "skewY"

; CSS
"opacity"
"backgroundColor", "color"
"width", "height"
"borderRadius"
```

## Timeline

```autoit
; Timeline erstellen
$tl = _WV2Anim_Timeline(True)

; Animationen hinzufügen
Local $aProps1[2] = ["opacity", "1"]
_WV2Anim_TimelineAdd($tl, ".box1", $aProps1, 500, "easeOut", 0)

Local $aProps2[2] = ["translateX", "200px"]
_WV2Anim_TimelineAdd($tl, ".box2", $aProps2, 800, "easeOut", "+=100")

; Kontrolle
_WV2Anim_TimelinePlay($tl)
_WV2Anim_TimelinePause($tl)
_WV2Anim_TimelineRestart($tl)
_WV2Anim_TimelineReverse($tl)
```

### Timeline Offset
```autoit
0          ; Sofort nach vorheriger
"+=500"    ; 500ms nach vorheriger
"-=200"    ; 200ms Overlap
"1000"     ; Bei absoluter Position 1000ms
```

## Stagger

```autoit
; Gestaffelte Animation für mehrere Elemente
Local $aProps[4] = ["opacity", "1", "translateY", "0"]
_WV2Anim_Stagger(".item", $aProps, 80, 800, "easeOutExpo")
;                                    ^^
;                                    Delay zwischen Elementen (ms)
```

## Easing Functions

### Konstanten
```autoit
$WV2ANIM_EASE_LINEAR
$WV2ANIM_EASE_INQUAD / OUTQUAD / INOUTQUAD
$WV2ANIM_EASE_INCUBIC / OUTCUBIC / INOUTCUBIC
$WV2ANIM_EASE_INEXPO / OUTEXPO / INOUTEXPO
$WV2ANIM_EASE_INELASTIC / OUTELASTIC / INOUTELASTIC
$WV2ANIM_EASE_SPRING
```

### Custom Easing
```autoit
"cubicBezier(.5, .05, .1, .3)"
"spring(1, 80, 10, 0)"
"easeOutElastic(1, .6)"
```

## Helper Animationen (JavaScript)

```autoit
; Shake
_WV2Anim_ExecuteJS("WV2Anim.shake('.box', 15, 500);")

; Pulse
_WV2Anim_ExecuteJS("WV2Anim.pulse('.box', 1.2, 600);")

; Bounce
_WV2Anim_ExecuteJS("WV2Anim.bounce('.box', 60, 1000);")

; Fade In/Out
_WV2Anim_ExecuteJS("WV2Anim.fadeIn('.box', 800);")
_WV2Anim_ExecuteJS("WV2Anim.fadeOut('.box', 800);")

; Slide In
_WV2Anim_ExecuteJS("WV2Anim.slideInLeft('.box', 100, 800);")
_WV2Anim_ExecuteJS("WV2Anim.slideInRight('.box', 100, 800);")

; Continuous Rotation
_WV2Anim_ExecuteJS("WV2Anim.rotateContinuous('.box', 2000, 1);")
```

## SVG Animations

### Path Drawing
```autoit
; HTML
$sHTML = '<svg><path id="line" d="M 10 10 L 100 100" stroke="#667eea" fill="none"/></svg>'
_WV2Anim_SetHTML($sHTML)

; Animation
_WV2Anim_ExecuteJS("WV2Anim.drawPath('#line', 2000, 'easeInOutSine');")
```

### Path Morphing
```autoit
_WV2Anim_ExecuteJS("WV2Anim.morphPath('#path', 'M 10 10 L 90 90', 1500, 'easeInOutQuad');")
```

## Number Counter

```autoit
; HTML
_WV2Anim_SetHTML('<div id="counter">0</div>')

; Animation
_WV2Anim_ExecuteJS("WV2Anim.animateNumber('#counter', 0, 100, 2000, 0);")
;                                                                     ^
;                                                                     Dezimalstellen
```

## Animation Control

```autoit
; Stoppen
_WV2Anim_Stop(".box")      ; Bestimmtes Element
_WV2Anim_StopAll()         ; Alle Animationen

; HTML setzen
_WV2Anim_SetHTML($sHTML)

; JavaScript ausführen
_WV2Anim_ExecuteJS($sScript)
```

## Komplexes Beispiel

```autoit
; Dashboard mit animierten Stats
_WV2Anim_SetHTML('<div class="stat">0</div>')

; Timeline erstellen
$tl = _WV2Anim_Timeline()

; Fade in
Local $aFade[2] = ["opacity", "1"]
_WV2Anim_TimelineAdd($tl, ".stat", $aFade, 500, "easeOut", 0)

; Counter
Sleep(600)
_WV2Anim_ExecuteJS("WV2Anim.animateNumber('.stat', 0, 1247, 2000, 0);")
```

## Performance-Tipps

1. **Transform statt Position**: Nutzen Sie `translateX` statt `left`
2. **will-change**: Für bessere GPU-Acceleration
   ```autoit
   _WV2Anim_ExecuteJS("document.querySelector('.box').style.willChange = 'transform';")
   ```
3. **Stagger delay**: Nicht < 30ms für bessere Performance
4. **Timeline**: Bei vielen Animationen effizienter als einzelne

## Debug

```autoit
; Console-Output prüfen
_WV2Anim_ExecuteJS("console.log(WV2Anim);")

; Elemente prüfen
_WV2Anim_ExecuteJS("console.log(document.querySelectorAll('.box'));")

; DevTools öffnen (WebView2_Native.au3)
_WebView2_OpenDevTools($aWebView)
```

## Häufige Patterns

### Loading Spinner
```autoit
$sHTML = '<div class="spinner" style="width:60px;height:60px;border:6px solid rgba(102,126,234,0.2);border-top-color:#667eea;border-radius:50%;"></div>'
_WV2Anim_SetHTML($sHTML)
_WV2Anim_ExecuteJS("WV2Anim.rotateContinuous('.spinner', 1000, 1);")
```

### Card Flip
```autoit
Local $aProps[2] = ["rotateY", "180deg"]
_WV2Anim_Animate(".card", $aProps, 600, "easeInOutQuad")
```

### Slide & Fade
```autoit
Local $aProps[4] = ["translateX", "200px", "opacity", "1"]
_WV2Anim_Animate(".box", $aProps, 800, "easeOutExpo")
```

### Stagger Grid
```autoit
Local $aProps[4] = ["opacity", "1", "scale", "1"]
_WV2Anim_Stagger(".grid-item", $aProps, 60, 600, "easeOutExpo")
```

---

## Weitere Ressourcen

- **Vollständige Doku**: `README.md`
- **Beispiele**: `Examples/WV2_Animation_Demo.au3`
- **Advanced**: `Examples/WV2_Animation_Advanced.au3`
- **Anime.js Doku**: https://animejs.com/documentation/
