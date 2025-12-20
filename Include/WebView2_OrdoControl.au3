#include-once
#include <GUIConstantsEx.au3>
#include "WebView2_Runtime.au3"

; #INDEX# =======================================================================================================================
; Title .........: WebView2_OrdoControl
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: Native Microsoft Edge WebView2 using OrdoWebView2.ocx ActiveX Control
; Author(s) .....: AutoIt Community
; ===============================================================================================================================
;
; REQUIREMENTS:
; 1. WebView2 Runtime must be installed (auto-check with WebView2_Runtime.au3)
; 2. OrdoWebView2.ocx must be registered on the system
;
; INSTALLATION:
; 1. Download OrdoWebView2 from: https://freeware.ordoconcept.net/OrdoWebview2.php
; 2. Run the installer or manually register: regsvr32 OrdoWebView2.ocx
; 3. Install WebView2 Runtime (will be checked automatically)
;
; ADVANTAGES:
; - Real Microsoft Edge (Chromium) rendering engine
; - Full modern web standards (HTML5, CSS3, ES6+)
; - Regular security updates
; - Supports React, Vue, Angular and all modern frameworks
; - Chrome DevTools for debugging
; - Much simpler than raw COM interface implementation
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WebView2Ordo_Create
; _WebView2Ordo_Navigate
; _WebView2Ordo_NavigateToString
; _WebView2Ordo_ExecuteScript
; _WebView2Ordo_ExecuteScriptAsync
; _WebView2Ordo_GetInnerText
; _WebView2Ordo_GetInnerHTML
; _WebView2Ordo_GetTitle
; _WebView2Ordo_GetURL
; _WebView2Ordo_GoBack
; _WebView2Ordo_GoForward
; _WebView2Ordo_Reload
; _WebView2Ordo_Stop
; _WebView2Ordo_SetZoomFactor
; _WebView2Ordo_GetZoomFactor
; _WebView2Ordo_OpenDevTools
; _WebView2Ordo_SetUserAgent
; _WebView2Ordo_ClearCache
; _WebView2Ordo_IsOCXRegistered
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_aWebView2Ordo_Instances[1][4] ; [0][0] = Count, [n][0] = hWnd, [n][1] = hCtrl, [n][2] = oWebView, [n][3] = UserDataFolder
Global $__g_sWebView2Ordo_DefaultUserDataFolder = @AppDataDir & "\WebView2"
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_IsOCXRegistered
; Description ...: Check if OrdoWebView2.ocx is registered on the system
; Syntax ........: _WebView2Ordo_IsOCXRegistered()
; Parameters ....: None
; Return values .: Success - True (OCX is registered)
;                  Failure - False (OCX is not registered)
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Attempts to create the COM object to verify registration
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_IsOCXRegistered()
    Local $oTest = ObjCreate("OrdoWebView2.WebView2Control")
    If IsObj($oTest) Then
        $oTest = 0 ; Release object
        Return True
    EndIf
    Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_Create
