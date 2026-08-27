# Ingest plan — `latest logs` / `latest latest logs` / `new new logs`

**Status: EXECUTED 2026-08-27.** See `INGEST_REPORT_DUMP_2026-08-27.md`.
**Date:** 2026-08-27
**Method:** SHA-256 of every dump file vs `ALL-MY-LOGS-SO-FAR/`; read organization prompts v1–v5, `ORGANIZATION_HISTORY.md`, `DISSECTION_REPORT`, `RECON_NOTES`, living docs; read the two raw chat exports and the unique evidence files.

There is **no folder named `new`**. The three dump roots are:

| Folder | Role in time | Unique hashes |
|---|---|---|
| `latest logs/` | First live-debug drop (V6 play + broken watcher + launch-mode x64dbg deaths) | 18 unique (plus 6 byte-identical to archive patchers/logs) |
| `latest latest logs/` | Later drop: both chat exports, git patches, preflight tooling copies, overlapping evidence | 14 unique hashes, several also in the other two dumps |
| `new new logs/` | Strict subset of `latest latest logs/` (3 files, identical hashes) | 0 hashes that are not already in `latest latest logs/` |

Treat them as **one dump with three overlapping generations**, not three independent archives.

---

## 0. What the organization rules already say (binding)

Operative prompt is **`PROMPT_organize_research_log_v5.md`** (ingestion/maintenance). For the two raw chat exports, also apply **v4** (dissect-or-verify-first, then tear).

Hard rules this pass must obey:

1. **Do not re-invent the 15-folder tree.** New material lands in existing homes.
2. **Dedup by SHA-256**, never by name. Byte-identical → discard; note in ledger.
3. **Raw chat exports:** cross-reference sweep → net-new facts into living docs / Part 4 addendum / `RAWLOG_NETNEW_EXTRACTS.md` → `12_raw_chat_logs/INDEX.md` ledger entry → **delete the raw file**.
4. **Runnable tooling integrity:** every `.bat`/`.ps1` STATUS mentions must exist under `05_patches_and_scripts/{bat,ps1,py}`. No `.txt` mirrors of patchers left in dump folders.
5. **The repo is the handoff.** No new standalone handoff. Update STATUS / CASES / MASTER table / PLAN / README / INDEX.
6. **Key builds by SHA**, never label. V6 and V7 each name two different binaries.
7. **Banned vs abandoned** stays. Do not resurrect `a6cb92b8…` or feat-V7 `0074af70…`.
8. **Do not commit patched executables.** Guarded patchers + hashes only.

---

## 1. What is already in the organized tree (do not re-create)

These conclusions from the dump **already live** in `ALL-MY-LOGS-SO-FAR/`:

| Distilled fact | Where it already is |
|---|---|
| `latest logs/` A/B vs V6 second-look; retracted C17/C08 claims; three Continue surfaces; watcher v1 bugs; x64dbg `0x406D1388` | `03_analysis/LATEST_LOGS_ANALYSIS_2026-08-26.md` |
| V7 cloud-sync gate `0x1409E678B` / `0x009E5B8B` `75 2f → eb 2f`; live Kulin load | `03_analysis/V7_RUNTIME_RESULTS.md`, `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART4.md` |
| C08 marked SOLVED (banner + case table) | `STATUS.md` top banner, `CASES_AND_FINDINGS.md` C08 row |
| Guarded `patch_ck2_mj_v7.ps1` | `05_patches_and_scripts/ps1/` (byte-identical to dump `patch_ck2_mj_v7.txt`) |
| Preflight + watcher v2 + README_PREFLIGHT + debug-guide Part 0 | already under `05_patches_and_scripts/` (dump copies differ only by CRLF/encoding) |
| V5/V6 APPLY/patch scripts | dump `.txt` copies are **byte-identical** to archive `.bat`/`.ps1` |

So this is **not** a Phase-0 re-sort. It is a v5 ingest of leftover evidence + a **living-docs repair**, because the banner says V7 is solved while PLAN/README/STATUS body/MASTER table/patch map/preflight still speak as if V7 is the open target.

---

## 2. SHA map — keep / discard / distill

