; ===============================================================================================================================
; ReactFramework_Showcase.au3 - Vollstaendige Demo aller UI-Komponenten
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Demonstriert ALLE 27 UI-Komponenten des WV2React Frameworks mit ECHTEN
; interaktiven Demos und sichtbarem Event-Logging.
;
; DUAL-MODE RENDERING:
; Das Framework unterstuetzt zwei Render-Modi, waehlbar ueber das Menue:
;
;   - DOM-Modus (Standard): Vanilla JavaScript mit DOM API
;     * 0 KB Framework-Overhead
;     * Schnellerer Initial-Load
;     * Ideal fuer einfache UIs
;
;   - React-Modus: React 18 mit Virtual DOM
;     * ~130 KB React CDN wird geladen
;     * Deklaratives UI-Modell
;     * Effiziente Updates bei komplexen UIs
;
; BEDIENUNG:
;   - Menue "Modus" -> Zwischen DOM und React wechseln
;   - Menue "Ansicht" -> Light/Dark Theme wechseln
;   - ESC-Taste -> Anwendung beenden
;
; AUTOR: Ralle1976
; VERSION: 2.3.0
;
; ===============================================================================================================================

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "..\Include\WV2React_Core.au3"

; ===============================================================================================================================
; Konfiguration
; ===============================================================================================================================
Global Const $APP_TITLE = "WV2React Framework - Komponenten Showcase v2.3"

Global $g_hMainGUI = 0
Global $g_oWebView = 0
Global $g_iScreenWidth = 0
Global $g_iScreenHeight = 0

; ===============================================================================================================================
; DUAL-MODE KONFIGURATION
; ===============================================================================================================================
; Aktueller Render-Modus: "dom" oder "react"
; Der Modus wird bei _WV2React_Init() gesetzt und erfordert Neuinitialisierung zum Wechseln
Global $g_sRenderMode = "dom"       ; Standard: DOM-Modus (0 KB Overhead)
Global $g_sTheme = "light"          ; Standard: Light Theme
Global $g_sPrimaryColor = "#3B82F6" ; Standard: Blau

; Menue-Handles (global fuer Checkmarks)
Global $g_hModeDomItem = 0
Global $g_hModeReactItem = 0

; ===============================================================================================================================
; Hauptprogramm
; ===============================================================================================================================
Main()

Func Main()
    ; Bildschirmgroesse ermitteln fuer Vollbild
    $g_iScreenWidth = @DesktopWidth
    $g_iScreenHeight = @DesktopHeight

    ; GUI erstellen (Vollbild ohne Rahmen)
    $g_hMainGUI = GUICreate($APP_TITLE, $g_iScreenWidth, $g_iScreenHeight, 0, 0, _
        BitOR($WS_POPUP, $WS_CLIPCHILDREN))

    ; ===== MENUE: Datei =====
    Local $hFileMenu = GUICtrlCreateMenu("&Datei")
    Local $hExitItem = GUICtrlCreateMenuItem("&Beenden" & @TAB & "ESC", $hFileMenu)

    ; ===== MENUE: Modus (NEU - Dual-Mode Switcher) =====
    Local $hModeMenu = GUICtrlCreateMenu("&Modus")
    $g_hModeDomItem = GUICtrlCreateMenuItem("DOM-Modus (0 KB Overhead)", $hModeMenu)
    $g_hModeReactItem = GUICtrlCreateMenuItem("React-Modus (Virtual DOM)", $hModeMenu)
    GUICtrlCreateMenuItem("", $hModeMenu) ; Separator
    Local $hModeInfoItem = GUICtrlCreateMenuItem("Info: Render-Modi...", $hModeMenu)

    ; Initialen Checkmark setzen
    _UpdateModeCheckmarks()

    ; ===== MENUE: Ansicht =====
    Local $hViewMenu = GUICtrlCreateMenu("&Ansicht")
    Local $hDarkItem = GUICtrlCreateMenuItem("Dark Mode", $hViewMenu)
    Local $hLightItem = GUICtrlCreateMenuItem("Light Mode", $hViewMenu)

    GUISetState(@SW_MAXIMIZE, $g_hMainGUI)

    ; ESC-Taste zum Beenden registrieren
    HotKeySet("{ESC}", "_ExitApp")

    ; WebView2 initialisieren mit aktuellem Modus
    _InitWebView()

    ; Hauptschleife
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")
    While True
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE, $hExitItem
                ExitLoop

            ; ----- Modus-Wechsel -----
            Case $g_hModeDomItem
                If $g_sRenderMode <> "dom" Then
                    $g_sRenderMode = "dom"
                    _SwitchRenderMode()
                EndIf

            Case $g_hModeReactItem
                If $g_sRenderMode <> "react" Then
                    $g_sRenderMode = "react"
                    _SwitchRenderMode()
                EndIf

            Case $hModeInfoItem
                _ShowModeInfo()

            ; ----- Theme-Wechsel -----
            Case $hDarkItem
                $g_sTheme = "dark"
                _WV2React_SetTheme("dark")
                _WebView2_ExecuteScript($g_oWebView, "document.documentElement.classList.add('dark');", 100)

            Case $hLightItem
                $g_sTheme = "light"
                _WV2React_SetTheme("light")
                _WebView2_ExecuteScript($g_oWebView, "document.documentElement.classList.remove('dark');", 100)
        EndSwitch

        ; Windows Message-Pump (KRITISCH fuer WebView2!)
        While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
            DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
            DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
        WEnd

        _WV2React_ProcessEvents()
        Sleep(10)
    WEnd

    _WebView2_Close($g_oWebView)
    GUIDelete($g_hMainGUI)
