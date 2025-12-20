#include-once
#include "WebView2_COM.au3"

; #INDEX# =======================================================================================================================
; Title .........: WebView2_Callbacks
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: Callback handlers for native Microsoft Edge WebView2
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; This file implements COM callback handlers for WebView2 async operations.
; It uses WebView2Helper.dll for proper COM callback support and
; communicates via Windows messages.
;
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; Helper DLL handle
Global $__g_hWV2_HelperDll = 0
Global $__g_sWV2_HelperPath = ""

; Pending async operation data
Global $__g_pWV2_PendingEnvironment = 0
Global $__g_pWV2_PendingController = 0
Global $__g_pWV2_PendingWebView2 = 0
Global $__g_sWV2_PendingScriptResult = ""
Global $__g_bWV2_NavigationSuccess = False
Global $__g_sWV2_LastWebMessage = ""
Global $__g_sWV2_DocumentTitle = ""
Global $__g_bWV2_IsLoading = False

; Synchronization flags
Global $__g_bWV2_EnvironmentReady = False
Global $__g_bWV2_ControllerReady = False
Global $__g_bWV2_ScriptComplete = False

; Event callback functions (user-defined)
Global $__g_fWV2_OnEnvironmentCreated = 0
Global $__g_fWV2_OnControllerCreated = 0
Global $__g_fWV2_OnScriptExecuted = 0
Global $__g_fWV2_OnNavigationCompleted = 0
Global $__g_fWV2_OnWebMessageReceived = 0

; Window message IDs (must match WebView2Helper.c)
Global Const $WM_WV2_ENVIRONMENT_CREATED = 0x8000 + 100  ; WM_USER + 100
Global Const $WM_WV2_CONTROLLER_CREATED = 0x8000 + 101
Global Const $WM_WV2_NAVIGATION_COMPLETED = 0x8000 + 102
Global Const $WM_WV2_WEB_MESSAGE_RECEIVED = 0x8000 + 103
Global Const $WM_WV2_SCRIPT_COMPLETED = 0x8000 + 104
; ===============================================================================================================================

