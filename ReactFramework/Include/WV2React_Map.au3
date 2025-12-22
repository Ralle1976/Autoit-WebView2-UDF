#include-once
#include "WV2React_Core.au3"

; #INDEX# =======================================================================================================================
; Title .........: WV2React_Map
; AutoIt Version : 3.3.16.1+
; Language ......: English/German
; Description ...: High-Level Map Functions for WebView2 React Framework
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Stellt einfache Funktionen fuer Kartenoperationen bereit.
; Basiert auf Leaflet.js mit OpenStreetMap-Tiles.
;
; FEATURES:
; - Marker hinzufuegen, entfernen, verschieben
; - Drag-and-Drop Unterstuetzung
; - Custom Marker-Farben
; - Popup-Informationen
; - Event-Callbacks fuer Benutzerinteraktionen
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WV2React_CreateMap
; _WV2React_AddMapMarker
; _WV2React_RemoveMapMarker
; _WV2React_UpdateMapMarker
; _WV2React_SetMapCenter
; _WV2React_GetMapMarkers
; _WV2React_ClearMapMarkers
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_CreateMap
; Description ...: Erstellt eine interaktive Karte
; Syntax ........: _WV2React_CreateMap($sId, [$nLat = 52.520], [$nLng = 13.405], [$iZoom = 13], [$bDraggable = True])
; Parameters ....: $sId        - Eindeutige ID fuer die Karte
;                  $nLat       - [optional] Latitude des Zentrums (Standard: Berlin)
;                  $nLng       - [optional] Longitude des Zentrums
;                  $iZoom      - [optional] Zoom-Stufe (1-18)
;                  $bDraggable - [optional] Marker per Drag verschiebbar
; Return values .: Success - Map ID
;                  Failure - "" und setzt @error
; Example .......: $sMapId = _WV2React_CreateMap("myMap", 52.520, 13.405, 13)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_CreateMap($sId, $nLat = 52.520, $nLng = 13.405, $iZoom = 13, $bDraggable = True)
    Local $sOptions = '{"center":[' & $nLat & ',' & $nLng & '],"zoom":' & $iZoom & ',"draggable":' & ($bDraggable ? "true" : "false") & ',"markers":[]}'

    ; Command direkt senden statt ueber CreateComponent (fuer JSON-Parsing)
    Local $sCmd = '{"action":"createComponent","componentId":"' & $sId & '","componentType":"map","payload":' & $sOptions & '}'
    _WV2React_SendCommand($sCmd)

    ; Komponente lokal registrieren
    Local $iIndex = $__g_aWV2React_Components[0][0] + 1
    ReDim $__g_aWV2React_Components[$iIndex + 1][4]
    $__g_aWV2React_Components[0][0] = $iIndex
    $__g_aWV2React_Components[$iIndex][0] = $sId
    $__g_aWV2React_Components[$iIndex][1] = "map"
    $__g_aWV2React_Components[$iIndex][2] = "created"
    $__g_aWV2React_Components[$iIndex][3] = 0

    Return $sId
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_AddMapMarker
; Description ...: Fuegt einen Marker zur Karte hinzu
; Syntax ........: _WV2React_AddMapMarker($sMapId, $nLat, $nLng, [$sPopup = ""], [$sColor = "#3B82F6"], [$sMarkerId = ""])
; Parameters ....: $sMapId    - ID der Karte
;                  $nLat      - Latitude
;                  $nLng      - Longitude
;                  $sPopup    - [optional] Popup-Text
;                  $sColor    - [optional] Marker-Farbe (Hex)
;                  $sMarkerId - [optional] Eigene Marker-ID
; Return values .: Success - Marker-Index
;                  Failure - -1 und setzt @error
; Example .......: _WV2React_AddMapMarker("myMap", 52.520, 13.405, "Berlin Zentrum", "#FF0000")
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_AddMapMarker($sMapId, $nLat, $nLng, $sPopup = "", $sColor = "#3B82F6", $sMarkerId = "")
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, -1)

    If $sMarkerId = "" Then $sMarkerId = "marker_" & Random(1000, 9999, 1)

    ; Escape Popup-Text
    $sPopup = StringReplace($sPopup, '"', '\"')
    $sPopup = StringReplace($sPopup, @CRLF, "<br>")
    $sPopup = StringReplace($sPopup, @CR, "<br>")
    $sPopup = StringReplace($sPopup, @LF, "<br>")

    Local $sMarker = '{"id":"' & $sMarkerId & '","lat":' & $nLat & ',"lng":' & $nLng & ',"popup":"' & $sPopup & '","color":"' & $sColor & '"}'

    ; JavaScript ausfuehren um Marker hinzuzufuegen
    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "if(comp) { comp.markers.push(" & $sMarker & "); comp.updateMarkers(); }"
    $sScript &= "comp ? comp.markers.length - 1 : -1;"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    If @error Then Return SetError(2, @error, -1)

    Return Number(StringReplace($sResult, '"', ''))
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_RemoveMapMarker
; Description ...: Entfernt einen Marker von der Karte
; Syntax ........: _WV2React_RemoveMapMarker($sMapId, $iMarkerIndex)
; Parameters ....: $sMapId       - ID der Karte
;                  $iMarkerIndex - Index des Markers (von AddMapMarker)
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_RemoveMapMarker($sMapId, $iMarkerIndex)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "if(comp && comp.markers[" & $iMarkerIndex & "]) {"
    $sScript &= "  comp.markers.splice(" & $iMarkerIndex & ", 1);"
    $sScript &= "  comp.updateMarkers();"
    $sScript &= "  true;"
    $sScript &= "} else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_UpdateMapMarker