; Description ...: Create a native WebView2 control using OrdoWebView2.ocx
; Syntax ........: _WebView2Ordo_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight, [$sUserDataFolder = Default, [$bCheckRuntime = True]])
; Parameters ....: $hWnd             - Handle to the parent window
;                  $iLeft            - Left position
;                  $iTop             - Top position
;                  $iWidth           - Width
;                  $iHeight          - Height
;                  $sUserDataFolder  - [optional] Path for WebView2 user data. Default is @AppDataDir & "\WebView2"
;                  $bCheckRuntime    - [optional] Check and prompt for Runtime installation. Default is True.
; Return values .: Success - OrdoWebView2 object
;                  Failure - 0 and sets @error:
;                            1 - OrdoWebView2.ocx is not registered
;                            2 - WebView2 Runtime is not installed (and user declined installation)
;                            3 - Failed to create COM object
;                            4 - Failed to initialize control
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Requires OrdoWebView2.ocx to be registered and WebView2 Runtime installed
; Related .......: _WebView2Ordo_Navigate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_Create($hWnd, $iLeft, $iTop, $iWidth, $iHeight, $sUserDataFolder = Default, $bCheckRuntime = True)
    ; Check if OrdoWebView2.ocx is registered
    If Not _WebView2Ordo_IsOCXRegistered() Then
        MsgBox(16, "OrdoWebView2.ocx Required", _
            "OrdoWebView2.ocx is not registered on this system!" & @CRLF & @CRLF & _
            "Please download and install from:" & @CRLF & _
            "https://freeware.ordoconcept.net/OrdoWebview2.php" & @CRLF & @CRLF & _
            "Or register manually using:" & @CRLF & _
            "regsvr32 OrdoWebView2.ocx")
        Return SetError(1, 0, 0)
    EndIf

    ; Check WebView2 Runtime
    If $bCheckRuntime Then
        If Not _WebView2Runtime_CheckAndPromptInstall() Then
            Return SetError(2, 0, 0)
        EndIf
    EndIf

    ; Set user data folder
    If $sUserDataFolder = Default Then $sUserDataFolder = $__g_sWebView2Ordo_DefaultUserDataFolder
    If Not FileExists($sUserDataFolder) Then DirCreate($sUserDataFolder)

    ; Create OrdoWebView2 COM object
    Local $oWebView = ObjCreate("OrdoWebView2.WebView2Control")
    If Not IsObj($oWebView) Then
        MsgBox(16, "Error", "Failed to create OrdoWebView2.WebView2Control object!")
        Return SetError(3, 0, 0)
    EndIf

    ; Create GUI control
    Local $hCtrl = GUICtrlCreateObj($oWebView, $iLeft, $iTop, $iWidth, $iHeight)
    If $hCtrl = 0 Then
        $oWebView = 0
        MsgBox(16, "Error", "Failed to create GUI control!")
        Return SetError(4, 0, 0)
    EndIf

    ; Initialize the WebView2 control
    Local $iResult = $oWebView.InitEx($hWnd, $sUserDataFolder)
    If $iResult <> 0 Then
        ConsoleWrite("[WebView2Ordo] Warning: InitEx returned " & $iResult & @CRLF)
    EndIf

    ; Store instance
    $__g_aWebView2Ordo_Instances[0][0] += 1
    ReDim $__g_aWebView2Ordo_Instances[$__g_aWebView2Ordo_Instances[0][0] + 1][4]
    $__g_aWebView2Ordo_Instances[$__g_aWebView2Ordo_Instances[0][0]][0] = $hWnd
    $__g_aWebView2Ordo_Instances[$__g_aWebView2Ordo_Instances[0][0]][1] = $hCtrl
    $__g_aWebView2Ordo_Instances[$__g_aWebView2Ordo_Instances[0][0]][2] = $oWebView
    $__g_aWebView2Ordo_Instances[$__g_aWebView2Ordo_Instances[0][0]][3] = $sUserDataFolder

    Return $oWebView
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_Navigate
; Description ...: Navigate to a URL
; Syntax ........: _WebView2Ordo_Navigate($oWebView, $sURL)
; Parameters ....: $oWebView - OrdoWebView2 object
;                  $sURL     - URL to navigate to
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_Navigate($oWebView, $sURL)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.Navigate($sURL)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_NavigateToString
; Description ...: Navigate to HTML content from string
; Syntax ........: _WebView2Ordo_NavigateToString($oWebView, $sHTML)
; Parameters ....: $oWebView - OrdoWebView2 object
;                  $sHTML    - HTML string
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_NavigateToString($oWebView, $sHTML)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.NavigateToString($sHTML)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_ExecuteScript
; Description ...: Execute JavaScript synchronously (blocking)
; Syntax ........: _WebView2Ordo_ExecuteScript($oWebView, $sScript)
; Parameters ....: $oWebView - OrdoWebView2 object
;                  $sScript  - JavaScript code
; Return values .: Success - Result string
;                  Failure - "" and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: This is a synchronous call and will block until script completes
; Related .......: _WebView2Ordo_ExecuteScriptAsync
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_ExecuteScript($oWebView, $sScript)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")
    Local $sResult = $oWebView.RunJs($sScript)
    Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_ExecuteScriptAsync
