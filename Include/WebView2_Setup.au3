#include-once
#include <MsgBoxConstants.au3>
#include <InetConstants.au3>
#include "WebView2_Runtime.au3"

; #INDEX# =======================================================================================================================
; Title .........: WebView2_Setup
; AutoIt Version : 3.3.16.1+
; Language ......: English
; Description ...: Complete automatic setup for WebView2 with OrdoWebView2.ocx
; Author(s) .....: AutoIt Community
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WebView2Setup_RunCompleteSetup
; _WebView2Setup_CheckAll
; _WebView2Setup_IsOrdoInstalled
; _WebView2Setup_DownloadAndInstallOrdo
; _WebView2Setup_GetOrdoInstallerURL
; _WebView2Setup_GetLatestOrdoVersion
; _WebView2Setup_ShowSetupWizard
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Current version as of implementation - update manually if needed
Global Const $ORDO_INSTALLER_VERSION = "2.0.9"
Global Const $ORDO_INSTALLER_URL = "https://freeware.ordoconcept.net/download.php?file=OrdoWebView2ActiveXControl." & $ORDO_INSTALLER_VERSION & ".exe"
Global Const $ORDO_WEBSITE_URL = "https://freeware.ordoconcept.net/OrdoWebview2.php"
Global Const $ORDO_PROGID = "OrdoWebView2.WebView2Control"
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_RunCompleteSetup
; Description ...: Run complete automatic setup for WebView2 (Runtime + OrdoWebView2.ocx)
; Syntax ........: _WebView2Setup_RunCompleteSetup([$bSilent = False, [$bForce = False]])
; Parameters ....: $bSilent - [optional] Silent installation without prompts. Default is False.
;                  $bForce  - [optional] Force reinstall even if already installed. Default is False.
; Return values .: Success - True (All components installed)
;                  Failure - False and sets @error:
;                            1 - WebView2 Runtime installation failed
;                            2 - OrdoWebView2.ocx installation failed
;                            3 - User cancelled
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: This is the main function to call for complete setup
; Related .......: _WebView2Setup_CheckAll
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Setup_RunCompleteSetup($bSilent = False, $bForce = False)
    If Not $bSilent Then
        ConsoleWrite("=== WebView2 Complete Setup ===" & @CRLF & @CRLF)
    EndIf

    Local $bRuntimeOK = False
    Local $bOrdoOK = False

    ; Step 1: Check WebView2 Runtime
    If Not $bSilent Then ConsoleWrite("[1/2] Checking WebView2 Runtime..." & @CRLF)

    If $bForce Or Not _WebView2Runtime_IsInstalled() Then
        If Not $bSilent Then
            ConsoleWrite("      WebView2 Runtime not found or force reinstall" & @CRLF)
        EndIf

        If Not _WebView2Runtime_CheckAndPromptInstall($bSilent, True) Then
            If Not $bSilent Then
                ConsoleWrite("      [FAILED] WebView2 Runtime installation failed or cancelled" & @CRLF)
            EndIf
            Return SetError(1, 0, False)
        EndIf
        $bRuntimeOK = True
    Else
        Local $sVersion = _WebView2Runtime_GetVersion()
        If Not $bSilent Then
            ConsoleWrite("      ✓ WebView2 Runtime already installed: v" & $sVersion & @CRLF)
        EndIf
        $bRuntimeOK = True
    EndIf

    ; Step 2: Check OrdoWebView2.ocx
    If Not $bSilent Then ConsoleWrite("[2/2] Checking OrdoWebView2.ocx..." & @CRLF)

    If $bForce Or Not _WebView2Setup_IsOrdoInstalled() Then
        If Not $bSilent Then
            ConsoleWrite("      OrdoWebView2.ocx not found or force reinstall" & @CRLF)
        EndIf

        If Not _WebView2Setup_DownloadAndInstallOrdo($bSilent) Then
            If Not $bSilent Then
                ConsoleWrite("      [FAILED] OrdoWebView2.ocx installation failed or cancelled" & @CRLF)
            EndIf
            Return SetError(2, 0, False)
        EndIf
        $bOrdoOK = True
    Else
        If Not $bSilent Then
            ConsoleWrite("      ✓ OrdoWebView2.ocx already installed and registered" & @CRLF)
        EndIf
        $bOrdoOK = True
    EndIf

    ; Success!
    If Not $bSilent Then
        ConsoleWrite(@CRLF & "=== Setup Complete ===" & @CRLF)
        ConsoleWrite("✓ WebView2 Runtime: " & _WebView2Runtime_GetVersion() & @CRLF)
        ConsoleWrite("✓ OrdoWebView2.ocx: Registered" & @CRLF)
        ConsoleWrite(@CRLF & "You can now use native WebView2 in your AutoIt applications!" & @CRLF)

        MsgBox($MB_ICONINFORMATION, "Setup Complete", _
            "WebView2 setup completed successfully!" & @CRLF & @CRLF & _
            "Installed components:" & @CRLF & _
            "✓ WebView2 Runtime: v" & _WebView2Runtime_GetVersion() & @CRLF & _
            "✓ OrdoWebView2.ocx: Registered" & @CRLF & @CRLF & _
            "You can now create modern web applications with AutoIt!")
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_CheckAll
; Description ...: Check if all required components are installed
; Syntax ........: _WebView2Setup_CheckAll()
; Parameters ....: None
; Return values .: Success - True (All components installed)
;                  Failure - False (Some components missing)
;                  Sets @extended to bitmask:
;                    Bit 0 (1) = WebView2 Runtime missing
;                    Bit 1 (2) = OrdoWebView2.ocx missing
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......: _WebView2Setup_RunCompleteSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Setup_CheckAll()
    Local $iMissing = 0

    If Not _WebView2Runtime_IsInstalled() Then
        $iMissing = BitOR($iMissing, 1)
    EndIf

    If Not _WebView2Setup_IsOrdoInstalled() Then
        $iMissing = BitOR($iMissing, 2)
    EndIf

    If $iMissing > 0 Then
        Return SetError(1, $iMissing, False)
    EndIf

    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_IsOrdoInstalled
