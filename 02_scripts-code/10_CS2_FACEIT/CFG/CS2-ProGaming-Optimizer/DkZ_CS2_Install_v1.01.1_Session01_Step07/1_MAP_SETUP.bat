@echo off
:: ============================================================
::  DkZ devkitz - CS2 MAP-SETUP (3 Baustellen, waehlbar)
::  Version: v1.01.1_Session01_Step07
::  [1] CSAFAP  [2] Radar/Callouts  [3] GoldKingZ (Server)
::  [A] Alle    - konfliktfrei: Backup + Rollback + Verify
:: ============================================================
setlocal EnableDelayedExpansion
title DkZ Map-Setup v1.01.1_Session01_Step07
color 0C

:: ============================================================
::  LEETED - CS2 MAP-SETUP  (powered by DkZ devkitz)
::  Version: v1.01.1_Session01_Step07
:: ============================================================

:: ------- ANIMATION SUBROUTINES (rein kosmetisch) -------
goto AFTER_SUBS

:SPIN
:: %1 = Text
setlocal
<nul set /p ="   %~1 "
for %%s in (- \ ^| / - \ ^| / - \ ^| /) do (
    <nul set /p =%%s
    ping -n 1 -w 90 127.0.0.1 >nul
    <nul set /p =!BS!
)
echo [OK]
endlocal
exit /b 0

:PBAR
:: %1 = Text  - Fortschrittsbalken
setlocal
echo    %~1
<nul set /p ="   ["
for /l %%i in (1,1,24) do (
    <nul set /p =#
    ping -n 1 -w 35 127.0.0.1 >nul
)
echo ] 100%%
endlocal
exit /b 0

:BANNER
cls
echo.
echo    ##      ######  ######  ########  ######  #####
echo    ##      ##      ##         ##     ##      ##  ##
echo    ##      #####   #####      ##     #####   ##   ##
echo    ##      ##      ##         ##     ##      ##  ##
echo    ######  ######  ######     ##     ######  #####
echo.
echo    ================= C S 2   S E T U P =================
echo                                       ... powered by DkZ
echo.
exit /b 0

:AFTER_SUBS
:: Backspace-Zeichen fuer Spinner
for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"


set "TS=%date:~-4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%"
set "TS=%TS: =0%"
set "LOG=%~dp0dkz_setup_%TS%.log"
set "BKP=%~dp0DkZ_Backup_%TS%"
echo DkZ Setup-Log %date% %time% > "%LOG%"

:MENU
call :BANNER
echo   v1.01.1_Session01_Step07
echo.
echo   [1] CSAFAP Config Package     (Lineups, Practice, Wheels)
echo   [2] Radar + Callout-Setup     (dkz_radar.cfg)
echo   [3] GoldKingZ Map-Configs     (NUR fuer eigenen SERVER!)
echo   [A] ALLE drei Baustellen
echo   [X] Abbrechen (nichts wird veraendert)
echo.
set "WAHL="
set /p WAHL="  Auswahl: "
if /i "%WAHL%"=="X" exit /b 0
if /i "%WAHL%"=="1" ( set "DO1=1" & set "DO2=" & set "DO3=" & goto PREFLIGHT )
if /i "%WAHL%"=="2" ( set "DO1="  & set "DO2=1" & set "DO3=" & goto PREFLIGHT )
if /i "%WAHL%"=="3" ( set "DO1="  & set "DO2="  & set "DO3=1" & goto PREFLIGHT )
if /i "%WAHL%"=="A" ( set "DO1=1" & set "DO2=1" & set "DO3=1" & goto PREFLIGHT )
goto MENU

:PREFLIGHT
echo.
:: ---- CS2-Prozess-Check (nur relevant fuer 1+2) ----
if defined DO1 goto CHECKPROC
if defined DO2 goto CHECKPROC
goto FINDSTEAM
:CHECKPROC
tasklist /FI "IMAGENAME eq cs2.exe" 2>nul | find /I "cs2.exe" >nul
if not errorlevel 1 (
    color 0E
    echo  [KONFLIKT] CS2 laeuft! Bitte beenden, dann neu starten.
    echo  KONFLIKT: cs2.exe laeuft >> "%LOG%"
    pause & exit /b 1
)
echo  [OK] CS2 ist nicht gestartet.

