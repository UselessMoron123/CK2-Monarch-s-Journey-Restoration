# Crusader Kings II Monarch's Journey restoration — next-session handoff (2026-08-29)

> ## ⚠️ SUPERSEDED — 2026-08-30
>
> Everything below describes the state **before** V8 was tested and before V9 existed.
> Two of its central claims are now known to be wrong:
>
> 1. **"V8 (candidate) — feat re-hydration candidate"** → V8 was applied and its premise
>    was **disproven**: feats went to 0 in game *and* in the main-menu MJ tab.
> 2. **"`IsActiveForPlaythrough` gates are the cold-load block"** → the clean trace
>    logged `RESTORE_GATE al=1` on the cold burst, i.e. that function returned **true**.
>
> The open bug described here is **CLOSED**. Baseline is **V9**
> `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`, runtime-proven
> 2026-08-30. Read `03_analysis/V9_RUNTIME_RESULTS.md`,
> `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md`, and
> `00_START_HERE/STATUS.md`. This file is kept as the historical record of what was
> believed on 2026-08-29 — do not act on it.

> **Status banner (2026-08-29):** In-game baseline is **V7** (SHA-256
> `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`), and the core
> restoration loop + in-game Continue are runtime-proven. **One bug is open:** feat /
> challenge progress shows **0** after a **cold quit → relaunch → Load/Continue**, while
> the same load right after an in-session **resign** works. A fix candidate (**V8**, two
> byte edits, SHA-256 `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`)
> was built but the user reported **"still didn't work"** on 2026-08-29 — the exact failure
> mode is **not yet pinned down** (see §4/§6). This document is self-contained for the
> feat-reset question; deep background is in `CK2_MJ_ULTIMATE_HANDOFF.md` (same folder).

## Instructions to the next session (read first)

- The user is **non-technical** and runs everything on Windows by drag-and-drop. Give
  copy-paste instructions, never raw hex work for them to do by hand.
- The facts below are verified against the real binaries and are not guesses. Do **not**
  restart the investigation or re-derive V2–V7.
- This is a **personal restoration** of a retired single-player feature. Do **not**
  redistribute any complete stock or patched `CK2game.exe`; deliver only guarded patch
  scripts that edit the user's own verified executable.
- The user will run tests on their machine and upload results **only when interesting**.
  Be patient; ask for one small thing at a time.

---

## 1. Situation in one paragraph

CK2's retired **Monarch's Journey (MJ)** feature was restored to work offline by
byte-patching Windows **3.3.3 (May 2020)** `CK2game.exe`. A local JSON payload
(`gfx\monarchs`, 11 rulers / 33 challenges) plus a chain of length-preserving patches
**V2 → V7** make the panel, Bronzeman campaigns, live challenge progress, save/load, the
persistent feat cache, and the **in-game Continue** button all work. The single remaining
functional defect is that **feat/challenge progress shows 0 in-game after a cold
quit → relaunch → load**, even though (a) it survives a warm resign, and (b) the main-menu
MJ panel shows the correct values. A candidate fix (**V8**) was produced; the user tried it
and it "still didn't work" — unresolved.

## 2. Executable identities (all verified, key by SHA never by label)

Target: Windows May-2020 3.3.3 `CK2game.exe`, **24,753,368 bytes**,
PE32+ x86-64, image base `0x140000000`, `.text` raw `0x400`,
so **VA = raw_offset + 0x140000c00**.

