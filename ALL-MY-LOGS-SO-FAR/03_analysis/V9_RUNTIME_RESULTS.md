# V8 & V9 Runtime Results — the cold-load feat defect, closed

Date: 2026-08-30. Sources: `last log/one more raw log.txt` (V8 applied by hand),
`last log/x64dbg logs.txt` (the decisive V8 clean trace),
`last log/last log (for now).txt` (disassembly + V9 build), and the user's V9
playtest verdict. Full narrative: `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md`.

---

## 1. Executive summary

- **Problem (Case C07/C08 family):** after quitting to desktop and relaunching, all
  feat counters read **0** in game, and challenge progress never advanced again in
  that session.
- **V8 hypothesis:** the two `IsActiveForPlaythrough` gates (raw `0x00666546`,
  raw `0x007B786B`) were the block. **Disproven** — see §2.
- **Actual cause:** `CalcShouldTrackFeatProgress` fails at its **final** gate,
  raw `0x007B7906` (VA `0x1407B8506`), `call 0x1400AF690`. Every earlier check passes
  on a cold load; that call returns 0.
- **V9 fix:** replace the 5-byte call with `mov al,1; nop; nop; nop`
  (`E8 85 71 8F FF` → `B0 01 90 90 90`), length-preserving.
- **Result:** ✅ **works.** Feats are present after a cold quit → relaunch → load,
  they do not reset on soft or hard quit, and they increase when the player does the
  right thing.
- **Residual (not a defect):** the medal stays Bronze on earlier saves and the
  "Word has spread far and wide…" popup does not repeat. Explained in
  `FEAT_CACHE_PEAK_TIER_ICON.md`.

**V9 = current baseline.** SHA-256
`61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`,
24,753,368 bytes.

---

## 2. V8: applied for real, and it made things worse

User applied V8 by hand from PowerShell on 2026-08-29:

```text
Verify → State: v7 / SHA-256: 57b18e43… / RESULT: V7 BASELINE DETECTED; READY TO APPLY V8
Apply  → backup CK2game.exe.before_mj_v8_from_v7_20260829_132333.bak
         Set 0x00666546: 74 0d -> 90 90
         Set 0x007b786b: 75 05 -> eb 05
         RESULT: V8 FEAT-REHYDRATION PATCH APPLIED AND VERIFIED
         SHA-256: 94d6fb40…
```

User verdict, verbatim:

> *"tried. feats are 0 in game, and even in main menu (in MJ tab) too now"*

and after reverting:

> *"it picks up feats from game previously loaded. but when i do something that
> should give scores in them, it stays in place."*

Three things died with V8:

1. "the two gates are the cold-load block" — with both bypassed the cold path still
   returned 0;
2. "the cache is fine and only the in-game vector is empty" — the main-menu MJ tab
   went to 0 as well;
3. "load-hydration and live evaluation are the same code path" — the second quote
   shows a warm load restoring values while live progress stays frozen.

What V8 did **not** do: it did not erase the disk cache and it did not damage the
saves. The user's own paste of `cache/q847rsja8ndx` **taken after** the failed V8 run
still read `conquerer_from_bribir=1` / `established=4` (`user_id=1179784490`), and all
ten saves still carried their `global_*` values. Reverting to V7 restored the previous
behaviour.

> ⚠️ The chat written at the time claimed V8 "calculated 0 progress for all 33
> challenges and pushed those 0s into the local feat cache … **wiping out** the
> main-menu display". That is **refuted by the very paste quoted two paragraphs
> later** — the cache still held `established=4`. The corrected wording used in the
> same session is the right one: V8 pushed zeroes **to the display**, not to the
> cache. Do not restate the "cache was wiped" version.
>
> The same chat also attributed the whole defect to `special_event` being blank at
> `gameState+0x598` on a cold launch. The V8 clean trace later weakened that: the
> ruler-info check passed (`rax=00000222A2B27050`, `zf=0`) and
> `IsActiveForPlaythrough` returned true at the restore caller. It remains a plausible
> description of *why the display* went blank under V8, but it is not what the trace
> measured.

---

## 3. What the clean trace showed

`MJ_V8_CLEAN_TRACE.txt` armed seven logging breakpoints (no pauses) on an
attach-mode x64dbg session against the V8 exe and cleared the stale Continue
breakpoints first. Base address `0x7FF7B6EE0000` (reproduced from all six
`rip − offset` pairs). Four `[MJ]` bursts were logged — two warm, two cold:

```text
warm  DAILY_GATE rip=00007FF7B7546146 rax=0000022301DD6DA0 al=A0 zf=0 tf=1
      UPDATE_ENTRY rip=00007FF7B7698E60 rcx=00007FF7B87B7760 rdx=0000000000000004
      RULER_INFO_CHECK rip=00007FF7B769848D rax=00000222A2B27050 zf=0
      CALC_RETURN_PATH rip=00007FF7B7698519 al=1 zf=0
      CALC_RESULT      rip=00007FF7B7698E86 al=1 zf=0
warm  RESTORE_GATE rip=00007FF7B76662E8 al=1 zf=0 tf=1  → same four lines, al=1
cold  DAILY_GATE rip=00007FF7B7546146 rax=00000222E758CF80 al=80 zf=0 tf=1
      UPDATE_ENTRY … rcx=00007FF7B87B7760 rdx=4
      RULER_INFO_CHECK rax=00000222A2B27050 zf=0
      CALC_RETURN_PATH al=0 zf=0
      CALC_RESULT      al=0 zf=0
cold  RESTORE_GATE rip=00007FF7B76662E8 al=1 zf=0 tf=1  → same four lines, al=0
```

