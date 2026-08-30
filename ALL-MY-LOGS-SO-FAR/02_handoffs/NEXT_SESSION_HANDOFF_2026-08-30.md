# Crusader Kings II Monarch's Journey restoration — next-session handoff (2026-08-30)

> **Status banner (2026-08-30):** In-game baseline is **V8** (SHA-256
> `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`). The V8 clean
> trace (`last log/x64dbg logs.txt`) **disambiguated** the open bug: V8 ran and its
> bypasses executed, yet `CalcShouldTrackFeatProgress` still returned 0 on the cold
> path — the remaining failure is the **final feature-eligibility gate** `0x1400af690`
> at raw `0x7b7906`. **V9 is ready** (one length-preserving edit at raw `0x007b7906`,
> `e8 85 71 8f ff` → `b0 01 90 90 90`; SHA-256
> `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`) and needs one
> cold rerun to confirm. This document supersedes the 2026-08-29 handoff for the
> feat-reset question; deep background is in `CK2_MJ_ULTIMATE_HANDOFF.md` (same folder).

## Instructions to the next session (read first)

- The user is **non-technical** and runs everything on Windows by drag-and-drop. Give
  copy-paste instructions, never raw hex work for them to do by hand.
- The facts below are verified against the real binaries and are not guesses. Do **not**
  restart the investigation or re-derive V2–V8.
- This is a **personal restoration** of a retired single-player feature. Do **not**
  redistribute any complete stock or patched `CK2game.exe`; deliver only guarded patch
  scripts that edit the user's own verified executable.
- The user will run tests on their machine and upload results **only when interesting**.
  Be patient; ask for one small thing at a time.
- Do **not** resurrect the banned V6 trampoline (`a6cb92b8…`) or the abandoned feat-V7
  (`0074af70…`). Never run `wipe_feats`. Launch `CK2game.exe` directly (Paradox launcher
  Continue is the separate case C25).

---

## 1. Situation in one paragraph

CK2's retired **Monarch's Journey (MJ)** feature was restored to work offline by
byte-patching Windows **3.3.3 (May 2020)** `CK2game.exe`. A local JSON payload
(`gfx\monarchs`, 11 rulers / 33 challenges) plus a chain of length-preserving patches
**V2 → V8** make the panel, Bronzeman campaigns, live challenge progress, save/load, the
persistent feat cache, and the **in-game Continue** button all work. The single remaining
functional defect was that **feat/challenge progress shows 0 in-game after a cold
quit → relaunch → load**, even though it survives a warm resign. **V9** is now built and
targets the exact gate the clean trace proved was failing; it needs a cold rerun to
confirm.

## 2. Executable identities (all verified, key by SHA never by label)

- Stock: `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`
  (`ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe`,
  24,753,368 bytes, PE32+ x86-64, entry VA `0x140e20c14`).
- V7 (revert target): `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`
- V8: `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`
- **V9: `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`** (new)
- Linux twin: `.../executables/linux/ck2` (stripped ELF64, entry `0x93bdb0`, `.text`
  VA `0x8e1880` offset `0x4e1880`) — cross-build layout reference only, no symbols.
- Address math: **VA = raw offset + `0x140000c00`** (raw = VA − `0x140000c00`).

## 3. The V8 clean trace — what it proved (2026-08-30)

`last log/x64dbg logs.txt` contains three `CLEAN V8 TRACE ARMED` lines and two full
`[MJ]` bursts (warm + cold). Cold burst:

```
[MJ] DAILY_GATE        al=80
[MJ] UPDATE_ENTRY      rcx=00007FF7B87B7760 rdx=4 r8=0 r9=0
[MJ] RULER_INFO_CHECK  rax=00000222A2B27050 zf=0     <- ruler info OK
[MJ] CALC_RETURN_PATH  al=0                          <- final gate said NO
[MJ] CALC_RESULT       al=0
```

Warm burst: identical prefix but `CALC_RETURN_PATH al=1`, `CALC_RESULT al=1`.
`CALC_FAIL_PATH` never fired in either session. Conclusions:

