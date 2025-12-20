#include-once
#include <GUIConstantsEx.au3>
#include "..\Include\WebView2_Native.au3"

; #EXAMPLE# =====================================================================================================================
; Title .........: Native WebView2 Basic Example
; AutoIt Version : 3.3.16.1+
; Description ...: Demonstrates basic usage of the native WebView2 UDF without OrdoWebView2.ocx
; Author ........: Ralle1976
; ===============================================================================================================================

; ===============================================================================================================================
; REQUIREMENTS:
; 1. WebView2 Runtime must be installed
; 2. WebView2Loader.dll must be in the bin folder or script directory
; ===============================================================================================================================

; Check for Runtime
If Not _WebView2_IsRuntimeInstalled() Then
    MsgBox(0x10, "Error", "WebView2 Runtime is not installed!" & @CRLF & @CRLF & _
        "Please download from:" & @CRLF & _
        "https://developer.microsoft.com/en-us/microsoft-edge/webview2/")
    Exit
EndIf

; Check for WebView2Loader.dll
If Not _WebView2_GetLoaderDll() Then
    MsgBox(0x10, "Error", "WebView2Loader.dll not found!" & @CRLF & @CRLF & _
        "Please run bin\extract_dll.bat to extract it from the NuGet package.")
    Exit
EndIf

; Create main GUI
Global $g_hMainGUI = GUICreate("Native WebView2 Example - Ralle1976", 1024, 768)

; Control buttons
Global $g_idBtnBack = GUICtrlCreateButton("<", 10, 10, 30, 25)
Global $g_idBtnForward = GUICtrlCreateButton(">", 45, 10, 30, 25)
Global $g_idBtnReload = GUICtrlCreateButton("Reload", 80, 10, 60, 25)
Global $g_idBtnHome = GUICtrlCreateButton("Home", 145, 10, 50, 25)
Global $g_idInputURL = GUICtrlCreateInput("https://www.google.com", 200, 10, 600, 25)
Global $g_idBtnGo = GUICtrlCreateButton("Go", 805, 10, 40, 25)
Global $g_idBtnDevTools = GUICtrlCreateButton("DevTools", 850, 10, 70, 25)
Global $g_idBtnTest = GUICtrlCreateButton("Test JS", 925, 10, 60, 25)

; Status bar
GUICtrlCreateLabel("Status:", 10, 740, 50, 20)
Global $g_idLblStatus = GUICtrlCreateLabel("Initializing...", 60, 740, 900, 20)

GUISetState(@SW_SHOW)

; Create WebView2 control
ConsoleWrite("[Example] Creating WebView2 control..." & @CRLF)
Global $g_aWebView2 = _WebView2_Create($g_hMainGUI, 0, 45, 1024, 690)

If @error Then
    GUICtrlSetData($g_idLblStatus, "Error: Failed to create WebView2 (Error " & @error & ")")
    ConsoleWrite("[Example] Failed to create WebView2: Error " & @error & ", Extended " & @extended & @CRLF)
Else
    GUICtrlSetData($g_idLblStatus, "WebView2 created successfully!")
    ConsoleWrite("[Example] WebView2 created successfully" & @CRLF)

    ; Navigate to initial URL
    _WebView2_Navigate($g_aWebView2, "https://www.google.com")

    ; Set navigation callback
    _WebView2_SetNavigationCallback($g_aWebView2, "_OnNavigationCompleted")

    ; Set message callback for JS communication
    _WebView2_SetMessageCallback($g_aWebView2, "_OnWebMessage")
EndIf

; Main message loop
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $g_idBtnBack
            _WebView2_GoBack($g_aWebView2)

        Case $g_idBtnForward
            _WebView2_GoForward($g_aWebView2)

        Case $g_idBtnReload
            _WebView2_Reload($g_aWebView2)

        Case $g_idBtnHome
            _WebView2_Navigate($g_aWebView2, "https://www.google.com")

        Case $g_idBtnGo
            Local $sURL = GUICtrlRead($g_idInputURL)
            If $sURL <> "" Then
                If Not StringInStr($sURL, "://") Then $sURL = "https://" & $sURL
                _WebView2_Navigate($g_aWebView2, $sURL)
            EndIf

        Case $g_idBtnDevTools
            _WebView2_OpenDevTools($g_aWebView2)

        Case $g_idBtnTest
            ; Execute JavaScript and get result
            Local $sResult = _WebView2_ExecuteScript($g_aWebView2, "document.title")
            MsgBox(0x40, "JavaScript Result", "Document Title: " & @CRLF & $sResult)
    EndSwitch
WEnd

; Cleanup
_WebView2_Close($g_aWebView2)
GUIDelete($g_hMainGUI)

; ===============================================================================================================================
; Callback Functions
; ===============================================================================================================================

Func _OnNavigationCompleted($bSuccess)
    If $bSuccess Then
        Local $sURL = _WebView2_GetSource($g_aWebView2)
        Local $sTitle = _WebView2_GetTitle($g_aWebView2)
        GUICtrlSetData($g_idInputURL, $sURL)
        GUICtrlSetData($g_idLblStatus, "Loaded: " & $sTitle)
    Else
        GUICtrlSetData($g_idLblStatus, "Navigation failed!")
    EndIf
EndFunc

Func _OnWebMessage($sMessage)
    ConsoleWrite("[WebMessage] Received: " & $sMessage & @CRLF)
    GUICtrlSetData($g_idLblStatus, "Message from JS: " & $sMessage)
EndFunc
