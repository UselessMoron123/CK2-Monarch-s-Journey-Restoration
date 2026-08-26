# RESEARCH ARCHIVE — Restoring CK2 "Monarch's Journey" offline
**Part 1 of the research · source: `new text doc(first).txt` (6,463-line conversation log) · supersedes the earlier short summary**

> **How this document is built (and how other parts should be built):**
> A — Orientation · B — Story (timeline + how the theory evolved + patch lineage) · C — Knowledge base (facts, math, artifacts, offsets) · D — Attempts & dead ends · E — Open threads & future directions (incl. beyond the original goal) · F — Context (environment, safety, curiosities, method lessons, evidence inventory).
> Every claim below comes from the log; all arithmetic was independently re-verified.

---

# A. ORIENTATION

## A1. Goal
Bring back the retired **Monarch's Journey** (MJ; internal names: *highlighted ruler*, *Featured Ruler*, dev branch "Red King") mode of Crusader Kings II — main-menu ruler panel, Bronzeman challenge campaigns, challenge tracking — for **personal, offline use on Windows**, without the retired Paradox online services.

## A2. Status dashboard at the end of this part

| Area | State |
|---|---|
| MJ panel + arrow, 11 rulers × 3 challenges in main menu | ✅ **works** (patch v2) |
| Play → Game Rules → Bronzeman + Challenges Enabled → Start | ✅ **works** (v3+v4) |
| In-game challenge panel with **live** progress (Heretical Courtiers 1/6) | ✅ **works** (v4) |
| Loading Featured-Ruler saves offline via Load Game | ✅ **works** (v5) |
| Challenge progress **persistence** (survives game restart) | ❌ **open** — resets to 0/6; this is exactly where the log ends |
| Launcher "Continue" button | ❌ greyed (in-game Load Game works) |
| Reward gallery, progress bar, total score, CK3 cosmetics | ❌ dead server-side content (Titus); hidden, not restored |
| Full 16-ruler roster | ❌ payload snapshot has only the first 11 |

## A3. One-paragraph story
The investigation began by patching an expiry date in a data file, failed for two years' worth of wrong reasons, then succeeded through systematic reverse engineering: Steam-depot archaeology proved the feature's controller was compiled out of the executable at retirement; string dumps proved which builds can even read a local file; disassembling the Linux build exposed a complete offline loader (`CNullGameSpark`) and the actual visibility formula — which revealed the very first fix had been sabotaged by an integer overflow. Five generations of two-to-24-byte patches on the exact May 2020 Windows executable then re-enabled the whole feature offline, one gate at a time: loader → UI → login gates → challenge eligibility → save loading. The only unfinished piece is progress persistence across restarts.

---

# B. STORY

## B1. Timeline of the investigation

**T1 — The data file.** User supplies `monarchs.txt` (the MJ content payload: 11 rulers, 33 challenges, portrait DNA, camera data, bronze/silver/gold thresholds, 4-language localisation, embedded CK2 script). Every ruler carries `event_time_end: 1609502400` (= 2021‑01‑01 12:00 UTC) — a global kill date. A patched copy sets all 11 values to `2147483647`. Also noted early: the file has *no* reward definitions or account endpoints → CK3 cosmetics almost certainly unrecoverable.

**T2 — GUI files.** `highlighted_ruler_gui.txt` defines the four runtime windows (`upcoming_event_window`, `highlighted_ruler_window_main`, `_pause`, `highlighted_ruler_feat_window`) plus play/continue/restart/tabs/progress controls — but **no handlers**; labels start as `UI_MISSING_TEXT`; two fields commented `# Hidden by code` → the executable finds these named objects and binds them itself. 51 MJ textures exist (49 + 2 in frontend). Localisation (LT.csv has all 8 CK3 reward names; RedKing.csv has the full Bronzeman validation vocabulary) is complete. Conclusion: **no asset is missing; the controller is compiled code.**

**T3 — Rollback test.** User installs 3.3.2, manually creates `common\monarchs_journey\monarchs.txt` → no interface, no errors (logs confirm genuine 3.3.2 IIVC and that `highlighted_ruler.gui` + `LT_featured_ruler.txt` load fine). 

