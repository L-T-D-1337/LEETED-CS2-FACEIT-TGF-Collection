# 🚑 LEETED Display-Notfall — v1.01.1_Session01_Step07

## Was ist passiert?
Du hast **1280x940** getestet — ein **ungültiger Modus** (kein Standard-Timing).
Der Treiber hat abgelehnt und ist auf **60 Hz** zurückgefallen. Deine 143-Hz-Modi
sind nicht kaputt, du kommst über dein debloated Windows nur gerade nicht an die
Anzeige-Einstellungen (`rundll32`-Fehler = fehlende Windows-Komponente).
**Kein Hardware-Schaden.**

## SOFORT-FIX (2 Klicks)
1. **`DkZ_1_DIAGNOSE.bat`** als Admin → erzeugt `DkZ_Diagnose_*.txt`
   → diese Datei an DkZ/Claude schicken (dann sehe ich exakt deine Modi & Werte).
2. **`DkZ_2_REPARATUR.bat`** als Admin → Menü:
   - **[1]** löst die 60-Hz-Sperre (setzt native Auflösung @ höchste Hz)
   - **[5]** macht alles: 60 Hz lösen + Stretched aktivieren + Adapter-Neustart

> Beide Skripte nutzen **Windows-Bordmittel** (Win32-API `ChangeDisplaySettingsEx`
> + `Get-PnpDevice`). Sie umgehen deine kaputte Anzeige komplett — **kein
> Nvidia-Panel, kein Fremdtool nötig.**

## Stretching — die Wahrheit
- **Nvidia Profile Inspector kann KEIN Stretching** (nur 3D-Flags).
- Stretching = **ein** Registry-Wert pro Monitor:
  `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration\...\00\00\Scaling`
  - `1` = Aspect (Balken) · `2` = Zentriert · **`3` = VOLLBILD/STRETCHED** · `5` = Integer
- Das Reparatur-Skript setzt **`Scaling=3`** und sichert vorher den alten Wert
  als `scaling_backup.reg` (Rollback per Doppelklick).

## Custom Resolution (für 1280x960 & 1280x1024 @ 143 Hz)
Ohne Nvidia-Panel geht das am saubersten mit **CRU** (ToastyX, Freeware):
- Download: https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU
- `CRU.exe` → Detailed Resolution → 1280x960 @143 + 1280x1024 @143 anlegen
- `restart64.exe` (im CRU-Ordner) → Treiber neu, **kann blind ausgeführt werden**
- **Notausgang bei schwarzem Bild:** `reset-all.exe` (im CRU-Ordner) setzt ALLE
  Custom-Modi zurück → das ist auch dein Retter, falls je wieder was hängt.

## Rollback
- Auflösung/Hz: einfach neuen Modus über Reparatur-Menü [1]/[2] setzen.
- Scaling: `scaling_backup.reg` im `DkZ_Backup_*`-Ordner doppelklicken.

## Major-Ready-Checkliste (nach Fix)
1. Native Auflösung @ 143/144 Hz stabil ✔
2. 1280x960 (oder 1024) via CRU angelegt, @143 Hz ✔
3. `Scaling=3` gesetzt → CS2 4:3 voll gestreckt ✔
4. CS2: Vollbild **exklusiv**, HDR aus, DSR aus ✔
5. `exec dkz_radar` für Radar/Callout-Setup ✔
