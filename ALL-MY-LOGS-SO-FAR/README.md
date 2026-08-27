# CK2 Monarch's Journey — log archive (organized)

Raw reverse-engineering session files, sorted. **Perfect byte-for-byte
duplicates have been deleted.** Unique content only.

## The project (one sentence)
Restore the retired **Monarch's Journey / Featured Rulers / Bronzeman** mode of
Crusader Kings II for **personal, fully offline use on Windows**, via payload
re-activation, version archaeology, and hash-guarded executable patches
(v1→v7 done; **V7 = in-game Continue** proven; launcher Continue is C25). Featured Rulers is a planned
follow-on (see `00_START_HERE/FEATURED_RULERS.md`).

## Read in this order
1. **`00_START_HERE/`**
   - `STATUS.md` — current authoritative state
   - **`CASES_AND_FINDINGS.md`** — solved / unsolved / partial / info map
   - **`FR_MJ_COMPLETE_ROSTER.md`** — every FR+MJ ruler, bio, B/S/G challenge (text-only)
   - **`FEATURED_RULERS.md`** — FR UI/timeline/assets/restore checklist
   - **`SCREENSHOTS_CATALOG.md`** — image intents (optional; roster is complete without pics)
   - original prompt + organize-prompt templates (**v6** is the operative one; v1–v5 kept as history)
2. **`01_research_archives/`** — Parts 1–3 structured archives
3. **`02_handoffs/`** — **one** handoff (`CK2_MJ_ULTIMATE_HANDOFF.md`, deep background; older handoffs merged into it 2026-08-26) + completed PDB-investigation mission brief
4. **`03_analysis/`** — binary analysis, patch maps, banned artifacts, Continue semantics
5. **`04_test_guides_and_reports/`** — in-game click paths
6. **`05_patches_and_scripts/`** — guarded bat/ps1/py patchers (only things that touch the exe)
7. **`06_game_data/`** — `monarchs` payloads, loc CSVs, GUI/GFX, string dumps
8. **`07_runtime_logs/`** — game/error/system/setup logs
9. **`08_steam_vdf/`** — Steam manifests
10. **`09_web_captures/`** — GitHub / SteamDB HTML
11. **`10_binary_artifacts/`** — materialized Windows/Linux executables, the
    2.6.1.1 debug drop, extracted PDBs, retained RAR volumes, manifests, and
    `test_versioned.dds`
12. **`11_git_patch/`** — Arena branch patch
13. **`12_raw_chat_logs/`** — `INDEX.md` only (all raw exports were torn apart & deleted; their info lives in Parts 1–3 + `03_analysis/RAWLOG_NETNEW_EXTRACTS.md`)
14. **`13_save_and_cache/`** — `*.meta` + feat cache `q847rsja8ndx`
15. **`14_screenshots_and_media/`** — **drop zone for image binaries** (catalog is text-only until you upload)

## Cases at a glance
| Status | Examples |
|---|---|
| **SOLVED** | payload load, login gate, Challenges enable, live tracking, save Load + feat persistence, Bronze popup, time-gate, **in-game Continue (V7)** |
| **UNSOLVED (C25)** | Paradox **launcher** Continue still grey (launch `CK2game.exe` directly) |
| **UNSOLVED secondary** | MP 2nd-boot, grey map, portrait flicker, missing MJ arrow |
| **INFO / future** | Featured Rulers full roster, local reward gallery |

## Perfect-duplicate cleanup
Removed: entire `99_duplicates/`, `CHECK_CK2_MJ_SAVES_FIXED.bat`,
`monarchs_reactivated_2030.txt`, misnamed `test.dds` (= `monarchs` payload),
empty prep-upload log. Rescued unique `system2.log` → `07_runtime_logs/`.

## Your next uploads
Image files listed in `00_START_HERE/SCREENSHOTS_CATALOG.md` → drop into
`14_screenshots_and_media/` (subfolders A–H). Start with **A** (Continue).

See `PLAN.md` for phased work remaining.
