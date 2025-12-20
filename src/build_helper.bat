@echo off
REM Build WebView2Helper.dll for x86 and x64
REM Author: Ralle1976
REM Requires: Visual Studio with C++ tools and CMake

setlocal enabledelayedexpansion

echo ============================================
echo Building WebView2Helper.dll
echo ============================================
echo.

REM Find CMake
set "CMAKE_PATH="
if exist "C:\Program Files\CMake\bin\cmake.exe" (
    set "CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe"
) else if exist "C:\Program Files (x86)\CMake\bin\cmake.exe" (
    set "CMAKE_PATH=C:\Program Files (x86)\CMake\bin\cmake.exe"
) else (
    for /f "delims=" %%i in ('where cmake 2^>nul') do set "CMAKE_PATH=%%i"
)

if "%CMAKE_PATH%"=="" (
    echo ERROR: CMake not found!
    echo Please install CMake from https://cmake.org/download/
    pause
    exit /b 1
)

echo Using CMake: %CMAKE_PATH%
echo.

cd /d "%~dp0"

REM Clean old builds
if exist build32 rmdir /s /q build32
if exist build64 rmdir /s /q build64

REM Build 32-bit
echo ============================================
echo Building 32-bit version...
echo ============================================
"%CMAKE_PATH%" -G "Visual Studio 17 2022" -A Win32 -B build32
if errorlevel 1 (
    echo Trying Visual Studio 16 2019...
    "%CMAKE_PATH%" -G "Visual Studio 16 2019" -A Win32 -B build32
)
if errorlevel 1 (
    echo ERROR: CMake configure failed for 32-bit!
    pause
    exit /b 1
)

"%CMAKE_PATH%" --build build32 --config Release
if errorlevel 1 (
    echo ERROR: Build failed for 32-bit!
    pause
    exit /b 1
)
echo 32-bit build COMPLETE!
echo.

REM Build 64-bit
echo ============================================
echo Building 64-bit version...
echo ============================================
"%CMAKE_PATH%" -G "Visual Studio 17 2022" -A x64 -B build64
if errorlevel 1 (
    echo Trying Visual Studio 16 2019...
    "%CMAKE_PATH%" -G "Visual Studio 16 2019" -A x64 -B build64
)
if errorlevel 1 (
    echo ERROR: CMake configure failed for 64-bit!
    pause
    exit /b 1
)

"%CMAKE_PATH%" --build build64 --config Release
if errorlevel 1 (
    echo ERROR: Build failed for 64-bit!
    pause
    exit /b 1
)
echo 64-bit build COMPLETE!
echo.

REM Copy to all needed locations
echo ============================================
echo Copying DLLs to locations...
echo ============================================

set "BIN_DIR=%~dp0..\bin"
set "EXAMPLES_DIR=%~dp0..\Examples"
set "INCLUDE_DIR=%~dp0..\Include"

if exist "%BIN_DIR%\WebView2Helper_x86.dll" (
    copy /y "%BIN_DIR%\WebView2Helper_x86.dll" "%EXAMPLES_DIR%\" > nul
    copy /y "%BIN_DIR%\WebView2Helper_x86.dll" "%INCLUDE_DIR%\" > nul
    echo Copied WebView2Helper_x86.dll
)

if exist "%BIN_DIR%\WebView2Helper_x64.dll" (
    copy /y "%BIN_DIR%\WebView2Helper_x64.dll" "%EXAMPLES_DIR%\" > nul
    copy /y "%BIN_DIR%\WebView2Helper_x64.dll" "%INCLUDE_DIR%\" > nul
    echo Copied WebView2Helper_x64.dll
)

REM Also copy as generic name for fallback
if exist "%BIN_DIR%\WebView2Helper_x86.dll" (
    copy /y "%BIN_DIR%\WebView2Helper_x86.dll" "%BIN_DIR%\WebView2Helper.dll" > nul
    echo Created WebView2Helper.dll (32-bit default)
)

echo.
echo ============================================
echo BUILD COMPLETE!
echo ============================================
echo.
echo Output files:
dir /b "%BIN_DIR%\WebView2Helper*.dll" 2>nul
echo.

pause
