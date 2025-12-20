#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Description=SQLite Manager Pro
#AutoIt3Wrapper_Res_Fileversion=3.5.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Ralle1976
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SQLite.au3>
#include "..\Include\WebView2_Native.au3"

; ============================================================
; SQLite Manager Pro v3.5 - MODULAR PLUGIN SYSTEM
; Features: Syntax Highlighting, Auto-Completion, Query Wizard
;           EXPLAIN Plan, Import/Export, Multi-Statement, Themes
; ============================================================

; Konstante fuer einfache Anfuehrungszeichen in JavaScript
Global Const $Q = Chr(39)

; Pagination System - Ergebnisse in Chunks laden
Global Const $CHUNK_SIZE = 500  ; Zeilen pro Chunk
Global $g_aLastResult[0][0]     ; Gespeichertes Ergebnis
Global $g_iLastRows = 0         ; Gesamtzahl Zeilen
Global $g_iLastCols = 0         ; Anzahl Spalten
Global $g_iCurrentOffset = 0    ; Aktuelle Position

; ============================================================
; PLUGIN SYSTEM - Enable/Disable Features
; ============================================================
Global $g_aPlugins[7][3] = [ _
    ["explain", True, "EXPLAIN QUERY PLAN Analyse"], _
    ["import", True, "CSV/JSON Import"], _
    ["dump", True, "SQL Dump Export"], _
    ["multiexec", True, "Multi-Statement Execution"], _
    ["themes", True, "Dark/Light Theme Toggle"], _
    ["templates", True, "Query Templates"], _
    ["compare", True, "Table Compare Tool"] _
]

Func _PluginEnabled($sName)
    For $i = 0 To UBound($g_aPlugins) - 1
        If $g_aPlugins[$i][0] = $sName Then Return $g_aPlugins[$i][1]
    Next
    Return False
EndFunc

ConsoleWrite("=== SQLite Manager Pro v3.5 (Modular) startet ===" & @CRLF)

; COM init
DllCall("ole32.dll", "long", "OleInitialize", "ptr", 0)

; SQLite init
Local $sSQLiteDll = @ScriptDir & "\sqlite3" & (@AutoItX64 ? "_x64" : "_x86") & ".dll"
If Not FileExists($sSQLiteDll) Then $sSQLiteDll = @ScriptDir & "\sqlite3.dll"
_SQLite_Startup($sSQLiteDll, False, 1)
If @error Then
    MsgBox(16, "Error", "SQLite DLL nicht gefunden!")
    Exit
EndIf

; GUI erstellen - groesseres Fenster
Global $hGUI = GUICreate("SQLite Manager Pro v3.5", 1400, 900, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))

; Native Buttons - Erste Reihe
Global $btnOpen = GUICtrlCreateButton("Open DB", 10, 10, 80, 28)
Global $btnNew = GUICtrlCreateButton("New DB", 95, 10, 80, 28)
Global $btnExec = GUICtrlCreateButton("Execute F5", 180, 10, 85, 28)
Global $btnWizard = GUICtrlCreateButton("Query Wizard", 270, 10, 95, 28)
Global $btnExport = GUICtrlCreateButton("Export", 370, 10, 70, 28)
Global $btnHistory = GUICtrlCreateButton("History", 445, 10, 70, 28)

; Plugin Buttons - Modular (nur wenn aktiviert)
Global $btnExplain = 0, $btnImport = 0, $btnDump = 0, $btnTemplates = 0, $btnTheme = 0
Local $iNextX = 520

If _PluginEnabled("explain") Then
    $btnExplain = GUICtrlCreateButton("EXPLAIN", $iNextX, 10, 70, 28)
    $iNextX += 75
EndIf
If _PluginEnabled("import") Then
    $btnImport = GUICtrlCreateButton("Import", $iNextX, 10, 60, 28)
    $iNextX += 65
EndIf
If _PluginEnabled("dump") Then
    $btnDump = GUICtrlCreateButton("SQL Dump", $iNextX, 10, 75, 28)
    $iNextX += 80
EndIf
If _PluginEnabled("templates") Then
    $btnTemplates = GUICtrlCreateButton("Templates", $iNextX, 10, 75, 28)
    $iNextX += 80
EndIf
If _PluginEnabled("themes") Then
    $btnTheme = GUICtrlCreateButton("Theme", $iNextX, 10, 60, 28)
    $iNextX += 65
EndIf

Global $lblStatus = GUICtrlCreateLabel("Keine Datenbank", $iNextX + 10, 14, 1380 - $iNextX, 20)
GUICtrlSetColor($lblStatus, 0x666666)

; Hotkeys
Local $aAccel[2][2] = [["{F5}", $btnExec], ["^{SPACE}", $btnWizard]]
GUISetAccelerators($aAccel)

GUISetState(@SW_SHOW)

; Message pump
For $i = 1 To 20
    GUIGetMsg()
    Sleep(10)
Next

; WebView2
Global $aWebView = _WebView2_Create($hGUI, 0, 45, 1400, 855)
If @error Then
    MsgBox(16, "Error", "WebView2 konnte nicht erstellt werden!")
    Exit
EndIf

; HTML laden (externe Dateien oder Fallback)
_WebView2_NavigateToString($aWebView, _LoadUI())

; JS -> AutoIt Kommunikation: Polling-basiert (zuverlaessiger als Callbacks)
; Die Nachrichten werden in der Event-Loop geprueft

; Globale Variablen
Global $g_sDB = ""
Global $g_aHistory[0]

; Globale Theme-Variable
Global $g_bDarkTheme = True

; Event Loop mit JS-Polling
Local $iLastPoll = 0
While True
    Local $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $btnOpen
            _DoOpenDB()
        Case $btnNew
            _DoNewDB()
        Case $btnExec
            _DoExecute()
        Case $btnWizard
            _DoShowWizard()
        Case $btnExport
            _DoExport()
        Case $btnHistory
            _DoShowHistory()
        ; Plugin Event Handlers
        Case $btnExplain
            If $btnExplain Then _DoExplain()
        Case $btnImport
            If $btnImport Then _DoImport()
        Case $btnDump
            If $btnDump Then _DoDump()
        Case $btnTemplates
            If $btnTemplates Then _DoShowTemplates()
        Case $btnTheme
            If $btnTheme Then _DoToggleTheme()
        Case $GUI_EVENT_RESIZED, $GUI_EVENT_MAXIMIZE, $GUI_EVENT_RESTORE
            Local $aSize = WinGetClientSize($hGUI)
            If IsArray($aSize) Then _WebView2_SetBounds($aWebView, 0, 45, $aSize[0], $aSize[1] - 45)
    EndSwitch

    ; JS-Polling alle 100ms fuer pending actions
    If TimerDiff($iLastPoll) > 100 Then
        $iLastPoll = TimerInit()
        _CheckPendingAction()
    EndIf
WEnd

; Cleanup
If $g_sDB Then _SQLite_Close()
_SQLite_Shutdown()
If IsArray($aWebView) Then
    _WebView2_Close($aWebView)
    _WV2CB_Cleanup()
EndIf
GUIDelete($hGUI)
DllCall("ole32.dll", "none", "OleUninitialize")

; ============================================================
; Funktionen
; ============================================================

Func _DoOpenDB()
    Local $sFile = FileOpenDialog("Open SQLite Database", @ScriptDir, "SQLite (*.db;*.sqlite;*.sqlite3)|All (*.*)", 1, "", $hGUI)
    If @error Then Return
    If $g_sDB Then _SQLite_Close()
    _SQLite_Open($sFile)
    If @error Then
        _ShowError("Konnte Datenbank nicht oeffnen!")
        Return
    EndIf
    $g_sDB = $sFile
    GUICtrlSetData($lblStatus, "DB: " & StringRegExpReplace($sFile, ".*\\", ""))
    _RefreshSchema()
    _ShowMessage("Datenbank geoeffnet!")
EndFunc

Func _DoNewDB()
    Local $sFile = FileSaveDialog("Create New Database", @ScriptDir, "SQLite (*.db)", 18, "newdb.db", $hGUI)
    If @error Then Return
    If Not StringRegExp($sFile, "\.db$") Then $sFile &= ".db"
    If $g_sDB Then _SQLite_Close()
    _SQLite_Open($sFile)
    If @error Then
        _ShowError("Konnte Datenbank nicht erstellen!")
        Return
    EndIf
    $g_sDB = $sFile
    GUICtrlSetData($lblStatus, "DB: " & StringRegExpReplace($sFile, ".*\\", ""))
    _RefreshSchema()
    _ShowMessage("Neue Datenbank erstellt!")
EndFunc

