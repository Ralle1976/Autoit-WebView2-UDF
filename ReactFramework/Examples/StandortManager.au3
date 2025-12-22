; ===============================================================================================================================
; StandortManager.au3 - Adress-Suche mit OpenStreetMap
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Praktisches Tool zur Adresssuche:
; - Freie Adresseingabe (Stadt, Strasse, Hausnummer)
; - Geocoding via Nominatim (OpenStreetMap) - kostenlos, kein API-Key
; - Suchergebnisse in interaktivem Grid
; - Klick auf Ergebnis -> Marker auf Karte + Zoom
;
; AUTOR: Ralle1976
; VERSION: 2.0.0
;
; ===============================================================================================================================

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "..\Include\WV2React_Core.au3"
#include "..\Include\WV2React_Map.au3"
#include "..\Include\WV2React_Grid.au3"

; ===============================================================================================================================
; Konfiguration
; ===============================================================================================================================
Global Const $APP_TITLE = "Adress-Suche (OpenStreetMap)"
Global Const $APP_WIDTH = 1200
Global Const $APP_HEIGHT = 700

; Globale Variablen
Global $g_hMainGUI = 0
Global $g_oWebView = 0
Global $g_sMapId = "searchMap"
Global $g_sGridId = "resultGrid"

; ===============================================================================================================================
; Hauptprogramm
; ===============================================================================================================================
Main()

Func Main()
    ; GUI erstellen
    $g_hMainGUI = GUICreate($APP_TITLE, $APP_WIDTH, $APP_HEIGHT, -1, -1, _
        BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))

    ; Menue erstellen
    Local $hFileMenu = GUICtrlCreateMenu("&Datei")
    Local $hExitItem = GUICtrlCreateMenuItem("&Beenden", $hFileMenu)

    Local $hViewMenu = GUICtrlCreateMenu("&Ansicht")
    Local $hDarkItem = GUICtrlCreateMenuItem("Dark Mode", $hViewMenu)
    Local $hLightItem = GUICtrlCreateMenuItem("Light Mode", $hViewMenu)

    Local $hHelpMenu = GUICtrlCreateMenu("&Hilfe")
    Local $hAboutItem = GUICtrlCreateMenuItem("&Ueber...", $hHelpMenu)

    ; Status-Label
    Local $hStatusLabel = GUICtrlCreateLabel("Initialisiere...", 10, $APP_HEIGHT - 30, 600, 20)

    GUISetState(@SW_SHOW, $g_hMainGUI)

    ; WebView2 React Framework initialisieren
    ConsoleWrite("[AdressSuche] Initialisiere WV2React Framework..." & @CRLF)

    $g_oWebView = _WV2React_Init($g_hMainGUI, 0, 0, $APP_WIDTH, $APP_HEIGHT - 50, "light", "#2563EB")
    If @error Then
        MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!" & @CRLF & "@error = " & @error)
        Exit 1
    EndIf

    ; Event-Callback registrieren
    _WV2React_OnEvent(_OnSearchEvent)

    ; Status aktualisieren
    GUICtrlSetData($hStatusLabel, "Bereit - Gib eine Adresse ein und druecke Enter oder klicke Suchen")

    ; Kurz warten fuer Framework-Initialisierung
    Sleep(1000)

    ; UI aufbauen
    _CreateSearchUI()

    ; Hauptschleife (mit korrektem Message-Pump fuer WebView2)
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")
    While True
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE, $hExitItem
                ExitLoop

            Case $hDarkItem
                _WV2React_SetTheme("dark")
                GUICtrlSetData($hStatusLabel, "Theme: Dark Mode")

            Case $hLightItem
                _WV2React_SetTheme("light")
                GUICtrlSetData($hStatusLabel, "Theme: Light Mode")

            Case $hAboutItem
                MsgBox(64, "Ueber " & $APP_TITLE, _
                    "Adress-Suche v2.0" & @CRLF & @CRLF & _
                    "Funktionen:" & @CRLF & _
                    "- Freie Adresseingabe" & @CRLF & _
                    "- Geocoding via Nominatim (OpenStreetMap)" & @CRLF & _
                    "- Interaktive Karte (Leaflet.js)" & @CRLF & _
                    "- Ergebnisliste mit Klick-Zoom" & @CRLF & @CRLF & _
                    "Autor: Ralle1976")
        EndSwitch

        ; Windows Messages verarbeiten - KRITISCH fuer WebView2!
        While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
            DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
            DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
        WEnd

        ; Events verarbeiten
        _WV2React_ProcessEvents()
        Sleep(10)
    WEnd

    ; Cleanup
    _WebView2_Close($g_oWebView)
    GUIDelete($g_hMainGUI)