| State | SHA-256 | Meaning / status |
|---|---|---|
| Stock 3.3.3 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | unpatched baseline |
| V5 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` | superseded |
| V6 | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | proven; V7 revert target |
| **V7 (current)** | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` | in-game Continue proven; **what the user runs now** |
| **V8 (candidate)** | `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93` | feat re-hydration candidate, **untested/inconclusive** |
| "V6" trampoline | `a6cb92b8…` | ❌ BANNED (injected code) |
| "V7" feat-update | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` | 🟡 ABANDONED (premise disproven) |

Ruler payload `gfx\monarchs` (unchanged, must verify): 101,949 bytes, SHA-256
`fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`; all
`event_time_end = 1893499200` (2030-01-01 UTC — deliberately **not** INT_MAX).

## 3. What already works today (V7 baseline — do not regress)

- Local 11-ruler payload; MJ arrow/panel; challenge names/descriptions.
- Play + Bronzeman start; "Challenges: Enabled"; campaign start.
- Live in-game challenge evaluation and tier progress (Bronze grant proven on Pavao).
- Save writing with `bronzeman=yes` + `special_event` + feat `global_*` variables.
- Manual Load with full deserialization (Bosnia 1173.3.3 → "Heretical Company 1/6").
- Persistent local feat cache `cache/q847rsja8ndx` across sessions.
- **In-game Continue** (main menu / MJ / Single Player) — no popup.

Not working: **Paradox launcher Continue (case C25)** — still grey; separate
`pdx_launcher.lib` / `launcher-v2.sqlite` path. Always launch `CK2game.exe` **directly**.

## 4. The open bug — feats reset after cold quit → relaunch → load

### Verbatim symptom (user, 2026-08-26)

> "feats reset when quitting completely. Resign → menu → load/continue = fine. Quit →
> relaunch → main-menu MJ interface (rulers, arrows, challenges, feats) intact →
> load/continue → feats all 0."

### Confirmed facts (preflight + disassembly)

- Feat progress lives in **two places**: ordinary script globals in the save
  (`global_established`, `global_heretical_company`, …), and a peak mirror in the local
  cache `cache/q847rsja8ndx` (plain key=value, `feat_progress_storage.cpp`).
- The **main menu** reads the cache → that's why it stays correct across a cold launch.
- The **in-game** counter is `CRulerFeatTracker`'s two `std::vector<int>`s at `+0x108`
  (current) and `+0x120` (cached). It is filled from the save's `global_*` values only by
  `CRulerFeatTracker::UpdateFeatProgress()`.
- `UpdateFeatProgress` is gated **twice** by `IsActiveForPlaythrough()`:
  1. `CGameState::DailyUpdate` skips the call entirely when it returns false
     (win `0x14066713f`; skip branch raw `0x00666546`: `74 0d`).
  2. `CalcShouldTrackFeatProgress()` (called at the top of `UpdateFeatProgress`) bails
     when it returns false (win call site `0x1407b8464`; continue branch raw `0x007b786b`:
     `75 05`).
- `IsActiveForPlaythrough()` requires the current game's featured-ruler key
  (`[gameState+0x598]`, i.e. the `special_event`) to be non-null **and** match a ruler name
  in the payload. A fresh campaign sets it via the frontend; a warm resign keeps process
  state; a **cold load does not re-establish it** → both gates fail → feats stay 0.
- **Identity drift was refuted**: preflight showed `user_id=84696387`, identical to the
  archived Bronze run, stable across launches. `category` changed across captures
  (`697115649` → `-1991027533` → `1474319405`) but is not the feat-scope key.
- Bronzeman **disables the console** by design, so `feat_log` / console probes are
  unusable — testing is GUI + preflight only.

### V8 (the candidate) — two length-preserving edits, no code injection

| Raw offset | VA | V7 | V8 | Purpose |
|---|---|---|---|---|
| `0x00666546` | `0x140667146` | `74 0d` | `90 90` | daily update always calls `UpdateFeatProgress` |
| `0x007b786b` | `0x1407b846b` | `75 05` | `eb 05` | `UpdateFeatProgress` ignores the `IsActiveForPlaythrough` gate |

Both offsets were verified untouched by V1–V7. The stock→V7 reconstruction was verified
byte-perfect (intermediate hashes match), so the V8 output hash is trustworthy. Downstream
safety is preserved: Bronzeman/Ironman mode bytes (`+0x500/+0x501`), the non-expired-ruler
check, and the achievement-eligibility helper are all still enforced, so a normal
non-Bronzeman game still never tracks feats.

### What the user reported (2026-08-29)

After the previous session (which fixed a bat line-ending bug — see §5), the user tried the
new files and said: **"it still didn't work, unlike early ones."** This is **ambiguous** and
must be resolved first (§6). It means **either**:

- **(A) the V8 bat still flickers/closes without running** (so the exe is still V7 and the
  fix was never applied — feats-0 would then be expected), **or**
- **(B) the bat ran and the exe is V8, but feats still show 0** after a cold load (the V8
  gate hypothesis was wrong or incomplete).

## 5. The bat "flicker" delivery problem (separate, blocking)

- Earlier (2026-08-27) the user reported the V8 `.bat` files "flick for a second and
  nothing happens" while the older V7 bats worked. Root cause found: the V8 bats had been
  saved with **Unix LF** line endings instead of Windows **CRLF**, which breaks cmd's
  multi-line `if (…)` blocks. **Already fixed in the repo** (all three V8 bats are CRLF and
  structurally identical to the working V7 bats; the `.ps1` is plain LF like the working
  V7 `.ps1`).
- If it **still** flickers for the user after re-copying, suspect their download/copy tool
  re-normalizing line endings, or them double-clicking instead of dragging. **Escalate to a
  bat-free path** and stop relying on the bat:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<folder>\patch_ck2_mj_v8.ps1" Apply "<folder>\CK2game.exe"
```

  or `Verify` / `Revert` in place of `Apply`. This bypasses the bat entirely.