### 2.1 Byte-identical to archive → discard (do not copy)

| Dump file | Matches |
|---|---|
| `latest logs/patches…/APPLY_CK2_MJ_V5.txt` | `05_…/bat/APPLY_CK2_MJ_V5.bat` |
| `…/APPLY_CK2_MJ_V6.txt` | `APPLY_CK2_MJ_V6.bat` |
| `…/patch_ck2_mj_v5.txt` | `ps1/patch_ck2_mj_v5.ps1` |
| `…/patch_ck2_mj_v6.txt` | `ps1/patch_ck2_mj_v6.ps1` |
| `…/patch_ck2_mj_v7.txt` | `ps1/patch_ck2_mj_v7.ps1` |
| `latest logs/game logs/error.log` | `07_runtime_logs/error.log` |
| `…/graphics.log` | `07_runtime_logs/graphics4.log` |
| `…/historical_setup_errors.log` | `07_runtime_logs/historical_setup_errors2.log` |

### 2.2 Dump-internal duplicates (keep one source of truth, then delete the extras)

| Hash / content | Copies |
|---|---|
| `what we wanted to do.txt` | `latest logs/` **and** `latest latest logs/` |
| `ck2_live_observer.log` (1.88 MB) | `latest logs/watcher logs/` **and** `latest latest logs/` |
| `watch_ck2_mj LOG.txt` | same two folders (console tail of the observer) |
| `preflight check.txt` | `latest latest logs/` **and** `new new logs/` |
| `watcher log.txt` | same |
| `x64dbg log1.txt` (attach-era) | `latest latest logs/` **and** `new new logs/` |

`new new logs/` can be deleted wholesale after the three files are processed from `latest latest logs/`.

### 2.3 Unique files — proposed homes

#### A. Missing runnable tool (must accept)

| File | Action |
|---|---|
| `latest logs/patches…/APPLY_CK2_MJ_V7.txt` | **`git mv` → `05_patches_and_scripts/bat/APPLY_CK2_MJ_V7.bat`** |

STATUS already claims this bat exists. It does **not**. Tooling-integrity failure. Convert `.txt` → `.bat`, CRLF like the other APPLY bats. There is still **no** `CHECK_CK2_MJ_V7.bat` / `REVERT_CK2_MJ_V7.bat` in the dump; `patch_ck2_mj_v7.ps1` already has Verify/Revert — optional follow-up, not blocking.

#### B. Near-dup tooling (do not replace archive)

| Dump file | vs archive | Action |
|---|---|---|
| `latest latest logs/ck2check/RUN_PREFLIGHT.bat` | archive missing final CRLF only | discard dump copy |
| `…/ps1/preflight_ck2_mj.ps1` | encoding/CRLF only | discard; **then patch archive** to add V7 hash `57b18e43…` to `$KnownExe` and treat it as current-good (see §4) |
| `…/watch_ck2_mj_v2.ps1` | encoding only | discard |

#### C. Git patches → `11_git_patch/` (provenance) then optional delete of dump copies

| File | What it is |
|---|---|
| `01a03e8a-ac93-76b7-a133-6a98f2d15a3a.patch` | PR #10 — latest-logs analysis + preflight (already applied in tree) |
| `01a03f95-541f-7c0f-8ab5-c6879d3a5e06.patch` | PR #11 — V7 + Part 4 (already applied except APPLY_V7.bat) |

Keep as history next to existing `01a02609-….patch`. Do not re-apply.

#### D. Runtime logs → `07_runtime_logs/` with collision-free names

Suggested names (boot + purpose, per v5):

| Dump | Proposed archive name | Why keep |
|---|---|---|
| `game logs/game.log` (480 B) | `game_pavao_resume_1278_01_08.log` | **Evidence** of loaded-save vs fresh campaign (quoted in LATEST_LOGS_ANALYSIS) |
| `game logs/ai.log` | `ai_pavao_resume.log` | “Human takes control of Duke Pavao of Croatia” |
| `game logs/setup.log` | `setup_pavao_resume.log` | unique hash (same build, reordered) |
| `game logs/system.log` | `system_pavao_resume.log` | unique (extra alt-tab) |
| `game logs/system_interface.log` | `system_interface_pavao_resume.log` | unique hash |
| `game logs/text.log` | `text_pavao_resume.log` | unique hash, payload strings still load |
| `game logs/message.log` | `message_pavao_resume.log` | unique 80 B |

