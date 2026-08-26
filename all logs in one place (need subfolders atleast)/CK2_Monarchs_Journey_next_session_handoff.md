# CK2 Monarch’s Journey restoration — current handoff

## Read this first

Continue from these results; do not restart the investigation or ask the user to repeat old tests. **V4 is runtime-proven to start a Bronzeman Monarch campaign and track live challenge progress, and both written saves are structurally valid. A fresh, fully offline process proved that the remaining blocker is the generic saved-game selector's Featured Ruler account check: both saves can be selected, but Load and Continue are disabled with the explicit retired Paradox-login requirement. V5 has now been built to bypass only that final account check after all ordinary save-validity and DLC checks pass.** The first V5 runtime load of `Bosnia1173_03_03.ck2` is pending. Reward UI remains a separate later layer.

This work is for personal restoration of the retired Crusader Kings II Monarch’s Journey mode on the exact pre-removal May 2020 Windows 3.3.3 build, without its retired backend.

## User constraints

- The user is on Windows and is not comfortable with technical PC details. Give literal beginner-level steps.
- Verified test game root: `C:\Users\UZWERG\Desktop\SteamCrusader`.
- Exact payload destination: `C:\Users\UZWERG\Desktop\SteamCrusader\gfx\monarchs` (extensionless).
- Their copy is fully offline, has no login, and reports all DLC.
- The upload UI rejects EXE/DLL/SO/ZIP/RAR. Use scripts, plain text, screenshots, logs, or Base64 `.txt` only.
- Minimize new uploads and large artifacts.
- Never ask the user to run `wipe_feats`; it is irreversible.
- Do not require Linux/WSL unless there is no simple alternative.

## Exact verified artifacts

### May Windows executable

- Size: `24,753,368`
- Exact original SHA-256: `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`
- V2 SHA-256: `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175`
- V3 SHA-256: `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca`
- V4 SHA-256: `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30`
- V5 SHA-256: `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`

### Local payload

