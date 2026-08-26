Drop image files here (keep original filenames).

Subfolders:
  A_v6_continue_and_secondary/   P0 — Continue grey + MP/grey-map/flicker
  B_v4_v5_milestones/            load/continue/progress arc
  C_v2_v3_ui/                    login gate, UI_MISSING
  D_historical_mj_working/       when online MJ worked
  E_featured_rulers_predecessor/ Featured Rulers generation (future project)
  F_rewards_and_wiki/            score ladder, wiki tables, promo
  G_asset_folders/               Снимок.PNG / Снимок2.PNG texture lists
  H_misc/                        anything else

Full descriptions: 00_START_HERE/SCREENSHOTS_CATALOG.md
Cases index:       00_START_HERE/CASES_AND_FINDINGS.md
Featured Rulers:   00_START_HERE/FEATURED_RULERS.md

---

Decision (2026-08-26, session arena/01a03d31):

Raw screenshot pixels stay OUT of the repo. The 18 V6/V5-era shots from the
unmerged branch arena/01a02609 were located, verified byte-identical to the
originals, and deliberately NOT re-added — the text descriptions in
SCREENSHOTS_CATALOG.md / CASES_AND_FINDINGS.md are canonical and sufficient.
Do not re-upload them; the source branch still holds the files if pixels are
ever truly needed.

Recovery map for that branch (case-style, numbers = catalog rows):

- V6 runtime set — branch folder "log playing with new v6 patch":
    Continue grey after V6: launcher + main menu + SP menu (1)(2)(4)
    manual Load Game works (5)
    Bronzeman character lock, "cannot change character" (6)
    stale gauntlet tooltip, "challenges disabled" hover (7)
    bookmark before the featured ruler is born (15)
    random-ruler load keeps Bronzeman but drops MJ interface (16)
    featured-ruler crown missing on Bronzeman save (17)
    transient empty panel / Observe state on quick re-load (18)
    multiplayer: first boot OK but grey map (3); breaks on second
    boot / resign-to-menu with "Game State is corrupted" (2,5)

- V5-failure era — branch folder "things parent AI asked to upload":
    Continue-failed popups (224)(226)
    corrupted state + multiplayer circled (225)
    challenges-disabled gauntlet with "!" (227)
    progress lost after load, 0/6 — pre-V6 (228)
    in-game history tooltip / no in-game flicker (229)
