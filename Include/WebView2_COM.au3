#include-once
; Note: We avoid including WinAPIConstants.au3 to prevent constant conflicts
; Instead we define our own prefixed versions

; #INDEX# =======================================================================================================================
; Title .........: WebView2_COM
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: COM Interface definitions for native Microsoft Edge WebView2
; Author(s) .....: Ralle1976
; ===============================================================================================================================
;
; This file contains all COM interface GUIDs, method indices, and structure definitions
; required for native WebView2 integration without third-party OCX controls.
;
; Based on Microsoft WebView2 SDK COM API
; https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/
;
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

; ===============================================================================================================================
; WebView2 Environment Creation Options
; ===============================================================================================================================
Global Const $COREWEBVIEW2_BROWSER_EXECUTABLE_FOLDER = ""
Global Const $COREWEBVIEW2_USER_DATA_FOLDER_DEFAULT = @AppDataDir & "\WebView2UDF"

; ===============================================================================================================================
; Interface GUIDs - Core WebView2 Interfaces
; ===============================================================================================================================
Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"
Global Const $sIID_ICoreWebView2 = "{76ECEACB-0462-4D94-AC83-423A6793775E}"
Global Const $sIID_ICoreWebView2_2 = "{9E8F0CF8-E670-4B5E-B2BC-73E061E3184C}"
Global Const $sIID_ICoreWebView2Controller = "{4D00C0D1-9434-4EB6-8078-8697A560334F}"
Global Const $sIID_ICoreWebView2Environment = "{B96D755E-0319-4E92-A296-23436F46A1FC}"
Global Const $sIID_ICoreWebView2Settings = "{E562E4F0-D7FA-43AC-8D71-C05150499F00}"

; Environment Handler Interfaces
Global Const $sIID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler = "{4E8A3389-C9D8-4BD2-B6B5-124FEE6CC14D}"
Global Const $sIID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler = "{6C4819F3-C9B7-4260-8127-C9F5BDE7F68C}"

; Navigation Handler Interfaces
Global Const $sIID_ICoreWebView2NavigationStartingEventHandler = "{9ADBE429-F36D-432B-9DDC-F8881FBD76E3}"
Global Const $sIID_ICoreWebView2NavigationCompletedEventHandler = "{D33A35BF-1C49-4F98-93AB-006E0533FE1C}"
Global Const $sIID_ICoreWebView2ContentLoadingEventHandler = "{364471E7-F2BE-4910-BDBA-D72077D51C4B}"

; Script/Message Handler Interfaces
Global Const $sIID_ICoreWebView2ExecuteScriptCompletedHandler = "{49511172-CC67-4BCA-9923-137112F4C4CC}"
Global Const $sIID_ICoreWebView2WebMessageReceivedEventHandler = "{57213F19-00E6-49FA-8E07-898EA01ECBD2}"
Global Const $sIID_ICoreWebView2AddScriptToExecuteOnDocumentCreatedCompletedHandler = "{B99369F3-9B11-47B5-BC6F-8E7895FCEA17}"

; Event Args Interfaces
Global Const $sIID_ICoreWebView2NavigationStartingEventArgs = "{5B495469-E119-438A-9B18-7604F25F2E49}"
Global Const $sIID_ICoreWebView2NavigationCompletedEventArgs = "{30D68B7D-20D9-4752-A9CA-EC8448FBB5C1}"
Global Const $sIID_ICoreWebView2WebMessageReceivedEventArgs = "{0F99A40C-E962-4207-9E92-E3D542EFF849}"
Global Const $sIID_ICoreWebView2ContentLoadingEventArgs = "{0C8A1275-9B6B-4901-87AD-70DF25BAFA6E}"

; ===============================================================================================================================
; ICoreWebView2Environment VTable Method Indices (0-based, after IUnknown)
; IUnknown: QueryInterface=0, AddRef=1, Release=2
; ===============================================================================================================================
Global Const $ICoreWebView2Environment_QueryInterface = 0
Global Const $ICoreWebView2Environment_AddRef = 1
Global Const $ICoreWebView2Environment_Release = 2
Global Const $ICoreWebView2Environment_CreateCoreWebView2Controller = 3
Global Const $ICoreWebView2Environment_CreateWebResourceResponse = 4
Global Const $ICoreWebView2Environment_get_BrowserVersionString = 5
Global Const $ICoreWebView2Environment_add_NewBrowserVersionAvailable = 6
Global Const $ICoreWebView2Environment_remove_NewBrowserVersionAvailable = 7

