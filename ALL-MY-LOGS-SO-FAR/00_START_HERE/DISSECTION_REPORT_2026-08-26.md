# Dissection Report — "logs to dissect condense distill and organize"

**Source folder:** `logs to dissect condense distill and organize/` (6 files, total ~744 KB)
**Date of audit:** 2026-08-26 (session branch `arena/01a03c92-all-my-logs-so-far`)
**Main branch state:** `cad3e23 Add files via upload` — single commit containing full organized tree (15 subfolders + README + PLAN). This audit checks whether actions described in the 6 raw logs made it into that main commit.

---

## File-by-file dissection

### (1) Новый текстовый документ (1).txt — 16,444 B, 196 lines
**What it is:** Transcript of an AI session that did **Phase 0 organisation**.

**Actions described:**
- Explored repo structure, read original prompt, PROMPT v1/v2, STATUS, research archives, handoffs
- Sorted flat dump of 186 files into 15 labeled subfolders (`00_START_HERE/` … `14_screenshots_and_media/`)
- Verified duplicates byte-for-byte (`cmp`), moved 28 exact duplicates into `99_duplicates/` (later removed, per README)
- Created `README.md` (50 lines, read order + current state) and `PLAN.md` (127 lines, phased plan)
- Created `12_raw_chat_logs/INDEX.md` mapping raw logs to sessions/patch versions
- Committed as `e2d3a8f` on branch `arena/01a03373-...`, opened PR #1, merged into main
- Final git status clean, local HEAD = merge commit `ab8dae6`

**Preserved in main?** ✅ **YES — fully**
- Current repo has exactly those 15 subfolders, `README.md`, `PLAN.md`, `12_raw_chat_logs/INDEX.md`
- No `99_duplicates/` remains (intentionally deleted per README — perfect duplicates removed, unique `system2.log` rescued)
- The commit hash `e2d3a8f` is not in this repo's history (this repo was re-uploaded as one squashed commit `cad3e23`), but **all file contents are present** in `cad3e23`. Info preserved via folder structure, not via git history.

**Lessons for v3:** Need to document folder convention, duplicate handling (byte comparison, `(1)` suffix, Russian filenames, boot log variants with same size but different content), and that GitHub sessions are even shorter than chat sessions → handoff discipline required.

---

### (2) Новый текстовый документ (2).txt — 118,680 B, 933 lines
**What it is:** Transcript of Part 2 archiving session (`new text doc(second).txt`).

**Actions described:**
- Read `PROMPT_organize_research_log.md` (v1), `CK2_MJ_RESEARCH_ARCHIVE.md` (Part 1), and raw log `new text doc(second).txt` (3,224 lines, 257 KB)
- Reconstructed chronology: this session = first Windows analysis (Patch A + Patch B), father session = v1→v5 patches catching 2 errors (Documents-path claim, 10-byte-over-9-byte string patch)
- Verified calculations: linker timestamp `0x5EB2ACA8` = 2020-05-06 12:25:12 UTC, base64 sizes, PE geometry, branch displacements, token IDs, expiry math
- Produced `CK2_MJ_RESEARCH_ARCHIVE_PART2.md` (431 lines) with A-F skeleton, merge notes, banned list, error ledger
- Produced `PROMPT_organize_research_log_v2.md` with 12 improvement points (A0 read-first, error ledger, banned register, deployment logs = ground truth, recompute extended, multi-session chronology, runtime reports verbatim, contradictions protocol, loose-ends register, session-created docs inventory, materials-received-but-not-analyzed flag, handoff verbatim)

**Preserved in main?** ✅ **YES — fully**
- `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART2.md` exists (verified)
- `00_START_HERE/PROMPT_organize_research_log_v2.md` exists
- Part 2's key findings (feat_progress read case no-op at `0x1407824a5`, writer at `0x1409df82f`, banned hash `a6cb92b8…`) are in `03_analysis/BANNED_ARTIFACTS.md` and `CK2_MJ_V6_FAILED_ROADCAUSE.md`
- The 18-entry patch map from apply log (first complete v5 offsets) is in `03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv`

