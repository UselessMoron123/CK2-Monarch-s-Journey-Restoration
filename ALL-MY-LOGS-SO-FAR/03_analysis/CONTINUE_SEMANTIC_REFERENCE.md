# Continue button — semantic reference (2.6.1.1 PDB → win333 mapping)

The V7 target is the **greyed Continue button** on win333 May 3.3.3. This file
consolidates the two things a V7 analyst needs in one place: (A) the *proven*
2.6.1.1 Continue control-flow model from the exact-matched PDB, and (B) the
known win333 anchor points to map it onto. The 2.6.1.1 material is a **semantic
checklist only** — its 32-bit VAs do not transfer; the win333 facts are the
patch target.

Primary sources: `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md`,
`TYPE_AND_VTABLE_NOTES.md` §2, `SEARCH_RESULTS.md` group 1,
`WINDOWS_3351_PORT_ASSESSMENT.md` §7, the Part 1–3 archives.

---

## A. The 2.6.1.1 model (proven, semantic reference)

```
enumerate local/cloud .ck2 candidates, NEWEST FIRST (stable sort by mtime)
  → CSaveGameModel ctor parses header/meta
  → anon::IsValidSave(model, dlc) rejects:
        _bBroken
        non-empty _VersionStatus  (unsupported version diagnostic)
        Conclave save without Conclave DLC
     (NO account / GameSparks / cloud-presence / special-mode check)
  → first (newest) valid candidate wins
  → UpdateIronmanAndCharForContinue parses: version, date, player, optional ironman
  → set _bIsContinueSaveValid
  → RefreshContinueButton:
        GetButton("continue")->Enable()  if valid   (CButton vtbl +0xDC)
        GetButton("continue")->Disable() otherwise  (CButton vtbl +0xE0)
OnContinue(): if (!_bIsContinueSaveValid) return; else commit load.
```

Key 2.6.1.1 symbols (for name recognition only; NOT addresses to patch):

| Symbol | 2.6.1.1 VA | Role |
|---|---:|---|
| `CIronmanSaveSelect::GetContinueSave(bool, CloudStorageContext**, CDLCManager*)` (static) | `0x00AC7160` | enumerate + pick newest valid |
| `anon::IsValidSave(const CSaveGameModel*, CDLCManager*)` | `0x00AC70A0` | the validity gate |
| `CIronmanSaveSelect::UpdateContinueData(const CString*)` | `0x00AC7770` | recompute winner + `_bIsContinueSaveValid` @ `+0x23D` |
| `CIronmanSaveSelect::UpdateIronmanAndCharForContinue(CFile*)` | `0x00AC6D80` | parse version/date/player/ironman |
| `CIronmanSaveSelect::RefreshContinueButton()` | `0x00AC9BF0` | push Enable/Disable to widget `"continue"` |
| `CIronmanSaveSelect::RefreshLoadButton()` | `0x00AC9CC0` | analogous for Load |
| `CIronmanSaveSelect::OnContinue()` | `0x00AC8E00` | commits if `_bIsContinueSaveValid` |
| `CIronmanSaveSelect::ContinueOnStartup(const CString&)` | `0x00AC8D00` | startup path |
| launcher-side `anon::GetContinueSave(CDLCManager*)` in main.obj | `0x0099F540` | pre-scan wrapper (Steam cloud) |
| `CSaveGameModel::GetVersionStatus()` | `0x00AC22B0` | builds `_VersionStatus` (strings `"2.6.1.1"`, `"2.1.0.0"`, `UNSUPPORTED_VERSION"`, `"UNSUPPORTED_VERSION_2_1"`) |
| `CContinueFailedDialog::CContinueFailedDialog(CFrontEnd*)` | `0x008FD8A0` | shown when forced candidate mismatches |

Field offsets (2.6.1.1 `CIronmanSaveSelect`, size 0x290): `_Continue` button glue
@ `0x4C`; `_pSelectedItem` @ `0x1CC`; `_ContinueName` @ `0x1D4`;
`_LastLocalSavedFile` @ `0x1F0`; `_LastCloudSaveFile` @ `0x20C`;
`_bContinueIronman` @ `0x210`; `_ContinueChar` @ `0x214`;
**`_bIsContinueSaveValid` @ `0x23D`**.

**The crucial negative finding:** in 2.6.1.1 the Continue path has **no account
or online check**. Therefore the win333 failure (a *later* build, 64-bit, with
Featured-Ruler account logic added) is a **newer predicate**, not the original
Continue mechanism. Manual Load and Continue legitimately diverge because they
use different validity paths.

## B. The win333 anchor points (the actual V7 search space)

All addresses are Windows May 2020 3.3.3 (`656f4f48…`). VA = raw + `0x140000c00`.

### B1. The shared Continue/save-selection helper

