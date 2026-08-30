# V9 — cold-load feat bug root cause and fix (2026-08-30)

## Evidence: the V8 clean trace (`last log/x64dbg logs.txt`)

Cold quit → relaunch → Load/Continue, traced on the confirmed V8 exe
(SHA-256 `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`):

```
[MJ] DAILY_GATE      ... al=80
[MJ] UPDATE_ENTRY    rcx=00007FF7B87B7760 rdx=4 r8=0 r9=0
[MJ] RULER_INFO_CHECK rax=00000222A2B27050 zf=0     <- ruler info OK
[MJ] CALC_RETURN_PATH al=0                          <- final gate said NO
[MJ] CALC_RESULT     al=0
```

Warm resign → load burst: identical prefix, but `CALC_RETURN_PATH al=1` and
`CALC_RESULT al=1`.

Key facts the trace establishes:

- V8 **ran**: `DAILY_GATE` (raw 0x666546 `74 0d`→`90 90`) executed and
  `UPDATE_ENTRY` fired, so the daily caller *did* call `UpdateFeatProgress`
  on the cold path. This is not a BAT-delivery problem.
- `RULER_INFO_CHECK` passed (`rax≠0`, `zf=0`) — the old "ruler-info null"
  theory from the handoff is refuted for this run.
- `CALC_FAIL_PATH` never fired, so the `[+0x65]==0`/`[+0x60]!=0` short-circuits
  were not the cause either.
- The cold `al=0` arrived **only** at `CALC_RETURN_PATH` (raw 0x7b7919,
  VA 0x1407b8519), i.e. the final gate call at raw 0x7b7906
  (`call 0x1400af690`) returned 0 on the cold load and 1 on the warm load.

## The failing gate chain (from static disassembly of the stock exe)

`UpdateFeatProgress` (raw 0x7b8260 / VA 0x1407b8e60) → `call CalcShouldTrackFeatProgress`
(raw 0x7b7850 / VA 0x1407b8450) → checks, in order:

1. global MJ flag `[rip+0xf2ad08]` (VA 0x1416e3163) → if set, return 1.
2. `IsActiveForPlaythrough` raw 0x7b7864 (V8 already bypasses its result at
   raw 0x7b786b).
3. ruler info via vtable `+0xd8`, null check raw 0x7b848d (passed).
4. date helper `0x140e1daf8`, expiry `[rbx+0x20]` (passed).
5. gameState mode bytes `+0x500`/`+0x501` (passed).
6. singleton flags via `0x1400af050`: `[+0x60]==0` and `[+0x65]!=0` (passed).
7. **final gate raw 0x7b7906: `call 0x1400af690`** → `setne al` → ret.
   **This is the only failing point on the cold path.**

## What the final gate `0x1400af690` does (raw 0xaea90 / VA 0x1400af690)

- `[this+0x64]!=0` → return true immediately.
- Global object `[rip+0x1633b3b]` + r8b path → early false (not our path).
- With `dl=1`, call the eligibility loop `0x14072d540` on `global+0x530`
  (or an allocated 0x428-byte object; offset `0xd0`/`0x120` picked by
  `[global+0x581]`). If that returns 0 → gate returns 0.
- Otherwise return true iff `[this+0x61]!=0` **and** `[this+0x63]!=0`.
  (`[this+0x62]` is irrelevant — the "blocked" flag written by the
  `recommended_dlc_list`/`YOUKICKED` matcher at raw 0x767cb3.)

The singleton `0x1400af050` (raw 0xae450) lazily allocates a 0x68-byte object
with defaults `+0x60=0, +0x61=1, +0x62=0, +0x63=1, +0x64=0, +0x65=0`, so the
`+0x61`/`+0x63` condition is satisfied by default. Therefore the cold `al=0`
must come from `0x14072d540` returning 0.

## The eligibility loop `0x14072d540` (raw 0x72c940 / VA 0x14072d540)

Walks `[rcx+0x10 .. 0x18]` (stride 8); each element is a 2-dword key
(`type`, `id`). For each key:

- `0x14072c6c0(global container, type, 0)` — binary search in a sorted
  0x90-stride list (key at `+0x10`), requiring `[elem+0x89]==0` when the
  filter flag is 0.
