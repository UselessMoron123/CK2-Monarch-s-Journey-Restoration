# Upload Guide — what to (not) upload

**Source:** Recovered from `logs to dissect.../Новый текстовый документ (4).txt` (repo health-check session) and `.../ (5).txt`. Preserved here so future sessions don't ask for redundant uploads.

## Already well covered — do NOT re-upload

- Verified byte-identical source executables as Base64 chunks:
  - Windows 3.3.2 (24,727,272 B, `83ba6a68…`)
  - Windows May 2020 3.3.3 — **correct restoration target** (24,753,368 B, `656f4f48…`)
  - Windows 3.3.5.1 (24,236,024 B, `a0cc8e92…`)
  - Linux May 2020 3.3.3, symbol-rich reference (27,729,272 B, `99776be0…`)
- Local monarchs JSON payload (11 rulers / 33 challenges, 101,949 B, `fc6ec025…`, expiry 2030)
- Guarded V2–V6 Windows patch scripts and apply/check/revert BATs (in `05_patches_and_scripts/`)
- Patch-offset documentation and cumulative CSV map (`03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv`, `windows333_patch_map.csv`)
- Evidence saves: `Bosnia1173_03_03.ck2`, `Bronzeman_kulin_bosnia.ck2`, Pavao saves, plus `.meta`
- Persisted feat-progress cache `q847rsja8ndx` (`feat_progress_storage`)
- Runtime logs and screenshots proving core loop (panel loads, rulers, Bronzeman start, live eval, Bronze grant, save write, manual load, globals deserialize, peak progress persists) — `07_runtime_logs/` + `SCREENSHOTS_CATALOG.md`
- PDB analysis for 2.6.1.1 (`03_analysis/IDENTITY.md`, `SYMBOL_SUMMARY.md`, etc.) — exact match GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1

Current source of truth: `STATUS.md`; detailed evidence: `03_analysis/V6_RUNTIME_RESULTS.md`; deep background: `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`.

## Do NOT upload again (ops rule)

- Another copy of any CK2 EXE or its Base64 chunks
- Broad generic CK2 logs (only targeted logs after a specific V7 candidate)
- Steam DLLs, runtime files, account files, tokens (`pdx_login.txt`)
- GUI/GFX files already represented in `06_game_data/`
- Duplicate patch scripts, saves, screenshots, payload files
- Patched executable binaries themselves — guarded scripts are the deliverable
- The 2.6.1.1 debug drop again — it is already materialized under
  `10_binary_artifacts/debug_files/`, with hashes and identity analysis preserved

## Few uploads that could still be genuinely useful (optional, ranked)

1. **Complete official/older Monarch's Journey payload** if you happen to have one — especially old `monarchs.txt`, `monarchs` file, cached GameSparks response, old CK2 install backup, Linux `common/monarchs_journey/monarchs.txt`, or browser/download cache from when MJ was active. **Most valuable missing artifact** because it could recover 5 absent official rulers:
   - Liao Hongji, Basarab I, Mindaugas, Grand Mayor Botstain, Stefan the First-Crowned
   - May also contain original challenge definitions and reward metadata.

2. **Historical reward/score-gallery material** (if you later want separate restoration project):
   - Screenshots showing score totals, tiers, cosmetic unlocks, reward descriptions
   - Exported/archived CK3 reward pages, old MJ web/cache data, CSV/text describing scores/costs
   - Repo has some reward icon screenshots and `LT.csv`, but no full authoritative reward catalogue.

3. **Precise V7 Continue-test capture — only AFTER V7 patch exists:**
   - Patch-window text
   - Screenshot showing Continue enabled before clicking
   - Screenshot after it successfully loads
   - Newly generated `game.log` only if it fails

4. **Debug symbols / PDB files for exact May 2020 Windows 3.3.3 build** (if somehow available) — unusually valuable for RE, but not expected and not necessary. Linux binary already provides strong symbolic guidance.

## Bottom line from that session

> You have not missed anything required for immediate next task. I can proceed from existing repository with V7 Continue-enable investigation. Two meaningful longer-term gaps: historical/full payload with 5 missing rulers; authoritative reward-gallery/score data. Everything else needed is already here.

## Debug symbols note (2.6.1.1)

The 2.6.1.1 PDBs are from last build when they were present. Limits:
- Cannot directly symbolize 2020 3.3.3 exe (GUID/age must match)
- Predate MJ, so no `CNullGameSpark`, GameSparks, `CHighlightedRuler*`, feat/reward symbols
- Still useful for stable systems: save discovery/selection, frontend/menu states, Ironman rules, cloud/local save abstractions, GUI widgets, game-state loading, serialization.

Most useful subset if full folder too large: PDB for principal game EXE + exact matching EXE + any `.map` + tiny `provenance.txt`.

## For restoration project repo migration

When you download everything from here and upload into restoration project repo:
- That repo probably already contains old logs already dissected here — check `12_raw_chat_logs/INDEX.md` naming collision table (V6 `a6cb92b8…` banned vs `f5b7dfd6…` proven vs feat-V7 `0074af70…` abandoned). Key by SHA, never label.
- Files like "v7 something" (feat-V7 bats/ps1) — feat-V7 intentionally excluded (hash `0074af70…` in `BANNED_ARTIFACTS.md`, offsets `0x00666546` + `0x007856e8` documented as abandoned, not shipped). The two V7 analysis notes (`V7_CONTINUE_CFG.md`, `V7_CONTINUE_INITIAL_TRIAGE.md`) were merged into `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` on 2026-08-26; that file is the single V7 knowledge base.
- Do NOT copy `logs to dissect.../` raw files — they are staging area, now torn apart into this guide + `DISSECTION_REPORT.md` + `V7_CONTINUE_CFG.md` + `PROMPT_v3.md`. Delete staging folder before migration to avoid duplication.