EndFunc

; ===============================================================================================================================
; UI Aufbau mit Suchfeld
; ===============================================================================================================================
Func _CreateSearchUI()
    ConsoleWrite("[AdressSuche] Erstelle UI..." & @CRLF)

    ; Layout per JavaScript erstellen - mit separaten Eingabefeldern
    Local $sLayoutScript = "" & _
        "document.getElementById('root').innerHTML = `" & _
        "<div class='flex flex-col h-full'>" & _
        "  <div class='bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 p-4'>" & _
        "    <div class='grid grid-cols-12 gap-3'>" & _
        "      <div class='col-span-4'>" & _
        "        <label class='block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1'>Strasse + Hausnummer *</label>" & _
        "        <input type='text' id='inputStreet' " & _
        "          class='w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg " & _
        "          bg-white dark:bg-gray-700 text-gray-800 dark:text-white " & _
        "          focus:ring-2 focus:ring-blue-500 focus:border-transparent' " & _
        "          placeholder='z.B. Schieferweg 19' />" & _
        "      </div>" & _
        "      <div class='col-span-2'>" & _
        "        <label class='block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1'>PLZ</label>" & _
        "        <input type='text' id='inputPLZ' maxlength='5' " & _
        "          class='w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg " & _
        "          bg-white dark:bg-gray-700 text-gray-800 dark:text-white " & _
        "          focus:ring-2 focus:ring-blue-500 focus:border-transparent' " & _
        "          placeholder='73275' />" & _
        "      </div>" & _
        "      <div class='col-span-3'>" & _
        "        <label class='block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1'>Ort *</label>" & _
        "        <input type='text' id='inputCity' " & _
        "          class='w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg " & _
        "          bg-white dark:bg-gray-700 text-gray-800 dark:text-white " & _
        "          focus:ring-2 focus:ring-blue-500 focus:border-transparent' " & _
        "          placeholder='Ohmden' " & _
        "          onkeypress='if(event.key===" & Chr(34) & "Enter" & Chr(34) & ") window.searchAddress()' />" & _
        "      </div>" & _
        "      <div class='col-span-3 flex items-end'>" & _
        "        <button onclick='window.searchAddress()' " & _
        "          class='w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg " & _
        "          transition-colors shadow-md'>" & _
        "          Suchen" & _
        "        </button>" & _
        "      </div>" & _
        "    </div>" & _
        "    <div id='searchStatus' class='mt-2 text-sm text-gray-500 dark:text-gray-400'>" & _
        "      Strasse und Ort sind Pflichtfelder" & _
        "    </div>" & _
        "    <div class='mt-2 p-2 bg-blue-50 dark:bg-blue-900/30 rounded-lg text-xs text-blue-700 dark:text-blue-300'>" & _
        "      <span class='font-semibold'>Hinweis:</span> Die Suche nutzt OpenStreetMap (Nominatim) und Photon. " & _
        "      Nicht alle Adressen (bes. Hausnummern in kleinen Orten) sind erfasst. " & _
        "      Falls nichts gefunden wird, versuche nur den Strassennamen ohne Hausnummer." & _
        "    </div>" & _
        "  </div>" & _
        "  <div class='flex flex-1 overflow-hidden'>" & _
        "    <div id='grid-container' class='w-2/5 h-full border-r border-gray-200 dark:border-gray-700 overflow-auto'></div>" & _
        "    <div id='map-container' class='w-3/5 h-full'></div>" & _
        "  </div>" & _
        "</div>`;"

    _WebView2_ExecuteScript($g_oWebView, $sLayoutScript, 2000)
    Sleep(200)

    ; Geocoding mit Nominatim + Photon (beide kostenlos, kein API-Key)
    Local $sGeocodingScript = "" & _
        "window.searchResults = [];" & _
        "window.searchPhoton = async function(query) {" & _
        "  const url = 'https://photon.komoot.io/api/?q=' + encodeURIComponent(query) + '&limit=10&lang=de';" & _
        "  console.log('Photon Suche:', url);" & _
        "  const resp = await fetch(url);" & _
        "  const data = await resp.json();" & _
        "  return (data.features || []).map(f => ({" & _
        "    lat: f.geometry.coordinates[1], lon: f.geometry.coordinates[0]," & _
        "    display_name: [f.properties.name, f.properties.street, f.properties.housenumber, f.properties.postcode, f.properties.city, f.properties.country].filter(Boolean).join(', ')," & _
        "    type: f.properties.osm_value || f.properties.type || 'place', source: 'Photon'" & _
        "  }));" & _
        "};" & _
        "window.searchAddress = async function() {" & _
        "  const streetFull = document.getElementById('inputStreet').value.trim();" & _
        "  const plz = document.getElementById('inputPLZ').value.trim();" & _
        "  const city = document.getElementById('inputCity').value.trim();" & _
        "  const status = document.getElementById('searchStatus');" & _
        "  if(!streetFull || !city) {" & _
        "    status.style.color = '#EF4444'; status.textContent = 'Bitte Strasse und Ort ausfuellen!';" & _
        "    return;" & _
        "  }" & _
        "  status.style.color = '#6B7280'; status.textContent = 'Suche in Nominatim + Photon...';" & _
        "  const streetOnly = streetFull.replace(/\\s*\\d+.*$/, '');" & _
        "  const headers = { 'User-Agent': 'WV2React-AdressSuche/2.0' };" & _
        "  let results = []; let source = '';" & _
        "  try {" & _
        "    let url1 = 'https://nominatim.openstreetmap.org/search?format=json&limit=10&addressdetails=1&countrycodes=de';" & _
        "    url1 += '&street=' + encodeURIComponent(streetFull) + '&city=' + encodeURIComponent(city);" & _
        "    if(plz) url1 += '&postalcode=' + encodeURIComponent(plz);" & _
        "    console.log('Nominatim 1:', url1);" & _
        "    let resp = await fetch(url1, { headers }); results = await resp.json(); source = 'Nominatim';" & _
        "    if(results.length === 0 && streetOnly !== streetFull) {" & _
        "      let url2 = 'https://nominatim.openstreetmap.org/search?format=json&limit=10&addressdetails=1&countrycodes=de';" & _
        "      url2 += '&street=' + encodeURIComponent(streetOnly) + '&city=' + encodeURIComponent(city);" & _
        "      if(plz) url2 += '&postalcode=' + encodeURIComponent(plz);" & _
        "      console.log('Nominatim 2:', url2);" & _
        "      resp = await fetch(url2, { headers }); results = await resp.json();" & _
        "    }" & _
        "    if(results.length === 0) {" & _
        "      const q = streetFull + ', ' + (plz ? plz + ' ' : '') + city + ', Deutschland';" & _
        "      results = await window.searchPhoton(q); source = 'Photon';" & _
        "    }" & _
        "    if(results.length === 0) {" & _
        "      const q2 = streetOnly + ', ' + city + ', Deutschland';" & _
        "      results = await window.searchPhoton(q2); source = 'Photon';" & _
        "    }" & _
        "    if(results.length === 0) {" & _
        "      const q3 = (plz ? plz + ' ' : '') + city + ', Deutschland';" & _
        "      results = await window.searchPhoton(q3); source = 'Photon (nur Ort)';" & _
        "      if(results.length > 0) { status.style.color = '#F59E0B'; status.textContent = 'Strasse nicht gefunden - zeige ' + city; }" & _
        "    }" & _
        "    window.searchResults = results;" & _
        "    if(results.length === 0) {" & _
        "      status.style.color = '#EF4444'; status.textContent = 'Nichts gefunden - Adresse nicht in OpenStreetMap';" & _
        "      return;" & _
        "    }" & _
        "    if(!status.textContent.includes('nicht gefunden')) { status.style.color = '#10B981'; status.textContent = results.length + ' Treffer (' + source + ')'; }" & _
        "    window.updateResultGrid(results);" & _
        "    window.updateResultMarkers(results);" & _
        "  } catch(err) {" & _
        "    status.style.color = '#EF4444'; status.textContent = 'Fehler: ' + err.message;" & _
        "  }" & _
        "};" & _
        "window.updateResultGrid = function(results) {" & _
        "  const grid = WV2Bridge.components.get('" & $g_sGridId & "');" & _
        "  if(!grid) return;" & _
        "  grid.data = results.map((r, i) => ({" & _
        "    nr: i + 1," & _
        "    name: r.display_name.split(',')[0]," & _
        "    address: r.display_name," & _
        "    type: r.type || 'unbekannt'" & _
        "  }));" & _
        "  grid.updateTableBody();" & _
        "};" & _
        "window.updateResultMarkers = function(results) {" & _
        "  const map = WV2Bridge.components.get('" & $g_sMapId & "');" & _
        "  if(!map || !map.map) return;" & _
        "  map.clearMarkers();" & _
        "  const bounds = [];" & _
        "  const colors = ['#EF4444', '#F59E0B', '#10B981', '#3B82F6', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316', '#6366F1', '#84CC16'];" & _
        "  results.forEach((r, i) => {" & _
        "    const lat = parseFloat(r.lat);" & _
        "    const lng = parseFloat(r.lon);" & _
        "    bounds.push([lat, lng]);" & _
        "    map.addMarker(lat, lng, '<b>' + (i+1) + '. ' + r.display_name.split(',')[0] + '</b><br>' + r.display_name, colors[i % 10], false);" & _
        "  });" & _
        "  if(bounds.length > 0) {" & _
        "    if(bounds.length === 1) {" & _
        "      map.map.setView(bounds[0], 16);" & _
        "    } else {" & _
        "      map.map.fitBounds(bounds, { padding: [30, 30] });" & _
        "    }" & _
        "  }" & _
        "};" & _
        "window.zoomToResult = function(index) {" & _
        "  const result = window.searchResults[index];" & _
        "  if(!result) return;" & _
        "  const map = WV2Bridge.components.get('" & $g_sMapId & "');" & _
        "  if(!map || !map.map) return;" & _
        "  const lat = parseFloat(result.lat);" & _
        "  const lng = parseFloat(result.lon);" & _
        "  map.map.setView([lat, lng], 17);" & _
        "  if(map.markers && map.markers[index]) {" & _
        "    map.markers[index].openPopup();" & _
        "  }" & _
        "};"

    _WebView2_ExecuteScript($g_oWebView, $sGeocodingScript, 2000)
    Sleep(100)

    ; Grid erstellen fuer Suchergebnisse
    Local $aColumns[4][2] = [ _
        ["nr", "#"], _
        ["name", "Name"], _
        ["address", "Adresse"], _
        ["type", "Typ"] _
    ]
    _WV2React_CreateGrid($g_sGridId, $aColumns)

    ; Grid in Container verschieben
    Local $sMoveGrid = "var grid = document.getElementById('grid-" & $g_sGridId & "');" & _
        "if(grid) { document.getElementById('grid-container').appendChild(grid); }"
    _WebView2_ExecuteScript($g_oWebView, $sMoveGrid, 1000)

    ; Karte erstellen (Deutschland als Startpunkt)
    _WV2React_CreateMap($g_sMapId, 51.1657, 10.4515, 6, False)

    Sleep(500)

    ; Karte in Container verschieben
    Local $sMoveMap = "var mapEl = document.getElementById('map-" & $g_sMapId & "');" & _
        "if(mapEl) { " & _
        "  mapEl.style.height = '100%';" & _
        "  var inner = mapEl.querySelector('.map-inner');" & _
        "  if(inner) inner.style.height = '100%';" & _
        "  document.getElementById('map-container').appendChild(mapEl);" & _
        "  var comp = WV2Bridge.components.get('" & $g_sMapId & "');" & _
        "  if(comp && comp.map) { setTimeout(function() { comp.map.invalidateSize(); }, 100); }" & _
        "}"
    _WebView2_ExecuteScript($g_oWebView, $sMoveMap, 1000)

    ; Grid-Klick Handler ueberschreiben fuer Zoom-Funktion
    Local $sGridClickHandler = "" & _
        "var grid = WV2Bridge.components.get('" & $g_sGridId & "');" & _
        "if(grid) {" & _
        "  grid.selectRow = function(idx) {" & _
        "    this.selectedRow = idx;" & _
        "    this.updateTableBody();" & _
        "    window.zoomToResult(idx);" & _
        "    WV2Bridge.sendEvent('onRowSelect', this.id, { index: idx, row: this.data[idx] });" & _
        "  };" & _
        "}"
    _WebView2_ExecuteScript($g_oWebView, $sGridClickHandler, 1000)

    ConsoleWrite("[AdressSuche] UI erstellt!" & @CRLF)
