# V9 design alternatives, and why V8's bytes cannot simply be dropped

**Created 2026-08-30.** Recovered from `last log/last log (for now).txt`
(session `arena/01a0534b`), which contained the V9 design deliberation but whose
reasoning had **not** been carried into any archive document. Verified
independently by disassembling
`10_binary_artifacts/executables/windows/CK2game333.exe` and by replaying the
full V2→V9 patch chain.

This document exists because two facts here are **safety-critical** and were
missing from the archive:

1. V8's second edit is **load-bearing** in the shipped V9 — reverting it silently
   disables the V9 fix.
2. A **second, abandoned V9 design** existed at a different offset, and under
   *that* design the same V8 edit would be dead code. The two designs have
   opposite implications, so "is V8#2 redundant?" has no single answer.

---

## 1. The shipped design — V9(A): force the final gate

| | |
|---|---|
| Site | raw `0x007B7906` / VA `0x1407B8506` |
| Edit | `e8 85 71 8f ff` (`call 0x1400AF690`) → `b0 01 90 90 90` (`mov al,1; nop×3`) |
| Effect | `CalcShouldTrackFeatProgress` reports "track" at the *last* gate only |
| SHA-256 | `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687` |
| Status | ✅ shipped, runtime-proven 2026-08-30 — current baseline |

## 2. The abandoned design — V9(B): force the flag gate

| | |
|---|---|
| Site | raw `0x007B785B` / VA `0x1407B845B` |
| Stock bytes | `74 07` (`je 0x1407B8464`) — the branch over the early `return 1` |
| Edit | `74 07` → `90 90` (`nop nop`), falling into `mov al,1` at raw `0x7B785D` |
| Effect | `CalcShouldTrackFeatProgress` returns 1 at the **top**, before any other check |
| Status | ❌ considered and **not** shipped; V9(A) was chosen instead |

Verified stock bytes (disassembly of the real exe):

```
raw 0x007B7854  cmp  byte ptr [rip+0xF2AD08], 0   ; 80 3d 08 ad f2 00 00
raw 0x007B785B  je   0x1407B8464                  ; 74 07      <- V9(B) site
raw 0x007B785D  mov  al, 1                        ; b0 01
raw 0x007B785F  add  rsp, 0x28                    ; 48 83 c4 28
raw 0x007B7863  ret                               ; c3
```

Reconstructed hashes for V9(B), should it ever be retried (the guarded patchers
key on hash, so these are needed before it can be applied at all):

| Build | SHA-256 |
|---|---|
| V9(B) = V8 + `0x7B785B` | `54fc9f8b6bdc042d8da121c4ef20e034533dbd1317ed2627e72f05dfad5268b8` |
| V9(B) minimal = V7 + V8#1 + `0x7B785B`, V8#2 restored | `ac244c447b50c72cf330948f924edbdad05ebbc3bfd2a422105288bec8c136c1` |

**Why V9(A) was chosen:** V9(B) short-circuits *every* check in
`CalcShouldTrackFeatProgress` — ruler-info null check, date expiry, game-mode
bytes, and the singleton `+0x60`/`+0x65` flags — not just the eligibility gate
the trace had actually measured failing. V9(A) is the narrower edit: it forces
only the one gate the cold trace proved was returning 0.

## 3. The dependency that must not be forgotten

`0x7B786B` (V8's second edit) sits **upstream** of the shipped V9 byte:

```
raw 0x7B7864  call 0x1407B8370        ; IsActiveForPlaythrough
raw 0x7B7869  test al, al
raw 0x7B786B  jne  0x1407B8472        ; <- V8#2: 75 05 -> eb 05
raw 0x7B786D  add  rsp, 0x28          ; \  early exit, returns al = 0
raw 0x7B7871  ret                     ; /
        ...
raw 0x7B7906  <V9 byte>               ; only reachable via the 0x7B786B branch
```

`CalcShouldTrackFeatProgress` has exactly **one** caller (raw `0x7B8281`), so
every path to the V9 byte passes through `0x7B786B`.

**Consequence — the two designs disagree:**

| Design | Is V8#2 (`0x7B786B`) needed? |
|---|---|
| **V9(A), shipped** | **YES — mandatory.** Restore `75 05` and, when `IsActiveForPlaythrough` returns 0, the function returns 0 at raw `0x7B7871` *before* reaching the V9 byte. The V9 fix becomes unreachable and cold-load feats break again. |
| **V9(B), abandoned** | No — dead code. `0x7B785B` is *before* `0x7B786B`, so the function returns 1 at raw `0x7B785D` and `0x7B786B` is never executed. |

Source, `last log (for now).txt` line 2963:

> "With V9, the 0x7b786b patch becomes semi-redundant (the function would return
> 1 at the end anyway), but keeping it is harmless and consistent. Actually wait
> — … if we patched 0x7b786b back to `75 05`, on cold `IsActiveForPlaythrough`
> returns 0 → early return 0 at `0x1407b8471` → the whole function returns 0
> BEFORE reaching the patched gate. **So we MUST keep the 0x7b786b patch (or the
> gate patch alone is useless).**"