Optional: one copy of `ck2_live_observer.log` as `observer_v1_empty_2026-08-26.log` **or discard** — 15,526 inventory lines, zero `FILE CHANGED`; analysis already extracted the 4 process lines. Prefer **discard** (workspace budget; conclusions in LATEST_LOGS_ANALYSIS §4). Same for `watch_ck2_mj LOG.txt` (tail of the same file).

#### E. Debugger traces → new subfolder, not a 16th top-level folder

Create **`07_runtime_logs/x64dbg/`** (keeps the 15-folder contract):

| Dump file | Keep? | Note |
|---|---|---|
| `latest logs/x64dbg logs/x64dbg log1.txt` | one representative launch-death | 14× identical `0x406D1388` story |
| `…/log2.txt`, `log3.txt`, `log(maybe not needed).txt` | **discard after confirming same death** | already classified in analysis §5 |
| `latest latest logs/x64dbg log1.txt` | **keep** as `x64dbg_attach_bps_then_launch_death.txt` | attach success, 7 BPs at ASLR base `0x7FF75EF20000`, clean exit `0x0`, then later File→Open death |

Do **not** dump the 1.1 MB chat log’s stack traces into this folder. Distill registers (see §3).

#### F. User transcripts of UI text → `04_test_guides_and_reports/` or fold into CASES

| File | Action |
|---|---|
| `latest logs/text of error messages.txt` | fold verbatim Continue-failed + gauntlet tooltip into CASES C08/C17 (already described; this is the canonical English wording). Keep file as `04_test_guides_and_reports/CONTINUE_FAILED_AND_GAUNTLET_TOOLTIP.txt` **or** quote in CASES and delete. Prefer quote + delete (small, already in analysis). |

#### G. Preflight output → evidence, not a tool

`preflight check.txt` is **two concatenated runs**:

1. No `.ck2` saves, no feat cache. Both `CK2game.exe` and `CK2gameV6.exe` = V6 `f5b7dfd6…`. Payload correct.
2. After a session: `Bronzeman_llywelyn_gwynedd.ck2` (1195.1.1) and `Gwynedd1195_01_08.ck2` (1195.1.8), `special_event=llywelyn_gwynedd`, `bronzeman=yes`. **Still no feat cache.**

Action: copy to `07_runtime_logs/preflight_two_runs_llywelyn.txt` (or fold into a short `03_analysis/PREFLIGHT_2026-08-26.md`). **Saves themselves are not in the dump** — record metadata in MASTER table as “user-side, not uploaded”; do not invent files under `13_save_and_cache/saves/`.

#### H. Watcher v2 failed start

`watcher log.txt` = PowerShell `CommandNotFoundException` because cwd was `C:\Users\UZWERG` and the sample used `D:\CK2`. Method lesson only → one paragraph in debug guide / README_PREFLIGHT (“cd to the folder that contains the script; GameRoot is SteamCrusader”). Then delete.

#### I. Raw chat logs — dissect, then delete

| File | Lines | Session |
|---|---:|---|
| `latest latest logs/latest latest log1.txt` | 572 | Analyse `latest logs/`; wrong C17/C08 claims; retraction; preflight; PR #10 `cd7dd1b` |
| `latest latest logs/latest latest log2.txt` | 17,752 | Attach-mode x64dbg; Continue BPs; register dumps; live V7 proof; unguarded one-liner; PR #11 `d609c1b`; Part 4 |

`what we wanted to do.txt` is an earlier fragment of the same arc (request for watcher + x64dbg). After log1/log2 are ledgered, it is redundant.

---

## 3. Net-new facts still only in the raw chats (must survive deletion)

Part 4 + V7_RUNTIME_RESULTS already hold the root cause and the patch. Sweep remaining **only-in-raw** items into a short addendum (`03_analysis/RAWLOG_NETNEW_EXTRACTS.md` new section, or Part 4 §G), then `git rm` the raw files.

