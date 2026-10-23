@echo off
title CS2 Pro Optimizer
echo ========================================
echo   CS2 PRO GAMING OPTIMIZER
echo ========================================
echo.

:: --- Systemwiederherstellungspunkt ---
echo [1/5] Systemwiederherstellungspunkt erstellen...
powershell -Command "Checkpoint-Computer -Description 'CS2-Optimizer-Pre' -RestorePointType MODIFY_SETTINGS" 2>nul
echo       Wiederherstellungspunkt erstellt!
echo.

:: --- Power Plan auf High Performance ---
echo [2/5] Power Plan auf Hoechstleistung...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo       High Performance aktiviert!
echo.

:: --- CS2 Fullscreen Optimizations deaktivieren ---
echo [3/5] Fullscreen Optimizations deaktivieren...
set "CS2_PATHS="
for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM_PATH=%%b"
if defined STEAM_PATH (
    if exist "%STEAM_PATH%\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe" (
        set "CS2_EXE=%STEAM_PATH%\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
    )
)
if defined CS2_EXE (
    reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%CS2_EXE%" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
    echo       cs2.exe: Fullscreen Optimizations deaktiviert!
) else (
    echo       CS2 nicht gefunden — uebersprungen
)
echo.

:: --- Gaming Registry Tweaks importieren ---
echo [4/5] Gaming Registry Tweaks importieren...
if exist "%~dp0gaming-optimize.reg" (
    reg import "%~dp0gaming-optimize.reg" >nul 2>&1
    echo       Registry Tweaks importiert!
) else (
    echo       gaming-optimize.reg nicht gefunden!
)
echo.

:: --- DNS Flush ---
echo [5/5] DNS Cache leeren...
ipconfig /flushdns >nul 2>&1
echo       DNS Cache geleert!
echo.

echo ========================================
echo   FERTIG! Alle CS2 Optimierungen aktiv.
echo   Starte CS2 mit: -novid -high -nojoy
echo   Resolution: -w 1280 -h 960
echo ========================================
echo.
pause
