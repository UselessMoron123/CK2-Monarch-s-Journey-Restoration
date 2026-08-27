# CK2 Monarch’s Journey Restoration — authoritative project status

> **2026-08-27 — V7 in-game Continue proven. C08 SOLVED. Dashboard repaired.**
>
> Live x64dbg tracing identified the “Continue failed!” popup as an offline
> cloud-sync gate at `0x1409E678B` (`movzx ecx, [rsi+0x63]` / `test cl, cl` /
> `jne 0x1409E67BC`) inside Continue *execution* `0x1409E6700`.
>
> V7 (`0x009E5B8B`: `75 2f` → `eb 2f`) loads `Bosnia1173_01_02.ck2`, creates
> `MrHuman`, assigns `Kulin of d_bosnia (218800)`, and enters the map with no
> popup. SHA-256
> `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`.
>
> Evidence: `03_analysis/V7_RUNTIME_RESULTS.md`,
> `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART4.md`.
> Tools: `ps1/patch_ck2_mj_v7.ps1`, `bat/APPLY_CK2_MJ_V7.bat`,
> `CHECK_CK2_MJ_V7.bat`, `REVERT_CK2_MJ_V7_TO_V6.bat`.
>
> **Not solved:** Paradox *launcher* Continue (case **C25**) — separate
> `pdx_launcher.lib` / `launcher-v2.sqlite` path. Launch `CK2game.exe` directly.

Last updated: 2026-08-27 (ingest of `latest logs/` / `latest latest logs/` /
`new new logs/`). Read this file first, then:

- `CASES_AND_FINDINGS.md` — solved/unsolved/partial case map
- `FR_MJ_COMPLETE_ROSTER.md` — all FR+MJ rulers, bios, challenge tiers
- `FEATURED_RULERS.md` — FR UI/timeline/assets/restore checklist
- `SCREENSHOTS_CATALOG.md` — image intents
- `../02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` for deep binary background

## Bottom line (V7 verdict — live-proven)

**Current in-game baseline is V7** (Windows May-2020 3.3.3,
SHA-256 `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`).
V6 (`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`) remains
the exact revert target and a still-valid Load/campaign baseline.

V6 already proved the core restoration loop (payload, Bronzeman, live feats,
Bronze grant, save write, Load Game, feat cache). V7 adds in-game Continue
*execution* so the main-menu / MJ / Single Player Continue controls load the
latest Bronzeman save without the generic failed popup.

### Proven working

- V6 campaign/tier/save/cache pipeline — `03_analysis/V6_RUNTIME_RESULTS.md`
- V7 Continue execution — `03_analysis/V7_RUNTIME_RESULTS.md`
- Local 11-ruler payload (`gfx\monarchs`, SHA `fc6ec025…`)
- Resume-after-restart via **Load Game** *and* in-game **Continue**
- Pavao resume evidence: `07_runtime_logs/game_pavao_resume_1278_01_08.log`
  (start-date 1278.1.8, Pavao Subic)

### Still open (do not conflate with C08)

- **C25 — Paradox launcher Continue** still grey. Independent of engine V7.
  Breadcrumbs: `pdx_launcher.lib` `0xDE47C0` / `0xDE8BB0` / `0x99F540`,
  `launcher-v2.sqlite`. Hypothesis until those files are actually inspected.
- Feat-cache after the Llywelyn session: preflight saw
  `Bronzeman_llywelyn_gwynedd.ck2` (1195.1.1) and `Gwynedd1195_01_08.ck2`
  (1195.1.8), both `bronzeman=yes` `special_event=llywelyn_gwynedd`, **no feat
  cache file**. Saves not uploaded. Identity-drift hypothesis still untested.

### Secondary (do not block on these)

- Multiplayer button breaks on second boot / after resign-to-menu; grey map on first boot.
- MJ arrow absent in some boots.
- Portrait-tooltip flicker.
- MJ interface disappears if a Bronzeman save is entered via random-ruler path.
- C17 gauntlet tooltip still says Challenges Disabled (cosmetic; play works).

## Authoritative files

| File | Content |
|---|---|
| `STATUS.md` (this file) | One-page current state — read first |
| `03_analysis/V7_RUNTIME_RESULTS.md` | Live Continue-execution proof |
| `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART4.md` | Part 4: attach-mode x64dbg → V7 |
| `03_analysis/V6_RUNTIME_RESULTS.md` | V6 campaign/save/cache evidence |
| `03_analysis/EXECUTABLE_IDENTITIES.md` | Stock + patched hashes |
| `03_analysis/MASTER_ARTIFACT_TABLE.md` | Canonical registry |
| `03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv` | Cumulative V2→**V7** patch table |
| `03_analysis/BANNED_ARTIFACTS.md` | Banned trampoline V6 + abandoned feat-V7 |
| `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` | 2.6.1.1 model + win333 + **§F V7 execution** |
| `03_analysis/CONTRADICTIONS.md` | Disagreement register |
| `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` | Deep background (banner must match this file) |

## Environment constants (unchanged)

- Test root: `C:\Users\UZWERG\Desktop\SteamCrusader`, payload at `gfx\monarchs`.
- Test offline (Internet disconnected). Bronzeman console unavailable is normal.
- **Never** run `wipe_feats`; never apply May-2020 offsets to 3.3.5.1; never
  redistribute complete stock or patched CK2 executables — keep everything as
  guarded patch scripts on the user’s own verified binary.
- Launch **`CK2game.exe` directly**. Do not expect the Paradox launcher Continue
  button to work.

## Next actions, in order

1. ~~Cross-version executable comparison~~ **DONE**.
2. ~~V7 in-game Continue execution~~ **DONE** (`57b18e43…`).
3. Optional: **C25 launcher Continue** (separate project; not required to play).
4. Phase 3 polish: C09–C12, C13, C17.
5. Separate projects: local score/reward gallery; five missing rulers; Featured
   Rulers restore (`FEATURED_RULERS.md`).

## Naming collision (key by SHA, never label)

| Label | SHA-256 | Meaning | Status |
|---|---|---|---|
| “V6” trampoline | `a6cb92b8…` | injected code | ❌ BANNED |
| V6 | `f5b7dfd6…` | 5 save-list branches | ✅ proven; V7 revert target |
| “V7” feat-update | `0074af70…` | two `74 0d→90 90` | 🟡 ABANDONED |
| **V7 Continue** | `57b18e43…` | `0x009E5B8B` `75 2f→eb 2f` | ✅ **current in-game Continue** |