---

### (3) Новый текстовый документ (3).txt — 117,203 B, 1,075 lines
**What it is:** Transcript of Part 1 archiving session (`new text doc(first).txt` 6,463 lines).

**Actions described:**
- Organized first/father session (payload expiry → depot archaeology → Linux `CNullGameSpark` breakthrough → Windows v1–v5, ends on persistence cliffhanger)
- Produced `CK2_MJ_RESEARCH_ARCHIVE.md` (Part 1, 334 lines, supersedes earlier short summary) with theory evolution table, patch lineage, verified calculations (expiry formula `now < int32(event_time_end+172800)`, INT_MAX overflow to 1901, safe value 1893499200 = 2030-01-01)
- Produced `PROMPT_organize_research_log.md` (v1, 29 lines) with A-F skeleton

**Preserved in main?** ✅ **YES — fully**
- `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE.md` exists
- `00_START_HERE/PROMPT_organize_research_log.md` exists
- Artifact table (May Win exe 24,753,368 B SHA `656f4f48…`, V1–V5 hashes, Linux 27,729,272 B SHA `99776be0…`, payload 101,949 B SHA `fc6ec025…`) matches `03_analysis/MASTER_ARTIFACT_TABLE.md` and `EXECUTABLE_IDENTITIES.md`

---

### (4) Новый текстовый документ (4).txt — 9,586 B, 180 lines
**What it is:** Transcript of repo health-check + PDB handoff session.

**Actions described:**
- User: "look at my repository, read documentation, look through present folders, and say if you have full picture"
- AI reviewed repo, listed well-covered material (verified executables as Base64 chunks, payload, V2–V6 patchers, saves, cache, logs, screenshots)
- Concluded: core restoration proven, only Continue greyed remains, 3.3.5.1 port not feasible, no upload needed for V7
- Listed things NOT to upload (exes, logs, DLLs, GUI/GFX, duplicate scripts, patched binaries) and few optional useful uploads (full late payload with 5 missing rulers, reward gallery material, V7 test capture after patch, PDB for May 2020 build)
- User: "i've got them. look in debugfiles folder. but they are from 2.6.1.1 version"
- AI checked working tree, found no debugfiles folder, asked to upload PDB + matching EXE + .map + provenance.txt
- Created `DEBUGFILES_PDB_HANDOFF.md` (270 lines, standalone handoff for separate session)
- Later: created `analysis/V7_CONTINUE_INITIAL_TRIAGE.md` (116 lines) documenting shared helper `0x1409e4970` called from `0x1407bffa1` (MJ), `0x1408145ec` (normal), `0x140a0ba62`
- Committed as `baf5cda`, opened PR #3, merged into main (merge commit `9315a388...`)

**Preserved in main?** ✅ **YES — fully**
- `02_handoffs/DEBUGFILES_PDB_HANDOFF.md` exists
- `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` exists
- `00_START_HERE/STATUS.md` references `analysis/debug2611/` (PDB analysis) which is present as `03_analysis/IDENTITY.md`, `SYMBOL_SUMMARY.md`, `SEARCH_RESULTS.md`, `TYPE_AND_VTABLE_NOTES.md`, `SYMBOLS_FILTERED.csv`
- The "no debugfiles folder" note is obsolete — debug files investigation completed and committed under `03_analysis/` (see file 6)

---

### (5) Новый текстовый документ (5).txt — 10,968 B, 273 lines
**What it is:** Transcript of V7 Continue triage continuation.

