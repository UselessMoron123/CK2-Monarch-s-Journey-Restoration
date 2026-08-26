# CK2 Monarch's Journey Windows 3.3.3 — v3 offline-gate test

## Current status

The v2 runtime test was a real partial success:

- the local payload at `<game folder>\gfx\monarchs` loaded;
- the Monarch's Journey panel appeared;
- all eleven ruler records rendered correctly;
- the remaining problem was the retired Paradox-account UI gate.

Static analysis now supports a narrowly targeted v3 test. It does **not** spoof
the account singleton globally. It changes only five highlighted-ruler UI
branches in addition to the two already validated v2 loader patches.

This v3 executable has been reconstructed and hash-checked here, but it still
needs the user's Windows runtime test before it can be called final.

## Why the Play patch is now justified

The highlighted-ruler update routine resolves the GUI object named
`play_button`, computes a Boolean, and passes it to `0x1401733b0`.

`0x1401733b0` is now identified as an enabled-state setter:

- false changes the base control's state to `3` and invokes its disable/update
  behavior;
- true changes state `3` back to `0`, or invokes the equivalent virtual method
  on a derived control.

The Boolean is true only if all of these conditions pass:

1. `[rdi+0xaa]` is nonzero;
2. `[rdi+0x108]` equals `2`;
3. the local readiness value in `r14` is positive;
4. the retired account status equals `3`.

The v3 edit removes only condition 4. The three local validity/DLC/readiness
checks remain intact.

## Start action check

The function at `0x1407c3640` handles `highlighted_ruler_start`. It requires a
non-null selected ruler, builds the start command data, calls the normal helper
at `0x1407a5870`, and then enters the start transition at `0x1407c38e0`.
Neither this handler nor the immediate transition performs another call to the
account-status accessor `0x140d73220`.

The matching restart handler follows the same structure. This means the Play
button was the direct account gate; clicking it is not immediately rejected by
a second account check.

## Reward/login panel check

The setup routine resolves the `reward` window before its account check.

- Offline path: calls the reward window's hide method and leaves
  `log_in_to_earn_rewards_text` visible.
- Logged-in path: leaves the already-populated reward window visible and hides
  `log_in_to_earn_rewards_text`.

The focused v3 branch sends this one panel down the logged-in display path. It
does not alter the account object or any unrelated subsystem.

Three additional focused branches prevent Play, Continue, and Restart from
selecting `LOG_IN_TO_PLAY_FEATURED_RULER`. Their non-login paths retain the
normal local-state and DLC checks.

## Exact v3 edits

The first two edits are the runtime-proven v2 loader edits:

| File offset | Original | v3 | Purpose |
|---|---:|---:|---|
| `0x00d73d02` | `74 2b` | `eb 2b` | Force local/null implementation |
| `0x00d73e1a` | `ba 23 36 00` | `21 fc 32 00` | Redirect only the local loader to `gfx\monarchs` |

Focused highlighted-ruler UI edits:

| File offset | Original | v3 | Purpose |
|---|---:|---:|---|
| `0x007bd64e` | `75 04` | `90 90` | Ignore account status only after the three local Play checks pass |
| `0x007beacb` | `74 19` | `eb 19` | Use the normal Play tooltip path |
| `0x007beea2` | `74 0c` | `eb 0c` | Use the normal Continue tooltip path |
| `0x007befaf` | `74 2d` | `eb 2d` | Use the normal Restart path |
| `0x007c0d18` | `74 0b` | `eb 0b` | Keep rewards visible and hide the login prompt |

No strings are overwritten, no instruction length changes, and account status
is not globally changed.

## Verified identities

Exact May 2020 original:

- Size: `24,753,368`
- SHA-256: `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`

Runtime-proven v2:

- SHA-256: `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175`

Prepared v3:

- Size: `24,753,368`
- SHA-256: `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca`

Payload:

- Required path: `<game folder>\gfx\monarchs`
- Size: `101,949`
- SHA-256: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`

## Prepared files

Keep these together:

```text
APPLY_CK2_MJ_V3.bat
patch_ck2_mj_v3.ps1
monarchs
```

Optional beginner-friendly helpers:

```text
CHECK_CK2_MJ_V3.bat
REVERT_CK2_MJ_V3.bat
```

The patcher refuses the wrong executable size, unknown bytes at any patch site,
or any executable that cannot be normalized to the exact original SHA-256. It
accepts the exact original, branch-only test, v2, v3, and recognized partial
combinations containing no other edits.

Before changing the executable it creates:

1. a timestamped, SHA-verified copy of the current executable; and
2. `CK2game...exe.verified_may333_original.bak`, whose SHA-256 must equal the
   exact May original.

## Beginner test steps

1. Close CK2 completely.
2. Put `APPLY_CK2_MJ_V3.bat`, `patch_ck2_mj_v3.ps1`, and `monarchs` in one
   ordinary folder.
3. Drag the **same executable that produced the successful v2 ruler panel**
   onto `APPLY_CK2_MJ_V3.bat`.
4. Wait for the green `V3 PATCH AND PAYLOAD INSTALLATION COMPLETE` result.
   If the window says `PATCH FAILED`, stop and send a screenshot; do not edit
   the executable manually.
5. Start that exact executable directly.
6. Open Monarch's Journey and check that:
   - `Log in to earn rewards` is gone;
   - the reward/progress section is visible;
   - the Play button is clickable;
   - the three challenge rows are present.
7. Choose one ruler and click Play. Use a disposable test save if prompted.
8. After the game loads, open the Monarch's Journey/challenge panel and check
   that the same three challenges and their progress counters appear.
9. Exit normally. Do **not** use the console command `wipe_feats`.

The map being mostly grey on the ruler-selection screen alone is not enough to
call the test a failure. The decisive results are the reward panel, challenge
rows, clickable Play action, successful game start, and in-game progress UI.

## Revert

1. Close CK2.
2. Keep `REVERT_CK2_MJ_V3.bat` beside `patch_ck2_mj_v3.ps1`.
3. Drag the patched executable onto `REVERT_CK2_MJ_V3.bat`.
4. The restored SHA-256 must be:

```text
656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8
```

The `gfx\monarchs` payload is inert with the original executable and may be
left in place or deleted manually.