## 6. First things to establish with the user (disambiguation, in order)

1. **What state is their exe actually in right now?** Have them run (bat-free if needed):
   `… patch_ck2_mj_v8.ps1 Verify <their CK2game.exe>` — or report the SHA-256 from
   `preflight_ck2_mj.ps1`. If it prints **V7**, the fix was never applied and case (A) is
   confirmed → fix the delivery, then re-test. If it prints **V8**, proceed to step 2.
2. **Does the apply window stay open and print `V8 FEAT-REHYDRATION PATCH COMPLETE` + the
   SHA-256?** If no, it's a delivery problem (§5), not a patching problem.
3. **With V8 confirmed applied:** quit completely → relaunch → Load/Continue the Pavao save
   (`Bronzeman_pavao_croatia.ck2` / `Croatia1278_01_*.ck2`). Are feats 0 **immediately**,
   or **also after one full in-game day**? (`DailyUpdate` runs once/day — if feats appear
   after the first day tick, the patch is working and the symptom is just timing.)
4. Ask for a **screenshot of the in-game challenges tab** plus the **preflight output**
   (binary SHA, payload SHA, cache `NON-ZERO FEATS` line, `user_id`).

## 7. If V8 is applied and feats are still 0 after a full day — next suspects

1. **A different gate inside `CalcShouldTrackFeatProgress`** still fails on cold load:
   - ruler-info **null** check (`win 0x1407b848d`: `test rax,rax; je fail`) — the
     `vtable+0xd8` "current ruler info" may be null/empty right after a cold load even
     though the main-menu roster (different `vtable+0x88` path) is populated;
   - Bronzeman/Ironman **mode bytes** `+0x500/+0x501` not set at the moment the tracker
     first runs after a cold load (set later than the first `DailyUpdate`?).
2. **The save genuinely doesn't carry the `global_*` values** for the loaded campaign
   (verify by unzipping the `.ck2` — it's a ZIP with `meta` — and reading the `vars`
   block). If present, the bug is read-path; if absent, it's a write-path bug.
3. **Live-trace the actual failing branch.** Best tool so far was x64dbg **attach-mode**
   (launch CK2, attach, set breakpoints on `CalcShouldTrackFeatProgress` →
   `0x1407b8450` and `IsActiveForPlaythrough` → `0x1407b8370`, reproduce the cold load,
   and read `al` at each `test al,al`). Note: x64dbg launch-mode crashed 14/14 times
   historically; attach-mode is the reliable route.
4. If a trace shows `IsActiveForPlaythrough` is false **because `[gameState+0x598]` is
   empty after cold load**, the root-cause fix is in the **save-load deserialization**
   (restore `special_event` into the game state), not in the tracker. Keep V8's two edits
   as a band-aid candidate but don't insist on them.