**Actions described:**
- Read handoffs, analyse logs, previous sessions, says what can be done now
- Documents current position: V6 proven working (panel, rulers, Bronzeman, live tracking, Bronze popup, save writing, persistent cache), only Continue greyed remains
- Proposes immediate actions: finish Continue CFG analysis, compare Windows flow vs Linux `CIronmanSaveSelect::GetContinueSave`, then create real V7 patch (hash-guarded, length-preserving, limited to Continue predicate)
- Creates `analysis/V7_CONTINUE_CFG.md` (112 lines) — first-pass CFG for `0x1409e4970–0x1409e5342` and `0x1409e5500–0x1409e66f6`, notes call at `0x1409e671f`, rejection paths `0x1409e4f35/42/fba`, helper `0x1409e4900`
- Later finds and verifies applyable V7 candidate for live feat-update (not Continue): hash `0074af70…`, two gates at raw offsets `0x00666546` and `0x007856e8` (`74 0d → 90 90`)
- Files ready in `things parent AI asked to upload/` (APPLY/CHECK/REVERT bats, ps1, test guide), committed as `cb1df83`, `3218e77`

**Preserved in main?** 🟡 **Partially — intentionally**
- `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` exists and contains the shared helper analysis
- `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` exists (semantic model + ordered V7 steps)
- `03_analysis/BANNED_ARTIFACTS.md` lists feat-V7 hash `0074af70…` as **abandoned** (built but premise disproven, never shipped to organized repo)
- `analysis/V7_CONTINUE_CFG.md` and `things parent AI asked to upload/` do **NOT** exist in organized repo — this is **documented as intentional**: feat-V7 was hypothesis-only, disproven by second-look Pavao Bronze test (Part 3 D1). Its hash is preserved in banned register, not as deliverable.
- The live feat-update gates `0x00666546` / `0x007856e8` are not in current patch map (since abandoned) — correctly excluded.

**Action needed:** Ensure `V7_CONTINUE_CFG.md` content is merged into `V7_CONTINUE_INITIAL_TRIAGE.md` or `CONTINUE_SEMANTIC_REFERENCE.md` if any unique info. Quick check: triage file already contains caller table and next steps; semantic reference contains ordered steps. CFG file's key correction (two separate helpers `0x1409e4970–0x1409e5342` vs `0x1409e5500–0x1409e66f6`, not one calling the other) is worth preserving — add to `CONTINUE_SEMANTIC_REFERENCE.md` if missing.

---

### (6) Новый текстовый документ (6).txt — 497,212 B, 3,491 lines
**What it is:** Large standalone handoff + full investigation transcript for **CK2 2.6.1.1 debug files**.

