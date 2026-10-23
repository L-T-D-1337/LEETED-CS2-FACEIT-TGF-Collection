@echo off
:: ============================================================
::  LEETED - 1-Klick DISPLAY-DIAGNOSE  (powered by DkZ)
::  v1.01.1_Session01_Step07  |  liest nur aus, aendert NICHTS
:: ============================================================
title LEETED Diagnose v1.01.1_S01_Step07
color 0C
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Fordere Administrator-Rechte an...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
cls
echo.
echo    ##      ######  ######  ########  ######  #####
echo    ##      ##      ##         ##     ##      ##  ##
echo    ##      #####   #####      ##     #####   ##   ##
echo    ##      ##      ##         ##     ##      ##  ##
echo    ######  ######  ######     ##     ######  #####
echo.
echo    =========== 1-KLICK DISPLAY-DIAGNOSE ===========
echo                                  ... powered by DkZ
echo.
echo    Liest System, GPU, Modi, Scaling, Fehler aus.
echo    Es wird NICHTS veraendert.
echo.
pause
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_diag.ps1"
echo.
echo    FERTIG. Die erzeugte DkZ_Diagnose_*.txt bitte an DkZ schicken.
echo.
pause
