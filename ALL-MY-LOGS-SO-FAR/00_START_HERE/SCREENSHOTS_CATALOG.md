# Screenshots catalog (authoritative descriptions)

Source: user-supplied names + what each shot was meant to show, merged with
archive/chat context.

> **2026-08-26 — image binaries removed.** All 56 screenshot/picture binaries
> (`.png`/`.jpg`/`.mp4`) were deleted from the repo. **This file is now the
> canonical record of every screenshot**: what it showed, why it was taken, and
> which Case/Finding/Peculiarity it maps to. The "What's on screen" column is
> the full textual substitute for the pixels — read it instead of re-uploading.
> The `.dds` files (`test.dds`, `test_versioned.dds`) were **kept** — they are
> binary patch artifacts (payload + loader-redirect name), not screenshots.
> `14_screenshots_and_media/` stays as an optional drop zone if a future session
> ever needs the actual pixels again.

Legend in **Case** column → `CASES_AND_FINDINGS.md`.

Suggested subfolders:
- `A_v6_continue_and_secondary` — open V7 + secondary boots
- `B_v4_v5_milestones` — load/continue/progress evolution
- `C_v2_v3_ui` — login gate, UI_MISSING, early patched UI
- `D_historical_mj_working` — when online MJ still worked
- `E_featured_rulers_predecessor` — FR generation
- `F_rewards_and_wiki` — score ladder, wiki tables, promo text
- `G_asset_folders` — texture directory listings
- `H_misc` — emu folder, flicker video, oddities

---

## A. V6 runtime / Continue / secondary (P0–P1)

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `Снимок экрана (1) still cant click continue.png` | A | **C08 UNSOLVED** | Continue still dead after V6 | Launcher/main: Continue from `Bronzeman_llywelyn_gwynedd` **grey** |
| `Снимок экрана (2) cant continue from main menu.png` | A | C08 | Continue failed from main menu | Popup “Continue failed / Continuing from the Save Game…” (DLC, newer version, mods, clock); Continue grey; MJ panel; “Cannot load autosave (Bronze)” behind |
| `Снимок экрана (2,5) multiplayer button breaks on second boot or when resigned from game and went to main menu from save.png` | A | **C09** | MP dies after 2nd boot / resign→menu | Main menu, MP circled; “Game State is corrupted. Please restart”; MJ = Doux Kulin |
| `Снимок экрана (3) multiplayer button is working on FIRST boot. old problem - all land is gray as if hes only person alive. maybe cause of that there flickering when hovering on smll prtrt.png` | A | C09, **C10**, C11 | First boot OK; grey map; link to flicker | MP works (circled); **all land grey**; MJ challenges panel. User note: grey = provinces with no ruler/history (seen after deleting character history; load then fills randoms) |
| `Снимок экрана (4)cant continue from there too.png` | A | C08 | Continue also fails from SP menu | “Continue failed” + Single Player menu |
| `Снимок экрана (5) from there it works.png` | A | **C07 SOLVED** | Manual Load path works | SP → Load Game; save `Bronzeman_llywelyn_gwynedd` — **this route works** (contrast Continue) |
| `Снимок экрана (6) cant pick anyone else (as intended probably).png` | A | **C16 INFO** | Bronzeman character lock | Llywelyn character window; arrow on random/switch; tooltip **“You cannot change character right now.”** |
| `Снимок экрана (7) when hovering on gauntlet it says that challange - bronzeman - wont work, but....png` | A | **C17 PARTIAL** | Stale gauntlet tooltip | Paused game; “Challenges: Disabled” rules tooltip; red circle on gauntlet beside Play |
| `Снимок экрана (15) when changed bookmark my character disapeared (not born yet actually).png` | A | **C14 INFO** | Bookmark before birth | Load/bookmark **7 Aug 936** Iron Century; right character panel **empty** (MJ ruler not born yet) |
| `Снимок экрана (16) was able to choose random ruler - with bronze still active - but mj interface disapeared on load (...).png` | A | **C13 PARTIAL** | Random ruler + Bronzeman | Game Rules: Bronzeman **Enabled**, Challenges **Enabled** (after map start). MJ UI gone on load per filename |
| `Снимок экрана (17) bronzeman, but no featured ruler crown.png` | A | C13 | Crown missing on Bronzeman save | Save/Load: `Bronzeman_Juyan 7 August 936` circled; also autosave + `Bronzeman_kulin bosnia 1 January 1173`; no featured-ruler crown |
| `Снимок экрана (18) when loaded bronzeman save (but before clicking play on map), then clicked 00back00, then loaded again quick (...).png` | A | **C15 PECULIARITY** | Transient empty panel + Observe Game | Load Game; right ruler panel empty (red); “Continue from savegame: autosave_bronzeman.ck2”; Observe / Play / Back — panel normal after seconds. Observe Game rarely seen |
| `(19 january of 2020) no arrow, multiplayer button not working.png` | A | **C12**, C09 | Missing MJ arrow; MP dead | Main menu MJ for **Duke Pavao**, score **47**, reward **Cone Shaped Hennin**; **no** open-arrow; MP dead |
| `when feature was going to end such things occured - no score grayed play button, grayed arrows to change rulers. play button appeared when no internet, with date set to earlier time.png` | A/D | **C18 SOLVED** (payload dates) | Time-gate death mode | MJ **King Stefan**: score 0, **grey Play**, **grey arrows**, reward Chaperon 30 as if unearned, empty bar. Play returned offline + earlier system clock |
| `xami5llmaht31.jpg` | A/D | C18 | Same end-of-feature state, other ruler | Same grey Play/arrows/no score class as above |
| `flickering. either it gets fixed when we fix gray map, or we disable information popping up there.mp4` | A | **C11** | Portrait hover flicker | ~11s 480×480: MJ challenges over **all-grey map**; small portrait hover → info popup flickers. Fine once in-game. Fix with grey map or disable popup |
| `map (see how normally it should look when choosing ruler).png` | A | C10 contrast | **Healthy** ruler-pick map | Full map + menu + MJ; most land **coloured** (red circle). Contrast to grey “only person alive” |
| `Снимок экрана (256).png` | A | **C22 SOLVED** | Bronze tier grant works | Achievement: rank **Bronze** in **Established** challenge |