- `0x14072d010(found, id)` — linear search in a 0x60-stride sub-list.
- Result byte `[+0x58]` (or `[+0x59]` if `[rcx+0x46]!=0`) is ANDed.

Empty vector → true. So the gate passes only if **every** linked entry
resolves and has its `+0x58`/`+0x59` availability flag set. On a cold load at
the moment `UpdateFeatProgress` runs, at least one of those flags is still 0
(feature-availability data not populated yet); by the time of a warm resign it
has been set, so the same call returns 1.

## V9 fix (one length-preserving edit, keeps all V8 behavior)

```
raw 0x007b7906:  e8 85 71 8f ff   (call 0x1400af690)  ->  b0 01 90 90 90
                  (mov al,1; nop; nop; nop)
```

`CalcShouldTrackFeatProgress` now reports "yes, track progress" exactly at the
point the cold trace proved it was rejected. `UpdateFeatProgress` then proceeds
to re-hydrate the in-game feat counter on the cold path.

- V9 SHA-256: `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`
- Files: `ps1/patch_ck2_mj_v9.ps1`, `bat/APPLY_CK2_MJ_V9.bat`,
  `bat/CHECK_CK2_MJ_V9.bat`, `bat/REVERT_CK2_MJ_V9_TO_V8.bat`,
  `x64dbg/MJ_V9_CLEAN_TRACE.txt`, `x64dbg/RUN_MJ_V9_CLEAN_TRACE.bat`,
  `x64dbg/README_MJ_V9_CLEAN_TRACE.md`.

## What to verify in the V9 cold rerun

- `[MJ] V9_GATE_FORCE` fires at `CK2game.exe+7b8506` (the patched site).
- `CALC_RETURN_PATH` now shows `al=1` on the cold load (previously `al=0`).
- `CALC_RESULT` shows `al=1`; in-game feats show the re-hydrated values.

If the feats still read 0, the residual cause is downstream of
`CalcShouldTrackFeatProgress` inside `UpdateFeatProgress` itself — the log must
then include the full `[MJ]` burst plus the executable hash line.

---

## ADDENDUM 2026-08-30 — two corrections to this document

Added during the `last log/` ingest, after re-reading the trace and the trace script
byte by byte. **The V9 conclusion is unchanged**; two supporting claims were wrong.

### 1. The `DAILY_GATE` breakpoint is not at raw `0x666546`

This document says "`DAILY_GATE` (raw 0x666546 `74 0d`→`90 90`) executed". It did not
measure that.

The script arms `bp CK2game.exe+666146`, which is VA `0x140666146` = **raw
`0x665546`** — the second byte of a 7-byte `mov qword ptr [rbp+0x648], rdi`
(VA `0x140666145`) in a *different* function (VA ≈ `0x140665EF8`) that the xref scan
proved does **not** call `UpdateFeatProgress`. The patched `je` is at raw `0x666546`
= `+667146`. It is a `666146`-vs-`667146` typo, off by `0x1000`.

What survives: `UPDATE_ENTRY` fired on the cold path, so `UpdateFeatProgress` *was*
entered — that is what rules out a BAT-delivery problem, and it rests on
`UPDATE_ENTRY` (`CK2game.exe+7b8e60` = VA `0x1407b8e60` = raw `0x7b8260`, the
function entry, correctly placed), not on `DAILY_GATE`. What does not survive: any
claim about which caller entered it, or that the V8 byte at raw `0x666546` was
executed.

### 2. `RESTORE_GATE` also passed, which is a stronger result

This document did not mention `RESTORE_GATE`. The cold burst logs it as
`rip=00007FF7B76662E8 al=1` — the `je` at raw `0x007856E8`, immediately after
`test al,al` on `IsActiveForPlaythrough`. `al=1` means that function returned **true**
during the cold load, and `UPDATE_ENTRY` followed it. That removes the last argument
for patching raw `0x007856E8`, and it is independent confirmation that
`IsActiveForPlaythrough` was not the cold-load blocker.

Both corrections are tracked in `CONTRADICTIONS.md` §13 and in
`RAWLOG_NETNEW_EXTRACTS.md` §11.6. The full corrected trace, all four bursts
verbatim, is in `V9_RUNTIME_RESULTS.md` §3 and in
`01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md` §B1.
