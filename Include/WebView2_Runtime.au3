#include-once
#include <MsgBoxConstants.au3>
#include <InetConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: WebView2_Runtime
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: Functions for detecting and installing Microsoft Edge WebView2 Runtime
; Author(s) .....: AutoIt Community
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WebView2Runtime_GetVersion
; _WebView2Runtime_IsInstalled
; _WebView2Runtime_CheckAndPromptInstall
; _WebView2Runtime_DownloadAndInstall
; _WebView2Runtime_GetBootstrapperURL
; _WebView2Runtime_GetStandaloneURL
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $WV2_BOOTSTRAPPER_URL = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
Global Const $WV2_STANDALONE_X64_URL = "https://go.microsoft.com/fwlink/p/?LinkId=2124701"
Global Const $WV2_STANDALONE_X86_URL = "https://go.microsoft.com/fwlink/p/?LinkId=2099617"
Global Const $WV2_CLIENT_GUID = "{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_GetVersion
; Description ...: Get the installed WebView2 Runtime version
; Syntax ........: _WebView2Runtime_GetVersion()
; Parameters ....: None
; Return values .: Success - Version string (e.g., "131.0.2903.86")
;                  Failure - "" (empty string) if not installed
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Checks registry keys in the following order:
;                  1. HKLM\SOFTWARE\WOW6432Node (64-bit systems, per-machine install)
;                  2. HKLM\SOFTWARE (32-bit systems, per-machine install)
;                  3. HKCU\Software (per-user install)
; Related .......: _WebView2Runtime_IsInstalled
; Link ..........: https://learn.microsoft.com/en-us/microsoft-edge/webview2/
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Runtime_GetVersion()
    Local $sRegPath = "Microsoft\EdgeUpdate\Clients\" & $WV2_CLIENT_GUID
    Local $sVersion = ""

    ; Check HKLM\SOFTWARE\WOW6432Node (64-bit Windows, per-machine install)
    If @OSArch = "X64" Then
        $sVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\" & $sRegPath, "pv")
        If Not @error And $sVersion <> "" And $sVersion <> "0.0.0.0" Then
            Return $sVersion
        EndIf
    EndIf

    ; Check HKLM\SOFTWARE (32-bit Windows or 32-bit app on 64-bit Windows)
    $sVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\" & $sRegPath, "pv")
    If Not @error And $sVersion <> "" And $sVersion <> "0.0.0.0" Then
        Return $sVersion
    EndIf

    ; Check HKCU\Software (per-user install)
    $sVersion = RegRead("HKEY_CURRENT_USER\Software\" & $sRegPath, "pv")
    If Not @error And $sVersion <> "" And $sVersion <> "0.0.0.0" Then
        Return $sVersion
    EndIf

    Return "" ; Not installed
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_IsInstalled
; Description ...: Check if WebView2 Runtime is installed
; Syntax ........: _WebView2Runtime_IsInstalled()
; Parameters ....: None
; Return values .: Success - True (Runtime is installed)
;                  Failure - False (Runtime is not installed)
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Runtime_GetVersion
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Runtime_IsInstalled()
    Return _WebView2Runtime_GetVersion() <> ""
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_CheckAndPromptInstall
; Description ...: Check if Runtime is installed and prompt user to install if missing
; Syntax ........: _WebView2Runtime_CheckAndPromptInstall([$bSilent = False, [$bUseBootstrapper = True]])
; Parameters ....: $bSilent          - [optional] If True, don't show message boxes. Default is False.
;                  $bUseBootstrapper - [optional] If True, use small bootstrapper (requires internet). Default is True.
; Return values .: Success - True (Runtime is installed or was successfully installed)
;                  Failure - False (Runtime is not installed and user declined or installation failed)
;                            Sets @error:
;                            1 - User declined installation
;                            2 - Download failed
;                            3 - Installation failed or was cancelled
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: This function will display GUI dialogs unless $bSilent = True
; Related .......: _WebView2Runtime_DownloadAndInstall
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Runtime_CheckAndPromptInstall($bSilent = False, $bUseBootstrapper = True)
    ; Check if already installed
    Local $sVersion = _WebView2Runtime_GetVersion()

    If $sVersion <> "" Then
        If Not $bSilent Then
            ConsoleWrite("[WebView2] Runtime already installed: v" & $sVersion & @CRLF)
        EndIf
        Return True
    EndIf

    ; Not installed - prompt user
    If Not $bSilent Then
        Local $iResponse = MsgBox($MB_YESNO + $MB_ICONQUESTION, "WebView2 Runtime Required", _
            "This application requires Microsoft Edge WebView2 Runtime." & @CRLF & @CRLF & _
            "The WebView2 Runtime enables modern web content in Windows applications." & @CRLF & @CRLF & _
            "Would you like to download and install it now?" & @CRLF & @CRLF & _
            "Download size: " & ($bUseBootstrapper ? "~2 MB" : "~150 MB"))

        If $iResponse = $IDNO Then
            Return SetError(1, 0, False)
        EndIf
    EndIf

    ; Download and install
    Return _WebView2Runtime_DownloadAndInstall($bSilent, $bUseBootstrapper)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_DownloadAndInstall
; Description ...: Download and install WebView2 Runtime
; Syntax ........: _WebView2Runtime_DownloadAndInstall([$bSilent = False, [$bUseBootstrapper = True]])
; Parameters ....: $bSilent          - [optional] If True, install silently. Default is False.
;                  $bUseBootstrapper - [optional] If True, use bootstrapper (small, requires internet). Default is True.
; Return values .: Success - True (Installation completed successfully)
;                  Failure - False and sets @error:
;                            1 - Download failed
;                            2 - Installation failed or was cancelled
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Bootstrapper is ~2MB but requires internet. Standalone is ~150MB but works offline.
; Related .......: _WebView2Runtime_CheckAndPromptInstall
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Runtime_DownloadAndInstall($bSilent = False, $bUseBootstrapper = True)
    Local $sURL = $bUseBootstrapper ? $WV2_BOOTSTRAPPER_URL : _WebView2Runtime_GetStandaloneURL()
    Local $sInstallerPath = @TempDir & "\WebView2RuntimeInstaller.exe"

    ; Show download progress
    If Not $bSilent Then
        ConsoleWrite("[WebView2] Downloading Runtime installer..." & @CRLF)
        ConsoleWrite("[WebView2] URL: " & $sURL & @CRLF)
    EndIf

    ; Download installer
    Local $hDownload = InetGet($sURL, $sInstallerPath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

    ; Wait for download to complete
    Local $iTimeout = 300000 ; 5 minutes
    Local $iStartTime = TimerInit()

    While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        If TimerDiff($iStartTime) > $iTimeout Then
            InetClose($hDownload)
            If Not $bSilent Then
                MsgBox($MB_ICONERROR, "Error", "Download timeout. Please check your internet connection.")
            EndIf
            Return SetError(1, 0, False)
        EndIf
        Sleep(100)
    WEnd

    ; Check if download was successful
    Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
    InetClose($hDownload)

    If $iBytesRead = 0 Or Not FileExists($sInstallerPath) Then
        If Not $bSilent Then
            MsgBox($MB_ICONERROR, "Error", "Failed to download WebView2 Runtime installer.")
        EndIf
        Return SetError(1, 0, False)
    EndIf

    If Not $bSilent Then
        ConsoleWrite("[WebView2] Download complete (" & $iBytesRead & " bytes)" & @CRLF)
        ConsoleWrite("[WebView2] Installing Runtime..." & @CRLF)
    EndIf

    ; Run installer
    Local $sInstallCmd = $bSilent ? '/silent /install' : '/install'
    Local $iPID = Run($sInstallerPath & " " & $sInstallCmd, "", @SW_SHOW)

    ; Wait for installation to complete
    ProcessWaitClose($iPID, 600) ; 10 minute timeout

    ; Cleanup installer
    FileDelete($sInstallerPath)

    ; Verify installation
    Sleep(2000) ; Give registry time to update
    Local $sVersion = _WebView2Runtime_GetVersion()

    If $sVersion <> "" Then
        If Not $bSilent Then
            ConsoleWrite("[WebView2] Installation successful! Version: " & $sVersion & @CRLF)
            MsgBox($MB_ICONINFORMATION, "Success", "WebView2 Runtime installed successfully!" & @CRLF & "Version: " & $sVersion)
        EndIf
        Return True
    Else
        If Not $bSilent Then
            MsgBox($MB_ICONWARNING, "Installation Status", "Installation may have been cancelled or failed." & @CRLF & @CRLF & _
                "Please install WebView2 Runtime manually from:" & @CRLF & _
                "https://developer.microsoft.com/microsoft-edge/webview2/")
        EndIf
        Return SetError(2, 0, False)
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_GetBootstrapperURL
; Description ...: Get URL for WebView2 Runtime Bootstrapper
; Syntax ........: _WebView2Runtime_GetBootstrapperURL()
; Parameters ....: None
; Return values .: URL string
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Bootstrapper is small (~2MB) but requires internet connection during installation
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Runtime_GetBootstrapperURL()
    Return $WV2_BOOTSTRAPPER_URL
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Runtime_GetStandaloneURL
; Description ...: Get URL for WebView2 Runtime Standalone Installer based on system architecture
; Syntax ........: _WebView2Runtime_GetStandaloneURL()
; Parameters ....: None
; Return values .: URL string
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Standalone installer is large (~150MB) but works offline
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Runtime_GetStandaloneURL()
    Return (@OSArch = "X64") ? $WV2_STANDALONE_X64_URL : $WV2_STANDALONE_X86_URL
EndFunc