; ===============================================================================================================================
; ICoreWebView2Controller VTable Method Indices
; ===============================================================================================================================
Global Const $ICoreWebView2Controller_QueryInterface = 0
Global Const $ICoreWebView2Controller_AddRef = 1
Global Const $ICoreWebView2Controller_Release = 2
Global Const $ICoreWebView2Controller_get_IsVisible = 3
Global Const $ICoreWebView2Controller_put_IsVisible = 4
Global Const $ICoreWebView2Controller_get_Bounds = 5
Global Const $ICoreWebView2Controller_put_Bounds = 6
Global Const $ICoreWebView2Controller_get_ZoomFactor = 7
Global Const $ICoreWebView2Controller_put_ZoomFactor = 8
Global Const $ICoreWebView2Controller_add_ZoomFactorChanged = 9
Global Const $ICoreWebView2Controller_remove_ZoomFactorChanged = 10
Global Const $ICoreWebView2Controller_SetBoundsAndZoomFactor = 11
Global Const $ICoreWebView2Controller_MoveFocus = 12
Global Const $ICoreWebView2Controller_add_MoveFocusRequested = 13
Global Const $ICoreWebView2Controller_remove_MoveFocusRequested = 14
Global Const $ICoreWebView2Controller_add_GotFocus = 15
Global Const $ICoreWebView2Controller_remove_GotFocus = 16
Global Const $ICoreWebView2Controller_add_LostFocus = 17
Global Const $ICoreWebView2Controller_remove_LostFocus = 18
Global Const $ICoreWebView2Controller_add_AcceleratorKeyPressed = 19
Global Const $ICoreWebView2Controller_remove_AcceleratorKeyPressed = 20
Global Const $ICoreWebView2Controller_get_ParentWindow = 21
Global Const $ICoreWebView2Controller_put_ParentWindow = 22
Global Const $ICoreWebView2Controller_NotifyParentWindowPositionChanged = 23
Global Const $ICoreWebView2Controller_Close = 24
Global Const $ICoreWebView2Controller_get_CoreWebView2 = 25

