# CK2 Monarch’s Journey — Windows v4 test candidate

## Status

V4 is a **new runtime-test candidate**, not yet a proven final patch. V3 proved that the local ruler payload, challenge rows, Play button, and historical Game Rules route work, but Game Rules still reported **Challenges: Disabled** and blocked Start.

V4 addresses that specific state and the in-game progress predicate. It does **not** merely force the final Start button.

## What was traced

The Monarch Play event already sets the real Bronzeman request flag. The remaining challenge predicate then required all of the following:

1. Bronzeman/Ironman challenge context;
2. game rules that permit challenges;
3. a valid save state;
4. no Ruler Designer;
5. stock checksum/no user modification;
6. Steam active.

The retired/offline environment fails the last two conditions. The same Steam/checksum eligibility is also called from the in-game feat-progress tracker.

V4 keeps the mode, game-rule, save, Ruler Designer, ruler, expiry, and in-game tracking checks. It changes the shared final eligibility expression so the checksum is ignored **only while Steam is inactive**, and bypasses the Steam-active branch only at five challenge-specific call sites. Normal Ironman/achievement Steam branches are not patched.

V4 also undoes V3’s exposure of the empty reward controls. The local ruler snapshot has feats and localisation but no retired account reward catalogue, so V4 hides both the unpopulated reward area and the obsolete login message instead of displaying `UI Missing Text`.

## Files to keep together

- `APPLY_CK2_MJ_V4.bat`
- `patch_ck2_mj_v4.ps1`
- `monarchs` — no filename extension

Optional helpers:

- `CHECK_CK2_MJ_V4.bat`
- `REVERT_CK2_MJ_V4.bat`

Do not use the old V3 installer for this test.

## Apply — beginner steps

1. Close Crusader Kings II completely.
2. Put the three required V4 files listed above in one ordinary folder.
3. Open:
   `C:\Users\UZWERG\Desktop\SteamCrusader`
4. Drag the current `CK2game.exe` onto `APPLY_CK2_MJ_V4.bat`.
5. Wait for the black window to report:
   `V4 TEST PATCH AND PAYLOAD INSTALLATION COMPLETE`
6. The executable SHA-256 shown must be:
   `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30`
7. The payload SHA-256 shown must be:
   `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`
8. Start that exact `CK2game.exe` directly.

The installer accepts the exact V3 executable and safely upgrades it. It creates both a timestamped backup of the current state and a fixed hash-verified original backup.

## Short runtime test

Do not spend hours on this test yet.

1. Open Monarch’s Journey and choose a ruler.
2. Confirm the three challenge rows still contain real names and descriptions.
3. Click **Play**.
4. On Game Rules, check:
   - **Bronzeman Mode: Enabled**;
   - **Challenges: Enabled**;
   - **Start Game** is clickable.
5. Start the campaign.
6. After loading, unpause for several in-game days. If no progress numbers appear yet, let one in-game month pass.
7. Pause and open the Monarch’s Journey/feat panel. Confirm the selected ruler and all three challenge rows appear in-game with progress values.
8. Make a manual save named `MJ_V4_TEST`.
9. Quit to the main menu, use **Continue**, and confirm the same campaign loads with its challenge panel/progress intact.

The requirement list may still draw red marks beside the real Steam and checksum rows. That is intentional and honest: V4 bypasses those retired/offline requirements for Monarch tracking without falsifying the displayed platform state. The important results are **Challenges: Enabled**, a working Start button, and populated in-game progress.

## What to report

Please provide only these small items:

1. the text shown in the patch window;
2. one screenshot of Game Rules before Start;
3. one screenshot of the in-game challenge panel after several days or one month;
4. if Start or progress fails: `game.log`, `system.log`, `error.log`, and `text.log` from that run.

Also say whether save → main menu → Continue preserved the challenge panel.

## Revert

1. Close the game.
2. Drag the patched `CK2game.exe` onto `REVERT_CK2_MJ_V4.bat`.
3. It must report the exact original SHA-256:
   `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`

`gfx\monarchs` is inert with the original executable and may be left in place.

## Verified hashes

- Exact May original EXE: `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`
- V3 EXE accepted for upgrade: `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca`
- V4 runtime-proven EXE: `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30`
- Payload: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`
