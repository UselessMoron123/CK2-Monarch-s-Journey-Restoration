# CK2 Monarch’s Journey V6 — save-loading test

## What the uploaded files proved

Both compressed saves are structurally valid and contain real game state:

- `Bosnia1173_03_03.ck2`: internal date **1173.3.3**, `global_heretical_company=1`.
- `Bronzeman_kulin_bosnia.ck2`: internal date **1173.1.1**, `global_heretical_company=1`.

The January 1 campaign displaying 0/6 in the screenshots was therefore not the state stored in either save. CK2 had entered a fresh scenario/setup state instead of deserializing the selected archive.

## What V5 missed

V5 correctly removed the generic save-validity account check, which removed the login tooltip and made the Load control available. However, CK2 duplicates the same Featured Ruler account check inside:

- Continue’s candidate-selection loop; and
- four branches of the save-list selection routine.

Those branches rejected a save record containing `special_event="kulin_bosnia"` before CK2 stored it as the actual file to deserialize. This explains all observed behavior:

- the save row could be selected;
- Load appeared available;
- the selected state was not installed;
- CK2 showed the January 1 historical setup instead;
- Continue failed;
- returning from that failed/fallback state later produced the secondary “Game State is corrupted” UI state.

## V6 changes

V6 keeps V5 and redirects only five already-validated Featured Ruler branches to their normal accepted-save targets. Broken-file, version, DLC, alternate-start, and other ordinary validation checks remain intact. It does not change either save and does not globally fabricate a Paradox account.

Expected V6 executable:

- Size: **24,753,368 bytes**
- SHA-256: `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`

Existing payload:

- Path: `<game folder>\gfx\monarchs`
- SHA-256: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`

## Apply

1. Keep the Internet disconnected.
2. Close CK2 completely.
3. Put these two files together in one folder:
   - `APPLY_CK2_MJ_V6.bat`
   - `patch_ck2_mj_v6.ps1`
4. Drag your current tested V5 file onto `APPLY_CK2_MJ_V6.bat`:
   - `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`
5. Wait for `V6 SAVE-LOADING TEST PATCH COMPLETE`.
6. The displayed V6 SHA-256 must match the value above.

The patcher accepts only the exact V5 or already-patched V6 executable. It creates a timestamped, hash-verified V5 backup before writing.

## First test: manual Load

Do not overwrite either existing save.

1. Launch the exact patched `CK2game.exe` directly.
2. Choose **Single Player → Load Game**.
3. Select `Bosnia1173_03_03.ck2`.
4. Click the normal Load/Play control.
5. Confirm the loaded campaign date at the top right is **3 March 1173**, not 1 January.
6. Open Monarch’s Journey.
7. Confirm **Heretical Company is 1/6**.
8. Exit without saving over the two evidence files.

## Second test: Continue

Only after the manual March load works:

1. Close CK2 fully and start it again.
2. Try the normal Single Player **Continue** control.
3. If that works, restart once more and try the Monarch’s Journey panel’s **Continue** button.

## What to send back

If manual Load succeeds, send one screenshot showing both:

- the date **3 March 1173**; and
- `Heretical Company: 1/6`.

If it fails, send:

- the text from the V6 patch window;
- one screenshot immediately after selecting the March save but before pressing Load/Play;
- one screenshot of the result or error after pressing it.

No additional broad log collection is needed yet. Do not use `wipe_feats`.

## Revert V6 to V5

Keep `REVERT_CK2_MJ_V6_TO_V5.bat` beside `patch_ck2_mj_v6.ps1`, close CK2, then drag the V6 executable onto the Revert BAT. It restores exact V5 SHA-256:

`29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`
