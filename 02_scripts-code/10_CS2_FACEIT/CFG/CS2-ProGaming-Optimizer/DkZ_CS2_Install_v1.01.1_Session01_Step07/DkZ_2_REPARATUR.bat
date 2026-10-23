@echo off
:: ============================================================
::  LEETED - 1-Klick DISPLAY-REPARATUR  (powered by DkZ)
::  v1.01.1_Session01_Step07  |  Backup + Rollback integriert
:: ============================================================
title LEETED Reparatur v1.01.1_S01_Step07
color 0C
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Fordere Administrator-Rechte an...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_repair.ps1"
