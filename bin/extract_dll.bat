@echo off
echo ============================================================
echo  WebView2Loader.dll Extraction
echo ============================================================
echo.

cd /d "%~dp0"

echo Extracting WebView2 NuGet package...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path 'webview2.nupkg' -DestinationPath 'webview2_temp' -Force"

echo.
echo Suche WebView2Loader.dll...

if exist "webview2_temp\runtimes\win-x64\native\WebView2Loader.dll" (
    copy /Y "webview2_temp\runtimes\win-x64\native\WebView2Loader.dll" "WebView2Loader.dll"
    echo [OK] WebView2Loader.dll ^(x64^) kopiert
) else if exist "webview2_temp\build\native\x64\WebView2Loader.dll" (
    copy /Y "webview2_temp\build\native\x64\WebView2Loader.dll" "WebView2Loader.dll"
    echo [OK] WebView2Loader.dll ^(x64^) kopiert
) else (
    echo Suche in allen Verzeichnissen...
    for /r "webview2_temp" %%f in (WebView2Loader.dll) do (
        echo Gefunden: %%f
        copy /Y "%%f" "WebView2Loader.dll"
        goto :found
    )
    echo [ERROR] WebView2Loader.dll nicht gefunden!
    goto :cleanup
)

:found
echo.
echo [OK] WebView2Loader.dll erfolgreich extrahiert!

:cleanup
echo.
echo Aufraumen...
rmdir /s /q webview2_temp 2>nul

echo.
if exist "WebView2Loader.dll" (
    echo ============================================================
    echo  ERFOLG! WebView2Loader.dll ist bereit.
    echo ============================================================
) else (
    echo ============================================================
    echo  FEHLER! Bitte manuell herunterladen.
    echo ============================================================
)
pause
