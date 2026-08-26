# Recon notes — 2026-08-26 ("look around, note everything")

Scope: exploratory pass over the whole repo. No files were moved/deleted. Goal was to
(a) map where everything is, (b) find connections between the organized "log repo"
(`ALL-MY-LOGS-SO-FAR/`) and files already in this project, (c) list things mentioned in
the log repo that are NOT physically present, and (d) point out every remaining log/raw
file that still needs the same "organize" treatment as the log repo.

---

## 0. One-sentence state

This repo now holds **three overlapping generations of the same project material**:
(1) the original session-by-session uploads (`1st/2d/3d/4th session/`), (2) a flat dump
(`all logs in one place (need subfolders atleast)/`, 186 files), and (3) the **organized
archive** (`ALL-MY-LOGS-SO-FAR/`). On top of that, the user just added **6 brand-new raw
chat transcripts** in `adding just to make sure/` plus newer runtime evidence in
`v6 second look/` and `things parent AI asked to upload/`.

698 tracked files, 156 duplicated content-hashes (lots of byte-identical copies).

---

## 1. Top-level map

| Path | What it is | Files |
|---|---|---|
| `ALL-MY-LOGS-SO-FAR/` | **The organized log repo** (15 subfolders + README + PLAN) | ~180 |
| `adding just to make sure/` | **6 new raw chat logs** (Russian default names) | 6 |
| `all logs in one place (need subfolders atleast)/` | Flat 186-file dump (pre-organization state) | 186 |
| `1st session/` `2d session/` `3d session/` `4th session/` | Original per-session uploads | 143/33/23/1 |
| `analysis/` (+ `debug2611/`) | This project's own analysis (subset of organized `03_analysis/`) | 11 |
| `things parent AI asked to upload/` | V6 toolchain + evidence `.ck2` saves + screenshots 224–229 | 21 |
| `v6 second look/` | V6 "second look" evidence: saves, logs, cache, screenshots, mp4 | ~30 |
| `log playing with new v6 patch/` | 13 Continue/MJ screenshots | 13 |
| `More things/` | all-rulers + reward icons + map images | ~28 |
| `debug files/` | 2.6.1.1 exe + RARs + dbghelp.dll (binary) | 8 |
| `CK2game_win332/333/3351_upload_chunks/`, `ck2_linux_upload_chunks/` | base64 upload chunks + manifests (intermediates) | 5/5/5/6 |
| root loose files | exes, `STATUS.md`, `README.md`, `DEBUGFILES_PDB_HANDOFF.md`, 5 `new text doc` logs | ~9 |

