# CK2 Monarch’s Journey Restoration — authoritative project status

> **2026-08-31 — latest-version direction and evidence status.** V9 remains the
> runtime-proven 3.3.3 baseline. The DLC payload-only experiment succeeded for the
> Christian `dlc024` ruler but the three `dlc007` Muslim rulers immediately game-over
> without the required gameplay DLC; payload declarations are not a general unlock.
> On 3.3.5.1, static matching proves that update callers, tracker/database consumers,
> low-level parser, VFS helper, and `CReader` machinery survive, while GameSparks-facing
> orchestration wrappers and the main-menu controller do not. A small native data
> adapter plus normal mod UI/setup is now the strongest high-fidelity direction; a
> fully scripted mod remains the safest fallback. Exact adapter feasibility is not yet
> runtime-proven. Evidence: `03_analysis/DLC_TEST_UNLOCK_RUNTIME_RESULTS.md`,
> `03_analysis/WINDOWS_3351_NATIVE_REUSE_AUDIT.md`, and research archive Part 6.
>
> **2026-08-30 — V9 cold-load feat fix proven. The last V9 functional defect is closed.**
>
> **Current baseline is V9**, SHA-256
> `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`
> (Windows May-2020 3.3.3, 24,753,368 bytes). User verdict: feats are present after a
> full quit → relaunch → load, they do not reset on soft or hard quit, and they
> increase when the player does the right thing.
>
> One length-preserving edit on top of V8: raw `0x007B7906`
> `e8 85 71 8f ff` (`call 0x1400AF690`) → `b0 01 90 90 90` (`mov al,1; nop×3`).
>
> ⚠️ **Do not remove V8's `0x007B786B` byte while "cleaning up" V9.** It sits
> *upstream* of the V9 edit in the same function, and
> `CalcShouldTrackFeatProgress` has only one caller — so if
> `IsActiveForPlaythrough` returns 0 the function exits at raw `0x7B7871` before
> the V9 byte is ever reached. "Neither V8 edit is the fix" is true; "both are
> removable" is **false** for the shipped design. Full reasoning, plus the
> abandoned alternative V9 design at `0x007B785B` where the same byte *would* be
> dead code: `03_analysis/V9_DESIGN_ALTERNATIVES_AND_V8_DEPENDENCY.md`.
>
> **V8 is recorded as applied-and-disproven.** It bypassed the two
> `IsActiveForPlaythrough` gates and made things worse (feats 0 in game *and* in the
> main-menu MJ tab). The clean x64dbg trace then showed `RESTORE_GATE al=1` on the
> cold burst — `IsActiveForPlaythrough` returned true — so V8's premise was wrong
> twice over. Both V8 edits are kept in V9; neither is the fix.
>
> **Revert ladder:** V9 `61e4345b…` → V8 `94d6fb40…` → V7 `57b18e43…` → V6
> `f5b7dfd6…` → V5 `29556549…` → stock `656f4f48…`. V7 is the more useful revert
> target than V8.
>
> **Still not solved:** Paradox *launcher* Continue (case **C25**).
>
> Evidence: `03_analysis/V9_RUNTIME_RESULTS.md`,
> `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md`,
> `04_test_guides_and_reports/CK2_MJ_V9_TEST_GUIDE.md`.
>
> **Answered, not a defect:** the medal stays Bronze on older saves / restarted
> campaigns and the “Word has spread far and wide…” popup does not repeat — the
> cache stores a lifetime peak per Windows profile, not per save.
> `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`.
>
> **Corrections issued this pass:** `CONTRADICTIONS.md` §12 (identity drift),
> §13 (`DAILY_GATE` breakpoint is `0x1000` off the patched byte), §14 (V8 did not
> wipe the cache).

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

Last updated: 2026-08-31 (Part 6 direct-session archive, DLC runtime verdict,
3.3.5.1 two-pass native-reuse audit, and operative organization prompt v8). Previous
major ingest: 2026-08-30 (`last log/`, V8 disproof and V9 verdict). Read this file first,
then:

- `CASES_AND_FINDINGS.md` — solved/unsolved/partial case map
- `FR_MJ_COMPLETE_ROSTER.md` — all FR+MJ rulers, bios, challenge tiers
- `FEATURED_RULERS.md` — FR UI/timeline/assets/restore checklist
- `SCREENSHOTS_CATALOG.md` — image intents
- `../02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md` for deep binary background

## Bottom line (V9 verdict — runtime-proven 2026-08-30)

**Current in-game baseline is V9** (Windows May-2020 3.3.3,
SHA-256 `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`).
Revert ladder: V8 `94d6fb40…` → V7 `57b18e43…` → V6
`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` → V5
`29556549…` → stock `656f4f48…`. V7 is the most useful revert target, because V8's
premise was disproven.

V6 proved the core restoration loop (payload, Bronzeman, live feats, Bronze grant,
save write, Load Game, feat cache). V7 added in-game Continue *execution*.
V8 tried to fix cold-load feats by bypassing the `IsActiveForPlaythrough` gates and
**failed**. V9 fixes it at the actual failure point — the final eligibility gate
inside `CalcShouldTrackFeatProgress` — and is the first state in which feats survive
a full quit → relaunch → load.

