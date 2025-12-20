#include-once
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include "WebView2_COM.au3"
#include "WebView2_Callbacks.au3"
#include "WebView2_Runtime.au3"

; #INDEX# =======================================================================================================================
; Title .........: WebView2_Native
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: Native Microsoft Edge WebView2 wrapper for AutoIt
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; REQUIREMENTS:
; 1. WebView2 Runtime must be installed (checked automatically)
; 2. WebView2Loader.dll (from Microsoft WebView2 SDK)
;
; FEATURES:
; - Native WebView2 integration without third-party OCX controls
; - Full HTML5/CSS3/ES6+ support via Chromium engine
; - Bidirectional communication between AutoIt and JavaScript
; - Event-driven architecture with callback support
; - DevTools support for debugging
;
; INSTALLATION:
; 1. Install WebView2 Runtime from Microsoft
; 2. Place WebView2Loader.dll in your script directory or Windows\System32
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WebView2_Create
; _WebView2_Navigate
; _WebView2_NavigateToString
; _WebView2_ExecuteScript
; _WebView2_ExecuteScriptAsync
; _WebView2_GetSource
; _WebView2_GetTitle
; _WebView2_GoBack
; _WebView2_GoForward
; _WebView2_Reload
; _WebView2_Stop
; _WebView2_SetZoomFactor
; _WebView2_GetZoomFactor
; _WebView2_OpenDevTools
; _WebView2_PostMessage
; _WebView2_SetBounds
; _WebView2_Close
; _WebView2_IsRuntimeInstalled
; _WebView2_GetLoaderDll
; _WebView2_SetMessageCallback
; _WebView2_SetNavigationCallback
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_hWV2_LoaderDll = 0
Global $__g_sWV2_LoaderPath = ""
Global $__g_aWV2_Instances[1][6]  ; [0][0] = Count, [n][0] = hWnd, [n][1] = Environment, [n][2] = Controller, [n][3] = WebView2, [n][4] = Settings, [n][5] = UserDataFolder
$__g_aWV2_Instances[0][0] = 0
Global $__g_sWV2_DefaultUserDataFolder = @AppDataDir & "\WebView2UDF"
; ===============================================================================================================================