EndFunc

; ===============================================================================================================================
; _InitWebView - Initialisiert WebView2 mit aktuellem Render-Modus
; ===============================================================================================================================
Func _InitWebView()
    ConsoleWrite("========================================" & @CRLF)
    ConsoleWrite("[Showcase] Initialisiere WV2React..." & @CRLF)
    ConsoleWrite("[Showcase] Render-Modus: " & StringUpper($g_sRenderMode) & @CRLF)
    ConsoleWrite("[Showcase] Theme: " & $g_sTheme & @CRLF)
    ConsoleWrite("========================================" & @CRLF)

    ; WebView2 mit explizitem Render-Modus initialisieren
    ; Parameter: $hGUI, $x, $y, $width, $height, $theme, $primaryColor, $renderMode
    $g_oWebView = _WV2React_Init($g_hMainGUI, 0, 0, $g_iScreenWidth, $g_iScreenHeight, _
        $g_sTheme, $g_sPrimaryColor, $g_sRenderMode)

    If @error Then
        MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!" & @CRLF & _
            "Fehlercode: " & @error)
        Exit 1
    EndIf

    ; Event-Handler registrieren
    _WV2React_OnEvent(_OnEvent)

    ; Warten bis WebView2 bereit ist
    Sleep(1000)

    ; Externe JavaScript-Datei laden
    _LoadShowcaseJS()

    ; Modus-Anzeige im UI aktualisieren
    _UpdateModeDisplay()
EndFunc

; ===============================================================================================================================
; _SwitchRenderMode - Wechselt den Render-Modus (erfordert Neuinitialisierung)
; ===============================================================================================================================
Func _SwitchRenderMode()
    ConsoleWrite("[Showcase] Wechsle Render-Modus zu: " & StringUpper($g_sRenderMode) & @CRLF)

    ; Bestaetigung vom User
    Local $sModeName = ($g_sRenderMode = "dom") ? "DOM-Modus" : "React-Modus"
    Local $iResult = MsgBox(36, "Render-Modus wechseln", _
        "Wechsel zu: " & $sModeName & @CRLF & @CRLF & _
        "Dies erfordert eine Neuinitialisierung des WebView2." & @CRLF & _
        "Die aktuelle Ansicht wird zurueckgesetzt." & @CRLF & @CRLF & _
        "Fortfahren?")

    If $iResult <> 6 Then
        ; Abgebrochen - Modus zuruecksetzen
        $g_sRenderMode = ($g_sRenderMode = "dom") ? "react" : "dom"
        Return
    EndIf

    ; Altes WebView2 schliessen
    _WebView2_Close($g_oWebView)
    Sleep(200)

    ; Checkmarks aktualisieren
    _UpdateModeCheckmarks()

    ; Neues WebView2 mit neuem Modus initialisieren
    _InitWebView()
EndFunc