; Description ...: Check if OrdoWebView2.ocx is installed and registered
; Syntax ........: _WebView2Setup_IsOrdoInstalled()
; Parameters ....: None
; Return values .: Success - True (OrdoWebView2.ocx is registered)
;                  Failure - False (Not registered)
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Setup_IsOrdoInstalled()
    Local $oTest = ObjCreate($ORDO_PROGID)
    If IsObj($oTest) Then
        $oTest = 0
        Return True
    EndIf
    Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_DownloadAndInstallOrdo
; Description ...: Download and install OrdoWebView2.ocx automatically
; Syntax ........: _WebView2Setup_DownloadAndInstallOrdo([$bSilent = False])
; Parameters ....: $bSilent - [optional] Silent installation. Default is False.
; Return values .: Success - True
;                  Failure - False and sets @error:
;                            1 - Download failed
;                            2 - Installation failed or cancelled
;                            3 - Verification failed (still not registered after install)
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Downloads from official OrdoConcept website
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Setup_DownloadAndInstallOrdo($bSilent = False)
    ; Prompt user (if not silent)
    If Not $bSilent Then
        Local $iResponse = MsgBox($MB_YESNO + $MB_ICONQUESTION, "OrdoWebView2.ocx Required", _
            "OrdoWebView2.ocx is required for native WebView2 support." & @CRLF & @CRLF & _
            "This is a FREE ActiveX control from OrdoConcept that enables" & @CRLF & _
            "Microsoft Edge WebView2 integration in AutoIt." & @CRLF & @CRLF & _
            "Download size: ~20 MB" & @CRLF & _
            "Source: https://freeware.ordoconcept.net/OrdoWebview2.php" & @CRLF & @CRLF & _
            "Download and install now?")

        If $iResponse = $IDNO Then
            Return SetError(3, 0, False)
        EndIf
    EndIf

    ; Try to get latest version from website
    Local $sVersion = _WebView2Setup_GetLatestOrdoVersion()
    Local $sDownloadURL = "https://freeware.ordoconcept.net/download.php?file=OrdoWebView2ActiveXControl." & $sVersion & ".exe"
    Local $sInstallerPath = @TempDir & "\OrdoWebView2ActiveXControl." & $sVersion & ".exe"

    ; Download installer
    If Not $bSilent Then
        ConsoleWrite("         Downloading OrdoWebView2.ocx installer..." & @CRLF)
        ConsoleWrite("         Version: " & $sVersion & @CRLF)
        ConsoleWrite("         URL: " & $sDownloadURL & @CRLF)
    EndIf

    Local $hDownload = InetGet($sDownloadURL, $sInstallerPath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

    ; Wait for download
    Local $iTimeout = 300000 ; 5 minutes
    Local $iStartTime = TimerInit()

    While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        If TimerDiff($iStartTime) > $iTimeout Then
            InetClose($hDownload)
            If Not $bSilent Then
                MsgBox($MB_ICONERROR, "Download Error", "Download timeout. Please check your internet connection.")
            EndIf
            Return SetError(1, 0, False)
        EndIf
        Sleep(100)
    WEnd

    Local $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
    InetClose($hDownload)

    If $iBytesRead = 0 Or Not FileExists($sInstallerPath) Then
        If Not $bSilent Then
            MsgBox($MB_ICONERROR, "Download Error", _
                "Failed to download OrdoWebView2.ocx installer." & @CRLF & @CRLF & _
                "Please download manually from:" & @CRLF & _
                "https://freeware.ordoconcept.net/OrdoWebview2.php")
        EndIf
        Return SetError(1, 0, False)
    EndIf

    If Not $bSilent Then
        ConsoleWrite("         Download complete (" & Round($iBytesRead / 1024 / 1024, 2) & " MB)" & @CRLF)
        ConsoleWrite("         Installing OrdoWebView2.ocx..." & @CRLF)
    EndIf

    ; Run installer
    Local $sInstallCmd = $bSilent ? '/verysilent /suppressmsgboxes' : ''
    Local $iPID = Run($sInstallerPath & " " & $sInstallCmd, "", @SW_SHOW)

    ; Wait for installation
    ProcessWaitClose($iPID, 600) ; 10 minute timeout

    ; Cleanup
    Sleep(1000) ; Give it a moment
    FileDelete($sInstallerPath)

    ; Verify installation
    Sleep(2000) ; Give registry time to update

    If _WebView2Setup_IsOrdoInstalled() Then
        If Not $bSilent Then
            ConsoleWrite("         ✓ OrdoWebView2.ocx installed and registered successfully!" & @CRLF)
        EndIf
        Return True
    Else
        If Not $bSilent Then
            MsgBox($MB_ICONWARNING, "Installation Status", _
                "Installation may have been cancelled or failed." & @CRLF & @CRLF & _
                "If you cancelled the installation, please run it again." & @CRLF & @CRLF & _
                "Or install manually from:" & @CRLF & _
                "https://freeware.ordoconcept.net/OrdoWebview2.php")
        EndIf
        Return SetError(2, 0, False)
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_GetOrdoInstallerURL
; Description ...: Get URL for OrdoWebView2.ocx installer
; Syntax ........: _WebView2Setup_GetOrdoInstallerURL()
; Parameters ....: None
; Return values .: URL string
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Setup_GetOrdoInstallerURL()
    Return $ORDO_INSTALLER_URL
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_GetLatestOrdoVersion
; Description ...: Try to detect the latest OrdoWebView2.ocx version from website
; Syntax ........: _WebView2Setup_GetLatestOrdoVersion()
; Parameters ....: None
; Return values .: Success - Version string (e.g., "2.0.9")
;                  Failure - Default version from $ORDO_INSTALLER_VERSION
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: Attempts to parse the version from the OrdoConcept website
;                  Falls back to hardcoded version if parsing fails
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WebView2Setup_GetLatestOrdoVersion()
    ; Try to fetch the website and parse the version
    Local $sHTML = InetRead($ORDO_WEBSITE_URL, $INET_FORCERELOAD)
    If @error Then Return $ORDO_INSTALLER_VERSION ; Fallback to default

    $sHTML = BinaryToString($sHTML)

    ; Try to find version pattern: OrdoWebView2ActiveXControl.X.X.X.exe
    Local $aMatches = StringRegExp($sHTML, 'OrdoWebView2ActiveXControl\.(\d+\.\d+\.\d+)\.exe', 3)
    If Not @error And IsArray($aMatches) And UBound($aMatches) > 0 Then
        ; Found version on website
        ConsoleWrite("[OrdoWebView2] Detected latest version from website: " & $aMatches[0] & @CRLF)
        Return $aMatches[0]
    EndIf

    ; Fallback to hardcoded version
    ConsoleWrite("[OrdoWebView2] Could not detect version, using default: " & $ORDO_INSTALLER_VERSION & @CRLF)
    Return $ORDO_INSTALLER_VERSION
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WebView2Setup_ShowSetupWizard
; Description ...: Show interactive setup wizard with status and install options
; Syntax ........: _WebView2Setup_ShowSetupWizard()
; Parameters ....: None
; Return values .: Success - True (Setup completed)
;                  Failure - False (User cancelled or setup failed)
; Author ........: AutoIt Community
; Modified ......:
; Remarks .......: User-friendly wizard interface
; Related .......: _WebView2Setup_RunCompleteSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WebView2Setup_ShowSetupWizard()
    ; Check current status
    Local $bRuntimeInstalled = _WebView2Runtime_IsInstalled()
    Local $bOrdoInstalled = _WebView2Setup_IsOrdoInstalled()
    Local $sRuntimeVersion = $bRuntimeInstalled ? _WebView2Runtime_GetVersion() : "Not installed"

    ; Build status message
    Local $sMessage = "WebView2 Setup Wizard" & @CRLF & @CRLF
    $sMessage &= "Current Status:" & @CRLF
    $sMessage &= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" & @CRLF
    $sMessage &= ($bRuntimeInstalled ? "✓" : "✗") & " WebView2 Runtime: " & $sRuntimeVersion & @CRLF
    $sMessage &= ($bOrdoInstalled ? "✓" : "✗") & " OrdoWebView2.ocx: " & ($bOrdoInstalled ? "Registered" : "Not installed") & @CRLF
    $sMessage &= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" & @CRLF & @CRLF

    If $bRuntimeInstalled And $bOrdoInstalled Then
        $sMessage &= "All components are installed!" & @CRLF & @CRLF
        $sMessage &= "You can now use native WebView2 in your AutoIt applications." & @CRLF & @CRLF
        $sMessage &= "Do you want to reinstall anyway?"

        Local $iResponse = MsgBox($MB_YESNO + $MB_ICONINFORMATION, "Setup Wizard", $sMessage)
        If $iResponse = $IDNO Then Return True

        ; Force reinstall
        Return _WebView2Setup_RunCompleteSetup(False, True)
    Else
        ; Missing components
        Local $aMissing[0]
        If Not $bRuntimeInstalled Then
            ReDim $aMissing[UBound($aMissing) + 1]
            $aMissing[UBound($aMissing) - 1] = "WebView2 Runtime (~150 MB)"
        EndIf
        If Not $bOrdoInstalled Then
            ReDim $aMissing[UBound($aMissing) + 1]
            $aMissing[UBound($aMissing) - 1] = "OrdoWebView2.ocx (~20 MB)"
        EndIf

        $sMessage &= "Missing components:" & @CRLF
        For $i = 0 To UBound($aMissing) - 1
            $sMessage &= "  • " & $aMissing[$i] & @CRLF
        Next
        $sMessage &= @CRLF & "Total download: ~" & (Not $bRuntimeInstalled ? 150 : 0) + (Not $bOrdoInstalled ? 20 : 0) & " MB" & @CRLF
        $sMessage &= @CRLF & "Install missing components now?"

        Local $iResponse = MsgBox($MB_YESNO + $MB_ICONQUESTION, "Setup Wizard", $sMessage)
        If $iResponse = $IDNO Then Return False

        ; Run setup
        Return _WebView2Setup_RunCompleteSetup(False, False)
    EndIf
EndFunc
