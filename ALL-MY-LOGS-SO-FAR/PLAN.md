# Step-by-step plan — CK2 Monarch's Journey restoration

## The main goal
**Bring back Monarch's Journey for personal offline Windows use** — panel,
Bronzeman, live tracking, saves, **Continue**, and as much reward UI as is
local — without losing research history. **Featured Rulers** is a separate
follow-on (`00_START_HERE/FEATURED_RULERS.md`). In-game Continue is done (V7);
cold-load feats are done (V9, 2026-08-30); launcher Continue is C25.
**Current baseline: V9** `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`.

---

## PHASE 0 — Organisation & continuity ✅
- [x] Sort dump into labeled subfolders
- [x] MD5-delete all perfect duplicates (`99_duplicates/` gone; outside clones removed)
- [x] Rescue unique `system2.log` into `07_runtime_logs/`
- [x] Research Archive Parts 1–3 + chat `INDEX.md`
- [x] **Cases / findings index** → `00_START_HERE/CASES_AND_FINDINGS.md`
- [x] **Screenshot catalog** (user descriptions + intent) → `SCREENSHOTS_CATALOG.md`
- [x] **Featured Rulers notes** → `FEATURED_RULERS.md`
- [x] Drop folders `14_screenshots_and_media/A`…`H` (optional — user prefers text
      descriptions; sessions froze on big image uploads)
- [x] Full FR+MJ roster transcribed from wiki/Screenshot 1–3 text →
      `FR_MJ_COMPLETE_ROSTER.md` (no pics required)
- [ ] Image binaries optional only if a future session needs pixels

## PHASE 1 — Knowledge base ✅
- Master artifact table, patch map CSV, banned register, Continue semantic
  reference (2.6.1.1 PDB → win333), contradictions register, 3.3.5.1 port
  assessment (port not feasible).

## PHASE 2 — V7 in-game Continue execution ✅
**Case C08 SOLVED.** The remaining V6 failure was not the enable predicate.
Continue *execution* at `0x1409E6700` failed the retired cloud-sync byte
`[rsi+0x63]` and constructed `CContinueFailedPopup` (`0x140726560`).
V7: `0x009E5B8B` `75 2f → eb 2f`. Hash
`57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`.
Live Kulin load in `03_analysis/V7_RUNTIME_RESULTS.md` / Part 4.

- [x] Guarded `patch_ck2_mj_v7.ps1` + APPLY/CHECK/REVERT bats
- [x] Offline test: in-game Continue loads Bronzeman without popup
- [ ] Paradox launcher Continue (split out as **C25**, not Phase 2)

## PHASE 2b — V8 disproven, V9 cold-load feat fix ✅ (2026-08-30)
**Case C26 SOLVED.** V8 bypassed the two `IsActiveForPlaythrough` gates
(raw `0x00666546`, `0x007B786B`) and made things **worse** — feats 0 in game *and* in
the main-menu MJ tab. A clean attach-mode x64dbg trace then isolated the real failure:
`CalcShouldTrackFeatProgress` returns 0 at its **final** gate, raw `0x007B7906`
(`call 0x1400AF690`), while every earlier check passes on a cold load.

V9 replaces that one 5-byte call with `mov al,1; nop; nop; nop`. Hash
`61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`.

- [x] Guarded `patch_ck2_mj_v9.ps1` + APPLY/CHECK/REVERT bats
- [x] `py/build_v9_chain.py` — replays V2→V9 asserting every hash (re-run clean 2026-08-30)
- [x] `RUN_APPLY_CK2_MJ_V9_INLINE.ps1` — paste-into-PowerShell route (reconstructed 2026-08-30)
- [x] Clean-trace helper `x64dbg/MJ_V9_CLEAN_TRACE.*`
- [x] Offline test: feats survive soft resign **and** hard quit, and increase during play
- [x] **C27 answered:** medal / “Word has spread…” behaviour is by design —
      `FEAT_CACHE_PEAK_TIER_ICON.md`
- [ ] Fix the `DAILY_GATE` typo in `MJ_V9_CLEAN_TRACE.txt` (`+666146` → `+667146`)
      and re-publish its hash — `CONTRADICTIONS.md` §13
- [ ] Optional: run the V9 clean trace for machine proof of `V9_GATE_FORCE`

## PHASE 3 — Secondary polish ⬅ current
Cases C09–C12, C13, C17: MP 2nd boot, grey map, flicker mp4, missing arrow,
random-ruler MJ loss, gauntlet tooltip. Optional C25 launcher Continue.

## PHASE 4 — Separate projects
- [ ] Local reward gallery (ladder in `FR_MJ_COMPLETE_ROSTER.md` §0; Linux SetupRewards)
- [ ] Recover missing rulers / full late payload — content specs already in
      `FR_MJ_COMPLETE_ROSTER.md` §2.12–2.16 + §3 (need DNA/scripts from a late dump)
- [ ] **Featured Rulers restore** — checklist `FEATURED_RULERS.md` §8; content §1 of roster
- [x] Transcribe full FR+MJ wiki/screenshot tables to text (no image upload required)

## PHASE 5 — Hygiene ongoing
- [ ] Upload screenshots; verify Miller 70 vs 90 and crowd icon from pixels
- [ ] Personal storage list: exes, Base64+manifests, PDB, screenshots, saves, patch scripts

---

## Suggested next move
1. Play on V7 (`CK2game.exe` launched directly). Optional: drop Continue-success
   screenshots into `14_screenshots_and_media/` catalog **A**.
2. Optional Phase 3 polish, or C25 launcher Continue, or Featured Rulers.
