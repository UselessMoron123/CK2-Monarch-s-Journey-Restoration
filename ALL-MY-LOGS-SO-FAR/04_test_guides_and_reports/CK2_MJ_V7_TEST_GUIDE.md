# CK2 Monarch’s Journey V7 — in-game Continue test

V7 does **not** replace V6. It keeps every V6 save-list branch and adds one
length-preserving jump so Continue *execution* no longer demands a live cloud
sync flag.

## What V6 still left broken

After V6, Single Player → Load Game deserialized Bronzeman / Featured Ruler
saves correctly. Clicking **Continue** on the in-game main menu, MJ panel, or
Single Player screen still opened:

```text
Continue failed!

Continuing from the latest save failed. This could be for the following reasons:
* The save is broken
* The save requires DLC that isn't active
…
```

That dialog is generic. The real gate was `0x1409E6700` reading `[rsi+0x63]`
(cloud-sync byte) and, when it is 0 offline, constructing `CContinueFailedPopup`
at `0x140726560`.

## V7 change

| Raw offset | VA | V6 | V7 | Purpose |
|---|---|---|---|---|
| `0x009e5b8b` | `0x1409e678b` | `75 2f` | `eb 2f` | Always take the load-save path instead of the failed-popup path |

Expected V7 executable:

- Size: **24,753,368 bytes**
- SHA-256: `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`

Existing payload (unchanged):

- Path: `<game folder>\gfx\monarchs`
- SHA-256: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`

The Paradox **launcher** Continue button is a different program
(`pdx_launcher.lib` / `launcher-v2.sqlite`). V7 does **not** un-grey it.
Launch `CK2game.exe` directly.

## Apply

1. Keep the Internet disconnected.
2. Close CK2 completely.
3. Put these two files together in one folder:
   - `APPLY_CK2_MJ_V7.bat`
   - `patch_ck2_mj_v7.ps1`
4. Drag your current tested **V6** (or V5) file onto `APPLY_CK2_MJ_V7.bat`:
   - `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`
5. Wait for `V7 CONTINUE FIX PATCH COMPLETE`.
6. The displayed V7 SHA-256 must match the value above.

Do **not** use unguarded one-liners that poke `0x009e5b8b` without a SHA check.
The guarded patcher is the only deliverable.

## First test: in-game Continue

Do not overwrite the Kulin evidence saves.

1. Launch the exact patched `CK2game.exe` directly (not the Paradox launcher).
2. At the main menu click **Continue**.
3. Confirm there is **no** “Continue failed!” popup.
4. Confirm the campaign actually loads (date + character, e.g. Kulin of Bosnia
   `218800` on `Bosnia1173_01_02.ck2`, or whichever latest Bronzeman save you
   have).
5. Optionally repeat from the Monarch’s Journey panel Continue control.

Live proof already on file: `03_analysis/V7_RUNTIME_RESULTS.md` (Kulin load,
`MrHuman` → `218800`).

## What this does **not** test

- Paradox launcher Continue (case **C25**) — still grey; expected.
- Feat-cache identity after a Llywelyn campaign — still open; preflight after
  that session found **no** cache file.

## Revert V7 to V6

Keep `REVERT_CK2_MJ_V7_TO_V6.bat` beside `patch_ck2_mj_v7.ps1`, close CK2, then
drag the V7 executable onto the Revert BAT. It restores exact V6 SHA-256:

`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`

## Check without changing anything

Drag the exe onto `CHECK_CK2_MJ_V7.bat`. It only prints Verify output.
