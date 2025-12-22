#include-once
#include "WV2React_Core.au3"

; #INDEX# =======================================================================================================================
; Title .........: WV2React_Grid
; AutoIt Version : 3.3.16.1+
; Language ......: English/German
; Description ...: High-Level Data Grid Functions for WebView2 React Framework
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Stellt einfache Funktionen fuer Daten-Tabellen bereit.
; Unterstuetzt Sortierung, Filterung und Zeilenauswahl.
;
; FEATURES:
; - Automatische Spalten-Erkennung aus Array
; - Sortierbare Spalten
; - Such-/Filterfunktion
; - Zeilen-Selektion mit Callback
; - Pagination fuer grosse Datensaetze
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WV2React_CreateGrid
; _WV2React_CreateGridFromArray
; _WV2React_UpdateGridData
; _WV2React_GetGridSelection
; _WV2React_SetGridFilter
; _WV2React_SortGrid
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_CreateGrid
; Description ...: Erstellt ein Daten-Grid mit definierten Spalten
; Syntax ........: _WV2React_CreateGrid($sId, $aColumns, [$aData = Default], [$bSortable = True], [$bFilterable = True])
; Parameters ....: $sId         - Eindeutige ID fuer das Grid
;                  $aColumns    - Array mit Spalten-Definitionen: [["key", "label"], ...]
;                  $aData       - [optional] 2D-Array mit Daten (ohne Header-Zeile)
;                  $bSortable   - [optional] Spalten sortierbar
;                  $bFilterable - [optional] Filterfeld anzeigen
; Return values .: Success - Grid ID
;                  Failure - "" und setzt @error
; Example .......: Local $aCols = [["id", "ID"], ["name", "Name"], ["city", "Stadt"]]
;                  _WV2React_CreateGrid("myGrid", $aCols)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_CreateGrid($sId, $aColumns, $aData = Default, $bSortable = True, $bFilterable = True)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, "")
    If Not IsArray($aColumns) Then Return SetError(2, 0, "")

    ; Spalten-JSON erstellen
    Local $sColumns = "["
    Local $iDims = UBound($aColumns, 0)  ; Anzahl Dimensionen

    For $i = 0 To UBound($aColumns) - 1
        If $i > 0 Then $sColumns &= ","

        ; 2D-Array: $aColumns[i][0] = key, $aColumns[i][1] = label
        If $iDims = 2 Then
            If UBound($aColumns, 2) >= 2 Then
                $sColumns &= '{"key":"' & $aColumns[$i][0] & '","label":"' & $aColumns[$i][1] & '"}'
            Else
                $sColumns &= '{"key":"' & $aColumns[$i][0] & '","label":"' & $aColumns[$i][0] & '"}'
            EndIf
        ; 1D-Array: Einfache Strings als Keys
        Else
            $sColumns &= '{"key":"' & $aColumns[$i] & '","label":"' & $aColumns[$i] & '"}'
        EndIf
    Next
    $sColumns &= "]"

    ; Daten-JSON erstellen
    Local $sData = "[]"
    If IsArray($aData) And UBound($aData) > 0 Then
        $sData = __WV2React_Grid_DataToJson($aColumns, $aData)
    EndIf

    ; Optionen
    Local $sSortable = $bSortable ? "true" : "false"
    Local $sFilterable = $bFilterable ? "true" : "false"

    Local $sOptions = '{"columns":' & $sColumns & ',"data":' & $sData & ',"sortable":' & $sSortable & ',"filterable":' & $sFilterable & '}'

    ; Command senden
    Local $sCmd = '{"action":"createComponent","componentId":"' & $sId & '","componentType":"grid","payload":' & $sOptions & '}'
    _WV2React_SendCommand($sCmd)

    ; Komponente lokal registrieren
    Local $iIndex = $__g_aWV2React_Components[0][0] + 1
    ReDim $__g_aWV2React_Components[$iIndex + 1][4]
    $__g_aWV2React_Components[0][0] = $iIndex
    $__g_aWV2React_Components[$iIndex][0] = $sId
    $__g_aWV2React_Components[$iIndex][1] = "grid"
    $__g_aWV2React_Components[$iIndex][2] = "created"
    $__g_aWV2React_Components[$iIndex][3] = 0

    Return $sId
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_CreateGridFromArray
; Description ...: Erstellt ein Grid direkt aus einem 2D-Array (erste Zeile = Header)
; Syntax ........: _WV2React_CreateGridFromArray($sId, $aData, [$bSortable = True], [$bFilterable = True])
; Parameters ....: $sId         - Eindeutige ID fuer das Grid
;                  $aData       - 2D-Array (erste Zeile = Spalten-Namen)
;                  $bSortable   - [optional] Spalten sortierbar
;                  $bFilterable - [optional] Filterfeld anzeigen
; Return values .: Success - Grid ID
;                  Failure - "" und setzt @error
; Example .......: Local $aData[4][3] = [["ID", "Name", "Stadt"], [1, "Max", "Berlin"], [2, "Anna", "Hamburg"], [3, "Tom", "Muenchen"]]
;                  _WV2React_CreateGridFromArray("myGrid", $aData)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_CreateGridFromArray($sId, $aData, $bSortable = True, $bFilterable = True)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, "")
    If Not IsArray($aData) Or UBound($aData, 0) <> 2 Then Return SetError(2, 0, "")
    If UBound($aData) < 2 Then Return SetError(3, 0, "")  ; Mindestens Header + 1 Zeile

    ; Spalten aus erster Zeile extrahieren
    Local $iCols = UBound($aData, 2)
    Local $aColumns[$iCols][2]
    For $j = 0 To $iCols - 1
        $aColumns[$j][0] = StringReplace($aData[0][$j], " ", "_")  ; Key (keine Leerzeichen)
        $aColumns[$j][1] = $aData[0][$j]  ; Label
    Next

    ; Daten ohne Header-Zeile
    Local $aDataRows[UBound($aData) - 1][$iCols]
    For $i = 1 To UBound($aData) - 1
        For $j = 0 To $iCols - 1
            $aDataRows[$i - 1][$j] = $aData[$i][$j]
        Next
    Next

    Return _WV2React_CreateGrid($sId, $aColumns, $aDataRows, $bSortable, $bFilterable)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_UpdateGridData
