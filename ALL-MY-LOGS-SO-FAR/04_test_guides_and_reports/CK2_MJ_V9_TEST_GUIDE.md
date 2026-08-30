# CK2 Monarch's Journey V9 — cold-load feat fix (TESTED & PASSING)

**Status 2026-08-30: applied on the user's machine and confirmed working.**
Feats are present after a full quit → relaunch → load, they survive both a soft
(resign) and a hard (quit-to-desktop) exit, and they increase when you do the
right thing. This guide is kept for the record, for re-applying on a fresh
machine, and for reverting.

---

## 1. What V9 fixes

After V8, one thing was still broken:

> quit to desktop → relaunch → Load/Continue → **all feat counters read 0**, and
> they never advanced again in that session.

The same load right after an in-session **resign** was fine (warm process).

V8 tried to fix this by bypassing the two `IsActiveForPlaythrough` gates. It did
**not** work — it made the main-menu MJ tab go to 0 as well. See
`03_analysis/V9_RUNTIME_RESULTS.md` §2.

A controlled x64dbg trace then proved where the real block is. On a cold load every
check inside `CalcShouldTrackFeatProgress()` passes — ruler info is non-null, the
date is valid, the game-mode bytes are set, the singleton flags are fine — **except
the very last one**:

| Raw offset | VA | Instruction | Cold | Warm |
|---|---|---|---|---|
| `0x007b7906` | `0x1407b8506` | `call 0x1400af690` (final eligibility check) | returns **0** | returns **1** |

That call is the "are all the linked feature entries visible/available right now"
check. On a cold load the feature entries' availability flags are not populated yet,
so it says no, and the whole tracker bails. A warm session has them set.

## 2. The V9 change

One extra length-preserving edit on top of V8 — no code injection, no size change:

| Raw offset | VA | Before | After | Meaning |
|---|---|---|---|---|
| `0x007b7906` | `0x1407b8506` | `e8 85 71 8f ff` | `b0 01 90 90 90` | `mov al,1; nop; nop; nop` — the final gate always says yes |

Everything from V2 through V8 is kept. Full V9 patch list:
`03_analysis/WINDOWS_333_PATCH_MAP.md`.

**Expected executable**

| | |
|---|---|
| Size | `24,753,368` bytes (unchanged) |
| SHA-256 | `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687` |
| Accepts as input | V7 `57b18e43…` **or** V8 `94d6fb40…` |
| Payload beside the exe | `gfx\monarchs`, SHA-256 `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` |

## 3. Applying it — pick ONE route

**Close Crusader Kings II completely first**, whichever route you use.

### Route A — easiest: paste into PowerShell

1. Press the Start button, type `powershell`, press Enter.
2. Open `05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` in Notepad.
3. Copy everything from the line `function Invoke-MJV9 {` down to the last line
   `Invoke-MJV9 'C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe'`.
4. Right-click in the PowerShell window to paste, press **Enter**.
5. Wait for `RESULT: V9 PATCH APPLIED AND VERIFIED` and `SHA-256: 61e4345b…`.

If your game is installed somewhere else, change the path in that last line before
pasting. The command backs up your game first
(`CK2game.exe.before_v9_<date>_<time>.bak` next to it) and refuses to touch anything
that is not exactly V7 or V8.

### Route B — the guarded patcher

```powershell
cd C:\Users\UZWERG\Desktop\ck2check
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Verify "C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe"
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Apply  "C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe"
```

`Verify` must print `State: v7` or `State: v8` before you run `Apply`.

### Route C — double-click the `.bat` files

`05_patches_and_scripts/bat/` → `CHECK_CK2_MJ_V9.bat`, then
`APPLY_CK2_MJ_V9.bat`. Only use these if the window stays open and shows a result;
the older V8 `.bat` had a cmd.exe bug that closed the window silently
(`03_analysis/RAWLOG_NETNEW_EXTRACTS.md` §11.4). If the window vanishes, use Route A.

## 4. The test that matters

1. Launch **`CK2game.exe` directly** (not the Paradox launcher — launcher Continue is
   still broken, case **C25**).
2. Load an existing Bronzeman Pavao/Croatia save.
3. Open the challenges tab. **Expect:** counters show the values from the save, not 0.
4. Press Esc → **Resign** → load the same save again. **Expect:** still correct.
5. **Quit to desktop.** Relaunch `CK2game.exe`, load the save again.
   **Expect: still correct — this is the step that used to fail.**
6. Do something that scores (e.g. get a fourth dynasty member landed).
   **Expect:** the counter goes up.
7. Repeat step 5 once more. **Expect:** the increase is still there.

Steps 5 and 6 are the two that V8 could not pass.

## 5. Reverting

```powershell
cd C:\Users\UZWERG\Desktop\ck2check
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Revert "C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe"
```

That returns you to **V8** `94d6fb40…`. Because V8's premise was disproven, the more
useful revert target is **V7** `57b18e43…` (restore the `.before_v9_*.bak` backup, or
run `REVERT_CK2_MJ_V8_TO_V7.bat`). Ladder:
V9 `61e4345b…` → V8 `94d6fb40…` → V7 `57b18e43…` → V6 `f5b7dfd6…` →
V5 `29556549…` → stock `656f4f48…`.

## 6. Things that are NOT bugs on V9

- **The medal stays Bronze when you load an older save or restart the campaign, and
  "Word has spread far and wide…" does not fire again.** By design. The medal shows
  your best-ever result, stored in `cache\q847rsja8ndx` for your whole Windows
  profile, not per save. Full explanation and the optional reset experiment:
  `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`.
- `Kernel Debug[fixedwindow.cpp:1246] … nonexistant subwindow ruler /
  start_notification`, `Failed to find text key NUM / LIST / MAX / …`,
  `[S_API FAIL] SteamAPI_Init() failed`, `character.cpp:1624 … Deleting playerdata
  for char #470001` — all normal offline noise.

## 7. Never do

- Never run `wipe_feats` or any console command that clears the feat cache.
- Never redistribute a complete stock or patched `CK2game.exe`; share the guarded
  patchers only.
- Never launch through the Paradox launcher when testing Continue.
- Never resurrect trampoline-V6 `a6cb92b8…` or feat-V7 `0074af70…`.
- Test offline.

## 8. Optional: the belt-and-braces trace

If you ever want machine proof rather than in-game observation, use
`05_patches_and_scripts/x64dbg/MJ_V9_CLEAN_TRACE.txt` with
`RUN_MJ_V9_CLEAN_TRACE.bat` (attach mode, logging breakpoints, no pauses). You want
to see `V9_GATE_FORCE` at `CK2game.exe+7b8506` and `CALC_RETURN_PATH al=1` on a cold
load.

⚠️ Known defect in that script: its `DAILY_GATE` breakpoint is armed at
`CK2game.exe+666146` where it should be `+667146` — a typo carried over from the V8
script. It is harmless for the V9 check (all the lines that matter are inside
`UpdateFeatProgress` / `CalcShouldTrackFeatProgress`) but it must not be used to
prove anything about the byte at raw `0x00666546`. Tracked in
`03_analysis/CONTRADICTIONS.md` §13. Fixing it changes the file, so re-publish its
SHA-256 in `README_MJ_V9_CLEAN_TRACE.md` at the same time.