; ===============================================================================================================================
; Helper DLL Management
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_LoadHelperDll
; Description ...: Find and load WebView2Helper.dll
; Syntax ........: _WV2CB_LoadHelperDll([$sPath = ""])
; Parameters ....: $sPath - [optional] Custom path to WebView2Helper.dll
; Return values .: Success - Handle to loaded DLL
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_LoadHelperDll($sPath = "")
    If $__g_hWV2_HelperDll <> 0 Then Return $__g_hWV2_HelperDll

    ; Detect AutoIt architecture (x86 or x64)
    Local $sArch = @AutoItX64 ? "_x64" : "_x86"

    ; Search paths for WebView2Helper.dll - try architecture-specific first
    Local $aPaths[12] = [ _
        $sPath, _
        @ScriptDir & "\WebView2Helper" & $sArch & ".dll", _
        @ScriptDir & "\WebView2Helper.dll", _
        @ScriptDir & "\bin\WebView2Helper" & $sArch & ".dll", _
        @ScriptDir & "\bin\WebView2Helper.dll", _
        @ScriptDir & "\..\bin\WebView2Helper" & $sArch & ".dll", _
        @ScriptDir & "\..\bin\WebView2Helper.dll", _
        @ScriptDir & "\..\Include\WebView2Helper" & $sArch & ".dll", _
        @ScriptDir & "\..\Include\WebView2Helper.dll", _
        @SystemDir & "\WebView2Helper.dll", _
        @LocalAppDataDir & "\WebView2UDF\WebView2Helper" & $sArch & ".dll", _
        @LocalAppDataDir & "\WebView2UDF\WebView2Helper.dll" _
    ]

    ; Try each path
    For $i = 0 To UBound($aPaths) - 1
        If $aPaths[$i] = "" Then ContinueLoop
        If FileExists($aPaths[$i]) Then
            $__g_hWV2_HelperDll = DllOpen($aPaths[$i])
            If $__g_hWV2_HelperDll <> -1 Then
                $__g_sWV2_HelperPath = $aPaths[$i]
                ConsoleWrite("[WebView2] Loaded Helper DLL: " & $aPaths[$i] & " (AutoIt " & (@AutoItX64 ? "x64" : "x86") & ")" & @CRLF)
                Return $__g_hWV2_HelperDll
            EndIf
        EndIf
    Next

    ConsoleWrite("[WebView2] Warning: WebView2Helper.dll not found for " & (@AutoItX64 ? "x64" : "x86") & " architecture!" & @CRLF)
    Return SetError(1, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_IsHelperAvailable
; Description ...: Check if WebView2Helper.dll is available
; Syntax ........: _WV2CB_IsHelperAvailable()
; Return values .: True if helper DLL is available, False otherwise
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_IsHelperAvailable()
    If $__g_hWV2_HelperDll <> 0 Then Return True

    _WV2CB_LoadHelperDll()
    Return ($__g_hWV2_HelperDll <> 0)
EndFunc

; ===============================================================================================================================
; Handler Creation Functions - Using Helper DLL
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_CreateEnvironmentHandler
; Description ...: Create the environment creation completed handler
; Syntax ........: _WV2CB_CreateEnvironmentHandler([$hNotifyWnd = 0])
; Parameters ....: $hNotifyWnd - [optional] Window handle for notifications
; Return values .: Success - Pointer to handler object
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_CreateEnvironmentHandler($hNotifyWnd = 0)
    ConsoleWrite("[WebView2] _WV2CB_CreateEnvironmentHandler called with hWnd: " & $hNotifyWnd & @CRLF)

    ; Try Helper DLL first - it handles COM threading correctly
    If _WV2CB_IsHelperAvailable() Then
        ConsoleWrite("[WebView2] Using Helper DLL for Environment handler" & @CRLF)
        Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_CreateEnvironmentHandler", "hwnd", $hNotifyWnd)
        If Not @error And $aResult[0] <> 0 Then
            ConsoleWrite("[WebView2] Helper Environment handler created: " & $aResult[0] & @CRLF)
            Return $aResult[0]
        EndIf
        ConsoleWrite("[WebView2] Helper DLL failed, falling back to AutoIt" & @CRLF)
    EndIf

    ; Fallback to AutoIt callback
    ConsoleWrite("[WebView2] Using AutoIt callback for Environment handler" & @CRLF)
    Return _WV2CB_CreateEnvironmentHandler_AutoIt()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_CreateControllerHandler
; Description ...: Create the controller creation completed handler
; Syntax ........: _WV2CB_CreateControllerHandler([$hNotifyWnd = 0])
; Parameters ....: $hNotifyWnd - [optional] Window handle for notifications
; Return values .: Success - Pointer to handler object
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_CreateControllerHandler($hNotifyWnd = 0)
    ConsoleWrite("[WebView2] _WV2CB_CreateControllerHandler called with hWnd: " & $hNotifyWnd & @CRLF)

    ; Try Helper DLL first - it handles COM threading correctly
    If _WV2CB_IsHelperAvailable() Then
        ConsoleWrite("[WebView2] Using Helper DLL for Controller handler" & @CRLF)
        Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_CreateControllerHandler", "hwnd", $hNotifyWnd)
        If Not @error And $aResult[0] <> 0 Then
            ConsoleWrite("[WebView2] Helper Controller handler created: " & $aResult[0] & @CRLF)
            Return $aResult[0]
        EndIf
        ConsoleWrite("[WebView2] Helper DLL failed, falling back to AutoIt" & @CRLF)
    EndIf

    ; Fallback to AutoIt callback
    ConsoleWrite("[WebView2] Using AutoIt callback for Controller handler" & @CRLF)
    Return _WV2CB_CreateControllerHandler_AutoIt()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_CreateNavigationHandler
; Description ...: Create the navigation completed handler
; Syntax ........: _WV2CB_CreateNavigationHandler([$hNotifyWnd = 0])
; Parameters ....: $hNotifyWnd - [optional] Window handle for notifications
; Return values .: Success - Pointer to handler object
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_CreateNavigationHandler($hNotifyWnd = 0)
    If Not _WV2CB_IsHelperAvailable() Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_CreateNavigationHandler", "hwnd", $hNotifyWnd)
    If @error Or $aResult[0] = 0 Then Return SetError(1, @error, 0)

    Return $aResult[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_CreateWebMessageHandler
; Description ...: Create the web message received handler
; Syntax ........: _WV2CB_CreateWebMessageHandler([$hNotifyWnd = 0])
; Parameters ....: $hNotifyWnd - [optional] Window handle for notifications
; Return values .: Success - Pointer to handler object
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_CreateWebMessageHandler($hNotifyWnd = 0)
    If Not _WV2CB_IsHelperAvailable() Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_CreateWebMessageHandler", "hwnd", $hNotifyWnd)
    If @error Or $aResult[0] = 0 Then Return SetError(1, @error, 0)

    Return $aResult[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_CreateExecuteScriptHandler
; Description ...: Create the execute script completed handler
; Syntax ........: _WV2CB_CreateExecuteScriptHandler([$hNotifyWnd = 0])
; Parameters ....: $hNotifyWnd - [optional] Window handle for notifications
; Return values .: Success - Pointer to handler object
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_CreateExecuteScriptHandler($hNotifyWnd = 0)
    ; IMPORTANT: Always use AutoIt callback for script execution
    ; The Helper DLL's script handler doesn't properly signal completion,
    ; causing timeouts. The AutoIt callback sets $__g_bWV2_ScriptComplete
    ; directly and works reliably.
    ConsoleWrite("[WebView2] Using AutoIt callback for ExecuteScript" & @CRLF)
    Return _WV2CB_CreateExecuteScriptHandler_AutoIt()

    #cs --- Original code (Helper DLL has issues with script callbacks) ---
    If Not _WV2CB_IsHelperAvailable() Then
        Return _WV2CB_CreateExecuteScriptHandler_AutoIt()
    EndIf

    Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_CreateScriptHandler", "hwnd", $hNotifyWnd)
    If @error Or $aResult[0] = 0 Then Return SetError(1, @error, 0)

    Return $aResult[0]
    #ce
EndFunc

; ===============================================================================================================================
; Wait Functions
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_WaitForEnvironment
; Description ...: Wait for environment creation to complete (message-based)
; Syntax ........: _WV2CB_WaitForEnvironment($hWnd, [$iTimeout = 10000])
; Parameters ....: $hWnd     - Window handle to receive messages
;                  $iTimeout - [optional] Timeout in milliseconds. Default is 10000.
; Return values .: Success - Pointer to ICoreWebView2Environment
;                  Failure - 0 and sets @error (1 = timeout)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_WaitForEnvironment($iTimeout = 10000)
    Local $hTimer = TimerInit()
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")

    While Not $__g_bWV2_EnvironmentReady And $__g_pWV2_PendingEnvironment = 0
        ; Pump Windows messages
        While _WV2CB_PeekMessage($tMSG, 0, 0, 0, 1)
            ; Check for our message
            Local $uMsg = DllStructGetData($tMSG, "message")
            If $uMsg = $WM_WV2_ENVIRONMENT_CREATED Then
                $__g_bWV2_EnvironmentReady = True
                Local $hResult = DllStructGetData($tMSG, "wParam")
                Local $pEnv = DllStructGetData($tMSG, "lParam")

                If $hResult = 0 And $pEnv <> 0 Then
                    $__g_pWV2_PendingEnvironment = $pEnv
                EndIf
            EndIf

            _WV2CB_TranslateMessage($tMSG)
            _WV2CB_DispatchMessage($tMSG)
        WEnd

        ; Also check helper DLL directly (in case message was missed)
        If $__g_hWV2_HelperDll <> 0 And $__g_pWV2_PendingEnvironment = 0 Then
            Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_GetEnvironment")
            If Not @error And $aResult[0] <> 0 Then
                $__g_pWV2_PendingEnvironment = $aResult[0]
                $__g_bWV2_EnvironmentReady = True
                ConsoleWrite("[WebView2] Environment from helper: " & $aResult[0] & @CRLF)
            EndIf
        EndIf

        Sleep(10)
        If TimerDiff($hTimer) > $iTimeout Then
            Return SetError(1, 0, 0)
        EndIf
    WEnd

    Return $__g_pWV2_PendingEnvironment
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_WaitForController
; Description ...: Wait for controller creation to complete (message-based)
; Syntax ........: _WV2CB_WaitForController([$iTimeout = 10000])
; Parameters ....: $iTimeout - [optional] Timeout in milliseconds. Default is 10000.
; Return values .: Success - Pointer to ICoreWebView2Controller
;                  Failure - 0 and sets @error (1 = timeout)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_WaitForController($iTimeout = 10000)
    Local $hTimer = TimerInit()
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")

    While Not $__g_bWV2_ControllerReady And $__g_pWV2_PendingController = 0
        ; Pump Windows messages
        While _WV2CB_PeekMessage($tMSG, 0, 0, 0, 1)
            ; Check for our message
            Local $uMsg = DllStructGetData($tMSG, "message")
            If $uMsg = $WM_WV2_CONTROLLER_CREATED Then
                $__g_bWV2_ControllerReady = True
                Local $hResult = DllStructGetData($tMSG, "wParam")
                Local $pCtrl = DllStructGetData($tMSG, "lParam")

                If $hResult = 0 And $pCtrl <> 0 Then
                    $__g_pWV2_PendingController = $pCtrl
                EndIf
            EndIf

            _WV2CB_TranslateMessage($tMSG)
            _WV2CB_DispatchMessage($tMSG)
        WEnd

        ; Also check helper DLL directly (in case message was missed)
        If $__g_hWV2_HelperDll <> 0 And $__g_pWV2_PendingController = 0 Then
            Local $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_GetController")
            If Not @error And $aResult[0] <> 0 Then
                $__g_pWV2_PendingController = $aResult[0]
                $__g_bWV2_ControllerReady = True
                ConsoleWrite("[WebView2] Controller from helper: " & $aResult[0] & @CRLF)

                ; Also get the WebView2 interface
                $aResult = DllCall($__g_hWV2_HelperDll, "ptr", "WV2Helper_GetWebView2")
                If Not @error And $aResult[0] <> 0 Then
                    $__g_pWV2_PendingWebView2 = $aResult[0]
                    ConsoleWrite("[WebView2] WebView2 from helper: " & $aResult[0] & @CRLF)
                EndIf
            EndIf
        EndIf

        Sleep(10)
        If TimerDiff($hTimer) > $iTimeout Then
            Return SetError(1, 0, 0)
        EndIf
    WEnd

    Return $__g_pWV2_PendingController
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_WaitForScript
; Description ...: Wait for script execution to complete
; Syntax ........: _WV2CB_WaitForScript([$iTimeout = 5000])
; Parameters ....: $iTimeout - [optional] Timeout in milliseconds. Default is 5000.
; Return values .: Success - JSON result string
;                  Failure - Empty string and sets @error (1 = timeout)
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_WaitForScript($iTimeout = 5000)
    ; NOTE: Do NOT reset $__g_bWV2_ScriptComplete here!
    ; It was already reset in _WebView2_ExecuteScript before calling ExecuteScript.
    ; Resetting here causes a race condition if the callback fires quickly.

    Local $hTimer = TimerInit()
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")

    ; Check if already complete (fast callback)
    If $__g_bWV2_ScriptComplete Then
        ConsoleWrite("[WebView2] Script already completed before wait" & @CRLF)
    EndIf

    While Not $__g_bWV2_ScriptComplete
        ; Pump Windows messages
        While _WV2CB_PeekMessage($tMSG, 0, 0, 0, 1)
            ; Check for our message
            Local $uMsg = DllStructGetData($tMSG, "message")
            If $uMsg = $WM_WV2_SCRIPT_COMPLETED Then
                $__g_bWV2_ScriptComplete = True
            EndIf

            _WV2CB_TranslateMessage($tMSG)
            _WV2CB_DispatchMessage($tMSG)
        WEnd

        ; Poll Helper DLL for result (in case message was missed or not sent)
        If $__g_hWV2_HelperDll <> 0 Then
            Local $aPollResult = DllCall($__g_hWV2_HelperDll, "wstr", "WV2Helper_GetScriptResult")
            If Not @error And $aPollResult[0] <> "" Then
                $__g_sWV2_PendingScriptResult = $aPollResult[0]
                $__g_bWV2_ScriptComplete = True
                ConsoleWrite("[WebView2] Script result from polling: " & StringLeft($aPollResult[0], 50) & @CRLF)
                ExitLoop
            EndIf
        EndIf

        Sleep(10)
        If TimerDiff($hTimer) > $iTimeout Then
            ConsoleWrite("[WebView2] Script execution timeout after " & $iTimeout & "ms" & @CRLF)
            Return SetError(1, 0, "")
        EndIf
    WEnd

    ; Get result from helper DLL only if we don't have a result yet
    ; (AutoIt callback might have already set the result)
    If $__g_hWV2_HelperDll <> 0 And $__g_sWV2_PendingScriptResult = "" Then
        Local $aResult = DllCall($__g_hWV2_HelperDll, "wstr", "WV2Helper_GetScriptResult")
        If Not @error And $aResult[0] <> "" Then
            $__g_sWV2_PendingScriptResult = $aResult[0]
        EndIf
    EndIf

    ConsoleWrite("[WebView2] Script result: " & StringLeft($__g_sWV2_PendingScriptResult, 100) & @CRLF)
    Return $__g_sWV2_PendingScriptResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_GetLastWebMessage
; Description ...: Get the last received web message
; Syntax ........: _WV2CB_GetLastWebMessage()
; Return values .: The last web message string
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_GetLastWebMessage()
    If $__g_hWV2_HelperDll <> 0 Then
        Local $aResult = DllCall($__g_hWV2_HelperDll, "wstr", "WV2Helper_GetLastMessage")
        If Not @error Then
            Return $aResult[0]
        EndIf
    EndIf
    Return $__g_sWV2_LastWebMessage
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

Func _WV2CB_PeekMessage(ByRef $tMSG, $hWnd, $iMsgMin, $iMsgMax, $iRemove)
    Local $aResult = DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", $hWnd, "uint", $iMsgMin, "uint", $iMsgMax, "uint", $iRemove)
    If @error Then Return False
    Return $aResult[0]
EndFunc

Func _WV2CB_TranslateMessage(ByRef $tMSG)
    DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
EndFunc

Func _WV2CB_DispatchMessage(ByRef $tMSG)
    DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_ResetState
; Description ...: Reset all callback state variables
; Syntax ........: _WV2CB_ResetState()
; Parameters ....: None
; Return values .: None
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_ResetState()
    $__g_pWV2_PendingEnvironment = 0
    $__g_pWV2_PendingController = 0
    $__g_pWV2_PendingWebView2 = 0
    $__g_sWV2_PendingScriptResult = ""
    $__g_bWV2_NavigationSuccess = False
    $__g_sWV2_LastWebMessage = ""
    $__g_sWV2_DocumentTitle = ""
    $__g_bWV2_IsLoading = False
    $__g_bWV2_EnvironmentReady = False
    $__g_bWV2_ControllerReady = False
    $__g_bWV2_ScriptComplete = False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_Initialize
; Description ...: Initialize the callback system
; Syntax ........: _WV2CB_Initialize($hNotifyWnd)
; Parameters ....: $hNotifyWnd - Window handle for receiving WebView2 notifications
; Return values .: True on success, False on failure
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_Initialize($hNotifyWnd)
    ConsoleWrite("[WebView2] _WV2CB_Initialize called with hWnd: " & $hNotifyWnd & @CRLF)

    If Not _WV2CB_LoadHelperDll() Then
        ConsoleWrite("[WebView2] Warning: WebView2Helper.dll not found, using fallback mode" & @CRLF)
        Return False
    EndIf

    ConsoleWrite("[WebView2] Calling WV2Helper_Initialize..." & @CRLF)
    Local $aResult = DllCall($__g_hWV2_HelperDll, "bool", "WV2Helper_Initialize", "hwnd", $hNotifyWnd)
    ConsoleWrite("[WebView2] WV2Helper_Initialize @error=" & @error & " result=" & ($aResult[0] ? "True" : "False") & @CRLF)

    If @error Or Not $aResult[0] Then
        ConsoleWrite("[WebView2] WV2Helper_Initialize FAILED!" & @CRLF)
        Return False
    EndIf

    ConsoleWrite("[WebView2] WV2Helper_Initialize OK" & @CRLF)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2CB_Cleanup
; Description ...: Cleanup the callback system
; Syntax ........: _WV2CB_Cleanup()
; Parameters ....: None
; Return values .: None
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2CB_Cleanup()
    If $__g_hWV2_HelperDll <> 0 Then
        DllCall($__g_hWV2_HelperDll, "none", "WV2Helper_Cleanup")
        DllClose($__g_hWV2_HelperDll)
        $__g_hWV2_HelperDll = 0
    EndIf
EndFunc

; ===============================================================================================================================
; AutoIt Fallback Callbacks (for when helper DLL is not available)
; These may not work with all WebView2 versions due to COM threading issues
; ===============================================================================================================================

; Global variables for AutoIt callbacks
Global $__g_iWV2_RefCount = 1
Global $__g_tWV2_VT_EnvironmentHandler = 0
Global $__g_tWV2_EnvironmentHandler = 0
Global $__g_tWV2_VT_ControllerHandler = 0
Global $__g_tWV2_ControllerHandler = 0
Global $__g_tWV2_VT_ExecuteScriptHandler = 0
Global $__g_tWV2_ExecuteScriptHandler = 0

; Global DllCallback handles - MUST persist or callbacks crash!
; Environment Handler
Global $__g_hWV2_CB_Env_QI = 0
Global $__g_hWV2_CB_Env_AddRef = 0
Global $__g_hWV2_CB_Env_Release = 0
Global $__g_hWV2_CB_Env_Invoke = 0
; Controller Handler
Global $__g_hWV2_CB_Ctrl_QI = 0
Global $__g_hWV2_CB_Ctrl_AddRef = 0
Global $__g_hWV2_CB_Ctrl_Release = 0
Global $__g_hWV2_CB_Ctrl_Invoke = 0
; Script Handler
Global $__g_hWV2_CB_Script_QI = 0
Global $__g_hWV2_CB_Script_AddRef = 0
Global $__g_hWV2_CB_Script_Release = 0
Global $__g_hWV2_CB_Script_Invoke = 0

; IUnknown Implementation
Func __WV2CB_QueryInterface($pSelf, $pRIID, $ppvObject)
    Local $tRIID = DllStructCreate($tagWV2_GUID, $pRIID)
    Local $tIID_IUnknown = _WV2COM_StringToGUID($sIID_IUnknown)

    If _WV2COM_CompareGUID($tRIID, $tIID_IUnknown) Then
        Local $tOut = DllStructCreate("ptr", $ppvObject)
        DllStructSetData($tOut, 1, $pSelf)
        __WV2CB_AddRef($pSelf)
        Return $WV2_S_OK
    EndIf

    Local $tOut = DllStructCreate("ptr", $ppvObject)
    DllStructSetData($tOut, 1, 0)
    Return $WV2_E_NOINTERFACE
EndFunc

Func __WV2CB_AddRef($pSelf)
    $__g_iWV2_RefCount += 1
    Return $__g_iWV2_RefCount
EndFunc

Func __WV2CB_Release($pSelf)
    $__g_iWV2_RefCount -= 1
    If $__g_iWV2_RefCount <= 0 Then $__g_iWV2_RefCount = 0
    Return $__g_iWV2_RefCount
EndFunc

Func __WV2CB_EnvironmentCompleted_Invoke($pSelf, $hResult, $pEnvironment)
    If $hResult = $WV2_S_OK And $pEnvironment <> 0 Then
        $__g_pWV2_PendingEnvironment = $pEnvironment
    EndIf
    $__g_bWV2_EnvironmentReady = True
    Return $WV2_S_OK
EndFunc

Func __WV2CB_ControllerCompleted_Invoke($pSelf, $hResult, $pController)
    If $hResult = $WV2_S_OK And $pController <> 0 Then
        $__g_pWV2_PendingController = $pController
    EndIf
    $__g_bWV2_ControllerReady = True
    Return $WV2_S_OK
EndFunc

Func __WV2CB_ExecuteScriptCompleted_Invoke($pSelf, $hResult, $pResultJson)
    ConsoleWrite("[WebView2] ExecuteScript callback invoked! hResult=" & $hResult & " pResult=" & $pResultJson & @CRLF)
    If $hResult = $WV2_S_OK Then
        $__g_sWV2_PendingScriptResult = _WV2COM_PtrToWStr($pResultJson)
        ConsoleWrite("[WebView2] Script result received: " & StringLeft($__g_sWV2_PendingScriptResult, 100) & @CRLF)
    Else
        $__g_sWV2_PendingScriptResult = ""
        ConsoleWrite("[WebView2] Script execution failed with code: " & $hResult & @CRLF)
    EndIf
    $__g_bWV2_ScriptComplete = True
    Return $WV2_S_OK
EndFunc

Func _WV2CB_CreateEnvironmentHandler_AutoIt()
    ; Return existing handler if already created (reuse to avoid memory leaks)
    If IsDllStruct($__g_tWV2_EnvironmentHandler) Then
        Local $pExisting = DllStructGetPtr($__g_tWV2_EnvironmentHandler)
        If $pExisting <> 0 Then
            ConsoleWrite("[WebView2] Reusing existing Environment handler: " & $pExisting & @CRLF)
            Return $pExisting
        EndIf
    EndIf

    ; Register callbacks - store in GLOBAL variables so they persist!
    $__g_hWV2_CB_Env_QI = DllCallbackRegister("__WV2CB_QueryInterface", "long", "ptr;ptr;ptr*")
    $__g_hWV2_CB_Env_AddRef = DllCallbackRegister("__WV2CB_AddRef", "ulong", "ptr")
    $__g_hWV2_CB_Env_Release = DllCallbackRegister("__WV2CB_Release", "ulong", "ptr")
    $__g_hWV2_CB_Env_Invoke = DllCallbackRegister("__WV2CB_EnvironmentCompleted_Invoke", "long", "ptr;long;ptr")

    If @error Then
        ConsoleWrite("[WebView2] ERROR: Failed to register Environment callbacks!" & @CRLF)
        Return SetError(1, 0, 0)
    EndIf

    $__g_tWV2_VT_EnvironmentHandler = DllStructCreate("ptr[4]")
    DllStructSetData($__g_tWV2_VT_EnvironmentHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Env_QI), 1)
    DllStructSetData($__g_tWV2_VT_EnvironmentHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Env_AddRef), 2)
    DllStructSetData($__g_tWV2_VT_EnvironmentHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Env_Release), 3)
    DllStructSetData($__g_tWV2_VT_EnvironmentHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Env_Invoke), 4)

    $__g_tWV2_EnvironmentHandler = DllStructCreate("ptr")
    DllStructSetData($__g_tWV2_EnvironmentHandler, 1, DllStructGetPtr($__g_tWV2_VT_EnvironmentHandler))

    ConsoleWrite("[WebView2] Created Environment handler at: " & DllStructGetPtr($__g_tWV2_EnvironmentHandler) & @CRLF)
    Return DllStructGetPtr($__g_tWV2_EnvironmentHandler)