; ===============================================================================================================================
; ICoreWebView2 VTable Method Indices
; ===============================================================================================================================
Global Const $ICoreWebView2_QueryInterface = 0
Global Const $ICoreWebView2_AddRef = 1
Global Const $ICoreWebView2_Release = 2
Global Const $ICoreWebView2_get_Settings = 3
Global Const $ICoreWebView2_get_Source = 4
Global Const $ICoreWebView2_Navigate = 5
Global Const $ICoreWebView2_NavigateToString = 6
Global Const $ICoreWebView2_add_NavigationStarting = 7
Global Const $ICoreWebView2_remove_NavigationStarting = 8
Global Const $ICoreWebView2_add_ContentLoading = 9
Global Const $ICoreWebView2_remove_ContentLoading = 10
Global Const $ICoreWebView2_add_SourceChanged = 11
Global Const $ICoreWebView2_remove_SourceChanged = 12
Global Const $ICoreWebView2_add_HistoryChanged = 13
Global Const $ICoreWebView2_remove_HistoryChanged = 14
Global Const $ICoreWebView2_add_NavigationCompleted = 15
Global Const $ICoreWebView2_remove_NavigationCompleted = 16
Global Const $ICoreWebView2_add_FrameNavigationStarting = 17
Global Const $ICoreWebView2_remove_FrameNavigationStarting = 18
Global Const $ICoreWebView2_add_FrameNavigationCompleted = 19
Global Const $ICoreWebView2_remove_FrameNavigationCompleted = 20
Global Const $ICoreWebView2_add_ScriptDialogOpening = 21
Global Const $ICoreWebView2_remove_ScriptDialogOpening = 22
Global Const $ICoreWebView2_add_PermissionRequested = 23
Global Const $ICoreWebView2_remove_PermissionRequested = 24
Global Const $ICoreWebView2_add_ProcessFailed = 25
Global Const $ICoreWebView2_remove_ProcessFailed = 26
Global Const $ICoreWebView2_AddScriptToExecuteOnDocumentCreated = 27
Global Const $ICoreWebView2_RemoveScriptToExecuteOnDocumentCreated = 28
Global Const $ICoreWebView2_ExecuteScript = 29
Global Const $ICoreWebView2_CapturePreview = 30
Global Const $ICoreWebView2_Reload = 31
Global Const $ICoreWebView2_PostWebMessageAsJson = 32
Global Const $ICoreWebView2_PostWebMessageAsString = 33
Global Const $ICoreWebView2_add_WebMessageReceived = 34
Global Const $ICoreWebView2_remove_WebMessageReceived = 35
Global Const $ICoreWebView2_CallDevToolsProtocolMethod = 36
Global Const $ICoreWebView2_get_BrowserProcessId = 37
Global Const $ICoreWebView2_get_CanGoBack = 38
Global Const $ICoreWebView2_get_CanGoForward = 39
Global Const $ICoreWebView2_GoBack = 40
Global Const $ICoreWebView2_GoForward = 41
Global Const $ICoreWebView2_GetDevToolsProtocolEventReceiver = 42
Global Const $ICoreWebView2_Stop = 43
Global Const $ICoreWebView2_add_NewWindowRequested = 44
Global Const $ICoreWebView2_remove_NewWindowRequested = 45
Global Const $ICoreWebView2_add_DocumentTitleChanged = 46
Global Const $ICoreWebView2_remove_DocumentTitleChanged = 47
Global Const $ICoreWebView2_get_DocumentTitle = 48
Global Const $ICoreWebView2_AddHostObjectToScript = 49
Global Const $ICoreWebView2_RemoveHostObjectFromScript = 50
Global Const $ICoreWebView2_OpenDevToolsWindow = 51
Global Const $ICoreWebView2_add_ContainsFullScreenElementChanged = 52
Global Const $ICoreWebView2_remove_ContainsFullScreenElementChanged = 53
Global Const $ICoreWebView2_get_ContainsFullScreenElement = 54
Global Const $ICoreWebView2_add_WebResourceRequested = 55
Global Const $ICoreWebView2_remove_WebResourceRequested = 56
Global Const $ICoreWebView2_AddWebResourceRequestedFilter = 57
Global Const $ICoreWebView2_RemoveWebResourceRequestedFilter = 58
Global Const $ICoreWebView2_add_WindowCloseRequested = 59
Global Const $ICoreWebView2_remove_WindowCloseRequested = 60

; ===============================================================================================================================
; ICoreWebView2Settings VTable Method Indices
; ===============================================================================================================================
Global Const $ICoreWebView2Settings_QueryInterface = 0
Global Const $ICoreWebView2Settings_AddRef = 1
Global Const $ICoreWebView2Settings_Release = 2
Global Const $ICoreWebView2Settings_get_IsScriptEnabled = 3
Global Const $ICoreWebView2Settings_put_IsScriptEnabled = 4
Global Const $ICoreWebView2Settings_get_IsWebMessageEnabled = 5
Global Const $ICoreWebView2Settings_put_IsWebMessageEnabled = 6
Global Const $ICoreWebView2Settings_get_AreDefaultScriptDialogsEnabled = 7
Global Const $ICoreWebView2Settings_put_AreDefaultScriptDialogsEnabled = 8
Global Const $ICoreWebView2Settings_get_IsStatusBarEnabled = 9
Global Const $ICoreWebView2Settings_put_IsStatusBarEnabled = 10
Global Const $ICoreWebView2Settings_get_AreDevToolsEnabled = 11
Global Const $ICoreWebView2Settings_put_AreDevToolsEnabled = 12
Global Const $ICoreWebView2Settings_get_AreDefaultContextMenusEnabled = 13
Global Const $ICoreWebView2Settings_put_AreDefaultContextMenusEnabled = 14
Global Const $ICoreWebView2Settings_get_AreHostObjectsAllowed = 15
Global Const $ICoreWebView2Settings_put_AreHostObjectsAllowed = 16
Global Const $ICoreWebView2Settings_get_IsZoomControlEnabled = 17
Global Const $ICoreWebView2Settings_put_IsZoomControlEnabled = 18
Global Const $ICoreWebView2Settings_get_IsBuiltInErrorPageEnabled = 19
Global Const $ICoreWebView2Settings_put_IsBuiltInErrorPageEnabled = 20