; ===============================================================================================================================
; Loader DLL Management
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetLoaderDll
; Description ...: Find and load WebView2Loader.dll (automatically selects x86 or x64 based on AutoIt architecture)
; Syntax ........: _WebView2_GetLoaderDll([$sPath = ""])
; Parameters ....: $sPath - [optional] Custom path to WebView2Loader.dll
; Return values .: Success - Handle to loaded DLL
;                  Failure - 0 and sets @error:
;                            1 - DLL not found
;                            2 - Failed to load DLL
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GetLoaderDll($sPath = "")
    ; If already loaded, return handle
    If $__g_hWV2_LoaderDll <> 0 Then Return $__g_hWV2_LoaderDll

    ; Detect AutoIt architecture (x86 or x64)
    Local $sArch = @AutoItX64 ? "_x64" : "_x86"
    Local $sArchAlt = @AutoItX64 ? "_x64" : ""  ; Alternative naming

    ; Search paths for WebView2Loader.dll - try architecture-specific first
    Local $aPaths[12] = [ _
        $sPath, _
        @ScriptDir & "\WebView2Loader" & $sArch & ".dll", _
        @ScriptDir & "\WebView2Loader" & $sArchAlt & ".dll", _
        @ScriptDir & "\WebView2Loader.dll", _
        @ScriptDir & "\bin\WebView2Loader" & $sArch & ".dll", _
        @ScriptDir & "\bin\WebView2Loader.dll", _
        @ScriptDir & "\..\bin\WebView2Loader" & $sArch & ".dll", _
        @ScriptDir & "\..\bin\WebView2Loader.dll", _
        @SystemDir & "\WebView2Loader.dll", _
        @WindowsDir & "\System32\WebView2Loader.dll", _
        @WindowsDir & "\SysWOW64\WebView2Loader.dll", _
        @LocalAppDataDir & "\Microsoft\WebView2\Loader\WebView2Loader.dll" _
    ]

    ; Try each path
    For $i = 0 To UBound($aPaths) - 1
        If $aPaths[$i] = "" Then ContinueLoop
        If FileExists($aPaths[$i]) Then
            $__g_hWV2_LoaderDll = DllOpen($aPaths[$i])
            If $__g_hWV2_LoaderDll <> -1 Then
                $__g_sWV2_LoaderPath = $aPaths[$i]
                ConsoleWrite("[WebView2] Loaded DLL: " & $aPaths[$i] & " (AutoIt " & (@AutoItX64 ? "x64" : "x86") & ")" & @CRLF)
                Return $__g_hWV2_LoaderDll
            EndIf
        EndIf
    Next

    ConsoleWrite("[WebView2] ERROR: WebView2Loader.dll not found for " & (@AutoItX64 ? "x64" : "x86") & " architecture!" & @CRLF)
    Return SetError(1, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_IsRuntimeInstalled
; Description ...: Check if WebView2 Runtime is installed
; Syntax ........: _WebView2_IsRuntimeInstalled()
; Parameters ....: None
; Return values .: True - Runtime is installed
;                  False - Runtime is not installed
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_IsRuntimeInstalled()
    Return _WebView2Runtime_IsInstalled()
EndFunc

; ===============================================================================================================================
; Core WebView2 Functions
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Create
; Description ...: Create a native WebView2 control embedded in a window
; Syntax ........: _WebView2_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sUserDataFolder = Default, [$bCheckRuntime = True]])
; Parameters ....: $hWnd             - Handle to the parent window
;                  $iLeft            - Left position
;                  $iTop             - Top position
;                  $iWidth           - Width
;                  $iHeight          - Height
;                  $sUserDataFolder  - [optional] Path for WebView2 user data. Default is @AppDataDir & "\WebView2UDF"
;                  $bCheckRuntime    - [optional] Check and prompt for Runtime installation. Default is True.
; Return values .: Success - Array[Environment, Controller, WebView2, Settings]
;                  Failure - 0 and sets @error:
;                            1 - WebView2Loader.dll not found
;                            2 - WebView2 Runtime not installed
;                            3 - Failed to create environment
;                            4 - Failed to create controller
;                            5 - Failed to get WebView2 interface
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight, $sUserDataFolder = Default, $bCheckRuntime = True)
    ; Initialize COM (required for WebView2)
    _WV2COM_Initialize()

    ; Check runtime installation
    If $bCheckRuntime Then
        If Not _WebView2_IsRuntimeInstalled() Then
            Local $iResult = MsgBox(0x24, "WebView2 Runtime Required", _
                "Microsoft Edge WebView2 Runtime is required but not installed." & @CRLF & @CRLF & _
                "Would you like to open the download page?")
            If $iResult = 6 Then ; Yes
                ShellExecute("https://developer.microsoft.com/en-us/microsoft-edge/webview2/")
            EndIf
            Return SetError(2, 0, 0)
        EndIf
    EndIf

    ; Load WebView2Loader.dll
    If $__g_hWV2_LoaderDll = 0 Then
        _WebView2_GetLoaderDll()
        If @error Then
            Return SetError(1, @extended, 0)
        EndIf
    EndIf

    ; Set user data folder
    If $sUserDataFolder = Default Or $sUserDataFolder = "" Then
        $sUserDataFolder = $__g_sWV2_DefaultUserDataFolder
    EndIf
    If Not FileExists($sUserDataFolder) Then DirCreate($sUserDataFolder)

    ; Process pending window messages (required before WebView2 initialization)
    Local $tMSG = DllStructCreate("hwnd hWnd;uint message;wparam wParam;lparam lParam;dword time;int pt[2]")
    For $i = 1 To 20
        While DllCall("user32.dll", "bool", "PeekMessageW", "struct*", $tMSG, "hwnd", 0, "uint", 0, "uint", 0, "uint", 1)[0]
            DllCall("user32.dll", "bool", "TranslateMessage", "struct*", $tMSG)
            DllCall("user32.dll", "lresult", "DispatchMessageW", "struct*", $tMSG)
        WEnd
        Sleep(10)
    Next

    ; Initialize callback system with the parent window handle
    _WV2CB_Initialize($hWnd)

    ; Reset callback state
    _WV2CB_ResetState()

    ; Create environment handler (uses helper DLL if available)
    Local $pEnvHandler = _WV2CB_CreateEnvironmentHandler($hWnd)
    If $pEnvHandler = 0 Then Return SetError(3, 1, 0)

    ConsoleWrite("[WebView2] Creating environment..." & @CRLF)

    ; Call CreateCoreWebView2EnvironmentWithOptions
    Local $aResult = DllCall($__g_hWV2_LoaderDll, "long", "CreateCoreWebView2EnvironmentWithOptions", _
        "wstr", "", _              ; browserExecutableFolder (empty = use installed runtime)
        "wstr", $sUserDataFolder, _ ; userDataFolder
        "ptr", 0, _                 ; environmentOptions (null for defaults)
        "ptr", $pEnvHandler)        ; environmentCreatedHandler

    If @error Or $aResult[0] <> $WV2_S_OK Then
        ConsoleWrite("[WebView2] CreateCoreWebView2Environment failed: 0x" & Hex($aResult[0]) & @CRLF)
        Return SetError(3, $aResult[0], 0)
    EndIf

    ; Wait for environment creation
    Local $pEnvironment = _WV2CB_WaitForEnvironment(15000)
    If $pEnvironment = 0 Then
        ConsoleWrite("[WebView2] Environment creation timed out" & @CRLF)
        Return SetError(3, 2, 0)
    EndIf

    ConsoleWrite("[WebView2] Environment created: " & $pEnvironment & " (0x" & Hex($pEnvironment) & ")" & @CRLF)

    ; Validate environment pointer
    If $pEnvironment = 0 Or $pEnvironment < 0x10000 Then
        ConsoleWrite("[WebView2] ERROR: Invalid environment pointer!" & @CRLF)
        Return SetError(3, 3, 0)
    EndIf

    ; Create controller handler (uses helper DLL if available)
    Local $pCtrlHandler = _WV2CB_CreateControllerHandler($hWnd)
    If $pCtrlHandler = 0 Then Return SetError(4, 1, 0)

    ; Reset controller ready flag
    $__g_bWV2_ControllerReady = False

    ConsoleWrite("[WebView2] Creating controller..." & @CRLF)

    ; Call CreateCoreWebView2Controller on the environment
    ; Get VTable from environment pointer
    Local $tVTable = DllStructCreate("ptr", $pEnvironment)
    Local $pVTable = DllStructGetData($tVTable, 1)
    ConsoleWrite("[WebView2] Environment VTable: 0x" & Hex($pVTable) & @CRLF)

    If $pVTable = 0 Or $pVTable < 0x10000 Then
        ConsoleWrite("[WebView2] ERROR: Invalid VTable pointer!" & @CRLF)
        Return SetError(3, 4, 0)
    EndIf

    Local $tVTableMethods = DllStructCreate("ptr[8]", $pVTable)

    ; CreateCoreWebView2Controller is at index 3 (after QI, AddRef, Release)
    Local $pCreateController = DllStructGetData($tVTableMethods, 1, 4)
    ConsoleWrite("[WebView2] CreateController method: 0x" & Hex($pCreateController) & @CRLF)

    If $pCreateController = 0 Or $pCreateController < 0x10000 Then
        ConsoleWrite("[WebView2] ERROR: Invalid CreateController method pointer!" & @CRLF)
        Return SetError(3, 5, 0)
    EndIf

    ConsoleWrite("[WebView2] Calling CreateCoreWebView2Controller..." & @CRLF)

    ; Call CreateCoreWebView2Controller(hWnd, handler)
    $aResult = DllCallAddress("long", $pCreateController, "ptr", $pEnvironment, "hwnd", $hWnd, "ptr", $pCtrlHandler)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        ConsoleWrite("[WebView2] CreateCoreWebView2Controller failed: 0x" & Hex($aResult[0]) & @CRLF)
        Return SetError(4, $aResult[0], 0)
    EndIf

    ; Wait for controller creation
    Local $pController = _WV2CB_WaitForController(15000)
    If $pController = 0 Then
        ConsoleWrite("[WebView2] Controller creation timed out" & @CRLF)
        Return SetError(4, 2, 0)
    EndIf

    ConsoleWrite("[WebView2] Controller created: " & $pController & @CRLF)

    ; Get ICoreWebView2 - first try from callback state (set by helper DLL)
    Local $pWebView2 = $__g_pWV2_PendingWebView2

    ; If not set by helper, get it manually from controller
    If $pWebView2 = 0 Then
        Local $tCtrlVTable = DllStructCreate("ptr", $pController)
        Local $pCtrlVTable = DllStructGetData($tCtrlVTable, 1)
        Local $tCtrlMethods = DllStructCreate("ptr[26]", $pCtrlVTable)

        ; get_CoreWebView2 is at index 25
        Local $pGetCoreWebView2 = DllStructGetData($tCtrlMethods, 1, 26)

        $aResult = DllCallAddress("long", $pGetCoreWebView2, "ptr", $pController, "ptr*", 0)
        If @error Or $aResult[0] <> $WV2_S_OK Or $aResult[2] = 0 Then
            ConsoleWrite("[WebView2] get_CoreWebView2 failed: 0x" & Hex($aResult[0]) & @CRLF)
            Return SetError(5, $aResult[0], 0)
        EndIf
        $pWebView2 = $aResult[2]
    EndIf

    ConsoleWrite("[WebView2] WebView2: " & $pWebView2 & @CRLF)

    ; Set initial bounds
    _WebView2_SetBoundsInternal($pController, $iLeft, $iTop, $iWidth, $iHeight)

    ; Make visible
    _WebView2_SetVisibleInternal($pController, True)

    ; Get settings
    Local $pSettings = 0
    Local $tWV2VTable = DllStructCreate("ptr", $pWebView2)
    Local $pWV2VTable = DllStructGetData($tWV2VTable, 1)
    Local $tWV2Methods = DllStructCreate("ptr[61]", $pWV2VTable)

    ; get_Settings is at index 3
    Local $pGetSettings = DllStructGetData($tWV2Methods, 1, 4)

    $aResult = DllCallAddress("long", $pGetSettings, "ptr", $pWebView2, "ptr*", 0)
    If Not @error And $aResult[0] = $WV2_S_OK Then
        $pSettings = $aResult[2]
    EndIf

    ; Store instance
    Local $iIndex = $__g_aWV2_Instances[0][0] + 1
    ReDim $__g_aWV2_Instances[$iIndex + 1][6]
    $__g_aWV2_Instances[0][0] = $iIndex
    $__g_aWV2_Instances[$iIndex][0] = $hWnd
    $__g_aWV2_Instances[$iIndex][1] = $pEnvironment
    $__g_aWV2_Instances[$iIndex][2] = $pController
    $__g_aWV2_Instances[$iIndex][3] = $pWebView2
    $__g_aWV2_Instances[$iIndex][4] = $pSettings
    $__g_aWV2_Instances[$iIndex][5] = $sUserDataFolder

    ConsoleWrite("[WebView2] WebView2 control created successfully!" & @CRLF)

    ; Return array with pointers
    Local $aReturn[4] = [$pEnvironment, $pController, $pWebView2, $pSettings]
    Return $aReturn
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Navigate
; Description ...: Navigate to a URL
; Syntax ........: _WebView2_Navigate($pWebView2, $sUrl)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $sUrl      - URL to navigate to
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_Navigate($pWebView2, $sUrl)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; Navigate is at index 5
    Local $pNavigate = DllStructGetData($tMethods, 1, 6)

    ; Call Navigate(url)
    Local $aResult = DllCallAddress("long", $pNavigate, "ptr", $pWebView2, "wstr", $sUrl)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_NavigateToString
