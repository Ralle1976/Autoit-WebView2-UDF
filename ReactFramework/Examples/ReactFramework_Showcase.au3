; ===============================================================================================================================
; ReactFramework_Showcase.au3 - Vollstaendige Demo aller UI-Komponenten
; ===============================================================================================================================
;
; BESCHREIBUNG:
; Demonstriert ALLE UI-Komponenten des WV2React Frameworks mit ECHTEN
; interaktiven Demos und sichtbarem Event-Logging.
;
; AUTOR: Ralle1976
; VERSION: 2.2.0
;
; ===============================================================================================================================

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "..\Include\WV2React_Core.au3"

; ===============================================================================================================================
; Konfiguration
; ===============================================================================================================================
Global Const $APP_TITLE = "WV2React Framework - Komponenten Showcase v2.2"

Global $g_hMainGUI = 0
Global $g_oWebView = 0
Global $g_iScreenWidth = 0
Global $g_iScreenHeight = 0

; ===============================================================================================================================
; Hauptprogramm
; ===============================================================================================================================
Main()

Func Main()
    ; Bildschirmgroesse ermitteln fuer Vollbild
    $g_iScreenWidth = @DesktopWidth
    $g_iScreenHeight = @DesktopHeight

    $g_hMainGUI = GUICreate($APP_TITLE, $g_iScreenWidth, $g_iScreenHeight, 0, 0, _
        BitOR($WS_POPUP, $WS_CLIPCHILDREN))

    Local $hFileMenu = GUICtrlCreateMenu("&Datei")
    Local $hExitItem = GUICtrlCreateMenuItem("&Beenden", $hFileMenu)
    Local $hViewMenu = GUICtrlCreateMenu("&Ansicht")
    Local $hDarkItem = GUICtrlCreateMenuItem("Dark Mode", $hViewMenu)
    Local $hLightItem = GUICtrlCreateMenuItem("Light Mode", $hViewMenu)

    GUISetState(@SW_MAXIMIZE, $g_hMainGUI)

    ; ESC-Taste zum Beenden registrieren
    HotKeySet("{ESC}", "_ExitApp")

    ConsoleWrite("[Showcase] Initialisiere WV2React..." & @CRLF)
    $g_oWebView = _WV2React_Init($g_hMainGUI, 0, 0, $g_iScreenWidth, $g_iScreenHeight, "light", "#3B82F6")
    If @error Then
        MsgBox(16, "Fehler", "WebView2 konnte nicht initialisiert werden!")
        Exit 1
    EndIf

    _WV2React_OnEvent(_OnEvent)
    Sleep(1000)

    ; Externe JavaScript-Datei laden
    _LoadShowcaseJS()

    ; Hauptschleife
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")
    While True
        Local $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE, $hExitItem
                ExitLoop
            Case $hDarkItem
                _WV2React_SetTheme("dark")
                _WebView2_ExecuteScript($g_oWebView, "document.documentElement.classList.add('dark');", 100)
            Case $hLightItem
                _WV2React_SetTheme("light")
                _WebView2_ExecuteScript($g_oWebView, "document.documentElement.classList.remove('dark');", 100)
        EndSwitch

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

Func _LoadShowcaseJS()
    ; Lade externe showcase.js Datei
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

Func _OnEvent($sEventType, $sComponentId, $sData)
    ConsoleWrite("[AutoIt Event] " & $sEventType & " | " & $sComponentId & @CRLF)
EndFunc

Func _ExitApp()
    HotKeySet("{ESC}")
    _WebView2_Close($g_oWebView)
    GUIDelete($g_hMainGUI)
    Exit
EndFunc
