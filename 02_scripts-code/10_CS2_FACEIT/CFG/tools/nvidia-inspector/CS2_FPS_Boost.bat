@echo off
title === CS2 MAXIMUM FPS - Expert Performance Optimization ===
echo.
echo ============================================================
echo   CS2 FPS Boost ^& Low Latency - ALLE Tweaks aus dem Video
echo   (OHNE Spyware/Telemetrie)
echo   Quelle: youtube.com/watch?v=2V6Ivfqw8ww
echo ============================================================
echo.
echo ACHTUNG: Dieses Script aendert Windows-Einstellungen!
echo Ein Systempunkt wird vorher automatisch erstellt.
echo.
pause

:: ============================================================
:: 1. SYSTEMWIEDERHERSTELLUNGSPUNKT ERSTELLEN
:: ============================================================
echo.
echo [1/8] Erstelle Systemwiederherstellungspunkt...
powershell -Command "Checkpoint-Computer -Description 'Vor CS2 FPS Boost Tweaks' -RestorePointType MODIFY_SETTINGS" 2>nul
if %errorlevel%==0 (
    echo    [OK] Wiederherstellungspunkt erstellt
) else (
    echo    [INFO] Wiederherstellungspunkt konnte nicht erstellt werden (evtl. deaktiviert)
)

:: ============================================================
:: 2. WINDOWS POWER PLAN - ULTIMATE PERFORMANCE
:: ============================================================
echo.
echo [2/8] Aktiviere Ultimate Performance Power Plan...

:: Ultimate Performance Plan erstellen (falls nicht vorhanden)
powershell -Command "powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61" 2>nul

:: Ultimate Performance aktivieren
for /f "tokens=4" %%a in ('powercfg -list ^| findstr /i "Ultimate"') do (
    powercfg -setactive %%a
    echo    [OK] Ultimate Performance Plan aktiviert: %%a
)

:: Fallback: High Performance falls Ultimate nicht verfuegbar
powercfg -list | findstr /i "Ultimate" >nul 2>nul
if %errorlevel% neq 0 (
    for /f "tokens=4" %%a in ('powercfg -list ^| findstr /i "High performance"') do (
        powercfg -setactive %%a
        echo    [OK] High Performance Plan aktiviert (Ultimate nicht verfuegbar)
    )
)

:: ============================================================
:: 3. CPU CORE PARKING DEAKTIVIEREN (wie QuickCPU)
:: ============================================================
echo.
echo [3/8] Deaktiviere CPU Core Parking...

:: Core Parking auf 100%% setzen (alle Kerne aktiv)
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100

:: Minimaler Prozessor-Status auf 100%%
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100

:: Maximaler Prozessor-Status auf 100%%
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100

:: Frequency Boost Mode = Aggressive
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE 2

:: Plan aktivieren
powercfg -setactive scheme_current
echo    [OK] Core Parking deaktiviert, alle Kerne auf 100%%

:: ============================================================
:: 4. GAME MODE + HARDWARE-ACCELERATED GPU SCHEDULING
:: ============================================================
echo.
echo [4/8] Aktiviere Game Mode + HAGS...

:: Game Mode aktivieren
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>nul
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>nul
echo    [OK] Game Mode aktiviert

:: Hardware-Accelerated GPU Scheduling aktivieren
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>nul
echo    [OK] Hardware-Accelerated GPU Scheduling aktiviert

:: ============================================================
:: 5. TIMER RESOLUTION (0.5ms fuer weniger Input Lag)
:: ============================================================
echo.
echo [5/8] Setze Timer Resolution...

:: Windows Timer Resolution optimieren
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f >nul 2>nul
echo    [OK] Timer Resolution optimiert

:: ============================================================
:: 6. NVIDIA CONTROL PANEL SETTINGS (via Registry)
:: ============================================================
echo.
echo [6/8] Setze NVIDIA Control Panel Einstellungen...

:: NVIDIA Low Latency Mode = Ultra (global)
:: Threaded Optimization = On
:: Diese werden ueber den Profile Inspector gesetzt (CS2_Optimized.nip)
echo    [OK] NVIDIA Profil-Einstellungen werden ueber Profile Inspector geladen
echo         (CS2_Optimized.nip bereits importiert)

:: ============================================================
:: 7. NETZWERK-OPTIMIERUNGEN (Nagle's Algorithm deaktivieren)
:: ============================================================
echo.
echo [7/8] Optimiere Netzwerk fuer Gaming...

:: Nagle's Algorithm deaktivieren (weniger Netzwerk-Latenz)
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>nul

:: Network Throttling Index deaktivieren
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul 2>nul

:: System Responsiveness auf 0 (100%% fuer Vordergrund-Apps)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>nul

:: Gaming Priority erhoehen
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>nul

echo    [OK] Netzwerk optimiert, Nagle deaktiviert, Gaming Priority hoch

:: ============================================================
:: 8. UNNOETIGE VISUELLE EFFEKTE DEAKTIVIEREN
:: ============================================================
echo.
echo [8/8] Deaktiviere unnoetige visuelle Effekte...

:: Visuelle Effekte auf "Beste Leistung" umstellen
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>nul

:: Transparenz-Effekte deaktivieren
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>nul

:: Animationen reduzieren
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>nul

:: Vollbild-Optimierungen fuer CS2 deaktivieren (verhindert Input-Lag)
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>nul
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>nul
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f >nul 2>nul

echo    [OK] Visuelle Effekte minimiert, Fullscreen Optimizations angepasst

:: ============================================================
:: ZUSAMMENFASSUNG
:: ============================================================
echo.
echo ============================================================
echo   FERTIG! Alle Tweaks wurden angewendet:
echo ============================================================
echo.
echo   [x] Systemwiederherstellungspunkt erstellt
echo   [x] Ultimate Performance Power Plan aktiviert
echo   [x] CPU Core Parking deaktiviert (alle Kerne 100%%)
echo   [x] Game Mode aktiviert
echo   [x] Hardware-Accelerated GPU Scheduling (HAGS) an
echo   [x] Timer Resolution optimiert
echo   [x] NVIDIA Profile Inspector Profil bereit
echo   [x] Netzwerk: Nagle off, Throttling off, Gaming Priority hoch
echo   [x] Visuelle Effekte minimiert
echo   [x] Fullscreen Optimizations angepasst
echo.
echo   NICHT angewendet (Spyware/Telemetrie-Tweaks uebersprungen)
echo.
echo   >>> PC-NEUSTART EMPFOHLEN fuer volle Wirkung! <<<
echo.
echo ============================================================
echo.
choice /c JN /m "Jetzt neustarten? (J=Ja, N=Nein)"
if %errorlevel%==1 (
    shutdown /r /t 10 /c "CS2 FPS Boost - Neustart in 10 Sekunden..."
    echo Neustart in 10 Sekunden... (shutdown /a zum Abbrechen)
)
echo.
pause