EndFunc

Func _WV2CB_CreateControllerHandler_AutoIt()
    ; Return existing handler if already created (reuse to avoid memory leaks)
    If IsDllStruct($__g_tWV2_ControllerHandler) Then
        Local $pExisting = DllStructGetPtr($__g_tWV2_ControllerHandler)
        If $pExisting <> 0 Then
            ConsoleWrite("[WebView2] Reusing existing Controller handler: " & $pExisting & @CRLF)
            Return $pExisting
        EndIf
    EndIf

    ; Register callbacks - store in GLOBAL variables so they persist!
    $__g_hWV2_CB_Ctrl_QI = DllCallbackRegister("__WV2CB_QueryInterface", "long", "ptr;ptr;ptr*")
    $__g_hWV2_CB_Ctrl_AddRef = DllCallbackRegister("__WV2CB_AddRef", "ulong", "ptr")
    $__g_hWV2_CB_Ctrl_Release = DllCallbackRegister("__WV2CB_Release", "ulong", "ptr")
    $__g_hWV2_CB_Ctrl_Invoke = DllCallbackRegister("__WV2CB_ControllerCompleted_Invoke", "long", "ptr;long;ptr")

    If @error Then
        ConsoleWrite("[WebView2] ERROR: Failed to register Controller callbacks!" & @CRLF)
        Return SetError(1, 0, 0)
    EndIf

    $__g_tWV2_VT_ControllerHandler = DllStructCreate("ptr[4]")
    DllStructSetData($__g_tWV2_VT_ControllerHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Ctrl_QI), 1)
    DllStructSetData($__g_tWV2_VT_ControllerHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Ctrl_AddRef), 2)
    DllStructSetData($__g_tWV2_VT_ControllerHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Ctrl_Release), 3)
    DllStructSetData($__g_tWV2_VT_ControllerHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Ctrl_Invoke), 4)

    $__g_tWV2_ControllerHandler = DllStructCreate("ptr")
    DllStructSetData($__g_tWV2_ControllerHandler, 1, DllStructGetPtr($__g_tWV2_VT_ControllerHandler))

    ConsoleWrite("[WebView2] Created Controller handler at: " & DllStructGetPtr($__g_tWV2_ControllerHandler) & @CRLF)
    Return DllStructGetPtr($__g_tWV2_ControllerHandler)