**Actions described:**
- Mission: investigate supplied debug-symbol files (debug files folder) as self-contained archival task, extract names, types, source paths, subsystem relationships
- Required input: full debugfiles folder (CK2game.exe 16,535,040 B, ck2.part1-3.rar, ck2game.part1-3.rar, dbghelp.dll), plus exact matching EXE for GUID/age validation
- Explores repo, finds debug files folder, records file inventory (size, SHA-256, format), parses PE debug directory (CodeView RSDS GUID/age/PDB path)
- Extracts RAR5 archives (via unrar-cffi abi3 wheel), verifies CRC, gets ck2.pdb 64,770,048 B SHA `ffe81233…` and ck2game.pdb 67,005,440 B SHA `90ade46c…`, both MSF 7.00
- Identity verdict: `ck2game.pdb` ↔ `CK2game.exe` = **EXACT MATCH** (GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1, PE timestamp 2016-08-30 = 2.6.1.1 Reaper's Due era), `ck2.pdb` = mismatch (GUID `504A2C03…`, 2016-06-01, no matching EXE)
- Builds custom tooling: `msf.py`, `pe.py`, `msvc_demangle.py` (99.7% coverage), `symdump.py`, `tpi.py`, `classdump.py`, `search.py`, `make_csv.py`, `xref.py`, `vtables.py`, `andis.py`
- Produces 5 deliverables under `analysis/debug2611/`: `IDENTITY.md`, `SYMBOL_SUMMARY.md`, `SEARCH_RESULTS.md`, `TYPE_AND_VTABLE_NOTES.md`, `SYMBOLS_FILTERED.csv` (5,357 rows, RVA only for verified pair)
- Key findings: `CIronmanSaveSelect` size `0x290`, fields `_bIsContinueSaveValid @ +0x23D`, `_ContinueName @ 0x1D4`, `_LastLocalSavedFile @ 0x1F0`, functions `GetContinueSave @ 0x00AC7160`, `UpdateContinueData @ 0x00AC7770`, `RefreshContinueButton @ 0x00AC9BF0`, `OnContinue @ 0x00AC8E00`, `ContinueOnStartup @ 0x00AC8D00`, `IsValidSave @ 0x00AC70A0`, `CButton::Enable @ vtbl+0xDC`, `Disable @ +0xE0`, no account/online check in 2.6.1.1 Continue path, bronze/bronzeman/feat/reward/challenge/Titus/GameSparks absent in 2016 builds, Continue machinery added between June and Aug 2016

**Preserved in main?** ✅ **YES — fully (under different path)**
- `03_analysis/IDENTITY.md` = full identity and provenance (file inventory, PE, PDB, verdicts)
- `03_analysis/SYMBOL_SUMMARY.md` = counts, taxonomy
- `03_analysis/SEARCH_RESULTS.md` = search groups
- `03_analysis/TYPE_AND_VTABLE_NOTES.md` = class notes + decision flows
- `03_analysis/SYMBOLS_FILTERED.csv` = 873,027 B, 118,922 lines? Wait v3_01.csv 118,922 + SYMBOLS_FILTERED 873,027 — filtered index present
- `02_handoffs/DEBUGFILES_PDB_HANDOFF.md` = original handoff
- Original RARs not in repo (size + binary policy) — correct per safety rules: distribute only guarded patchers + manifests, not large binaries. Hashes preserved in IDENTITY.md.
- Custom tooling (`msf.py` etc) not in repo — scratch only, per deliverable spec ("do not commit extracted binaries or huge raw symbol dumps unless explicitly asked"). Correct.

---

## Whole-repo preservation audit

### What is in main (`cad3e23`)?
- `00_START_HERE/`: 7 files including original prompt, both PROMPT v1/v2, STATUS, CASES_AND_FINDINGS, FEATURED_RULERS, FR_MJ_COMPLETE_ROSTER, SCREENSHOTS_CATALOG — **all present**
- `01_research_archives/`: 3 parts covering all raw chat logs (first/second/third/fourth/(5) + Новый files) — **fully covers** per `12_raw_chat_logs/INDEX.md`
- `02_handoffs/`: 4 files — ultimate handoff (868 lines), next-session handoff, DEBUGFILES_PDB_HANDOFF, V7_CONTINUE_INITIAL_TRIAGE — **all present**
- `03_analysis/`: 26 files — banned register, master artifact table, patch maps, executable identities, continue semantic reference, contradictions, 3.3.5.1 port assessment, PDB analysis (IDENTITY etc), failed roadcause, runtime results, etc — **all present**
- `04_test_guides_and_reports/`: 6 files — save report, V5/V6 test guides, patch-window texts — **present**
- `05_patches_and_scripts/`: 3 subfolders bat/ps1/py — V2–V6 guarded patchers + check/revert — **present**, V7 feat-update **intentionally excluded** (banned/abandoned)
- `06_game_data/`: monarchs payloads, CSVs, GUI/GFX, string dumps — **present**
- `07_runtime_logs/`: 40+ logs — **present**
- `08_steam_vdf/`, `09_web_captures/`, `10_binary_artifacts/`, `11_git_patch/` — **present**
- `12_raw_chat_logs/`: 11 files + INDEX — **present**, fully archived per INDEX status
- `13_save_and_cache/`: .meta + cache token `q847rsja8ndx` — **present**
- `14_screenshots_and_media/`: drop zone README — **present** (image binaries optional per PLAN)
- `logs to dissect.../`: 6 raw session transcripts — **present as staging area** (this folder is the input to this audit)

### What is NOT in main but should be?
- **Nothing critical missing.** Two categories intentionally excluded:
  1. **Banned builds** (`a6cb92b8…` trampoline V6, `0074af70…` feat-V7) — hashes + failure analysis preserved in `BANNED_ARTIFACTS.md` and Part 2/3 archives, patcher files deliberately deleted from workspace to prevent reuse. Correct per safety rules.
  2. **Large binaries** (CK2game.exe, RARs, PDBs) — not committed, only hashes + manifests + guarded patchers. Correct per "never redistribute executables" rule.
  3. **Intermediate scratch tooling** (`msf.py`, `andis.py`, etc) — scratch only, not required in organized repo. Correct.

- **One minor gap:** `V7_CONTINUE_CFG.md` (112 lines) from file (5) is not in `03_analysis/`. Its key correction (two separate helpers `0x1409e4970–0x1409e5342` vs `0x1409e5500–0x1409e66f6`, call at `0x1409e671f`) should be merged into `CONTINUE_SEMANTIC_REFERENCE.md` or `V7_CONTINUE_INITIAL_TRIAGE.md`. Recommend adding a small addendum.

### Git history vs content
- Previous sessions created commits `e2d3a8f` (reorg), `baf5cda` (PDB handoff + triage), `3218e77` (CFG), `cb1df83` (feat-V7), `09f2d51` etc. This repo's main is squashed into single commit `cad3e23 Add files via upload` — **history lost but content preserved**. For a logs-only archive repo, this is acceptable; the authoritative history is in the file contents (SHA tables, patch maps, archives), not in git log. If you want history preservation, consider pushing the original arena branches or adding a `BRANCH_HISTORY.md`.

### Personal storage list (from original prompt)
User asked what files to keep in "my storage" (outside repo):
- **Exes:** Windows 3.3.2 (24,727,272 B `83ba6a68…`), May 2020 3.3.3 (24,753,368 B `656f4f48…`), 3.3.5.1 (24,236,024 B `a0cc8e92…`), Linux 3.3.3 (27,729,272 B `99776be0…`), 2.6.1.1 CK2game.exe (16,535,040 B `ec4ea039…`)
- **Base64+manifests:** for each exe (already in repo as `.txt` parts? Check — not in this repo, but hashes in `EXECUTABLE_IDENTITIES.md`)
- **Debug files:** 2.6.1.1 PDBs + RARs + dbghelp.dll (hashes in `IDENTITY.md`)
- **Screenshots:** catalog in `SCREENSHOTS_CATALOG.md`, drop zone `14_screenshots_and_media/` (binaries optional)
- **Saves:** `Bosnia1173_03_03.ck2`, `Bronzeman_kulin_bosnia.ck2`, Pavao saves, cache `q847rsja8ndx`
- **Patch scripts:** V2–V6 guarded ps1/bat/py (in `05_patches_and_scripts/`)

All are referenced in `MASTER_ARTIFACT_TABLE.md`.

---

## Recommendations for cleanup

1. **Keep** `PROMPT_organize_research_log.md` and `PROMPT_organize_research_log_v2.md` as history, add `v3` (this task).
2. **Keep** `logs to dissect.../` until v3 is verified, then move its 6 files into `12_raw_chat_logs/` with descriptive names (e.g., `session_reorg_2026-08-24.txt`, `session_part2_archive.txt`, etc.) and update `INDEX.md`, OR delete if they are exact duplicates of already-archived sessions (check: files 1,4,5 are PR/triage sessions not in INDEX — they deserve entries).
3. **Add** `V7_CONTINUE_CFG.md` addendum to `CONTINUE_SEMANTIC_REFERENCE.md` (the two-helper correction).
4. **Add** `BRANCH_HISTORY.md` if you care about preserving original commit hashes (e2d3a8f, baf5cda, etc.) since main is squashed.
5. **No action needed** on banned/abandoned patches — already correctly excluded with documentation.

---

## Conclusion

- The 6 logs describe a **complete Phase 0 → Phase 2** arc: reorg → Part 1/2/3 archives → PDB handoff + V7 triage → V7 CFG + feat-V7 candidate → full debug-files investigation.
- **All important information from those logs is preserved in main** — either as organized files, or intentionally as documented exclusions (banned/abandoned) with hashes and roadcause reports.
- **No info loss** detected except minor git history squash (content intact) and one small CFG note not merged (easily fixable).
- Ready to merge PROMPT v3 and proceed to V7 Continue enable fix (Phase 2).

---

## 9. Turn 4 — re-dissect the raw chat fragments + tooling integrity (2026-08-26)

Scope: dissect the raw session logs still flagged 🟡 in `12_raw_chat_logs/INDEX.md`
(`chat_fragment_may333_v1v2_continue_greyed.txt`, `chat_fragment_disasm_v4v5_continue_offsets.txt`,
plus the two command/report fragments), confirm whether anything is genuinely net-new, and
re-verify all runnable bats/ps1/py are intact. Also reviewed the original prompt and the
PROMPT organisation lineage (v1→v2→v3) to decide whether a newer prompt version is warranted.

### Coverage result
The two 🟡 fragments are **already ~fully distilled** into `01_research_archives/` (Parts 1–3)
and `03_analysis/`:
- V4/V5 patch offsets (`0x009e3d4c`, `0x009e1c2d`, the 24-byte `0x000aeb83` eligibility rewrite,
  all `0x007…` gates, the V5 15-group/46-byte diff) → already in `WINDOWS_333_PATCH_MAP.md`.
- Linux `nm -C` symbol list, dirty-session theory, Featured-Ruler account check → Parts 1/3 +
  `CONTINUE_SEMANTIC_REFERENCE.md`.
- The two command/report fragments (`command_sha256sum_v5_tooling.txt`,
  `report_fragment_v5_ready.txt`) → already captured (V5 hashes + offsets in Part 2).

### Net-new facts rescued (only exist in the raw fragments)
A cross-reference sweep (grep every VA/string/symbol against archives + analysis) found three
facts present **nowhere but the raw files**; recorded in `CONTINUE_SEMANTIC_REFERENCE.md` §E:
1. Raw Continue/Load **frontend xref disassembly set** at VA `0x1407bf650`, `0x1407bfa20`,
   `0x1407bfb20`, `0x1407bd550`, `0x1407be200` (each ~0x1c0 B window).
2. **`load_button` string VA** `0x141078318`.
3. The broader **Linux save/load `nm` symbol list** (beyond the curated Part 3 C2 tracker table).

These are raw evidence pointers, not new conclusions; the two fragment files remain in
`12_raw_chat_logs/` as the byte-level source. `INDEX.md` flags for both updated 🟡 → ✅.

### Tooling integrity check (bats/ps1/py)
Verified all runnable artifacts are intact under `05_patches_and_scripts/`:
- **19 `.bat`** (APPLY v2–v6, CHECK v1/v3/v4/v5/v6 + SAVES, REVERT v3/v4/v5/v6, PREPARE v5-EXE,
  `dump_ck2_strings`, `prepare_linux_ck2_upload`, `prepare_windows_may333_upload`) — all non-empty.
- **9 `.ps1`** (`check_ck2_mj`, `check_ck2_mj_saves`, `patch_ck2_mj`, `patch_ck2_mj_minimal`,
  `patch_ck2_mj_v2`–`v6`) — all non-empty.
- **3 `.py`** (`build_v6`, `patch_ck2_mj`, `patch_ck2_mj_minimal`) — all non-empty.
- No `.bat`/`.ps1`/`.py` anywhere else in the repo; no leftover `*_bat.txt` / `*_ps1.txt` / `*_py.txt`
  mirror copies. The only patcher still missing is the **V7 Continue** one (not yet built — correct).

### Prompt lineage → produced v4
Reviewed original prompt (`11first111myoriginal prompt.txt`: preserve evolution/attempts/dead ends/
results/future directions/interesting findings, produce a reusable instruction for the next AI,
list personal-storage files) and the PROMPT organisation v1→v3 evolution. Produced
**`PROMPT_organize_research_log_v4.md`** (operative; v1–v3 kept as history per the established
convention). v4 adds lessons from this pass: (1) **dissect-or-verify-first** — cross-reference a
fragment's VAs/strings/symbols before declaring it "already sorted"; (2) **tool-output fragments are
first-class evidence**, not noise; (3) **living INDEX** updates per fragment; (4) **runnable tooling
integrity check** as an explicit completion rule. README updated to point at v4 as operative.

### Conclusion
All raw session logs are now dissected; net-new facts preserved with cross-references; all
bats/ps1/py intact; prompt upgraded to v4. No further dissection needed on the current archive.

---

## 10. Turn 5 — raw logs torn apart & deleted; net-new facts preserved (2026-08-26)

Scope requested: re-check for anything "present only in raw logs", then tear the
raw logs, sort those bits, and clean the repo. Done.

### Comprehensive net-new sweep
Every raw export was scanned for `0x…` addresses, long hex tokens, and mangled
symbols, and each was tested against the whole archive/analysis/handoff corpus.
Results:
- **0 net-new** in: `command_sha256sum_v5_tooling`, `report_fragment_v5_ready`,
  `new text doc(first/third/fourth/5)`, `session_father_monarchs_expiry`,
  `session_v2_v5_recap_upload_checklist`, `session_featV7_test_plan`,
  `session_v6_runtime_crossversion_secondlook` — fully covered by Parts 1–3.
- The two disassembly-heavy fragments' ~3,000 hex "tokens" were **per-instruction
  byte addresses** (reproducible from the EXE) — discarded as tool-output noise,
  not facts.
- **Genuinely net-new content** (only-in-raw) was consolidated into the new
  **`03_analysis/RAWLOG_NETNEW_EXTRACTS.md`**:
  1. feat_progress reader/writer **case-entry VAs** (`0x140782404`, `0x1409df80a`,
     `0x1407824eb/4ff`, `0x14078252a`, `0x1409df974`, `0x1409e825f`) — Part 2 had
     only the helper funcs.
  2. Windows 3.3.5.1 **full function-address lists** (`extend_featured_ruler`
     4 funcs both builds; `test.dds` xref func `0x14077bdc0`).
  3. Linux **`.rodata` string addresses** (`0x1869814 red_king/ruler_feats`,
     `0x186984f common/monarchs_journey`, `0x18b4f27 gs_virtual/feat_script`).
  4. Linux `GetContinueSave` breadcrumbs (`0x121ac3a`, size, string consts,
     "save games/*.ck2" + `alternate_start` behavior).
  5. Linux feat-DB **load machinery addresses** (`0xff800c`, `0xff8912`, `0xff82d4`,
     `0xff8748`, `0xff8b2a`, `0x17ed028`, `0x17f5990`, …).
  6. `.pdata` function-count reconciliation (**48,666 vs 46,753 ≈ 1,913 fewer**).
  7. feat-V7 offset→VA mapping (`0x00666546→0x140667146`, `0x007856e8→0x1407862e8`).
  8. Full May-3.3.3 **string→VA map** (`load_button`…`CORRUPT`).
  9. Continue-frontend xref disassembly set (`0x1407bf650`…`0x1407be200`).

### Raw logs torn & deleted
All 17 raw exports in `12_raw_chat_logs/` were `git rm`'d. `INDEX.md` rewritten
as a **tear-down ledger** mapping every deleted file → the archive section (or
`RAWLOG_NETNEW_EXTRACTS.md` section) that holds its content. `CONTINUE_SEMANTIC_REFERENCE.md`
§E updated to point at the extraction doc. Raw wording remains recoverable from
git history if ever needed.

### Net result
The repo is now fully self-contained in structured docs: Parts 1–3 archives +
`03_analysis/` + `02_handoffs/` + `RAWLOG_NETNEW_EXTRACTS.md`. No raw log
retention needed; nothing lost (byte-level extras preserved; tool dumps
reproducible from the EXEs).
