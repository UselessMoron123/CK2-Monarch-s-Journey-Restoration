# Why the medal stays Bronze — feat cache, peak semantics, and the missing popup

Date: 2026-08-30. Triggered by the user's question after the V9 playtest:

> *"one thing i'm not sure about: when i load earlier save (conditions not met yet)
> or restart campaign, the feat icon stays bronze, so 'world heard about your deeds'
> notification doesn't trigger. i think it's because bronze is already recorded as
> achieved. so this cache file applies to every save, unless deleted?"*

**Short answer: yes — that is exactly right, and it is the game working as designed,
not a bug.** Everything below is the evidence.

---

## 1. Two independent stores, two different meanings

| Store | Path | Holds | Scope |
|---|---|---|---|
| Save variables | `…\Crusader Kings II\save games\*.ck2` → `global_<featkey>` | the **current** value at the moment of saving | **per save** |
| Feat cache | `…\Crusader Kings II\cache\q847rsja8ndx` | the **highest value ever reached** ("Best Result") | **per local account, not per save** |

The cache has no save identifier in it. Its only scoping keys are `key` / `id`
(always `-2128831035`) and `user_id`. Verbatim structure (from
`13_save_and_cache/q847rsja8ndx.txt`):

```text
key=-2128831035
id=-2128831035
user=152991562
user_id=453496064
not_so_land_locked=0
heretical_company=1
…
conquerer_from_bribir=0
established=0
subic_stantial_legacy=0
…
preemtive_selfdefense=0
category=697115649
```

That is 33 feat counters — one per challenge in the payload — bracketed by three
header fields and one `category` field.

The engine symbols say the same thing in one name
(`06_game_data/ck2_strings.txt`, Linux 3.3.3):

| Symbol | Meaning |
|---|---|
| `CFeatProgressStorage::SetCachedProgressIfHigher(CString const&, int)` | **"if higher"** — a peak, never a decrease |
| `CFeatProgressStorage::ReadCachedProgress` | what the medal / "Best Result" reads |
| `CFeatProgressStorage::ReadProgressFromKeyValueStorage` | what the save's `global_*` reads |
| `CFeatProgressStorage::CheckNeedsCache` | decides when the peak is worth persisting |
| `CFeatProgressStorage::SetNewProgress(CString, int, bool, bool)` | the write path |
| `CFeatProgressStorage::WipeFeats` | ❌ never call this |

And the UI proves the two are shown side by side — `06_game_data/RedKing.csv`,
verbatim English column:

| Loc key (line) | Text |
|---|---|
| `FEAT_CURRENT_TT` (729) | `Current Progress: $SCORE|Y$` |
| `FEAT_HIGHSCORE_TT` (724) | `Best Result: $HIGH_SCORE|G$` |
| `FEAT_PROGRESS_TT` (727) | `Progress $FEAT_PROGRESS|Y$ / $FEAT_LEVEL_VALUE$` |
| `FEAT_TEXT` (686) | `Challenges!` |

"Current Progress" comes from the save. "Best Result" comes from the cache. The medal
is driven by the **best result**.

---

## 2. Thresholds and tier names

From the payload (`06_game_data/monarchs.txt`, ruler `pavao_croatia`, verbatim):

```text
established = {
    icon = GFX_dream_home_34
    levels = { 4 6 8 }
    update = {
        set_variable = { which = global_established value = 0 }
        c_470001 = {            # Paul
            if = { limit = { is_alive = yes }
                any_dynasty_member = {
                    if = { limit = { is_landed = yes }
                        change_variable = { which = global_established value = 1 } } } } }
}
```

| Level | Loc key | Name | "Established" threshold |
|---|---|---|---|
| 1 | `RULER_FEAT_LEVEL_1_NAME` (683) | **Bronze** | 4 landed dynasty members |
| 2 | `RULER_FEAT_LEVEL_2_NAME` (684) | Silver | 6 |
| 3 | `RULER_FEAT_LEVEL_3_NAME` (685) | Gold | 8 |

---

## 3. The notification only fires on a *newly* earned level

Verbatim, `06_game_data/RedKing.csv`:

| Loc key | English text |
|---|---|
| `FEAT_LEVEL_1_COMPLETE_SETUP` (720) | `Challenge Rank Bronze Earned` ← popup **title** |
| `FEAT_LEVEL_2_COMPLETE_SETUP` (721) | `Challenge Rank Silver Earned` |
| `FEAT_LEVEL_3_COMPLETE_SETUP` (722) | `Challenge Rank Gold Earned` |
| `FEAT_LEVEL_1_COMPLETE_LOG` (691) | `\nCongratulations!\nWord has spread far and wide of your achievements.\nYou earned the rank of $LEVEL$ in the "$FEAT$" challenge.` |
| `FEAT_COMPLETE_LOG` (690) | `\nCongratulations!\nWord has spread far and wide of your achievements.\nYou completed the challenge "$FEAT$".` |

