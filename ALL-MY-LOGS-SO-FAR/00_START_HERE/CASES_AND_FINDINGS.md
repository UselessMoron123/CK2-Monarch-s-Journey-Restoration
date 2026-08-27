# Cases, findings, peculiarities — screenshot-backed index

Last updated from the user’s full image catalog (text descriptions of every
shot gathered so far). **Image binaries were removed 2026-08-26** — the
descriptions here (Cases C01–C24, Findings F1–F10, Peculiarities P1–P8) are the
canonical record and cite screenshots by name. Cross-ref:
`SCREENSHOTS_CATALOG.md`, `FEATURED_RULERS.md`.

Status tags:
- **SOLVED** — fixed by a known patch gen / payload change; do not re-open
- **PARTIAL** — core works, remaining edge / cosmetic
- **UNSOLVED** — open work (launcher Continue C25 and polish)
- **INFO** — historical reference, not a defect
- **PECULIARITY** — odd but non-blocking behaviour

---

## CASE map (one glance)

| ID | Case | Status | Patch / note | Key shots |
|---|---|---|---|---|
| C01 | Payload never loads / no MJ panel | **SOLVED** | v1 factory branch + v2 LEA→`gfx\monarchs` | (206)–(209) era |
| C02 | “Log in to Paradox Account” blocks Play | **SOLVED** | v3/v4 UI-gate + eligibility rewrite | (182)(192–199)(222) |
| C03 | Challenges Disabled / Start blocked (checksum·Steam) | **SOLVED** | v4 eligibility | (210)(213)(227 mixed) |
| C04 | Empty reward gallery shows `UI_MISSING_*` | **SOLVED** *(hidden on purpose)* | v4 hides empty Titus container | (202)(205)(208–210) |
| C05 | Live challenge tracking works in-session | **SOLVED** | v4 core loop | (214) tooltip 1/6 |
| C06 | Progress lost after save/load (0/6) | **SOLVED** | **V6** five save-list gates + feat globals | (228) before; (256) after |
| C07 | Manual Load of Bronzeman save | **SOLVED** | V6 | (5) works via SP→Load |
| C08 | **In-game Continue “Continue failed!” popup** | **SOLVED** | **V7** `0x1409E678B` / `0x009E5B8B` `75 2f→eb 2f` | (1)(2)(4)(217)(219)(224)(226) |
| C25 | **Paradox launcher Continue still grey** | **UNSOLVED** | Separate `pdx_launcher.lib` / `launcher-v2.sqlite`; V7 does not touch it | launcher UI |
| C09 | Multiplayer breaks 2nd boot / resign→menu | **UNSOLVED** secondary | frontend refresh | (2,5)(3)(225) |
| C10 | Grey “only person alive” selection map | **UNSOLVED** secondary | empty history / no ruler-set provinces | (3) + map reference |
| C11 | Portrait tooltip flicker on small MJ portrait | **UNSOLVED** secondary | tied to grey-map hover hitbox? | (188), `flickering.mp4` |
| C12 | MJ arrow missing some boots | **UNSOLVED** secondary | frontend init | `(19 january of 2020)…` |
| C13 | Random-ruler path: Bronzeman on, MJ UI/crown gone | **PARTIAL** | not the normal path | (16)(17) |
| C14 | Bookmark before birth → empty character panel | **INFO** expected | character not born yet | (15) |
| C15 | Load→Back→reload empty panel briefly | **PECULIARITY** | self-heals in seconds; “Observe Game” rare | (18) |
| C16 | Bronzeman lock: can’t switch character | **INFO** intended | tooltip “cannot change character” | (6) |
| C17 | Gauntlet tooltip still says challenges won’t work | **PARTIAL** cosmetic | stale account text; play works | (7) |
| C18 | `event_time_end` kill-switch greys Play/arrows | **SOLVED** *(payload)* | end dates → 2030 / INT_MAX | `when feature was going to end…`, `xami5…` |
| C19 | Internet-on breaks local offline path | **INFO** ops rule | stay offline for tests | (223) era notes |
| C20 | Featured Ruler predecessor UI (pre-MJ) | **INFO** / future project | see `FEATURED_RULERS.md` | `1 ruler`…`12 ruler`, wiki tables |
| C21 | CK3 reward gallery / score bar | **PARTIAL** deferred | local table possible; server cosmetics dead | rewards shots, `q2pkr…` |
| C22 | Bronze tier grant popup | **SOLVED** | V6 live eval (Pavao `established`) | (256) |
| C23 | Character history tooltips in panel | **INFO** | embedded in payload localisation | (198)(229) |
| C24 | Pirated/emu DLL folder listing | **INFO** env only | not a game bug | (215) |

---

## Findings (durable facts the screenshots prove)

### F1 — Two UI generations share one codebase
- **Featured Ruler** (pre–Oct 2019 / early rollout): “Time Remaining: N days”,
  simpler panel, challenges often only from later rulers, DLC-sale banners,
  Steam-friends score line, “Create a Paradox Account!”.
- **Monarch’s Journey** (3.3+, Oct 20 2019): challenges tab, score + reward
  strip, Bronzeman, biweekly roster via arrows.
- Evidence: `1 ruler.png`…`12 ruler.png` (FR) vs Konan/Llywelyn MJ shots;
  `Screenshot 3.png` (FR table) vs `Screenshot 1–2.png` (MJ table);
  texture folders `Снимок.PNG` (`featured_ruler/`) vs `Снимок2.PNG` (`highlighted_*`).

