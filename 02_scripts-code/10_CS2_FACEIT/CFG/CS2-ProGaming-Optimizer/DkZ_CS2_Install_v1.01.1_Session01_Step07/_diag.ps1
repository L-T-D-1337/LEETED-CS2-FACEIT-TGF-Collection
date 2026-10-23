# ============================================================
#  LEETED - CS2 Display Diagnose  (powered by DkZ devkitz)
#  v1.01.1_Session01_Step07  |  READ-ONLY, veraendert nichts
# ============================================================
$ErrorActionPreference = "SilentlyContinue"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$out   = Join-Path $PSScriptRoot "DkZ_Diagnose_$stamp.txt"

function W($t){ $t | Tee-Object -FilePath $out -Append }

"" | Out-File $out
W "============================================================"
W " LEETED DISPLAY-DIAGNOSE  (powered by DkZ)"
W " Zeitpunkt: $(Get-Date)"
W "============================================================"

# ---------- 1. WINDOWS ----------
W "`n===== [1] WINDOWS ====="
$os = Get-CimInstance Win32_OperatingSystem
W (" OS            : {0}" -f $os.Caption)
W (" Version/Build : {0} (Build {1})" -f $os.Version, $os.BuildNumber)
# Debloat-Indikatoren
$hasSettings = Test-Path "$env:SystemRoot\ImmersiveControlPanel\SystemSettings.exe"
$hasDeskCpl  = Test-Path "$env:SystemRoot\System32\desk.cpl"
W (" SystemSettings.exe vorhanden : {0}" -f $hasSettings)
W (" desk.cpl vorhanden           : {0}" -f $hasDeskCpl)

# ---------- 2. GPU / TREIBER ----------
W "`n===== [2] GPU / TREIBER ====="
Get-CimInstance Win32_VideoController | ForEach-Object {
    W (" GPU           : {0}" -f $_.Name)
    W (" Treiber-Ver.  : {0}" -f $_.DriverVersion)
    W (" Treiber-Datum : {0}" -f $_.DriverDate)
    W (" Aktuell H x V : {0} x {1}" -f $_.CurrentHorizontalResolution, $_.CurrentVerticalResolution)
    W (" Aktuell Hz    : {0}" -f $_.CurrentRefreshRate)
    W (" Max Hz (WMI)  : {0}" -f $_.MaxRefreshRate)
    W ""
}
# Nvidia Control Panel vorhanden?
$nvcp = Test-Path "$env:ProgramFiles\NVIDIA Corporation\Control Panel Client\nvcplui.exe"
W (" Nvidia Control Panel (nvcplui.exe) vorhanden : {0}" -f $nvcp)

# ---------- 3. VERFUEGBARE MODI (Win32 EnumDisplaySettings) ----------
W "`n===== [3] VERFUEGBARE ANZEIGE-MODI (echte Treiber-Modi) ====="
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class DM {
    [DllImport("user32.dll")]
    public static extern bool EnumDisplaySettings(string devName, int mode, ref DEVMODE dm);
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
$dm = New-Object DM+DEVMODE
$dm.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($dm)
$seen = @{}
$i = 0
while ([DM]::EnumDisplaySettings($null, $i, [ref]$dm)) {
    $key = "{0}x{1}@{2}" -f $dm.dmPelsWidth, $dm.dmPelsHeight, $dm.dmDisplayFrequency
    if (-not $seen.ContainsKey($key)) {
        $seen[$key] = $true
        # nur 4:3 / 5:4 / native-relevante hervorheben
        $tag = ""
        if ($dm.dmPelsWidth -eq 1280 -and $dm.dmPelsHeight -eq 960)  { $tag = "  <== 4:3 Ziel" }
        if ($dm.dmPelsWidth -eq 1280 -and $dm.dmPelsHeight -eq 1024) { $tag = "  <== 5:4 Ziel" }
        W (" {0}$tag" -f $key)
    }
    $i++
}
W (" -> {0} eindeutige Modi gefunden." -f $seen.Count)
if (-not ($seen.Keys | Where-Object { $_ -like "1280x960@14*" })) {
    W " [BEFUND] 1280x960 @ 143/144 Hz FEHLT -> Custom Resolution noetig oder durch 940-Test verlorengegangen."
}

# ---------- 4. SCALING-REGISTRY (Stretched-Schalter) ----------
W "`n===== [4] SCALING-EINSTELLUNG (Registry) ====="
W " 1=Aspect(Balken) | 2=Zentriert | 3=VOLLBILD/STRETCHED | 5=Integer"
$base = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
$found = $false
Get-ChildItem -Path $base -Recurse | ForEach-Object {
    $p = $_.PSPath
    $v = (Get-ItemProperty -Path $p -Name Scaling -ErrorAction SilentlyContinue).Scaling
    if ($v -ne $null) {
        $found = $true
        $label = switch ($v) { 1 {"Aspect (Balken)"} 2 {"Zentriert"} 3 {"VOLLBILD/STRETCHED"} 4 {"Aspect max"} 5 {"Integer"} default {"unbekannt"} }
        W (" Scaling = {0}  ({1})" -f $v, $label)
        W ("   Pfad: {0}" -f ($p -replace 'Microsoft.PowerShell.Core\\Registry::',''))
    }
}
if (-not $found) { W " [INFO] Kein Scaling-Wert gefunden (Standard = Treiber-Default)." }

# ---------- 5. DISPLAY-FEHLER IM EVENTLOG ----------
W "`n===== [5] LETZTE DISPLAY/GPU-FEHLER (Eventlog, 7 Tage) ====="
$since = (Get-Date).AddDays(-7)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$since} -ErrorAction SilentlyContinue |
    Where-Object { $_.ProviderName -match 'nvlddmkm|Display|WHEA|Video' -or $_.LevelDisplayName -eq 'Error' } |
    Select-Object -First 15 TimeCreated, ProviderName, Id, LevelDisplayName |
    ForEach-Object { W (" {0} | {1} | ID {2} | {3}" -f $_.TimeCreated, $_.ProviderName, $_.Id, $_.LevelDisplayName) }

# ---------- 6. rundll32 / Anzeige-Zugang ----------
W "`n===== [6] ANZEIGE-ZUGANG (rundll32-Fehlerquelle) ====="
W (" ms-settings:display Handler in Registry : {0}" -f (Test-Path "HKCR:\ms-settings"))
W (" desk.cpl startbar                       : {0}" -f $hasDeskCpl)
W " HINWEIS: Reparatur-Skript nutzt Win32-API direkt -> unabhaengig von rundll32/desk.cpl."

W "`n============================================================"
W " DIAGNOSE FERTIG. Datei: $out"
W " -> Diese .txt an DkZ/Claude schicken fuer den Feinschliff."
W "============================================================"

Write-Host ""
Write-Host "  Log gespeichert: $out" -ForegroundColor Green
Write-Host ""
