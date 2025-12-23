# WV2_Animation Extension

Anime.js Animation Framework Integration für AutoIt WebView2.

## Features

### Core Animations
- **Property Animations**: translateX/Y, rotate, scale, opacity, color, width, height, etc.
- **Timeline System**: Sequenzielle Animationen mit präzisem Timing
- **Stagger Effects**: Gestaffelte Animationen für mehrere Elemente
- **Easing Functions**: 30+ built-in Easing-Funktionen (easeInOutQuad, spring, elastic, etc.)

### SVG Support
- **Path Drawing**: SVG-Pfade zeichnen mit strokeDashoffset
- **Path Morphing**: Morphing zwischen zwei SVG-Pfaden
- **Transform Animations**: SVG-Transformationen (rotate, scale, translate)

### Helper Animations
- **Shake**: Schüttel-Animation
- **Pulse**: Pulsieren
- **Bounce**: Hüpf-Animation
- **Fade In/Out**: Ein-/Ausblenden
- **Slide In**: Von links/rechts einsliden
- **Number Counter**: Animierte Zahlen

### Playback Controls
- Play, Pause, Restart, Reverse
- Stop einzelne oder alle Animationen
- Timeline-Steuerung

## Installation

1. Kopieren Sie den Ordner `WV2_Animation` nach `Extensions/`
2. WebView2 Runtime muss installiert sein
3. WebView2Loader DLLs müssen im `bin/` Ordner verfügbar sein

## Quick Start

```autoit
#include "Extensions\WV2_Animation\Include\WV2_Animation.au3"

; GUI erstellen
$hGUI = GUICreate("Animation Demo", 800, 600)
GUISetState(@SW_SHOW)

; WebView2 mit Anime.js initialisieren
$aWebView = _WV2Anim_Init($hGUI, 0, 0, 800, 600)

; HTML setzen
_WV2Anim_SetHTML('<div class="box" style="width:100px;height:100px;background:red;"></div>')

; Animation ausführen
Local $aProps[2] = ["translateX", "500px"]
_WV2Anim_Animate(".box", $aProps, 1500, "easeOutQuad")
```

## API-Referenz

### Initialisierung

#### _WV2Anim_Init($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sInitialHTML])
Initialisiert WebView2 mit Anime.js Framework.

**Parameter:**
- `$hWnd` - Parent Window Handle
- `$iLeft, $iTop, $iWidth, $iHeight` - Position und Größe
- `$sInitialHTML` - Optional: Initiales HTML

**Rückgabe:** WebView2 Array oder 0 bei Fehler

---

### Basic Animations

#### _WV2Anim_Animate($sSelector, $aProperties, [$iDuration], [$sEasing])
Einfache Animation mit Property-Array.

**Parameter:**
- `$sSelector` - CSS-Selektor (".box", "#myDiv", etc.)
- `$aProperties` - Array mit Property/Value Paaren:
  ```autoit
  Local $aProps[4] = ["translateX", "250px", "rotate", "360deg"]
  ```
- `$iDuration` - Dauer in ms (Standard: 1000)
- `$sEasing` - Easing-Funktion (Standard: "easeOutQuad")

**Beispiel:**
```autoit
Local $aProps[6] = ["translateX", "200px", "rotate", "45deg", "scale", "1.5"]
_WV2Anim_Animate(".box", $aProps, 1500, "easeOutElastic")
```

---

#### _WV2Anim_AnimateEx($sSelector, $sJsonOptions)
Erweiterte Animation mit allen Anime.js Optionen als JSON.

**Beispiel:**
```autoit
Local $sJson = '{"translateX": 250, "rotate": "2turn", "duration": 2000, "easing": "spring(1, 80, 10, 0)"}'
_WV2Anim_AnimateEx(".box", $sJson)
```

---

### Timeline Animations

#### _WV2Anim_Timeline([$bAutoplay])
Erstellt eine neue Timeline für sequenzielle Animationen.

**Rückgabe:** Timeline ID (String)

**Beispiel:**
```autoit
$sTimeline = _WV2Anim_Timeline(True)
```

---

#### _WV2Anim_TimelineAdd($sTimelineID, $sSelector, $aProperties, [$iDuration], [$sEasing], [$iOffset])
Fügt Animation zur Timeline hinzu.

**Offset-Parameter:**
- `0` - Startet sofort nach vorheriger Animation
- `"+=500"` - 500ms nach vorheriger
- `"-=200"` - 200ms Overlap mit vorheriger
- `"1000"` - Bei absoluter Position 1000ms