### F2 — Score → CK3 cosmetics ladder (local display data)
| Score | Reward |
|------:|--------|
| 10 | Wizard’s Beard |
| 20 | The Pageboy |
| 30 | Chaperon |
| 40 | Jester’s Hat |
| 55 | Cone Shaped Hennin |
| 70 | Medieval Mullet |
| **90** | **The Miller** (confirmed; earlier “70” misread corrected) |
| 110 | The Joan of Arc |

Bronze/Silver/Gold on a challenge = **2 points each** (most challenges).
Full per-ruler challenge tables: `FR_MJ_COMPLETE_ROSTER.md`.
Shots (optional): `7k2d9u8x2ht31`, `YPmxNMB`, `upload_2019…`, `q2pkrvbmwml51`,
`(203)` Joan at 136, `(256)` Bronze popup.

### F3 — Login gate was UI-only after payload load
V2 loaded the panel but every action said log in — shots (182)(192–199)(222).
V4 removed the gate; those strings are **historical / fixed**.

### F4 — `UI_MISSING_*` = empty online reward container, not missing textures
When the reward strip is shown without server catalogue: score/name/desc all
`UI Missing…` — (202)(205)(208–210). V4 **hides** that container. Challenge
text progress still works without it — (214).

### F5 — Continue ≠ Load (and launcher ≠ in-game)
- **Load Game** path worked on V6 while in-game **Continue** still popped the
  generic failed dialog — (5) vs (1)(2)(4).
- Canonical English wording of that dialog (user transcript):
  *Continue failed! / Continuing from the latest save failed… The save is
  broken / requires DLC / doesn't work with the current version / a mod save
  folder / ironman + modified checksum. If the cause was ironman, load via
  Load Game.*
- V6 fixed Load + feat globals. **V7** (`57b18e43…`) fixed in-game Continue
  *execution* (cloud-sync byte `[rsi+0x63]`). The Paradox **launcher** Continue
  button is a different surface and stays grey (C25).

### F6 — Time gate is real and offline-clock-sensitive
When `event_time_end` passed: no score, grey Play, grey arrows — filename of
`when feature was going to end such things occured…png`. Play returned offline
with system date set earlier. Payload fix: push ends to 2030 / `2147483647`.

### F7 — Grey map correlates with “no characters on provinces”
User note on (3): deleting history/character files greys the ruler-pick map;
loading a game then fills with randoms. Same look as “only person alive.”
Flicker on small portrait may be hover vs empty map hit-testing — `flickering.mp4`.

### F8 — Current payload roster (May 3.3.3 `gfx\monarchs`) = 11 keys
`konan_brittany`, `llywelyn_gwynedd`, `mordechai_al_dawla`, `konstantinos_samos`,
`louise_aquitaine`, `shajar_egypt`, `pavao_croatia`, `arwa_yemen`, `harald_norway`,
`hethum_armenia`, `kulin_bosnia`.

**MJ wiki complete but missing (the classic five):** Liao, Basarab, Mindaugas,
Botstain, Stefan.

**FR-era with full challenges also missing:** Bohemond, Petronilla, Tamari,
Nuno, Mihajlo (+ Mindaugas overlap).

**FR-only, never published challenges:** Hugues, Johann Blind, Charles Hungary,
Mauregato.

Full tables + matrix → `FR_MJ_COMPLETE_ROSTER.md`. FR UI/restore → `FEATURED_RULERS.md`.

### F9 — Feats do evaluate offline after V6
Pavao campaign: Bronze on `Established` at threshold — (256). Cache
`q847rsja8ndx` stores peaks. Old fear “feats don’t go up” was mostly
loaded-old-save / abandoned feat-V7 noise.

### F10 — Asset packs still on disk in stock installs
`gfx/interface/featured_ruler/*` and `gfx/interface/highlighted_*` file lists
in `Снимок.PNG` / `Снимок2.PNG` — textures exist; controller is code + payload.

---

## Peculiarities (don’t chase unless bored)

| P# | What | Shot | Note |
|---|---|---|---|
| P1 | “Observe Game” button on load screen | (18) | rarely seen; not required for MJ |
| P2 | Crowd/three-figures icon under ruler/challenges tabs | `5 ruler` / `12 ruler` annotation | unknown control — user marked “not sure what this is” |
| P3 | Score shows 0 until Challenges tab opened | “more things” notes | FR-era UI refresh bug |
| P4 | Better Looking Garbs corrupts FR portrait | `2 ruler (portrait corrupted…)` | mod conflict, not MJ code |
| P5 | DLC-sale banner on FR panel | `4 ruler` Nuno | marketing hook in FR generation |
| P6 | “Cannot load autosave (Bronze)” behind Continue failed | (2) | Bronzeman autosave naming |
| P7 | Game State corrupted + MP circled | (2,5)(225) | may be intentional hard-stop after bad state |
| P8 | In-game portrait zone does **not** flicker | (229) | flicker is main-menu/MJ-overlay only |

---

## Recommended work order (from this index)

1. Optional: **C25** — Paradox launcher Continue (not required to play; launch `CK2game.exe` directly).
2. Optional polish: C09–C12 (MP, grey map, flicker, missing arrow), C17 tooltip.
3. Separate project: **Featured Rulers** full roster + FR UI (`FEATURED_RULERS.md`).
4. Separate project: local reward gallery (C21) using ladder in F2 + Linux reward table.

Do **not** re-open C01–C08, C18, C22 without new contradictory evidence.