; Description ...: Aktualisiert die Daten eines Grids
; Syntax ........: _WV2React_UpdateGridData($sGridId, $aData)
; Parameters ....: $sGridId - ID des Grids
;                  $aData   - Neues Daten-Array (ohne Header-Zeile)
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_UpdateGridData($sGridId, $aData)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)
    If Not IsArray($aData) Then Return SetError(2, 0, False)

    ; Spalten vom Grid holen
    Local $sScript = "var comp = WV2Bridge.components.get('" & $sGridId & "');"
    $sScript &= "comp ? JSON.stringify(comp.columns) : null;"

    Local $sColJson = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    If @error Or $sColJson = "null" Then Return SetError(3, 0, False)

    ; Spalten-Keys extrahieren (vereinfacht)
    Local $aColumns = __WV2React_Grid_ParseColumns($sColJson)

    ; Daten-JSON erstellen
    Local $sData = __WV2React_Grid_DataToJson($aColumns, $aData)

    ; Update senden
    Local $sCmd = '{"action":"updateComponent","componentId":"' & $sGridId & '","payload":{"data":' & $sData & '}}'
    _WV2React_SendCommand($sCmd)

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_GetGridSelection
; Description ...: Gibt die aktuell ausgewaehlte Zeile zurueck
; Syntax ........: _WV2React_GetGridSelection($sGridId)
; Parameters ....: $sGridId - ID des Grids
; Return values .: Success - Array [Index, RowData-JSON]
;                  Failure - -1 (keine Auswahl) oder setzt @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_GetGridSelection($sGridId)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, -1)

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sGridId & "');"
    $sScript &= "if(comp && comp.selectedRow !== null) {"
    $sScript &= "  JSON.stringify({index: comp.selectedRow, row: comp.data[comp.selectedRow]});"
    $sScript &= "} else { 'null'; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    If @error Then Return SetError(2, @error, -1)
    If $sResult = "null" Or $sResult = '"null"' Then Return -1

    Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SetGridFilter
