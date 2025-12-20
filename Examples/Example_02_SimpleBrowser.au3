#include <GUIConstantsEx.au3>
#include "..\Include\WebView2_Setup.au3"
#include "..\Include\WebView2_OrdoControl.au3"

; ====================================================================================================================
; Example 2: Simple Web Browser
; ====================================================================================================================
; A fully functional web browser with modern Edge rendering.
;
; Features:
; - URL navigation with address bar
; - Back/Forward buttons
; - Reload and Home buttons
; - Favorites (bookmarks)
; - Status bar with page info
; - Developer Tools (F12)
; - Works with modern websites (React, Vue, Angular)
;
; TRY THESE URLS:
; - https://www.google.com
; - https://react.dev (React framework - won't work with IE!)
; - https://vuejs.org (Vue framework)
; - https://github.com
; ====================================================================================================================

; Auto-setup if needed
If Not _WebView2Setup_CheckAll() Then
    ConsoleWrite("Missing components detected. Running setup..." & @CRLF)
    If Not _WebView2Setup_ShowSetupWizard() Then
        MsgBox(16, "Setup Required", "Please run Example_01_SetupWizard.au3 first!")
        Exit
    EndIf
EndIf

; Configuration
Local $sHomePage = "https://www.google.com"
Local $aFavorites[5][2] = [ _
    ["Google", "https://www.google.com"], _
    ["GitHub", "https://www.github.com"], _
    ["React Docs", "https://react.dev"], _
    ["Vue Docs", "https://vuejs.org"], _
    ["AutoIt Forums", "https://www.autoitscript.com/forum/"] _
]

; Create GUI
Local $hGUI = GUICreate("Simple Web Browser - Native Edge WebView2", 1280, 800)

; Toolbar
Local $idInputURL = GUICtrlCreateInput($sHomePage, 50, 10, 850, 25)
Local $idBtnGo = GUICtrlCreateButton("Go", 910, 10, 50, 25)
Local $idBtnHome = GUICtrlCreateButton("🏠", 10, 10, 35, 25)
Local $idBtnBack = GUICtrlCreateButton("◀", 970, 10, 35, 25)
Local $idBtnForward = GUICtrlCreateButton("▶", 1010, 10, 35, 25)
Local $idBtnReload = GUICtrlCreateButton("↻", 1050, 10, 35, 25)
Local $idBtnDevTools = GUICtrlCreateButton("F12", 1090, 10, 40, 25)

; Favorites menu
Local $idLabelFavorites = GUICtrlCreateLabel("Favorites:", 1140, 13, 55, 20)
Local $idComboFavorites = GUICtrlCreateCombo("", 1200, 10, 70, 25, 0x0003) ; CBS_DROPDOWNLIST
Local $sFavList = ""
For $i = 0 To UBound($aFavorites) - 1
    $sFavList &= $aFavorites[$i][0] & "|"
Next
GUICtrlSetData($idComboFavorites, $sFavList, "")

; Status bar
Local $idStatusBar = GUICtrlCreateLabel("Ready", 10, 45, 1260, 20)
GUICtrlSetBkColor($idStatusBar, 0xF0F0F0)

; Create WebView2
ConsoleWrite("Creating WebView2 control..." & @CRLF)
Local $oWebView = _WebView2Ordo_Create($hGUI, 0, 70, 1280, 730, Default, True)

If Not IsObj($oWebView) Then
    MsgBox(16, "Error", "Failed to create WebView2 control!" & @CRLF & @CRLF & _
        "Please run Example_01_SetupWizard.au3 to install required components.")
    Exit
EndIf

ConsoleWrite("WebView2 created successfully!" & @CRLF)

GUISetState(@SW_SHOW, $hGUI)

; Navigate to home page
_WebView2Ordo_Navigate($oWebView, $sHomePage)
GUICtrlSetData($idStatusBar, "Loading: " & $sHomePage)

ConsoleWrite("Browser ready! Try navigating to react.dev or vuejs.org" & @CRLF)

; Event loop
Local $iLastUpdate = TimerInit()

While 1
    Local $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $idBtnHome
            _WebView2Ordo_Navigate($oWebView, $sHomePage)
            GUICtrlSetData($idInputURL, $sHomePage)
            GUICtrlSetData($idStatusBar, "Navigating to home page...")

        Case $idBtnGo
            Local $sURL = GUICtrlRead($idInputURL)
            If $sURL <> "" Then
                ; Add http:// if missing
                If Not StringRegExp($sURL, "^https?://") Then
                    $sURL = "http://" & $sURL
                    GUICtrlSetData($idInputURL, $sURL)
                EndIf
                _WebView2Ordo_Navigate($oWebView, $sURL)
                GUICtrlSetData($idStatusBar, "Loading: " & $sURL)
            EndIf

        Case $idBtnBack
            _WebView2Ordo_GoBack($oWebView)
            Sleep(500)
            Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
            GUICtrlSetData($idInputURL, $sCurrentURL)
            GUICtrlSetData($idStatusBar, "Back: " & $sCurrentURL)

        Case $idBtnForward
            _WebView2Ordo_GoForward($oWebView)
            Sleep(500)
            Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
            GUICtrlSetData($idInputURL, $sCurrentURL)
            GUICtrlSetData($idStatusBar, "Forward: " & $sCurrentURL)

        Case $idBtnReload
            _WebView2Ordo_Reload($oWebView)
            GUICtrlSetData($idStatusBar, "Reloading page...")

        Case $idBtnDevTools
            _WebView2Ordo_OpenDevTools($oWebView)
            GUICtrlSetData($idStatusBar, "Developer Tools opened (F12)")

        Case $idComboFavorites
            Local $sSelected = GUICtrlRead($idComboFavorites)
            If $sSelected <> "" Then
                ; Find URL in favorites
                For $i = 0 To UBound($aFavorites) - 1
                    If $aFavorites[$i][0] = $sSelected Then
                        _WebView2Ordo_Navigate($oWebView, $aFavorites[$i][1])
                        GUICtrlSetData($idInputURL, $aFavorites[$i][1])
                        GUICtrlSetData($idStatusBar, "Loading: " & $aFavorites[$i][0])
                        ExitLoop
                    EndIf
                Next
                ; Reset combo
                GUICtrlSetData($idComboFavorites, "")
            EndIf
    EndSwitch

    ; Update URL bar and title periodically
    If TimerDiff($iLastUpdate) > 2000 Then ; Every 2 seconds
        Local $sCurrentURL = _WebView2Ordo_GetURL($oWebView)
        Local $sTitle = _WebView2Ordo_GetTitle($oWebView)

        If $sCurrentURL <> "" And $sCurrentURL <> "about:blank" Then
            ; Only update if different
            If GUICtrlRead($idInputURL) <> $sCurrentURL Then
                GUICtrlSetData($idInputURL, $sCurrentURL)
            EndIf

            ; Update window title
            If $sTitle <> "" Then
                WinSetTitle($hGUI, "", $sTitle & " - Simple Browser")
                GUICtrlSetData($idStatusBar, "Ready - " & $sTitle)
            EndIf
        EndIf

        $iLastUpdate = TimerInit()
    EndIf

    Sleep(10)
WEnd

; Cleanup
ConsoleWrite("Closing browser..." & @CRLF)
$oWebView = 0
GUIDelete($hGUI)
ConsoleWrite("Done!" & @CRLF)
