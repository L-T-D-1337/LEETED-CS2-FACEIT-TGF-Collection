# ============================================================
#  LEETED - CS2 Display Reparatur  (powered by DkZ devkitz)
#  v1.01.1_Session01_Step07
#  Holt dich von 60 Hz weg, setzt Stretching - mit Backup+Rollback.
# ============================================================
$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bkp   = Join-Path $PSScriptRoot "DkZ_Backup_$stamp"
New-Item -ItemType Directory -Path $bkp -Force | Out-Null
$log   = Join-Path $bkp "repair.log"
function L($t){ $t | Tee-Object -FilePath $log -Append; Write-Host $t }

# ---- Win32 API fuer Aufloesung/Hz (ChangeDisplaySettingsEx) ----
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WD {
    [DllImport("user32.dll")] public static extern bool EnumDisplaySettings(string d, int m, ref DEVMODE dm);
    [DllImport("user32.dll")] public static extern int ChangeDisplaySettings(ref DEVMODE dm, int flags);
    public const int CDS_UPDATEREGISTRY = 0x01;
    public const int CDS_TEST = 0x02;
    public const int ENUM_CURRENT = -1;
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
        public short dmSpecVersion; public short dmDriverVersion; public short dmSize;
        public short dmDriverExtra; public int dmFields;
        public int dmPositionX; public int dmPositionY; public int dmDisplayOrientation; public int dmDisplayFixedOutput;
        public short dmColor; public short dmDuplex; public short dmYResolution; public short dmTTOption;
        public short dmCollate; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
        public short dmLogPixels; public int dmBitsPerPel; public int dmPelsWidth; public int dmPelsHeight;
        public int dmDisplayFlags; public int dmDisplayFrequency;
        public int dmICMMethod; public int dmICMIntent; public int dmMediaType; public int dmDitherType;
        public int dmReserved1; public int dmReserved2; public int dmPanningWidth; public int dmPanningHeight;
    }
}
"@

function Get-Modes {
    $list = @(); $dm = New-Object WD+DEVMODE
    $dm.dmSize = [Runtime.InteropServices.Marshal]::SizeOf($dm); $i=0
    while ([WD]::EnumDisplaySettings($null,$i,[ref]$dm)) {
        $list += [pscustomobject]@{ W=$dm.dmPelsWidth; H=$dm.dmPelsHeight; Hz=$dm.dmDisplayFrequency }
        $i++
    }
    $list | Sort-Object W,H,Hz -Unique
}

function Set-Mode($w,$h,$hz){
    $dm = New-Object WD+DEVMODE
    $dm.dmSize = [Runtime.InteropServices.Marshal]::SizeOf($dm)
    [WD]::EnumDisplaySettings($null, [WD]::ENUM_CURRENT, [ref]$dm) | Out-Null
    $dm.dmPelsWidth=$w; $dm.dmPelsHeight=$h; $dm.dmDisplayFrequency=$hz
    # DM_PELSWIDTH=0x80000 | DM_PELSHEIGHT=0x100000 | DM_DISPLAYFREQUENCY=0x400000
    $dm.dmFields = 0x80000 -bor 0x100000 -bor 0x400000
    $test = [WD]::ChangeDisplaySettings([ref]$dm, [WD]::CDS_TEST)
    if ($test -ne 0) { return $false }
    $res = [WD]::ChangeDisplaySettings([ref]$dm, [WD]::CDS_UPDATEREGISTRY)
    return ($res -eq 0)
}

function Backup-Scaling {
    $base = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    $regFile = Join-Path $bkp "scaling_backup.reg"
    "Windows Registry Editor Version 5.00`n" | Out-File $regFile -Encoding ASCII
    Get-ChildItem -Path $base -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $v = (Get-ItemProperty -Path $_.PSPath -Name Scaling -ErrorAction SilentlyContinue).Scaling
        if ($v -ne $null) {
            $rk = ($_.PSPath -replace 'Microsoft.PowerShell.Core\\Registry::HKEY_LOCAL_MACHINE','HKEY_LOCAL_MACHINE')
            "[$rk]" | Out-File $regFile -Append -Encoding ASCII
            "`"Scaling`"=dword:$('{0:x8}' -f $v)`n" | Out-File $regFile -Append -Encoding ASCII
        }
    }
    L "  [BACKUP] Scaling-Werte gesichert -> $regFile"
}

function Set-Stretched {
    Backup-Scaling
    $base = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    $count = 0
    Get-ChildItem -Path $base -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $cur = (Get-ItemProperty -Path $_.PSPath -Name Scaling -ErrorAction SilentlyContinue).Scaling
        if ($cur -ne $null) {
            Set-ItemProperty -Path $_.PSPath -Name Scaling -Value 3 -Type DWord
            $count++
        }
    }
    L "  [OK] Scaling=3 (Vollbild/Stretched) auf $count Monitor-Eintrag(e) gesetzt."
    if ($count -eq 0) { L "  [HINWEIS] Kein bestehender Scaling-Wert -> greift erst nach 1x manuellem GPU-Scaling ODER Custom-Res." }
}