; Description ...: Execute JavaScript asynchronously (non-blocking)
; Syntax ........: _WebView2Ordo_ExecuteScriptAsync($oWebView, $sScript)
; Parameters ....: $oWebView - OrdoWebView2 object
;                  $sScript  - JavaScript code
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Result is not returned. Use for fire-and-forget scripts.
; Related .......: _WebView2Ordo_ExecuteScript
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_ExecuteScriptAsync($oWebView, $sScript)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.RunJsAsync($sScript)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GetInnerText
; Description ...: Get inner text of the document
; Syntax ........: _WebView2Ordo_GetInnerText($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - Text content
;                  Failure - "" and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_GetInnerHTML
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GetInnerText($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")
    Return $oWebView.GetInnerText()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GetInnerHTML
; Description ...: Get inner HTML of the document
; Syntax ........: _WebView2Ordo_GetInnerHTML($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - HTML content
;                  Failure - "" and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_GetInnerText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GetInnerHTML($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")
    Return $oWebView.GetInnerHTML()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GetTitle
; Description ...: Get title of current page
; Syntax ........: _WebView2Ordo_GetTitle($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - Page title
;                  Failure - "" and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GetTitle($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")
    Return $oWebView.GetDocumentTitle()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GetURL
; Description ...: Get URL of current page
; Syntax ........: _WebView2Ordo_GetURL($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - Current URL
;                  Failure - "" and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GetURL($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")
    Return $oWebView.GetUrl()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GoBack
; Description ...: Navigate back in history
; Syntax ........: _WebView2Ordo_GoBack($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_GoForward
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GoBack($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.GoBack()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GoForward
; Description ...: Navigate forward in history
; Syntax ........: _WebView2Ordo_GoForward($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_GoBack
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GoForward($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.GoForward()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_Reload
; Description ...: Reload current page
; Syntax ........: _WebView2Ordo_Reload($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_Reload($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.Reload()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_Stop
; Description ...: Stop loading current page
; Syntax ........: _WebView2Ordo_Stop($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_Stop($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.Stop()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_SetZoomFactor
; Description ...: Set zoom factor
; Syntax ........: _WebView2Ordo_SetZoomFactor($oWebView, $fZoom)
; Parameters ....: $oWebView - OrdoWebView2 object
;                  $fZoom    - Zoom factor (1.0 = 100%, 1.5 = 150%, etc.)
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_GetZoomFactor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_SetZoomFactor($oWebView, $fZoom)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.SetZoomFactor($fZoom)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_GetZoomFactor
; Description ...: Get current zoom factor
; Syntax ........: _WebView2Ordo_GetZoomFactor($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - Zoom factor
;                  Failure - 0 and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Ordo_SetZoomFactor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_GetZoomFactor($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, 0)
    Return $oWebView.GetZoomFactor()
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_OpenDevTools
; Description ...: Open Chrome DevTools for debugging
; Syntax ........: _WebView2Ordo_OpenDevTools($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Opens a separate window with Chrome Developer Tools (F12)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Ordo_OpenDevTools($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.OpenDevToolsWindow()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_SetUserAgent
; Description ...: Set custom User-Agent string
; Syntax ........: _WebView2Ordo_SetUserAgent($oWebView, $sUserAgent)
; Parameters ....: $oWebView    - OrdoWebView2 object
;                  $sUserAgent  - User-Agent string
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Must be set before navigation
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Ordo_SetUserAgent($oWebView, $sUserAgent)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.SetUserAgent($sUserAgent)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Ordo_ClearCache
; Description ...: Clear browser cache and cookies
; Syntax ........: _WebView2Ordo_ClearCache($oWebView)
; Parameters ....: $oWebView - OrdoWebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Ordo_ClearCache($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)
    $oWebView.ClearCache()
    Return True
EndFunc
