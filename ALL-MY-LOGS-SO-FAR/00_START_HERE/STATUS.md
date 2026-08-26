# CK2 Monarch’s Journey Restoration — authoritative project status

Last updated: 2026-08-25 (session branch). Read this file first, then:
- `CASES_AND_FINDINGS.md` — solved/unsolved/partial case map
- `FR_MJ_COMPLETE_ROSTER.md` — **all FR+MJ rulers, bios, challenge tiers** (text; no pics needed)
- `FEATURED_RULERS.md` — FR UI/timeline/assets/restore checklist
- `SCREENSHOTS_CATALOG.md` — image intents (optional; descriptions stand alone)
- `../02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` for deep binary background

## Bottom line (V6 verdict — user-confirmed)

V6 (Windows May-2020 3.3.3, SHA-256 `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`)
is **runtime-proven for the core restoration loop**, including full save loading and
persistence of challenge progress:

- old V4-era save `Bosnia1173_03_03.ck2` loaded via Single Player → Load Game and showed
  **3 March 1173** + **Heretical Company 1/6** (feat globals deserialize correctly);
- new Bronzeman campaign as Pavao of Croatia: live evaluation, **Bronze tier granted**
  at the exact payload threshold, resume-after-restart via Load Game works;
- local persistent feat cache (`cache/q847rsja8ndx`) stores peak progress.

**Only remaining functional gap: the Continue button stays grayed out** (enable-state
predicate, not a click handler issue) → V7 target: the flag/predicate the frontend reads
to decide a continuable save exists (see handoff callers `0x1407bffa1`, `0x1408145ec`,
`0x140a0ba62`).

### Proven working (evidence in `03_analysis/V6_RUNTIME_RESULTS.md`)

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
| `03_analysis/` | **2.6.1.1 debug-PDB analysis** (2026-08-23): the `10_binary_artifacts/debug_files/` drop decoded — `ck2game.pdb` **exact-matches** the supplied `CK2game.exe` (GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1, 2016-08-30). Full 2.6.1.1 Continue/save-select semantic model: `CIronmanSaveSelect::GetContinueSave`/`UpdateContinueData` → `_bIsContinueSaveValid` → `RefreshContinueButton` pushes `CButton::Enable/Disable` (vtbl +0xDC/+0xE0) on widget `"continue"`. No account/online check exists in the 2.6.1.1 Continue path — any 3.3.x equivalent failure is therefore a *newer* predicate. See `IDENTITY.md`, `TYPE_AND_VTABLE_NOTES.md` (esp. §2 semantic checklist for V7), `SEARCH_RESULTS.md`, `SYMBOLS_FILTERED.csv`. |
| `03_analysis/V6_RUNTIME_RESULTS.md` | Full evidence chain for the V6 verdict |
| `03_analysis/EXECUTABLE_IDENTITIES.md` | All four GitHub executables verified byte-exact + payload/save/cache hashes |
| `03_analysis/MASTER_ARTIFACT_TABLE.md` | **One canonical registry** of every artifact (exe/patch-state/payload/saves/cache/tools/PDB) → size/SHA/path/role |
| `03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv` | Machine-readable cumulative V2→V6 patch table for May-2020 Win 3.3.3 |
| `03_analysis/BANNED_ARTIFACTS.md` | Register of banned builds/hashes/helpers/approaches (the two bad "V6"/"V7" hashes, `0x1409e8200` load-path ban, etc.) |
| `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` | 2.6.1.1 Continue model mapped to win333 anchor points + ordered V7 steps |
| `03_analysis/CONTRADICTIONS.md` | Both-sides-and-verdict register for every documented disagreement |
| `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md` | Cross-version comparison, 3.3.5.1 port verdict (not feasible), recovered component map, V7 breadcrumbs |
| `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` | Deep background, dead ends, constraints |

## Environment constants (unchanged)

- Test root: `C:\Users\UZWERG\Desktop\SteamCrusader`, payload at `gfx\monarchs`.
- Test offline (Internet disconnected). Bronzeman console unavailable is normal.
- **Never** run `wipe_feats`; never apply May-2020 offsets to 3.3.5.1; never
  redistribute complete stock or patched CK2 executables — keep everything as
  guarded patch scripts on the user’s own verified binary.

## Next actions, in order (updated 2026-08-22 after cross-version analysis)

1. ~~Cross-version executable comparison~~ **DONE** → `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md`.
   Verdict: **3.3.5.1 byte-patch port is not feasible** (payload parser + `gs_virtual/feat_script`
   loader + GameSparks SDK removed; downstream Bronzeman/feat machinery survives but has no data
   source). May 3.3.3 stays the restoration target; hybrid usage recommended for performance.
2. **V7 (Continue enable fix)** for May 3.3.3 — the Continue control is *grayed out* (enable
   predicate). The knowledge-base prep is done: start from
   `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` (2.6.1.1 model → win333 anchors + ordered
   steps), `03_analysis/BANNED_ARTIFACTS.md`, and the breadcrumbs in
   `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md` §7: Linux
   `CIronmanSaveSelect::GetContinueSave` @ 0x121ac3a ↔ win333 `0x1409e5500` region and
   caller `0x1408145ec`. Uses the verified Windows May-2020 3.3.3 executable at
   `10_binary_artifacts/executables/windows/CK2game333.exe` for disassembly.**
3. Later, separate projects: local score/reward gallery reconstruction (Linux
   `CRoadToTitusProgression::SetupRewards` @ 0x1444e92 has the local reward table —
   see assessment §6); recovering the five missing rulers.