---

## B. V4 / V5 milestones (load, continue, progress)

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `Снимок экрана (214).png` | B | **C05 SOLVED** | Live progress exists | **Heretical Company** tooltip: Bronze **1/6**, Silver 1/9, Gold 1/12 (stuck at 1 that session) |
| `Снимок экрана (215).png` | B | **C24 INFO** | Install / emu layout | Explorer list of CK2 folder (pirated): `CK2game.exe`, steam emu DLLs, `pdx_online.dll`, tbb, SDL2, … — environment evidence only |
| `Снимок экрана (217).png` | B | C08 | Continue still grey mid-V4/V5 arc | Continue greyed |
| `Снимок экрана (218).png` | B | C03→solved | Play starts working on MJ panel | Play enabled in main-menu MJ window |
| `Снимок экрана (219).png` | B | C08 | SP Continue grey | Single Player; Continue greyed |
| `Снимок экрана (221).png` | B | C03 | Play working | Main menu MJ; Play already working |
| `Снимок экрана (222).png` | B | **C02 SOLVED** | Login wall on Load list | SP Load Game: “Monarch’s Journey requires you to be logged in to a Paradox Account” |
| `Снимок экрана (224).png` | B | C08 / was load path | Continue failed popup | Main menu “Continue failed” on existing save *(load side later fixed; Continue not)* |
| `Снимок экрана (225).png` | B | C09 | Corrupted state + MP | MP circled; “Game State is corrupted…”; MJ Kulin *(bug or intentional hard-stop)* |
| `Снимок экрана (226).png` | B | **C08 UNSOLVED** | Continue failed still | Continue failed + SP menu; Continue circled — **not fixed yet** |
| `Снимок экрана (227).png` | B | C03 / mixed old | Challenges disabled gauntlet | “Challenges: Disabled” tooltip; red circle on bronze gauntlet + **!** |
| `Снимок экрана (228).png` | B | **C06 SOLVED** | Progress lost after load | Heretical Company **0/6** after load *(fixed by V6)* |
| `Снимок экрана (229).png` | B | C23, P8 | In-game history tooltip; no flicker in-game | Map + MJ panel; Kulin portrait circled; history tooltip; **no flicker** in this zone in-game |

