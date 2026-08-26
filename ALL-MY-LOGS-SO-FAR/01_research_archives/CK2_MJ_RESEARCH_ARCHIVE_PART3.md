# RESEARCH ARCHIVE — CK2 Monarch's Journey — Part 3 (the successful V6, the abandoned feat-V7, and the road to Continue)

**Part 3 of the research · sources: `new text doc(third).txt` (1,600 lines), `new text doc(fourth).txt` (412 lines), `new text doc(5).txt` (125 lines) · continues Parts 1 & 2.**

> **How this document is built:** same skeleton as Parts 1 & 2 — A Orientation · B Story · C Knowledge base · D Attempts & dead ends · E Open threads · F Context + merge notes. Every claim comes from the three logs or the repository artifacts they produced; arithmetic re-verified where shown.
>
> **⚠️ Read this naming warning before anything else.** The label "V6" and "V7" were each used for *two different things* across the wrap-around sessions. Confusing them will corrupt every future conclusion:
>
> | Label | Build SHA | What it was | Status |
> |---|---|---|---|
> | **"V6" (Part 2)** | `a6cb92b8…` | 18-patch build with a **code-injection trampoline** that called `0x1409e8200` on the save-load path to fix the feat_progress reader | ❌ **BANNED** — corrupted save parsing; see Part 2 |
> | **"V6" (this part)** | `f5b7dfd6…` | 5 narrow **branch patches on top of V5** that fix Featured-Ruler **save selection** (the Jan-1 fallback). This is the V6 in the repo patcher set and in `STATUS.md`. | ✅ **runtime-proven baseline** |
> | **"V7" (this part, logs 4–5)** | `0074af70…` | Hypothesis-only patch to two "live feat update" gates after load | 🟡 **built, never shipped/tested, premise later disproven — abandoned** (see D1) |
> | **"V7" (`STATUS.md`, later)** | *(no patcher yet)* | The **Continue-button enable fix** — a genuinely different, later effort seeded by the 2.6.1.1 PDB work | 🟢 **the actual current target** (see E1) |
>
> Throughout this archive, **"V6" means the successful `f5b7dfd6…` save-selection build**, and the feat-update experiment is called **"feat-V7"** to avoid colliding with the later Continue-V7.

---

# A. ORIENTATION

## A1. Goal (unchanged)

Restore the retired **Monarch's Journey** mode of Crusader Kings II for personal, fully offline Windows use. Parts 1–2 ended with: V5 loads Featured-Ruler saves *visibly* but falls back to a fresh 1 January scenario (the selected save is never installed as the deserialize target); a separately attempted trampoline "V6" was banned for corrupting the parser.

## A2. Status dashboard at the end of this arc

| Area | State |
|---|---|
| MJ panel, 11 rulers, Bronzeman start, live in-session progress (V4) | ✅ works |
| **Correct save loads** (3 March, not 1 January) after selecting it | ✅ **works (V6 `f5b7dfd6…`)** |
| **MJ interface remains after load** | ✅ works |
| **Saved feat value (1/6) restores** from an old V4-era save | ✅ works |
| **Live challenge evaluation / tier granting in a fresh campaign** (Pavao Bronze) | ✅ **works** (proved by the "second look" playtest) |
| **Persistent progress across full restart** (local feat cache) | ✅ works |
| **Continue button** (main menu + MJ panel) | ❌ **still greyed — the real V7 target** |
| "Feats don't go up after loading a save" (the worry that spawned feat-V7) | 🟡 **resolved as a non-bug** — fresh-campaign evaluation works; the loaded old save's behavior is not the blocker it appeared to be (see D1) |
| Reward gallery / Titus / CK3 cosmetics | ❌ dead server-side, out of scope |
| 3.3.5.1 port | ❌ assessed infeasible (separate report, `WINDOWS_3351_PORT_ASSESSMENT.md`) |

## A3. Where this part sits in time

