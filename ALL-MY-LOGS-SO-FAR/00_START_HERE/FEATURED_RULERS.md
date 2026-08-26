# Featured Rulers — notes for a later restore

Monarch’s Journey (MJ) was **built on** the earlier **Featured Rulers (FR)**
system. You said you will probably want FR working too. This file freezes
everything we know so a future session does not re-derive it from chat noise.

Related:
- **`FR_MJ_COMPLETE_ROSTER.md`** — full FR+MJ bios and every Bronze/Silver/Gold
  challenge table (text-only; no images needed). **Start here for content.**
- `06_game_data/descriptions and challenges.txt` — raw wiki paste
- `06_game_data/Featured ruler.txt` — forum thread on partial rollout
- `06_game_data/LT_featured_ruler.txt` — LT.62001/62002 events
- Texture inventories described in screenshot catalog (`Снимок.PNG` / `Снимок2.PNG`)
- Ruler screenshots `1 ruler`…`12 ruler`, `Screenshot 3.png` (optional; catalog has text)

---

## 1. Timeline & relationship to MJ

| When | What |
|---|---|
| Pre–3.3 (2019, gradual remote rollout) | **Featured Rulers** — subset of players only (`can_see_highlighted_rulers` remote flag). Forum: some accounts see the box, some don’t, for months. |
| **2019-10-20**, patch **3.3** | **Monarch’s Journey** ships, “uses the previous Featured Rulers system as its base.” |
| 3.3.x biweekly | New MJ ruler added; old ones kept via top-right arrows. |
| ~2021-01-01 (`event_time_end` 1609502400) | Global kill date on payload entries. |
| Post–May 2020 / 3.3.5.1 | Local payload path / GameSparks pieces removed or gutted — see port assessment. |

**Practical meaning:** same GUI object names / highlighted-ruler machinery,
different **content shape** and **chrome** (Time Remaining vs score/rewards).
Restoring FR is mostly **data + which UI branch shows**, not a second engine.

---

## 2. UI differences (from your screenshots)

| Element | Featured Ruler (early) | Monarch’s Journey |
|---|---|---|
| Title chrome | “Featured Ruler” | “Monarch’s Journey” |
| Timer | **Time Remaining: N days** | end date in payload; no “N days” strip in later shots |
| Challenges | Often **none** on early rulers; full set from ~Bohemond / 7th+ | 3 challenges × Bronze/Silver/Gold standard |
| Score / rewards | Weak or absent; Steam-friends line | Score bar + CK3 cosmetic ladder |
| Marketing | “DLC on sale! Enjoy with The Reaper’s Due!”, CK3 “Read More” banner | CK3 promo still appears left on some builds |
| Account | “Create a Paradox Account!”, “Compete against Steam friends…” | “Log in to play Featured Rulers and earn Rewards!” (same backend family) |
| Right arrow | Slightly different art (`arrow_round_*` vs later) | MJ arrows; can go missing some boots |
| Tabs | Ruler / challenges; mystery **crowd/three-figures** icon under tabs | Feats / info tabs (`tab_feats`, `tab_info` textures) |
| Play mode | Featured run (Bronzeman lineage) | Explicit **Bronzeman** |

Shots: `1 ruler` Hugues … `12 ruler` / `7 ruler` Bohemond challenges;
`v276klwr66031` clean Llywelyn FR-era; `8b2cpjl9t9w31` MJ+CK3 banner+grey MP.

---

## 3. FR roster captured in your images / wiki dump

Ordered as in `descriptions and challenges.txt` “From the oldest…” FR section
and your `N ruler` files:

| # | Character | Start | Tagline (short) | Challenges in dump | Your shot |
|---|---|---|---|---|---|
| 1 | Hugues de Lusignan, Count of Lusignan | 1066 | Join the Crusades as the Devil of Lusignan! | **None** | `1 ruler.png` — Time Remaining 6 days; Wroth, Brave, Cynical |
| 2 | Johann “the Blind”, King of Bohemia | 1337 | Become the Blind Warrior of Bohemia! | **None** | `2 ruler…png` — Blind, Crusader, Brave, Chaste, Tough Soldier; BLG mod broke portrait |
| 3 | Arwa Sulayhid, Sultana of Yemen | 1074 | Discover God’s Will in her lifetime! | **None** *(later MJ has full set)* | `3 ruler.jpg` — Genius, Poet, Hafiz, Mastermind Theologian; TR 4 days |
| 4 | Mindaugas, High Chief of Lithuania | 1236 | Unravel the mystery of … King! | **None** in early FR list; **full** in late MJ wiki | `4 ruler.png` |
| 5 | Charles I (de Anjou), King of Hungary | 1307 | Bring prosperity to the Kingdom of Hungary | **None** | `5 ruler.png` — Just, Kind, Lisp, Tough Soldier |
| 6 | Mauregato, Count of Astorga | 769 | Secure the king title; stop nobles taking the realm | **None** | `6 ruler.png` — Deceitful, Envious, Amateurish Plotter |
| 7 | Bohemond d’Hauteville, Prince of Antioch | 1098 | Opportunities fall like autumn rain | **Yes:** Bye Zantium!; Blood, sweat & tears; Vassaline! | `7 ruler.png` (+ challenges panel) |
| 8 | Petronila Jimena, Queen of Aragon | 1157 | Child ruler, last of a dynasty | **Yes:** Arastrong!; Arastay!; Aragonastop? | `8 ruler.png` |
| 9 | Llywelyn II “the Great”, Gwynedd | 1195 | Independent Wales and further | **Yes:** Dragon’s Fire; Princes of Wales; Love Spoons | `9 ruler.png`, also MJ shots |
| 10 | Tamari, Queen of Georgia | 1184 | Recreate the Golden Age of Georgia | **Yes:** Megaloscheme; Hot Tamari; Golden Girls | `10 ruler.jpg` — Grey Eminence, Charitable, Patient, Diligent, Lustful, Zealous; TR 9 days |
| 11 | Nuno II, Duke of Porto / Portugal | 1066 | Become King… try not to die on the way | **Yes:** King of Portugal; Money Order!; Ahead of their time | `11 ruler.png` — DLC sale banner; Charismatic Negotiator, Greedy, Brave, Stubborn, Gregarious |
| 12 | Mihajlo, King of Serbia | 1066 | Unite nations; true King of the Slavs | **Yes:** Serbian Dream; With or Without Me?; Papal Support | `12 ruler.png` — Scholarly Theologian, Patient, Deceitful, Stubborn, Gregarious; **crowd icon** annotated |

`Screenshot 3.png` = FR table rows (Llywelyn, Johann Blind, Arwa, Mindaugas,
Petronilla, …).

---

## 4. Overlap with current MJ payload (11 rulers)

**In both worlds (payload keys today):**
Llywelyn, Arwa, Mindaugas *(if late payload — **not** in current 11)*, plus MJ-only
set Konan, Saad Mordechai, Konstantinos, Louis Stammerer, Shajar, Pavao, Harald,
Hethum, Kulin.

**Current `gfx\monarchs` keys (May 3.3.3 restore target):**
```
konan_brittany, llywelyn_gwynedd, mordechai_al_dawla, konstantinos_samos,
louise_aquitaine, shajar_egypt, pavao_croatia, arwa_yemen, harald_norway,
hethum_armenia, kulin_bosnia
```

**FR-only / missing from current payload (need another dump to play as FR or late MJ):**
Hugues, Johann Blind, Charles Hungary, Mauregato, Bohemond, Petronila, Tamari,
Nuno, Mihajlo, (+ late MJ) Liao Hongji, Basarab, Botstain, Stefan Nemanjic,
Mindaugas if not present, …

---

## 5. Rollout peculiarity (why FR “wasn’t there” for some players)

`06_game_data/Featured ruler.txt` preserves a forum thread:

- Feature appeared only for **some Steam accounts**.
- PDX: still being rolled out; months later still uneven.
- Not explained by “all DLC” (counterexamples both ways).
- `settings.txt` crumb: `last_event_shown="bohemond_antioch"`.
- Remote flag `can_see_highlighted_rulers` in payload JSON is the local mirror
  of that gate — our restore forces it to `1`.