; Description ...: Navigate to HTML content
; Syntax ........: _WebView2_NavigateToString($pWebView2, $sHtml)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $sHtml     - HTML content to display
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_NavigateToString($pWebView2, $sHtml)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; NavigateToString is at index 6
    Local $pNavigateToString = DllStructGetData($tMethods, 1, 7)

    ; Call NavigateToString(html)
    Local $aResult = DllCallAddress("long", $pNavigateToString, "ptr", $pWebView2, "wstr", $sHtml)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_ExecuteScript
; Description ...: Execute JavaScript code and return result (synchronous)
; Syntax ........: _WebView2_ExecuteScript($pWebView2, $sScript, [$iTimeout = 5000])
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $sScript   - JavaScript code to execute
;                  $iTimeout  - [optional] Timeout in milliseconds. Default is 5000.
; Return values .: Success - JSON result string
;                  Failure - Empty string and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_ExecuteScript($pWebView2, $sScript, $iTimeout = 5000)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, "")

    ; Create script handler
    Local $pHandler = _WV2CB_CreateExecuteScriptHandler()
    If $pHandler = 0 Then Return SetError(2, 0, "")

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; ExecuteScript is at index 29
    Local $pExecuteScript = DllStructGetData($tMethods, 1, 30)

    ; Reset script complete flag
    $__g_bWV2_ScriptComplete = False

    ; Call ExecuteScript(script, handler)
    Local $aResult = DllCallAddress("long", $pExecuteScript, "ptr", $pWebView2, "wstr", $sScript, "ptr", $pHandler)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(3, $aResult[0], "")
    EndIf

    ; Wait for result
    Local $sResult = _WV2CB_WaitForScript($iTimeout)
    If @error Then Return SetError(4, 0, "")

    Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_ExecuteScriptAsync