Func _DoExecute()
    If Not $g_sDB Then
        _ShowError("Keine Datenbank geoeffnet!")
        Return
    EndIf

    Local $sSQL = _WebView2_ExecuteScript($aWebView, "getSQL()")
    If @error Or $sSQL = "" Or $sSQL = '""' Or $sSQL = "null" Then
        _ShowError("Bitte SQL eingeben!")
        Return
    EndIf

    ; Bereinigen
    $sSQL = StringTrimLeft($sSQL, 1)
    $sSQL = StringTrimRight($sSQL, 1)
    $sSQL = StringReplace($sSQL, "\n", @CRLF)
    $sSQL = StringReplace($sSQL, '\"', '"')
    $sSQL = StringReplace($sSQL, "\\", "\")

    If StringStripWS($sSQL, 3) = "" Then
        _ShowError("Bitte SQL eingeben!")
        Return
    EndIf

    ; History
    _AddToHistory($sSQL)

    ; Ausfuehren
    Local $hTimer = TimerInit()
    Local $aResult, $iRows, $iCols
    Local $iRet = _SQLite_GetTable2d(-1, $sSQL, $aResult, $iRows, $iCols)
    Local $fTime = Round(TimerDiff($hTimer), 2)

    If $iRet <> $SQLITE_OK Then
        _ShowError(_SQLite_ErrMsg())
        Return
    EndIf

    If $iCols = 0 Then
        _ShowMessage("Ausgefuehrt: " & $iRows & " Zeilen betroffen (" & $fTime & " ms)")
    Else
        _ShowResults($aResult, $iRows, $iCols, $fTime)
    EndIf

    ; Schema aktualisieren bei DDL
    If StringRegExp(StringUpper($sSQL), "^\s*(CREATE|DROP|ALTER)") Then _RefreshSchema()
EndFunc

Func _DoShowWizard()
    If Not $g_sDB Then
        _ShowError("Bitte zuerst eine Datenbank oeffnen!")
        Return
    EndIf
    _UpdateJS("showWizard", "")
EndFunc

Func _DoShowHistory()
    If UBound($g_aHistory) = 0 Then
        _ShowMessage("Keine Historie vorhanden")
        Return
    EndIf
    Local $sJSON = "["
    For $i = UBound($g_aHistory) - 1 To 0 Step -1
        If $i < UBound($g_aHistory) - 1 Then $sJSON &= ","
        $sJSON &= '"' & _JSEscape($g_aHistory[$i]) & '"'
    Next
    $sJSON &= "]"
    _UpdateJS("showHistory", $sJSON)
EndFunc

Func _AddToHistory($sSQL)
    ; Max 50 Eintraege
    If UBound($g_aHistory) >= 50 Then
        For $i = 0 To UBound($g_aHistory) - 2
            $g_aHistory[$i] = $g_aHistory[$i + 1]
        Next
        ReDim $g_aHistory[49]
    EndIf
    ReDim $g_aHistory[UBound($g_aHistory) + 1]
    $g_aHistory[UBound($g_aHistory) - 1] = $sSQL
EndFunc

Func _DoExport()
    If Not $g_sDB Then
        _ShowError("Keine Datenbank geoeffnet!")
        Return
    EndIf
    Local $sCheck = _WebView2_ExecuteScript($aWebView, "hasData()")
    If $sCheck = "false" Or $sCheck = "" Then
        _ShowError("Keine Daten zum Exportieren!")
        Return
    EndIf
    Local $sFile = FileSaveDialog("Export CSV", @ScriptDir, "CSV (*.csv)", 18, "export.csv", $hGUI)
    If @error Then Return
    If Not StringRegExp($sFile, "\.csv$") Then $sFile &= ".csv"
    Local $sCSV = _WebView2_ExecuteScript($aWebView, "getCSV()")
    $sCSV = StringTrimLeft($sCSV, 1)
    $sCSV = StringTrimRight($sCSV, 1)
    $sCSV = StringReplace($sCSV, "\n", @CRLF)
    $sCSV = StringReplace($sCSV, '\"', '"')
    FileWrite(FileOpen($sFile, 2 + 128), $sCSV)
    _ShowMessage("Exportiert: " & StringRegExpReplace($sFile, ".*\\", ""))
EndFunc

Func _RefreshSchema()
    If Not $g_sDB Then Return

    ; Tabellen und Views
    Local $aResult, $iRows, $iCols
    _SQLite_GetTable2d(-1, "SELECT name, type FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY type, name;", $aResult, $iRows, $iCols)

    If @error Or $iRows = 0 Then
        _UpdateJS("setSchema", "[]")
        Return
    EndIf

    ; Schema mit Spalten-Info
    Local $sJSON = "["
    For $i = 1 To $iRows
        If $i > 1 Then $sJSON &= ","
        Local $sTable = $aResult[$i][0]
        Local $sType = $aResult[$i][1]

        ; Spalten holen
        Local $aCols, $iColRows, $iColCols
        _SQLite_GetTable2d(-1, "PRAGMA table_info('" & $sTable & "');", $aCols, $iColRows, $iColCols)

        Local $sCols = "["
        If Not @error And $iColRows > 0 Then
            For $j = 1 To $iColRows
                If $j > 1 Then $sCols &= ","
                $sCols &= '{"n":"' & $aCols[$j][1] & '","t":"' & $aCols[$j][2] & '","pk":' & $aCols[$j][5] & ',"nn":' & $aCols[$j][3] & '}'
            Next
        EndIf
        $sCols &= "]"

        ; Foreign Keys
        Local $aFK, $iFKRows, $iFKCols
        _SQLite_GetTable2d(-1, "PRAGMA foreign_key_list('" & $sTable & "');", $aFK, $iFKRows, $iFKCols)

        Local $sFK = "["
        If Not @error And $iFKRows > 0 Then
            For $j = 1 To $iFKRows
                If $j > 1 Then $sFK &= ","
                $sFK &= '{"from":"' & $aFK[$j][3] & '","to":"' & $aFK[$j][2] & '.' & $aFK[$j][4] & '"}'
            Next
        EndIf
        $sFK &= "]"

        ; Indizes
        Local $aIdx, $iIdxRows, $iIdxCols
        _SQLite_GetTable2d(-1, "PRAGMA index_list('" & $sTable & "');", $aIdx, $iIdxRows, $iIdxCols)

        Local $sIdx = "["
        If Not @error And $iIdxRows > 0 Then
            For $j = 1 To $iIdxRows
                If $j > 1 Then $sIdx &= ","
                $sIdx &= '{"n":"' & $aIdx[$j][1] & '","u":' & $aIdx[$j][2] & '}'
            Next
        EndIf
        $sIdx &= "]"

        $sJSON &= '{"n":"' & $sTable & '","t":"' & $sType & '","cols":' & $sCols & ',"fk":' & $sFK & ',"idx":' & $sIdx & '}'
    Next
    $sJSON &= "]"

    _UpdateJS("setSchema", $sJSON)
EndFunc

Func _ShowResults($aResult, $iRows, $iCols, $fTime)
    ; Ergebnis global speichern fuer Pagination
    $g_aLastResult = $aResult
    $g_iLastRows = $iRows
    $g_iLastCols = $iCols
    $g_iCurrentOffset = 0

    ; Ersten Chunk senden
    Local $iChunkEnd = ($iRows < $CHUNK_SIZE) ? $iRows : $CHUNK_SIZE
    Local $bHasMore = ($iRows > $CHUNK_SIZE)

    Local $sJSON = '{"c":['
    For $i = 0 To $iCols - 1
        If $i > 0 Then $sJSON &= ","
        $sJSON &= '"' & _JSEscape($aResult[0][$i]) & '"'
    Next
    $sJSON &= '],"r":['
    For $i = 1 To $iChunkEnd
        If $i > 1 Then $sJSON &= ","
        $sJSON &= "["
        For $j = 0 To $iCols - 1
            If $j > 0 Then $sJSON &= ","
            $sJSON &= '"' & _JSEscape($aResult[$i][$j]) & '"'
        Next
        $sJSON &= "]"
    Next
    $sJSON &= '],"n":' & $iRows & ',"t":' & $fTime
    $sJSON &= ',"hasMore":' & ($bHasMore ? "true" : "false")
    $sJSON &= ',"displayed":' & $iChunkEnd
    $sJSON &= ',"chunkSize":' & $CHUNK_SIZE & '}'

    $g_iCurrentOffset = $iChunkEnd

    _UpdateJS("setResults", $sJSON)
EndFunc

; Naechsten Chunk laden (wird von JS aufgerufen)
Func _LoadMoreResults()
    If $g_iCurrentOffset >= $g_iLastRows Then
        ConsoleWrite("[SQLiteManager] Keine weiteren Daten" & @CRLF)
        Return
    EndIf

    Local $iStart = $g_iCurrentOffset + 1
    Local $iEnd = $g_iCurrentOffset + $CHUNK_SIZE
    If $iEnd > $g_iLastRows Then $iEnd = $g_iLastRows

    Local $bHasMore = ($iEnd < $g_iLastRows)

    Local $sJSON = '{"r":['
    For $i = $iStart To $iEnd
        If $i > $iStart Then $sJSON &= ","
        $sJSON &= "["
        For $j = 0 To $g_iLastCols - 1
            If $j > 0 Then $sJSON &= ","
            $sJSON &= '"' & _JSEscape($g_aLastResult[$i][$j]) & '"'
        Next
        $sJSON &= "]"
    Next
    $sJSON &= '],"hasMore":' & ($bHasMore ? "true" : "false")
    $sJSON &= ',"displayed":' & $iEnd & ',"total":' & $g_iLastRows & '}'

    $g_iCurrentOffset = $iEnd

    ConsoleWrite("[SQLiteManager] Chunk geladen: " & $iStart & "-" & $iEnd & " von " & $g_iLastRows & @CRLF)
    _UpdateJS("appendResults", $sJSON)
EndFunc

Func _ShowMessage($sMsg)
    _UpdateJS("setMsg", '"' & _JSEscape($sMsg) & '"')
EndFunc

Func _ShowError($sMsg)
    _UpdateJS("setErr", '"' & _JSEscape($sMsg) & '"')
EndFunc

Func _UpdateJS($sFunc, $sArg)
    If Not IsArray($aWebView) Then Return
    If $sArg = "" Then
        _WebView2_ExecuteScriptAsync($aWebView, $sFunc & "();")
    Else
        _WebView2_ExecuteScriptAsync($aWebView, $sFunc & "(" & $sArg & ");")
    EndIf
EndFunc

Func _JSEscape($s)
    $s = StringReplace($s, "\", "\\")
    $s = StringReplace($s, '"', '\"')
    $s = StringReplace($s, @CR, "")
    $s = StringReplace($s, @LF, "\n")
    Return $s
EndFunc

; ============================================================
; JS -> AutoIt Polling Handler
; ============================================================
Func _CheckPendingAction()
    If Not IsArray($aWebView) Then Return

    Local $sAction = _WebView2_ExecuteScript($aWebView, "getPendingAction()")
    If @error Or $sAction = "" Or $sAction = "null" Or $sAction = '""' Then Return

    ; Bereinigen (Anfuehrungszeichen entfernen)
    $sAction = StringTrimLeft($sAction, 1)
    $sAction = StringTrimRight($sAction, 1)

    If $sAction = "" Or $sAction = "null" Then Return

    ConsoleWrite("[Polling] Action: " & $sAction & @CRLF)

    Switch $sAction
        Case "loadMore"
            _LoadMoreResults()
        Case "refresh"
            _RefreshSchema()
    EndSwitch
EndFunc

; ============================================================
; PLUGIN FUNKTIONEN
; ============================================================

; EXPLAIN QUERY PLAN - Zeigt Query-Ausfuehrungsplan
Func _DoExplain()
    If Not $g_sDB Then
        _ShowError("Keine Datenbank geoeffnet!")
        Return
    EndIf

    Local $sSQL = _WebView2_ExecuteScript($aWebView, "getSQL()")
    If @error Or $sSQL = "" Or $sSQL = '""' Or $sSQL = "null" Then
        _ShowError("Bitte SQL eingeben!")
        Return
    EndIf

    ; Bereinigen
    $sSQL = StringTrimLeft($sSQL, 1)
    $sSQL = StringTrimRight($sSQL, 1)
    $sSQL = StringReplace($sSQL, "\n", @CRLF)
    $sSQL = StringReplace($sSQL, '\"', '"')
    $sSQL = StringReplace($sSQL, "\\", "\")

    If StringStripWS($sSQL, 3) = "" Then
        _ShowError("Bitte SQL eingeben!")
        Return
    EndIf

    ; EXPLAIN QUERY PLAN ausfuehren
    Local $aResult, $iRows, $iCols
    Local $iRet = _SQLite_GetTable2d(-1, "EXPLAIN QUERY PLAN " & $sSQL, $aResult, $iRows, $iCols)

    If $iRet <> $SQLITE_OK Then
        _ShowError(_SQLite_ErrMsg())
        Return
    EndIf

    If $iRows = 0 Then
        _ShowMessage("Kein Ausfuehrungsplan verfuegbar")
        Return
    EndIf

    ; Als JSON formatieren
    Local $sJSON = '{"type":"explain","plan":['
    For $i = 1 To $iRows
        If $i > 1 Then $sJSON &= ","
        $sJSON &= '{"id":' & $aResult[$i][0] & ',"parent":' & $aResult[$i][1] & ',"notused":' & $aResult[$i][2] & ',"detail":"' & _JSEscape($aResult[$i][3]) & '"}'
    Next
    $sJSON &= ']}'
    _UpdateJS("showExplain", $sJSON)
EndFunc

; CSV/JSON Import
Func _DoImport()
    If Not $g_sDB Then
        _ShowError("Keine Datenbank geoeffnet!")
        Return
    EndIf

    Local $sFile = FileOpenDialog("Import CSV/JSON", @ScriptDir, "CSV (*.csv)|JSON (*.json)|All (*.*)", 1, "", $hGUI)
    If @error Then Return

    Local $sExt = StringLower(StringRight($sFile, 4))
    Local $sContent = FileRead($sFile)

    If $sExt = ".csv" Then
        _ImportCSV($sContent)
    ElseIf $sExt = "json" Then
        _ImportJSON($sContent)
    Else
        _ShowError("Unbekanntes Format!")
    EndIf
EndFunc

Func _ImportCSV($sContent)
    ; CSV parsen
    Local $aLines = StringSplit(StringReplace($sContent, @CRLF, @LF), @LF, 2)
    If UBound($aLines) < 2 Then
        _ShowError("CSV leer oder ungueltig!")
        Return
    EndIf

    ; Erste Zeile = Spalten
    Local $aCols = StringSplit($aLines[0], ";", 2)
    If UBound($aCols) = 0 Then $aCols = StringSplit($aLines[0], ",", 2)

    ; Tabellennamen erfragen
    Local $sTable = InputBox("CSV Import", "Tabellenname fuer Import:", "imported_table", "", 300, 130)
    If @error Then Return

    ; CREATE TABLE
    Local $sCreate = "CREATE TABLE IF NOT EXISTS " & $sTable & " ("
    For $i = 0 To UBound($aCols) - 1
        If $i > 0 Then $sCreate &= ", "
        $sCreate &= '"' & StringStripWS($aCols[$i], 3) & '" TEXT'
    Next
    $sCreate &= ");"

    _SQLite_Exec(-1, $sCreate)
    If @error Then
        _ShowError("Konnte Tabelle nicht erstellen: " & _SQLite_ErrMsg())
        Return
    EndIf

    ; INSERT Daten
    Local $iInserted = 0
    For $i = 1 To UBound($aLines) - 1
        If StringStripWS($aLines[$i], 3) = "" Then ContinueLoop

        Local $aVals = StringSplit($aLines[$i], ";", 2)
        If UBound($aVals) = 0 Then $aVals = StringSplit($aLines[$i], ",", 2)

        Local $sInsert = "INSERT INTO " & $sTable & " VALUES ("
        For $j = 0 To UBound($aVals) - 1
            If $j > 0 Then $sInsert &= ", "
            $sInsert &= "'" & StringReplace(StringStripWS($aVals[$j], 3), "'", "''") & "'"
        Next
        $sInsert &= ");"

        _SQLite_Exec(-1, $sInsert)
        If Not @error Then $iInserted += 1
    Next

    _RefreshSchema()
    _ShowMessage($iInserted & " Zeilen in Tabelle '" & $sTable & "' importiert!")
EndFunc

Func _ImportJSON($sContent)
    ; Einfacher JSON-Array Parser ([ {}, {} ])
    _ShowMessage("JSON Import in Entwicklung - nutze CSV fuer jetzt")
EndFunc

; SQL Dump Export
Func _DoDump()
    If Not $g_sDB Then
        _ShowError("Keine Datenbank geoeffnet!")
        Return
    EndIf

    Local $sFile = FileSaveDialog("SQL Dump Export", @ScriptDir, "SQL (*.sql)", 18, "dump.sql", $hGUI)
    If @error Then Return
    If Not StringRegExp($sFile, "\.sql$") Then $sFile &= ".sql"

    Local $sDump = "-- SQLite Dump generated by SQLite Manager Pro" & @CRLF
    $sDump &= "-- Database: " & $g_sDB & @CRLF
    $sDump &= "-- Date: " & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & @CRLF
    $sDump &= "PRAGMA foreign_keys=OFF;" & @CRLF
    $sDump &= "BEGIN TRANSACTION;" & @CRLF & @CRLF

    ; Alle Tabellen holen
    Local $aResult, $iRows, $iCols
    _SQLite_GetTable2d(-1, "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;", $aResult, $iRows, $iCols)

    For $i = 1 To $iRows
        Local $sTable = $aResult[$i][0]
        Local $sCreateSQL = $aResult[$i][1]

        ; CREATE TABLE
        $sDump &= "-- Table: " & $sTable & @CRLF
        $sDump &= $sCreateSQL & ";" & @CRLF

        ; INSERT Statements
        Local $aData, $iDataRows, $iDataCols
        _SQLite_GetTable2d(-1, "SELECT * FROM """ & $sTable & """;", $aData, $iDataRows, $iDataCols)

        For $j = 1 To $iDataRows
            $sDump &= "INSERT INTO """ & $sTable & """ VALUES ("
            For $k = 0 To $iDataCols - 1
                If $k > 0 Then $sDump &= ", "
                If $aData[$j][$k] = "" Then
                    $sDump &= "NULL"
                Else
                    $sDump &= "'" & StringReplace($aData[$j][$k], "'", "''") & "'"
                EndIf
            Next
            $sDump &= ");" & @CRLF
        Next
        $sDump &= @CRLF
    Next

    ; Views
    _SQLite_GetTable2d(-1, "SELECT name, sql FROM sqlite_master WHERE type='view' ORDER BY name;", $aResult, $iRows, $iCols)
    For $i = 1 To $iRows
        $sDump &= "-- View: " & $aResult[$i][0] & @CRLF
        $sDump &= $aResult[$i][1] & ";" & @CRLF & @CRLF
    Next

    ; Indizes
    _SQLite_GetTable2d(-1, "SELECT name, sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL ORDER BY name;", $aResult, $iRows, $iCols)
    For $i = 1 To $iRows
        $sDump &= "-- Index: " & $aResult[$i][0] & @CRLF
        $sDump &= $aResult[$i][1] & ";" & @CRLF
    Next

    $sDump &= @CRLF & "COMMIT;" & @CRLF

    FileWrite(FileOpen($sFile, 2 + 128), $sDump)
    _ShowMessage("SQL Dump exportiert: " & StringRegExpReplace($sFile, ".*\\", ""))
EndFunc

; Query Templates
Func _DoShowTemplates()
    _UpdateJS("showTemplates", "")
EndFunc

; Theme Toggle
Func _DoToggleTheme()
    $g_bDarkTheme = Not $g_bDarkTheme
    If $g_bDarkTheme Then
        _UpdateJS("setTheme", '"dark"')
    Else
        _UpdateJS("setTheme", '"light"')
    EndIf
EndFunc

; ============================================================
; UI Laden - Externe Dateien mit Platzhaltern
; ============================================================
Func _LoadUI()
    ; Externe Dateien laden
    Local $sUIPath = @ScriptDir & "\ui\"
    Local $sHTML = FileRead($sUIPath & "template.html")
    Local $sCSS = FileRead($sUIPath & "styles.css")
    Local $sJS = FileRead($sUIPath & "scripts.js")

    ; Fallback wenn externe Dateien fehlen
    If $sHTML = "" Or @error Then
        ConsoleWrite("[UI] Externe Dateien nicht gefunden, verwende Fallback..." & @CRLF)
        Return _BuildHTML_Fallback()
    EndIf

    ; Platzhalter ersetzen
    $sHTML = StringReplace($sHTML, "{{CSS}}", $sCSS)
    $sHTML = StringReplace($sHTML, "{{JS}}", $sJS)

    ConsoleWrite("[UI] Externe UI-Dateien geladen" & @CRLF)
    Return $sHTML
EndFunc

; Fallback falls externe Dateien fehlen
Func _BuildHTML_Fallback()
    Return '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>' & _BuildCSS() & '</style></head><body>' & _
        '<div class="layout" id="layout">' & _
        '<aside class="sidebar" id="sidebar">' & _
        '<div class="sb-header"><span class="sb-title">SCHEMA</span><button class="sb-refresh" onclick="requestRefresh()" title="Refresh">&#8635;</button></div>' & _
        '<div class="sb-search"><input type="text" id="schemaSearch" placeholder="Suchen..." oninput="filterSchema()"></div>' & _
        '<div class="sb-content" id="schema"><div class="empty">Keine Datenbank</div></div>' & _
        '</aside>' & _
        '<div class="resizer" id="resizerLeft" onmousedown="startResize(event,' & $Q & 'left' & $Q & ')"></div>' & _
        '<main class="main">' & _
        '<div class="editor-wrap">' & _
        '<div class="editor-header"><span>SQL Editor</span><div class="editor-actions">' & _
        '<button onclick="formatSQL()" title="Format SQL">Format</button>' & _
        '<button onclick="clearEditor()" title="Clear">Clear</button></div></div>' & _
        '<div class="editor-container">' & _
        '<div class="line-numbers" id="lineNumbers">1</div>' & _
        '<div class="editor-area"><pre id="highlight" class="highlight"></pre>' & _
        '<textarea id="sql" spellcheck="false" oninput="onSQLInput()" onkeydown="onKeyDown(event)" onscroll="syncScroll()">SELECT * FROM sqlite_master;</textarea></div>' & _
        '<div class="autocomplete" id="autocomplete"></div></div></div>' & _
        '<div class="h-resizer" id="resizerH" onmousedown="startResizeH(event)"></div>' & _
        '<div class="output" id="output"><div class="empty">Datenbank oeffnen und Query ausfuehren (F5)</div></div>' & _
        '</main>' & _
        '<div class="resizer" id="resizerRight" onmousedown="startResize(event,' & $Q & 'right' & $Q & ')" style="display:none"></div>' & _
        '<aside class="info-panel" id="infoPanel">' & _
        '<div class="ip-header"><span id="ipTitle">Tabellen-Info</span><button onclick="closeInfoPanel()">&#10005;</button></div>' & _
        '<div class="ip-content" id="ipContent"></div>' & _
        '</aside></div>' & _
        '<div class="modal" id="wizardModal"><div class="modal-content">' & _
        '<div class="modal-header"><span>Query Wizard</span><button onclick="closeWizard()">&#10005;</button></div>' & _
        '<div class="modal-body" id="wizardBody"></div>' & _
        '<div class="modal-footer"><button class="btn-primary" onclick="applyWizard()">Query uebernehmen</button>' & _
        '<button onclick="closeWizard()">Abbrechen</button></div></div></div>' & _
        '<div class="modal" id="historyModal"><div class="modal-content modal-lg">' & _
        '<div class="modal-header"><span>Query Historie</span><button onclick="closeHistory()">&#10005;</button></div>' & _
        '<div class="modal-body" id="historyBody"></div></div></div>' & _
        '<div class="toast" id="toast"></div>' & _
        '<script>' & _BuildJS() & '</script></body></html>'
EndFunc

Func _BuildCSS()
    Return _
        ':root{--bg:#0d1117;--bg2:#161b22;--bg3:#21262d;--border:#30363d;--text:#c9d1d9;--text2:#8b949e;--accent:#58a6ff;--green:#3fb950;--red:#f85149;--purple:#a371f7;--yellow:#d29922;--orange:#db6d28}' & _
        '*{box-sizing:border-box;margin:0;padding:0}' & _
        'body{font-family:Segoe UI,sans-serif;background:var(--bg);color:var(--text);height:100vh;overflow:hidden}' & _
        '.layout{display:grid;grid-template-columns:var(--sidebar-w,260px) 6px 1fr 0;height:100vh}' & _
        '.layout.info-open{grid-template-columns:var(--sidebar-w,260px) 6px 1fr 6px var(--info-w,320px)}' & _
        '.resizer{background:var(--border);cursor:col-resize;transition:background .2s}' & _
        '.resizer:hover,.resizer.active{background:var(--accent)}' & _
        '.sidebar{background:var(--bg2);border-right:1px solid var(--border);display:flex;flex-direction:column;overflow:hidden}' & _
        '.sb-header{padding:12px 16px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center}' & _
        '.sb-title{font-size:11px;font-weight:600;letter-spacing:1px;color:var(--text2)}' & _
        '.sb-refresh{background:none;border:none;color:var(--text2);font-size:16px;cursor:pointer;padding:4px;border-radius:4px}' & _
        '.sb-refresh:hover{background:var(--bg3);color:var(--text)}' & _
        '.sb-search{padding:8px 12px}' & _
        '.sb-search input{width:100%;padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px}' & _
        '.sb-search input:focus{border-color:var(--accent);outline:none}' & _
        '.sb-content{flex:1;overflow-y:auto;padding:8px}' & _
        '.table-item{margin-bottom:2px}' & _
        '.table-header{padding:8px 12px;cursor:pointer;border-radius:6px;display:flex;align-items:center;gap:8px;transition:background .15s}' & _
        '.table-header:hover{background:var(--bg3)}' & _
        '.table-header.active{background:var(--bg3)}' & _
        '.table-icon{width:20px;height:20px;border-radius:4px;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700}' & _
        '.table-icon.t{background:var(--green);color:#fff}' & _
        '.table-icon.v{background:var(--purple);color:#fff}' & _
        '.table-name{flex:1;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}' & _
        '.table-actions{opacity:0;display:flex;gap:4px;transition:opacity .15s}' & _
        '.table-header:hover .table-actions{opacity:1}' & _
        '.table-actions button{background:none;border:none;color:var(--text2);font-size:12px;cursor:pointer;padding:2px 6px;border-radius:4px}' & _
        '.table-actions button:hover{background:var(--bg);color:var(--text)}' & _
        '.table-cols{max-height:0;overflow:hidden;transition:max-height .3s}' & _
        '.table-cols.open{max-height:500px}' & _
        '.col-item{padding:4px 12px 4px 44px;font-size:12px;color:var(--text2);display:flex;align-items:center;gap:6px;cursor:pointer;border-radius:4px}' & _
        '.col-item:hover{background:var(--bg3);color:var(--text)}' & _
        '.col-type{font-size:10px;padding:2px 6px;background:var(--bg3);border-radius:3px;color:var(--text2)}' & _
        '.col-pk{color:var(--yellow)}' & _
        '.col-fk{color:var(--purple)}' & _
        '.main{display:flex;flex-direction:column;overflow:hidden}' & _
        '.editor-wrap{border-bottom:1px solid var(--border);min-height:100px;height:var(--editor-h,200px)}' & _
        '.h-resizer{height:6px;background:var(--border);cursor:row-resize;transition:background .2s}' & _
        '.h-resizer:hover,.h-resizer.active{background:var(--accent)}' & _
        '.editor-header{padding:8px 16px;background:var(--bg2);display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border)}' & _
        '.editor-header span{font-size:12px;font-weight:600;color:var(--text2)}' & _
        '.editor-actions{display:flex;gap:8px}' & _
        '.editor-actions button{padding:4px 12px;background:var(--bg3);border:1px solid var(--border);border-radius:4px;color:var(--text);font-size:12px;cursor:pointer}' & _
        '.editor-actions button:hover{background:var(--bg);border-color:var(--accent)}' & _
        '.editor-container{position:relative;display:flex;height:180px}' & _
        '.line-numbers{width:40px;padding:12px 8px;background:var(--bg2);color:var(--text2);font-family:Consolas,monospace;font-size:13px;line-height:1.5;text-align:right;user-select:none;border-right:1px solid var(--border);overflow:hidden}' & _
        '.editor-area{flex:1;position:relative;overflow:hidden}' & _
        '#sql,.highlight{position:absolute;top:0;left:0;width:100%;height:100%;padding:12px;font-family:Consolas,monospace;font-size:13px;line-height:1.5;white-space:pre-wrap;word-wrap:break-word;overflow:auto}' & _
        '#sql{background:transparent;color:transparent;caret-color:var(--text);border:none;resize:none;z-index:2}' & _
        '#sql:focus{outline:none}' & _
        '.highlight{background:var(--bg);color:var(--text);z-index:1;pointer-events:none}' & _
        '.hl-keyword{color:#0000ff;font-weight:600}' & _
        '.hl-function{color:#ff00ff}' & _
        '.hl-string{color:#a31515}' & _
        '.hl-number{color:#098658}' & _
        '.hl-comment{color:#008000;font-style:italic}' & _
        '.hl-operator{color:#666666}' & _
        '.hl-table{color:#2e7d32}' & _
        '.hl-column{color:#795548}' & _
        '.autocomplete{position:absolute;top:100%;left:50px;width:300px;max-height:200px;background:var(--bg2);border:1px solid var(--border);border-radius:6px;overflow:auto;display:none;z-index:100;box-shadow:0 8px 24px rgba(0,0,0,.4)}' & _
        '.ac-item{padding:8px 12px;cursor:pointer;display:flex;align-items:center;gap:8px}' & _
        '.ac-item:hover,.ac-item.selected{background:var(--bg3)}' & _
        '.ac-icon{font-size:10px;padding:2px 6px;border-radius:3px;font-weight:600}' & _
        '.ac-icon.kw{background:#6e40c9;color:#fff}' & _
        '.ac-icon.tb{background:var(--green);color:#fff}' & _
        '.ac-icon.cl{background:var(--orange);color:#fff}' & _
        '.ac-icon.fn{background:var(--purple);color:#fff}' & _
        '.ac-text{flex:1}' & _
        '.ac-hint{font-size:11px;color:var(--text2)}' & _
        '.output{flex:1;overflow:auto;padding:16px}' & _
        '.empty{padding:40px;text-align:center;color:var(--text2)}' & _
        '.msg{padding:16px;text-align:center;color:var(--green);animation:fadeIn .3s}' & _
        '.err{padding:16px;background:rgba(248,81,73,.1);border-left:3px solid var(--red);color:var(--red);animation:shake .3s}' & _
        '@keyframes fadeIn{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:translateY(0)}}' & _
        '@keyframes shake{0%,100%{transform:translateX(0)}25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}' & _
        'table{width:100%;border-collapse:collapse}' & _
        'th{background:var(--bg2);padding:10px 14px;text-align:left;font-size:11px;font-weight:600;color:var(--text2);text-transform:uppercase;position:sticky;top:0;border-bottom:2px solid var(--border)}' & _
        'td{padding:10px 14px;border-bottom:1px solid var(--bg3);font-family:Consolas,monospace;font-size:13px}' & _
        'tr:hover td{background:var(--bg2)}' & _
        '.null{color:var(--text2);font-style:italic}' & _
        '.result-stats{padding:12px;text-align:center;color:var(--text2);font-size:13px;border-top:1px solid var(--border)}' & _
        '.info-panel{background:var(--bg2);border-left:1px solid var(--border);overflow:hidden;display:flex;flex-direction:column}' & _
        '.ip-header{padding:12px 16px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center}' & _
        '.ip-header span{font-weight:600}' & _
        '.ip-header button{background:none;border:none;color:var(--text2);font-size:16px;cursor:pointer}' & _
        '.ip-content{flex:1;overflow-y:auto;padding:16px}' & _
        '.ip-section{margin-bottom:20px}' & _
        '.ip-section h4{font-size:11px;font-weight:600;color:var(--text2);text-transform:uppercase;margin-bottom:8px}' & _
        '.ip-row{padding:6px 0;font-size:13px;display:flex;justify-content:space-between}' & _
        '.ip-label{color:var(--text2)}' & _
        '.modal{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:1000}' & _
        '.modal.open{display:flex}' & _
        '.modal-content{background:var(--bg2);border:1px solid var(--border);border-radius:12px;width:600px;max-height:80vh;display:flex;flex-direction:column;animation:modalIn .2s}' & _
        '.modal-content.modal-lg{width:800px}' & _
        '@keyframes modalIn{from{opacity:0;transform:scale(.95)}to{opacity:1;transform:scale(1)}}' & _
        '.modal-header{padding:16px 20px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center}' & _
        '.modal-header span{font-size:16px;font-weight:600}' & _
        '.modal-header button{background:none;border:none;color:var(--text2);font-size:20px;cursor:pointer}' & _
        '.modal-body{flex:1;overflow-y:auto;padding:20px}' & _
        '.modal-footer{padding:16px 20px;border-top:1px solid var(--border);display:flex;justify-content:flex-end;gap:12px}' & _
        '.btn-primary{padding:8px 20px;background:var(--accent);border:none;border-radius:6px;color:#fff;font-weight:600;cursor:pointer}' & _
        '.btn-primary:hover{background:#4c9aed}' & _
        'button{padding:8px 16px;background:var(--bg3);border:1px solid var(--border);border-radius:6px;color:var(--text);cursor:pointer}' & _
        'button:hover{border-color:var(--accent)}' & _
        '.wizard-tabs{display:flex;gap:8px;margin-bottom:20px;border-bottom:1px solid var(--border);padding-bottom:12px}' & _
        '.wizard-tab{padding:8px 16px;border-radius:6px;cursor:pointer;font-size:13px}' & _
        '.wizard-tab:hover{background:var(--bg3)}' & _
        '.wizard-tab.active{background:var(--accent);color:#fff}' & _
        '.wizard-section{margin-bottom:16px}' & _
        '.wizard-section label{display:block;font-size:12px;color:var(--text2);margin-bottom:6px}' & _
        '.wizard-section select,.wizard-section input{width:100%;padding:10px 12px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px}' & _
        '.wizard-section select:focus,.wizard-section input:focus{border-color:var(--accent);outline:none}' & _
        '.wizard-row{display:grid;grid-template-columns:1fr 1fr;gap:16px}' & _
        '.wizard-preview{background:var(--bg);border:1px solid var(--border);border-radius:6px;padding:12px;font-family:Consolas,monospace;font-size:12px;white-space:pre-wrap;max-height:150px;overflow:auto}' & _
        '.history-item{padding:12px;border:1px solid var(--border);border-radius:6px;margin-bottom:8px;cursor:pointer;font-family:Consolas,monospace;font-size:12px;white-space:pre-wrap;max-height:80px;overflow:hidden}' & _
        '.history-item:hover{border-color:var(--accent);background:var(--bg3)}' & _
        '.toast{position:fixed;bottom:20px;left:50%;transform:translateX(-50%);padding:12px 24px;background:var(--bg2);border:1px solid var(--border);border-radius:8px;color:var(--text);display:none;animation:toastIn .3s}' & _
        '.toast.show{display:block}' & _
        '@keyframes toastIn{from{opacity:0;transform:translateX(-50%) translateY(20px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}' & _
        '.explain-wrap{padding:20px}' & _
        '.explain-tree{background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:16px}' & _
        '.explain-node{padding:8px;margin:4px 0;display:flex;align-items:center;gap:12px}' & _
        '.explain-id{background:var(--accent);color:#fff;padding:4px 10px;border-radius:4px;font-size:12px;font-weight:600}' & _
        '.explain-detail{font-family:Consolas,monospace;font-size:13px;color:var(--text)}' & _
        '.templates-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;padding:16px}' & _
        '.template-item{background:var(--bg2);border:1px solid var(--border);border-radius:8px;padding:16px;cursor:pointer;transition:all .2s}' & _
        '.template-item:hover{border-color:var(--accent);transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,.2)}' & _
        '.template-name{font-weight:600;margin-bottom:8px;color:var(--accent)}' & _
        '.template-sql{font-family:Consolas,monospace;font-size:11px;color:var(--text2);white-space:pre-wrap;max-height:60px;overflow:hidden}'
EndFunc

Func _BuildJS()
    Return _
        'var D=null,schema=[],acItems=[],acIndex=-1;' & _
        'var KEYWORDS=["SELECT","FROM","WHERE","AND","OR","NOT","IN","LIKE","BETWEEN","IS","NULL","AS","ON","JOIN","LEFT","RIGHT","INNER","OUTER","CROSS","FULL","NATURAL","USING","GROUP","BY","HAVING","ORDER","ASC","DESC","LIMIT","OFFSET","UNION","ALL","INTERSECT","EXCEPT","INSERT","INTO","VALUES","UPDATE","SET","DELETE","CREATE","TABLE","VIEW","INDEX","UNIQUE","PRIMARY","KEY","FOREIGN","REFERENCES","DROP","ALTER","ADD","COLUMN","RENAME","TO","IF","EXISTS","CASE","WHEN","THEN","ELSE","END","DISTINCT","COUNT","SUM","AVG","MIN","MAX","COALESCE","NULLIF","CAST","SUBSTR","LENGTH","UPPER","LOWER","TRIM","REPLACE","INSTR","ABS","ROUND","DATE","TIME","DATETIME","STRFTIME"];' & _
        'var FUNCTIONS=["COUNT","SUM","AVG","MIN","MAX","COALESCE","NULLIF","CAST","SUBSTR","LENGTH","UPPER","LOWER","TRIM","REPLACE","INSTR","ABS","ROUND","DATE","TIME","DATETIME","STRFTIME","TYPEOF","IFNULL","IIF","PRINTF","RANDOM","TOTAL","GROUP_CONCAT","HEX","QUOTE","ZEROBLOB"];' & _
        'function getSQL(){return document.getElementById("sql").value}' & _
        'function hasData(){return D&&D.r&&D.r.length>0}' & _
        'function getCSV(){if(!D)return"";var s=D.c.join(";")+"\n";for(var i=0;i<D.r.length;i++)s+=D.r[i].join(";")+"\n";return s}' & _
        'function setSchema(a){schema=a||[];renderSchema();updateAutocomplete()}' & _
        'function renderSchema(){var e=document.getElementById("schema"),f=document.getElementById("schemaSearch").value.toLowerCase();' & _
        'if(!schema.length){e.innerHTML="<div class=empty>Keine Tabellen</div>";return}' & _
        'var h="";schema.forEach(function(t){if(f&&t.n.toLowerCase().indexOf(f)<0)return;' & _
        'h+="<div class=table-item><div class=table-header onclick=toggleTable(this) data-name=\""+t.n+"\">";' & _
        'h+="<span class=\"table-icon "+(t.t==="table"?"t":"v")+"\">"+(t.t==="table"?"T":"V")+"</span>";' & _
        'h+="<span class=table-name>"+t.n+"</span>";' & _
        'h+="<div class=table-actions><button onclick=\"event.stopPropagation();selectTable(" & $Q & "+" & $Q & "+t.n+" & $Q & "+" & $Q & ")\">SELECT</button>";' & _
        'h+="<button onclick=\"event.stopPropagation();showTableInfo(" & $Q & "+" & $Q & "+t.n+" & $Q & "+" & $Q & ")\">Info</button></div></div>";' & _
        'h+="<div class=table-cols id=\"cols_"+t.n+"\">";' & _
        't.cols.forEach(function(c){h+="<div class=col-item onclick=\"insertColumn(" & $Q & "+" & $Q & "+c.n+" & $Q & "+" & $Q & ")\">"+(c.pk?"<span class=col-pk>PK</span>":"")+"<span>"+c.n+"</span><span class=col-type>"+c.t+"</span></div>"});' & _
        'h+="</div></div>"});e.innerHTML=h}' & _
        'function filterSchema(){renderSchema()}' & _
        'function toggleTable(el){var cols=document.getElementById("cols_"+el.dataset.name);' & _
        'document.querySelectorAll(".table-cols").forEach(function(c){if(c!==cols)c.classList.remove("open")});' & _
        'document.querySelectorAll(".table-header").forEach(function(h){if(h!==el)h.classList.remove("active")});' & _
        'cols.classList.toggle("open");el.classList.toggle("active")}' & _
        'function selectTable(n){document.getElementById("sql").value="SELECT * FROM "+n+" LIMIT 100;";onSQLInput()}' & _
        'function insertColumn(n){var ta=document.getElementById("sql"),p=ta.selectionStart;var v=ta.value;ta.value=v.slice(0,p)+n+v.slice(p);ta.selectionStart=ta.selectionEnd=p+n.length;ta.focus();onSQLInput()}' & _
        'function showTableInfo(n){var t=schema.find(function(x){return x.n===n});if(!t)return;' & _
        'var h="<div class=ip-section><h4>Spalten</h4>";t.cols.forEach(function(c){h+="<div class=ip-row><span>"+c.n+(c.pk?" <span class=col-pk>PK</span>":"")+(c.nn?" NOT NULL":"")+"</span><span class=col-type>"+c.t+"</span></div>"});h+="</div>";' & _
        'if(t.fk.length){h+="<div class=ip-section><h4>Foreign Keys</h4>";t.fk.forEach(function(f){h+="<div class=ip-row><span>"+f.from+"</span><span class=col-fk>"+f.to+"</span></div>"});h+="</div>"}' & _
        'if(t.idx.length){h+="<div class=ip-section><h4>Indizes</h4>";t.idx.forEach(function(i){h+="<div class=ip-row><span>"+i.n+"</span><span>"+(i.u?"UNIQUE":"")+"</span></div>"});h+="</div>"}' & _
        'document.getElementById("ipTitle").textContent=n;document.getElementById("ipContent").innerHTML=h;' & _
        'document.querySelector(".layout").classList.add("info-open")}' & _
        'function closeInfoPanel(){document.querySelector(".layout").classList.remove("info-open")}' & _
        'function onSQLInput(){highlightSQL();updateLineNumbers();checkAutocomplete()}' & _
        'function highlightSQL(){var sql=document.getElementById("sql").value;var h=esc(sql);' & _
        'h=h.replace(/--.*$/gm,"<span class=hl-comment>$&</span>");' & _
        'h=h.replace(/(' & $Q & '[^' & $Q & ']*' & $Q & '|"[^"]*")/g,"<span class=hl-string>$&</span>");' & _
        'h=h.replace(/\b(\d+\.?\d*)\b/g,"<span class=hl-number>$1</span>");' & _
        'var kwRe=new RegExp("\\\\b("+KEYWORDS.join("|")+")\\\\b","gi");h=h.replace(kwRe,"<span class=hl-keyword>$1</span>");' & _
        'var fnRe=new RegExp("\\\\b("+FUNCTIONS.join("|")+")\\\\s*\\\\(","gi");h=h.replace(fnRe,"<span class=hl-function>$1</span>(");' & _
        'schema.forEach(function(t){var re=new RegExp("\\\\b"+t.n+"\\\\b","gi");h=h.replace(re,"<span class=hl-table>"+t.n+"</span>")});' & _
        'document.getElementById("highlight").innerHTML=h}' & _
        'function updateLineNumbers(){var sql=document.getElementById("sql").value;var lines=sql.split("\n").length;var nums="";for(var i=1;i<=lines;i++)nums+=i+"\n";document.getElementById("lineNumbers").textContent=nums}' & _
        'function syncScroll(){var ta=document.getElementById("sql");document.getElementById("highlight").scrollTop=ta.scrollTop;document.getElementById("highlight").scrollLeft=ta.scrollLeft;document.getElementById("lineNumbers").scrollTop=ta.scrollTop}' & _
        'function checkAutocomplete(){var ta=document.getElementById("sql"),p=ta.selectionStart,v=ta.value;' & _
        'var before=v.slice(0,p),match=before.match(/[a-zA-Z_]\w*$/);if(!match){hideAC();return}' & _
        'var word=match[0].toUpperCase();acItems=[];' & _
        'KEYWORDS.forEach(function(k){if(k.indexOf(word)===0)acItems.push({t:"kw",n:k,h:"Keyword"})});' & _
        'FUNCTIONS.forEach(function(f){if(f.indexOf(word)===0&&!acItems.find(function(x){return x.n===f}))acItems.push({t:"fn",n:f,h:"Function"})});' & _
        'schema.forEach(function(tb){if(tb.n.toUpperCase().indexOf(word)===0)acItems.push({t:"tb",n:tb.n,h:"Table"});' & _
        'tb.cols.forEach(function(c){if(c.n.toUpperCase().indexOf(word)===0)acItems.push({t:"cl",n:c.n,h:tb.n+"."+c.t})})});' & _
        'if(acItems.length===0||acItems.length===1&&acItems[0].n.toUpperCase()===word){hideAC();return}' & _
        'acIndex=0;showAC()}' & _
        'function showAC(){var ac=document.getElementById("autocomplete"),h="";acItems.slice(0,10).forEach(function(it,i){' & _
        'h+="<div class=\"ac-item"+(i===acIndex?" selected":"")+"\" onclick=\"selectAC("+i+")\"><span class=\"ac-icon "+it.t+"\">"+it.t.toUpperCase()+"</span><span class=ac-text>"+it.n+"</span><span class=ac-hint>"+it.h+"</span></div>"});' & _
        'ac.innerHTML=h;ac.style.display="block"}' & _
        'function hideAC(){document.getElementById("autocomplete").style.display="none";acIndex=-1}' & _
        'function selectAC(i){var it=acItems[i];if(!it)return;' & _
        'var ta=document.getElementById("sql"),p=ta.selectionStart,v=ta.value;' & _
        'var before=v.slice(0,p),after=v.slice(p),match=before.match(/[a-zA-Z_]\w*$/);' & _
        'if(match){before=before.slice(0,-match[0].length)}' & _
        'ta.value=before+it.n+after;ta.selectionStart=ta.selectionEnd=before.length+it.n.length;ta.focus();onSQLInput();hideAC()}' & _
        'function onKeyDown(e){var ac=document.getElementById("autocomplete");if(ac.style.display==="block"){' & _
        'if(e.key==="ArrowDown"){e.preventDefault();acIndex=Math.min(acIndex+1,acItems.length-1);showAC()}' & _
        'else if(e.key==="ArrowUp"){e.preventDefault();acIndex=Math.max(acIndex-1,0);showAC()}' & _
        'else if(e.key==="Enter"||e.key==="Tab"){if(acIndex>=0){e.preventDefault();selectAC(acIndex)}}' & _
        'else if(e.key==="Escape"){hideAC()}}}' & _
        'function updateAutocomplete(){}' & _
        'function setResults(d){D=d;var e=document.getElementById("output");var h="<table><tr>";' & _
        'for(var i=0;i<d.c.length;i++)h+="<th>"+esc(d.c[i])+"</th>";h+="</tr>";' & _
        'for(var i=0;i<d.r.length;i++){h+="<tr>";for(var j=0;j<d.r[i].length;j++){var v=d.r[i][j];h+=v===""?"<td class=null>NULL</td>":"<td>"+esc(v)+"</td>"}h+="</tr>"}' & _
        'e.innerHTML=h+"</table><div class=result-stats>"+d.n+" Zeilen in "+d.t+" ms</div>"}' & _
        'function setMsg(m){D=null;document.getElementById("output").innerHTML="<div class=msg>"+esc(m)+"</div>"}' & _
        'function setErr(m){D=null;document.getElementById("output").innerHTML="<div class=err>"+esc(m)+"</div>"}' & _
        'function esc(s){if(s==null)return"";return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")}' & _
        'function formatSQL(){var ta=document.getElementById("sql"),sql=ta.value;' & _
        'sql=sql.replace(/\s+/g," ").trim();' & _
        'var kws=["SELECT","FROM","WHERE","AND","OR","ORDER BY","GROUP BY","HAVING","LIMIT","OFFSET","JOIN","LEFT JOIN","RIGHT JOIN","INNER JOIN","ON","SET","VALUES","INTO"];' & _
        'kws.forEach(function(k){sql=sql.replace(new RegExp("\\\\s*\\\\b"+k+"\\\\b\\\\s*","gi"),"\\n"+k+" ")});' & _
        'sql=sql.trim();ta.value=sql;onSQLInput()}' & _
        'function clearEditor(){document.getElementById("sql").value="";onSQLInput()}' & _
        'function requestRefresh(){toast("Schema wird aktualisiert...")}' & _
        'function showWizard(){document.getElementById("wizardModal").classList.add("open");renderWizard()}' & _
        'function closeWizard(){document.getElementById("wizardModal").classList.remove("open")}' & _
        'var wizardType="select";' & _
        'function renderWizard(){var h="<div class=wizard-tabs>";' & _
        '["select","join","insert","update","delete"].forEach(function(t){h+="<div class=\"wizard-tab"+(t===wizardType?" active":"")+"\" onclick=\"setWizardType(" & $Q & "+" & $Q & "+t+" & $Q & "+" & $Q & ")\">"+t.toUpperCase()+"</div>"});' & _
        'h+="</div><div id=wizardForm></div><div class=wizard-section><label>Vorschau</label><div class=wizard-preview id=wizardPreview></div></div>";' & _
        'document.getElementById("wizardBody").innerHTML=h;renderWizardForm()}' & _
        'function setWizardType(t){wizardType=t;renderWizard()}' & _
        'function renderWizardForm(){var f=document.getElementById("wizardForm"),tbOpts="<option value=\"\">Tabelle waehlen...</option>";' & _
        'schema.filter(function(t){return t.t==="table"}).forEach(function(t){tbOpts+="<option value=\""+t.n+"\">"+t.n+"</option>"});' & _
        'var h="";' & _
        'if(wizardType==="select"){h="<div class=wizard-row><div class=wizard-section><label>Tabelle</label><select id=wTable onchange=updateWizardPreview()>"+tbOpts+"</select></div><div class=wizard-section><label>Spalten (* fuer alle)</label><input id=wCols value=* oninput=updateWizardPreview()></div></div><div class=wizard-row><div class=wizard-section><label>WHERE</label><input id=wWhere oninput=updateWizardPreview()></div><div class=wizard-section><label>ORDER BY</label><input id=wOrder oninput=updateWizardPreview()></div></div><div class=wizard-row><div class=wizard-section><label>LIMIT</label><input id=wLimit type=number value=100 oninput=updateWizardPreview()></div><div class=wizard-section><label>OFFSET</label><input id=wOffset type=number value=0 oninput=updateWizardPreview()></div></div>"}' & _
        'else if(wizardType==="join"){h="<div class=wizard-row><div class=wizard-section><label>Tabelle 1</label><select id=wTable1 onchange=autoDetectJoin()>"+tbOpts+"</select></div><div class=wizard-section><label>Tabelle 2</label><select id=wTable2 onchange=autoDetectJoin()>"+tbOpts+"</select></div></div><div id=joinHint style=padding:8px></div><div class=wizard-row><div class=wizard-section><label>JOIN Typ</label><select id=wJoinType onchange=updateWizardPreview()><option>INNER JOIN</option><option>LEFT JOIN</option><option>RIGHT JOIN</option></select></div><div class=wizard-section><label>ON</label><input id=wJoinOn oninput=updateWizardPreview()></div></div><div class=wizard-section><label>Spalten</label><input id=wJoinCols value=* oninput=updateWizardPreview()></div>"}' & _
        'else if(wizardType==="insert"){h="<div class=wizard-section><label>Tabelle</label><select id=wTable onchange=updateInsertCols();updateWizardPreview()>"+tbOpts+"</select></div><div class=wizard-section><label>Spalten</label><input id=wInsCols readonly></div><div class=wizard-section><label>Werte</label><input id=wInsVals oninput=updateWizardPreview()></div>"}' & _
        'else if(wizardType==="update"){h="<div class=wizard-section><label>Tabelle</label><select id=wTable onchange=updateWizardPreview()>"+tbOpts+"</select></div><div class=wizard-section><label>SET</label><input id=wUpdSet oninput=updateWizardPreview()></div><div class=wizard-section><label>WHERE</label><input id=wUpdWhere oninput=updateWizardPreview()></div>"}' & _
        'else if(wizardType==="delete"){h="<div class=wizard-section><label>Tabelle</label><select id=wTable onchange=updateWizardPreview()>"+tbOpts+"</select></div><div class=wizard-section><label>WHERE (PFLICHT!)</label><input id=wDelWhere oninput=updateWizardPreview()></div>"}' & _
        'f.innerHTML=h;updateWizardPreview()}' & _
        'function updateInsertCols(){var t=document.getElementById("wTable").value;if(!t)return;' & _
        'var tb=schema.find(function(x){return x.n===t});if(!tb)return;' & _
        'document.getElementById("wInsCols").value=tb.cols.map(function(c){return c.n}).join(", ")}' & _
        'function updateWizardPreview(){var sql="";' & _
        'if(wizardType==="select"){var t=gv("wTable"),c=gv("wCols")||"*",w=gv("wWhere"),o=gv("wOrder"),l=gv("wLimit"),off=gv("wOffset");' & _
        'if(t){sql="SELECT "+c+" FROM "+t;if(w)sql+=" WHERE "+w;if(o)sql+=" ORDER BY "+o;if(l)sql+=" LIMIT "+l;if(off&&off!=="0")sql+=" OFFSET "+off}}' & _
        'else if(wizardType==="join"){var t1=gv("wTable1"),t2=gv("wTable2"),jt=gv("wJoinType"),jo=gv("wJoinOn"),jc=gv("wJoinCols")||"*";' & _
        'if(t1&&t2){var order=getTableOrder(t1,t2);sql="SELECT "+jc+" FROM "+order.main+" "+jt+" "+order.join;if(jo)sql+=" ON "+jo}}' & _
        'else if(wizardType==="insert"){var t=gv("wTable"),c=gv("wInsCols"),v=gv("wInsVals");' & _
        'if(t&&v){sql="INSERT INTO "+t;if(c)sql+=" ("+c+")";sql+=" VALUES ("+v+")"}}' & _
        'else if(wizardType==="update"){var t=gv("wTable"),s=gv("wUpdSet"),w=gv("wUpdWhere");' & _
        'if(t&&s){sql="UPDATE "+t+" SET "+s;if(w)sql+=" WHERE "+w}}' & _
        'else if(wizardType==="delete"){var t=gv("wTable"),w=gv("wDelWhere");' & _
        'if(t&&w){sql="DELETE FROM "+t+" WHERE "+w}}' & _
        'document.getElementById("wizardPreview").textContent=sql||"(Bitte Felder ausfuellen)"}' & _
        'function gv(id){var e=document.getElementById(id);return e?e.value.trim():""}' & _
        'function applyWizard(){var sql=document.getElementById("wizardPreview").textContent;' & _
        'if(sql&&!sql.startsWith("(")){document.getElementById("sql").value=sql+";";onSQLInput();closeWizard()}}' & _
        'function showHistory(arr){var h="";arr.forEach(function(sql,i){h+="<div class=history-item onclick=\"useHistory("+i+")\">"+esc(sql)+"</div>"});' & _
        'document.getElementById("historyBody").innerHTML=h;document.getElementById("historyModal").classList.add("open");window._histArr=arr}' & _
        'function useHistory(i){document.getElementById("sql").value=window._histArr[i];onSQLInput();closeHistory()}' & _
        'function closeHistory(){document.getElementById("historyModal").classList.remove("open")}' & _
        'function toast(msg){var t=document.getElementById("toast");t.textContent=msg;t.classList.add("show");setTimeout(function(){t.classList.remove("show")},2000)}' & _
        'onSQLInput();' & _
        'function showExplain(d){var e=document.getElementById("output");' & _
        'var h="<div class=explain-wrap><h3 style=\"margin-bottom:12px;color:var(--accent)\">EXPLAIN QUERY PLAN</h3><div class=explain-tree>";' & _
        'd.plan.forEach(function(p){h+="<div class=explain-node style=\"margin-left:"+(p.id*20)+"px\"><span class=explain-id>"+p.id+"</span><span class=explain-detail>"+esc(p.detail)+"</span></div>"});' & _
        'h+="</div></div>";e.innerHTML=h}' & _
        'function showTemplates(){var tpls=[' & _
        '{n:"Basic SELECT",sql:"SELECT * FROM table_name WHERE condition LIMIT 100;"},' & _
        '{n:"COUNT rows",sql:"SELECT COUNT(*) AS total FROM table_name;"},' & _
        '{n:"GROUP BY with COUNT",sql:"SELECT column, COUNT(*) AS cnt FROM table_name GROUP BY column ORDER BY cnt DESC;"},' & _
        '{n:"JOIN two tables",sql:"SELECT a.*, b.* FROM table1 a INNER JOIN table2 b ON a.id = b.fk_id;"},' & _
        '{n:"Subquery",sql:"SELECT * FROM table_name WHERE id IN (SELECT fk_id FROM other_table);"},' & _
        '{n:"INSERT row",sql:"INSERT INTO table_name (col1, col2) VALUES (' & $Q & 'value1' & $Q & ', ' & $Q & 'value2' & $Q & ');"},' & _
        '{n:"UPDATE row",sql:"UPDATE table_name SET col1 = ' & $Q & 'new_value' & $Q & ' WHERE id = 1;"},' & _
        '{n:"DELETE row",sql:"DELETE FROM table_name WHERE id = 1;"},' & _
        '{n:"CREATE TABLE",sql:"CREATE TABLE new_table (id INTEGER PRIMARY KEY, name TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);"},' & _
        '{n:"CREATE INDEX",sql:"CREATE INDEX idx_name ON table_name (column);"},' & _
        '{n:"CASE expression",sql:"SELECT name, CASE WHEN status = 1 THEN ' & $Q & 'Active' & $Q & ' ELSE ' & $Q & 'Inactive' & $Q & ' END AS status_text FROM table_name;"},' & _
        '{n:"Date functions",sql:"SELECT DATE(' & $Q & 'now' & $Q & '), TIME(' & $Q & 'now' & $Q & '), DATETIME(' & $Q & 'now' & $Q & ', ' & $Q & '-1 day' & $Q & ');"}' & _
        '];var h="<div class=templates-grid>";' & _
        'tpls.forEach(function(t,i){h+="<div class=template-item onclick=\"useTemplate("+i+")\"><div class=template-name>"+t.n+"</div><div class=template-sql>"+esc(t.sql)+"</div></div>"});' & _
        'h+="</div>";document.getElementById("output").innerHTML=h;window._tpls=tpls}' & _
        'function useTemplate(i){document.getElementById("sql").value=window._tpls[i].sql;onSQLInput()}' & _
        'var THEMES={dark:{bg:"#0d1117",bg2:"#161b22",bg3:"#21262d",border:"#30363d",text:"#c9d1d9",text2:"#8b949e",accent:"#58a6ff"},' & _
        'light:{bg:"#ffffff",bg2:"#f6f8fa",bg3:"#e1e4e8",border:"#d1d5da",text:"#24292e",text2:"#586069",accent:"#0366d6"}};' & _
        'function setTheme(t){var th=THEMES[t];if(!th)return;var r=document.documentElement;' & _
        'r.style.setProperty("--bg",th.bg);r.style.setProperty("--bg2",th.bg2);r.style.setProperty("--bg3",th.bg3);' & _
        'r.style.setProperty("--border",th.border);r.style.setProperty("--text",th.text);r.style.setProperty("--text2",th.text2);' & _
        'r.style.setProperty("--accent",th.accent);toast(t==="dark"?"Dark Theme":"Light Theme")}' & _
        'var resizing=null,startX=0,startW=0;' & _
        'function startResize(e,side){e.preventDefault();resizing=side;startX=e.clientX;' & _
        'startW=side==="left"?document.getElementById("sidebar").offsetWidth:document.getElementById("infoPanel").offsetWidth;' & _
        'document.body.style.cursor="col-resize";document.body.style.userSelect="none";' & _
        'document.getElementById("resizer"+(side==="left"?"Left":"Right")).classList.add("active")}' & _
        'function startResizeH(e){e.preventDefault();resizing="h";startX=e.clientY;' & _
        'startW=document.querySelector(".editor-wrap").offsetHeight;' & _
        'document.body.style.cursor="row-resize";document.body.style.userSelect="none";' & _
        'document.getElementById("resizerH").classList.add("active")}' & _
        'document.addEventListener("mousemove",function(e){if(!resizing)return;' & _
        'if(resizing==="left"){var w=Math.max(180,Math.min(500,startW+(e.clientX-startX)));' & _
        'document.documentElement.style.setProperty("--sidebar-w",w+"px")}' & _
        'else if(resizing==="right"){var w=Math.max(200,Math.min(500,startW-(e.clientX-startX)));' & _
        'document.documentElement.style.setProperty("--info-w",w+"px")}' & _
        'else if(resizing==="h"){var h=Math.max(100,Math.min(500,startW+(e.clientY-startX)));' & _
        'document.documentElement.style.setProperty("--editor-h",h+"px")}});' & _
        'document.addEventListener("mouseup",function(){if(resizing){' & _
        'document.body.style.cursor="";document.body.style.userSelect="";' & _
        'document.querySelectorAll(".resizer,.h-resizer").forEach(function(r){r.classList.remove("active")});resizing=null}});' & _
        'function showInfoPanelWithResizer(){document.getElementById("resizerRight").style.display="block";document.querySelector(".layout").classList.add("info-open")}' & _
        'var origShowTableInfo=showTableInfo;showTableInfo=function(n){origShowTableInfo(n);document.getElementById("resizerRight").style.display="block"};' & _
        'var origCloseInfoPanel=closeInfoPanel;closeInfoPanel=function(){origCloseInfoPanel();document.getElementById("resizerRight").style.display="none"};' & _
        'function getTableOrder(t1,t2){var tb1=schema.find(function(x){return x.n===t1});var tb2=schema.find(function(x){return x.n===t2});' & _
        'if(!tb1||!tb2)return{main:t1,join:t2,on:""};' & _
        'var fk1to2=tb1.fk.find(function(f){return f.to.startsWith(t2+".")});' & _
        'var fk2to1=tb2.fk.find(function(f){return f.to.startsWith(t1+".")});' & _
        'if(fk1to2)return{main:t2,join:t1,on:t1+"."+fk1to2.from+" = "+fk1to2.to,hint:"("+t1+" hat FK auf "+t2+")"};' & _
        'if(fk2to1)return{main:t1,join:t2,on:t2+"."+fk2to1.from+" = "+fk2to1.to,hint:"("+t2+" hat FK auf "+t1+")"};' & _
        'return{main:t1,join:t2,on:"",hint:"(keine FK-Beziehung gefunden)"}}' & _
        'function autoDetectJoin(){var t1=gv("wTable1"),t2=gv("wTable2");if(!t1||!t2){document.getElementById("joinHint").innerHTML="";return}' & _
        'var order=getTableOrder(t1,t2);' & _
        'document.getElementById("wJoinOn").value=order.on;' & _
        'var hint="<b>Empfohlene Reihenfolge:</b> "+order.main+" → "+order.join+" "+order.hint;' & _
        'if(order.on){hint+="<br><b>Auto-erkannte Bedingung:</b> "+order.on}' & _
        'document.getElementById("joinHint").innerHTML=hint;updateWizardPreview()}'
EndFunc
