@echo off
REM Compile WebView2Helper.dll - Native COM callback helper for AutoIt
REM Author: Ralle1976

echo === WebView2Helper DLL Compiler ===
echo.

REM Check for Visual Studio Build Tools
where cl >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Visual Studio C++ compiler (cl.exe) not found!
    echo.
    echo Please run this script from a Visual Studio Developer Command Prompt
    echo or install Visual Studio Build Tools from:
    echo https://visualstudio.microsoft.com/downloads/
    echo.
    echo For x86 build, use: "x86 Native Tools Command Prompt"
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0"

echo Compiling x86 (32-bit) version...
cl /nologo /O2 /LD /MD /W3 WebView2Helper.c /Fe:..\bin\WebView2Helper.dll ole32.lib user32.lib /link /DEF:WebView2Helper.def

if %errorlevel% neq 0 (
    echo.
    echo Compilation failed! Trying without DEF file...
    cl /nologo /O2 /LD /MD /W3 WebView2Helper.c /Fe:..\bin\WebView2Helper.dll ole32.lib user32.lib
)

if exist ..\bin\WebView2Helper.dll (
    echo.
    echo SUCCESS: WebView2Helper.dll created in bin\ folder
    echo.
    REM Copy to other locations for convenience
    copy /Y ..\bin\WebView2Helper.dll ..\Include\ >nul
    copy /Y ..\bin\WebView2Helper.dll ..\Examples\ >nul
    echo DLL copied to Include\ and Examples\ folders
) else (
    echo.
    echo ERROR: Compilation failed!
)

REM Cleanup
del /q *.obj 2>nul

echo.
pause