EndFunc

; ===============================================================================================================================
; Event-Handler
; ===============================================================================================================================
Func _OnSearchEvent($sEventType, $sComponentId, $sData)
    ConsoleWrite("[Event] " & $sEventType & " von " & $sComponentId & ": " & $sData & @CRLF)

    Switch $sEventType
        Case "onSearchComplete"
            ; Suche abgeschlossen
            Local $sCount = __ExtractJsonValue($sData, "count")
            Local $sQuery = __ExtractJsonValue($sData, "query")
            ConsoleWrite("[AdressSuche] Suche nach '" & $sQuery & "' ergab " & $sCount & " Treffer" & @CRLF)

        Case "onRowSelect"
            ; Ergebnis wurde ausgewaehlt
            Local $sIndex = __ExtractJsonValue($sData, "index")
            ConsoleWrite("[AdressSuche] Ergebnis #" & (Number($sIndex) + 1) & " ausgewaehlt" & @CRLF)

        Case "onMarkerClick"
            ConsoleWrite("[AdressSuche] Marker geklickt" & @CRLF)

    EndSwitch
EndFunc

; ===============================================================================================================================
; Hilfs-Funktionen
; ===============================================================================================================================
Func __ExtractJsonValue($sJson, $sKey, $sParentKey = "")
    Local $sPattern
    If $sParentKey <> "" Then
        $sPattern = '"' & $sParentKey & '"\s*:\s*\{[^}]*"' & $sKey & '"\s*:\s*([^,}]+)'
    Else
        $sPattern = '"' & $sKey & '"\s*:\s*([^,}\]]+)'
    EndIf

    Local $aMatch = StringRegExp($sJson, $sPattern, 1)
    If @error Then Return ""

    Local $sValue = StringStripWS($aMatch[0], 3)
    If StringLeft($sValue, 1) = '"' Then
        $sValue = StringTrimLeft(StringTrimRight($sValue, 1), 1)
    EndIf

    Return $sValue
EndFunc

; ===============================================================================================================================
; End of StandortManager.au3
; ===============================================================================================================================