Root executables now present (this contradicts the organized `STATUS.md` note "not in
this logs-only repository"):
- `CK2game333.exe` = 24,753,368 B = **May-2020 3.3.3** (the restoration target, SHA `656f4f48…`)
- `CK2game3351.exe` = 24,236,024 B = 3.3.5.1 (SHA `a0cc8e92…`)
- 3.3.2 (`83ba6a68…`) only exists as base64 chunks in `CK2game_win332_upload_chunks/` (no loose exe)
- `debug files/CK2game.exe` = 16,535,040 B = 2.6.1.1 (SHA `ec4ea039…`)

---

## 2. Connections — organized archive ↔ project files

- **`analysis/` is a strict subset of `ALL-MY-LOGS-SO-FAR/03_analysis/`.** The project's
  `analysis/` + `analysis/debug2611/` contains zero unique content. The organized archive
  additionally holds these 6 files the project `analysis/` does NOT have:
  `BANNED_ARTIFACTS.md`, `CONTINUE_SEMANTIC_REFERENCE.md`, `CONTRADICTIONS.md`,
  `DEBUG_INVESTIGATION_TOOLS.md`, `MASTER_ARTIFACT_TABLE.md`, `V7_CONTINUE_CFG.md`.
- **`V7_CONTINUE_CFG.md` now EXISTS** in `03_analysis/` — the "one minor gap" flagged in
  `DISSECTION_REPORT_2026-08-26.md` has been closed.
- **STATUS.md versions differ:** root `STATUS.md` == `all logs in one place/STATUS.md`
  (85 lines, "last updated 2026-08-22") but is **older** than the organized
  `00_START_HERE/STATUS.md` (97 lines, "2026-08-25"). The root copy is stale.
- **Root loose `new text doc(second/third/fourth/5).txt`** are byte-identical to the
  organized `12_raw_chat_logs/` copies. But **`new text doc(first).txt` at root is a
  DIFFERENT export** — 6,499 lines / 225,551 B vs organized 6,463 / 223,226 B. Worth a
  diff to see if the root copy has extra tail content.
- **`all logs in one place (need subfolders atleast)/` is ~99% redundant** with the
  organized archive (it IS the pre-org dump). Only 2 files differ in content from organized:
  - `descriptions and challenges.txt` (467 lines) vs organized `06_game_data/...` (144 lines).
    The 467-line dump additionally holds the **MJ overview/mechanics, the full CK3 reward
    ladder with point costs (Miller = 90, etc.), and full bios incl. the 5 "missing" rulers**
    (Liao Hongji, Basarab I, Mindaugas, Botstain, Stefan). These bios are already absorbed
    into `00_START_HERE/FR_MJ_COMPLETE_ROSTER.md` (418 lines), so likely no loss — but verify.
  - `STATUS.md` (the older 85-line copy, see above).
- **Session folders are mostly duplicates** of the organized archive and of each other
  (e.g. the same base64 part files appear byte-identical in `1st/`, `2d/`, `3d/` sessions —
  all 25,165,824 B each, all one hash `178b6c87…`).

---

## 3. `adding just to make sure/` — 6 NEW raw transcripts (all net-new, no content match anywhere)

None of these 6 files matches any existing file byte-for-byte. They are 6 fresh session
exports (overlapping in time with the already-archived `12_raw_chat_logs/` but distinct files):

| File | Lines | Bytes | What it is |
|---|---:|---:|---|
| `Новый текстовый документ (1).txt` | 1,815 | 226,628 | **V7 feat-update patch session** — branch merged, hash `0074af70…`; renames Continue fix to **V8**; ends with "V7 = feat-update, Continue fix = V8, guide me through V7 runtime test". |
| `Новый текстовый документ (2).txt` | 82 | 3,321 | Short V7 test plan ("two yes/no results", `IsActiveForPlaythrough`, narrow V8). |
| `Новый текстовый документ (3).txt` | 370 | 18,913 | Reads `More things/` images (map, all rulers Screenshot 1–3), plans next actions, requests a PR. |
| `Новый текстовый документ (4).txt` | 1,540 | 58,465 | Reads `previous chat log.txt`, recaps V2→V4, upload checklist, handoff §19. |
| `Новый текстовый документ (5).txt` | 3,189 | 254,891 | Windows base64 upload session (part001–004 + manifest + `monarchs.txt` + `patch_ck2_mj_v5` + `build_v6.py`). |
| `Новый текстовый документ (6).txt` | 6,327 | 220,332 | **The original "father" session** — starts at "monarchs.txt … what can you see in file" → discovers the **expiration switch**. Near-twin of `new text doc(first).txt` (6,463 lines) but a different export. |

→ These 6 are the **primary "remaining logs that need the organize process"**: add them to
`12_raw_chat_logs/INDEX.md`, check overlap vs Part 1/2/3 archives, then archive/tear apart.

---

## 4. Missing items (mentioned in the log repo, not physically present)

1. **Game data (DNA/scripts) for the 5 absent rulers** — Liao Hongji, Basarab I, Mindaugas,
   Grand Mayor Botstain, Stefan the First-Crowned. Only their *bios* exist (in
   `FR_MJ_COMPLETE_ROSTER.md` + the 467-line dump); the payload `monarchs` (101,949 B,
   `fc6ec025…`) holds 11 of 16 rulers. Flagged as the **"most valuable missing artifact"**
   in `UPLOAD_GUIDE.md`.
2. **Full/late official MJ payload** (to recover those 5 rulers + original challenge/reward defs).
3. **Authoritative reward/score-gallery data** — only `LT.csv`, reward icon PNGs, and text
   ladder present; no full reward catalogue.
4. **PDB for the exact May-2020 3.3.3 build** — the 2.6.1.1 PDBs (`ck2game.pdb`
   `90ade46c…`, `ck2.pdb` `ffe81233…`) are referenced by hash only; the RARs are present
   in `debug files/` but the extracted PDBs are not in the repo (and the May-2020 PDB was
   never available).
5. **Many cataloged screenshot binaries** — `SCREENSHOTS_CATALOG.md` describes ~50 images,
   but only a subset exist as binaries in the repo (see §5). The drop zone
   `14_screenshots_and_media/` is still empty (README only).
6. **`xami5llmaht31.jpg`, `YPmxNMB.png`, `upload_2019-10-27…png`, `8b2cpjl9t9w31.png`,
   `v276klwr66031.png`** (catalog D/F entries) — not present anywhere in the repo.

---

## 5. Remaining unorganized / loose material (candidates for the same organize pass)

**Text/logs that are genuinely new and NOT in the organized archive:**

- `adding just to make sure/` — the 6 transcripts (§3) — top priority.
- `v6 second look/logs/` — **8 net-new runtime logs** not in `07_runtime_logs/`:
  `ai.log` (55 KB), `error.log` (25 KB), `game.log` (1.7 KB — contains the **Bronze popup**
  evidence), `historical_setup_errors.log` (452 B), `setup.log` (921 KB), `system.log` (5 KB),
  `system_interface.log` (20.5 KB), `text.log` (342 KB). (`graphics.log` already matches
  organized; the 7 zero-byte logs — converter/message/profiling/random/script_optimizations/
  stats/system_debug — are empty and trivial.)
- root `new text doc(first).txt` — the 6,499-line variant (diff vs the archived 6,463-line copy).
- `all logs in one place (need subfolders atleast)/descriptions and challenges.txt` (467-line rich copy).
- root `STATUS.md` — stale 85-line copy (organized has the newer 97-line one).

**Evidence binaries (intentionally kept out of the text archive, but still loose in this repo):**

- `things parent AI asked to upload/` — the **actual `.ck2` saves** (`Bosnia1173_03_03.ck2`,
  `Bronzeman_kulin_bosnia.ck2`) + screenshots `(224)–(229)` + V6 toolchain bats/ps1 + `monarchs`.
- `v6 second look/save games/` — `Bronzeman_pavao_croatia.ck2`, `Croatia1278_01_02.ck2`,
  `Croatia1278_01_10.ck2`; `v6 second look/cache/q847rsja8ndx` (feat cache).
- `log playing with new v6 patch/` — 13 Continue/MJ screenshots (catalog **A** section, incl. (1)(2)(4) key evidence).
- `More things/all rulers/` (1–12 ruler + Screenshot 1–3), `More things/reward icons/` (6 CK3 reward PNGs), `More things/map…png` — catalog **E/F**.
- `v6 second look/` screenshots + `flickering…mp4`.
- `debug files/` — `CK2game.exe` (2.6.1.1) + `ck2.part1-3.rar` + `ck2game.part1-3.rar` + `dbghelp.dll` (hashes already in `MASTER_ARTIFACT_TABLE.md` §7; binaries deliberately not committed to the organized archive).
- root `CK2game333.exe` / `CK2game3351.exe`.
- `*_upload_chunks/` base64 parts + manifests (reproducible intermediates — candidates for deletion).

**Likely safe to delete (reproducible / pure duplicates):**

- The 4 base64 chunk folders (`CK2game_win332/333/3351_upload_chunks/`, `ck2_linux_upload_chunks/`) — intermediates, and the 3.3.3 chunks are redundant with `CK2game333.exe` now at root.
- `all logs in one place (need subfolders atleast)/` — 186-file flat dump, ~99% byte-identical to organized (only 2 files carry extra content; rescue those first).
- The session folders' duplicate uploads (many byte-identical copies of the same base64 parts, logs, bats).

---

## 6. Suggested next step (not performed this turn)

1. Rescue the 2 content-unique files from `all logs in one place/` (the 467-line
   `descriptions and challenges.txt`, and confirm the stale `STATUS.md` is superseded).
2. Add the 6 `adding just to make sure/` transcripts to `12_raw_chat_logs/INDEX.md` and
   decide archive-vs-tear-apart per the existing Part 1/2/3 coverage (key by SHA, per
   `UPLOAD_GUIDE.md` / `INDEX.md` naming-collision warning).
3. Fold the 8 new `v6 second look/logs/` files into `07_runtime_logs/`.
4. Diff root `new text doc(first).txt` (6,499 lines) vs the archived 6,463-line copy.
5. Decide disposition of binary evidence (screenshots → `14_screenshots_and_media/`
   subfolders A–H per catalog; saves/cache → `13_save_and_cache/`; exes/RARs → keep hashes only).

---

## 7. Turn 2 — extraction audit + cleanup applied (2026-08-26)

### Raw chat logs — extraction verified (nothing net-new)
- Root `new text doc(second/third/fourth/5).txt` = byte-identical to
  `ALL-MY-LOGS-SO-FAR/12_raw_chat_logs/` copies.
- Root `new text doc(first).txt` = organized copy + a 36-line UI/sidebar header
  (unrelated older-chat previews; no MJ content).
- `adding just to make sure/Новый текстовый документ (1)–(6).txt` = 6 fresh exports
  of sessions already archived:
  - (6) father session → Part 1
  - (5), (4) son session → Part 2
  - (1), (2), (3) feat-V7 / V6-runtime / cross-version / second-look → Part 3 +
    `BANNED_ARTIFACTS.md` + `WINDOWS_3351_PORT_ASSESSMENT.md` + `V6_RUNTIME_RESULTS.md`
  - Verified key content present in organized: feat-V7 hash `0074af70…` + offsets
    `0x00666546`/`0x007856e8`, tracker VAs `0x1407b8370/0x1407b8450/0x1407b8e60/0x1407b9340`,
    runtime-trace plan, cross-version verdict, second-look Bronze.

### Cleanup applied
- `git rm -r "all logs in one place (need subfolders atleast)/"` — all 186 files
  (184 byte-identical to organized; `STATUS.md` 85-line superseded by the organized
  97-line; `descriptions and challenges.txt` 467-line fully distilled into
  `FR_MJ_COMPLETE_ROSTER.md` — all 22 rulers, full B/S/G tables incl. the 5 missing
  rulers, reward ladder, mechanics). Staged as deletions, not committed.

### Still candidates (left in place, user's call)
- Root `new text doc` (5 files) — duplicates of `12_raw_chat_logs/`.
- `adding just to make sure/` (6 files) — verified extracted; safe to remove.
- `1st/2d/3d/4th session/` — mostly duplicates.
- `*_upload_chunks/` base64 parts + manifests — reproducible intermediates.

---

## 8. Turn 3 — images removed + "Новый текстовый документ" renamed (2026-08-26)

### Images deleted (56 files: .png/.jpg/.mp4)
Removed every screenshot/picture binary across `1st session/`, `3d session/`,
`More things/`, `log playing with new v6 patch/`, `things parent AI asked to upload/`,
`v6 second look/`. All were already described + Case-linked in
`SCREENSHOTS_CATALOG.md` / `CASES_AND_FINDINGS.md`, which are now the canonical
textual record (see their updated headers + new section J "where still mentioned").

Kept (NOT screenshots — binary patch artifacts):
- `test.dds` (1st session) = byte-identical to `monarchs` payload (md5 `3a320ee0…`)
- `test_versioned.dds` (1st session + organized `10_binary_artifacts/`) = loader-redirect name

Added to catalog: the 6 `Ck3_reward_*.png` icons (→ case C21/F2, the 8 ladder
tiers collapsed into 6 textures).

### "Новый текстовый документ" files renamed (14, via git mv)
There were TWO unrelated sets sharing this name — the collision was the confusion
source. The old "logs to dissect" set was already torn apart/deleted; the surviving
set (below) is renamed to descriptive ASCII names:

- `12_raw_chat_logs/` (canonical) + `2d session/uploads/` (byte-identical dups):
  `chat_fragment_may333_v1v2_continue_greyed.txt`,
  `chat_fragment_disasm_v4v5_continue_offsets.txt`,
  `command_sha256sum_v5_tooling.txt`, `report_fragment_v5_ready.txt`
- `adding just to make sure/` (6 new unique session exports):
  `session_father_monarchs_expiry.txt`, `session_may333_exe_upload.txt`,
  `session_v2_v5_recap_upload_checklist.txt`, `session_v6_runtime_crossversion_secondlook.txt`,
  `session_featV7_patch_continue_to_V8.txt`, `session_featV7_test_plan.txt`

`12_raw_chat_logs/INDEX.md` updated with new names + a table for the 6 "adding
just to make sure" transcripts (and their archive coverage). Historical docs
(DISSECTION_REPORT, ORGANIZATION_HISTORY, UPLOAD_GUIDE, PART2, etc.) still
reference the OLD "logs to dissect" `Новый текстовый документ (1)–(6).txt` names
— those describe already-deleted files and are left as-is for history.

### Staged (not committed)
242 deletions (186 flat-dump + 56 images), 14 renames, 3 doc edits.

---

## 9. Turn 4 — session folders + "things parent AI asked to upload" dissected & sorted (2026-08-26)

Scope requested: dissect `1st/2d/3d/4th session/` and `things parent AI asked to
upload/`, sort their files, and review what else can be organized. Executed now
(via byte-for-byte `md5` comparison against `ALL-MY-LOGS-SO-FAR/`).

### Verdict: session folders were ~100% redundant
Every file in `1st session/` (143), `2d session/` (33), `3d session/` (23),
`4th session/` (1) and the remaining `things parent AI asked to upload/` was a
**byte-for-byte duplicate** of an already-organized file — except the 96-byte
base64 "chunk" placeholders, which are junk (`"there were symbols. not gonna
repeat them…"`). The only unique-by-hash content was rescued before deleting:

### Rescued into the organized archive
- **`13_save_and_cache/saves/`** (new subfolder) — 5 real `.ck2` saves:
  `Bosnia1173_03_03.ck2`, `Bronzeman_kulin_bosnia.ck2` (from `things parent…`),
  `Bronzeman_pavao_croatia.ck2`, `Croatia1278_01_02.ck2`, `Croatia1278_01_10.ck2`
  (from `v6 second look/save games/`). Pairs with the two `.txt.meta` already there.
- **`13_save_and_cache/q847rsja8ndx_v6_secondlook.txt`** — the *second* distinct
  cache state (`user_id=84696387`, `established=4`, `conquerer_from_bribir=1`)
  vs the existing `q847rsja8ndx.txt`. Added `13_save_and_cache/README.md` table.
- **`07_runtime_logs/`** — 10 net-new logs, all collision-free:
  the 8 v6 "second look" boots (`ai_v6sl.log`, `error_v6sl.log`,
  `game_v6sl.log` [contains the **Bronze popup** evidence], `setup_v6sl.log`,
  `system_v6sl.log`, `system_interface_v6sl.log`, `text_v6sl.log`,
  `historical_setup_errors_v6sl.log`) + 2 small fragments
  (`ai1.log`, `game2.log`).

### Moved into the archive
- `12_raw_chat_logs/` — the 6 `session_*` transcripts moved out of the loose
  `adding just to make sure/` folder (their proper home; INDEX.md section updated).
  `adding just to make sure/` deleted.

### Deleted (all content preserved in organized archive)
- `1st session/`, `2d session/`, `3d session/`, `4th session/`, `things parent
  AI asked to upload/`, `v6 second look/`, `More things/`, `analysis/`
  (all byte-dups of `03_analysis/`), root `new text doc(first/2/3/4/5).txt`,
  stale root `STATUS.md` (superseded by the 97-line organized copy), and root
  `DEBUGFILES_PDB_HANDOFF.md` (dup of `02_handoffs/`).

### Root README rewritten
`README.md` now points into `ALL-MY-LOGS-SO-FAR/` and lists the still-loose
binaries (exes, base64 chunk folders, `debug files/`).

### Still loose (deliberately kept; candidates for a future pass)
- `CK2game_win332/333/3351_upload_chunks/` + `ck2_linux_upload_chunks/` — base64
  upload parts + manifests (~160 MB). **Reproducible intermediates**; the 3.3.3
  chunks are redundant with `CK2game333.exe` at root. Safe-to-delete if space is
  an issue; hashes already recorded in `MASTER_ARTIFACT_TABLE.md`.
- `CK2game333.exe`, `CK2game3351.exe` — the real executables (keep; hashes recorded).
- `debug files/` — 2.6.1.1 `CK2game.exe` + `ck2*.rar` + `dbghelp.dll` (143 MB).
  Binaries deliberately not committed to the text archive; hashes in the artifact table.

## 10. Turn 5 — raw logs torn apart & deleted; net-new facts preserved (2026-08-26)

Following the Turn 4 fragment dissection, the whole `12_raw_chat_logs/` folder was
torn: all 17 raw exports deleted after a full net-new sweep. Everything only-in-
raw was consolidated into `03_analysis/RAWLOG_NETNEW_EXTRACTS.md` (9 sections:
feat reader/writer case VAs, 3.3.5.1 function lists, Linux .rodata string
addresses, GetContinueSave breadcrumbs, feat-DB load machinery, .pdata count
reconciliation, feat-V7 offset→VA map, string→VA map, Continue-xref disasm set).
INDEX.md rewritten as a tear-down ledger. See DISSECTION_REPORT Turn 5 for detail.