The three reported UI call sites all converge on **one shared helper beginning
at VA `0x1409e4970`**. They should NOT be patched independently.

| Caller VA | Context | `edx` arg | Uses return via |
|---:|---|---:|---|
| `0x1407bffa1` | Monarch's Journey / highlighted-ruler Continue path | 0 | `0x1400cdd80` |
| `0x1408145ec` | ordinary frontend / launcher Continue path | 1 | writes result to output object & returns |
| `0x140a0ba62` | another frontend / featured-ruler construction path | 0 | `0x1400cdd80` |

At each call: `rcx` = output object, `r8` = context/input pointer. `edx` is a
likely mode selector (normal vs cloud/alternate scan), unproven. The helper
computes a save candidate/name returned through a string-like output object; an
empty/invalid result is what keeps Continue disabled.

### B2. Patches already applied inside/near this helper (do not re-add)

| Offset | VA | Gen | Effect |
|---|---|---|---|
| `0x009e3d4c` | `0x1409e494c` | V5 | skip Featured-Ruler account check in the generic valid-save predicate |
| `0x009e4611` | `0x1409e5211` | V6 | accept Featured-Ruler candidate in one Continue-selection branch |
| `0x009e4f1e` | `0x1409e5b1e` | V6 | accept selected FR save (save-list path) |
| `0x009e4fc3` | `0x1409e5bc3` | V6 | accept FR candidate (newer-save path) |
| `0x009e5377` | `0x1409e5f77` | V6 | accept named FR save |
| `0x009e5452` | `0x1409e6052` | V6 | accept latest FR save |

These made manual Load work but did **not** enable the Continue button. So V7
must find a *different, remaining* rejection — not re-patch these branches and
not globally force the button enabled.

### B3. V6 runtime evidence (what it narrows)

- A V4-era save (`Bosnia1173_03_03`, 3 March, `global_heretical_company=1`)
  loads via Single Player → Load Game and shows **3 March 1173** + **1/6**;
  feat globals deserialize.
- A fresh Pavao Bronzeman campaign grants Bronze and persists across restart.
- Continue stays **grayed from both the main menu and the MJ panel** — the
  failure is the button's *enable predicate*, not its click handler.

### B4. The Linux 3.3.3 semantic reference

Linux `CIronmanSaveSelect::GetContinueSave` is @ **`0x121ac3a`** (from the port
assessment §7 breadcrumbs). The Linux symbol is a same-version reference
implementation of candidate enumeration / metadata parsing / final validity —
port its **logic and call sequence**, never its addresses. The win333 region to
align it against is the `0x1409e5500` area (main save-list scan/selection) and
the shared helper `0x1409e4970`; caller `0x1408145ec` is the normal frontend
Continue path.

## C. Ordered V7 analysis steps (from the triage handoff)

1. Recover function bounds and build a **labelled CFG** of `0x1409e4970` using
   `.pdata`; identify every path that returns empty vs a candidate.
2. Annotate **every conditional on Featured-Ruler save metadata**, separating
   branches already covered by V5/V6 from remaining predicates; keep raw
   offsets, expected bytes, branch targets.
3. **Trace output state at each return** — determine whether an empty candidate,
   a separate bool, or an adjacent validity flag is consumed by each UI path
   (the win333 analogue of `_bIsContinueSaveValid` / `RefreshContinueButton`).
4. **Compare to Linux `GetContinueSave` @ `0x121ac3a`** as a semantic reference.
5. Hypotheses to test in order:
   1. a Featured-Ruler/marker check in the continue-save validator (parallel to
      the V5 Load gate already removed);
   2. a "save written by an account-bound session" / feat-storage predicate;
   3. a save-timestamp / cloud-save availability check;
   4. a widget-state init ordering issue (Continue refreshed before the save
      list is scanned).
6. Only then design a V7 candidate: **length-preserving, narrowly scoped,
   exact-stock/V6 hash-guarded, byte-verified, revertible**; never globally
   fabricate account state or blindly force the button enabled. Produce
   `05_patches_and_scripts/ps1/patch_ck2_mj_v7.ps1` (+ apply/check/revert bats)
   and a short test guide.
7. User test (offline): boot → MJ panel / main menu → is Continue clickable?
   → does it load the Bronzeman save with `1/6`+ progress? Two yes/no results.

## D. Guardrails

- The "V7" hash `0074af70…` from the raw `fourth`/`(5)` logs is an unrelated,
  **abandoned feat-update** patch (see Part 3 / BANNED_ARTIFACTS). It is not
  this Continue-V7; do not reuse its bytes or name.
- Never call `0x1409e8200` (vector append) from any read/load path.
- The win333 Continue helper is 64-bit; the 2.6.1.1 PDB is 32-bit — port logic,
  not offsets.
