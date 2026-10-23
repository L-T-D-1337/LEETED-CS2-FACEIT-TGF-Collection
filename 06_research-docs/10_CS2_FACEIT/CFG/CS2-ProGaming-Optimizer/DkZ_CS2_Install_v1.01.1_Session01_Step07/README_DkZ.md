# DkZ CS2 Install-Paket — v1.01.1_Session01_Step07

## Inhalt
| Datei | Zweck |
|---|---|
| ``1_MAP_SETUP.bat` | Menü: [1] CSAFAP  [2] Radar/Callouts  [3] GoldKingZ (Server)  [A] Alle — je mit Backup, Verify, Rollback |
| `2_NVIDIA_STRETCHED_SETUP.bat` | Gefuehrtes Setup: GPU-Skalierung "Vollbild" (4:3 stretched, immer Fullscreen) |
| `dkz_radar.cfg` | Radar/Overview-Optimierung + eigener Standort-Callout (separate Datei) |
| `csafap/` | Original CSAFAP-Ordner (unveraendert) |
| `CSAFAP-original.zip` | Original-Repo-ZIP als Backup |
| `server-only/` | GoldKingZ Map-Configs (Server-Plugin, siehe HINWEIS.txt) |

## Reihenfolge
1. `1_INSTALL_CSAFAP.bat` als **Administrator** ausfuehren
2. `csafap\main.cfg` oeffnen → **Sensitivity oben eintragen**
3. Steam → CS2 → Startoptionen → **STRG+V** (liegt in Zwischenablage)
4. `2_NVIDIA_STRETCHED_SETUP.bat` ausfuehren
5. Im Spiel: `exec dkz_radar` in die Konsole

## Callouts auf der Karte — ehrliche Info
CS2 zeigt Callout-NAMEN nicht nativ als Text auf dem Radar/Overview
(das ging nur in CS:GO via SimpleRadar). `dkz_radar.cfg` holt das
Maximum raus: ganze Map sichtbar, groesseres Radar, eigener
Standort-Callout im HUD. Die CSAFAP Map-Guides zeigen zusaetzlich
1000+ Lineups direkt in-game (Taste M → Practice Mode).

## Evaluierungs-Report (Step07, konfliktfrei geprueft)
1. **CSAFAP setzt KEINE Radar-Cvars** → `dkz_radar.cfg` kollidiert nicht. ✅
2. **Ungueltige Cvar entfernt** (`cl_hud_get_position` existiert in CS2 nicht) → cfg enthaelt nur verifizierte Befehle. ✅
3. **`.vtest` (Dotfile)**: xcopy jetzt mit `/H /K` → wird garantiert mitkopiert (haeufigster Install-Fehler laut FAQ Q23). ✅
4. **`platform_english.txt` wird ueberschrieben** → Original wird VOR Installation automatisch gesichert. ✅
5. **Hardened Installer**: CS2-Prozess-Check, Quell-Integritaetscheck, Timestamp-Backup, auto-generiertes `ROLLBACK.bat`, Logfile, 4-Punkte-Verify nach Installation. ✅
6. **Deine autoexec.cfg wird nie veraendert** (nur mitgesichert). Tastenkonflikt-Hinweis: CSAFAP nutzt 1,2,3,N,H,J,K,M,Space,Q,W,A,S,D. ✅
7. **GoldKingZ** bleibt Server-only, unangetastet. ✅
