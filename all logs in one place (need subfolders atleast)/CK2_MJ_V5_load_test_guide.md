# CK2 Monarch’s Journey V5 — offline save-loading test

## What V5 changes

V5 keeps every V4 change and adds two narrowly scoped edits in CK2’s saved-game selector:

1. A save must still pass the normal broken-file, version, DLC, and alternate-start checks. If it contains a Featured Ruler identifier, V5 skips only the retired Paradox-account session check.
2. The Load-button tooltip follows the normal save path instead of displaying the obsolete Monarch’s Journey login requirement.

This shared validation path is used by Load and Continue. V5 does **not** edit a save, invent a login, or globally force account status.

Expected V5 executable SHA-256:

`29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`

## Files to keep together

Place these four new files beside the same extensionless `monarchs` payload used for V4:

- `APPLY_CK2_MJ_V5.bat`
- `CHECK_CK2_MJ_V5.bat`
- `REVERT_CK2_MJ_V5.bat`
- `patch_ck2_mj_v5.ps1`
- `monarchs` — reuse the existing V4 payload; do not rename it

## Apply V5

1. Keep the Internet disabled.
2. Exit CK2 completely. Check that no CK2 window remains open.
3. Open:
   `C:\Users\UZWERG\Desktop\SteamCrusader`
4. Find the exact `CK2game.exe` on which V4 was tested.
5. Drag `CK2game.exe` onto `APPLY_CK2_MJ_V5.bat`.
6. Wait for the final green success result. The displayed executable hash should be:
   `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`
7. Do not delete or edit either Kulin save.

The patcher accepts the current verified V4 executable, creates a timestamped backup, keeps the exact verified May original backup, and refuses any executable with unrelated changes.

## First test: use Load Game, not Continue

This test deliberately selects the March 3 save rather than allowing Continue to choose a save automatically.

1. Start this exact file directly:
   `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`
2. Choose **Single Player → Load Game**.
3. Select `Bosnia1173_03_03.ck2`.
4. Confirm that **Load** is now clickable and no longer requires a Paradox login.
5. Click **Load**.
6. When the campaign opens, do **not** unpause and do **not** save over either existing file.
7. Open the Monarch’s Journey challenge panel.
8. Check **Heretical Company** and report exactly which value appears:
   - `1/6` — challenge progress restored from the save; or
   - `0/6` — loading works, but challenge progress needs a separate local-persistence fix.

A screenshot of the challenge panel is enough for this first result.

## If Load is still gray

1. Exit CK2 fully.
2. Drag the same `CK2game.exe` onto `CHECK_CK2_MJ_V5.bat`.
3. Send a screenshot of the complete checker window and of the tooltip shown after selecting `Bosnia1173_03_03.ck2`.

Do not make another test save and do not modify the two existing saves.