; Description ...: Aktualisiert einen bestehenden Marker
; Syntax ........: _WV2React_UpdateMapMarker($sMapId, $iMarkerIndex, [$nLat = Default], [$nLng = Default], [$sPopup = Default], [$sColor = Default])
; Parameters ....: $sMapId       - ID der Karte
;                  $iMarkerIndex - Index des Markers
;                  $nLat         - [optional] Neue Latitude
;                  $nLng         - [optional] Neue Longitude
;                  $sPopup       - [optional] Neuer Popup-Text
;                  $sColor       - [optional] Neue Farbe
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_UpdateMapMarker($sMapId, $iMarkerIndex, $nLat = Default, $nLng = Default, $sPopup = Default, $sColor = Default)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "if(comp && comp.markers[" & $iMarkerIndex & "]) {"
    $sScript &= "  var m = comp.markers[" & $iMarkerIndex & "];"

    If $nLat <> Default Then $sScript &= "  m.lat = " & $nLat & ";"
    If $nLng <> Default Then $sScript &= "  m.lng = " & $nLng & ";"
    If $sPopup <> Default Then
        $sPopup = StringReplace($sPopup, '"', '\"')
        $sScript &= '  m.popup = "' & $sPopup & '";'
    EndIf
    If $sColor <> Default Then $sScript &= '  m.color = "' & $sColor & '";'

    $sScript &= "  comp.updateMarkers();"
    $sScript &= "  true;"
    $sScript &= "} else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SetMapCenter
; Description ...: Setzt das Kartenzentrum
; Syntax ........: _WV2React_SetMapCenter($sMapId, $nLat, $nLng, [$iZoom = Default])
; Parameters ....: $sMapId - ID der Karte
;                  $nLat   - Latitude
;                  $nLng   - Longitude
;                  $iZoom  - [optional] Neue Zoom-Stufe
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SetMapCenter($sMapId, $nLat, $nLng, $iZoom = Default)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sZoomParam = ($iZoom <> Default) ? $iZoom : "comp.map.getZoom()"

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "if(comp && comp.map) {"
    $sScript &= "  comp.map.setView([" & $nLat & ", " & $nLng & "], " & $sZoomParam & ");"
    $sScript &= "  comp.center = [" & $nLat & ", " & $nLng & "];"
    $sScript &= "  true;"
    $sScript &= "} else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_GetMapMarkers
; Description ...: Gibt alle Marker einer Karte zurueck
; Syntax ........: _WV2React_GetMapMarkers($sMapId)
; Parameters ....: $sMapId - ID der Karte
; Return values .: Success - JSON-String mit Marker-Array
;                  Failure - "" und setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_GetMapMarkers($sMapId)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, "")

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "comp ? JSON.stringify(comp.markers) : '[]';"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    If @error Then Return SetError(2, @error, "")

    Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_ClearMapMarkers
; Description ...: Entfernt alle Marker von der Karte
; Syntax ........: _WV2React_ClearMapMarkers($sMapId)
; Parameters ....: $sMapId - ID der Karte
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_ClearMapMarkers($sMapId)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sMapId & "');"
    $sScript &= "if(comp) { comp.markers = []; comp.updateMarkers(); true; } else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; ===============================================================================================================================
; End of WV2React_Map.au3
; ===============================================================================================================================
