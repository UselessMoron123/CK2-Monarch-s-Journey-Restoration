# CK2 Monarch’s Journey Restoration — authoritative project status

Last updated: 2026-08-22 (session branch). Read this file first, then
`things parent AI asked to upload/CK2_MJ_ULTIMATE_HANDOFF.md` for deep background.

## Bottom line (V6 verdict)

V6 (Windows May-2020 3.3.3, SHA-256 `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`)
is **runtime-proven for the core loop** — starting Bronzeman campaigns, live challenge
evaluation, tier granting, save writing, and persistent local progress. What still fails
is the **Continue button** (both normal main-menu Continue and the Monarch’s Journey panel
Continue) and a set of secondary UI glitches. This corresponds to **outcome D** in the
handoff’s V6 interpretation matrix (manual load path OK, Continue path still rejected).

### Proven working (evidence in `analysis/V6_RUNTIME_RESULTS.md`)

- V6 patch applied cleanly from exact V5; final hash verified (patch-window text).
- Local 11-ruler payload loads (`gfx\monarchs`, SHA `fc6ec025…`).
- New Bronzeman campaign started as a *different* featured ruler (Pavao of Croatia, 1278.1.1).
- Live challenge evaluation: `global_established` tracked 2 → 4 across the first days.
- **Tier granting works**: Bronze rank popup in `game.log` at the exact payload threshold
  (`established` levels = {4 6 8} → Bronze at 4).
- **Save writing works**: three saves with `bronzeman=yes`, `special_event="pavao_croatia"`,
  feat globals serialized (`v6 second look/save games/`).
- **Persistent local progress works**: `v6 second look/cache/q847rsja8ndx` (feat_progress_storage)
  stores peak values (`established=4`, `conquerer_from_bribir=1`) across sessions.

### Still broken

- **Continue** — dead from main menu and from the MJ panel (screenshots (1), (2), (4) in
  `log playing with new v6 patch/`). V6 patched the inline account branch in the Continue
  candidate-selection helper (`0x1409e4970`), so a *different, non-account* predicate is
  rejecting Continue. Next binary target: callers `0x1407bffa1` (MJ Continue path),
  `0x1408145ec` (normal frontend Continue), `0x140a0ba62`.

### Secondary (do not block on these)

- Multiplayer button breaks on second boot / after resign-to-menu; gray map on first boot.
- MJ arrow absent in some boots (`v6 second look/(19 january of 2020)…png`).
- Portrait-tooltip flicker (`v6 second look/flickering….mp4`).
- MJ interface disappears if a Bronzeman save is entered via random-ruler path (screenshot (16));
  no featured-ruler crown in Bronzeman (screenshot (17)).
- All are cosmetic/flow polish after Continue is fixed.

## Authoritative files

| File | Content |
|---|---|
| `STATUS.md` (this file) | One-page current state — read first |
| `analysis/V6_RUNTIME_RESULTS.md` | Full evidence chain for the V6 verdict |
| `analysis/EXECUTABLE_IDENTITIES.md` | All four GitHub executables verified byte-exact + payload/save/cache hashes |
| `analysis/WINDOWS_333_PATCH_MAP.md` + `.csv` | Machine-readable cumulative V2→V6 patch table for May-2020 Win 3.3.3 |
| `things parent AI asked to upload/CK2_MJ_ULTIMATE_HANDOFF.md` | Deep background, dead ends, constraints |

## Environment constants (unchanged)

- Test root: `C:\Users\UZWERG\Desktop\SteamCrusader`, payload at `gfx\monarchs`.
- Test offline (Internet disconnected). Bronzeman console unavailable is normal.
- **Never** run `wipe_feats`; never apply May-2020 offsets to 3.3.5.1; never
  redistribute complete stock or patched CK2 executables — keep everything as
  guarded patch scripts on the user’s own verified binary.

## Next actions, in order

1. **V7 (Continue fix)** — static analysis of the three Continue callers in the verified
   stock May Win 3.3.3 (`analysis` note: binaries reconstructible from the four
   `*_upload_chunks` folders; see EXECUTABLE_IDENTITIES.md for the exact recipe).
   Find the non-account predicate that still rejects Featured-Ruler/Bronzeman saves;
   produce a hash-guarded V6→V7 patcher set like the V6 one.
2. Confirm (or have the user confirm) the one missing runtime datum: manual
   `Load Game` of the old `Bosnia1173_03_03.ck2` showing 1173.3.3 + Heretical Company 1/6.
3. Later, separate projects: local score/reward gallery reconstruction; recovering the
   five missing rulers; 3.3.5.1 port assessment (binaries now all verified).