### 3.1 Confirmed live Continue path (recompute)

ASLR base examples:

- Attach session A: module `0x00007FF75EF20000`
  - `+9E5500` → `00007FF75F905500`
  - `+9E4970` → `00007FF75F904970`
  - `+E64E90` → `00007FF75FD84E90`
  - `+8145EC` → `00007FF75F7345EC`
  - `+DE47C0` → `00007FF75FD047C0`
  - `+DE8BB0` → `00007FF75FD08BB0`
  - `+99F540` → `00007FF75F8BF540`
- Later session: base `0x00007FF73C980000`
  - INT3 `00007FF73D1945EC` = `+8145EC`
  - INT3 `00007FF73D364970` = `+9E4970`
  - INT3 `00007FF73D365500` = `+9E5500`
  - INT3 `00007FF73D36678B` = `+9E678B` (**the V7 patch site, hit live**)

VA↔offset check: `0x1409E678B − 0x140000C00 = 0x009E5B8B`. Matches patcher.

### 3.2 Register snapshots worth keeping (not the megabyte ntdll stacks)

At `RIP=+8145EC` / `+9E4970`:

- `RAX` → string `"checksum"`
- `RDX` → `"irst_on_top"` (truncated `"first_on_top"`)
- `R10`/`R11` → `"checksum"`
- `R15` → path to `CK2game.exe`
- Unrelated freeze dump at `ntdll` with `R10="view_in_store"` — **noise**, UI string, not Continue

At success: engine log identical to V7_RUNTIME_RESULTS §3 (Kulin `218800`, date `1173.1.2`).

### 3.3 Operational discoveries

- **Attach, never File→Open.** `0x406D1388` (`MS_VC_EXCEPTION` / `SetThreadName`) kills launch-mode even after adding the exception range. Shift+F9 vs F9.
- **Fullscreen freeze:** `settings.txt` `fullScreen=no` / `borderless=yes` so D3D9 exclusive mode does not lock the desktop on BP.
- **TLS callback BPs** on `inputhost.dll` / `windowmanagementapi.dll` / vorbis/ogg — x64dbg auto; ignore.
- Offline `pops_api` still talks to `prod-telemetry.paradox-interactive.com`; `RPC_S_SERVER_UNAVAILABLE` (`000006BA`) during load — benign.
- Watcher v2 sample path `D:\CK2` is wrong for this machine.

### 3.4 New user-side artifacts (metadata only)

| Save | date | special_event | size (preflight) | In repo? |
|---|---|---|---:|---|
| `Bronzeman_llywelyn_gwynedd.ck2` | 1195.1.1 | `llywelyn_gwynedd` | 3,682,972 | **no** |
| `Gwynedd1195_01_08.ck2` | 1195.1.8 | `llywelyn_gwynedd` | 3,836,788 | **no** |

Feat cache **still missing** after that campaign → identity-drift hypothesis **untested**; also suggests this Llywelyn run may not have written peak progress (open, not a conclusion).

### 3.5 Do **not** promote

- The **unguarded one-liner** that pokes `CK2game.exe` byte `0x009e5b8b` without SHA guard. Record as “user workaround when the bat flashed and closed”; **guarded `patch_ck2_mj_v7.ps1` remains the only deliverable**.
- Russian UI text from x64dbg as canonical docs (debug guide is English).
- Claim that launcher Continue is “by design / SQLite” as proven — Part 4 states it; treat as **hypothesis** until `pdx_launcher.lib` / `launcher-v2.sqlite` is actually inspected. User confirmed it is still grey.

### 3.6 Error ledger (must stay visible — this repo’s convention)

1. First analysis blamed C17 “Challenges: Disabled” for feats=0. **Wrong.** User + existing CASES. Retracted in LATEST_LOGS_ANALYSIS.
2. First analysis claimed Continue symptom *changed*. **Wrong.** C08 always had grey launcher + in-game dialog.
3. Wrong-binary hypothesis **killed** by preflight (both exes = V6 `f5b7dfd6…`).
4. APPLY_V7.bat was documented as shipped and never placed in `bat/`.

---

