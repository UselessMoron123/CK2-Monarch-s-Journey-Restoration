# Windows May-2020 3.3.3 cumulative patch map (V2 → V7)

Target: stock `CK2game.exe`
SHA-256 `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`,
24,753,368 bytes. `VA = raw_offset + 0x140000c00`.
Current applied state: **V7** (`57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`).
V6 (`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`) is the revert target.

Every edit is length-preserving. Machine-readable copy: `windows333_patch_map.csv`.

## Factory / loader (V2)

| Raw offset | VA | Stock | V6 | Purpose |
|---|---|---|---|---|
| 0x00d73d02 | — | `74 2b` | `eb 2b` | Force local/null GameSpark factory branch |
| 0x00d73e1a | — | `ba 23 36 00` | `21 fc 32 00` | LoadLocalCache filename `gfx\test.dds` → `gfx\monarchs` |

## Panel Play / Continue UI gates (V3, one V3 edit reverted in V4)

| Raw offset | VA | Stock | V6 | Purpose |
|---|---|---|---|---|
| 0x007bd64e | — | `75 04` | `90 90` | Enable Play when local ruler otherwise ready |
| 0x007beacb | — | `74 19` | `eb 19` | Normal Play tooltip |
| 0x007beea2 | — | `74 0c` | `eb 0c` | Normal Continue tooltip |
| 0x007befaf | — | `74 2d` | `eb 2d` | Normal Restart path |
| 0x007c0d18 | — | `74 0b` | `74 0b` | *(stock — V3 force reverted; do not touch)* |

## Offline challenge mode (V4)

| Raw offset | VA | Stock | V6 | Purpose |
|---|---|---|---|---|
| 0x007c0d23 | — | `eb 5c` | `90 90` | Hide empty reward controls + obsolete login text offline |
| 0x00732b03 | — | `74 16` | `90 90` | Start-button Steam-active gate |
| 0x007336b0 | — | `74 1d` | `90 90` | Challenge-enabled predicate gate |
| 0x007337e1 | — | `74 1d` | `90 90` | Start-warning predicate gate |
| 0x00737262 | — | `74 1b` | `90 90` | Challenge-tooltip heading gate |
| 0x007b78eb | — | `75 0c` | `eb 0c` | In-game feat tracking gate |
| 0x000aeb83 (24 bytes) | — | see below | see below | Eligibility helper tail |

Eligibility tail, stock → patched:

```text
stock:  80 7f 61 00 74 0c 80 7f 63 00 74 06 80 7f 62 00 74 02 33 f6 40 0f b6 c6
V6:     31 c0 66 83 7f 61 01 75 0f 80 7f 63 00 75 06 80 7f 65 00 75 03 ff c0 90
```

Effective: `save_ok && !ruler_designer && (stock_checksum || !steam_active)`

## Generic save validity + tooltip (V5)

| Raw offset | VA | Stock | V6 | Purpose |
|---|---|---|---|---|
| 0x009e3d4c | 0x1409e494c | `74 0b` | `eb 0b` | Generic valid-save predicate: skip account check for Featured Ruler metadata |
| 0x009e1c2d | — | `74 49` | `eb 49` | Normal save tooltip instead of `MONARCHS_JOURNEY_REQUIRES_LOGIN` |

## Save-list / Continue selection gates (V6)

| Raw offset | VA | Stock | V6 | Purpose |
|---|---|---|---|---|
| 0x009e4611 | 0x1409e5211 | `74 0f` | `eb 0f` | Continue candidate selection: accept Featured Ruler save |
| 0x009e4f1e | 0x1409e5b1e | `0f 84 86 01 00 00` | `e9 87 01 00 00 90` | First save-list path → accepted target 0x1409e5caa |
| 0x009e4fc3 | 0x1409e5bc3 | `74 0f` | `eb 0f` | Newer/current-save path → accepted target 0x1409e5bd4 |
| 0x009e5377 | 0x1409e5f77 | `0f 84 63 01 00 00` | `e9 64 01 00 00 90` | Named-save path → accepted target 0x1409e60e0 |
| 0x009e5452 | 0x1409e6052 | `74 0b` | `eb 0b` | Latest-save path → accepted target 0x1409e605f |

## Runtime verdict per state

- V2: panel + 11 rulers + 33 challenge rows render; account UI blocks Play.
- V3: Play reachable, Bronzeman requested, challenges still Disabled, Start blocked.
- V4: Bronzeman + Challenges Enabled, Start works, live 1/6 progress in-game.
- V5: Load button unblocked but selection never installed (duplicated gates).
- **V6: campaign/tier/save/cache pipeline proven (Bronze granted on Pavao); in-game Continue still popped “Continue failed!”.**
- **V7: in-game Continue execution proven (`57b18e43…`). Launcher Continue remains grey (C25).**

## Known do-not-touch list

`0x140727acc` no-ruler fallback; global account-status forcing; V3’s reward-container
force (`0x007c0d18`); final-Start-only forcing; any INT_MAX `event_time_end`;
`gfx\test.dds` payload placement. Full list in handoff §16.