**Beispiel:**
```autoit
$tl = _WV2Anim_Timeline()

Local $aProps1[2] = ["opacity", "1"]
_WV2Anim_TimelineAdd($tl, ".box1", $aProps1, 500, "easeIn", 0)

Local $aProps2[2] = ["translateX", "200px"]
_WV2Anim_TimelineAdd($tl, ".box2", $aProps2, 800, "easeOut", "+=100")
```

---

#### Timeline Controls
```autoit
_WV2Anim_TimelinePlay($sTimelineID)      ; Abspielen
_WV2Anim_TimelinePause($sTimelineID)     ; Pausieren
_WV2Anim_TimelineRestart($sTimelineID)   ; Neustarten
_WV2Anim_TimelineReverse($sTimelineID)   ; Rückwärts abspielen
```

---

### Stagger Animations

#### _WV2Anim_Stagger($sSelector, $aProperties, [$iDelay], [$iDuration], [$sEasing])
Gestaffelte Animation für mehrere Elemente.

**Parameter:**
- `$iDelay` - Verzögerung zwischen Elementen in ms (Standard: 100)

**Beispiel:**
```autoit
; HTML mit mehreren .item Elementen
Local $aProps[4] = ["translateY", "0", "opacity", "1"]
_WV2Anim_Stagger(".item", $aProps, 80, 800, "easeOutExpo")
```

---

### Animation Control

#### _WV2Anim_Stop($sSelector)
Stoppt alle Animationen für einen Selektor.

#### _WV2Anim_StopAll()
Stoppt alle laufenden Animationen.

---

### Helper Functions

#### _WV2Anim_SetHTML($sHTML)
Setzt HTML-Inhalt des Body-Elements.

#### _WV2Anim_ExecuteJS($sScript)
Führt beliebigen JavaScript-Code aus.

**Erweiterte Helper (via JavaScript):**
```autoit
_WV2Anim_ExecuteJS("WV2Anim.shake('.box', 15, 500);")
_WV2Anim_ExecuteJS("WV2Anim.pulse('.box', 1.2, 600);")
_WV2Anim_ExecuteJS("WV2Anim.bounce('.box', 60, 1000);")
_WV2Anim_ExecuteJS("WV2Anim.fadeIn('.box', 800);")
_WV2Anim_ExecuteJS("WV2Anim.fadeOut('.box', 800);")
_WV2Anim_ExecuteJS("WV2Anim.slideInLeft('.box', 100, 800);")
_WV2Anim_ExecuteJS("WV2Anim.slideInRight('.box', 100, 800);")
_WV2Anim_ExecuteJS("WV2Anim.rotateContinuous('.box', 2000, 1);")
```

**SVG Helper:**
```autoit
_WV2Anim_ExecuteJS("WV2Anim.drawPath('#myPath', 2000, 'easeInOutSine');")
_WV2Anim_ExecuteJS("WV2Anim.morphPath('#path1', 'M 10 10 L 90 90', 1500);")
```

**Number Counter:**
```autoit
_WV2Anim_ExecuteJS("WV2Anim.animateNumber('#counter', 0, 100, 2000, 0);")
```

---

## Easing Functions

### Verfügbare Konstanten:
```autoit
$WV2ANIM_EASE_LINEAR
$WV2ANIM_EASE_INQUAD
$WV2ANIM_EASE_OUTQUAD
$WV2ANIM_EASE_INOUTQUAD
$WV2ANIM_EASE_INCUBIC
$WV2ANIM_EASE_OUTCUBIC
$WV2ANIM_EASE_INOUTCUBIC
$WV2ANIM_EASE_INEXPO
$WV2ANIM_EASE_OUTEXPO
$WV2ANIM_EASE_INOUTEXPO
$WV2ANIM_EASE_INELASTIC
$WV2ANIM_EASE_OUTELASTIC
$WV2ANIM_EASE_INOUTELASTIC
$WV2ANIM_EASE_SPRING
```

### Custom Easing:
```autoit
; Cubicbezier
_WV2Anim_Animate(".box", $aProps, 1000, "cubicBezier(.5, .05, .1, .3)")

; Spring mit Parametern
_WV2Anim_Animate(".box", $aProps, 1000, "spring(1, 80, 10, 0)")

; Elastic
_WV2Anim_Animate(".box", $aProps, 1000, "easeOutElastic(1, .6)")
```

---

## Animierbare Properties

### CSS Transform
- `translateX`, `translateY`, `translateZ`
- `rotate`, `rotateX`, `rotateY`, `rotateZ`
- `scale`, `scaleX`, `scaleY`, `scaleZ`
- `skewX`, `skewY`

### CSS Properties
- `opacity`
- `backgroundColor`, `color`
- `width`, `height`
- `padding`, `margin`
- `borderRadius`
- `left`, `top`, `right`, `bottom`