:FINDSTEAM
if not defined DO1 if not defined DO2 goto TASK3
:: ---- Steam/CS2-Pfad (Registry + alle Libraries) ----
set "STEAM="
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM=%%b"
if not defined STEAM set "STEAM=C:\Program Files (x86)\Steam"
set "STEAM=%STEAM:/=\%"
set "CS2=%STEAM%\steamapps\common\Counter-Strike Global Offensive"
if not exist "%CS2%\game\csgo\cfg" (
    for /f "usebackq tokens=2 delims=	 " %%p in (`findstr /i "path" "%STEAM%\steamapps\libraryfolders.vdf" 2^>nul`) do (
        set "LIB=%%~p"
        set "LIB=!LIB:\\=\!"
        if exist "!LIB!\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg" (
            set "CS2=!LIB!\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)
if not exist "%CS2%\game\csgo\cfg" (
    color 0E
    echo  [FEHLER] CS2 nicht gefunden.
    set /p CS2="  CS2-Pfad manuell (bis '...Counter-Strike Global Offensive'): "
)
if not exist "%CS2%\game\csgo\cfg" (
    echo  [ABBRUCH] Pfad ungueltig. NICHTS veraendert. & echo ABBRUCH Pfad >> "%LOG%"
    pause & exit /b 1
)
echo  [OK] CS2: %CS2%
echo  CS2: %CS2% >> "%LOG%"
mkdir "%BKP%" >nul 2>&1

:: ============================================================
:: BAUSTELLE 1 - CSAFAP
:: ============================================================
if not defined DO1 goto TASK2
echo.
echo  --- [1] CSAFAP ---
call :SPIN "Pruefe Quellpaket..."
if not exist "%~dp0csafap\MAIN.cfg" ( echo [FEHLER] Quelle: MAIN.cfg fehlt & pause & exit /b 1 )
if not exist "%~dp0csafap\addons\.vtest" ( echo [FEHLER] Quelle: .vtest fehlt & pause & exit /b 1 )
if exist "%CS2%\game\csgo\cfg\csafap" (
    echo  [KONFLIKT ERKANNT] csafap existiert - sichere nach Backup...
    xcopy /E /I /H /K /Y "%CS2%\game\csgo\cfg\csafap" "%BKP%\csafap" >nul
)
if exist "%CS2%\game\csgo\resource\platform_english.txt" copy /Y "%CS2%\game\csgo\resource\platform_english.txt" "%BKP%\platform_english.txt" >nul
if exist "%CS2%\game\csgo\cfg\autoexec.cfg" copy /Y "%CS2%\game\csgo\cfg\autoexec.cfg" "%BKP%\autoexec.cfg" >nul
call :PBAR "Installiere CSAFAP..."
xcopy /E /I /H /K /Y "%~dp0csafap" "%CS2%\game\csgo\cfg\csafap" >nul
xcopy /E /I /H /K /Y "%~dp0csafap\csgo" "%CS2%\game\csgo" >nul
if not exist "%CS2%\game\csgo\cfg\csafap\addons\.vtest" ( echo [VERIFY-FEHLER] .vtest fehlt im Ziel! & echo VERIFY FEHLER 1 >> "%LOG%" & pause & exit /b 1 )
set "LAUNCH=+exec csafap/main -testscript_inline "Test_Run ../../csgo/cfg/csafap/addons/.vtest""
echo !LAUNCH!| clip
echo  [OK] CSAFAP installiert + verifiziert. Startoptionen in Zwischenablage.
echo  CSAFAP OK >> "%LOG%"

:: ============================================================
:: BAUSTELLE 2 - RADAR/CALLOUTS
:: ============================================================
:TASK2
if not defined DO2 goto TASK3
echo.
echo  --- [2] RADAR/CALLOUTS ---
call :SPIN "Setze Radar-Optimierung..."
if exist "%CS2%\game\csgo\cfg\dkz_radar.cfg" copy /Y "%CS2%\game\csgo\cfg\dkz_radar.cfg" "%BKP%\dkz_radar.cfg" >nul
copy /Y "%~dp0dkz_radar.cfg" "%CS2%\game\csgo\cfg\dkz_radar.cfg" >nul
if not exist "%CS2%\game\csgo\cfg\dkz_radar.cfg" ( echo [VERIFY-FEHLER] dkz_radar.cfg & echo VERIFY FEHLER 2 >> "%LOG%" & pause & exit /b 1 )
echo  [OK] dkz_radar.cfg installiert. Im Spiel: exec dkz_radar
echo  RADAR OK >> "%LOG%"

:: ============================================================
:: BAUSTELLE 3 - GOLDKINGZ (SERVER-ONLY)
:: ============================================================
:TASK3
if not defined DO3 goto DONE
echo.
echo  --- [3] GOLDKINGZ MAP-CONFIGS (SERVER-PLUGIN) ---
call :SPIN "Lade Server-Modul..."
echo  [WICHTIG] Laeuft NUR auf einem dedizierten CS2-Server
echo  mit Metamod:Source 2.x + CounterStrikeSharp.
echo  Im normalen CS2-Client hat es KEINE Funktion.
echo.
set "SRV="
set /p SRV="  Pfad zu deinem SERVER-csgo-Ordner (leer = ueberspringen): "
if "%SRV%"=="" (
    echo  [UEBERSPRUNGEN] Kein Serverpfad - Dateien bleiben im Paket unter server-only\.
    echo  GOLDKINGZ uebersprungen >> "%LOG%"
    goto DONE
)
if not exist "%SRV%\addons\counterstrikesharp\plugins" (
    color 0E
    echo  [KONFLIKT] Kein CounterStrikeSharp gefunden unter:
    echo  %SRV%\addons\counterstrikesharp\plugins
    echo  Installation abgebrochen - erst CSS + Metamod installieren.
    echo  GOLDKINGZ: CSS fehlt >> "%LOG%"
    goto DONE
)
mkdir "%BKP%" >nul 2>&1
if exist "%SRV%\addons\counterstrikesharp\plugins\Map-Configs-GoldKingZ" (
    xcopy /E /I /Y "%SRV%\addons\counterstrikesharp\plugins\Map-Configs-GoldKingZ" "%BKP%\Map-Configs-GoldKingZ" >nul
)
xcopy /E /I /Y "%~dp0server-only\cs2-Map-Configs-GoldKingZ-main" "%SRV%\addons\counterstrikesharp\plugins\Map-Configs-GoldKingZ" >nul
mkdir "%SRV%\cfg\Map-Configs" >nul 2>&1
echo  [OK] GoldKingZ installiert. Map-Cfgs kommen nach: %SRV%\cfg\Map-Configs\
echo  GOLDKINGZ OK >> "%LOG%"

:DONE
:: ---- Rollback-Script ----
if exist "%BKP%" (
(
echo @echo off
echo :: DkZ Rollback v1.01.1_Session01_Step07
echo rmdir /S /Q "%CS2%\game\csgo\cfg\csafap" 2^>nul
echo if exist "%BKP%\csafap" xcopy /E /I /H /K /Y "%BKP%\csafap" "%CS2%\game\csgo\cfg\csafap" ^>nul
echo if exist "%BKP%\platform_english.txt" copy /Y "%BKP%\platform_english.txt" "%CS2%\game\csgo\resource\platform_english.txt" ^>nul
echo del /Q "%CS2%\game\csgo\cfg\dkz_radar.cfg" 2^>nul
echo if exist "%BKP%\dkz_radar.cfg" copy /Y "%BKP%\dkz_radar.cfg" "%CS2%\game\csgo\cfg\dkz_radar.cfg" ^>nul
echo echo Rollback fertig. Startoptionen in Steam manuell entfernen!
echo pause
) > "%BKP%\ROLLBACK.bat"
)
echo.
echo  =====================================================
echo   FERTIG. Log: %LOG%
if exist "%BKP%" echo   Backup + ROLLBACK.bat: %BKP%
echo  =====================================================
if defined DO1 (
echo.
echo   CSAFAP - noch 2 manuelle Schritte:
echo   1. csafap\MAIN.cfg ^> Zeile 6: Sensitivity eintragen
echo   2. Steam ^> CS2 ^> Startoptionen ^> STRG+V
)
echo.
pause