---

## C. V2 / V3 UI (login gate, UI_MISSING, early panel)

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `Снимок экрана (182).png` | C | C02 fixed | Login wall on Kulin | MJ Doux Kulin; Play; “Log in to your Paradox Account to play Featured Rulers and earn Rewards!” |
| `Снимок экрана (188).png` | C | C11 | Flicker target | Kulin Challenges; portrait **circled red** (flicker problem) |
| `Снимок экрана (192).png` | C | C02 | Login + challenges | Same Kulin challenges + main menu login notice |
| `Снимок экрана (193).png` | C | INFO | What “Monarch’s Journey” means | Tooltip on title: Featured Rulers pre-selected; Challenges → Score → Rewards |
| `Снимок экрана (194).png` | C | C02 | Login on other rulers | Harald IV Hardråde + login notice |
| `Снимок экрана (195).png` | C | C02 | | Sultana Arwa + login |
| `Снимок экрана (196).png` | C | C02 + DLC | Grey map + grey Play for DLC | Title 3.3.3; Queen Shajar; grey map except her lands; login; Play grey **for missing DLC** |
| `Снимок экрана (197).png` | C | C02 | | Louis II the Stammerer + login |
| `Снимок экрана (198).png` | C | **C23** | Are history blurbs in-game? | Saad Mordechai + long historical tooltip (1289 AD) — **yes, in payload localisation** |
| `Снимок экрана (199).png` | C | C02 | | Llywelyn + login notice |
| `Снимок экрана (202).png` | C | **C04** | UI_MISSING reward strip | “UI Missing…” score; “UI Missing Text” reward name/points; “UI_Missing_Text” description |
| `Снимок экрана (203).png` | C | C21 / F2 | Reward unlock chrome | Score **136**; circle on unlocked **Joan of Arc**; “Reward Unlocked” |
| `Снимок экрана (204).png` | C | INFO | Some challenges done | Low value — completed challenges montage |
| `Снимок экрана (205).png` | C | C04 | Completed but missing text | Challenges done + UI missing text |
| `Снимок экрана (206).png` | C | C01/C04 | Partial reward UI | Score **2**, Wizard’s Beard, “No time to shave…”, **8 points** until reward |
| `Снимок экрана (207).png` | C | INFO | How MJ looks | Same class as 206 |
| `Снимок экрана (208).png` | C | INFO | Konan empty progress | Konan, score 0, 10 points to reward |
| `Снимок экрана (209).png` | C | INFO | | Same as 208 |
| `Снимок экрана (210).png` | C | C04 | | UI Missing Text |
| `Снимок экрана (213).png` | C | **C03 SOLVED** | Challenges rules block Start | Game Rules: Achievements disabled when Challenges on; Start blocked “Challenges must be enabled” *(old — fixed)* |

---

## D. Historical MJ when it still worked (online / community)

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `7k2d9u8x2ht31.jpg` | D/F | F2 | Working challenges + first reward | Konan Challenges: Time Bending, Gloves Come Off, Pre-Emptive Self-Defense; score 0; reward Wizard’s Beard, 10 pts, flavor text |
| `YPmxNMB.png` | D/F | F2 | All challenges Gold | Same layout as 7k2… with **all gold** complete |
| `upload_2019-10-27_12-26-20.png` | D/F | F2 | Score drives bar (“2 points to reward”) | Same family; **score 18** → progress bar length / “2 points to this reward” |
| `8b2cpjl9t9w31.png` | D | C09, C04 contrast | Healthy reward text vs UI_MISSING; grey MP | Wide main menu; Llywelyn MJ + long history tooltip; CK3 “Read More” left; **grey MP**; real “2 points to this reward” under icon (not UI_MISSING) |
| `v276klwr66031.png` | D/E | INFO | Clean FR/MJ panel nothing wrong | 3.3.3 main menu; Llywelyn “Develop an Independent Wales…”; Create Paradox Account; Steam friends score — **nothing off** |