These three logs are **short continuation sessions on the `arena/01a02609…` branch** (the feat-V7 test guide in log 5 references the newer `arena/01a02a4a…` branch). They sit *after* the Part-1 father session produced V5 and *around* the Part-2 session that built the banned trampoline. Crucially, this arc takes the **other, successful fork**: instead of injecting code to "fix" the feat reader, it finds that V5's actual remaining problem is *five duplicated account gates in save selection*, patches only those, and gets a clean runtime win. The later "second look" playtest then disproves the need for the feat-V7 that grew out of a misleading first report.

## A4. One-paragraph story

A fresh session opened both test saves and proved they were valid and genuinely different (3 March vs 1 January, both carrying `global_heretical_company=1`), so the 1-January screen after V5 was a *fallback*, not the save contents. Reconstructing the exact V5 executable and re-disassembling every account-status xref in the save subsystem showed V5 had patched only the *generic* validator, while the same Featured-Ruler account check was duplicated in Continue candidate-selection and four save-list paths — those branches rejected the record before it became the active load target. Five length-preserving branch edits became **V6 `f5b7dfd6…`**, an 868-line ultimate handoff was written, and the user reported it worked: the save loaded, the MJ interface stayed, and the saved "1" was present — but new feat actions did not seem to raise the score. That report spawned a **feat-V7** candidate (two tiny gates) and a cross-version/runtime-tracing plan. Before it was ever tested, the user's **"second look"** Pavao playtest showed live evaluation working perfectly — Bronze tier granted at the exact payload threshold, progress persisted via the local cache — which retired the feat-V7 premise. The one genuinely remaining defect, the **greyed Continue button**, became the next (and current) target.

---

# B. STORY

## B1. Timeline

**S1 — Save forensics (log 3).** The session opened with only `previous chat log.txt` and asked for the two saves + V5 patcher. Both `.ck2` files (uploaded as `.txt`) were opened as ZIPs and found structurally valid and **distinct**:

| Save | Internal date | `global_heretical_company` | Uncompressed size | Archive SHA-256 |
|---|---|---|---|---|
| `Bosnia1173_03_03.ck2` | 1173.3.3 | 1.000 | 24,272,124 B | `e25c1c90074b9c02c29163fb6f034241226f1432edfbe184c804aa330edd61c0` |
| `Bronzeman_kulin_bosnia.ck2` | 1173.1.1 | 1.000 | 20,608,047 B | `5b7767b92483ec21bd86149aab8fe56577caf7f77a3a19ebf7bdaf0f3729d038` |

Both carry `bronzeman=yes`, `special_event="kulin_bosnia"`, version 3.3.3.0. Therefore the 1-January/0-6 screen seen under V5 was **not the contents of either save** — CK2 was falling back to a fresh setup scenario. The "Game State is corrupted" tooltip was a *secondary* state after the failed transition, not archive corruption.

**S2 — V5 reconstruction + the five missed gates.** The user uploaded V5 as four Base64 parts; it reconstructed to 24,753,368 B, SHA `29556549…` (exact V5). Independent disassembly of every account-status xref in the save subsystem found that V5's single edit (the generic validator `0x009e3d4c`) was necessary but not sufficient: the **same Featured-Ruler account check was duplicated in five more places** — Continue candidate selection and four save-list/selection paths — that prevented the selected record from being written into the selection fields the loader reads (object `+0x368` = selected save name, `+0x3a8` = selected record pointer). This single fact explains every V5 symptom: row selectable, Load looks available, but the selected state is never installed.

**S3 — V6 (`f5b7dfd6…`) built.** Five length-preserving edits (full table in C1), all on already-validated accepted-save paths; broken-file/version/DLC/alternate-start checks untouched; no save modified; no global account fabrication. The guarded PowerShell patcher accepts only exact V5 or exact V6, takes a verified-original backup, verifies the full-output SHA, and reverts exactly. A `PREPARE_CK2_MJ_V5_EXE_UPLOAD.bat` drag-and-drop Base64 chunker was also delivered.