**T4 — Depot archaeology.** May 2020 build identified as last pre-removal (manifests recorded, see C4). Retirement update of **2 Sept 2020** diff: `mainmenu_rtt.gui` −1 byte (`PREORDER_NOW`→`BUY_CK3_NOW`), `LT.csv` +91 bytes, **`CK2game.exe` −775 KiB** → proof a compiled MJ/online component was removed. User downloads May Win + Linux depots; both still show no interface with the reactivated JSON.

**T5 — String dumps.** After fixing a broken `strings64` batch (stderr wasn't captured), three executables are dumped and fingerprinted by embedded build strings: current 3.3.5.1 (2021‑09‑21), May 3.3.3 (2020‑05‑06 — initially mislabeled "3.3.2"), genuine 3.3.2 (2020‑02‑06). **Decisive result:** 3.3.2 has the full MJ controller + GameSparks client (`ws.gamesparks.net`) but **no** `common/monarchs_journey` and **no** `can_see_highlighted_rulers` → it is remote-only and physically cannot read the file; May 3.3.3 added both strings (the Linux static-snapshot pathway). 3.3.5.1 still contains directories, debug commands and validation strings — only the higher-level initialization is gone. Four restoration paths are enumerated (fix Linux path / patch Windows to use local path / inject into 3.3.2's GameSparks response / emulate GameSparks).

**T6 — Linux disassembly (breakthrough).** Uploading binaries is impossible → they are transferred as Base64 text parts with SHA‑256 manifests. The Linux `ck2` (27,729,272 B) is reconstructed and disassembled: **`CNullGameSpark`** is a complete offline GameSparks replacement — always constructed on Linux, reads `common/monarchs_journey/monarchs.txt` (plaintext JSON fine; optional XOR `<pineapple>` format), `GetHasFetchedPropertySet()` always true, **no login/POPS/Titus check in the visibility path**. And the decisive formula: `visible ⇔ now < int32(event_time_end + 172800)` — **the INT_MAX payload could never work** (it overflows to 1901). A 2030 payload (`1893499200`) is created. (Native Linux was never actually run — user is on Windows.)

**T7 — Session handoff.** Workspace space runs low → a complete handoff document is written so a fresh session can continue without repeating anything; workspace cleaned 95→52 MB.

**T8 — Windows patch saga (v1→v5).** The May Windows exe (24,753,368 B, SHA `656f…`) is uploaded the same way. See B3 for the patch lineage and each runtime result. Two errors in the first session's Windows report are caught by independent disassembly (unsafe 10-byte-over-9-byte string patch; a Documents-path claim built on misreading a callback).

**T9 — The persistence cliffhanger.** V4 proves live tracking (`heretical_company=1`); saving works; both saves verified valid; but restart resets progress to 0/6, and Featured-Ruler saves are login-gated. V5 removes the save-login gate. Final exchange: loading shows the 1 Jan auto-save while the 3 Mar save was selected; user reports both saves "the same"; **the model hits its context limit — end of log.**

## B2. Evolution of the mental model (the important part)

| # | Working theory at the time | What killed / confirmed it |
|---|---|---|
| 1 | "The expiry timestamp is the only blocker" | Disproven twice over: INT_MAX overflows the +2-day check (T6), and no Windows build reads the file by default anyway |
| 2 | "Some GUI/GFX file or hook is missing" | Killed by exhaustive file review: all assets present; UI is code-bound |
| 3 | "Old version + file = feature back" (community reports of Sept 2020 rollbacks working) | Killed by tests on 3.3.2 / May Win / May Linux; later explained: those reports happened while GameSparks was still alive (a fresh test years later is not equivalent) |
| 4 | "POPS/Paradox-Online initialization never completes, so the manager is never created" | Plausible mid-way; **disproven by Linux disassembly** — the offline path has no login check at all. The real blockers were: (a) Windows factory never selects the local client, (b) wrong hardcoded filename/path on Windows, (c) the INT_MAX overflow |
| 5 | "Force the local client + fix the filename and it will all work" | **Confirmed** (v2) — then revealed the *next* layer of gates: account status on Play, challenge eligibility (Steam-active + stock-checksum), save loading (login gate on Featured-Ruler saves) — each peeled off in v3–v5 |
| 6 | "Progress works" | Corrected by the user's restart test: v4 proved *in-memory* tracking only, not persistence |