; Description ...: Execute JavaScript code asynchronously (no wait for result)
; Syntax ........: _WebView2_ExecuteScriptAsync($pWebView2, $sScript, [$fCallback = 0])
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $sScript   - JavaScript code to execute
;                  $fCallback - [optional] Callback function for result
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_ExecuteScriptAsync($pWebView2, $sScript, $fCallback = 0)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Create script handler with callback
    Local $pHandler = _WV2CB_CreateExecuteScriptHandler($fCallback)
    If $pHandler = 0 Then Return SetError(2, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; ExecuteScript is at index 29
    Local $pExecuteScript = DllStructGetData($tMethods, 1, 30)

    ; Call ExecuteScript(script, handler)
    Local $aResult = DllCallAddress("long", $pExecuteScript, "ptr", $pWebView2, "wstr", $sScript, "ptr", $pHandler)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(3, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetSource
; Description ...: Get the current URL
; Syntax ........: _WebView2_GetSource($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - Current URL string
;                  Failure - Empty string and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GetSource($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, "")

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; get_Source is at index 4
    Local $pGetSource = DllStructGetData($tMethods, 1, 5)

    ; Call get_Source(url*)
    Local $aResult = DllCallAddress("long", $pGetSource, "ptr", $pWebView2, "ptr*", 0)
    If @error Or $aResult[0] <> $WV2_S_OK Or $aResult[2] = 0 Then
        Return SetError(2, 0, "")
    EndIf

    Local $sUrl = _WV2COM_PtrToWStr($aResult[2])
    _WV2COM_CoTaskMemFree($aResult[2])

    Return $sUrl
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetTitle
; Description ...: Get the document title
; Syntax ........: _WebView2_GetTitle($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - Document title string
;                  Failure - Empty string and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GetTitle($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, "")

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; get_DocumentTitle is at index 48
    Local $pGetTitle = DllStructGetData($tMethods, 1, 49)

    ; Call get_DocumentTitle(title*)
    Local $aResult = DllCallAddress("long", $pGetTitle, "ptr", $pWebView2, "ptr*", 0)
    If @error Or $aResult[0] <> $WV2_S_OK Or $aResult[2] = 0 Then
        Return SetError(2, 0, "")
    EndIf

    Local $sTitle = _WV2COM_PtrToWStr($aResult[2])
    _WV2COM_CoTaskMemFree($aResult[2])

    Return $sTitle
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GoBack
; Description ...: Navigate back in history
; Syntax ........: _WebView2_GoBack($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GoBack($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; GoBack is at index 40
    Local $pGoBack = DllStructGetData($tMethods, 1, 41)

    ; Call GoBack()
    Local $aResult = DllCallAddress("long", $pGoBack, "ptr", $pWebView2)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GoForward
; Description ...: Navigate forward in history
; Syntax ........: _WebView2_GoForward($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GoForward($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; GoForward is at index 41
    Local $pGoForward = DllStructGetData($tMethods, 1, 42)

    ; Call GoForward()
    Local $aResult = DllCallAddress("long", $pGoForward, "ptr", $pWebView2)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Reload
; Description ...: Reload the current page
; Syntax ........: _WebView2_Reload($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_Reload($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; Reload is at index 31
    Local $pReload = DllStructGetData($tMethods, 1, 32)

    ; Call Reload()
    Local $aResult = DllCallAddress("long", $pReload, "ptr", $pWebView2)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Stop
; Description ...: Stop navigation
; Syntax ........: _WebView2_Stop($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_Stop($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; Stop is at index 43
    Local $pStop = DllStructGetData($tMethods, 1, 44)

    ; Call Stop()
    Local $aResult = DllCallAddress("long", $pStop, "ptr", $pWebView2)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_OpenDevTools
; Description ...: Open Chrome DevTools window
; Syntax ........: _WebView2_OpenDevTools($pWebView2)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_OpenDevTools($pWebView2)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; OpenDevToolsWindow is at index 51
    Local $pOpenDevTools = DllStructGetData($tMethods, 1, 52)

    ; Call OpenDevToolsWindow()
    Local $aResult = DllCallAddress("long", $pOpenDevTools, "ptr", $pWebView2)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_PostMessage
; Description ...: Send a message to JavaScript (window.chrome.webview.postMessage)
; Syntax ........: _WebView2_PostMessage($pWebView2, $sMessage, [$bAsJson = False])
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $sMessage  - Message string to send
;                  $bAsJson   - [optional] Send as JSON (True) or String (False). Default is False.
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_PostMessage($pWebView2, $sMessage, $bAsJson = False)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    Local $pPostMessage, $aResult
    If $bAsJson Then
        ; PostWebMessageAsJson is at index 32
        $pPostMessage = DllStructGetData($tMethods, 1, 33)
    Else
        ; PostWebMessageAsString is at index 33
        $pPostMessage = DllStructGetData($tMethods, 1, 34)
    EndIf

    ; Call PostWebMessageAs*(message)
    $aResult = DllCallAddress("long", $pPostMessage, "ptr", $pWebView2, "wstr", $sMessage)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_SetZoomFactor
; Description ...: Set the zoom factor
; Syntax ........: _WebView2_SetZoomFactor($pController, $nZoomFactor)
; Parameters ....: $pController  - Pointer to ICoreWebView2Controller or array from _WebView2_Create
;                  $nZoomFactor  - Zoom factor (1.0 = 100%)
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_SetZoomFactor($pController, $nZoomFactor)
    ; Handle array input
    If IsArray($pController) Then $pController = $pController[1]
    If $pController = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pController)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[26]", $pVTable)

    ; put_ZoomFactor is at index 8
    Local $pPutZoom = DllStructGetData($tMethods, 1, 9)

    ; Call put_ZoomFactor(zoom)
    Local $aResult = DllCallAddress("long", $pPutZoom, "ptr", $pController, "double", $nZoomFactor)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetZoomFactor
; Description ...: Get the current zoom factor
; Syntax ........: _WebView2_GetZoomFactor($pController)
; Parameters ....: $pController - Pointer to ICoreWebView2Controller or array from _WebView2_Create
; Return values .: Success - Zoom factor (double)
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_GetZoomFactor($pController)
    ; Handle array input
    If IsArray($pController) Then $pController = $pController[1]
    If $pController = 0 Then Return SetError(1, 0, 0)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pController)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[26]", $pVTable)

    ; get_ZoomFactor is at index 7
    Local $pGetZoom = DllStructGetData($tMethods, 1, 8)

    ; Call get_ZoomFactor(zoom*)
    Local $tZoom = DllStructCreate("double")
    Local $aResult = DllCallAddress("long", $pGetZoom, "ptr", $pController, "struct*", $tZoom)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], 0)
    EndIf

    Return DllStructGetData($tZoom, 1)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_SetBounds
; Description ...: Set the WebView2 control bounds
; Syntax ........: _WebView2_SetBounds($pController, $iLeft, $iTop, $iWidth, $iHeight)
; Parameters ....: $pController - Pointer to ICoreWebView2Controller or array from _WebView2_Create
;                  $iLeft, $iTop, $iWidth, $iHeight - New bounds
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_SetBounds($pController, $iLeft, $iTop, $iWidth, $iHeight)
    ; Handle array input
    If IsArray($pController) Then $pController = $pController[1]
    Return _WebView2_SetBoundsInternal($pController, $iLeft, $iTop, $iWidth, $iHeight)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Close
; Description ...: Close the WebView2 control
; Syntax ........: _WebView2_Close($pController)
; Parameters ....: $pController - Pointer to ICoreWebView2Controller or array from _WebView2_Create
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_Close($pController)
    ; Handle array input
    If IsArray($pController) Then $pController = $pController[1]
    If $pController = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pController)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[26]", $pVTable)

    ; Close is at index 24
    Local $pClose = DllStructGetData($tMethods, 1, 25)

    ; Call Close()
    Local $aResult = DllCallAddress("long", $pClose, "ptr", $pController)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_SetMessageCallback
; Description ...: Set callback for web messages from JavaScript
; Syntax ........: _WebView2_SetMessageCallback($pWebView2, $fCallback)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $fCallback - Callback function: Func($sMessage)
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_SetMessageCallback($pWebView2, $fCallback)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Store callback
    $__g_fWV2_OnWebMessageReceived = $fCallback

    ; Create and register handler
    Local $pHandler = _WV2CB_CreateWebMessageHandler($fCallback)
    If $pHandler = 0 Then Return SetError(2, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; add_WebMessageReceived is at index 34
    Local $pAddHandler = DllStructGetData($tMethods, 1, 35)

    ; Call add_WebMessageReceived(handler, token*)
    Local $tToken = DllStructCreate("int64")
    Local $aResult = DllCallAddress("long", $pAddHandler, "ptr", $pWebView2, "ptr", $pHandler, "struct*", $tToken)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(3, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_SetNavigationCallback
; Description ...: Set callback for navigation completed events
; Syntax ........: _WebView2_SetNavigationCallback($pWebView2, $fCallback)
; Parameters ....: $pWebView2 - Pointer to ICoreWebView2 or array from _WebView2_Create
;                  $fCallback - Callback function: Func($bSuccess)
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WebView2_SetNavigationCallback($pWebView2, $fCallback)
    ; Handle array input
    If IsArray($pWebView2) Then $pWebView2 = $pWebView2[2]
    If $pWebView2 = 0 Then Return SetError(1, 0, False)

    ; Store callback
    $__g_fWV2_OnNavigationCompleted = $fCallback

    ; Create and register handler
    Local $pHandler = _WV2CB_CreateNavigationHandler($fCallback)
    If $pHandler = 0 Then Return SetError(2, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pWebView2)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[61]", $pVTable)

    ; add_NavigationCompleted is at index 15
    Local $pAddHandler = DllStructGetData($tMethods, 1, 16)

    ; Call add_NavigationCompleted(handler, token*)
    Local $tToken = DllStructCreate("int64")
    Local $aResult = DllCallAddress("long", $pAddHandler, "ptr", $pWebView2, "ptr", $pHandler, "struct*", $tToken)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(3, $aResult[0], False)
    EndIf

    Return True
EndFunc

; ===============================================================================================================================
; Internal Helper Functions
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
Func _WebView2_SetBoundsInternal($pController, $iLeft, $iTop, $iWidth, $iHeight)
    If $pController = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pController)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[26]", $pVTable)

    ; put_Bounds is at index 6
    Local $pPutBounds = DllStructGetData($tMethods, 1, 7)

    ; Create RECT structure (using right/bottom instead of width/height)
    Local $tRect = DllStructCreate("long left;long top;long right;long bottom")
    DllStructSetData($tRect, "left", $iLeft)
    DllStructSetData($tRect, "top", $iTop)
    DllStructSetData($tRect, "right", $iLeft + $iWidth)
    DllStructSetData($tRect, "bottom", $iTop + $iHeight)

    ; Call put_Bounds(rect) - on x64 pass struct pointer
    Local $aResult = DllCallAddress("long", $pPutBounds, "ptr", $pController, "struct*", $tRect)

    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
Func _WebView2_SetVisibleInternal($pController, $bVisible)
    If $pController = 0 Then Return SetError(1, 0, False)

    ; Get VTable
    Local $tVTable = DllStructCreate("ptr", $pController)
    Local $pVTable = DllStructGetData($tVTable, 1)
    Local $tMethods = DllStructCreate("ptr[26]", $pVTable)

    ; put_IsVisible is at index 4
    Local $pPutVisible = DllStructGetData($tMethods, 1, 5)

    ; Call put_IsVisible(visible)
    Local $aResult = DllCallAddress("long", $pPutVisible, "ptr", $pController, "bool", $bVisible)
    If @error Or $aResult[0] <> $WV2_S_OK Then
        Return SetError(2, $aResult[0], False)
    EndIf

    Return True
EndFunc

; ===============================================================================================================================
; End of WebView2_Native.au3
; ===============================================================================================================================