**S4 — The ultimate handoff.** The user connected the next session to GitHub (which now held Base64 of Linux 3.3.3 and Windows 3.3.2/3.3.3/3.3.5.1) and asked for a complete handoff. The 868-line `CK2_MJ_ULTIMATE_HANDOFF.md` was written (now in `02_handoffs/`), consolidating the full v2→V6 patch map, both save identities, the loader findings, dead ends, safety rules, repository hygiene, and the exact pending V6 runtime test (with an outcome matrix A–D).

**S5 — V6 runtime result (log 4).** After reading the handoff and all tools/screenshots, the user reported (verbatim): *"it did load game, interface remained, '1' was present. but feats doesn't work. scores don't go up even if i do right things."* This is the core save-selection **success** — outcome A/B hybrid: correct date + restored value, but a new worry about live evaluation. The session correctly recorded V6 as: save loading ✅, interface persistence ✅, serialized-value restoration ✅, live feat updates after load ❓.

**S6 — The feat-V7 candidate.** Static analysis (using Linux symbols mapped to Windows) named the tracker functions (C2) and proposed that two "duplicated caller branches can still skip the live feat-update routine after loading." A focused two-branch patch was prepared and pushed (commit `c70a453` on `arena/01a02609…`), producing `patch_ck2_mj_v7.ps1` + apply/check/revert bats + a test guide. Target hash `0074af70…`. This was explicitly a **hypothesis-driven test patch**, not a claimed fix.

**S7 — Tracing & cross-version ideas.** The user asked whether one could "observe everything that happens in real life" and whether comparing all four EXEs would help. The answer proposed two tracks: (1) Windows runtime tracing — Process Monitor for file/path, plus x64dbg/WinDbg/Frida function-level logging around the four tracker addresses; (2) static cross-version comparison of 3.3.2 / May-3.3.3 / Linux-3.3.3 / 3.3.5.1. The Linux binary's intact `.dynsym` exposed the full `CRulerFeatTracker` / `CFeatProgressStorage` API. No trace was ever run.

**S8 — "More things" and "second look" (log 4 end).** The user pointed to two new evidence folders. **"More things"** documented the **Featured Ruler** predecessor (MJ was built on its base): a slightly different right-arrow, challenges appearing only on the 7th ruler, a UI bug where score showed 0 until the Challenges tab was opened, and community screenshots showing the Multiplayer button working for *some* people on older builds (3.3.0 era). **"Second look"** was the decisive playtest: a fresh **Pavao of Croatia** Bronzeman campaign, landing family members, unpausing, and getting the **Bronze-conditions-met message**. The local feat cache `q847rsja8ndx` showed `established=4` (the Bronze threshold) and `conquerer_from_bribir=1`, surviving outside the save. The session was cut off ("open a pull request… conversation too long") before acting on this.

**S9 — Feat-V7 test plan & V8 idea (log 5).** The next session read the feat-V7 tools and handed back a crisp two-question test (loaded save: progress up? yes/no; fresh campaign: progress up? yes/no) with the V7 hash and a note that if both failed, the next suspect was `IsActiveForPlaythrough` returning false after load — "we'd make a narrow V8 only for that." The repo workspace showed "No Changes," i.e. **feat-V7 was never applied/committed as a result**. The "second look" evidence from S8 already answers the fresh-campaign question with a clear *yes* (Bronze granted), which is why feat-V7/V8 were not pursued.

---

## B2. Evolution of the mental model