; ===============================================================================================================================
; HRESULT Constants (WebView2 specific - using WV2 prefix to avoid conflicts)
; ===============================================================================================================================
Global Const $WV2_S_OK = 0x00000000
Global Const $WV2_E_FAIL = 0x80004005
Global Const $WV2_E_INVALIDARG = 0x80070057
Global Const $WV2_E_NOINTERFACE = 0x80004002
Global Const $WV2_E_POINTER = 0x80004003
Global Const $WV2_E_UNEXPECTED = 0x8000FFFF
Global Const $WV2_E_OUTOFMEMORY = 0x8007000E

; ===============================================================================================================================
; COREWEBVIEW2_MOVE_FOCUS_REASON Enumeration
; ===============================================================================================================================
Global Const $COREWEBVIEW2_MOVE_FOCUS_REASON_PROGRAMMATIC = 0
Global Const $COREWEBVIEW2_MOVE_FOCUS_REASON_NEXT = 1
Global Const $COREWEBVIEW2_MOVE_FOCUS_REASON_PREVIOUS = 2

; ===============================================================================================================================
; COREWEBVIEW2_WEB_ERROR_STATUS Enumeration
; ===============================================================================================================================
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN = 0
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_COMMON_NAME_IS_INCORRECT = 1
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_EXPIRED = 2
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CLIENT_CERTIFICATE_CONTAINS_ERRORS = 3
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_REVOKED = 4
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_IS_INVALID = 5
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_SERVER_UNREACHABLE = 6
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_TIMEOUT = 7
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_ERROR_HTTP_INVALID_SERVER_RESPONSE = 8
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_ABORTED = 9
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_RESET = 10
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_DISCONNECTED = 11
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_CANNOT_CONNECT = 12
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_HOST_NAME_NOT_RESOLVED = 13
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_OPERATION_CANCELED = 14
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_REDIRECT_FAILED = 15
Global Const $COREWEBVIEW2_WEB_ERROR_STATUS_UNEXPECTED_ERROR = 16

; ===============================================================================================================================
; COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT Enumeration
; ===============================================================================================================================
Global Const $COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT_PNG = 0
Global Const $COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT_JPEG = 1

; ===============================================================================================================================
; Structure Tag Definitions (for DllStructCreate) - using WV2 prefix to avoid conflicts
; ===============================================================================================================================
Global Const $tagWV2_GUID = "ulong Data1;ushort Data2;ushort Data3;byte Data4[8]"
Global Const $tagWV2_RECT = "long Left;long Top;long Right;long Bottom"
Global Const $tagWV2_POINT = "long X;long Y"
Global Const $tagWV2_SIZE = "long Width;long Height"

; ===============================================================================================================================
; VTable Descriptor Strings for ObjCreateInterface
; Used to create AutoIt objects from raw COM interface pointers
; ===============================================================================================================================

; ICoreWebView2Environment VTable
Global Const $dtag_ICoreWebView2Environment = _
    "QueryInterface hresult(ptr;ptr*);" & _
    "AddRef ulong();" & _
    "Release ulong();" & _
    "CreateCoreWebView2Controller hresult(hwnd;ptr);" & _
    "CreateWebResourceResponse hresult(ptr;int;wstr;wstr;ptr*);" & _
    "get_BrowserVersionString hresult(wstr*);" & _
    "add_NewBrowserVersionAvailable hresult(ptr;int64*);" & _
    "remove_NewBrowserVersionAvailable hresult(int64);"

; ICoreWebView2Controller VTable
Global Const $dtag_ICoreWebView2Controller = _
    "QueryInterface hresult(ptr;ptr*);" & _
    "AddRef ulong();" & _
    "Release ulong();" & _
    "get_IsVisible hresult(bool*);" & _
    "put_IsVisible hresult(bool);" & _
    "get_Bounds hresult(struct*);" & _
    "put_Bounds hresult(struct);" & _
    "get_ZoomFactor hresult(double*);" & _
    "put_ZoomFactor hresult(double);" & _
    "add_ZoomFactorChanged hresult(ptr;int64*);" & _
    "remove_ZoomFactorChanged hresult(int64);" & _
    "SetBoundsAndZoomFactor hresult(struct;double);" & _
    "MoveFocus hresult(int);" & _
    "add_MoveFocusRequested hresult(ptr;int64*);" & _
    "remove_MoveFocusRequested hresult(int64);" & _
    "add_GotFocus hresult(ptr;int64*);" & _
    "remove_GotFocus hresult(int64);" & _
    "add_LostFocus hresult(ptr;int64*);" & _
    "remove_LostFocus hresult(int64);" & _
    "add_AcceleratorKeyPressed hresult(ptr;int64*);" & _
    "remove_AcceleratorKeyPressed hresult(int64);" & _
    "get_ParentWindow hresult(hwnd*);" & _
    "put_ParentWindow hresult(hwnd);" & _
    "NotifyParentWindowPositionChanged hresult();" & _
    "Close hresult();" & _
    "get_CoreWebView2 hresult(ptr*);"