---

## E. Featured Rulers predecessor (future project)

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `1 ruler.png` | E | **C20** | FR Hugues | Count Hugues “the Devil”; Time Remaining **6 days**; Continue/Restart; Wroth, Brave, Cynical |
| `2 ruler (portrait corrupted by Better Looking Garbs).png` | E | C20, P4 | FR Johann + mod break | Johann Blind Bohemia; Blind, Crusader, Brave, Chaste, Tough Soldier; portrait corrupted by BLG |
| `3 ruler.jpg` | E | C20 | FR Arwa | Arwa; TR 4 days; Genius, Poet, Hafiz, Mastermind Theologian |
| `4 ruler.png` | E | C20 | FR Mindaugas + history tooltip | Mindaugas 1236; Just, Temperate, Socializer |
| `5 ruler.png` | E | C20 | FR Charles Hungary | Charles I 1307; Just, Kind, Lisp, Tough Soldier |
| `6 ruler.png` | E | C20 | FR Mauregato | Mauregato Astorga 769; Deceitful, Envious, Amateurish Plotter |
| `7 ruler.png` | E | C20 | FR Bohemond + first challenges | Bohemond; TR 5 days; Brilliant Strategist… **and** Challenges panel: Bye Zantium!, Blood sweat & tears, Vassaline! |
| `8 ruler.png` | E | C20 | FR Petronila | Petronila Aragon; Amateurish Plotter, Proud, Kind, Content, Honest |
| `9 ruler.png` | E | C20 | FR Llywelyn + Steam friends line | Llywelyn; TR 9 days; “Compete against Steam friends…” |
| `10 ruler.jpg` | E | C20 | FR Tamari | Tamari Georgia; TR 9 days; Grey Eminence, Charitable, Patient, Diligent, Lustful, Zealous |
| `11 ruler.png` | E | C20 | FR Nuno + DLC sale | Nuno Portugal; TR 9 days; “DLC on sale! … Reaper’s Due!” |
| `12 ruler.png` | E | C20, P2 | FR Mihajlo + mystery icon | Mihajlo; Scholarly Theologian…; user red arrow on **crowd/three-figures** icon under ruler/challenges tabs — identity unknown |

---

## F. Rewards, wiki tables, promo copy

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `Screenshot 1.png` | F | F2, roster | Official MJ table pt1 | Rewards ladder Wizard’s Beard 10 → Joan 110; rows Robert de Hauteville, Llywelyn, Saad, Konstantinos, Louis, Tamar… |
| `Screenshot 2.png` | F | F2, roster | Official MJ table pt2 | Arwa, Harald, Mindaugas, Kulin, Bohemond, … |
| `Screenshot 3.png` | F/E | C20 | **FR** table (not MJ) | Featured Ruler list: Llywelyn, Johann Blind, Arwa, Mindaugas, Petronilla… |
| `q2pkrvbmwml51.jpg` | F | F2 | Reward ladder only | Wizard’s Beard 10 → … → Mullet 70 → **Miller 90** → Joan 110 |
| `seen this text somewhere.png` | F | INFO | Official MJ pitch → CK3 cosmetics | CK3 promo wall of text: Ruler Challenges, special cosmetic rewards for CK3, medieval sandbox… |
| `Screenshot 1.png` / `2.png` / `3.png` | F | roster | Full wiki tables | **Entire content transcribed** into `FR_MJ_COMPLETE_ROSTER.md` — images optional |
| `Ck3_reward_beard_t69X.png` | F | **C21** / F2 | CK3 cosmetic reward icon — Wizard's Beard (10) | beard icon from the reward strip |
| `Ck3_reward_hair_male_t69X.png` | F | C21 / F2 | reward icon — The Pageboy (20) / Medieval Mullet (70) | male hair icon |
| `Ck3_reward_hat_t69X.png` | F | C21 / F2 | reward icon — Chaperon (30) | hat icon |
| `Ck3_reward_chest_t69X.png` | F | C21 / F2 | reward icon — Jester's Hat (40) | chest icon |
| `Ck3_reward_veil_t69X.png` | F | C21 / F2 | reward icon — Cone Shaped Hennin (55) | veil icon |
| `Ck3_reward_hair_female_t69X.png` | F | C21 / F2 | reward icon — The Miller (90) / The Joan of Arc (110) | female hair icon |