| # | Working theory | What confirmed / killed it |
|---|---|---|
| 1 | "V5 fails because the save is corrupt or the wrong file loads" | **Killed** by S1 — both saves valid and distinct; CK2 falls back to Jan 1 because the record is never *selected*, not because the archive is bad |
| 2 | "One generic account branch is the whole save-loading problem" | **Killed** by S2 — five duplicated gates remained; patching all five (V6) made the right save load |
| 3 | "V6 works for loading, but live feats are broken after load → feat-V7 needed" | **Killed** by S8 — a *fresh* Pavao campaign evaluated and granted Bronze correctly at the payload threshold; the post-load worry came from an old V4-era save, not a general tracker failure |
| 4 | "Persistence needs the banned trampoline (Part 2) to read token 0x3816" | **Superseded** — V6 `f5b7dfd6…` never touches the reader, yet persistence works: feat globals are ordinary script variables that serialize normally, and peak progress is mirrored in the *local cache* `q847rsja8ndx`. The no-op reader did not block the restoration path in practice |
| 5 | **Final model:** the core MJ loop is fully restored; the only remaining functional defect is the Continue **enable predicate** | **Open → becomes the real V7** (E1) |

## B3. Patch lineage for this part

| Gen | Change over prior | Runtime result | Verdict |
|---|---|---|---|
| **V6 `f5b7dfd6…`** | +5 branch edits in save selection / Continue-candidate paths (C1) | **Correct save loads (3 March), interface stays, saved 1/6 restores** | ✅ **new safe baseline** (this is the V6 in the repo and STATUS) |
| **feat-V7 `0074af70…`** | +2 branch edits targeting live feat-update gates after load | never tested by user; premise disproven by fresh-campaign Bronze | 🟡 **abandoned, do not ship** (D1) |

> The Part-2 banned trampoline `a6cb92b8…` is **not** part of this lineage; V6 `f5b7dfd6…` is built cleanly on V5 with 16 V5 entries + 5 new = 21 cumulative patches and contains **no** injected code.

---

# C. KNOWLEDGE BASE

## C1. The five V6 save-selection patches (definitive)

From the repo patcher `05_patches_and_scripts/ps1/patch_ck2_mj_v6.ps1` and the handoff §11. All are length-preserving (the two 6-byte conditionals become a 5-byte `jmp` + NOP). Input SHA `29556549…`, output SHA `f5b7dfd6…`, size 24,753,368.

| File offset | VA | V5 bytes | V6 bytes | Meaning |
|---|---|---|---|---|
| `0x009e4611` | `0x1409e5211` | `74 0f` | `eb 0f` | Continue candidate selection: skip Featured-Ruler account check, take accepted-save path |
| `0x009e4f1e` | `0x1409e5b1e` | `0f 84 86 01 00 00` | `e9 87 01 00 00 90` | First save-list selection path → accepted target `0x1409e5caa` |
| `0x009e4fc3` | `0x1409e5bc3` | `74 0f` | `eb 0f` | Newer/current-save path → accepted target `0x1409e5bd4` |
| `0x009e5377` | `0x1409e5f77` | `0f 84 63 01 00 00` | `e9 64 01 00 00 90` | Named-save path → accepted target `0x1409e60e0` |
| `0x009e5452` | `0x1409e6052` | `74 0b` | `eb 0b` | Latest-save path → accepted target `0x1409e605f` |

**Relevant functions:** Continue candidate selection `0x1409e4970–0x1409e5342`; main save-list scan/selection `0x1409e5500–0x1409e66f6`; caller that consumes the selected record `0x1409e6700…`; the V5-patched generic validator `0x1409e4900–0x1409e4967`. The Continue helper is called from `0x1407bffa1` (MJ path), `0x1408145ec` (normal frontend), `0x140a0ba62` — these three are the breadcrumbs for the Continue-V7.

## C2. Feat-tracker function map (Windows May 3.3.3, from Linux symbols)

Recovered by mapping Linux `.dynsym` names onto Windows. Useful for any future live-tracking work, but **no patch here is currently warranted**:

| Windows VA | Linux-symbol name |
|---|---|
| `0x1407b8370` | `CRulerFeatTracker::IsActiveForPlaythrough()` |
| `0x1407b8450` | `CRulerFeatTracker::CalcShouldTrackFeatProgress()` (the V4 in-game tracking gate is here, `0x007b78eb`) |
| `0x1407b8e60` | `CRulerFeatTracker::UpdateFeatProgress()` |
| `0x1407b9340` | `CRulerFeatTracker::RecalcScore()` |
| — | `CFeatProgressStorage::Update() / ReadCachedProgress() / SetNewProgress()` |

The feat-V7 premise was that after a load, `IsActiveForPlaythrough`/`CalcShouldTrackFeatProgress` returned false and skipped `UpdateFeatProgress`. The Pavao second-look (Bronze granted in a *fresh* campaign) shows the chain works; the old-save behavior is a narrower, non-blocking curiosity.

## C3. Persistence model (corrected vs Part 2)

Part 2 located a no-op save-reader case for token `0x3816` ("feat_progress") and hypothesized it was the persistence bug, motivating the banned trampoline. The V6 runtime result corrects this:

- **Challenge progress lives in ordinary CK2 script globals** (e.g. `global_established`, `global_heretical_company`), which serialize through the normal save path and deserialize correctly — proven by the 3 March save showing `1/6` and the Pavao save showing `established=4`.
- **Peak progress is additionally mirrored in the local feat-progress cache** `cache/q847rsja8ndx` (`feat_progress_storage`, `user_id=84696387`), e.g. `established=4`, `conquerer_from_bribir=1`. This survives full restarts independent of the save and does not contact the dead Titus backend.
- The token-0x3816 reader no-op therefore did **not** block observable persistence; the banned trampoline was solving a problem that did not manifest, with a helper whose data direction was also wrong.

## C4. Cross-version findings (high level; full report separate)

Drawn from log 4 and finalized in `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md`:

| | 3.3.2 | May 3.3.3 | 3.3.5.1 |
|---|---|---|---|
| GameSparks SDK / payload JSON parser / `gs_virtual/feat_script` loader | present | present | **removed** |
| MJ main-menu panel UI | present | present | **gone** (only `_icon/_toggle_open/_toggle_close` remain) |
| Bronzeman / feat tracking / save fields / Titus reward table | present | present | **survives but has no data source** |
| Local `common/monarchs_journey` path | **absent** (remote-only) | present | present (strings) but higher init gone |

**Verdict:** byte-patch port to 3.3.5.1 is **not feasible** without code injection, which the project avoids. May 3.3.3 stays the target; 3.3.5.1 can be used for normal play with the patched May EXE for MJ runs (hybrid). Raw offsets must never be copied between versions.

## C5. Artifact identities (this part)

| Artifact | SHA-256 |
|---|---|
| V6 (successful, save-selection) | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` |
| feat-V7 candidate (abandoned, hash only) | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` |
| `Bosnia1173_03_03.ck2` (archive) | `e25c1c90074b9c02c29163fb6f034241226f1432edfbe184c804aa330edd61c0` |
| `Bronzeman_kulin_bosnia.ck2` (archive) | `5b7767b92483ec21bd86149aab8fe56577caf7f77a3a19ebf7bdaf0f3729d038` |
| Payload `gfx\monarchs` | `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` (unchanged) |

The payload's Pavao (`pavao_croatia`, startdate 1278.01.01) defines `established levels = {4 6 8}` (Bronze 4 / Silver 6 / Gold 8), `conquerer_from_bribir levels = {4}`, `subic_stantial_legacy levels = {1 2 3}`. The runtime Bronze grant at `established=4` matches the payload exactly — independent proof the evaluator reads the local JSON correctly.

---

# D. ATTEMPTS & DEAD ENDS

## D1. feat-V7 / feat-V8 — built but abandoned (do not ship)

The two-branch feat-V7 (`0074af70…`) and the mooted narrow V8 for `IsActiveForPlaythrough` were responses to *"feats doesn't work, scores don't go up"* from a loaded **old V4-era save**. The "second look" fresh Pavao campaign then showed:

- live evaluation fires (`global_established` 2 → 4 across the first days);
- Bronze rank granted at exactly `established=4`;
- saves written with `bronzeman=yes`, `special_event="pavao_croatia"`, feat globals serialized;
- resume after full restart works via Load Game;
- the local cache stores peak progress.

That is a full refutation of the "tracker is dead after load" premise for the general case. **The feat-V7 patcher is not in the organized repo** (only V6 and earlier are shipped), and it should not be resurrected without a specific, reproducible failing case on a *fresh* V6 campaign. If a real post-load regression is ever reproduced, trace the four C2 addresses first (log 4's plan) rather than forcing branches.

This also retires Part 2's open doubt that the Bosnia "1" might have been Kulin counting himself at start — Pavao's threshold-crossing Bronze is an unambiguous real-event count.

## D2. Other closed items from these logs

- **Runtime tracing (Process Monitor / x64dbg / Frida)** was proposed for the feat worry; never needed once the second-look succeeded. The recipe remains valid if a future defect needs it.
- **"Maybe an earlier 3.3.0 EXE has MJ"** (user's question from community screenshots): the version landscape in Part 1 already establishes 3.3.2 is remote-only and May 3.3.3 is the last pre-removal local-capable build; older builds add nothing the Linux symbols don't already provide. No earlier EXE is needed.
- **The "Featured Ruler predecessor" / right-arrow / 7th-ruler observations** are historical UI-generation context (already noted in Part 1 C2); they are not action items.
- **The score-shows-0-until-Challenges-tab-opens UI bug** and the **Multiplayer button works-on-some-boots / grey-map-on-first-boot** items are cosmetic frontend-refresh quirks, filed with STATUS.md's secondary list.

---

# E. OPEN THREADS & FUTURE DIRECTIONS

## E1. The Continue button — the actual V7 target (carries forward)

V6 patched the inline Featured-Ruler account branch *inside* the Continue candidate-selection helper `0x1409e4970`, yet Continue stays greyed on both the main menu and MJ panel. Per the 2.6.1.1 PDB semantic model (see `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` and `03_analysis/TYPE_AND_VTABLE_NOTES.md`), the older flow computes one `is valid continue save` result and pushes Enable/Disable to widget `"continue"`. The 3.3.3 failure is therefore a **different, non-account enable predicate**. The three caller breadcrumbs are `0x1407bffa1` (MJ path), `0x1408145ec` (normal frontend), `0x140a0ba62`, all converging on the shared helper at `0x1409e4970`. This is the first item in `PLAN.md` Phase 2 and the next real work.

## E2. Separate later projects (unchanged)

- Local reward-gallery reconstruction (Linux `CRoadToTitusProgression::SetupRewards` @ `0x1444e92` holds the reward table; Titus itself is dead).
- Recovering the 5 missing rulers (payload has 11 of 16; need a late-Aug 2020 snapshot).
- 3.3.5.1 port — assessed infeasible via byte-patching (C4); hybrid usage recommended.

---

# F. CONTEXT

## F1. Environment & constraints (unchanged)

- Windows, non-technical user; offline testing only (Internet on switches the obsolete client to a failed state).
- Test root `C:\Users\UZWERG\Desktop\SteamCrusader`, payload at `gfx\monarchs`.
- Uploads are text/image only → Base64 parts + SHA-256 manifests; `prepare_*_upload.bat` chunkers delivered this part work for any file.
- GitHub sessions are even shorter than chat sessions; hence the handoff-file discipline and the 868-line `CK2_MJ_ULTIMATE_HANDOFF.md`.

## F2. Safety (additions)

- **Do not ship or derive from feat-V7 `0074af70…`** until a reproducible fresh-campaign failure exists; its premise was disproven.
- V6 `f5b7dfd6…` is the new safe baseline. The Part-2 banned `a6cb92b8…` and its trampoline remain forbidden (never call `0x1409e8200` on a load path).
- Unchanged: never run `wipe_feats`; never redistribute patched executables (only guarded patchers); never apply May offsets to 3.3.5.1; keep the two Kulin evidence saves; stay offline.

## F3. Method lessons (this part)

1. **Forensics before patching.** Opening the two saves as ZIPs and reading their internal dates/globals converted a confusing "both saves look the same" report into a precise "the selected save is never installed" diagnosis — in one step, with no disassembly.
2. **One validator ≠ one check.** V5 patched the generic predicate; the account test was duplicated five times in the selection layer. Enumerate *every* xref of a retired check before declaring a gate fixed.
3. **A runtime win can retire a whole line of static work.** The feat-V7, the tracing plan, and the mooted V8 all became unnecessary the moment a fresh campaign demonstrably granted a tier. Test the simplest real scenario before building instrumented patches.
4. **Names collide across wrap-around sessions.** "V6" and "V7" each meant two things; always key builds by SHA, never by generation label. The naming table at the top of this file exists because that collision was a real hazard.
5. **The handoff document is the load-bearing artifact** for short, interrupt-prone sessions — the 868-line ultimate handoff let the next session start with zero re-derivation.

## F4. Evidence & artifact inventory (this part)

| Evidence | Proves |
|---|---|
| `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` (868 lines) | the full bridge state written at end of log 3: patch map, saves, loader findings, pending test, outcome matrix |
| `05_patches_and_scripts/ps1/patch_ck2_mj_v6.ps1` + apply/check/revert bats | the successful 5-branch V6 (`f5b7dfd6…`), hash-guarded, revert-capable |
| `05_patches_and_scripts/bat/PREPARE_CK2_MJ_V5_EXE_UPLOAD.bat` | drag-and-drop verified Base64 chunker |
| `04_test_guides_and_reports/CK2_MJ_V6_TEST_GUIDE.md` | the V6 manual-load + Continue test procedure |
| `03_analysis/V6_RUNTIME_RESULTS.md` | compiled 2026-08-22 evidence chain: Pavao Bronze, persistence, Continue still greyed |
| `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md` | cross-version verdict (3.3.5.1 not byte-patchable) |
| `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` | seeds the Continue-V7 (the real next target) |
| `13_save_and_cache/q847rsja8ndx` | local feat cache proving offline persistence (`established=4`) |
| Screenshots `(1)`–`(7)`, `(15)`–`(18)`, "second look" / "more things" sets | Continue greyed, secondary UI quirks, Pavao Bronze evidence |
| feat-V7 files (`patch_ck2_mj_v7.ps1` + bats, `0074af70…`) | existed on the `arena/01a02609…` session branch; **not carried into the organized repo** because abandoned |

---

# MERGE NOTES (vs Parts 1 & 2)

- **Part 1** ended on the persistence cliffhanger with V5. This part shows V5's real defect was *save selection* (five gates), not persistence, and that V6 fixed it.
- **Part 2** documented the **banned** trampoline V6 (`a6cb92b8…`) built to fix the token-0x3816 no-op reader. This part documents the **successful**, divergent V6 (`f5b7dfd6…`) that patches only selection branches and never touches the reader — and shows persistence works without that reader being "fixed" (C3). The two must not be conflated; the top-of-file naming table is authoritative.
- The `INDEX.md` note that `fourth`/`(5)` "need Part 3 (V7 triage + V6 runtime verdict)" is satisfied here, with the important correction that the V7 in those logs is the **abandoned feat-V7**, not the later **Continue-V7** that `STATUS.md` names as current. The Continue triage lives in `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` and is the next work item, not a topic of these three logs.
- After this part, the chronological arc of the raw logs is fully covered: Part 1 (`first`/`previous chat log`), Part 2 (`second`/`previous chat log (2)`), Part 3 (`third`/`fourth`/`(5)`). The four `Новый…` files are evidence fragments already absorbed into Parts 1–2 (V3–V5 build, xref disassembly, SHA manifests, V5 readiness) and need no separate archive.