1. **V8 ran.** `UPDATE_ENTRY` fired on the cold path → the daily caller did call
   `UpdateFeatProgress` (V8's raw `0x666546` edit worked). Not a BAT-delivery problem.
2. `RULER_INFO_CHECK` passed → the old "ruler-info null at `0x1407b848d`" theory is
   refuted (handoff §7.1 wrong).
3. `CALC_FAIL_PATH` (raw `0x7b78f8`, the `[+0x65]==0`/`[+0x60]!=0` return) never fired
   → those short-circuits were not the cause.
4. The cold `al=0` arrived **only** at `CALC_RETURN_PATH` (raw `0x7b7919`,
   VA `0x1407b8519`) — i.e. the final gate call raw `0x7b7906`
   (`call 0x1400af690`) returned 0 cold / 1 warm.

## 4. The gate chain (static, from stock exe)

`UpdateFeatProgress` (raw `0x7b8260` / VA `0x1407b8e60`) → first instruction
`call CalcShouldTrackFeatProgress` (raw `0x7b8281`, VA `0x1407b8e81`; the result is
consumed by `test al,al` at `0x1407b8e86` = CALC_RESULT bp, `je` bail to `0x1407b932e`).

`CalcShouldTrackFeatProgress` (raw `0x7b7850` / VA `0x1407b8450`) checks, in order:

1. global flag `[rip+0xf2ad08]` (VA `0x1416e3163`) → if set, return 1 immediately
   (raw `0x7b785d`).
2. `IsActiveForPlaythrough` raw `0x7b7864` (V8 already bypasses the result at
   raw `0x7b786b` `75 05`→`eb 05`).
3. ruler info via vtable `+0xd8`, null check raw `0x7b848d` (passed).
4. date helper `0x140e1daf8`, expiry `[rbx+0x20]` (passed).
5. gameState mode bytes `+0x500`/`+0x501` (passed).
6. singleton flags via `0x1400af050`: `[+0x60]==0` and `[+0x65]!=0` (passed).
7. **final gate raw `0x7b7906`: `call 0x1400af690`** → `setne al` → ret
   (`CALC_RETURN_PATH`). **This is the only failing point on the cold path.**

Exactly two direct callers of `UpdateFeatProgress`: daily-site raw `0x666550`
(VA `0x140667150`, same function as the V8 raw `0x666546` edit) and restore-site raw
`0x7856f2` (VA `0x1407862f2`). Both are gated by `IsActiveForPlaythrough` with a
global-flag bypass (`cmp byte ptr [rip+…],0 / jne`). Both cold-session calls returned 0
→ there is no alternative re-hydration path on cold load.

## 5. Final gate `0x1400af690` (raw `0xaea90`, VA `0x1400af690`) — 13 call sites

- `[this+0x64]!=0` → return true immediately (raw `0xaeab7`).
- Global object `[rip+0x1633b3b]` + r8b path → possible early false (not our path;
  CalcShouldTrack calls with r8d=0, dl=1).
- With `dl=1`, call eligibility loop `0x14072d540` on `global+0x530` (or an allocated
  0x428-byte object; offset `0xd0`/`0x120` chosen by `[global+0x581]`); if it returns 0
  → gate returns 0 (raw `0xaeb7d` → `0x1400af6e1`).
- Then true iff `[this+0x61]!=0` **and** `[this+0x63]!=0` (`+0x62` irrelevant).
- Singleton `0x1400af050` (raw `0xae450`) lazily allocates the 0x68-byte object with
  defaults `+0x60=0, +0x61=1, +0x62=0, +0x63=1, +0x64=0, +0x65=0`, so the
  `+0x61`/`+0x63` condition holds by default → **cold `al=0` must come from
  `0x14072d540` returning 0**.
- The only `[+0x62]=1` write (raw `0x767cb3`, inside function raw `0x767b16` /
  VA `0x140768716` that matches `recommended_dlc_list`, `YOUKICKED`, `ld`) is the
  achievement-block/anti-cheat flag, NOT the cold gate; init leaves `+0x62=0` (allowed).

## 6. Eligibility loop `0x14072d540` (raw `0x72c940`, VA `0x14072d540`)

All-entries-visible loop: walks `[rcx+0x10..0x18]` (stride 8); each element is a
2-dword key. For each: `0x14072c6c0(type, 0)` = binary search in a sorted 0x90-stride
list (key at `+0x10`, requires `[elem+0x89]==0` when filter flag 0), then
`0x14072d010(id)` = linear search in a 0x60-stride sub-list; ANDs result byte `[+0x58]`
(or `[+0x59]` if `[rcx+0x46]!=0`). Empty vector → true. Cold failure = a linked entry's
flag byte is 0 at that moment (feature-availability data not populated yet).

## 7. V9 fix and test

**Patch (V9, length-preserving, keeps all V8 behavior):**

```
raw 0x007b7906:  e8 85 71 8f ff   (call 0x1400af690)  ->  b0 01 90 90 90
                  (mov al,1; nop; nop; nop)
```

Files (already written, verified hashes):
`ps1/patch_ck2_mj_v9.ps1`, `bat/APPLY_CK2_MJ_V9.bat`, `bat/CHECK_CK2_MJ_V9.bat`,
`bat/REVERT_CK2_MJ_V9_TO_V8.bat`, `x64dbg/MJ_V9_CLEAN_TRACE.txt`,
`x64dbg/RUN_MJ_V9_CLEAN_TRACE.bat`, `x64dbg/README_MJ_V9_CLEAN_TRACE.md`.
Analysis doc: `03_analysis/V9_COLD_LOAD_FEATS_FIX.md`.

**Next user step (one thing only):** apply V9 (drag `APPLY_CK2_MJ_V9.bat` onto the
current V8 exe; the bat verifies the V8 hash first), then do the exact cold repro
(quit → relaunch → Load/Continue → check feats). Expected: feats show values on the
cold load. If they still show 0, run the V9 clean trace and send the `[MJ]` burst:
`V9_GATE_FORCE` (raw `0x7b8506`) must fire and `CALC_RETURN_PATH` must show `al=1`.

## 8. What to ask for next session

- The V9 `APPLY` result lines (state detected, bytes set, final SHA) and the in-game
  outcome after the cold repro.
- If feats still 0: the `[MJ]` burst from `MJ_V9_CLEAN_TRACE.txt` plus whether the
  failure is "0 immediately" vs "0 after one in-game day".
- If V9 works: run `REVERT_CK2_MJ_V9_TO_V8.bat`? No — keep V9; log it as the new
  baseline and update STATUS.md. Also optionally verify the feat cache file
  (`cache/q847rsja8ndx`) values after the cold load.

## 9. Suggested first message to paste into the next session

> Continuing the CK2 Monarch's Journey restoration. Baseline is now V8
> `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93` with the cold-load
> bug root-caused: the V8 clean trace proved all gates except the final eligibility gate
> `0x1400af690` (raw `0x7b7906`) pass on the cold path. V9 (raw `0x007b7906`
> `e8 85 71 8f ff`→`b0 01 90 90 90`, SHA
> `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`) is built and the
> user was asked to apply it and redo the cold quit→relaunch→load test. Awaiting the V9
> apply result and the in-game outcome (feats 0 vs values). Never run wipe_feats; launch
> CK2game.exe directly; test offline.
