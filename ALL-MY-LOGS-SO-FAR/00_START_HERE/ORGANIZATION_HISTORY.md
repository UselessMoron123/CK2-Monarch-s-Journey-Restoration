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

## Turn 9 — `last log/` ingest and dissection 2026-08-30

Instructions: the user asked for the organizing prompts to be **collected into one
continuous thing first, then dissected into the appropriate folders**. Both steps were
done, in that order.

**Step 1 — consolidation.** `PROMPT_organize_research_log_v7.md` merges the v4 §1–§10
skeleton and its 12 rules with v5 §4–§7 (artifact→folder map, SHA-256 dedup, living
docs, integrity) and v6 §8–§13 (dashboard, naming collisions, Continue surfaces,
tooling integrity) into a single operative rulebook. It declares itself operative;
v4–v6 are kept as history and are no longer authoritative on their own.

**Step 2 — dissection.** Report: `DISSECTION_REPORT_2026-08-30.md`. Ledger:
`12_raw_chat_logs/INDEX.md`. Source: 11 files, 1,716,243 bytes, 21,437 lines, covering
six distinct sessions (`arena/01a044b2`, `01a04980`, `01a049a4`, `01a04d46`,
`01a0534b`, plus one no-repo pasted chat) and PRs #13/#14/#15.

Created: `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md`,
`03_analysis/V9_RUNTIME_RESULTS.md`, `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`,
`04_test_guides_and_reports/CK2_MJ_V9_TEST_GUIDE.md`,
`05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` (the file the V9 session
claimed to have saved but never did — reconstructed verbatim from the log).

Repaired: `STATUS.md`, `CASES_AND_FINDINGS.md` (C26/C27, F11),
`MASTER_ARTIFACT_TABLE.md` (V8/V9 states + tooling hashes + cache semantics),
`WINDOWS_333_PATCH_MAP.md` (+ `.csv`), `CONTRADICTIONS.md` (§12–§14),
`RAWLOG_NETNEW_EXTRACTS.md` (§11), `PLAN.md`, `README.md`,
`V9_COLD_LOAD_FEATS_FIX.md` (addendum).

**Three corrections issued against existing documents** (rule 11):

1. `V9_COLD_LOAD_FEATS_FIX.md` said the `DAILY_GATE` breakpoint (raw `0x666546`)
   executed. The script arms `+666146` = raw **`0x665546`**, mid-instruction in a
   different function. `CONTRADICTIONS.md` §13.
2. `FEAT_RESET_QUIT_VS_RESIGN.md` declared identity drift refuted on one capture.
   Four distinct `user_id` values are now on record. `CONTRADICTIONS.md` §12.
3. The V8-era claim that the failed run "pushed 0s into the cache, wiping the
   main-menu display" is contradicted by the user's own paste in the same log.
   `CONTRADICTIONS.md` §14.

**Verification actually run** (not asserted): `py/build_v9_chain.py` re-executed clean,
reproducing every hash V2→V9 including `v9 61e4345b…`; objdump decoded both the stock
and V4 variants of the eligibility-helper tail at raw `0x000aeb83`; all 26 rows of
`windows333_patch_map.csv` were checked against the real stock exe and the real V9
image (stock bytes, VA mapping, patched bytes — 0 mismatches); the reconstructed inline
patcher was parsed from disk and simulated against real V7 and V8 chain images,
producing the declared V9 hash from both; `cmp` confirmed the three duplicate artifacts
before removal.

**Teardown:** the three byte-identical duplicates in `last log/`
(`01a044b2-….patch`, `MJ_V8_CLEAN_TRACE.txt`, `RUN_MJ_V8_CLEAN_TRACE.bat`) were
deleted under the dedup rule — canonical copies live in `11_git_patch/` and
`05_patches_and_scripts/x64dbg/`. The nine raw chat exports were **kept** on disk with
ledger entries (a deliberate departure from the 2026-08-26/27 practice of deleting raw
exports after dissection; recorded here so a future session does not treat them as
un-dissected). 15-folder tree unchanged.

**2026-08-31 addendum:** a verification pass (address/hash/PR sweep of the nine
exports vs. the archive) found one gap — **PR #16** (the V9 PR, merge `d2f61bb9…`)
was missing from §11.7 / Part 5 §A3; fixed. With that, the `last log/` folder was
deleted per user request; all nine files remain in git history (tracked at `fdefa19`).