And line 3709, for the abandoned design:

> "0x7b785b is BEFORE 0x7b786b; with je→nop, execution goes 0x7b7854 cmp →
> 0x7b785b nop,nop → 0x7b785d mov al,1 → ret. So 0x7b786b is never reached.
> Keeping the V8 patch there is harmless dead code."

### Practical rule

**Do not "tidy up" V9 by removing either V8 byte.** Specifically:

- Removing `0x7B786B` from the shipped V9(A) is **known-bad by construction**,
  not merely untested. A build of that shape
  (`924a91454e663b0db85378905e70e4b1781b0975e93d9076d235039a61b71fe5`) was
  proposed as an experiment on 2026-08-30 and should **not** be run — the source
  log had already reasoned it out.
- The only shape in which V8#2 is genuinely droppable is the abandoned V9(B),
  which is not the shipped baseline.

## 4. V8's first edit is a resurrection of a banned patch

`BANNED_ARTIFACTS.md` §B1 bans the **"V7 feat-update candidate"**
`0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8`, whose edits
were:

- `0x00666546: 74 0d → 90 90`
- `0x007856e8: 74 0d → 90 90`

**V8's first edit is byte-identical to the first of those** — same offset, same
before/after bytes. The register's condition was "do not resurrect without
reproducible fresh-campaign failure"; that condition was not met, and V8 was
subsequently disproven at runtime (feats 0 in game *and* in the main-menu MJ
tab). The ban is therefore vindicated rather than overturned.

V8's second banned sibling (`0x007856E8`, the RESTORE gate) was **not** carried
into V8 — the trace showed `RESTORE_GATE al=1`, so that gate was never the
blocker (`CK2_MJ_RESEARCH_ARCHIVE_PART5.md` §B2, theory 6).

## 5. Half-preserved finding: the activation-flag writer

From `last log (for now).txt` line 4120:

> "the `0x14080f370` function sets `+0x63 = (ebx == 0x17a36d62)` and `+0x65 = al`.
> This is likely `CFeatTracker::SetPlaythroughId` or similar. It's not the cold
> gate (no direct callers → vtable dispatch). Not needed for V9."

Previously the constant `0x17A36D62` survived in
`CK2_MJ_RESEARCH_ARCHIVE_PART5.md` §B2 (theory 5), but the **function address
`0x14080F370` existed only inside the scratch script
`05_patches_and_scripts/py/disasm18.py`** and in no document. Recorded here so
the address and the finding stay linked:

- `0x14080F370` — writes the singleton's `+0x63` as `(id == 0x17A36D62)` and
  `+0x65` from `al`.
- No direct callers; reached by vtable dispatch, so it cannot be breakpointed by
  address alone.
- **Not** the cold-load gate. Relevant only to the `special_event` /
  playthrough-identity family of theories (§B2 theory 5), which is *not* the
  operative cause of the traced failure.

## 6. Minor: misaligned linear disassembly in the `0x665600` region

`last log (for now).txt` line 1467:

> "Only one 'interesting' instruction found, and it's garbage (`call qword ptr
> [rax+0x388d8d48]` — that's mid-instruction junk from misaligned linear
> disassembly; the region raw `0x665600`+ is likely data or padding, not code)."

Same failure mode as `CONTRADICTIONS.md` §13, where the `DAILY_GATE` breakpoint
was armed `0x1000` off the patched byte and landed on the second byte of a
7-byte `mov`. **Rule: never trust a linear sweep that starts mid-instruction;
confirm the site decodes from a known function prologue.**