For a **personal offline FR restore**, remote rollout is irrelevant: ship a
local payload the parser accepts and skip account gates the same way MJ v4 did.

---

## 6. Assets still in a stock install

From `Снимок.PNG` — `gfx/interface/featured_ruler/`:
```
arrow_round_left/right.dds, arrow_small_left/right.dds,
feat_bg.dds, feat_bg_pause.dds,
feat_frame_bronze/gold/silver.dds, feat_frames.dds, feat_icon.dds,
reward_icon_beard/bg/chest/hat/lady.dds,
reward_icon_hair_female/male.dds, reward_progress_frame.dds,
ruler_bg.dds, tab_feats.dds, tab_info.dds
```

From `Снимок2.PNG` — `gfx/interface/highlighted_*` (MJ-era chrome):
```
highlighted_ad_bg, highlighted_bg, highlighted_crown_smaller,
highlighted_dlc_sale(+anim), highlighted_entry_big/tiers,
highlighted_event_art, highlighted_event_bg_{bronze,gold,regular,silver},
highlighted_event_ended/info/running_out, highlighted_extend/icon/chalice,
highlighted_leaderboard_tabs,
highlighted_main_{feats,ruler,social}_bg,
highlighted_new_content_banner,
highlighted_pause_{feats,menu_bg_area,ruler,social},
highlighted_ruler_bg/save,
highlighted_start_notification(_anim)_yellow,
highlighted_sub_{achievements,highscore,ruler},
highlighted_tab_anim_yellow, highlighted_tab_flash,
highlighted_top_players_entry
```

**Conclusion:** art is not the blocker. Missing pieces are (1) **payload entries**
for FR-only rulers, (2) whichever **UI branch** chooses FR chrome vs MJ chrome,
(3) the same **account/time gates** already beaten for MJ.

---

## 7. Events / script crumbs

- `LT_featured_ruler.txt` — namespace `LT`, ids **LT.62001–62002** (and comment
  block LT.61000–61999): hidden events tracking conversion flags for Arwa-style
  challenges (`was_converted_by_arwa_al_sulayhi`, `character_converted_to_shia`).
- Challenge scripts live inside the JSON payload (`feats_script`), not as
  normal `common/…` event files for the full set.
- Bronzeman validation vocabulary: `RedKing.csv`.

---

## 8. What “make Featured Rulers work” should mean (future checklist)

Do **not** start this until Continue-V7 is done unless you explicitly reprioritize.

1. **Define success:** FR panel chrome + Time Remaining + at least the FR-only
   roster playable offline in Bronzeman, with or without MJ score strip.
2. **Get data:** hunt a pre-MJ or early-3.3 payload / GameSparks cache /
   `common/monarchs_journey` from an install that still had Hugues…Mihajlo.
   Wiki + your `N ruler` shots are enough to **author** JSON if schema is known
   (schema documented in Research Archive Part 1).
3. **UI branch:** compare `highlighted_ruler_gui.txt` / frontend bindings for
   strings only used in FR (“Time Remaining”, DLC sale). Decide show-FR vs show-MJ
   vs hybrid.
4. **Reuse MJ patches:** factory branch, LEA payload path, account/eligibility
   gates, time-end rewrite — almost certainly the same binary hooks.
5. **Don’t expect:** Steam friends leaderboard, real CK3 unlocks, remote
   staggered rollout.

---

## 9. Open questions (answer when FR project starts)

1. Is FR chrome selected by **payload version/fields** or by **exe build**?
2. What exact JSON field drove **Time Remaining** (derived from `event_time_end`?)?
3. Is the crowd/three-figures icon leaderboard, co-op, or dead control?
4. Can one payload list **both** FR-era and MJ-era rulers, or did PDX replace the file wholesale each biweekly?
5. Do FR-only rulers without challenges still require Bronzeman?

---

## 10. Screenshot drop folder for FR

`14_screenshots_and_media/E_featured_rulers_predecessor/`

Priority files: `1 ruler.png` … `12 ruler.png`, `Screenshot 3.png`,
`v276klwr66031.png`, `2 ruler (portrait corrupted…)`, map reference if FR-specific.
