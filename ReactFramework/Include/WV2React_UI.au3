; ===============================================================================================================================
; WV2React_UI.au3 - Erweiterte UI-Komponenten fuer WV2React Framework
; ===============================================================================================================================
; Komponenten:
;   - Button, Input, Textarea, Checkbox, Radio, Switch, Select (Basis-Eingabe)
;   - DatePicker, ColorPicker, Slider, FileUpload (Erweiterte Eingabe)
;   - Tabs, Sidebar, Breadcrumb, Pagination, Stepper (Navigation)
;   - TreeView, Accordion, Splitter (Struktur)
;   - Modal, Toast, Alert, Progress, Spinner, Tooltip (Feedback)
;   - Chart, Badge, Avatar, Tag (Daten)
;   - Dashboard, Divider (Layout)
;
; AUTOR: Ralle1976
; VERSION: 1.0.0
; ===============================================================================================================================

#include-once
#include "WV2React_Core.au3"

; ===============================================================================================================================
; PHASE 1: BASIS-EINGABE
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateButton
; Description....: Erstellt einen Button
; Syntax.........: _WV2React_CreateButton($sId, $sText, $sVariant = "primary", $sSize = "md", $sIcon = "")
; Parameters.....: $sId      - Eindeutige ID
;                  $sText    - Button-Text
;                  $sVariant - Variante: primary, secondary, success, danger, warning, outline, ghost
;                  $sSize    - Groesse: sm, md, lg
;                  $sIcon    - Optional: Icon (Emoji oder HTML)
; Return values..: Erfolg: 1, Fehler: 0
; ===============================================================================================================================
Func _WV2React_CreateButton($sId, $sText, $sVariant = "primary", $sSize = "md", $sIcon = "")
    Local $sPayload = '{"text":"' & $sText & '","variant":"' & $sVariant & '","size":"' & $sSize & '","icon":"' & $sIcon & '","disabled":false}'
    Return _WV2React_CreateComponent("button", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateInput
; Description....: Erstellt ein Eingabefeld
; Syntax.........: _WV2React_CreateInput($sId, $sType = "text", $sPlaceholder = "", $sLabel = "", $sValue = "")
; Parameters.....: $sId          - Eindeutige ID
;                  $sType        - Typ: text, number, password, email, tel, url, search
;                  $sPlaceholder - Placeholder-Text
;                  $sLabel       - Label ueber dem Input
;                  $sValue       - Startwert
; Return values..: Erfolg: 1, Fehler: 0
; ===============================================================================================================================
Func _WV2React_CreateInput($sId, $sType = "text", $sPlaceholder = "", $sLabel = "", $sValue = "")
    Local $sPayload = '{"type":"' & $sType & '","placeholder":"' & $sPlaceholder & '","label":"' & $sLabel & '","value":"' & $sValue & '","disabled":false,"required":false}'
    Return _WV2React_CreateComponent("input", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTextarea
; Description....: Erstellt ein mehrzeiliges Textfeld
; ===============================================================================================================================
Func _WV2React_CreateTextarea($sId, $sPlaceholder = "", $sLabel = "", $sValue = "", $iRows = 4)
    Local $sPayload = '{"placeholder":"' & $sPlaceholder & '","label":"' & $sLabel & '","value":"' & $sValue & '","rows":' & $iRows & ',"disabled":false}'
    Return _WV2React_CreateComponent("textarea", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateCheckbox
; Description....: Erstellt eine Checkbox
; ===============================================================================================================================
Func _WV2React_CreateCheckbox($sId, $sLabel, $bChecked = False)
    Local $sChecked = $bChecked ? "true" : "false"
    Local $sPayload = '{"label":"' & $sLabel & '","checked":' & $sChecked & ',"disabled":false}'
    Return _WV2React_CreateComponent("checkbox", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateRadioGroup
; Description....: Erstellt eine Radio-Button-Gruppe
; Parameters.....: $sId      - Eindeutige ID
;                  $sLabel   - Gruppen-Label
;                  $aOptions - Array mit Optionen: [["value1", "Label 1"], ["value2", "Label 2"]]
;                  $sValue   - Vorausgewaehlter Wert
; ===============================================================================================================================
Func _WV2React_CreateRadioGroup($sId, $sLabel, $aOptions, $sValue = "")
    Local $sOptions = "["
    For $i = 0 To UBound($aOptions) - 1
        If $i > 0 Then $sOptions &= ","
        $sOptions &= '{"value":"' & $aOptions[$i][0] & '","label":"' & $aOptions[$i][1] & '"}'
    Next
    $sOptions &= "]"
    Local $sPayload = '{"label":"' & $sLabel & '","options":' & $sOptions & ',"value":"' & $sValue & '","disabled":false}'
    Return _WV2React_CreateComponent("radio", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateSwitch
; Description....: Erstellt einen Toggle-Switch
; ===============================================================================================================================
Func _WV2React_CreateSwitch($sId, $sLabel, $bChecked = False)
    Local $sChecked = $bChecked ? "true" : "false"
    Local $sPayload = '{"label":"' & $sLabel & '","checked":' & $sChecked & ',"disabled":false}'
    Return _WV2React_CreateComponent("switch", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateSelect
; Description....: Erstellt ein Dropdown-Select
; Parameters.....: $sId      - Eindeutige ID
;                  $sLabel   - Label
;                  $aOptions - Array mit Optionen: [["value1", "Label 1"], ["value2", "Label 2"]]
;                  $sValue   - Vorausgewaehlter Wert
;                  $sPlaceholder - Placeholder wenn nichts ausgewaehlt
; ===============================================================================================================================
Func _WV2React_CreateSelect($sId, $sLabel, $aOptions, $sValue = "", $sPlaceholder = "Bitte waehlen...")
    Local $sOptions = "["
    For $i = 0 To UBound($aOptions) - 1
        If $i > 0 Then $sOptions &= ","
        $sOptions &= '{"value":"' & $aOptions[$i][0] & '","label":"' & $aOptions[$i][1] & '"}'
    Next
    $sOptions &= "]"
    Local $sPayload = '{"label":"' & $sLabel & '","options":' & $sOptions & ',"value":"' & $sValue & '","placeholder":"' & $sPlaceholder & '","disabled":false}'
    Return _WV2React_CreateComponent("select", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 2: ERWEITERTE EINGABE
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateDatePicker
; Description....: Erstellt einen Datums-Picker
; ===============================================================================================================================
Func _WV2React_CreateDatePicker($sId, $sLabel = "", $sValue = "", $sMin = "", $sMax = "")
    Local $sPayload = '{"label":"' & $sLabel & '","value":"' & $sValue & '","min":"' & $sMin & '","max":"' & $sMax & '","disabled":false}'
    Return _WV2React_CreateComponent("datepicker", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTimePicker
; Description....: Erstellt einen Zeit-Picker
; ===============================================================================================================================
Func _WV2React_CreateTimePicker($sId, $sLabel = "", $sValue = "")
    Local $sPayload = '{"label":"' & $sLabel & '","value":"' & $sValue & '","disabled":false}'
    Return _WV2React_CreateComponent("timepicker", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateColorPicker
; Description....: Erstellt einen Farb-Picker
; ===============================================================================================================================
Func _WV2React_CreateColorPicker($sId, $sLabel = "", $sValue = "#3B82F6")
    Local $sPayload = '{"label":"' & $sLabel & '","value":"' & $sValue & '","disabled":false}'
    Return _WV2React_CreateComponent("colorpicker", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateSlider
; Description....: Erstellt einen Slider/Range
; ===============================================================================================================================
Func _WV2React_CreateSlider($sId, $sLabel = "", $nValue = 50, $nMin = 0, $nMax = 100, $nStep = 1)
    Local $sPayload = '{"label":"' & $sLabel & '","value":' & $nValue & ',"min":' & $nMin & ',"max":' & $nMax & ',"step":' & $nStep & ',"disabled":false}'
    Return _WV2React_CreateComponent("slider", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateFileUpload
; Description....: Erstellt ein Datei-Upload-Feld
; ===============================================================================================================================
Func _WV2React_CreateFileUpload($sId, $sLabel = "Datei auswaehlen", $sAccept = "*", $bMultiple = False)
    Local $sMultiple = $bMultiple ? "true" : "false"
    Local $sPayload = '{"label":"' & $sLabel & '","accept":"' & $sAccept & '","multiple":' & $sMultiple & ',"disabled":false}'
    Return _WV2React_CreateComponent("fileupload", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 3: NAVIGATION
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTabs
; Description....: Erstellt ein Tab-Panel
; Parameters.....: $sId      - Eindeutige ID
;                  $aTabs    - Array mit Tabs: [["id1", "Label 1", "content1"], ["id2", "Label 2", "content2"]]
;                  $sActive  - ID des aktiven Tabs
; ===============================================================================================================================
Func _WV2React_CreateTabs($sId, $aTabs, $sActive = "")
    Local $sTabs = "["
    For $i = 0 To UBound($aTabs) - 1
        If $i > 0 Then $sTabs &= ","
        $sTabs &= '{"id":"' & $aTabs[$i][0] & '","label":"' & $aTabs[$i][1] & '","content":"' & StringReplace($aTabs[$i][2], '"', '\"') & '"}'
    Next
    $sTabs &= "]"
    If $sActive = "" And UBound($aTabs) > 0 Then $sActive = $aTabs[0][0]
    Local $sPayload = '{"tabs":' & $sTabs & ',"active":"' & $sActive & '"}'
    Return _WV2React_CreateComponent("tabs", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateBreadcrumb
; Description....: Erstellt eine Breadcrumb-Navigation
; Parameters.....: $sId    - Eindeutige ID
;                  $aItems - Array mit Items: [["Home", ""], ["Kategorie", ""], ["Aktuell", ""]]
; ===============================================================================================================================
Func _WV2React_CreateBreadcrumb($sId, $aItems)
    Local $sItems = "["
    For $i = 0 To UBound($aItems) - 1
        If $i > 0 Then $sItems &= ","
        $sItems &= '{"label":"' & $aItems[$i][0] & '","href":"' & $aItems[$i][1] & '"}'
    Next
    $sItems &= "]"
    Local $sPayload = '{"items":' & $sItems & '}'
    Return _WV2React_CreateComponent("breadcrumb", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreatePagination
; Description....: Erstellt eine Pagination
; ===============================================================================================================================
Func _WV2React_CreatePagination($sId, $iTotal, $iPerPage = 10, $iCurrent = 1)
    Local $sPayload = '{"total":' & $iTotal & ',"perPage":' & $iPerPage & ',"current":' & $iCurrent & '}'
    Return _WV2React_CreateComponent("pagination", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateStepper
; Description....: Erstellt einen Stepper/Wizard
; Parameters.....: $sId     - Eindeutige ID
;                  $aSteps  - Array mit Steps: [["Schritt 1", "Beschreibung"], ...]
;                  $iActive - Aktiver Schritt (0-basiert)
; ===============================================================================================================================
Func _WV2React_CreateStepper($sId, $aSteps, $iActive = 0)
    Local $sSteps = "["
    For $i = 0 To UBound($aSteps) - 1
        If $i > 0 Then $sSteps &= ","
        $sSteps &= '{"title":"' & $aSteps[$i][0] & '","description":"' & $aSteps[$i][1] & '"}'
    Next
    $sSteps &= "]"
    Local $sPayload = '{"steps":' & $sSteps & ',"active":' & $iActive & '}'
    Return _WV2React_CreateComponent("stepper", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 4: STRUKTUR
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTreeView
; Description....: Erstellt einen TreeView
; Parameters.....: $sId    - Eindeutige ID
;                  $aNodes - Hierarchisches Array (wird als JSON uebergeben)
; Beispiel.......: '[{"id":"1","label":"Root","children":[{"id":"1.1","label":"Child"}]}]'
; ===============================================================================================================================
Func _WV2React_CreateTreeView($sId, $sNodesJson)
    Local $sPayload = '{"nodes":' & $sNodesJson & ',"expandedIds":[],"selectedId":""}'
    Return _WV2React_CreateComponent("treeview", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateAccordion
; Description....: Erstellt ein Accordion
; Parameters.....: $sId     - Eindeutige ID
;                  $aItems  - Array: [["Titel 1", "Inhalt 1"], ["Titel 2", "Inhalt 2"]]
;                  $bMultiple - Mehrere gleichzeitig offen?
; ===============================================================================================================================
Func _WV2React_CreateAccordion($sId, $aItems, $bMultiple = False)
    Local $sItems = "["
    For $i = 0 To UBound($aItems) - 1
        If $i > 0 Then $sItems &= ","
        $sItems &= '{"id":"item' & $i & '","title":"' & $aItems[$i][0] & '","content":"' & StringReplace($aItems[$i][1], '"', '\"') & '"}'
    Next
    $sItems &= "]"
    Local $sMultiple = $bMultiple ? "true" : "false"
    Local $sPayload = '{"items":' & $sItems & ',"multiple":' & $sMultiple & ',"openIds":[]}'
    Return _WV2React_CreateComponent("accordion", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 5: FEEDBACK
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateModal
; Description....: Erstellt ein Modal/Dialog
; ===============================================================================================================================
Func _WV2React_CreateModal($sId, $sTitle, $sContent, $bShowClose = True)
    Local $sShowClose = $bShowClose ? "true" : "false"
    Local $sPayload = '{"title":"' & $sTitle & '","content":"' & StringReplace($sContent, '"', '\"') & '","showClose":' & $sShowClose & ',"open":false}'
    Return _WV2React_CreateComponent("modal", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_ShowModal
; Description....: Zeigt ein Modal an
; ===============================================================================================================================
Func _WV2React_ShowModal($sId)
    Return _WV2React_UpdateComponent($sId, '{"open":true}')
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_HideModal
; Description....: Versteckt ein Modal
; ===============================================================================================================================
Func _WV2React_HideModal($sId)
    Return _WV2React_UpdateComponent($sId, '{"open":false}')
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_ShowToast
; Description....: Zeigt eine Toast-Benachrichtigung
; Parameters.....: $sMessage  - Nachricht
;                  $sType     - Typ: success, error, warning, info
;                  $iDuration - Dauer in ms (0 = persistent)
; ===============================================================================================================================
Func _WV2React_ShowToast($sMessage, $sType = "info", $iDuration = 3000)
    Local $sPayload = '{"message":"' & $sMessage & '","type":"' & $sType & '","duration":' & $iDuration & '}'
    Return _WV2React_CreateComponent("toast", "toast_" & Random(1000, 9999, 1), $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateAlert
; Description....: Erstellt eine Alert-Box
; ===============================================================================================================================
Func _WV2React_CreateAlert($sId, $sMessage, $sType = "info", $sTitle = "", $bDismissable = True)
    Local $sDismissable = $bDismissable ? "true" : "false"
    Local $sPayload = '{"message":"' & $sMessage & '","type":"' & $sType & '","title":"' & $sTitle & '","dismissable":' & $sDismissable & ',"visible":true}'
    Return _WV2React_CreateComponent("alert", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateProgress
; Description....: Erstellt einen Progress-Bar
; ===============================================================================================================================
Func _WV2React_CreateProgress($sId, $nValue = 0, $sLabel = "", $sColor = "")
    Local $sPayload = '{"value":' & $nValue & ',"label":"' & $sLabel & '","color":"' & $sColor & '","showValue":true}'
    Return _WV2React_CreateComponent("progress", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_SetProgress
; Description....: Aktualisiert Progress-Bar
; ===============================================================================================================================
Func _WV2React_SetProgress($sId, $nValue, $sLabel = "")
    If $sLabel = "" Then
        Return _WV2React_UpdateComponent($sId, '{"value":' & $nValue & '}')
    Else
        Return _WV2React_UpdateComponent($sId, '{"value":' & $nValue & ',"label":"' & $sLabel & '"}')
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateSpinner
; Description....: Erstellt einen Lade-Spinner
; ===============================================================================================================================
Func _WV2React_CreateSpinner($sId, $sSize = "md", $sColor = "")
    Local $sPayload = '{"size":"' & $sSize & '","color":"' & $sColor & '"}'
    Return _WV2React_CreateComponent("spinner", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTooltip
; Description....: Erstellt einen Tooltip (wird an Element angehaengt)
; ===============================================================================================================================
Func _WV2React_CreateTooltip($sId, $sTargetId, $sContent, $sPosition = "top")
    Local $sPayload = '{"targetId":"' & $sTargetId & '","content":"' & $sContent & '","position":"' & $sPosition & '"}'
    Return _WV2React_CreateComponent("tooltip", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 6: DATEN
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateChart
; Description....: Erstellt ein Chart (Chart.js)
; Parameters.....: $sId     - Eindeutige ID
;                  $sType   - Typ: line, bar, pie, doughnut, radar, polarArea
;                  $sDataJson - Chart-Daten als JSON
; Beispiel.......: '{"labels":["A","B","C"],"datasets":[{"label":"Werte","data":[10,20,30]}]}'
; ===============================================================================================================================
Func _WV2React_CreateChart($sId, $sType, $sDataJson)
    Local $sPayload = '{"type":"' & $sType & '","data":' & $sDataJson & ',"options":{}}'
    Return _WV2React_CreateComponent("chart", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateBadge
; Description....: Erstellt ein Badge/Label
; ===============================================================================================================================
Func _WV2React_CreateBadge($sId, $sText, $sVariant = "primary")
    Local $sPayload = '{"text":"' & $sText & '","variant":"' & $sVariant & '"}'
    Return _WV2React_CreateComponent("badge", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateAvatar
; Description....: Erstellt einen Avatar
; ===============================================================================================================================
Func _WV2React_CreateAvatar($sId, $sSrc = "", $sName = "", $sSize = "md")
    Local $sPayload = '{"src":"' & $sSrc & '","name":"' & $sName & '","size":"' & $sSize & '"}'
    Return _WV2React_CreateComponent("avatar", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateTag
; Description....: Erstellt ein Tag/Chip
; ===============================================================================================================================
Func _WV2React_CreateTag($sId, $sText, $sColor = "", $bRemovable = False)
    Local $sRemovable = $bRemovable ? "true" : "false"
    Local $sPayload = '{"text":"' & $sText & '","color":"' & $sColor & '","removable":' & $sRemovable & '}'
    Return _WV2React_CreateComponent("tag", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; PHASE 7: LAYOUT
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateDivider
; Description....: Erstellt einen Trenner
; ===============================================================================================================================
Func _WV2React_CreateDivider($sId, $sText = "", $sOrientation = "horizontal")
    Local $sPayload = '{"text":"' & $sText & '","orientation":"' & $sOrientation & '"}'
    Return _WV2React_CreateComponent("divider", $sId, $sPayload)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_CreateStatCard
; Description....: Erstellt eine Statistik-Karte
; ===============================================================================================================================
Func _WV2React_CreateStatCard($sId, $sTitle, $sValue, $sIcon = "", $sChange = "", $bPositive = True)
    Local $sPositive = $bPositive ? "true" : "false"
    Local $sPayload = '{"title":"' & $sTitle & '","value":"' & $sValue & '","icon":"' & $sIcon & '","change":"' & $sChange & '","positive":' & $sPositive & '}'
    Return _WV2React_CreateComponent("statcard", $sId, $sPayload)
EndFunc

; ===============================================================================================================================
; HILFSFUNKTIONEN
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_SetValue
; Description....: Setzt den Wert einer Eingabe-Komponente
; ===============================================================================================================================
Func _WV2React_SetValue($sId, $sValue)
    Return _WV2React_UpdateComponent($sId, '{"value":"' & $sValue & '"}')
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_GetValue
; Description....: Liest den Wert einer Eingabe-Komponente
; ===============================================================================================================================
Func _WV2React_GetValue($sId)
    Local $sState = _WV2React_GetComponentState($sId)
    If $sState = "" Then Return ""
    ; Einfaches JSON-Parsing fuer "value"
    Local $aMatch = StringRegExp($sState, '"value"\s*:\s*"([^"]*)"', 1)
    If @error Then
        ; Versuche numerischen Wert
        $aMatch = StringRegExp($sState, '"value"\s*:\s*([0-9.]+)', 1)
        If @error Then Return ""
    EndIf
    Return $aMatch[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_SetEnabled
; Description....: Aktiviert/Deaktiviert eine Komponente
; ===============================================================================================================================
Func _WV2React_SetEnabled($sId, $bEnabled = True)
    Local $sDisabled = $bEnabled ? "false" : "true"
    Return _WV2React_UpdateComponent($sId, '{"disabled":' & $sDisabled & '}')
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2React_SetVisible
; Description....: Zeigt/Versteckt eine Komponente
; ===============================================================================================================================
Func _WV2React_SetVisible($sId, $bVisible = True)
    Local $sVisible = $bVisible ? "true" : "false"
    Return _WV2React_UpdateComponent($sId, '{"visible":' & $sVisible & '}')
EndFunc
