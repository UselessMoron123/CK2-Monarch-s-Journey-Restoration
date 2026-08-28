# Feats reset across quit, survive resign — CONFIRMED mechanism + V8 candidate

Date: 2026-08-27. Two sessions. This is the authoritative record for the
"feats show 0 after a cold relaunch + load, but survive an in-session resign"
defect. The earlier identity-drift hypothesis is **refuted** by the user's
preflight output; the actual mechanism is a gated re-hydration path.

## User evidence (verbatim, two messages)

> "feats reset when quitting completely. Resign → menu → load/continue = fine.
> Quit → relaunch → main-menu MJ interface (rulers, arrows, challenges, feats)
> intact → load/continue → feats all 0."

> Preflight (2026-08-27): binary = V7 `57b18e43…`; payload correct; cache
> `q847rsja8ndx` = `user_id=84696387`, `category=1474319405`,
> `conquerer_from_bribir=1`, `established=2`. `user_id` **matches** the archived
> Bronze run. Console is disabled in Bronzeman (by design), so `feat_log` is not
> usable — all further testing must be GUI/preflight based.

## What the preflight proves (and disproves)

1. **Identity drift is refuted.** `user_id=84696387` is identical to the archived
   v6-secondlook Bronze run. It did not change between launches. (The earlier
   `453496064` vs `84696387` discrepancy was two *different* captures, not drift.)
2. **`category` changed** (`697115649` → `-1991027533` → `1474319405`), but
   `category` is not the feat-scope key; it does not explain the reset.
3. **The cache is written correctly** in-session (`established=2`,
   `conquerer_from_bribir=1`). Tracking works during a session; only the
   *cold-load read-back into the in-game counter* fails.
4. **Main menu shows feats fine** (reads the cache). The defect is specifically
   the **in-game** counter after a cold load.

## Confirmed mechanism (Linux 3.3.3 `ck2` = May-3.3.3, + Windows bytes)

The visible in-game counter lives in two `std::vector<int>` on
`CRulerFeatTracker` (`+0x108` current, `+0x120` cached). The only in-game writer
that re-fills them from the save is `UpdateFeatProgress` (`lin 0xff78a6` /
win `0x1407b8e60`), which reads `global_<featkey>` script variables.

`UpdateFeatProgress` is gated **twice** by `IsActiveForPlaythrough`
(`lin 0xff6d46` / win `0x1407b8370`):

1. `CGameState::DailyUpdate` (`lin 0xfc6659` / win `0x14066713f`):
   `call IsActiveForPlaythrough; test al; je <skip>` — when false it never even
   calls `UpdateFeatProgress`. Windows skip branch = raw `0x00666546`: `74 0d`.
2. `CalcShouldTrackFeatProgress` (`lin 0xff6e48` / win `0x1407b8464`), called
   at the top of `UpdateFeatProgress`: `call IsActiveForPlaythrough; test al;
   jne <continue>` — when false it returns false and `UpdateFeatProgress` bails.
   Windows continue branch = raw `0x007b786b`: `75 05`.

`IsActiveForPlaythrough` returns false when `[gameState+0x598]` (the featured
ruler key, i.e. `special_event`) is null/empty or does not match a ruler name in
the local payload. A fresh campaign sets it via the frontend; a warm resign
keeps the process state; a **cold load** does not re-establish the match, so
both gates fail and feats stay 0.

The main menu is unaffected because it reads the local cache
`cache/q847rsja8ndx` (via `CFeatProgressStorage::ReadCachedProgress`), which the
preflight confirms is written correctly.

## V8 candidate (two length-preserving edits, no code injection)

| Raw offset | VA | V7 | V8 | Purpose |
|---|---|---|---|---|
| `0x00666546` | `0x140667146` | `74 0d` | `90 90` | daily update always calls `UpdateFeatProgress` |
| `0x007b786b` | `0x1407b846b` | `75 05` | `eb 05` | `UpdateFeatProgress` ignores the `IsActiveForPlaythrough` gate |

Both bytes were verified unchanged by V1–V7. The reconstruction stock→V7 was
verified byte-perfect (all three intermediate SHA-256 values match), so the V8
output hash is trustworthy:

- V8 SHA-256: `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`

Downstream safety is preserved: `CalcShouldTrackFeatProgress` still requires
Bronzeman/Ironman mode bytes (`+0x500/+0x501`), a non-expired ruler, and the
achievement-eligibility helper (`0x1400af690`), so normal non-Bronzeman games
still never track feats.

## Deliverables (this turn)

- `05_patches_and_scripts/ps1/patch_ck2_mj_v8.ps1` — guarded V7→V8 patcher
  (also accepts V5/V6 and upgrades through V6/V7 first).
- `05_patches_and_scripts/bat/APPLY_CK2_MJ_V8.bat`
- `05_patches_and_scripts/bat/CHECK_CK2_MJ_V8.bat`
- `05_patches_and_scripts/bat/REVERT_CK2_MJ_V8_TO_V7.bat`
- `04_test_guides_and_reports/CK2_MJ_V8_TEST_GUIDE.md`
- `05_patches_and_scripts/ps1/preflight_ck2_mj.ps1` — fixed: added V7 hash,
  defined `$AcceptableExe`, `$GoodExe` now V7 (the old `$AcceptableExe` bug made
  it print "UNKNOWN" and a PowerShell error).

## If V8 does not fix it

Then the remaining suspect is a *different* gate inside `CalcShouldTrackFeatProgress`
(ruler-info null at `0x1407b848d`, or mode bytes not set on load), or the save is
genuinely not carrying the `global_*` values. Collect: (a) is it 0 immediately
vs after one in-game day; (b) the in-game challenges tab + preflight output.
Do **not** run `wipe_feats`; do not reuse the banned trampoline or abandoned
feat-V7.
