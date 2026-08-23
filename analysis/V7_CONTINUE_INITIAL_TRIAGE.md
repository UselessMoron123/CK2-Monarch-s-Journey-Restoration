# V7 Continue investigation — initial triage

Date: 2026-08-23. This is the first investigation note after the 2.6.1.1
full-PDB results. It makes **no executable change** and proposes no patch yet.

## Inputs and scope

- The local `CK2game333.exe` is the verified **stock** May-2020 Windows 3.3.3
  target: SHA-256
  `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`.
- V6 runtime evidence already establishes that a Featured Ruler / Bronzeman
  save manually loads and its feat globals deserialize, but normal-menu and MJ
  **Continue remain grayed out**.
- The newer 2.6.1.1 debug-symbol research (available on repository `main` under
  `analysis/debug2611/`) exactly matches its own 2016 EXE. Its addresses and
  layouts are *not* used here. Its safe semantic finding is that the older
  Continue flow has one computed `is valid continue save` result, which is
  then pushed to the button as Enable/Disable. Manual Load and Continue can
  therefore legitimately diverge.

## First verified 3.3.3 observation: all relevant UI paths share one helper

The three existing V7 breadcrumbs are direct calls to the same 3.3.3 function,
with the common helper beginning at **VA `0x1409e4970`**:

| Caller VA | Context inferred from established project map | `edx` argument | Immediate use of return value |
|---:|---|---:|---|
| `0x1407bffa1` | Monarch’s Journey frontend path | 0 | passes returned string/object to `0x1400cdd80` |
| `0x1408145ec` | ordinary frontend Continue path | 1 | returns immediately after helper result is written to its output object |
| `0x140a0ba62` | another frontend/rank/featured-ruler construction path | 0 | passes returned value to `0x1400cdd80` |

At each call, `rcx` is an output object and `r8` is a context/input pointer;
this shape is consistent with a helper that computes a save candidate/name and
returns it through a string-like output object. The boolean `edx` is likely a
mode selector (for example normal versus cloud/alternate scan), but this is
not yet proven.

This resolves one early ambiguity: the three callers should not be patched
independently. The next unit of analysis is the shared helper
`0x1409e4970` and the exact state/check that makes its result empty or
non-continuable.

## Existing scoped edits inside the shared region

The V5/V6 patch map already identifies these edits in/near this helper:

- V5 `0x009e3d4c` / VA `0x1409e494c`: skip a Featured-Ruler account check in a
  generic valid-save predicate.
- V6 `0x009e4611` / VA `0x1409e5211`: accept a Featured Ruler candidate in one
  Continue-selection branch.
- V6 `0x009e4f1e`, `0x009e4fc3`, `0x009e5377`, `0x009e5452`: accept a selected
  Featured Ruler save in four save-list paths.

Those edits enabled manual load, but not the visual Continue enable state.
Therefore V7 must locate a **different remaining rejection**, not merely force
one of the three callers or force the button enabled.

## What the 2.6.1.1 PDB result contributes

The exact 2016 implementation used the conceptual sequence:

```text
enumerate local/cloud .ck2 candidates newest-first
  → parse candidate metadata
  → reject malformed / unsupported-version / unavailable-DLC candidates
  → choose newest valid candidate
  → parse display metadata
  → set a single valid-continue result
  → RefreshContinueButton: Enable or Disable "continue"
```

3.3.3 is a different 64-bit build and later introduced Featured Ruler account
logic, so this is a **semantic checklist only**. It provides a disciplined
search order for remaining helper branches:

1. malformed or rejected metadata;
2. save version compatibility;
3. DLC / alternate-start / campaign-mode exclusion;
4. newest-save comparison and local/cloud selection;
5. Featured-Ruler-specific status after the V5/V6 account branches;
6. a downstream result-empty check that the ordinary and MJ frontends both
   consume.

The observed manual-load success makes malformed archive data, general version
incompatibility, and generic save parsing lower-probability causes, but none is
eliminated until the helper’s actual control flow is labelled.

## Next concrete analysis steps

1. **Recover function bounds and build a labelled CFG for `0x1409e4970`.**
   Use `.pdata` boundaries and disassembly of the exact stock 3.3.3 EXE.
   Identify all paths that return an empty output versus a candidate.
2. **Annotate every conditional involving Featured-Ruler save metadata.**
   Specifically distinguish branches already covered by V5/V6 from remaining
   predicates. Retain raw offsets, expected bytes, and branch targets.
3. **Trace output state at each return.**
   Determine what object/string is returned and whether an empty candidate, a
   separate boolean, or an adjacent validity flag is ultimately consumed by
   each UI path.
4. **Compare to Linux 3.3.3 `CIronmanSaveSelect::GetContinueSave`.**
   The Linux symbol is a semantic reference, not an address translation. Align
   candidate enumeration, metadata parsing, and final validity decisions.
5. **Only then design a V7 candidate.** It must be length-preserving, narrowly
   scoped, exact-stock/V6 hash guarded, byte-verified, revertible, and tested
   first with the existing evidence saves. Never globally fabricate account
   state or blindly force a GUI button enabled.

## Current confidence

- **High:** the three reported UI paths converge at `0x1409e4970`.
- **High:** V7 should begin in the shared selection helper, not with separate
  caller patches.
- **Medium:** the helper’s returned candidate/empty result drives the disabled
  state.
- **Unproven:** the specific remaining predicate and any safe patch bytes.