; ICoreWebView2 VTable (partial - most used methods)
Global Const $dtag_ICoreWebView2 = _
    "QueryInterface hresult(ptr;ptr*);" & _
    "AddRef ulong();" & _
    "Release ulong();" & _
    "get_Settings hresult(ptr*);" & _
    "get_Source hresult(wstr*);" & _
    "Navigate hresult(wstr);" & _
    "NavigateToString hresult(wstr);" & _
    "add_NavigationStarting hresult(ptr;int64*);" & _
    "remove_NavigationStarting hresult(int64);" & _
    "add_ContentLoading hresult(ptr;int64*);" & _
    "remove_ContentLoading hresult(int64);" & _
    "add_SourceChanged hresult(ptr;int64*);" & _
    "remove_SourceChanged hresult(int64);" & _
    "add_HistoryChanged hresult(ptr;int64*);" & _
    "remove_HistoryChanged hresult(int64);" & _
    "add_NavigationCompleted hresult(ptr;int64*);" & _
    "remove_NavigationCompleted hresult(int64);" & _
    "add_FrameNavigationStarting hresult(ptr;int64*);" & _
    "remove_FrameNavigationStarting hresult(int64);" & _
    "add_FrameNavigationCompleted hresult(ptr;int64*);" & _
    "remove_FrameNavigationCompleted hresult(int64);" & _
    "add_ScriptDialogOpening hresult(ptr;int64*);" & _
    "remove_ScriptDialogOpening hresult(int64);" & _
    "add_PermissionRequested hresult(ptr;int64*);" & _
    "remove_PermissionRequested hresult(int64);" & _
    "add_ProcessFailed hresult(ptr;int64*);" & _
    "remove_ProcessFailed hresult(int64);" & _
    "AddScriptToExecuteOnDocumentCreated hresult(wstr;ptr);" & _
    "RemoveScriptToExecuteOnDocumentCreated hresult(wstr);" & _
    "ExecuteScript hresult(wstr;ptr);" & _
    "CapturePreview hresult(int;ptr;ptr);" & _
    "Reload hresult();" & _
    "PostWebMessageAsJson hresult(wstr);" & _
    "PostWebMessageAsString hresult(wstr);" & _
    "add_WebMessageReceived hresult(ptr;int64*);" & _
    "remove_WebMessageReceived hresult(int64);" & _
    "CallDevToolsProtocolMethod hresult(wstr;wstr;ptr);" & _
    "get_BrowserProcessId hresult(uint*);" & _
    "get_CanGoBack hresult(bool*);" & _
    "get_CanGoForward hresult(bool*);" & _
    "GoBack hresult();" & _
    "GoForward hresult();" & _
    "GetDevToolsProtocolEventReceiver hresult(wstr;ptr*);" & _
    "Stop hresult();" & _
    "add_NewWindowRequested hresult(ptr;int64*);" & _
    "remove_NewWindowRequested hresult(int64);" & _
    "add_DocumentTitleChanged hresult(ptr;int64*);" & _
    "remove_DocumentTitleChanged hresult(int64);" & _
    "get_DocumentTitle hresult(wstr*);" & _
    "AddHostObjectToScript hresult(wstr;variant);" & _
    "RemoveHostObjectFromScript hresult(wstr);" & _
    "OpenDevToolsWindow hresult();" & _
    "add_ContainsFullScreenElementChanged hresult(ptr;int64*);" & _
    "remove_ContainsFullScreenElementChanged hresult(int64);" & _
    "get_ContainsFullScreenElement hresult(bool*);" & _
    "add_WebResourceRequested hresult(ptr;int64*);" & _
    "remove_WebResourceRequested hresult(int64);" & _
    "AddWebResourceRequestedFilter hresult(wstr;int);" & _
    "RemoveWebResourceRequestedFilter hresult(wstr;int);" & _
    "add_WindowCloseRequested hresult(ptr;int64*);" & _
    "remove_WindowCloseRequested hresult(int64);"

