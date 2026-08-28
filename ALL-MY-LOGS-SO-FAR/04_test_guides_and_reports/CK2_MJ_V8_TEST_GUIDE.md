# CK2 Monarch’s Journey V8 — cold-launch feat re-hydration test

V8 does **not** replace V7. It keeps every V7 Continue fix and adds two
length-preserving edits so the in-game feat/challenge counter repopulates from
the save after a **cold launch → Load/Continue** (the one path that still showed
0).

## What V7 still left broken

After V7, a Bronzeman save loaded fine, but feats showed **0** in-game when the
game was quit to desktop and relaunched first. The same load right after an
in-session **resign** showed feats correctly (the process was still warm). Main
menu showed the correct cached feats in both cases.

Root cause (disassembled from the Linux 3.3.3 twin, same May-3.3.3 code):

- The visible in-game counter lives on `CRulerFeatTracker` and is filled only by
  `UpdateFeatProgress()`, which reads the save’s `global_*` variables.
- That call is gated **twice** by `IsActiveForPlaythrough()`:
  1. `CGameState::DailyUpdate` skips `UpdateFeatProgress()` if it returns false;
  2. `CalcShouldTrackFeatProgress()` (inside `UpdateFeatProgress`) bails if it
     returns false.
- `IsActiveForPlaythrough()` requires the current game’s featured-ruler key
  (`[gameState+0x598]`) to match a ruler in the payload. A fresh campaign sets
  this via the frontend; a warm resign keeps it; a **cold load** does not
  re-establish it, so both gates fail and feats stay 0.

The main menu is unaffected because it reads the local cache (`cache/q847rsja8ndx`),
which is written correctly (preflight confirmed `established=2`, `conquerer_from_bribir=1`,
`user_id=84696387` stable).

## V8 change (two length-preserving edits, no code injection)

| Raw offset | VA | V7 | V8 | Purpose |
|---|---|---|---|---|
| `0x00666546` | `0x140667146` | `74 0d` | `90 90` | daily update always calls `UpdateFeatProgress` |
| `0x007b786b` | `0x1407b846b` | `75 05` | `eb 05` | `UpdateFeatProgress` ignores the `IsActiveForPlaythrough` gate |

Downstream safety is preserved: `CalcShouldTrackFeatProgress()` still requires
Bronzeman/Ironman mode bytes (`+0x500/+0x501`), a non-expired ruler, and the
achievement-eligibility helper — so a normal (non-Bronzeman) game still never
tracks feats.

Expected V8 executable:

- Size: **24,753,368 bytes**
- SHA-256: `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`

Expected payload (unchanged): `gfx\monarchs` =
`fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`.

## Apply

1. Keep the Internet disconnected.
2. Close CK2 completely.
3. Put `APPLY_CK2_MJ_V8.bat` and `patch_ck2_mj_v8.ps1` together in one folder.
4. Drag your current tested **V7** file onto `APPLY_CK2_MJ_V8.bat`:
   `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`
5. Wait for `V8 FEAT-REHYDRATION PATCH COMPLETE`.
6. The displayed V8 SHA-256 must match the value above.

## Test (console is disabled in Bronzeman — this is a GUI-only test)

1. Launch the exact patched `CK2game.exe` directly.
2. Load (or Continue) the Pavao save (`Croatia1278_01_01.ck2` / `Bronzeman_pavao_croatia.ck2`).
3. **Record the in-game challenge counters now** (expected: 0, unchanged — this
   is the pre-fix symptom; the next steps are what matter).
4. Quit **completely** to desktop.
5. Relaunch, Load/Continue the same save.
6. Check the in-game feats again. They should now show the saved values
   (e.g. `established` and `conquerer_from_bribir` matching the save’s
   `global_*`), not 0.

A useful cross-check: run `RUN_PREFLIGHT.bat` before and after and compare the
cache `NON-ZERO FEATS` line — the values should not regress.

## If it does not fix it

- Confirm the file is actually V8 with `CHECK_CK2_MJ_V8.bat` (must say V8).
- Note whether feats are 0 **immediately after load** or **also after a full
  in-game day** (the daily update runs once per day).
- Note whether the ruler is still shown with the MJ panel/crown in-game.
- Send a screenshot of the in-game challenges tab plus the preflight output.

## Revert

Drag the V8 file onto `REVERT_CK2_MJ_V8_TO_V7.bat` to restore exact V7
(`57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`).
