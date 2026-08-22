# V6 runtime results — evidence chain

Compiled 2026-08-22 from the user-uploaded evidence folders
`log playing with new v6 patch/`, `v6 second look/`, and
`things parent AI asked to upload/`. No new runtime test was requested from the user
to produce this report.

## 1. Patch application — verified

From `things parent AI asked to upload/the V6 patch-window text.txt`:

- V5 was re-applied to the exact stock May 3.3.3 from backups on 2026-08-21:
  final V5 SHA-256 `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`.
- V6 was then applied on top:
  final V6 SHA-256 `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`.
- Payload verified in place: `gfx\monarchs` = `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`.
- A first patch attempt on the unpatched stock EXE correctly refused (guard worked).

## 2. New Bronzeman campaign as Pavao of Croatia — works

`v6 second look/logs/`:

- `game.log`: `[frontend.cpp:1328] Launching SINGLEPLAYER-game  Start-date: 1278.1.1`
  (history executed to the Pavao bookmark date — a fresh campaign, not a load).
- `ai.log`: `[gamestate.cpp:4609] Human takes control of Duke Pavao of Croatia`.
- `system.log`: build `CK2 Version May 6 2020` — the correct patched executable.

## 3. Live evaluation + tier granting — works, and matches the payload exactly

The local payload (`things parent AI asked to upload/monarchs`, ruler `pavao_croatia`,
startdate `1278.01.01`) defines:

```text
established             levels = { 4 6 8 }   (Bronze 4, Silver 6, Gold 8)
conquerer_from_bribir   levels = { 4 }       (single-tier feat)
subic_stantial_legacy   levels = { 1 2 3 }
```

Observed in `game.log` during play:

```text
Congratulations!
Word has spread far and wide of your achievements.
You earned the rank of Bronze in the "Established" challenge.
```

The serialized `global_established` values in the three saves (below) hit exactly 4 on
1278.1.2 — the Bronze threshold. Evaluation, thresholds, and rank granting are all live
and correct.

## 4. Save writing — works

`v6 second look/save games/` (all ZIP-format .ck2, `meta` entry valid):

| File | Internal date | special_event | bronzeman | global_established | global_conquerer_from_bribir | SHA-256 (first 16) |
|---|---|---|---|---|---|---|
| Bronzeman_pavao_croatia.ck2 | 1278.1.1 | pavao_croatia | yes | 2.000 | 1.000 | d6ee9fc10449c15a |
| Croatia1278_01_02.ck2 | 1278.1.2 | pavao_croatia | yes | 4.000 | 1.000 | da84b4d1be695dee |
| Croatia1278_01_10.ck2 | 1278.1.10 | pavao_croatia | yes | 3.000 | 1.000 | 68d0c993ca68d222 |

Notes: `established` is a *state-based* feat (count of landed dynasty members), so it can
decrease (4 → 3); the cache below stores the *peak*. The dated saves at 1.2 and 1.10 are
consistent with save-on-exit and at least one resume in between; screenshot (18)’s
description (“when loaded bronzeman save (but before clicking play on map)… loaded again
quick”) independently indicates the user reached the load/map stage from a Bronzeman save
via the manual Load Game screen.

## 5. Persistent local progress — works

`v6 second look/cache/q847rsja8ndx` (feat_progress_storage local cache; note `user_id=84696387`):

```text
established=4            ← peak, matches Bronze grant
conquerer_from_bribir=1
(all 33 other feats = 0)
```

Progress survives outside the saves — the retired Titus backend is not involved.

## 6. Still failing: Continue — CONFIRMED grayed-out (not a no-op)

User-confirmed 2026-08-22, in addition to the annotated screenshot names in
`log playing with new v6 patch/`:

- (1) “still cant click continue”
- (2) “cant continue from main menu”
- (4) “cant continue from there too”
- **Exact mode: the Continue control is grayed out / not clickable at all** (main menu and
  MJ panel). The failure is therefore in the button’s *enable predicate*, i.e. whatever
  flag the frontend reads to decide “a valid continuable save exists” — not in the click
  handler and not a wrong-state load.

Classification per the handoff §12 matrix: **outcome D** — the manual load path is
unblocked (V6’s five save-list gates), but Continue still refuses. V6 already patched the
inline account branch inside the Continue candidate-selection helper
(`0x1409e4970`), so the remaining rejection is a *different, non-account* predicate on the
Continue callers: `0x1407bffa1` (highlighted-ruler/MJ Continue), `0x1408145ec` (normal
frontend Continue), `0x140a0ba62`. That analysis is the V7 target.

## 7. Secondary observations (user annotations)

- (2,5)/(3): multiplayer button works on first boot, breaks on second boot / after
  resign-to-menu; gray map on first boot (“as if he’s only person alive”) — same class of
  frontend-refresh issue as the known gray-map/flicker items in the handoff §15.
- (5) “from there it works”, (6) “cant pick anyone else (as intended probably)”,
  (7) gauntlet tooltip warns Bronzeman “wont work, but…” — tooltip-only inaccuracy.
- (15) changing bookmark makes the featured ruler disappear (not born yet) — expected.
- (16)/(17) loading via random-ruler path keeps Bronzeman but loses the MJ interface/crown.
- `v6 second look/(19 january of 2020)…png`: “no arrow, multiplayer button not working” —
  MJ arrow absent in some boots.
- `v6 second look/when feature was going to end…png`: the user’s historical 2020
  recollection — after `event_time_end` passed, arrows grayed, Play grayed, no score;
  Play reappeared offline with the system date set earlier. Confirms the time-gating
  model; current payload’s 2030-01-01 end dates remain the correct approach.
- `flickering….mp4`: known portrait-tooltip flicker (handoff §15), secondary.

## 8. User-confirmed outcomes (2026-08-22)

1. **`Bosnia1173_03_03.ck2` manual Load under V6: WORKED** — loaded **3 March 1173**
   with **Heretical Company 1/6**. The original handoff test passed, including feat-global
   deserialization from an old V4-era save.
2. **Pavao campaign resume after full game restart: WORKED** via Single Player →
   Load Game.
3. **Continue is grayed out** (enable-state failure, see §6).

Open items reduced to: none blocking. Manual load + persistence = complete;
Continue enable-logic = V7 target; user’s chosen next focus = cross-version exe
comparison (featured-ruler base feature) and a 3.3.5.1 port if feasible.