`Total loadtime was 779.015 seconds` separates the warm and cold sets.

Read the trace carefully — it eliminates four suspects at once:

| Suspect | Trace says |
|---|---|
| `UpdateFeatProgress` is never called on cold load | ❌ `UPDATE_ENTRY` fired, twice per burst set |
| Ruler info is null after a cold load (`0x1407B848D`) | ❌ `rax=00000222A2B27050`, `zf=0` — the *same* non-null pointer warm and cold |
| The singleton check `[+0x60]==0 && [+0x65]!=0` rejects tracking | ❌ `CALC_FAIL_PATH` (raw `0x7B78F8`) never fired in any burst |
| The restore caller's `IsActiveForPlaythrough` gate (raw `0x007856E8`) blocks the update | ❌ `RESTORE_GATE al=1` on the cold burst — the gate returned **true** and the call happened |

Everything that survives is one line: `CALC_RETURN_PATH al=0`. That breakpoint is
immediately after `setne al` on the return of `call 0x1400AF690`, so the call itself
returned 0. Warm, the identical path returns 1.

### 3.1 Caveat that must travel with this trace

The `DAILY_GATE` breakpoint is armed at `CK2game.exe+666146`, which is raw
`0x665546` — **not** the patched `je` at raw `0x666546` (`+667146`). The script has a
`666146`-vs-`667146` typo. Raw `0x665546` is the second byte of a 7-byte
`mov qword ptr [rbp+0x648], rdi` inside a different function (VA ≈ `0x140665EF8`)
that does **not** call `UpdateFeatProgress`. So:

- the logged `al=A0` / `al=80` are pointer bytes, not a flag;
- the trace proves `UpdateFeatProgress` was entered, but **not** by which caller;
- it does **not** prove the V8 byte at raw `0x666546` was ever executed.

This does not weaken the V9 conclusion (the four lines that matter are all inside
`UpdateFeatProgress` / `CalcShouldTrackFeatProgress`). It is recorded in
`CONTRADICTIONS.md` §13. The helper carried the typo when this trace was captured;
the canonical `MJ_V9_CLEAN_TRACE.txt` was corrected and re-hashed on 2026-08-31.

---

## 4. The failing gate chain (stock-exe disassembly)

`VA = raw + 0x140000C00`.

```text
UpdateFeatProgress  raw 0x7B8260 / VA 0x1407B8E60
  raw 0x7B8281  call CalcShouldTrackFeatProgress
  VA 0x1407B8E86  test al, al   ← CALC_RESULT
  je 0x1407B932E                ; bail

CalcShouldTrackFeatProgress  raw 0x7B7850 / VA 0x1407B8450
  1  [rip+0xF2AD08] global MJ flag   → if set, return 1     (raw 0x7B785D)
  2  raw 0x7B7864 call IsActiveForPlaythrough
     raw 0x7B786B 75 05  jne 0x1407B8472   ← V8: EB 05 (always proceed)
  3  VA 0x1407B848D ruler info, null check                    ← RULER_INFO_CHECK (passes)
  4  date helper 0x140E1DAF8 + expiry [rbx+0x20]
  5  gameState mode bytes +0x500 / +0x501 (Bronzeman/Ironman)
  6  singleton 0x1400AF050: [+0x60]==0 && [+0x65]!=0
     raw 0x7B78F8 return 0                                  ← CALC_FAIL_PATH (never fired)
  7  raw 0x7B7906 (VA 0x1407B8506)  call 0x1400AF690  ← V9 REPLACES THIS
     setne al ; ret  (VA 0x1407B8519)                       ← CALC_RETURN_PATH
```

`0x1400AF690` (raw `0xAEA90`) returns true immediately if `[this+0x64]!=0`
(no writer found; init leaves it 0); otherwise, with `dl=1`, it calls the eligibility
loop `0x14072D540` on `global+0x530` and returns 0 if that returns 0
(raw `0xAEB7D`); otherwise it falls through to its tail at raw `0x000AEB83`.

### 4.1 That tail was already rewritten by V4 — and it was not the failure

This was found during the 2026-08-30 ingest by cross-reading `WINDOWS_333_PATCH_MAP.md`
against the disassembly, then verifying both with objdump and with
`build_v9_chain.py`. It is recorded here because it sharpens the root cause.

Raw `0x000AEB83` (VA `0x1400AF783`) sits **0xF3 bytes inside the function V9
bypasses**, and V4 replaced its 24 bytes. Verified across the replayed chain: the tail
is stock in stock/V2/V3 and V4-rewritten in V4, V5, V6, V7, V8 **and V9**.

