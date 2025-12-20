#include "..\Include\WebView2_Setup.au3"

; ====================================================================================================================
; Example 1: Setup Wizard - First Time Setup
; ====================================================================================================================
; RUN THIS FIRST! This example checks and installs all required components.
;
; What it does:
; 1. Checks if WebView2 Runtime is installed
; 2. Checks if OrdoWebView2.ocx is installed
; 3. Shows status and offers to install missing components
; 4. Downloads and installs everything automatically
;
; INTERNET CONNECTION REQUIRED for first-time setup
; ====================================================================================================================

ConsoleWrite(@CRLF)
ConsoleWrite("╔═══════════════════════════════════════════════════════════════════╗" & @CRLF)
ConsoleWrite("║           WebView2 Setup Wizard - First Time Setup               ║" & @CRLF)
ConsoleWrite("╚═══════════════════════════════════════════════════════════════════╝" & @CRLF)
ConsoleWrite(@CRLF)
ConsoleWrite("This wizard will check and install all required components for" & @CRLF)
ConsoleWrite("native Microsoft Edge WebView2 support in AutoIt." & @CRLF)
ConsoleWrite(@CRLF)

; Run the interactive setup wizard
If _WebView2Setup_ShowSetupWizard() Then
    ConsoleWrite(@CRLF)
    ConsoleWrite("═══════════════════════════════════════════════════════════════════" & @CRLF)
    ConsoleWrite("✓ Setup completed successfully!" & @CRLF)
    ConsoleWrite("═══════════════════════════════════════════════════════════════════" & @CRLF)
    ConsoleWrite(@CRLF)
    ConsoleWrite("You can now run the other examples:" & @CRLF)
    ConsoleWrite("  • Example_02_SimpleBrowser.au3 - Simple web browser" & @CRLF)
    ConsoleWrite("  • Example_03_ModernDashboard.au3 - HTML dashboard" & @CRLF)
    ConsoleWrite("  • Example_04_AutoItJavaScriptBridge.au3 - AutoIt ↔ JS communication" & @CRLF)
    ConsoleWrite(@CRLF)

    MsgBox(64, "Setup Complete", _
        "Setup completed successfully!" & @CRLF & @CRLF & _
        "You can now run the other example scripts to see WebView2 in action.")
Else
    ConsoleWrite(@CRLF)
    ConsoleWrite("═══════════════════════════════════════════════════════════════════" & @CRLF)
    ConsoleWrite("✗ Setup was cancelled or failed" & @CRLF)
    ConsoleWrite("═══════════════════════════════════════════════════════════════════" & @CRLF)
    ConsoleWrite(@CRLF)
    ConsoleWrite("You can run this wizard again anytime to install the components." & @CRLF)
    ConsoleWrite(@CRLF)
EndIf
