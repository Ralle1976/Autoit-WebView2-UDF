#include <MsgBoxConstants.au3>
#include "..\Include\WebView2_Runtime.au3"

; ====================================================================================================================
; Example: WebView2 Runtime Detection and Installation
; ====================================================================================================================
; This example demonstrates how to detect and install WebView2 Runtime
; ====================================================================================================================

ConsoleWrite("=== WebView2 Runtime Detection Example ===" & @CRLF & @CRLF)

; ====================================================================================================================
; Check if WebView2 Runtime is installed
; ====================================================================================================================

Local $sVersion = _WebView2Runtime_GetVersion()

If $sVersion <> "" Then
    ConsoleWrite("[✓] WebView2 Runtime is installed!" & @CRLF)
    ConsoleWrite("    Version: " & $sVersion & @CRLF)
    ConsoleWrite(@CRLF)

    MsgBox($MB_ICONINFORMATION, "WebView2 Runtime Detected", _
        "Microsoft Edge WebView2 Runtime is installed!" & @CRLF & @CRLF & _
        "Version: " & $sVersion & @CRLF & @CRLF & _
        "You can now use native WebView2 controls in your AutoIt applications.")

Else
    ConsoleWrite("[✗] WebView2 Runtime is NOT installed!" & @CRLF)
    ConsoleWrite(@CRLF)

    ; Ask user if they want to install
    Local $iResponse = MsgBox($MB_YESNO + $MB_ICONQUESTION, "WebView2 Runtime Not Found", _
        "Microsoft Edge WebView2 Runtime is not installed on this system." & @CRLF & @CRLF & _
        "The WebView2 Runtime is required for modern web content in Windows applications." & @CRLF & @CRLF & _
        "Would you like to install it now?")

    If $iResponse = $IDYES Then
        ConsoleWrite("User chose to install WebView2 Runtime" & @CRLF)
        ConsoleWrite("Downloading and installing..." & @CRLF)

        ; Install WebView2 Runtime
        If _WebView2Runtime_DownloadAndInstall(False, True) Then
            ConsoleWrite(@CRLF & "[✓] Installation successful!" & @CRLF)
            Local $sNewVersion = _WebView2Runtime_GetVersion()
            ConsoleWrite("    Installed Version: " & $sNewVersion & @CRLF)

            MsgBox($MB_ICONINFORMATION, "Installation Complete", _
                "WebView2 Runtime has been installed successfully!" & @CRLF & @CRLF & _
                "Version: " & $sNewVersion)
        Else
            ConsoleWrite(@CRLF & "[✗] Installation failed or was cancelled" & @CRLF)
            MsgBox($MB_ICONWARNING, "Installation Failed", _
                "WebView2 Runtime installation failed or was cancelled." & @CRLF & @CRLF & _
                "You can install it manually from:" & @CRLF & _
                "https://developer.microsoft.com/microsoft-edge/webview2/")
        EndIf
    Else
        ConsoleWrite("User declined installation" & @CRLF)
        MsgBox($MB_ICONINFORMATION, "Installation Skipped", _
            "You can install WebView2 Runtime later from:" & @CRLF & _
            "https://developer.microsoft.com/microsoft-edge/webview2/")
    EndIf
EndIf

ConsoleWrite(@CRLF & "=== Example Complete ===" & @CRLF)