## 4. Living-docs repair (more important than moving files)

The dump’s sessions **already wrote** Part 4 / V7 results / C08=SOLVED, but left the dashboard inconsistent. Ingest is incomplete until these match:

| Doc | Problem | Fix |
|---|---|---|
| `STATUS.md` | Banner = C08 SOLVED; body still “only remaining gap: Continue grey”; next actions still “start V7”; “Authoritative files” ignore V7_RUNTIME_RESULTS / Part 4 | Rewrite body to V7-proven; split in-game vs launcher; next action = launcher Continue **or** Phase 3 polish |
| `PLAN.md` | Phase 2 still “⬅ current”; V7 patcher unchecked | Tick Phase 2; current = Phase 3 and/or launcher Continue as C25 |
| `ALL-MY-LOGS-SO-FAR/README.md` | Cases glance: UNSOLVED V7 | SOLVED in-game Continue; launcher still open |
| `CASES_AND_FINDINGS.md` | C08 SOLVED but **F5** still “Continue enable remains → V7”; work-order still “do V7” | Split: **C08** in-game dialog SOLVED; **C25** (new) launcher Continue grey UNSOLVED. Fix F5. |
| `MASTER_ARTIFACT_TABLE.md` | No V7 `57b18e43…`; V6 still “current baseline”; no v7 patcher hashes; no Llywelyn saves | Add V7 row; V6 = previous baseline / V7 revert target; hash `patch_ck2_mj_v7.ps1` + APPLY_V7.bat |
| `WINDOWS_333_PATCH_MAP.md` (+ csv) | Stops at V6; still “Continue → V7 target callers …” | Add one-byte V7 row `0x009e5b8b` |
| `BANNED_ARTIFACTS.md` | “current V7 *target*” wording | Distinguish abandoned feat-V7 `0074af70…` vs proven Continue-V7 `57b18e43…` |
| `CONTINUE_SEMANTIC_REFERENCE.md` | Still enable-predicate era | Add `0x1409E6700` dispatch + `[rsi+0x63]` cloud byte; note enable vs execute are different stages |
| `preflight_ck2_mj.ps1` | `$GoodExe` = V6 only; no `57b18e43…` | Add V7 as current-good; V6 still acceptable |
| `12_raw_chat_logs/INDEX.md` | No log1/log2 | Ledger the two exports after tear-down |
| `ORGANIZATION_HISTORY.md` | Stops at Turn 7 | Short Turn 8 note pointing at this plan / later ingest report |
| Root `README.md` | Fine | Maybe one line: dumps are staging, archive is `ALL-MY-LOGS-SO-FAR/` |

**Naming-collision table (update everywhere A0 appears):**

| Label | SHA-256 | Meaning | Status |
|---|---|---|---|
| “V6” trampoline | `a6cb92b8…` | injected code, corrupts | ❌ BANNED |
| V6 | `f5b7dfd6…` | 5 save-list branches | ✅ proven; V7 revert target |
| “V7” feat-update | `0074af70…` | two `74 0d→90 90` | 🟡 ABANDONED |
| **V7 Continue** | `57b18e43…` | `0x009E5B8B` `75 2f→eb 2f` | ✅ **current in-game Continue** |

---

## 5. Structure: keep the 15 folders; small internal tweaks only

**Do not add a 16th top-level folder** for this dump. The v5 map still fits:

| Class | Home |
|---|---|
| Raw chats | dissect → delete; INDEX ledger |
| Analysis conclusions | fold into existing `03_analysis/` docs (not a parallel “V7_NOTES2.md”) |
| Part-level story | Part 4 already exists; **addendum** if v4 A–F gaps bother us (Part 4 is thinner than Parts 1–3 — optional, not blocking) |
| Patchers | `05_…/{bat,ps1,py}` — APPLY_V7.bat is the hole |
| Game boots | `07_runtime_logs/` |
| Debugger | `07_runtime_logs/x64dbg/` (new **sub**folder) |
| Saves | only if user uploads `.ck2`; otherwise MASTER metadata |
| Git patches | `11_git_patch/` |
| Screenshots | none in this dump |