## 8. Key addresses (Linux 3.3.3 symbols == Windows May-3.3.3 code; win VA where noted)

- `CRulerFeatTracker::UpdateFeatProgress` — lin `0xff78a6` / **win `0x1407b8e60`**
- `CRulerFeatTracker::IsActiveForPlaythrough` — lin `0xff6d46` / **win `0x1407b8370`**
- `CRulerFeatTracker::CalcShouldTrackFeatProgress` — lin `0xff6e38` / **win `0x1407b8450`**
  (its `IsActiveForPlaythrough` call at `0x1407b8464`; the +0x65 achievement gate that V4
  already forced is at raw `0x007b78eb`)
- `CGameState::DailyUpdate` gate — lin `0xfc6659` / **win `0x14066713f`** (skip branch
  raw `0x00666546`)
- `CRulerFeatTracker::SetFeatProgress` lin `0xff7dfe`; `GetFeatLevel` `0xff7c68`;
  `RecalcScore` `0xff7cc2`; `ReloadFeatsDatabase` `0xff7f7a`
- `CFeatProgressStorage::ReadCachedProgress` lin `0xf46958`; `CacheProgress` `0xf460bc`;
  `SetNewProgress` `0xf47220`; `SetCachedProgressIfHigher` `0xf47534`; `Update` `0xf46722`;
  **`WipeFeats` `0xf45f8a` — never call**
- `CRulerFeatTracker` instance vectors: `+0x108` current progress, `+0x120` cached progress
- game state featured-ruler key (`special_event`): win `+0x598` (lin `+0x570`)

## 9. Environment and hard rules

- Test root: `C:\Users\UZWERG\Desktop\SteamCrusader`, payload at `gfx\monarchs`.
- Test **offline** (Internet disconnected). Launch `CK2game.exe` **directly**.
- Bronzeman console is disabled by design — no `feat_log`, no console probes.
- **Never** run `wipe_feats` (irreversibly clears the feat cache).
- **Never** apply May-2020 offsets to a different/newer exe (3.3.5.1 port is not feasible —
  see `WINDOWS_3351_PORT_ASSESSMENT.md`).
- **Never** use INT_MAX `event_time_end` (signed 32-bit overflow); 2030-01-01 is correct.
- **Never** resurrect the banned trampoline (`a6cb92b8…`) or the abandoned feat-V7
  (`0074af70…`).
- **Never** ask the user for credentials/tokens/`pdx_login.txt`.
- Verify every hash before disassembly; keep the patch table machine-readable.

## 10. Files to request from the user (only if the next session has no repo)

The user works "separately from GitHub", so the next session may not have the repo. If so,
ask only for what's needed, one item at a time:

- `patch_ck2_mj_v8.ps1` (+ the three V8 bats) — the candidate patcher;
- `preflight_ck2_mj.ps1` — prints binary SHA, payload SHA, cache values, `user_id`;
- the user's current `CK2game.exe` **SHA-256** (not the exe itself) to learn which state it is in;
- the Pavao `.ck2` save + `cache/q847rsja8ndx` if §7.2 is reached;
- `FEAT_RESET_QUIT_VS_RESIGN.md` and `CK2_MJ_ULTIMATE_HANDOFF.md` for deep background.

## 11. Suggested first message to paste into the next session

> Continuing the CK2 Monarch's Journey restoration. Baseline is V7
> `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` (Continue proven).
> The one open bug: feat progress shows 0 after a cold quit→relaunch→load but survives a
> resign. A candidate fix V8 (raw `0x00666546` `74 0d`→`90 90`; raw `0x007b786b`
> `75 05`→`eb 05`; SHA `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93`)
> was built, but the user reported "still didn't work" — not yet pinned down whether the
> bat didn't run or the patch didn't fix it. First, establish the exe's current state
> (Verify), then test a cold load and report 0-immediately vs 0-after-one-day. Never run
> wipe_feats; launch CK2game.exe directly; test offline. I'll upload results when I have
> something interesting.
