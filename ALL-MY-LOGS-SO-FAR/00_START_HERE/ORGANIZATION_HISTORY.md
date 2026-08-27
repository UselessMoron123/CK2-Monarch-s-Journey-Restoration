# Organization History — Phase 0

**Source:** `logs to dissect.../Новый текстовый документ (1).txt` (196 lines, 16,444 B) — the reorg session that created the current folder structure.

## What was done

- **Input:** flat dump of 186 files in repo root (mixed prompts, archives, handoffs, analysis, patch scripts, game data, runtime logs, VDFs, web captures, binary artifacts, raw chat logs, saves)
- **Action:** designed 4-layer folder structure (15 labeled subfolders) and sorted everything:
  - `00_START_HERE/` — original prompt, both PROMPT templates, STATUS, CASES_AND_FINDINGS, FEATURED_RULERS, FR_MJ_COMPLETE_ROSTER, SCREENSHOTS_CATALOG
  - `01_research_archives/` — Parts 1-3 structured archives
  - `02_handoffs/` — ultimate handoff, PDB handoff, V7 triage
  - `03_analysis/` — PDB/symbol notes, patch maps, 3.3.5.1 assessment, V6 roadcause, banned register, etc. (21 files at that time, now 27)
  - `04_test_guides_and_reports/` — in-game test guides + observations
  - `05_patches_and_scripts/` — guarded patchers split into `bat/` `ps1/` `py/` (v1-v6)
  - `06_game_data/` — monarchs payloads, CSVs, GUI/GFX, string dumps (`gui/`, `gfx/`)
  - `07_runtime_logs/` — game/error/system/setup logs from test boots
  - `08_steam_vdf/`, `09_web_captures/`, `10_binary_artifacts/`, `11_git_patch/` — Steam depots, GitHub/SteamDB HTML, test.dds, branch patch
  - `12_raw_chat_logs/` — original chat exports + INDEX.md mapping each to session/patch version
  - `13_save_and_cache/` — .meta saves + feat-cache token `q847rsja8ndx`
  - `14_screenshots_and_media/` — drop zone for image binaries (catalog text-only until upload), subfolders A-H suggested
- **Duplicate handling:** verified byte-for-byte via `cmp`, moved 28 exact duplicates into `99_duplicates/` (all `(1)` copies, `*_bat.txt`/`*_ps1.txt` mirrors, repeated error/system logs). Later `99_duplicates/` deleted per README — perfect duplicates removed, unique `system2.log` rescued to `07_runtime_logs/`.
- **Special handling:** `setup`, `system` files differ despite same size — kept as different boot logs (distinct CK2 boots). Russian-named files (`Новый текстовый документ`, `Снимок экрана`) preserved with descriptive labels via INDEX/CATALOG, not renamed.
- **Deliverables created in that session:** `README.md` (50 lines, read order + current state) + `PLAN.md` (127 lines, phased plan) + `12_raw_chat_logs/INDEX.md` (31 lines, mapping raw logs to sessions)
- **Git:** tracked renames via `git mv` to preserve history, committed as `e2d3a8f` on branch `arena/01a03373-...`, opened PR #1 "Organize research logs into labeled subfolders", merged into main (`ab8dae6` merge commit). Session branch retained, then fetch+merge main to ensure continuity.
- **Follow-up:** identified naming collision V6 failed `a6cb92b8…` vs V6 proven `f5b7dfd6…`, and V7 feat-update vs V7 Continue target. Proposed Part 3 archive from `third`/`fourth`/`(5)` + `Новый…` V6-verdict → V7-triage arc.

## Current state after squash

- This repo's main `cad3e23 Add files via upload` is squashed version of that reorg + later commits (`baf5cda` PDB handoff, `09f2d51` PDB analysis, etc.). **History lost but content preserved** — authoritative history is in file contents (SHA tables, patch maps, archives), not git log.
- `99_duplicates/` no longer exists — intentional.
- `logs to dissect.../` folder (6 files) is staging area for cleanup — now torn apart into `DISSECTION_REPORT.md`, `UPLOAD_GUIDE.md`, `V7_CONTINUE_CFG.md`, `DEBUG_INVESTIGATION_TOOLS.md`, and this file. Should be deleted before migration to restoration project repo to avoid duplication.

## Method lessons for future reorgs (from that session)

- Use `cmp` byte-for-byte, not size/name alone — boot logs can share size but differ.
- Keep Russian-named exports as-is, map via catalog/INDEX rather than renaming (preserves provenance).
- Use `git mv` for renames to keep history.
- Workspace budget 128 MB / 10K files — delete reproducible intermediates, minimize artifacts.
- GitHub sessions even shorter than chat sessions — handoff-file discipline required.
- After PR merge, local session closed to remote ops — further work stays local until new session.

## Turn 8 — dump ingest 2026-08-27 (`latest logs` / `latest latest logs` / `new new logs`)

Plan: `00_START_HERE/INGEST_PLAN_DUMP_2026-08-27.md`. Report:
`00_START_HERE/INGEST_REPORT_DUMP_2026-08-27.md`. Operative prompt is now **v6**.

Accepted: `APPLY_CK2_MJ_V7.bat` (+ CHECK/REVERT V7 bats), Pavao-resume runtime logs,
preflight two-run transcript, two x64dbg traces, git patches for PRs #10/#11.
Raw chats torn → `RAWLOG_NETNEW_EXTRACTS.md` §10 then deleted with the dump folders.
Living docs repaired so STATUS/PLAN/CASES/MASTER/preflight match V7 Continue-working
`57b18e43…`. New case **C25** = launcher Continue. 15-folder tree unchanged;
`07_runtime_logs/x64dbg/` is a subfolder only.

## For restoration project repo migration

- Do NOT copy raw organization transcripts — their info is now in `README.md`, `PLAN.md`, `INDEX.md`, `ORGANIZATION_HISTORY.md`, `DISSECTION_REPORT.md`.
- If old logs already dissected in this repo exist in restoration repo, check `12_raw_chat_logs/INDEX.md` for overlap (first/second/third/fourth/(5) + Новый files) — avoid re-archiving.