### SVG
- `strokeDashoffset` (Path Drawing)
- `d` (Path Morphing)
- SVG Transforms

### DOM Attributes
Beliebige DOM-Attribute können animiert werden.

---

## Beispiele

### 1. Einfache Bewegung
```autoit
Local $aProps[2] = ["translateX", "300px"]
_WV2Anim_Animate(".box", $aProps, 1200, "easeOutQuad")
```

### 2. Rotation mit Scale
```autoit
Local $aProps[4] = ["rotate", "360deg", "scale", "1.5"]
_WV2Anim_Animate(".box", $aProps, 1500, "easeInOutQuad")
```

### 3. Timeline-Sequenz
```autoit
$tl = _WV2Anim_Timeline()

Local $aProps1[2] = ["translateX", "200px"]
_WV2Anim_TimelineAdd($tl, ".box1", $aProps1, 800, "easeOut", 0)

Local $aProps2[2] = ["rotate", "180deg"]
_WV2Anim_TimelineAdd($tl, ".box2", $aProps2, 800, "easeOut", "-=400")

Local $aProps3[2] = ["scale", "2"]
_WV2Anim_TimelineAdd($tl, ".box3", $aProps3, 600, "easeOutBack", "+=100")
```

### 4. Stagger Grid
```autoit
; HTML mit Grid-Elementen
Local $sHTML = '<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;">'
For $i = 1 To 16
    $sHTML &= '<div class="grid-item" style="width:50px;height:50px;background:#667eea;opacity:0;"></div>'
Next
$sHTML &= '</div>'
_WV2Anim_SetHTML($sHTML)

; Stagger Animation
Local $aProps[4] = ["opacity", "1", "scale", "1"]
_WV2Anim_Stagger(".grid-item", $aProps, 60, 600, "easeOutExpo")
```

### 5. SVG Path Drawing
```autoit
Local $sHTML = '<svg width="500" height="300">'
$sHTML &= '<path id="line" d="M 10 150 Q 150 50 250 150 T 490 150" '
$sHTML &= 'stroke="#667eea" stroke-width="3" fill="none"/>'
$sHTML &= '</svg>'
_WV2Anim_SetHTML($sHTML)

_WV2Anim_ExecuteJS("WV2Anim.drawPath('#line', 3000, 'easeInOutQuad');")
```

### 6. Advanced: JSON-basiert
```autoit
Local $sJson = '{'
$sJson &= '"translateX": [0, 300],'
$sJson &= '"rotate": "1turn",'
$sJson &= '"duration": 2000,'
$sJson &= '"easing": "easeInOutQuad",'
$sJson &= '"loop": 3,'
$sJson &= '"direction": "alternate"'
$sJson &= '}'
_WV2Anim_AnimateEx(".box", $sJson)
```

---

## Performance-Tipps

1. **GPU-Acceleration nutzen**: Verwenden Sie `transform` Properties (translateX, rotate, scale) statt `left`, `top`, `width`, `height`
2. **will-change CSS**: Für bessere Performance:
   ```autoit
   _WV2Anim_ExecuteJS("document.querySelector('.box').style.willChange = 'transform';")
   ```
3. **Timeline statt einzelne Animationen**: Bei komplexen Sequenzen ist Timeline effizienter
4. **Stagger delay optimieren**: Zu kleine Delays (< 30ms) können zu Performance-Problemen führen

---

## Troubleshooting

### Animation startet nicht
- Prüfen Sie, ob Elemente mit dem Selektor existieren
- Console-Output in DevTools prüfen: `_WV2Anim_ExecuteJS("console.log(document.querySelectorAll('.box'));")`

### Ruckelige Animationen
- GPU-Acceleration aktivieren (transform statt position)
- Anzahl gleichzeitiger Animationen reduzieren
- Komplexe SVG-Pfade vereinfachen

### Timeline funktioniert nicht
- Timeline-ID korrekt gespeichert?
- Autoplay deaktiviert? Dann manuell starten: `_WV2Anim_TimelinePlay($tl)`

---

## Weiterführende Links

- [Anime.js Dokumentation](https://animejs.com/documentation/)
- [Anime.js CodePen Beispiele](https://codepen.io/collection/XLebem/)
- [WebView2 UDF Dokumentation](../../docs/)

---

## Lizenz

Dieses Modul ist Teil des WebView2 UDF Projekts.
Anime.js ist MIT-lizenziert (https://github.com/juliangarnier/anime)

---

## Changelog

### v1.0.0 (2025-01-23)
- Initial Release
- Basic Animations (translate, rotate, scale, opacity)
- Timeline System
- Stagger Effects
- SVG Path Drawing/Morphing
- Helper Animations
- 30+ Easing Functions
