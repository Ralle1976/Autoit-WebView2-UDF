#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPICom.au3>

; #INDEX# =======================================================================================================================
; Title .........: WebView2 (Internet Explorer Compatibility Layer)
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: LEGACY COMPATIBILITY - Functions using Internet Explorer Control (Shell.Explorer.2)
; Author(s) .....: AutoIt Community
; ===============================================================================================================================
;
; !!!!! IMPORTANT WARNING !!!!!
; This UDF uses the Internet Explorer ActiveX control (Shell.Explorer.2), NOT the native Microsoft Edge WebView2!
;
; LIMITATIONS:
; - No modern web standards (HTML5, CSS3, ES6+)
; - Security vulnerabilities (IE is deprecated since 2022)
; - Inconsistent rendering across Windows versions
; - Limited JavaScript support (ES5 only)
; - Cannot run modern web frameworks (React, Vue, Angular, etc.)
;
; FOR PRODUCTION USE:
; - Use Include\WebView2_Native.au3 for native Edge WebView2 implementation
; - Or use Include\WebView2_OrdoControl.au3 for simplified WebView2 via OrdoWebView2.ocx
; - Requires WebView2 Runtime: https://developer.microsoft.com/microsoft-edge/webview2
;
; THIS FILE IS PROVIDED FOR:
; - Legacy application compatibility
; - Testing and development on systems without WebView2
; - Simple HTML display where modern web standards are not required
;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WebView2_Startup
; _WebView2_Shutdown
; _WebView2_Create
; _WebView2_CreateAsync
; _WebView2_Navigate
; _WebView2_NavigateToString
; _WebView2_ExecuteScript
; _WebView2_GetSource
; _WebView2_GetTitle
; _WebView2_GetURL
; _WebView2_GoBack
; _WebView2_GoForward
; _WebView2_Reload
; _WebView2_Stop
; _WebView2_AddScriptToExecuteOnDocumentCreated
; _WebView2_PostWebMessageAsJSON
; _WebView2_PostWebMessageAsString
; _WebView2_OpenDevTools
; _WebView2_SetZoomFactor
; _WebView2_GetZoomFactor
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
; __WebView2_CreateEnvironment
; __WebView2_ErrorHandler
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_oWebView2_COM_ErrorHandler = ObjEvent("AutoIt.Error", "__WebView2_ErrorHandler")
Global $__g_aWebView2_Instances[1][5] ; [0][0] = Count, [n][0] = hWnd, [n][1] = Controller, [n][2] = WebView, [n][3] = Environment, [n][4] = Settings
Global $__g_sWebView2_UserDataFolder = @TempDir & "\WebView2"
Global $__g_bWebView2_Initialized = False
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Startup
; Description ...: Initialize the WebView2 UDF
; Syntax ........: _WebView2_Startup([$sUserDataFolder = Default])
; Parameters ....: $sUserDataFolder - [optional] Path to user data folder. Default is @TempDir & "\WebView2"
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Startup($sUserDataFolder = Default)
    If $__g_bWebView2_Initialized Then Return True

    If $sUserDataFolder = Default Then $sUserDataFolder = $__g_sWebView2_UserDataFolder
    $__g_sWebView2_UserDataFolder = $sUserDataFolder

    ; Create user data folder if it doesn't exist
    If Not FileExists($sUserDataFolder) Then DirCreate($sUserDataFolder)

    $__g_bWebView2_Initialized = True
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Shutdown
; Description ...: Shutdown the WebView2 UDF and cleanup resources
; Syntax ........: _WebView2_Shutdown()
; Parameters ....: None
; Return values .: Success - True
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Shutdown()
    ; Cleanup all instances
    For $i = 1 To $__g_aWebView2_Instances[0][0]
        If IsObj($__g_aWebView2_Instances[$i][1]) Then $__g_aWebView2_Instances[$i][1] = 0
        If IsObj($__g_aWebView2_Instances[$i][2]) Then $__g_aWebView2_Instances[$i][2] = 0
        If IsObj($__g_aWebView2_Instances[$i][3]) Then $__g_aWebView2_Instances[$i][3] = 0
        If IsObj($__g_aWebView2_Instances[$i][4]) Then $__g_aWebView2_Instances[$i][4] = 0
    Next

    ReDim $__g_aWebView2_Instances[1][5]
    $__g_aWebView2_Instances[0][0] = 0

    $__g_bWebView2_Initialized = False
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Create
; Description ...: Create a WebView2 control in a window
; Syntax ........: _WebView2_Create($hWnd, [$iLeft = 0, [$iTop = 0, [$iWidth = 800, [$iHeight = 600]]]])
; Parameters ....: $hWnd   - Handle to the parent window
;                  $iLeft  - [optional] Left position. Default is 0.
;                  $iTop   - [optional] Top position. Default is 0.
;                  $iWidth - [optional] Width. Default is 800.
;                  $iHeight- [optional] Height. Default is 600.
; Return values .: Success - WebView2 object
;                  Failure - 0 and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......: This is a simplified version. Full implementation requires WebView2Loader.dll
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Create($hWnd, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 600)
    If Not $__g_bWebView2_Initialized Then _WebView2_Startup()

    ; Create OLE control container
    Local $oWebView = ObjCreate("Shell.Explorer.2")
    If Not IsObj($oWebView) Then Return SetError(1, 0, 0)

    ; Embed in GUI
    Local $hWebView = GUICtrlCreateObj($oWebView, $iLeft, $iTop, $iWidth, $iHeight)
    If $hWebView = 0 Then Return SetError(2, 0, 0)

    ; Store instance
    $__g_aWebView2_Instances[0][0] += 1
    ReDim $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0] + 1][5]
    $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0]][0] = $hWnd
    $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0]][1] = 0 ; Controller
    $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0]][2] = $oWebView ; WebView object
    $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0]][3] = 0 ; Environment
    $__g_aWebView2_Instances[$__g_aWebView2_Instances[0][0]][4] = 0 ; Settings

    Return $oWebView
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Navigate
; Description ...: Navigate to a URL
; Syntax ........: _WebView2_Navigate($oWebView, $sURL)
; Parameters ....: $oWebView - WebView2 object
;                  $sURL     - URL to navigate to
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Navigate($oWebView, $sURL)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    $oWebView.Navigate($sURL)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_NavigateToString
; Description ...: Navigate to HTML string
; Syntax ........: _WebView2_NavigateToString($oWebView, $sHTML)
; Parameters ....: $oWebView - WebView2 object
;                  $sHTML    - HTML string
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_NavigateToString($oWebView, $sHTML)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    ; Create temporary HTML file
    Local $sTempFile = @TempDir & "\WebView2_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC & ".html"
    FileWrite($sTempFile, $sHTML)

    $oWebView.Navigate($sTempFile)
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_ExecuteScript
; Description ...: Execute JavaScript code
; Syntax ........: _WebView2_ExecuteScript($oWebView, $sScript)
; Parameters ....: $oWebView - WebView2 object
;                  $sScript  - JavaScript code to execute
; Return values .: Success - Result of script execution
;                  Failure - "" and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_ExecuteScript($oWebView, $sScript)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")

    Local $oDoc = $oWebView.Document
    If Not IsObj($oDoc) Then Return SetError(2, 0, "")

    Local $oWindow = $oDoc.ParentWindow
    If Not IsObj($oWindow) Then Return SetError(3, 0, "")

    Local $vResult = $oWindow.ExecScript($sScript, "JavaScript")
    Return $vResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetSource
; Description ...: Get HTML source of current page
; Syntax ........: _WebView2_GetSource($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - HTML source
;                  Failure - "" and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GetSource($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")

    Local $oDoc = $oWebView.Document
    If Not IsObj($oDoc) Then Return SetError(2, 0, "")

    Return $oDoc.DocumentElement.OuterHTML
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetTitle
; Description ...: Get title of current page
; Syntax ........: _WebView2_GetTitle($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - Page title
;                  Failure - "" and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GetTitle($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")

    Local $oDoc = $oWebView.Document
    If Not IsObj($oDoc) Then Return SetError(2, 0, "")

    Return $oDoc.Title
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetURL
; Description ...: Get URL of current page
; Syntax ........: _WebView2_GetURL($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - Current URL
;                  Failure - "" and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GetURL($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, "")

    Return $oWebView.LocationURL
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GoBack
; Description ...: Navigate back in history
; Syntax ........: _WebView2_GoBack($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GoBack($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    $oWebView.GoBack()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GoForward
; Description ...: Navigate forward in history
; Syntax ........: _WebView2_GoForward($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GoForward($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    $oWebView.GoForward()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Reload
; Description ...: Reload current page
; Syntax ........: _WebView2_Reload($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Reload($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    $oWebView.Refresh()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_Stop
; Description ...: Stop loading current page
; Syntax ........: _WebView2_Stop($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_Stop($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    $oWebView.Stop()
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_SetZoomFactor
; Description ...: Set zoom factor
; Syntax ........: _WebView2_SetZoomFactor($oWebView, $fZoom)
; Parameters ....: $oWebView - WebView2 object
;                  $fZoom    - Zoom factor (1.0 = 100%)
; Return values .: Success - True
;                  Failure - False and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_SetZoomFactor($oWebView, $fZoom)
    If Not IsObj($oWebView) Then Return SetError(1, 0, False)

    ; Note: This uses Internet Explorer zoom, not WebView2 zoom
    ; For true WebView2, you need the native WebView2 API
    Local $oDoc = $oWebView.Document
    If Not IsObj($oDoc) Then Return SetError(2, 0, False)

    $oDoc.Body.Style.Zoom = $fZoom
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2_GetZoomFactor
; Description ...: Get current zoom factor
; Syntax ........: _WebView2_GetZoomFactor($oWebView)
; Parameters ....: $oWebView - WebView2 object
; Return values .: Success - Zoom factor
;                  Failure - 0 and sets @error
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2_GetZoomFactor($oWebView)
    If Not IsObj($oWebView) Then Return SetError(1, 0, 0)

    Local $oDoc = $oWebView.Document
    If Not IsObj($oDoc) Then Return SetError(2, 0, 0)

    Return $oDoc.Body.Style.Zoom
EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name ..........: __WebView2_ErrorHandler
; Description ...: COM Error Handler
; Syntax ........: __WebView2_ErrorHandler()
; Parameters ....: None
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......: Internal use only
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __WebView2_ErrorHandler()
    Local $oError = $__g_oWebView2_COM_ErrorHandler
    ConsoleWrite("! COM Error: " & $oError.Description & @CRLF)
    ConsoleWrite("! Number: 0x" & Hex($oError.Number) & @CRLF)
    ConsoleWrite("! WinDescription: " & $oError.WinDescription & @CRLF)
    Return
EndFunc