The popup is a **level-grant event**, not a display event. It is emitted when the
engine records that you crossed a threshold you had not crossed before. If the cached
peak already covers that level, there is nothing new to grant, so nothing is emitted.

What that popup looks like in practice is on record — `V6_RUNTIME_RESULTS.md` §3,
captured from `game.log` during a live playtest:

```text
Congratulations!
Word has spread far and wide of your achievements.
You earned the rank of Bronze in the "Established" challenge.
```

That is `FEAT_LEVEL_1_COMPLETE_LOG` with `$LEVEL$` = Bronze (`RULER_FEAT_LEVEL_1_NAME`)
and `$FEAT$` = Established (`RULER_FEAT_established_NAME`). The template and the
observed string match character for character.

---

## 4. The proof that the medal reads the cache, not the save

The decisive data point, measured twice in two different sessions:

| Source | Save | Internal date | `global_established` | Cache `established` | Medal shown |
|---|---|---|---|---|---|
| `V6_RUNTIME_RESULTS.md` §4 | `Bronzeman_pavao_croatia.ck2` | 1278.1.1 | **2.000** | 4 | Bronze |
| user report 2026-08-29 | "first day save" | 1278.1.1 | 2.000 | 4 | Bronze |

Bronze needs **4**. The save carries **2**. `2 < 4`, so the save's own value cannot
produce a Bronze medal. The medal can only be coming from the cache, whose peak is 4.
QED.

The wider save inventory agrees — all ten Pavao/Croatia saves carry
`global_conquerer_from_bribir=1.000` and `global_established` = 2.000 (×3),
3.000 (×5), 4.000 (×2) (full table in
`01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md` §C4). `established` counts
*currently* landed dynasty members, so it legitimately falls as members die or lose
titles: 4 → 3 → 2 across a campaign. The cache keeps the peak; the save keeps the
present.

---

## 5. Answers to the three specific questions

**"When I load an earlier save where the conditions are not met yet, the icon stays
Bronze."**
Correct and expected. The medal is `max(cache peak)` = 4 ⇒ Bronze. The save's
`global_established=2` only drives "Current Progress: 2/4". The icon is not a
statement about the loaded save; it is a statement about your best-ever run.

**"When I restart the campaign, the icon stays Bronze."**
Also correct. A new campaign starts with `global_established=0`, but the cache is
untouched, so Bronze is still the recorded peak. This is the same mechanism that made
the earlier bug so confusing: the main menu read the cache while the in-game tracker
read the (broken) live path — see `V9_RUNTIME_RESULTS.md`.

**"So the 'world heard about your deeds' notification doesn't trigger because Bronze
is already recorded as achieved."**
Exactly. The popup is a level-grant event. Bronze was granted once, ever, and the
cache remembers. Nothing new to grant ⇒ no popup. You will see it again only when a
**higher** tier is reached for the first time (Silver at 6, Gold at 8).

**"This cache file applies to every save, unless deleted."**
Confirmed. One file, `cache\q847rsja8ndx`, keyed by `user_id`, shared by every save
and every campaign on this Windows user profile. Deleting (or renaming) it is the only
way to reset it.

---

## 6. If you want the Bronze popup again (optional experiment)

This is **destructive to the record**, so back up first. Do **not** use `wipe_feats`.

1. Close CK2 completely.
2. In Explorer go to `Documents\Paradox Interactive\Crusader Kings II\cache`.
3. Copy `q847rsja8ndx` to your desktop as a backup.
4. Rename the original to `q847rsja8ndx.old`.
5. Launch `CK2game.exe` (not the launcher), load the first-day save, play until
   4 dynasty members are landed.
6. Expect the medal to be empty at first and `Congratulations! … Bronze in the
   "Established" challenge.` to fire once.

Cost: every "Best Result" figure in the Monarch's Journey panel resets to 0. To go
back, close the game and rename `q847rsja8ndx.old` back to `q847rsja8ndx`.

There is nothing wrong with leaving it alone — the cache is doing its job.

---

## 7. One open wrinkle

Four different `user_id` values have been observed for this one cache file across the
captures on record: `453496064`, `84696387`, `1148909174`, `1179784490` — with
*identical* feat vectors in several of them. If the medal or the Best Result ever
behaves as though progress vanished, check `user_id` in the cache first: a changed
`user_id` means the game is reading a different (empty) record. Tracked as
`CONTRADICTIONS.md` §12; the earlier "identity drift is refuted" conclusion is
withdrawn.