; ICoreWebView2Settings VTable
Global Const $dtag_ICoreWebView2Settings = _
    "QueryInterface hresult(ptr;ptr*);" & _
    "AddRef ulong();" & _
    "Release ulong();" & _
    "get_IsScriptEnabled hresult(bool*);" & _
    "put_IsScriptEnabled hresult(bool);" & _
    "get_IsWebMessageEnabled hresult(bool*);" & _
    "put_IsWebMessageEnabled hresult(bool);" & _
    "get_AreDefaultScriptDialogsEnabled hresult(bool*);" & _
    "put_AreDefaultScriptDialogsEnabled hresult(bool);" & _
    "get_IsStatusBarEnabled hresult(bool*);" & _
    "put_IsStatusBarEnabled hresult(bool);" & _
    "get_AreDevToolsEnabled hresult(bool*);" & _
    "put_AreDevToolsEnabled hresult(bool);" & _
    "get_AreDefaultContextMenusEnabled hresult(bool*);" & _
    "put_AreDefaultContextMenusEnabled hresult(bool);" & _
    "get_AreHostObjectsAllowed hresult(bool*);" & _
    "put_AreHostObjectsAllowed hresult(bool);" & _
    "get_IsZoomControlEnabled hresult(bool*);" & _
    "put_IsZoomControlEnabled hresult(bool);" & _
    "get_IsBuiltInErrorPageEnabled hresult(bool*);" & _
    "put_IsBuiltInErrorPageEnabled hresult(bool);"

; ===============================================================================================================================
; Helper Functions for COM Operations
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_StringToGUID
; Description ...: Convert a GUID string to a binary GUID structure
; Syntax ........: _WV2COM_StringToGUID($sGUID)
; Parameters ....: $sGUID - GUID string in format "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}"
; Return values .: Success - DllStruct containing the GUID
;                  Failure - 0 and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_StringToGUID($sGUID)
    Local $tGUID = DllStructCreate($tagWV2_GUID)
    If @error Then Return SetError(1, 0, 0)

    Local $aResult = DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID)
    If @error Or $aResult[0] <> 0 Then Return SetError(2, 0, 0)

    Return $tGUID
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_GUIDToString
; Description ...: Convert a binary GUID structure to a GUID string
; Syntax ........: _WV2COM_GUIDToString($tGUID)
; Parameters ....: $tGUID - DllStruct containing the GUID
; Return values .: Success - GUID string
;                  Failure - Empty string and sets @error
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_GUIDToString($tGUID)
    Local $aResult = DllCall("ole32.dll", "int", "StringFromGUID2", "struct*", $tGUID, "wstr", "", "int", 40)
    If @error Or $aResult[0] = 0 Then Return SetError(1, 0, "")
    Return $aResult[2]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_CreateRECT
; Description ...: Create a RECT structure
; Syntax ........: _WV2COM_CreateRECT($iLeft, $iTop, $iRight, $iBottom)
; Parameters ....: $iLeft, $iTop, $iRight, $iBottom - Rectangle coordinates
; Return values .: DllStruct containing the RECT
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_CreateRECT($iLeft, $iTop, $iRight, $iBottom)
    Local $tRECT = DllStructCreate($tagWV2_RECT)
    DllStructSetData($tRECT, "Left", $iLeft)
    DllStructSetData($tRECT, "Top", $iTop)
    DllStructSetData($tRECT, "Right", $iRight)
    DllStructSetData($tRECT, "Bottom", $iBottom)
    Return $tRECT
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_CompareGUID
; Description ...: Compare two GUIDs for equality
; Syntax ........: _WV2COM_CompareGUID($tGUID1, $tGUID2)
; Parameters ....: $tGUID1, $tGUID2 - DllStructs containing GUIDs to compare
; Return values .: True if equal, False otherwise
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_CompareGUID($tGUID1, $tGUID2)
    Local $aResult = DllCall("ole32.dll", "int", "IsEqualGUID", "struct*", $tGUID1, "struct*", $tGUID2)
    If @error Then Return False
    Return $aResult[0] <> 0
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_CoTaskMemFree
; Description ...: Free memory allocated by COM
; Syntax ........: _WV2COM_CoTaskMemFree($pMem)
; Parameters ....: $pMem - Pointer to memory to free
; Return values .: None
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_CoTaskMemFree($pMem)
    If $pMem = 0 Then Return
    DllCall("ole32.dll", "none", "CoTaskMemFree", "ptr", $pMem)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_SysAllocString