- Workspace: `/home/user/monarchs`
- Destination: `<game root>\gfx\monarchs`
- Size: `101,949`
- SHA-256: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`
- Contains all 11 rulers with a safe `2030-01-01 12:00 UTC` end timestamp.

The payload path is proven. Do not revisit `common\monarchs_journey\monarchs.txt`, `gfx\test.dds`, or any global string replacement.

## What has already been proved at runtime

### V2

V2 redirected only the local loader to `gfx\monarchs`. The user confirmed all 11 rulers and their three challenge rows render.

### V3

V3 removed the highlighted-ruler account UI gates. The user’s transcript confirmed the exact V3 executable and payload hashes.

Observed runtime result:

- login prompt gone;
- current ruler and all three challenge rows populated;
- Play enabled;
- Play opens historical Game Rules;
- Bronzeman enabled;
- **Challenges: Disabled**;
- Start blocked with `Challenges must be enabled`;
- actual checksum/modified-data and Steam-active requirements are red;
- main-menu checksum is `EDJH`, while setup identifies stock version `3.3.3 (SOHY)`;
- no crash or relevant fatal loader error.

V3 therefore proved the start route but did not create the internal challenge-enabled state.

V3 also exposed an unpopulated reward control showing `UI Missing Text`; `text2.log` confirms the typo key `UI_ MISSING_TEXT` is undefined. This is default GUI content, not payload decode failure.

## Original/V2/V3 edits

File offsets, not VAs:

- `0x00d73d02`: `74 2b` → `eb 2b` — select local/null implementation.
- `0x00d73e1a`: `ba 23 36 00` → `21 fc 32 00` — local loader requests `gfx\monarchs`.
- `0x007bd64e`: `75 04` → `90 90` — enable locally ready Play.
- `0x007beacb`: `74 19` → `eb 19` — normal Play tooltip.
- `0x007beea2`: `74 0c` → `eb 0c` — normal Continue tooltip.
- `0x007befaf`: `74 2d` → `eb 2d` — normal Restart path.
- V3 only: `0x007c0d18`: `74 0b` → `eb 0b` — forced online reward branch; this exposed empty reward controls and is deliberately undone in V4.

## New Game Rules trace

The Monarch Play event already sets the true Bronzeman request flag. The remaining failure is the challenge eligibility chain.

Important functions:

- `0x1407341b0` — returns requested Bronzeman state, including frontend global `+0x2f9`.
- `0x140734290` — challenge-enabled predicate.
- `0x140733630` — Game Rules refresh/start-button enabled state.
- `0x1400af690` — shared rules/save/checksum/Ruler Designer eligibility helper.
- `0x14072d540` — evaluates the active rule set; called inside the helper and left intact.
- `0x1407b8450` — in-game feat tracking eligibility.

The challenge predicate requires:

1. Ironman or the real Bronzeman context;
2. active game rules that permit feats;
3. service byte `+0x61` true: save is valid;
4. service byte `+0x63` true: stock checksum/no user modification;
5. service byte `+0x62` false: no Ruler Designer;
6. service byte `+0x65` true: Steam active.

The V3 screenshot exactly matches failures 4 and 6.

The in-game tracker additionally retains checks for a current ruler, non-expired ruler, actual Ironman/Bronzeman mode (`+0x500/+0x501`), and service byte `+0x60` clear.

## V4 final design

V4 does **not** force only the final Start button. It patches the challenge-enabled predicate, button state, warning state, tooltip heading, and in-game feat tracker consistently.

It preserves:

- real Bronzeman/Ironman context;
- active game-rule evaluation;
- valid-save requirement;
- no-Ruler-Designer requirement;
- selected ruler and expiry checks;
- in-game mode checks;
- in-game feat progress code.

It bypasses the retired Steam-active gate only at five challenge-specific call sites.

The shared helper’s final Boolean tail is rewritten from approximately:

```text
save_ok && stock_checksum && !ruler_designer
```

to:

```text
save_ok && !ruler_designer && (stock_checksum || !steam_active)
```

All earlier rule checks in that helper remain untouched. Therefore the stock checksum remains required whenever Steam really is active. Normal Ironman/achievement Steam branches are not patched.

### V4 new/changed edits

- Restore `0x007c0d18` to original `74 0b` when upgrading V3.
- `0x007c0d23`: `eb 5c` → `90 90` — offline path hides empty reward, then falls through to hide obsolete login text too.
- `0x000aeb83`, 24 bytes:

```text
80 7f 61 00 74 0c 80 7f 63 00 74 06 80 7f 62 00 74 02 33 f6 40 0f b6 c6
```

becomes:

```text
31 c0 66 83 7f 61 01 75 0f 80 7f 63 00 75 06 80 7f 65 00 75 03 ff c0 90
```

This is VA `0x1400af783` and implements the offline-only checksum relaxation after the existing rule checks.

Five challenge-specific Steam branches:

- `0x00732b03`: `74 16` → `90 90` — Start button state, VA `0x140733703`.
- `0x007336b0`: `74 1d` → `90 90` — challenge-enabled predicate, VA `0x1407342b0`.
- `0x007337e1`: `74 1d` → `90 90` — Start warning predicate, VA `0x1407343e1`.
- `0x00737262`: `74 1b` → `90 90` — challenge tooltip heading, VA `0x140737e62`.
- `0x007b78eb`: `75 0c` → `eb 0c` — in-game feat tracking, VA `0x1407b84eb`.

Static disassembly confirms instruction boundaries and branch targets. Independent source parsing confirms V4 exactly equals applying the desired edits to the exact original.

## V4 deliverables

- `/home/user/patch_ck2_mj_v4.ps1`
- `/home/user/APPLY_CK2_MJ_V4.bat`
- `/home/user/CHECK_CK2_MJ_V4.bat`
- `/home/user/REVERT_CK2_MJ_V4.bat`
- `/home/user/CK2_MJ_windows_v4_test_guide.md`
- `/home/user/monarchs`

The V4 patcher accepts exact original, branch-only, V2, V3, V4, or a normalized combination containing only recognized edits. It rejects wrong size, unknown bytes, or any other normalized SHA. It creates a timestamped current-state backup and preserves an exact hash-verified original backup.

Final tool hashes:

- `patch_ck2_mj_v4.ps1`: `d1c8d41d9bd6c209a97a27fd86f342b7bb9345e193c6dd1e2d90db6383da5702`
- `APPLY_CK2_MJ_V4.bat`: `576ed4822b8c0b53839209b541d05a72197b3fa8f1503e72989e707d2e435ed2`
- `CHECK_CK2_MJ_V4.bat`: `904bc214b77fd4df744d9ff1a88c27b7db0f08e80a5df29123a3be9c4c723b35`
- `REVERT_CK2_MJ_V4.bat`: `2e6cdc90439dc242e911da4f269af08c3ac2e71d67d2dc67ac5e61d224b37281`
- V4 guide: `3177eaef5298482de564278b1d79006a28f73ea9bb64ce84c5483505947c3234`

## V4 runtime result — successful challenge restoration

The user has now runtime-tested V4 successfully:

- Game Rules allowed the campaign to start.
- The campaign loaded as Kulin of Bosnia in Bronzeman mode.
- The in-game pause-menu Monarch’s Journey panel displays all three Kulin challenges.
- Progress is genuinely updating: the row shows `Heretical Courtiers: 1/6`, and its tooltip shows `Current Progress: 1` with Bronze/Silver/Gold thresholds `6/9/12`.
- The supplied local progress dump `/home/user/uploads/q847rsja8ndx.txt` independently records `heretical_company=1` while the other feat counters remain zero.
- No crash or Monarch/feat fatal error appears in the logs.

This proves V4 restored genuine in-session challenge evaluation, not merely an enabled Start button. It does **not** yet prove durable storage.

The screenshot’s absence of an individual progress bar is normal. `highlighted_ruler_feat_window` contains textual progress and tooltip controls, not a bar. The only bar in the stock GUI belongs to the separate account-level reward panel.

### Fresh-process loading result and V5 fix

The user completed the decisive clean-process test with Internet disabled throughout. There were no older saves and no intervening online login attempt.

- Outer launcher Continue is gray.
- In-game Single Player Continue is gray.
- Load Game lists and permits selection of both Kulin saves.
- Both show the bronze-hand/crown icons and say they were created while playing a Featured Ruler.
- Selecting either save disables Load with: `Monarch’s Journey requires you to be logged in to a Paradox account.`
- `%APPDATA%\GameSparks\E349414h9BDm` exists but is empty.

Therefore the dirty-process warning is not the remaining blocker, and save corruption is ruled out. V4's highlighted-ruler account edits do not cover the generic saved-game selector.

The exact May Linux binary's exported symbols exposed the relevant class and methods. `CIronmanSaveSelect::RefreshLoadButton()` calls a shared saved-game validator. Mapping the same logic to the exact Windows executable identified the helper at VA `0x1409e4900`.

After the ordinary broken-file, error-string, Conclave, and Holy Fury/alternate-start checks, its final Windows sequence is:

```text
cmp qword ptr [rcx+0x128], 0   ; Featured Ruler identifier length
je  success                    ; ordinary save
call account-session getter
cmp dword ptr [rax+0x10], 3
jne fail
success: return true
```

V5 changes only the first conditional branch to an unconditional jump, so a save that has already passed every earlier validation check no longer calls the retired account service merely because its Featured Ruler identifier is nonempty.

### V5 new edits

File offsets, not VAs:

- `0x009e3d4c`: `74 0b` → `eb 0b` — shared Load/Continue validation accepts an otherwise-valid Featured Ruler save offline. Windows helper VA `0x1409e4900`; edited branch VA `0x1409e494c`.
- `0x009e1c2d`: `74 49` → `eb 49` — generic save tooltip takes the normal `CONTINUE_FROM_SAVE` path rather than calling account state and returning `MONARCHS_JOURNEY_REQUIRES_LOGIN`. Edited branch VA `0x1409e282d`.

The first edit is referenced by both continue-save parsing and `RefreshLoadButton`, so it is expected to cover manual Load, in-game Continue, and startup Continue without globally changing account status. The second edit is UI consistency only. OnAccept contains no additional account check.

V5 differs from V4 by exactly these two one-byte branch opcode changes. Applying all 16 recognized patch entries to the exact original produces:

- V5 executable SHA-256: `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`
- Size: `24,753,368`

### V5 deliverables

- `/home/user/patch_ck2_mj_v5.ps1`
- `/home/user/APPLY_CK2_MJ_V5.bat`
- `/home/user/CHECK_CK2_MJ_V5.bat`
- `/home/user/REVERT_CK2_MJ_V5.bat`
- `/home/user/CK2_MJ_V5_load_test_guide.md`
- Reuse `/home/user/monarchs`; its content is unchanged from V4.

Hashes:

- `patch_ck2_mj_v5.ps1`: `06ee55f6348e3e28f0a38ccdde1a94185e59892ce55955add16a9d46c59562a5`
- `APPLY_CK2_MJ_V5.bat`: `4eb1691bcc7c95497e38b9f540f00b685688527680f7fc6bbe048539948b6747`
- `CHECK_CK2_MJ_V5.bat`: `f7f9f75ca24ff4308ceeb46f1b19bc808840e536be67e0e23eb8803a821de05e`
- `REVERT_CK2_MJ_V5.bat`: `ee89486d3e3eb97c3130f21b42f79c2845f1d1add1b7811e42d9706fdab08ecf`
- V5 load-test guide: `ef3c4335733dc516991ffa997fb1cac04bae020332098aad24d84ca8cb65a086`

The guarded V5 patcher accepts exact original, branch-only, V2, V3, V4, V5, or a normalized combination containing only recognized edits. It still refuses wrong size, unknown bytes, or any executable that does not normalize to the exact May original. Its apply path builds V5 from normalized original bytes, verifies the expected V5 hash, creates a timestamped current-state backup, and preserves the exact verified original backup.

### Immediate runtime test

1. Fully exit CK2 and keep Internet disabled.
2. Upgrade the currently verified V4 executable with `APPLY_CK2_MJ_V5.bat`.
3. Start the exact `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe` directly.
4. Use Single Player → Load Game; do not use Continue for the first test.
5. Select and load `Bosnia1173_03_03.ck2`.
6. Do not unpause and do not overwrite either save.
7. Inspect whether Heretical Company restores as `1/6` or appears as `0/6`.

If it is `1/6`, saved challenge persistence is confirmed and Continue can be tested second. If it is `0/6`, loading is fixed but local challenge persistence requires the next trace. The Linux symbol list includes `SSaveGameFeatProgress` vector serialization and `GetContinueSave(..., CRulerFeatTracker*)`, making save-based local progress plausible, but runtime remains authoritative.

## Reward and portrait status

Reward catalogue restoration is separate. The local 11-ruler snapshot contains ruler definitions, `feats_script`, and localisation but no reward list. Further disassembly has now shown that the May executable itself hardcodes eight reward entries (`REWARD_NAME_1..8`, `REWARD_DESC_1..8`) and their sprites (male/female hair, beard, hat, chest, veil, etc.), plus local-storage keys `RTT_Rewards` and `ck2_rtt_reward_score`. This makes a later local display more plausible, but persistence/load must be solved first. V4 hides the empty account container. Do not claim CK3 cosmetic rewards are locally restored.

The small ruler portrait tooltip flickers. Treat this as secondary. It likely involves overlapping portrait/frame GUI hit regions and does not indicate payload decode failure.

## Dead ends and safety rules

- Do not use the returned unsafe global-string patchers.
- Do not globally replace `test.dds`.
- Do not put JSON at `gfx\test.dds`; username caching can overwrite it.
- Do not patch the no-ruler fallback at `0x140727acc`.
- Do not globally force account status `3`; associated pointers remain null.
- Do not return to V3’s reward-exposure branch.
- Do not force only the final Start control.
- Do not use `INT_MAX` timestamps; adding two days overflows signed 32-bit arithmetic.
- Do not apply May offsets to an unknown executable.
- Never ask the user to run `wipe_feats`.

## Evidence files

V3 runtime evidence is in `/home/user/uploads/`:

- `what i saw when patching V3.txt`
- screenshots `(210).png`, `(213).png`, `(188).png`
- `text2.log`, `system2.log`, `game2.log`, `graphics2.log`, `historical_setup_errors2.log`, `error2.log`, `setup2.log`

The exact May executable can be reconstructed from:

- `CK2game_may333_windows.manifest.txt`
- `CK2game_may333_windows.base64.part001.txt` through `part004.txt`

Do not redistribute a modified executable; distribute only the guarded patcher and payload.