*Historical V7 verdict, kept for the record:* V7 was the baseline from 2026-08-27
until 2026-08-30. Its Continue fix is still present and still working in V9.

### Proven working

- V6 campaign/tier/save/cache pipeline — `03_analysis/V6_RUNTIME_RESULTS.md`
- V7 Continue execution — `03_analysis/V7_RUNTIME_RESULTS.md`
- **V9 cold-load feats — `03_analysis/V9_RUNTIME_RESULTS.md` (2026-08-30).**
  Feats survive soft resign *and* hard quit-to-desktop, and increase during play.
- Local 11-ruler payload (`gfx\monarchs`, SHA `fc6ec025…`)
- Resume-after-restart via **Load Game** *and* in-game **Continue**
- Pavao resume evidence: `07_runtime_logs/game_pavao_resume_1278_01_08.log`
  (start-date 1278.1.8, Pavao Subic)

### Answered — not a defect

- **Medal stays Bronze on an older save or a restarted campaign, and “Word has spread
  far and wide…” does not fire again.** `cache\q847rsja8ndx` stores the lifetime peak
  per Windows profile (not per save) and drives the medal and “Best Result”; the save's
  `global_<featkey>` drives “Current Progress”. Proof: the day-one
  `Bronzeman_pavao_croatia.ck2` carries `global_established=2.000` while Bronze needs
  4, so the medal can only be coming from the cache. The popup is a level-grant event,
  so it fires only on a *new* tier. Full write-up and the optional reset experiment:
  `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`.

### Still open (do not conflate with C08)

- **C25 — Paradox launcher Continue** still grey. Independent of engine V7.
  Breadcrumbs: `pdx_launcher.lib` `0xDE47C0` / `0xDE8BB0` / `0x99F540`,
  `launcher-v2.sqlite`. Hypothesis until those files are actually inspected.
- ~~**Feats reset after a cold quit→relaunch→load**~~ — **CLOSED 2026-08-30 by V9.**
  History, for the record:
  - 2026-08-27 re-opened. Hypothesis: the in-game counter is re-hydrated only by
    `CRulerFeatTracker::UpdateFeatProgress`, gated twice by
    `IsActiveForPlaythrough()`, and the featured-ruler match is lost on cold load.
  - 2026-08-29 V8 applied by hand → **"feats are 0 in game, and even in main menu
    (in MJ tab) too now"**. Premise disproven.
  - 2026-08-30 the V8 clean trace settled it: `UPDATE_ENTRY` fired on the cold path,
    `RULER_INFO_CHECK` passed (`rax≠0`, `zf=0`), `CALC_FAIL_PATH` never fired, and
    **`RESTORE_GATE al=1`** — so `IsActiveForPlaythrough` returned *true* on cold.
    The only failing line was `CALC_RETURN_PATH al=0`, i.e. the final gate
    `call 0x1400af690` at raw `0x007b7906`.
  - **V9** = that one call replaced by `mov al,1; nop; nop; nop`. Applied and
    confirmed working by the user.
  - ⚠️ **Identity drift is NOT refuted.** The 2026-08-27 line above said it was, on
    the strength of one capture. Four distinct `user_id` values are now on record for
    the same cache file. See `CONTRADICTIONS.md` §12.
  - ⚠️ The trace's `DAILY_GATE` breakpoint is `0x1000` off the patched byte
    (`+666146` vs `+667146`). See `CONTRADICTIONS.md` §13.
  - Tools: `ps1/patch_ck2_mj_v9.ps1`, `ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1`
    (paste-into-PowerShell), `bat/APPLY_CK2_MJ_V9.bat`, `bat/CHECK_CK2_MJ_V9.bat`,
    `bat/REVERT_CK2_MJ_V9_TO_V8.bat`, `x64dbg/MJ_V9_CLEAN_TRACE.*`.
    Guide: `04_test_guides_and_reports/CK2_MJ_V9_TEST_GUIDE.md`.

### Secondary (do not block on these)

- **DLC-marked ruler experiment tested 2026-08-31:** the optional payload toggle
  removes the initial DLC gate. The `dlc024` Aquitaine/French ruler starts and tracks;
  the three `dlc007` Muslim rulers immediately game-over without Muslim gameplay
  support, although initial feat values calculate first. This does not install or
  unlock official DLC. See `03_analysis/DLC_TEST_UNLOCK_RUNTIME_RESULTS.md`.
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
| `03_analysis/V9_DESIGN_ALTERNATIVES_AND_V8_DEPENDENCY.md` | Why V8's bytes can't be dropped from V9 + the abandoned `0x007B785B` design |
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
| V7 Continue | `57b18e43…` | `0x009E5B8B` `75 2f→eb 2f` | ✅ in-game Continue proven; useful revert target |
| V8 feat-rehydration | `94d6fb40…` | `0x00666546` + `0x007B786B` bypasses | ❌ applied on the user machine, **premise disproven** |
| **V9 cold-load feat fix** | `61e4345b…` | `0x007B7906` `e8 85 71 8f ff → b0 01 90 90 90` | ✅ **current baseline**, runtime-proven 2026-08-30 |