Optional later (not this ingest): fold overlapping per-version `03_analysis/CK2_MJ_windows_v*.md` into the patch map — already listed as user’s-call in RECON_NOTES Turn 7.

**Dump folders after ingest:** delete `latest logs/`, `latest latest logs/`, `new new logs/` once unique bits are placed. They are staging, same role as the old `logs to dissect…/` and `all logs in one place…/`.

---

## 6. Instructions / prompt: write **v6**, keep v5 as history

v5 declared “sort complete, ingest discrete artifacts.” That is still the right *mode*. It is now **wrong on project state** and missing lessons from this dump.

**`PROMPT_organize_research_log_v6.md` should change:**

1. **State dashboard:** V6 core loop + **V7 in-game Continue** proven. Remaining functional: launcher Continue (separate code), C09–C12 polish, FR/rewards as follow-ons.
2. **Continue surfaces are first-class.** Never conflate Paradox launcher / in-game menu / MJ panel / SP menu.
3. **Naming collision** now includes proven Continue-V7 `57b18e43…` vs abandoned feat-V7 `0074af70…`.
4. **Tooling-integrity includes “files STATUS names must exist.”** APPLY_V7.bat was the miss.
5. **Preflight `$KnownExe` is a living register** — update it when a new proven hash appears, or the next preflight will flag a good V7 exe as unknown.
6. **x64dbg / observer logs:** distill BPs, registers, engine `Application debug[…]` lines; discard inventory dumps, TLS callbacks, ntdll stacks, repeated SetThreadName deaths.
7. **Unguarded poke-scripts are not deliverables.** If a session pastes a one-liner, keep the *offset/byte* in the patch map and throw the one-liner away.
8. **Living-docs drift is the default failure mode** after a “solved” session that only edits the banner. v6 Step 3 should say: if STATUS banner and PLAN/README/F5 disagree, **repair is part of ingest**, not optional.
9. **Git patches of already-merged work** go to `11_git_patch/` as provenance; never re-apply; never keep the dump folder “because the patch is there.”
10. **Saves mentioned only in preflight** → MASTER metadata + “not uploaded”; do not create empty save slots.

Folder map in v5 stays. A–F skeleton in v4 stays for any future raw export (there will be more).

---

## 7. Suggested execution order (next session — not this one)

1. **Integrity first:** land `APPLY_CK2_MJ_V7.bat`; hash it into MASTER §6.
2. **Living docs:** STATUS body, PLAN Phase 2→3, README glance, CASES F5 + new C25, patch map V7 row, BANNED wording, CONTINUE_SEMANTIC addendum, preflight KnownExe.
3. **Place unique runtime evidence** (`game_pavao_resume_*.log`, preflight two-runs, one attach x64dbg log).
4. **Git patches** into `11_git_patch/`.
5. **Raw-log sweep:** net-new §3 into EXTRACTS/Part 4 addendum; INDEX ledger; `git rm` log1, log2, `what we wanted to do.txt`.
6. **Dedup delete** dump folders (and `new new logs/` entirely).
7. **Prompt v6** + one paragraph in `ORGANIZATION_HISTORY.md`.
8. Report: accepted / duplicate / distilled / living-docs touched / mismatches (none expected on V7 offset math).

**Do not** in that session: start launcher reverse-engineering, re-open C01–C07, re-sort `03_analysis/` per-version docs, upload Llywelyn saves unless the user drops them.

---

## 8. What this dump does *not* contain (still missing from the project)

- Llywelyn `.ck2` binaries
- A feat-cache capture from the Llywelyn session (preflight said none)
- V7-patched exe (correct — we do not want it in git)
- Screenshot of in-game Continue succeeding (catalog A still empty)
- Anything that would un-grey the **launcher** Continue (`launcher-v2.sqlite`, `pdx_launcher.lib` dump)
- DNA/scripts for the five missing rulers

---

## 9. One-sentence ingest verdict

The dump is a **staging overlay of the V6-live-debug → V7-Continue-proof week**: most conclusions are already filed, the precious leftovers are APPLY_V7.bat, a handful of unique boot/debugger logs, two raw chats to tear, two git patches for provenance, and a **dashboard that still thinks Continue is the open problem.**
