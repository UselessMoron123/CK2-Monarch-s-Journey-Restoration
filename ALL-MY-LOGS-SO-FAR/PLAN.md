# Step-by-step plan — CK2 Monarch's Journey restoration

## The main goal
**Bring back Monarch's Journey for personal offline Windows use** — panel,
Bronzeman, live tracking, saves, **Continue**, and as much reward UI as is
local — without losing research history. **Featured Rulers** is a separate
follow-on (`00_START_HERE/FEATURED_RULERS.md`). In-game Continue is done (V7);
launcher Continue is C25.

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