function Restart-GPU {
    L "  [GPU] Starte Grafikadapter neu (Bordmittel)..."
    $gpu = Get-PnpDevice -Class Display -Status OK -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($gpu) {
        Disable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Enable-PnpDevice  -InstanceId $gpu.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
        L "  [OK] Adapter '$($gpu.FriendlyName)' neugestartet."
    } else { L "  [WARN] Kein Adapter gefunden - manueller Neustart noetig." }
}

# ---------------- MENUE ----------------
function Banner {
    Clear-Host
    Write-Host ""
    Write-Host "   ##      ######  ######  ########  ######  #####" -ForegroundColor Red
    Write-Host "   ##      ##      ##         ##     ##      ##  ##" -ForegroundColor Red
    Write-Host "   ##      #####   #####      ##     #####   ##   ##" -ForegroundColor Red
    Write-Host "   ##      ##      ##         ##     ##      ##  ##" -ForegroundColor Red
    Write-Host "   ######  ######  ######     ##     ######  #####" -ForegroundColor Red
    Write-Host ""
    Write-Host "   ========= DISPLAY-REPARATUR  v1.01.1_S01_Step07 =========" -ForegroundColor DarkGray
    Write-Host "                                        ... powered by DkZ" -ForegroundColor DarkGray
    Write-Host ""
}

:menu while ($true) {
    Banner
    Write-Host "   [1] NOTFALL: 60Hz-Sperre loesen (native Aufloesung @ max Hz)"
    Write-Host "   [2] Modus manuell setzen (Aufloesung + Hz frei waehlen)"
    Write-Host "   [3] STRETCHED aktivieren (Scaling=3, Vollbild gestreckt)"
    Write-Host "   [4] Grafikadapter neu starten (ohne Reboot)"
    Write-Host "   [5] KOMPLETT: 60Hz loesen + Stretched + Adapter-Neustart"
    Write-Host "   [R] Rollback-Info anzeigen"
    Write-Host "   [X] Beenden"
    Write-Host ""
    $c = Read-Host "   Auswahl"

    switch -Regex ($c) {
        '^1$' {
            $modes = Get-Modes
            $native = $modes | Sort-Object { $_.W * $_.H } -Descending | Select-Object -First 1
            $best = ($modes | Where-Object { $_.W -eq $native.W -and $_.H -eq $native.H } | Sort-Object Hz -Descending | Select-Object -First 1)
            L "  [1] Setze $($best.W)x$($best.H) @ $($best.Hz)Hz ..."
            if (Set-Mode $best.W $best.H $best.Hz) { L "  [OK] 60Hz-Sperre geloest -> $($best.Hz)Hz aktiv." }
            else { L "  [FEHLER] Modus abgelehnt. Bitte Option 2 mit anderem Wert." }
            Pause
        }
        '^2$' {
            $modes = Get-Modes
            Write-Host "`n   Verfuegbare Modi:" -ForegroundColor Cyan
            $modes | ForEach-Object { Write-Host ("     {0}x{1} @ {2}Hz" -f $_.W,$_.H,$_.Hz) }
            $rw = [int](Read-Host "`n   Breite"); $rh=[int](Read-Host "   Hoehe"); $rhz=[int](Read-Host "   Hz")
            if (Set-Mode $rw $rh $rhz) { L "  [OK] $rw x $rh @ $rhz Hz gesetzt." }
            else { L "  [FEHLER] Modus $rw x $rh @ $rhz existiert nicht/abgelehnt." }
            Pause
        }
        '^3$' { Set-Stretched; L "  -> Danach Option 4 (Adapter-Neustart) fuer sofortige Wirkung."; Pause }
        '^4$' { Restart-GPU; Pause }
        '^5$' {
            $modes = Get-Modes
            $native = $modes | Sort-Object { $_.W * $_.H } -Descending | Select-Object -First 1
            $best = ($modes | Where-Object { $_.W -eq $native.W -and $_.H -eq $native.H } | Sort-Object Hz -Descending | Select-Object -First 1)
            Set-Mode $best.W $best.H $best.Hz | Out-Null
            L "  [5a] 60Hz-Sperre geloest -> $($best.Hz)Hz."
            Set-Stretched
            Restart-GPU
            L "  [5-FERTIG] System zurueck + Stretched aktiv."
            Pause
        }
        '^[Rr]$' {
            Write-Host "`n   ROLLBACK:" -ForegroundColor Yellow
            Write-Host "   - Scaling zuruecksetzen: Doppelklick auf scaling_backup.reg in:"
            Write-Host "     $bkp"
            Write-Host "   - Aufloesung/Hz: einfach neuen Modus via Option 1/2 setzen."
            Pause
        }
        '^[Xx]$' { break menu }
        default { }
    }
}
Write-Host "`n  Backup+Log: $bkp" -ForegroundColor Green