| | Tail condition |
|---|---|
| stock | non-zero iff `+0x61!=0 && +0x63!=0 && +0x62==0` |
| V4 → V9 | 1 iff `word[+0x61]==1` (so `+0x61==1` **and** `+0x62==0`) **and** (`+0x63!=0` **or** `+0x65==0`) |

Full decode of both variants is in
`01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md` §C2.

Why this matters: in the traced V8 image the tail is the V4 version, and with the
singleton at its defaults (`+0x61=1, +0x62=0, +0x63=1, +0x65=0`) that condition is
**satisfied** — `CALC_FAIL_PATH` never firing implies `+0x65==0`, which alone satisfies
the OR. So the tail would have returned 1, and the cold `al=0` cannot have come from
it. It came from the earlier `0x14072D540` feature-list walk returning 0 — exactly the
"linked feature entries are not available yet on a cold load" mechanism.

That is why V9 replaces the **call** rather than any flag: it is immune to both
sub-causes, and it does not need to know which one fired.

⚠️ Two inputs to that inference are taken from the V9 session's disassembly and were
**not** independently re-verified in this ingest: the singleton's default values, and
the polarity of the `CALC_FAIL_PATH` test. Both are consistent with the trace.

---

## 5. V9

**One edit, on top of V8:**

| Raw offset | VA | Before | After | Effect |
|---|---|---|---|---|
| `0x007B7906` | `0x1407B8506` | `E8 85 71 8F FF` (`call 0x1400AF690`) | `B0 01 90 90 90` (`mov al,1; nop; nop; nop`) | the final gate always passes |

Verification of the "before" bytes (independently recomputed):
`rel32 = 0x1400AF690 − (0x1407B8506 + 5) = 0xFF8F7185` → little-endian
`85 71 8F FF`, opcode `E8` → `E8 85 71 8F FF`. Exact match. 5 bytes → 5 bytes.

**Full V9 patch map (8 sites):** V2/V4/V5 payload + save-list branches, V6's five
`74 0d→90 90` / equivalent flips, V7 `0x009E5B8B` `75 2f→eb 2f`, V8 `0x00666546`
`74 0d→90 90` and `0x007B786B` `75 05→eb 05`, plus V9 `0x007B7906`. The authoritative
list is `WINDOWS_333_PATCH_MAP.md` / `windows333_patch_map.csv`; the V8/V9 rows were
added on 2026-08-30.

**Chain replay.** `05_patches_and_scripts/py/build_v9_chain.py` starts from the stock
exe (`656f4f48…`, hash re-verified this pass), replays V2→V8 from the patcher
sources asserting every documented intermediate hash, then applies V9 and prints
`61e4345b…`. The V9 hash is therefore derived, not asserted.

**Why not patch raw `0x007856E8` too?** It was considered as belt-and-braces so the
restore path would also call `UpdateFeatProgress` unconditionally. The trace showed
`RESTORE_GATE al=1` on cold, i.e. it already does. Left alone deliberately.

---

## 6. Runtime verdict (2026-08-30, user playtest)

| Check | Result |
|---|---|
| Feats present after cold quit → relaunch → load | ✅ |
| Feats present in the main-menu MJ tab | ✅ |
| Survive soft quit (resign) | ✅ |
| Survive hard quit (quit to desktop) | ✅ |
| Increase when the player does the right thing | ✅ |
| Medal tier on an older / restarted save | 🟡 shows the account-wide peak — by design, see `FEAT_CACHE_PEAK_TIER_ICON.md` |

User's words: *"the result of v9 — it works, feats are present, don't reset after
soft or hard quiting. they go up if i do the right thing."*

---

## 7. What is left

1. **Optional** confirmatory trace: `MJ_V9_CLEAN_TRACE` should log
   `V9_GATE_FORCE` at `CK2game.exe+7B8506` and `CALC_RETURN_PATH al=1` on a cold load.
   The playtest already settles the functional question.
2. ~~Fix the `DAILY_GATE` typo (`+666146` → `+667146`) and re-publish its hash.~~
   **Done 2026-08-31:** corrected helper SHA-256 `9bd5fc652eae425b3becd5508a806203c2ef2ab8d150f46a09ee16da58a24bfa`;
   see `CONTRADICTIONS.md` §13.
3. `user_id` instability: four distinct values for one logical cache
   (`CONTRADICTIONS.md` §12).
4. A cleaner-than-V9 fix would require identifying `0x17A36D62` and the vtable that
   reaches `0x14080F370` (`RAWLOG_NETNEW_EXTRACTS.md` §11.1). Not needed for play.
5. Unchanged backlog: C25 launcher Continue, C09–C13, C17, Featured Rulers,
   reward gallery, five missing rulers.

**Revert ladder:** V9 `61e4345b…` → V8 `94d6fb40…` → V7 `57b18e43…` → V6
`f5b7dfd6…` → V5 `29556549…` → stock `656f4f48…`. Never trampoline-V6
`a6cb92b8…`; never feat-V7 `0074af70…`; never `wipe_feats`.