These six `Ck3_reward_*` icons are the 8 ladder tiers collapsed into 6 textures
(`hair_male` and `hair_female` each serve two tiers). Case **C21 / F2**.

Miller = **90** (confirmed from wiki paste).

---

## G. Asset folder listings

| File | Drop | Case | Intended to show | What’s on screen |
|---|---|---|---|---|
| `Снимок.PNG` | G | F10 | FR texture pack present on disk | Folder `gfx\interface\featured_ruler` — arrows, feat frames bronze/silver/gold, reward icons, tabs… |
| `Снимок2.PNG` | G | F10 | MJ `highlighted_*` pack present | Folder `gfx\interface` — full `highlighted_*` set (event bgs, leaderboard, pause, crown, DLC sale anim…) |

---

## H. Quick filename → case cheat sheet

```
UNSOLVED V7:     (1) (2) (4) (217) (219) (226) [and Continue side of 224]
SECONDARY:       (2,5) (3) (225) | grey map+flicker | (19 jan) arrow | (16)(17)
SOLVED load:     (5) (218) (221) (228 fixed) (256)
SOLVED login:    (182)(192–199)(222)
SOLVED UI_MISS:  hidden — (202)(205)(210) are the before
TIME GATE:       when feature was going to end… | xami5…
FR FUTURE:       1 ruler … 12 ruler | Screenshot 3 | v276…
REWARDS REF:     7k2… YPmx… upload_2019… q2pkr… Screenshot 1–2 | (203)
```

---

## I. After you drop the files

1. Put each file in the **Drop** subfolder (or flat into `14_screenshots_and_media/` if easier).
2. Tell the agent “screenshots uploaded” — it should verify names, fix any Miller 70/90 mismatch from pixels, and label the crowd icon if visible.
3. No need to re-upload patchers/logs already in `05_`–`13_`.

---

## J. Where screenshots are still mentioned (after 2026-08-26 deletion)

The image *files* are gone, but their *filenames + descriptions* still appear in:

- **This file** — the authoritative per-shot description + Case mapping (sections A–H).
- `CASES_AND_FINDINGS.md` — the Case map (C01–C24), Findings F1–F10 and
  Peculiarities P1–P8 all cite screenshots by name as evidence.
- `STATUS.md` — "Still broken / Secondary" cites `log playing with new v6 patch/`
  screenshots (1)(2)(4) and `v6 second look/` items.
- `FR_MJ_COMPLETE_ROSTER.md` — transcribed wiki Screenshot 1/2/3 content.
- `FEATURED_RULERS.md` — references the `1 ruler…12 ruler` FR shots.
- `01_research_archives/*` and raw chat logs — narrate the shots being read
  (e.g. Part 2 S4: screenshots (224)–(229)).
- `MASTER_ARTIFACT_TABLE.md` / `EXECUTABLE_IDENTITIES.md` — hash-reference the
  payload (`monarchs`, `fc6ec025…`) that `test.dds` duplicates.

Note: some screenshots were **never** uploaded at all (the upload failed) and so
never had binaries — those are catalogued here purely by description: (182)(188)
(192)–(199)(204)(205)(208)(209)(210)(213)(214)(217)(218)(219)(221)(222)(223),
`YPmxNMB.png`, `upload_2019-10-27_12-26-20.png`, `8b2cpjl9t9w31.png`,
`v276klwr66031.png`, `xami5llmaht31.jpg`.