; Description ...: Setzt den Filtertext des Grids
; Syntax ........: _WV2React_SetGridFilter($sGridId, $sFilter)
; Parameters ....: $sGridId - ID des Grids
;                  $sFilter - Filtertext
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SetGridFilter($sGridId, $sFilter)
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    $sFilter = StringReplace($sFilter, '"', '\"')
    $sFilter = StringReplace($sFilter, "'", "\'")

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sGridId & "');"
    $sScript &= "if(comp) { comp.filter('" & $sFilter & "'); true; } else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2React_SortGrid
; Description ...: Sortiert das Grid nach einer Spalte
; Syntax ........: _WV2React_SortGrid($sGridId, $sColumnKey, [$sDirection = "asc"])
; Parameters ....: $sGridId    - ID des Grids
;                  $sColumnKey - Spalten-Key
;                  $sDirection - [optional] "asc" oder "desc"
; Return values .: Success - True
;                  Failure - False
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2React_SortGrid($sGridId, $sColumnKey, $sDirection = "asc")
    If Not $__g_bWV2React_Initialized Then Return SetError(1, 0, False)

    Local $sScript = "var comp = WV2Bridge.components.get('" & $sGridId & "');"
    $sScript &= "if(comp) {"
    $sScript &= "  comp.sortColumn = '" & $sColumnKey & "';"
    $sScript &= "  comp.sortDir = '" & $sDirection & "';"
    $sScript &= "  comp.sort('" & $sColumnKey & "');"
    $sScript &= "  true;"
    $sScript &= "} else { false; }"

    Local $sResult = _WebView2_ExecuteScript($__g_oWV2React_WebView, $sScript, 3000)
    Return ($sResult = "true")
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Konvertiert Daten-Array zu JSON basierend auf Spalten-Definition
Func __WV2React_Grid_DataToJson($aColumns, $aData)
    If Not IsArray($aData) Then Return "[]"

    Local $sJson = "["
    Local $bFirstRow = True

    ; 2D Array
    If UBound($aData, 0) = 2 Then
        For $i = 0 To UBound($aData) - 1
            If Not $bFirstRow Then $sJson &= ","
            $bFirstRow = False

            $sJson &= "{"
            For $j = 0 To UBound($aData, 2) - 1
                If $j > 0 Then $sJson &= ","

                ; Key ermitteln
                Local $sKey
                If IsArray($aColumns) And $j < UBound($aColumns) Then
                    ; Pruefen ob 2D-Array
                    If UBound($aColumns, 0) = 2 Then
                        $sKey = $aColumns[$j][0]
                    Else
                        $sKey = $aColumns[$j]
                    EndIf
                Else
                    $sKey = "col" & $j
                EndIf

                ; Value
                $sJson &= '"' & $sKey & '":'
                If IsString($aData[$i][$j]) Then
                    Local $sVal = StringReplace($aData[$i][$j], '\', '\\')
                    $sVal = StringReplace($sVal, '"', '\"')
                    $sJson &= '"' & $sVal & '"'
                ElseIf IsNumber($aData[$i][$j]) Then
                    $sJson &= $aData[$i][$j]
                Else
                    $sJson &= "null"
                EndIf
            Next
            $sJson &= "}"
        Next
    EndIf

    $sJson &= "]"
    Return $sJson
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Parsed Spalten-JSON zu Array
Func __WV2React_Grid_ParseColumns($sJson)
    ; Vereinfachtes Parsing - extrahiert nur Keys
    Local $aKeys[0]
    Local $aMatches = StringRegExp($sJson, '"key"\s*:\s*"([^"]+)"', 3)
    If Not @error And IsArray($aMatches) Then
        ReDim $aKeys[UBound($aMatches)]
        For $i = 0 To UBound($aMatches) - 1
            $aKeys[$i] = $aMatches[$i]
        Next
    EndIf
    Return $aKeys
EndFunc

; ===============================================================================================================================
; End of WV2React_Grid.au3
; ===============================================================================================================================