; Description ...: Allocate a BSTR string
; Syntax ........: _WV2COM_SysAllocString($sString)
; Parameters ....: $sString - String to allocate
; Return values .: Pointer to BSTR
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_SysAllocString($sString)
    Local $aResult = DllCall("oleaut32.dll", "ptr", "SysAllocString", "wstr", $sString)
    If @error Then Return 0
    Return $aResult[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_SysFreeString
; Description ...: Free a BSTR string
; Syntax ........: _WV2COM_SysFreeString($pBSTR)
; Parameters ....: $pBSTR - Pointer to BSTR to free
; Return values .: None
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_SysFreeString($pBSTR)
    If $pBSTR = 0 Then Return
    DllCall("oleaut32.dll", "none", "SysFreeString", "ptr", $pBSTR)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_PtrToWStr
; Description ...: Read a wide string from a pointer
; Syntax ........: _WV2COM_PtrToWStr($pStr)
; Parameters ....: $pStr - Pointer to wide string
; Return values .: String content
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_PtrToWStr($pStr)
    If $pStr = 0 Then Return ""

    ; Use lstrlenW to safely get string length first
    Local $aLen = DllCall("kernel32.dll", "int", "lstrlenW", "ptr", $pStr)
    If @error Then
        ConsoleWrite("[WebView2] ERROR: lstrlenW failed for ptr " & $pStr & @CRLF)
        Return ""
    EndIf

    Local $iLen = $aLen[0]
    If $iLen <= 0 Then Return ""
    If $iLen > 65536 Then $iLen = 65536  ; Safety limit

    ; Now read the string with the known length
    Local $tStr = DllStructCreate("wchar[" & ($iLen + 1) & "]", $pStr)
    If @error Then
        ConsoleWrite("[WebView2] ERROR: DllStructCreate failed for ptr " & $pStr & @CRLF)
        Return ""
    EndIf

    Return DllStructGetData($tStr, 1)
EndFunc

; ===============================================================================================================================
; COM Initialization Functions
; ===============================================================================================================================

Global $__g_bWV2_COMInitialized = False

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_Initialize
; Description ...: Initialize COM for WebView2 (must be called before creating WebView2)
; Syntax ........: _WV2COM_Initialize()
; Return values .: True on success, False on failure
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_Initialize()
    If $__g_bWV2_COMInitialized Then Return True

    ; Use OleInitialize which guarantees STA mode (required for WebView2)
    ; This is more reliable than CoInitializeEx because AutoIt may have already initialized COM
    Local $aResult = DllCall("ole32.dll", "long", "OleInitialize", "ptr", 0)
    If @error Then Return SetError(1, @error, False)

    ; S_OK (0) or S_FALSE (1) are both acceptable
    ; S_FALSE means COM was already initialized, which is fine
    If $aResult[0] <> 0 And $aResult[0] <> 1 Then
        ; OleInitialize failed, try CoInitializeEx as fallback (STA = 0x2)
        $aResult = DllCall("ole32.dll", "long", "CoInitializeEx", "ptr", 0, "dword", 0x2)
        If @error Then Return SetError(1, @error, False)
        If $aResult[0] <> 0 And $aResult[0] <> 1 Then
            Return SetError(2, $aResult[0], False)
        EndIf
    EndIf

    $__g_bWV2_COMInitialized = True
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WV2COM_Uninitialize
; Description ...: Uninitialize COM
; Syntax ........: _WV2COM_Uninitialize()
; Return values .: None
; Author ........: Ralle1976
; ===============================================================================================================================
Func _WV2COM_Uninitialize()
    If Not $__g_bWV2_COMInitialized Then Return

    ; Use OleUninitialize to match OleInitialize
    DllCall("ole32.dll", "none", "OleUninitialize")
    $__g_bWV2_COMInitialized = False
EndFunc

; ===============================================================================================================================
; End of WebView2_COM.au3
; ===============================================================================================================================