EndFunc

Func _WV2CB_CreateExecuteScriptHandler_AutoIt()
    ; Return existing handler if already created (reuse to avoid memory leaks)
    If IsDllStruct($__g_tWV2_ExecuteScriptHandler) Then
        Local $pExisting = DllStructGetPtr($__g_tWV2_ExecuteScriptHandler)
        If $pExisting <> 0 Then
            ConsoleWrite("[WebView2] Reusing existing ExecuteScript handler: " & $pExisting & @CRLF)
            Return $pExisting
        EndIf
    EndIf

    ; Register callbacks - store in GLOBAL variables so they persist!
    $__g_hWV2_CB_Script_QI = DllCallbackRegister("__WV2CB_QueryInterface", "long", "ptr;ptr;ptr*")
    $__g_hWV2_CB_Script_AddRef = DllCallbackRegister("__WV2CB_AddRef", "ulong", "ptr")
    $__g_hWV2_CB_Script_Release = DllCallbackRegister("__WV2CB_Release", "ulong", "ptr")
    $__g_hWV2_CB_Script_Invoke = DllCallbackRegister("__WV2CB_ExecuteScriptCompleted_Invoke", "long", "ptr;long;ptr")

    If @error Then
        ConsoleWrite("[WebView2] ERROR: Failed to register ExecuteScript callbacks!" & @CRLF)
        Return SetError(1, 0, 0)
    EndIf

    $__g_tWV2_VT_ExecuteScriptHandler = DllStructCreate("ptr[4]")
    DllStructSetData($__g_tWV2_VT_ExecuteScriptHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Script_QI), 1)
    DllStructSetData($__g_tWV2_VT_ExecuteScriptHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Script_AddRef), 2)
    DllStructSetData($__g_tWV2_VT_ExecuteScriptHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Script_Release), 3)
    DllStructSetData($__g_tWV2_VT_ExecuteScriptHandler, 1, DllCallbackGetPtr($__g_hWV2_CB_Script_Invoke), 4)

    $__g_tWV2_ExecuteScriptHandler = DllStructCreate("ptr")
    DllStructSetData($__g_tWV2_ExecuteScriptHandler, 1, DllStructGetPtr($__g_tWV2_VT_ExecuteScriptHandler))

    ConsoleWrite("[WebView2] Created ExecuteScript handler at: " & DllStructGetPtr($__g_tWV2_ExecuteScriptHandler) & @CRLF)
    Return DllStructGetPtr($__g_tWV2_ExecuteScriptHandler)
EndFunc

; ===============================================================================================================================
; End of WebView2_Callbacks.au3
; ===============================================================================================================================