## B3. Patch lineage (each generation = one hypothesis test)

| Gen | Change (cumulative) | Runtime result | What it proved |
|---|---|---|---|
| payload | `event_time_end` 2021→2030 in JSON | (tested inside T3/T4, no UI) | Nothing alone activates the feature |
| **v1** | 1 branch patch: force local/null GameSparks client | **Nothing** (checker verified exe + payload + version all correct) | Decisive negative → forced real disassembly instead of guessing; the Windows local loader wants `gfx\test.dds`, not `monarchs_journey\monarchs.txt` |
| **v2** | + redirect only the MJ loader's filename: `gfx\test.dds` → `gfx\monarchs` | **Panel + 11 rulers + 3 challenge rows render** | The loader, parser, schema and UI all work offline; login text + greyed Play remain |
| **v3** | + 5 UI-gate edits (Play enable skips account status; 3 tooltips; reward panel branch) | **Play works** → Game Rules: Bronzeman enabled, **Challenges: Disabled**, Start blocked; empty reward area shows `UI_ MISSING_TEXT` | Play's account gate was the only one on the button itself; the *challenge eligibility chain* is a separate, deeper gate; reward area must stay hidden (its content is server-side) |
| **v4** | + eligibility rewrite `save_ok && !ruler_designer && (stock_checksum ‖ !steam_active)` + 5 Steam-branch NOPs + hide empty reward/login text | **Full success of the core loop** — Challenges: Enabled, Start works, campaign runs, live progress 1/6 | The offline failure was exactly two conditions: stock checksum + Steam active; all real checks (Bronzeman, rules, valid save, no Ruler Designer, ruler, expiry) can stay intact |
| **v5** | + 2 edits in the shared save validator (skip only the Featured-Ruler account branch; fix Load tooltip) | **Saves load offline** (login gate gone) | Save rejection was a pure account-status check on saves carrying the Featured-Ruler marker; but progress shown after load is 0/6 → **persistence is the remaining bug** |

---

# C. KNOWLEDGE BASE (reference facts)

## C1. System architecture (as reverse-engineered)

```
ONLINE (original, Windows 3.3.2–3.3.3):
  CK2game.exe → GameSparks (ws.gamesparks.net, "GameSparks SDK C++ 1.0")
    → .AuthenticationRequest → .GetPropertySetRequest(propertySetShortCode)
    → response fields: scheduled_rulers + default_versions, required_gui, gui_version,
      event_version, active/upcoming_alert_level, scheduled_ruler, scheduled_upcoming,
      incompatible_mods, allow_with_mods
    → CHighlightedRulerView (Create/CopyGameSparksData/Reload/Show/ToggleOpen/
      StartGame/ContinueGame/RestartGame) → Bronzeman campaign + challenges
  Rewards/score → "Titus" backend (road_to_titus_progression.cpp:301 logs
    "FAILED TO FETCH FROM TITUS" when dead)
  Account layer → POPS (pops_api.dll): Initialize, RunCallbacks, AccountLogIn,
    AccountGetGuid, FeedRequest, KVStorageRead/Write; separate normal vs
    "Titus" login states; pdx_login.txt cache (SENSITIVE)

OFFLINE (Linux 3.3.3 only, May 2020 patch):
  CNullGameSpark replaces the whole service: constructed unconditionally;
  LoadLocalCache() reads <install>/common/monarchs_journey/monarchs.txt
  (storage location 0 → GetOriginalDirectory(0x52)); plaintext JSON accepted;
  optional XOR-0x0C obfuscated format marked "<pineapple>"; Download/Reconnect/
  Update are no-ops; GetHasFetchedPropertySet() = true always.

WINDOWS May 3.3.3 (the patch target):
  Same CNullGameSpark exists, but the factory builds the real (dead) client;
  its local loader hardcodes storage location 0 → GetOriginalDirectory(2)="gfx"
  → gfx\test.dds — a file ALSO read/rewritten by the startup username-cache
  routine (0x140778610) before MJ initializes → collision by design.

VISIBILITY PIPELINE (all builds):
  JSON root: { "can_see_highlighted_rulers": 1, "scheduled_rulers": [...] }
  → can_see_highlighted_rulers copied to GUI-version slot 14 (highlighted_ruler_version)
  → databases + CHighlightedRulerView created only if slot > 0, windows exist,
    a current ruler exists, and CalcCurrentHighlightedRulerViewState() ≠ hidden
  → visible ⇔ now < int32(event_time_end + 172800)   [Linux local: no upcoming event]
```

