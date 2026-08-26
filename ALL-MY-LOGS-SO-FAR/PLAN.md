# Step-by-step plan — CK2 Monarch's Journey restoration

## The main goal
**Bring back Monarch's Journey for personal offline Windows use** — panel,
Bronzeman, live tracking, saves, **Continue**, and as much reward UI as is
local — without losing research history. **Featured Rulers** is a separate
follow-on once MJ Continue works (`00_START_HERE/FEATURED_RULERS.md`).

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

## PHASE 2 — V7 Continue enable fix ⬅ current
**Case C08.** Continue greyed = *enable predicate*, not click handler.
V6 already patched account branch in helper `0x1409e4970`.
Knowledge base is consolidated: `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md`
(2.6.1.1 model → win333 anchors, two-helper CFG correction, rejection-path
breadcrumbs, ordered steps). The old triage/CFG notes were merged into it
(2026-08-26).

- [ ] Anchors: Linux `GetContinueSave` ↔ win333 `0x1409e5500` region;
      callers `0x1407bffa1`, `0x1408145ec`, `0x140a0ba62`
- [ ] Map `_bIsContinueSaveValid` / `RefreshContinueButton` equivalents
- [ ] Hypotheses: FR-marker in continue validator; account-bound session flag;
      cloud/timestamp; widget refresh order
- [ ] Guarded `patch_ck2_mj_v7.ps1` + bats; hash-guard from exact V6 SHA
- [ ] Offline test: Continue clickable? Loads Bronzeman with progress?
- Evidence shots: catalog **A** — (1)(2)(4)(5)(217)(219)(226)

## PHASE 3 — Secondary polish (after V7)
Cases C09–C12, C13, C17: MP 2nd boot, grey map, flicker mp4, missing arrow,
random-ruler MJ loss, gauntlet tooltip.

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
1. You drop **A_v6_continue_*** images into `14_screenshots_and_media/`.
2. Agent (or you) starts **Phase 2 V7** on May-2020 win333 exe with triage doc.
