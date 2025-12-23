# WV2_Chart Extension

Data visualization extension for WebView2 UDF using Chart.js.

## Overview

WV2_Chart provides easy integration of Chart.js into AutoIt applications via WebView2. Create interactive charts with minimal code.

## Features

- **6 Chart Types**: Line, Bar, Pie, Doughnut, Radar, Polar Area
- **Real-time Updates**: Update chart data dynamically
- **Theming**: Light/Dark mode support
- **Events**: Click callbacks for interactivity
- **CDN-based**: No local files required (Chart.js 4.4.1)

## Installation

1. Copy `Extensions/WV2_Chart/` to your project
2. Ensure `bin/` folder contains WebView2 DLLs
3. Include the main file:

```autoit
#include "Extensions\WV2_Chart\Include\WV2_Chart.au3"
```

## Quick Start

```autoit
#include <GUIConstantsEx.au3>
#include "Extensions\WV2_Chart\Include\WV2_Chart.au3"

; Create GUI
Local $hGUI = GUICreate("Chart Demo", 800, 600)
GUISetState(@SW_SHOW)

; Initialize WV2_Chart
Local $aWebView = _WV2Chart_Init($hGUI, 10, 10, 780, 580)
If @error Then Exit MsgBox(16, "Error", "Init failed")

; Create Line Chart
Local $aLabels[5] = ["Jan", "Feb", "Mar", "Apr", "May"]
Local $aDatasets[1][2]
$aDatasets[0][0] = "Sales"
$aDatasets[0][1] = "65,59,80,81,56"

_WV2Chart_Create("chart1", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets)

; Main loop
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

_WebView2_Close($aWebView)
```

## API Reference

### Initialization

#### _WV2Chart_Init
Initializes WebView2 with Chart.js.

```autoit
$aWebView = _WV2Chart_Init($hGUI, $iX, $iY, $iWidth, $iHeight, $sTheme = "light")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| $hGUI | Handle | Parent GUI handle |
| $iX, $iY | Integer | Position |
| $iWidth, $iHeight | Integer | Size |
| $sTheme | String | "light" or "dark" |

### Chart Creation

#### _WV2Chart_Create
Creates a new chart.

```autoit
_WV2Chart_Create($sId, $iType, $aLabels, $aDatasets, $aOptions = "")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| $sId | String | Unique chart ID |
| $iType | Integer | Chart type constant |
| $aLabels | Array | X-axis labels |
| $aDatasets | Array[n][2] | [Name, "comma,separated,values"] |
| $aOptions | String | JSON options (optional) |

### Chart Types

| Constant | Value | Description |
|----------|-------|-------------|
| $WV2CHART_TYPE_LINE | 0 | Line chart |
| $WV2CHART_TYPE_BAR | 1 | Bar chart |
| $WV2CHART_TYPE_PIE | 2 | Pie chart |
| $WV2CHART_TYPE_DOUGHNUT | 3 | Doughnut chart |
| $WV2CHART_TYPE_RADAR | 4 | Radar chart |
| $WV2CHART_TYPE_POLARAREA | 5 | Polar area chart |

### Data Updates

#### _WV2Chart_Update
Updates chart with new data.

```autoit
_WV2Chart_Update($sId, $aLabels, $aDatasets)
```

#### _WV2Chart_UpdateDataset
Fast update for single dataset (ideal for real-time).

```autoit
_WV2Chart_UpdateDataset($sId, $iDatasetIndex, $aNewData)
```

### Theming

#### _WV2Chart_SetTheme
Switch between light and dark mode.

```autoit
_WV2Chart_SetTheme("dark")  ; or "light"
```

### Events

#### _WV2Chart_OnClick
Register click callback.

```autoit
_WV2Chart_OnClick($sId, "_MyClickHandler")

Func _MyClickHandler($sChartId, $iDatasetIndex, $iDataIndex, $sLabel, $nValue)
    ConsoleWrite("Clicked: " & $sLabel & " = " & $nValue & @CRLF)
EndFunc
```

### Cleanup

#### _WV2Chart_Destroy
Remove a single chart.

```autoit
_WV2Chart_Destroy($sId)
```

#### _WV2Chart_Clear
Remove all charts.

```autoit
_WV2Chart_Clear()
```

## Examples

### Multi-Dataset Chart

```autoit
Local $aLabels[4] = ["Q1", "Q2", "Q3", "Q4"]
Local $aDatasets[2][2]
$aDatasets[0][0] = "2023"
$aDatasets[0][1] = "100,120,115,130"
$aDatasets[1][0] = "2024"
$aDatasets[1][1] = "110,125,140,155"

_WV2Chart_Create("comparison", $WV2CHART_TYPE_BAR, $aLabels, $aDatasets)
```

### Real-time Update

```autoit
; In timer or loop
Local $aNewData[5] = [Random(50,100), Random(50,100), Random(50,100), Random(50,100), Random(50,100)]
_WV2Chart_UpdateDataset("realtime", 0, $aNewData)
```

### Custom Colors

```autoit
Local $sOptions = '{"datasets":[{"backgroundColor":"rgba(255,99,132,0.5)","borderColor":"rgb(255,99,132)"}]}'
_WV2Chart_Create("custom", $WV2CHART_TYPE_LINE, $aLabels, $aDatasets, $sOptions)
```

## See Also

- [[Home]] - Main documentation
- [[WV2React Framework]] - UI components
- [[WV2_Animation]] - Animation extension