## C2. Version & content landscape

| Build | Date | MJ properties |
|---|---|---|
| 3.3.2 (IIVC) | 2020‑02‑06 | Full controller, **remote-only**; binary lacks the local path & flag strings |
| 3.3.3 | 2020‑05‑06 | **Last pre-removal**; adds `common/monarchs_journey` + `can_see_highlighted_rulers`; Linux gets static fallback; **this is the patch target** |
| Retirement update | 2020‑09‑02 | exe −775 KiB (controller/online code removed); other changes were CK3 promo only |
| 3.3.5.1 | 2021‑09‑21 | Strings/subsystems remain; initialization gone; not hash-compatible with the patches |
| GameSparks shutdown | 2022‑09 | Remote path permanently dead |

- Steam app 203770; depots: common 203771 (manifest `7374899011992364670`), Windows 210890 (`8653648373486267886`), Linux 210909 (`4089811292004061988`).
- Payload content: 11 rulers (Konan of Brittany, Llywelyn of Gwynedd, Sa'd Mordechai, Konstantinos of Samos, Louis the Stammerer, Shajar al-Durr, Pavao of Croatia, Arwa of Yemen, Harald Hardrada, Hethum of Armenia, Kulin of Bosnia) × 3 challenges each; 30 unique icons; 51 textures; 8 CK3 rewards (Wizards Beard, The Pageboy, Chaperon, Jesters Hat, Cone Shaped Hennin, Medieval Mullet, The Miller, The Joan of Arc).
- The 5 missing rulers (later releases): Liao Hongji, Basarab I, Mindaugas, Grand Mayor Botstain, Stefan the First-Crowned → a full restore needs a **late-Aug 2020** payload.
- `LT_featured_ruler.txt` = 2 hidden events (LT.62001/62002) tracking Arwa's Shia conversions (`was_converted_by_arwa_al_sulayhi`, `character_converted_to_shia`) — auxiliary to one challenge only.
- Historical: Featured Rulers were once rolled out remotely to a subset of players (hence `can_see_highlighted_rulers` as a remote flag); screenshots show **two UI generations** (early "Featured Ruler" with Time Remaining; later MJ with challenges/rewards) — explains orphaned legacy textures.
- Parser keys accepted (Linux, documented): `can_see_highlighted_rulers, scheduled_rulers, highlighted_ruler, add_localisation, key, event_time_end, alert_level, title, startdate, dynasty_id, feats_script, required_dlcs, traits, portrait, age, female, coa_dynasty, dna, properties, religion, culture, government, map, provinces, color, camera_position, camera_look_at`.

## C3. Verified calculations

**Visibility formula & timestamps:**
```
visible ⇔ now < int32(event_time_end + 172800)     172800 s = 2 days (0x2A300); 86400 = 1 day (0x15180)
```
| Value | UTC date | Note |
|---|---|---|
| 1609502400 | 2021‑01‑01 12:00 | original kill date in all 11 rulers |
| 2147483647 | 2038‑01‑19 03:14:07 | **broken**: +172800 → −2147310849 = **1901‑12‑15** ⇒ instantly expired |
| 1893499200 | 2030‑01‑01 12:00 | **chosen**; visible until 1893672000 = 2030‑01‑03 12:00 |
| 2147310847 | 2038‑01‑17 03:14:07 | mathematical maximum safe value (INT_MAX − 172800) |

**Transfer arithmetic:** Linux exe 27,729,272 B → ~37 MB Base64 → 5 × 8 MB text parts; Windows exe 24,753,368 B → 4 parts. Current-exe string dump ≈ 1 MB / 68,542 strings. Retirement exe delta ≈ 775 KiB.

## C4. Artifact identities (SHA-256, all verified during the work)

| Artifact | Size (B) | SHA-256 |
|---|---|---|
| May 2020 Win `CK2game.exe` — exact original | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` |
| v1 branch-only | 24,753,368 | `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c` |
| v2 loader redirect | 24,753,368 | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` |
| v3 UI gates | 24,753,368 | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` |
| v4 offline challenges | 24,753,368 | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` |
| v5 save loading | 24,753,368 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| Linux 3.3.3 `ck2` | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` |
| Payload `gfx\monarchs` (2030 JSON) | 101,949 | `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` |
| Test saves | 4,195,136 / 3,430,038 | `Bosnia1173_03_03.ck2` (1173.3.3) / `Bronzeman_kulin_bosnia.ck2` (1173.1.1) — both valid zip saves, `bronzeman=yes`, v3.3.3.0 |

## C5. Complete patch map (file offsets; exact-May exe only)

```
v1  0x00d73d02  74 2b → eb 2b          factory: always build local/null client
v2  0x00d73e1a  ba 23 36 00 → 21 fc 32 00   lea displacement: loader filename
                                           test.dds(0x1410d6dd8) → "monarchs_journey"
                                           string(0x1410a463f) first 8 bytes = "monarchs"
v3  0x007bd64e  75 04 → 90 90          Play enable: skip account-status condition only
v3  0x007beacb  74 19 → eb 19          Play tooltip → normal path
v3  0x007beea2  74 0c → eb 0c          Continue tooltip → normal path
v3  0x007befaf  74 2d → eb 2d          Restart path → normal
v3  0x007c0d18  74 0b → eb 0b          reward panel online branch (UNDONE in v4 — exposed
                                       empty controls "UI_ MISSING_TEXT")
v4  0x007c0d18  restored to 74 0b      hide empty reward container again
v4  0x007c0d23  eb 5c → 90 90          ...and hide obsolete login text too
v4  0x000aeb83  24-byte rewrite (VA 0x1400af783, shared eligibility helper):
      from: 80 7f 61 00 74 0c 80 7f 63 00 74 06 80 7f 62 00 74 02 33 f6 40 0f b6 c6
      to:   31 c0 66 83 7f 61 01 75 0f 80 7f 63 00 75 06 80 7f 65 00 75 03 ff c0 90
      semantics: save_ok && !ruler_designer && (stock_checksum || !steam_active)
v4  0x00732b03  74 16 → 90 90          Start-button state (Steam branch)
v4  0x007336b0  74 1d → 90 90          challenge-enabled predicate
v4  0x007337e1  74 1d → 90 90          Start warning predicate
v4  0x00737262  74 1b → 90 90          challenge tooltip heading
v4  0x007b78eb  75 0c → eb 0c          in-game feat tracking eligibility
v5  (2 edits, offsets not recorded in this part of the log; only final SHA known)
    shared save validator: skip Featured-Ruler account branch + Load tooltip
```

## C6. Key code locations (Windows May 3.3.3)

| Address | Function |
|---|---|
| 0x1401733b0 | GUI enabled-state setter (used for `play_button`; state 3 = disabled) |
| 0x1400af690 | shared rules/save/checksum/Ruler-Designer eligibility helper (rule evaluator 0x14072d540 inside) |
| 0x140733630 | Game Rules refresh / Start-button state |
| 0x1407341b0 / 0x140734290 | requested-Bronzeman state / challenge-enabled predicate |
| 0x1407b8450 | in-game feat tracking eligibility |
| 0x1407c3640 / 0x1407c38e0 | `highlighted_ruler_start` handler / start transition (no second account check) |
| 0x140778030 / 0x140777ee0 | storage load callback / path builder (location 0 → `gfx`) |
| 0x140778610 | startup username generation (collides with `gfx\test.dds`) |
| 0x140d74902 (VA) / 0x00d73d02 (file) | factory branch patched in v1 |
| Service flags (challenge predicate): +0x61 save valid · +0x63 stock checksum · +0x62 no Ruler Designer · +0x65 Steam active · in-game mode bytes +0x500/+0x501, +0x60 | |

---

# D. ATTEMPTS & DEAD ENDS

## D1. Attempt ledger (chronological)

| # | Attempt | Result |
|---|---|---|
| 1 | Patch expiry timestamps (INT_MAX) | ❌ harmful (overflow) — unknown at the time |
| 2 | Audit GUI/GFX/localisation/achievements for a missing activator | ❌ nothing missing; UI is code-bound |
| 3 | 3.3.2 + hand-created `common\monarchs_journey\monarchs.txt` | ❌ path not registered in that binary |
| 4 | May 2020 Win + Linux depots + reactivated JSON | ❌ factory never picks local client; wrong filename on Windows |
| 5 | String dumps ×3 builds | ✅ capability map; found debug commands, POPS/Titus, source filenames |
| 6 | Steam depot diff | ✅ located exact pre-removal build; proved −775 KiB removal |
| 7 | Linux exe disassembly | ✅ breakthrough (CNullGameSpark, path, schema, gates, overflow) |
| 8 | v1 branch patch + `test.dds` at 2 locations | ❌ decisive negative (path actually `gfx\test.dds`, plus username-cache collision) |
| 9 | v2 loader redirect to `gfx\monarchs` | ✅ **panel + rulers + challenges render** |
| 10 | v3 UI gates | ✅ Play works / ❌ revealed deeper eligibility gate |
| 11 | v4 eligibility rewrite | ✅ **core loop + live progress** |
| 12 | Console diagnostics (`feat_log`) | ✅ proved live tracking (`heretical_company=1`); `bronzedbg` never needed |
| 13 | Save & Continue test | 🟡 saves valid; Continue greyed; progress resets on restart |
| 14 | Read-only save checker (after `^`-escaping bugfix) | ✅ both saves valid; "Missing Version" was an old incomplete file |
| 15 | v5 save-validator patch | ✅ saves load offline / 🟡 progress still 0/6 after load |
| 16 | Running with Internet enabled | ❌ interferes (client switches to failed online state) — stay offline |

## D2. Dead ends — closed with evidence (do not revisit)

- More GUI/GFX/event files as activation mechanisms (all reviewed; handlers live in code).
- `mainmenu_rtt.*` (CK3 promo panel), `LT_featured_ruler.txt` (Arwa helper only), `achievements*.txt` (icons only).
- `common\monarchs_journey\monarchs.txt` on Windows 3.3.2 — string absent from that binary.
- JSON at `gfx\test.dds` — username cache reads/rewrites the same file before MJ starts.
- Global rename of the `test.dds` string — breaks the username cache; use the v2 displacement redirect instead.
- Globally faking account status 3 — associated pointers stay null; patch the specific UI branches instead.
- Forcing only the final Start button — earlier predicate still blocks; patch the eligibility chain (v4 approach).
- INT_MAX timestamps (overflow). Payload must be regenerated before **2030‑01‑03**; absolute ceiling 2038‑01‑17.
- Applying May offsets to any other exe (3.3.5.1 etc.) — hash-guarded patchers refuse; different builds need fresh analysis.
- pops_api/pdx_online DLLs — deliberately deferred; main exe contains everything relevant so far.
- Native Linux runtime test — never performed (user is Windows-only); static analysis sufficed.

## D3. Disproven theories vs confirmed facts
See B2 — the theory table *is* this record.

---

# E. OPEN THREADS & FUTURE DIRECTIONS

## E1. Open questions (ranked)

1. **Progress persistence (the cliffhanger).** Is feat progress serialized into the save at all, and where does restore fail? User's last words: both saves load and show the same (0) progress. Next investigation target: `feat_progress_storage.cpp` path (`Failed to write/read reward status/score to/from storage` strings exist), and whether load-time restore is gated by another account/Steam check.
2. **Which save loads.** The v5 test showed the 1 Jan auto-save where 3 Mar was selected — verify save-selection behavior (auto-save vs manual) before concluding anything about restore.
3. **Launcher "Continue"** for Featured-Ruler saves (the launcher tooltip `FEATURED_RULER_NOT_SUPPORTED_LINUX` lives in `CPdxLauncherGUI::UpdateTooltip` — same neighborhood). Low priority: in-game Load works.
4. **Reward gallery / progress bar / total score** — cosmetic *local* reconstruction (V5-style display of the historical 8 rewards) is possible but was deliberately deferred; nothing server-side can return.
5. **Full 16-ruler roster** — find a late-Aug 2020 payload (other installs, depots, web archives of the feed, GameSparks cache folders).
6. **Porting the patch set to 3.3.5.1** (current exe) so MJ works with the newest DLC set — different offsets, full re-analysis required; only worth it if the user wants the newer content.

## E2. Ideas beyond the original goal ("other things")

- **Custom Featured Rulers.** v2 proved the game parses *any* valid JSON at `gfx\monarchs`. The full accepted schema is documented (C2) → authoring custom rulers/challenges (a mini modding toolkit) is realistic.
- **Reusable technique template.** The workflow (depot archaeology → 3-build string comparison → Linux symbols as a "map" → hash-guarded minimal patches on the Windows twin) should transfer to other retired Paradox online features.
- **`<pineapple>` XOR cache format.** The GameSparks local-cache obfuscation (XOR-0x0C marker) could decode old cached feed data in `AppData\Roaming\GameSparks` (user's had an empty folder `E349414h9BDm`) — a possible source for the missing 5 rulers.
- **`bronzedbg` debug window** — never actually opened; might expose manager/feed state internals if deeper debugging is ever needed.
- **Maintenance note:** the working payload expires 2030‑01‑03; regenerate with a later date (≤ 2147310847) before then.

## E3. If continuing in a new session
Hand the AI: this archive + the companion files (`CK2_Monarchs_Journey_next_session_handoff.md` lineage, `patch_ck2_mj_v5.ps1`, `monarchs` payload, `CK2_MJ_SAVE_REPORT.txt`, final screenshots 224–229). State: *"Continue from the persistence problem; do not repeat closed dead ends (D2)."*

---

# F. CONTEXT

## F1. Environment & constraints (recorded for continuity)

- User: **Windows**, non-technical — needs literal beginner steps, drag-and-drop .bat wrappers, no Linux/WSL.
- Test root: `C:\Users\UZWERG\Desktop\SteamCrusader` (exact May 2020 build). A second, newer pirated copy at `C:\$ASUS\Games\Crusader Kings II` is fully offline, all DLC — patches refuse it (different build).
- Game must run **offline**: with Internet, the obsolete client switches to a failed online state and interferes.
- Upload channel accepts only text/images/PDF → binaries transferred as Base64 `.txt` parts + manifest (size + SHA-256). Rename executables before dumping/uploading to avoid overwrites.
- Workspace budget was the binding constraint (95→52 MB cleanup; 119.1/128 MB at the end) — minimize artifacts, delete reproducible intermediates.
- Russian-language Windows (error messages, "Снимок экрана" = screenshot).

## F2. Safety rules (hard)

- **Never run `wipe_feats`** — "Wipe out all CK2 Featured Ruler feats. WARNING: CANNOT BE UNDONE!"
- Never upload/share `pdx_login.txt`, tokens, account data.
- Patch only hash-verified copies: every patcher checks size + original SHA-256 + expected bytes at every offset, writes backups (timestamped + verified-original), verifies the result by normalized-hash, and can revert. Never distribute a patched exe — only the guarded patcher + payload.
- Don't open newer saves in the old version; don't delete the two Kulin test saves.

## F3. Curiosities & side-findings (not needed for the goal, worth keeping)

- Hidden console commands: `bronzedbg`/`bronzeman_debug` (Bronzeman Debug Window), `feat_log`, `helplog` (dumps full command list to game.log), `wipe_feats` (dangerous). Console is disabled in Bronzeman *by design* (like Ironman); Bronzeman also forces compressed saves.
- Dev codenames: **RTT** ("road to Titus" = the CK3 promotion; splash keys `RTT_SPLASH_MESSAGE_1/2`), **Titus** = Paradox backend for MJ reward progression / CK3 tie-in, **Red King** (`red_king/ruler_feats`) = MJ dev branch, **LT** = its localisation/event prefix.
- Embedded source filenames: `feat_progress_storage.cpp`, `road_to_titus_progression.cpp`, `directorysettings.cpp`, `savegameinterfaces.cpp`, `ck_application.cpp`.
- Localisation typo key `UI_ MISSING_TEXT` is genuinely undefined in the game's loc files.
- Checksums: patched main menu shows **EDJH**; stock 3.3.3 is **SOHY** (difference = the patches; this is why the "stock checksum" requirement was red).
- Stock CK2 quirk: after quitting any campaign, Continue/Load/Multiplayer can stay greyed ("dirty session") until a full restart — reproduced in a non-Bronzeman game; not MJ-related.
- Challenge scripts create variables like `global_time_bending` — old MJ-era saves may still expose them.
- Featured Ruler saves show bronze-hand + crown icons and the text "save was created playing a Featured Ruler".
- `gs_test` command-line token feeds the GameSparks factory Boolean (not an offline switch).
- Two historical UI generations of the feature (see C2).

## F4. Method lessons (what worked)

1. **Independently verify AI-produced disassembly reports** — two real errors were caught this way (length-mismatched string patch; a callback misread as a directory getter).
2. A **verified-input negative runtime result is decisive** — it converts "maybe the payload is wrong" into "the patch theory is wrong; disassemble".
3. **Linux binaries as a symbol map** for the stripped Windows twin — the single highest-leverage technique in the project.
4. String dumps identify *capabilities*, only disassembly proves *behavior*; dumps without offsets mislead.
5. Hash-manifested Base64 parts solve "uploader rejects binaries".
6. A living handoff document is what made the 2-session continuation possible; update it after every result.
7. Minimal, per-purpose patches beat global hacks: each v-generation changed only the branches its hypothesis named, keeping every legitimate check intact.
8. Windows batch → PowerShell: mind `^` escaping (broke one checker; Russian-locale parse error revealed it).

## F5. Evidence inventory (what in the workspace proves what)

| Evidence | Proves |
|---|---|
| `monarchs.txt`, `monarchs_reactivated*.txt`, `monarchs`, `test.dds` | payload lineage (INT_MAX → 2030) |
| `ck2_may333_linux.base64.part001–005` + manifest | Linux binary identity/transfer |
| `CK2game_may333_windows.base64.part001–004` + manifest | Windows binary identity/transfer |
| `ck2_strings*`, `CK2game_strings*`, `*_monarchs_filtered.txt` | build capability comparison |
| `game{332,333,newest}.log` | 3.3.2/3.3.3/current behavior; Titus failure in all |
| `setup*.log`, `system*.log`, `text*.log`, `error*.log`, `graphics*.log` (numbered generations 1–4) | per-test-run states; `UI_ MISSING_TEXT`; EDJH checksum |
| `CK2_MJ_SAVE_REPORT.txt` | both saves valid |
| `what i saw when patching V3.txt` | v3 patcher transcript |
| Screenshot series: (206)–(209) v2 success + login gate · (182),(192)–(199),(202)–(205) references/old-days · (210),(213),(188) v3 · (214)–(215) v4 live progress 1/6 · (217)–(222) save tests · (223) internet-on breakage · (224)–(229) v5 results | each runtime milestone |
| `patch_ck2_mj_v2–v5.ps1`, `APPLY/CHECK/REVERT_*.bat` | the toolchain (hash-guarded, revert-capable) |
| `CK2_MJ_windows_*.md`, `CK2_MJ_V5_load_test_guide.md`, `findings.md`, handoff `.md`s | per-stage reports |
| `steamdb.html`, `github.html`, `libraryfolder.vdf` | depot research |
