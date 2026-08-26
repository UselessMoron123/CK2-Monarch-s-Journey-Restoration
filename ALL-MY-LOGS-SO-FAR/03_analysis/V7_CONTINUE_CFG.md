# V7 Continue investigation — first-pass CFG (recovered from cleanup log)

**Date:** 2026-08-23 (recovered from `logs to dissect.../Новый текстовый документ (5).txt`, session branch `arena/01a03c92-...` / `arena/01a02609…`)
**Status:** No executable change, analysis only. This file was mentioned in log (5) as `analysis/V7_CONTINUE_CFG.md` +112 lines, commit `3218e77`, but was not present in the squashed main `cad3e23`. Recovered here to preserve info.

## Correction vs initial triage notes

Initial triage (`V7_CONTINUE_INITIAL_TRIAGE.md`) described three callers converging on shared helper `0x1409e4970`. First-pass disassembly clarifies:

| Range (VA) | Role |
|---|---|
| `0x1409e4970–0x1409e5342` | **One save-candidate construction/selection helper** — constructs save-related strings, obtains candidate collection, iterates, compares metadata, checks validity, selects/rejects, produces object consumed by frontend |
| `0x1409e5500–0x1409e66f6` | **Separate, larger save-selection routine** — scans `save games/*.ck2`, builds exclusion for `alternate_start`, newest-first sort, etc. |
| `0x1409e671f` | Call site where second routine is invoked — **not called by first helper** (earlier assumption that first calls second was wrong) |

This means Continue has **multiple independent layers**, not a single helper:

```
save enumeration
→ metadata/status checks
→ candidate validity
→ newest/current-save comparison
→ candidate installation (writes selected save name +0x368, record pointer +0x3a8, etc.)
→ frontend enable-state (RefreshContinueButton → CButton::Enable/Disable)
```

## Rejection paths (stock May 2020 3.3.3)

Important convergence points (from log):

- `0x1409e4f35`, `0x1409e4f42`, `0x1409e4fba` — rejection branches inside `0x1409e4970` region
- `0x1409e4900` — distinct validity helper (performs another validity check on save-related object), already has V5/V6 edits nearby (`0x009e3d4c` / `0x1409e494c`)
- `0x1409e4dc1` / `0x1409e5a71` — signed status/compatibility result checks (strongest current candidates for remaining blocker per log)
- Final candidate/output installation failure after V6-patched save-list branches (`0x009e4611`, `0x009e4f1e`, `0x009e4fc3`, `0x009e5377`, `0x009e5452`) — V6 enabled manual Load, but Continue still greyed → different, non-account predicate

## What to label next

Per log's own recommendation, label each branch in `0x1409e4970` CFG as:

- ordinary invalid save (broken, missing Version/Player/Date)
- unsupported version (SAVE_GAME_VERSION_TOO_OLD etc., `+0xbc` VersionStatus length)
- alternate-start exclusion (`alternate_start` token)
- DLC/checksum condition (Conclave gate `+0xcd`, DLC manager)
- Featured Ruler/account condition already handled by V5/V6 (account status ==3)
- empty candidate result (no valid save found)
- final Continue-specific rejection (enable predicate)

## Relation to Linux semantic model

Linux `CIronmanSaveSelect::GetContinueSave` @ `0x121ac3a` ↔ win333 `0x1409e5500` region provides:

```
enumerate local/cloud .ck2 newest-first
→ parse meta (version/date/player/ironman)
→ reject malformed / unsupported-version / unavailable-DLC
→ choose newest valid
→ set single valid-continue result (_bIsContinueSaveValid @ +0x23D in 2.6.1.1, different offset in 3.3.3)
→ RefreshContinueButton: Enable/Disable "continue"
```

2.6.1.1 PDB proves **no account/GameSparks predicate** existed in old Continue path — any 3.3.x failure after V5/V6 account patches is therefore a **newer predicate** (non-account).

## Next steps (from log)

1. Recover function bounds via `.pdata`, build labelled CFG for `0x1409e4970`
2. Annotate every conditional involving Featured-Ruler metadata, distinguishing already-covered V5/V6 branches
3. Trace output state at each return (empty vs candidate, boolean flag)
4. Compare to Linux `GetContinueSave` (semantic reference, not address translation)
5. Only then design V7 candidate: length-preserving, hash-guarded (stock `656f4f48…` / V6 `f5b7dfd6…`), byte-verified, revertible, tested with Bosnia `Bosnia1173_03_03.ck2` and Pavao saves

## Preservation note

This file was built from log (5) transcript; original commit `3218e77 Document first-pass Continue control-flow analysis` on branch `arena/01a02609…` was lost in squashed main `cad3e23`. Content preserved here per preservation audit. The analysis itself was later superseded by `CONTINUE_SEMANTIC_REFERENCE.md` and `V7_CONTINUE_INITIAL_TRIAGE.md`, but the two-helper correction remains valuable.