; ===============================================================================================================================
; _UpdateModeCheckmarks - Aktualisiert die Checkmarks im Modus-Menue
; ===============================================================================================================================
Func _UpdateModeCheckmarks()
    If $g_sRenderMode = "dom" Then
        GUICtrlSetState($g_hModeDomItem, $GUI_CHECKED)
        GUICtrlSetState($g_hModeReactItem, $GUI_UNCHECKED)
    Else
        GUICtrlSetState($g_hModeDomItem, $GUI_UNCHECKED)
        GUICtrlSetState($g_hModeReactItem, $GUI_CHECKED)
    EndIf
EndFunc

; ===============================================================================================================================
; _UpdateModeDisplay - Zeigt den aktuellen Modus im WebView2 an
; ===============================================================================================================================
Func _UpdateModeDisplay()
    ; Modus-Badge im UI anzeigen (falls vorhanden)
    Local $sModeBadge = ($g_sRenderMode = "dom") ? "DOM" : "React"
    Local $sScript = "if(typeof updateModeBadge === 'function') { updateModeBadge('" & $sModeBadge & "'); }"
    _WebView2_ExecuteScript($g_oWebView, $sScript, 100)
EndFunc

; ===============================================================================================================================
; _ShowModeInfo - Zeigt Informationen ueber die Render-Modi
; ===============================================================================================================================
Func _ShowModeInfo()
    Local $sInfo = "WV2React Framework - Dual-Mode Rendering" & @CRLF & @CRLF
    $sInfo &= "Das Framework unterstuetzt zwei Rendering-Engines:" & @CRLF & @CRLF
    $sInfo &= "=== DOM-Modus (Standard) ===" & @CRLF
    $sInfo &= "- Vanilla JavaScript mit DOM API" & @CRLF
    $sInfo &= "- 0 KB Framework-Overhead" & @CRLF
    $sInfo &= "- Schnellerer Initial-Load" & @CRLF
    $sInfo &= "- Ideal fuer einfache bis mittlere UIs" & @CRLF & @CRLF
    $sInfo &= "=== React-Modus ===" & @CRLF
    $sInfo &= "- React 18 mit Virtual DOM" & @CRLF
    $sInfo &= "- ~130 KB React CDN wird geladen" & @CRLF
    $sInfo &= "- Deklaratives UI-Modell" & @CRLF
    $sInfo &= "- Effiziente Updates bei komplexen UIs" & @CRLF & @CRLF
    $sInfo &= "Aktueller Modus: " & StringUpper($g_sRenderMode)

    MsgBox(64, "Render-Modi Information", $sInfo)
EndFunc

; ===============================================================================================================================
; _LoadShowcaseJS - Laedt die externe Showcase JavaScript-Datei
; ===============================================================================================================================
Func _LoadShowcaseJS()
    Local $sJsFile = @ScriptDir & "\showcase.js"

    If Not FileExists($sJsFile) Then
        ConsoleWrite("[Showcase] FEHLER: showcase.js nicht gefunden!" & @CRLF)
        MsgBox(16, "Fehler", "showcase.js nicht gefunden in:" & @CRLF & $sJsFile)
        Return
    EndIf

    Local $hFile = FileOpen($sJsFile, 0)
    If $hFile = -1 Then
        ConsoleWrite("[Showcase] FEHLER: Konnte showcase.js nicht oeffnen!" & @CRLF)
        Return
    EndIf

    Local $sJs = FileRead($hFile)
    FileClose($hFile)

    ConsoleWrite("[Showcase] JavaScript geladen (" & StringLen($sJs) & " Bytes)" & @CRLF)
    _WebView2_ExecuteScript($g_oWebView, $sJs, 5000)
    ConsoleWrite("[Showcase] JavaScript ausgefuehrt" & @CRLF)
EndFunc

; ===============================================================================================================================
; _OnEvent - Event-Handler fuer Komponenten-Events
; ===============================================================================================================================
Func _OnEvent($sEventType, $sComponentId, $sData)
    ConsoleWrite("[AutoIt Event] " & $sEventType & " | " & $sComponentId & @CRLF)
EndFunc

; ===============================================================================================================================
; _ExitApp - Beendet die Anwendung (via ESC-Taste)
; ===============================================================================================================================
Func _ExitApp()
    HotKeySet("{ESC}")
    _WebView2_Close($g_oWebView)
    GUIDelete($g_hMainGUI)
    Exit
EndFunc
