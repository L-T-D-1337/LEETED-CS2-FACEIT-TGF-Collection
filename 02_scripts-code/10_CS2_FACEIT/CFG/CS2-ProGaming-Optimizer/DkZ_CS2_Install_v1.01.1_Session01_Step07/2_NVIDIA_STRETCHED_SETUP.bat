@echo off
:: ============================================================
::  LEETED - NVIDIA STRETCHED SETUP  (powered by DkZ devkitz)
::  Version: v1.01.1_Session01_Step07
::  FIX: 1280x960 + 1280x1024 stretched @ 143 Hz (Custom Res)
:: ============================================================
setlocal EnableDelayedExpansion
title LEETED Nvidia Stretched v1.01.1_Session01_Step07
color 0C
for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
goto NV_START

:BANNER
cls
echo.
echo    ##      ######  ######  ########  ######  #####
echo    ##      ##      ##         ##     ##      ##  ##
echo    ##      #####   #####      ##     #####   ##   ##
echo    ##      ##      ##         ##     ##      ##  ##
echo    ######  ######  ######     ##     ######  #####
echo.
echo    ============ N V I D I A   S T R E T C H ============
echo                                       ... powered by DkZ
echo.
exit /b 0

:SPIN
setlocal
<nul set /p ="   %~1 "
for %%s in (- \ ^| / - \ ^| /) do (
    <nul set /p =%%s
    ping -n 1 -w 90 127.0.0.1 >nul
    <nul set /p =!BS!
)
echo [OK]
endlocal
exit /b 0

:NV_START
call :BANNER
echo   PROBLEM-DIAGNOSE (dein Fall):
echo   Stretched funktioniert bei 99 Hz, aber NICHT bei 143/144 Hz.
echo   URSACHE: GPU-Scaling gilt PRO MODUS. Der Modus
echo   "1280x960 @ 144Hz" existiert auf deinem Monitor nicht -
echo   also kann Nvidia dort nichts strecken.
echo   FIX: Wir legen den Modus selbst an. 3 Schritte:
echo.
pause
call :SPIN "Starte Nvidia Systemsteuerung..."
start "" "%ProgramFiles%\NVIDIA Corporation\Control Panel Client\nvcplui.exe" 2>nul
if errorlevel 1 start "" nvcplui.exe 2>nul

call :BANNER
echo   -----------------------------------------------------
echo    SCHRITT 1 - CUSTOM RESOLUTION ANLEGEN (der Kern-Fix)
echo   -----------------------------------------------------
echo    Nvidia Panel: "Anzeige" ^> "Aufloesung aendern"
echo.
echo    [1] Button "Anpassen..." (unten)
echo    [2] Haken: "Aufloesungen aktivieren, die nicht vom
echo        Bildschirm unterstuetzt werden"
echo    [3] "Benutzerdefinierte Aufloesung erstellen" - ZWEIMAL:
echo.
echo        MODUS A:  1280 x 960   @ 143 Hz   (4:3)
echo        MODUS B:  1280 x 1024  @ 143 Hz   (5:4)
echo.
echo          Timing/Standard:  Automatisch
echo    [4] Jeweils: "Testen" ^> Bild kommt ^> "Ja" ^> OK
echo.
echo    ^>^> Beide Modi existieren jetzt mit 143 Hz.
echo.
pause
call :BANNER
echo   -----------------------------------------------------
echo    SCHRITT 2 - GPU-SCALING FUER DEN NEUEN MODUS SETZEN
echo   -----------------------------------------------------
echo    WICHTIG: Scaling ist pro Modus gespeichert!
echo.
echo    FUER JEDEN DER BEIDEN MODI EINZELN wiederholen:
echo    [1] "Aufloesung aendern": waehle 1280x960 @ 143Hz
echo        und klicke UEBERNEHMEN (kurz drin bleiben!)
echo    [2] "Desktop-Groesse und -Position anpassen":
echo          Skalierungsmodus:      VOLLBILD
echo          Skalierung auf:        GPU
echo          Haken: "Von Spielen und Programmen festgelegte
echo                  Einstellung ausser Kraft setzen"
echo        ^> UEBERNEHMEN
echo    [3] Dasselbe fuer 1280x1024 @ 143Hz wiederholen
echo        (Modus waehlen ^> Uebernehmen ^> Vollbild/GPU pruefen).
echo    [4] Danach Aufloesung zurueck auf deine native stellen.
echo.
echo    CHECK: HDR = AUS, DSR-Faktoren = AUS (3D-Einstellungen),
echo    sonst kapert das die Skalierung.
echo.
pause
call :BANNER
echo   -----------------------------------------------------
echo    SCHRITT 3 - CS2 EINSTELLEN
echo   -----------------------------------------------------
echo    CS2 ^> Einstellungen ^> Video:
echo      Anzeigemodus:        Vollbild (exklusiv!)
echo      Variante A: Seitenverh. 4:3  ^> 1280x960  @ 143 Hz
echo      Variante B: Seitenverh. 5:4  ^> 1280x1024 @ 143 Hz
echo.
echo    ^>^> Beide Varianten voll gestreckt BEI 143 Hz.
echo       Einfach in CS2 umschalten - Scaling greift fuer beide.
echo.
echo   -----------------------------------------------------
echo    FALLS 144 IN CS2 NICHT AUFTAUCHT:
echo    - Spiel neu starten (liest Modi nur beim Start)
echo    - In Schritt 1 exakt die Hz nehmen, die dein Monitor
echo      nativ kann (144 oder 143.85 ^> dann 143 eintragen)
echo    - DisplayPort statt HDMI nutzen (HDMI limitiert oft Hz
echo      bei Custom Resolutions)
echo   -----------------------------------------------------
echo.
pause
