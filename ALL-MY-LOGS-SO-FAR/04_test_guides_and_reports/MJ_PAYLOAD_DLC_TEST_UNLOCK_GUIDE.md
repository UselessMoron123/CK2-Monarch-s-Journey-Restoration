# Monarch's Journey payload DLC test unlock

> **Runtime result, 2026-08-31:** the Aquitaine/French ruler starts and tracks. The
> three Muslim rulers pass the payload gate but immediately game-over without Muslim
> gameplay support; some initial feat values calculate before game-over. Canonical
> results and condition clarifications:
> `../03_analysis/DLC_TEST_UNLOCK_RUNTIME_RESULTS.md`.

## Purpose

This optional V9 experiment removes the local payload's `required_dlcs` declarations
for four rulers whose Play button is otherwise grey and carries a DLC icon:

| Ruler | Payload requirement removed |
|---|---|
| Mordechai al-Dawla | `dlc007` |
| Louise of Aquitaine | `dlc024` |
| Shajar al-Durr | `dlc007` |
| Arwa of Yemen | `dlc007` |

It does **not** install, emulate, or grant ownership of official DLC. It only lets
campaign setup proceed far enough to reveal whether the installed 3.3.3 game data can
play each ruler without the declared DLC. Missing mechanics may still cause rejection,
a changed government, reduced gameplay, or another error.

## Guarded files and identities

The tool accepts only these exact extensionless payloads:

| State | Size | SHA-256 |
|---|---:|---|
| Canonical V9 payload | 101,949 | `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` |
| DLC-test payload | 101,761 | `1216a9eda59e35779171a616e489d6b1f823e6d4b62909a4924fafe8330e982b` |

Unknown files are refused. Apply and Revert each make and hash-check a timestamped
backup before replacing the payload. The executable and saves are not edited.

## Apply

1. Close CK2.
2. Find the extensionless file:
   `C:\Users\UZWERG\Desktop\SteamCrusader\gfx\monarchs`
3. Drag `monarchs` onto `APPLY_MJ_PAYLOAD_DLC_TEST_UNLOCK.bat`.
4. Confirm the green result and final SHA-256 `1216a9ed…`.
5. Keep the Internet disconnected and launch the V9 `CK2game.exe` directly.
6. Try Play for Mordechai, Louise, Shajar, and Arwa, one at a time.

For each ruler, record the first matching outcome:

- Play remains grey;
- Play starts but setup fails;
- map opens with a different government/religion or missing mechanics;
- map opens normally and all three challenges appear;
- challenges also increase after one relevant action/day.

A screenshot is useful only if an error, wrong character, or altered government appears.
A short text report is enough when a ruler works normally.

## Revert

Close CK2, then drag the same `gfx\monarchs` file onto
`REVERT_MJ_PAYLOAD_DLC_TEST_UNLOCK.bat`. It reconstructs and verifies the exact
canonical payload (`fc6ec025…`). Do not manually edit the payload and do not use the
revert tool on an unknown/custom payload.

## Why this precedes a 3.3.5.1 port

Windows 3.3.5.1 removed the GameSparks/local JSON parser, virtual feat-script loader,
and most MJ frontend code. It cannot receive the V9 payload through ordinary byte
offset porting. This experiment determines whether the practical reason for wanting a
port—testing the DLC-marked rulers—can be addressed safely on V9 first.
