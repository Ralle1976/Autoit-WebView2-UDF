# WV2_Animation Extension

Animation extension for WebView2 UDF using Anime.js.

## Overview

WV2_Animation provides powerful animation capabilities for AutoIt applications via WebView2. Create smooth, professional animations with minimal code.

## Features

- **Property Animations**: translate, rotate, scale, opacity, colors
- **Timeline System**: Sequence multiple animations
- **Stagger Effects**: Animate multiple elements with delays
- **SVG Support**: Path drawing and morphing
- **30+ Easing Functions**: From linear to elastic
- **CDN-based**: No local files required (Anime.js 3.2.1)

## Installation

1. Copy `Extensions/WV2_Animation/` to your project
2. Ensure `bin/` folder contains WebView2 DLLs
3. Include the main file:

```autoit
#include "Extensions\WV2_Animation\Include\WV2_Animation.au3"
```

## Quick Start

```autoit
#include <GUIConstantsEx.au3>
#include "Extensions\WV2_Animation\Include\WV2_Animation.au3"

; Create GUI
Local $hGUI = GUICreate("Animation Demo", 800, 600)
GUISetState(@SW_SHOW)

; Initialize WV2_Animation
Local $aWebView = _WV2Anim_Init($hGUI, 10, 10, 780, 580)
If @error Then Exit MsgBox(16, "Error", "Init failed")

; Add HTML element
_WV2Anim_SetHTML('<div class="box" style="width:100px;height:100px;background:#3B82F6;"></div>')

; Animate it
_WV2Anim_Animate(".box", "translateX", 300, 1000, $WV2ANIM_EASE_OUT_ELASTIC)

; Main loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

## API Reference

### Initialization

#### _WV2Anim_Init
Initializes WebView2 with Anime.js.

```autoit
$aWebView = _WV2Anim_Init($hGUI, $iX, $iY, $iWidth, $iHeight)
```

### Basic Animation

#### _WV2Anim_Animate
Animate a single property.

```autoit
_WV2Anim_Animate($sSelector, $sProperty, $vValue, $iDuration, $sEasing = "easeOutQuad")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| $sSelector | String | CSS selector (e.g., ".box", "#myId") |
| $sProperty | String | Property to animate |
| $vValue | Mixed | Target value |
| $iDuration | Integer | Duration in milliseconds |
| $sEasing | String | Easing function |

#### _WV2Anim_AnimateEx
Extended animation with JSON options.

```autoit
_WV2Anim_AnimateEx($sSelector, $sOptionsJSON)
```

### Animatable Properties

| Category | Properties |
|----------|------------|
| **Transform** | translateX, translateY, rotate, scale, skewX, skewY |
| **CSS** | opacity, backgroundColor, color, width, height, borderRadius |
| **SVG** | strokeDashoffset, d (path morphing) |

### Easing Functions

| Constant | Effect |
|----------|--------|
| $WV2ANIM_EASE_LINEAR | Linear |
| $WV2ANIM_EASE_IN_QUAD | Accelerate (quadratic) |
| $WV2ANIM_EASE_OUT_QUAD | Decelerate (quadratic) |
| $WV2ANIM_EASE_IN_OUT_QUAD | Accelerate then decelerate |
| $WV2ANIM_EASE_OUT_ELASTIC | Elastic overshoot |
| $WV2ANIM_EASE_OUT_BOUNCE | Bouncing effect |
| $WV2ANIM_EASE_SPRING | Spring physics |

### Timeline

#### _WV2Anim_Timeline
Create a new timeline.

```autoit
$sTimelineId = _WV2Anim_Timeline($bAutoplay = True)
```

#### _WV2Anim_TimelineAdd
Add animation to timeline.

```autoit
_WV2Anim_TimelineAdd($sTimelineId, $sSelector, $sOptionsJSON, $sOffset = "")
```

| Offset | Meaning |
|--------|---------|
| `""` | After previous |
| `"+=500"` | 500ms after previous ends |
| `"-=200"` | 200ms before previous ends |
| `0` | At timeline start |

### Timeline Controls

```autoit
_WV2Anim_TimelinePlay($sTimelineId)
_WV2Anim_TimelinePause($sTimelineId)
_WV2Anim_TimelineRestart($sTimelineId)
_WV2Anim_TimelineReverse($sTimelineId)
```

### Stagger Effects

#### _WV2Anim_Stagger
Animate multiple elements with staggered timing.

```autoit
_WV2Anim_Stagger($sSelector, $sProperty, $vValue, $iDuration, $iStaggerDelay, $sEasing)
```

### Helper Animations

Pre-built animation effects:

```autoit
_WV2Anim_Shake($sSelector, $iIntensity = 10)
_WV2Anim_Pulse($sSelector)
_WV2Anim_Bounce($sSelector)
_WV2Anim_FadeIn($sSelector, $iDuration = 500)
_WV2Anim_FadeOut($sSelector, $iDuration = 500)
_WV2Anim_SlideInLeft($sSelector)
_WV2Anim_SlideInRight($sSelector)
```

### SVG Animations

#### _WV2Anim_DrawPath
Animate SVG path drawing.

```autoit
_WV2Anim_DrawPath($sSelector, $iDuration, $sEasing)
```

#### _WV2Anim_MorphPath
Morph between two SVG paths.

```autoit
_WV2Anim_MorphPath($sSelector, $sTargetPath, $iDuration)
```

### Control

#### _WV2Anim_Stop
Stop animation on element.

```autoit
_WV2Anim_Stop($sSelector)
```

#### _WV2Anim_StopAll
Stop all animations.

```autoit
_WV2Anim_StopAll()
```

## Examples

### Chained Animation (Timeline)

```autoit
Local $sTimeline = _WV2Anim_Timeline(False)
_WV2Anim_TimelineAdd($sTimeline, ".box", '{"translateX":250,"duration":500}')
_WV2Anim_TimelineAdd($sTimeline, ".box", '{"rotate":"1turn","duration":500}')
_WV2Anim_TimelineAdd($sTimeline, ".box", '{"scale":1.5,"duration":300}')
_WV2Anim_TimelinePlay($sTimeline)
```

### Stagger Grid

```autoit
; Animate 12 boxes with 50ms delay between each
_WV2Anim_Stagger(".grid-item", "opacity", 1, 500, 50, "easeOutQuad")
```

### SVG Logo Draw

```autoit
; Draw SVG path over 2 seconds
_WV2Anim_DrawPath("#logo-path", 2000, "easeInOutQuad")
```

### Number Counter

```autoit
; Animate number from 0 to 100
_WV2Anim_ExecuteJS("WV2Animation.animateNumber('#counter', 0, 100, 2000)")
```

## Performance Tips

1. **Use transforms** over position properties (faster GPU rendering)
2. **Add `will-change`** CSS for frequently animated elements
3. **Avoid animating** layout properties (width, height, margin)
4. **Use `requestAnimationFrame`** for custom animations

## See Also

- [[Home]] - Main documentation
- [[WV2React Framework]] - UI components
- [[WV2_Chart]] - Chart extension
