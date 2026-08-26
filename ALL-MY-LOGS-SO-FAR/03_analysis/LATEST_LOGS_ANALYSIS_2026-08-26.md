# Analysis of `latest logs/` — 2026-08-26 session

Scope: every file in the repository-root folder `latest logs/` — the ten Paradox
game logs, both watcher logs, all four x64dbg logs, the two patch scripts, the
error-message transcript, and `what we wanted to do.txt`.

Method: each new log was diffed against the **archived logs of the known-good V6
run** in `07_runtime_logs/` (`*_v6sl.log` = the "second look" Pavao run that
granted Bronze). That A/B is what makes the conclusions below evidence-based
rather than speculative.

---

## 1. Bottom line

**The feats did not "reset". Challenge tracking was switched off for the whole
session, so every counter read 0 and nothing could accumulate on unpause.**

The user's own screenshot transcript (`text of error messages.txt`) contains the
proof, and it is the single most important artifact in the drop:

```text
Challenges: Disabled
  (*) Game must be played in Bronze man or Ironman mode
  (*) No Game Rule must disable challenges
  (X) No User Modification that change the game's checksum must be active
  (X) The save file must not have been changed, and must have had challenges
      enabled from the start
  (X) Steam must be active
  (*) The Ruler Designer cannot be used
```

Mapped onto the service-flag model in `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`
§8.2, the challenge predicate needs:

| # | Requirement | Service byte | This session |
|---|---|---|---|
| 1 | Bronzeman/Ironman context | `+0x500/+0x501` | OK |
| 2 | Game rules permit challenges | rule evaluator | OK |
| 3 | **Save is valid / unchanged** | **`+0x61`** | **RED** |
| 4 | Stock checksum | `+0x63` | RED (expected offline) |
| 5 | No Ruler Designer | `+0x62` | OK |
| 6 | Steam active | `+0x65` | RED (expected offline) |

Rows 4 and 6 being red is **normal and documented** — V4 deliberately left the
display honest while bypassing those two gates
(`04_test_guides_and_reports/CK2_MJ_windows_v4_test_guide.md`: *"The requirement
list may still draw red marks beside the real Steam and checksum rows. That is
intentional and honest."*).

**Row 3 is the regression.** `save_ok` (`+0x61`) is a real check that V4/V5/V6
deliberately left intact because a legitimate Bronzeman save passes it. It is
red here. Because the in-game feat tracker (`0x1407b8450`) consumes the *same*
eligibility helper (`0x1400af690`), a false `+0x61` disables tracking outright:

- every feat renders as 0 → looks exactly like "feats reset";
- the tracker never runs → **unpausing cannot restore them**.

That is precisely the two-part symptom described. It is **not** the old
token-`0x3816` reader bug (Part 3 / `CONTRADICTIONS.md` C3 already retired that
theory), and it is **not** save corruption — `error.log` records zero
save-parsing problems this run.

---

## 2. Decisive evidence: this run *loaded a save*, the working run *started a campaign*

`game.log`, new run (480 bytes):

```text
[history.cpp:212]: Executing History from -1.1.1 to  2.1.1
[history.cpp:212]: Executing History from 2.1.1 to  1066.9.15
[ck_application.cpp:803]: After first history execution
[controlcommands.cpp:58]: Human MrHuman set as primary local
[frontend.cpp:1328]: [[ Launching SINGLEPLAYER-game ]]
        Start-date: 1278.1.8
        Country: Pavao Subic
```

`game_v6sl.log`, archived **working** run (1668 bytes):

```text
[history.cpp:212]: Executing History from -1.1.1 to  2.1.1
[history.cpp:212]: Executing History from 2.1.1 to  1066.9.15
[ck_application.cpp:803]: After first history execution
[history.cpp:212]: Executing History from 1066.9.15 to  1278.1.1   <-- fast-forward
[frontend.cpp:1328]: [[ Launching SINGLEPLAYER-game ]]
        Start-date: 1278.1.1
        Country: No Character
[characterinteraction.cpp:4648]: ... chosen to be Cardinal  (x9)
[messagehandler.cpp:623]: ... has become Count of Imotski.
[messagehandler.cpp:623]:
Congratulations!
Word has spread far and wide of your achievements.
You earned the rank of Bronze in the "Established" challenge.
```

Two hard differences:

1. **Third `Executing History` line present only in the working run.** History is
   fast-forwarded to the bookmark date only when a **new campaign** starts. Its
   absence in the new log, combined with a mid-campaign date of **1278.1.8**
   (a week past the 1278.1.1 bookmark) and a named `Country: Pavao Subic`, means
   this session **loaded an existing save** rather than starting fresh.
2. **`messagehandler.cpp:623` count: 6 in the working run, 0 in the new run.**
   No challenge messages, no rank grants, no notifications of any kind.

So the only session that ever produced a Bronze grant was a *fresh* campaign.
This session resumed a save — and that save is the one failing `+0x61`.

### Why that matters — the save may be permanently ineligible

Requirement 3 reads: *"the save file must not have been changed, and must have
had **challenges enabled from the start**"*. That is a sticky property recorded
in the save. If the 1278.1.8 campaign was ever begun or re-saved while
challenges were disabled (for example under a wrong or partially-patched
executable), the save is poisoned for good: fixing the binary afterwards will
**never** make feats count in that particular save.

This is the most likely trap in play, and it is testable in five minutes (§5).

---

## 3. The watcher logs captured essentially nothing — the script has three bugs

`ck2_live_observer.log` is 1.9 MB and 15,530 lines, of which **15,526 are a
one-time directory inventory** taken before the game ever started. The only
other lines in the entire file:

```text
[15:41:42.662] Observer started. GameRoot=C:\Users\UZWERG\Desktop\SteamCrusader
[15:41:42.817] Watching: C:\Users\UZWERG\Desktop\SteamCrusader
[15:45:07.452] PROCESS START pid=3804 path=...\CK2game.exe
[16:20:53.118] PROCESS EXIT  pid=3804
[16:21:50.876] PROCESS START pid=5064 path=...\CK2game.exe
```

**Zero `FILE CHANGED` events. Zero `LOG` lines. Across 35 minutes of play.**

Root causes, all in `ps1/watch_ck2_mj.ps1`:

1. **The `Watching:` line proves only the game root was monitored.** The script
   builds `$paths` once and filters with `Where-Object { Test-Path $_ }`. The
   save folder, the cache folder and the Paradox log folder all failed that test
   at 15:41:42, so they were dropped **permanently** — even though the game
   creates and writes them seconds later. The three things the tool exists to
   watch were the three things it never looked at.
2. **`$env:USERPROFILE\Documents` is the wrong path on this machine.** The
   x64dbg logs are Russian-localised; with a redirected, OneDrive-backed or
   localised Documents folder that literal path does not resolve. CK2 keeps
   `save games\`, `logs\` and the feat cache under the real Documents tree —
   confirmed by the inventory, which shows **no `cache`, no `save games` and no
   `logs` directory anywhere in the game root** (top-level dirs are only:
   common, connectui, decisions, dlc_metadata, eula, events, gfx, history,
   interface, launcher, localisation, map, mod, music,
   open_source_license_notices, pdx_browser, sound, soundtrack, tutorial).
3. **A full recursive `Get-ChildItem` of ~15,500 files every second** is far too
   slow to keep up, and it re-stats the whole tree instead of using a
   `FileSystemWatcher`.

`watch_ck2_mj LOG.txt` (1,479 lines) is simply the **last 1,479 lines of the same
file** — a console-scrollback copy, identical tail, no extra information. Only
one of the two ever needs to be sent.

**Consequence:** the watcher cannot support *any* conclusion about saves, cache
or feat progress. Its silence is a blind spot, not evidence. §6 ships a fixed
version.

---

## 4. x64dbg never actually ran the game — one setting is responsible

Across all four debugger logs (**13 launches total**: 1 + 2 + 10, plus a symbol-only
log) every single session ends identically:

```text
Поток 2116 создан, Точка входа: ck2game.00007FF75FD6BBA8
Исключение SetThreadName на 00007FFEE02DCD29 (844, "Task#0")
Исключение SetThreadName на 00007FFEE02DCD29 (844, "Task#0")
Процесс остановлен с кодом выхода 0x406D1388 (1080890248)
```

`0x406D1388` is `MS_VC_EXCEPTION`, the magic code MSVC programs raise purely to
tell a debugger a thread's name. It is **not** a crash and not a real exit code —
seeing it *as* the exit code means the exception was swallowed by the debugger
and never handed back to CK2, so the unhandled-exception path terminated the
process. In x64dbg, `F9` resumes **without** passing the exception to the
program; `Shift+F9` passes it on. Every run here used the former.

This is why the game "doesn't even open": CK2 dies at its very first
`SetThreadName` call, long before the main menu — so **no Continue/feat evidence
was ever reachable**, and the four MJ breakpoint addresses were never hit.

Also confirmed benign in these logs:

- `[S_API FAIL] SteamAPI_Init() failed` ×3 pairs — expected offline, present in
  every historical run too.
- `No symbols loaded for: ck2game.exe` (the `(maybe not needed)` log) — CK2 ships
  no PDB; the 2.6.1.1 PDBs in `10_binary_artifacts/` are a different build and
  must not be force-loaded onto 3.3.3.
- ASLR is off in practice: the module lands at `00007FF75EF20000` in every
  session, but `CK2game.exe+OFFSET` form should still be used.

### Fix

Options → Preferences → **Exceptions** → Add range `0x406D1388`, set to
**ignore** (pass to program, do not break). Then `F9` once and CK2 boots
normally. Full corrected procedure in §6 of the updated debug guide.

---

## 5. Two candidate causes for the red `save_ok`, and how to tell them apart

The logs cannot discriminate between these, but one command can.

### Candidate A — the wrong executable was launched

The inventory shows **two same-sized binaries** in the game root:

```text
[15:41:42.948] FILE NEW size=24753368 ...\CK2game.exe
[15:41:42.964] FILE NEW size=24753368 ...\CK2gameV6.exe
```

and the process that actually ran was **`CK2game.exe`**, not `CK2gameV6.exe`.
All patch states (stock, V1–V6) are byte-identical in size at 24,753,368, so
size proves nothing — only SHA-256 does, and the observer never hashed them.
If `CK2game.exe` is stock or an earlier patch level, the V4 eligibility rewrite
is absent and challenges are disabled exactly as observed.

### Candidate B — the 1278.1.8 save is permanently ineligible

Per §2, a save that was ever started or written while challenges were off keeps
that state forever.

### Discriminator

Run `preflight_ck2_mj.ps1` (§6). It hashes every `CK2game*.exe`, names the exact
patch level of each, verifies the payload, locates the real Documents tree, and
prints the live feat cache. Then start **one fresh Bronzeman campaign** under the
binary it confirms as V6 and check whether the counters move. Fresh campaign
worked before; a resumed save is the untested path.

---

## 6. Everything else checked, and found clean

| Log | Verdict |
|---|---|
| `setup.log` | Byte-for-byte the same content as the working V6 run, only re-ordered (religion block emitted earlier). `Version: 3.3.3 (SOHY)`, `Hash: f516e46`, `2020-05-06` — **correct build**. |
| `text.log` | Same content as working run, re-ordered. `FEAT_HIGHSCORE_TT` / `FEAT_CURRENT_TT` duplicate-key warnings appear 4× in **both** — pre-existing, harmless. MJ challenge strings ("Progress continues for as long as you play the featured ruler's dynasty") load in 5 languages, so **the payload is being read**. |
| `error.log` | 220 lines, **all** of them `dynasty.cpp:1663 … invalid texture in their coat of arms`. Deterministic startup noise; byte-identical to an archived run. **No save, load, or parser errors at all.** |
| `system.log` | Identical to working run apart from two extra `Used video memory before/after alt tab` lines — the user alt-tabbed. Confirms an interactive session. |
| `graphics.log` | Stock map/port warnings only. |
| `historical_setup_errors.log` | 4 stock unborn-spouse warnings. |
| `message.log` | 2 stock lines. |
| `ai.log` | `[gamestate.cpp:4609]: Human takes control of Duke Pavao of Croatia` — the correct featured ruler was in control. |
| `system_interface.log` | 78 `size x: 0 and y: 0` layout warnings — **identical count to the working run**. Pre-existing cosmetic issue, unrelated. |
| `patch_ck2_mj_v5.txt` / `v6.txt` | Reviewed in full. Both are the correct, guarded patchers: hash-gated on entry, verified backup, in-memory hash check, atomic verified write. V5 → `29556549…`, V6 → `f5b7dfd6…`. They **cannot** silently produce a wrong binary — but they also only ever touch the file you drag onto them, which is the `CK2game.exe` / `CK2gameV6.exe` ambiguity above. |

### New, previously unrecorded symptom

`STATUS.md` and `V6_RUNTIME_RESULTS.md` §6 both record Continue as **greyed
out / not clickable**. The transcript in this drop shows something different:

> "When trying to click continue in main menu, or in single player menu:
> **Continue failed!** Continuing from the latest save failed…"

The button is now **clickable and produces the stock failure dialog**. That is a
genuine state change and it re-frames the V7 target: the enable predicate is
evidently satisfied, and the failure has moved downstream into candidate
validation. Note the dialog's own listed causes include *"The save doesn't work
with the current version of the game"* and *"your game is modified"* — the same
`+0x61`/checksum family as the disabled challenges, which suggests one shared
root cause rather than two separate bugs.

---

## 7. Recommended next steps, in order

1. **Run `preflight_ck2_mj.ps1`.** Answers "which binary am I actually running,
   and where is my feat cache" in one shot. Nothing else is worth doing first.
2. If `CK2game.exe` is not `f5b7dfd6…`, copy `CK2gameV6.exe` over it (or launch
   `CK2gameV6.exe` directly) and retest.
3. **Start one fresh Bronzeman campaign** as Pavao and confirm the counters move
   before touching the old save again. This reproduces the one configuration
   already proven to work.
4. Only then retest Continue, with `watch_ck2_mj_v2.ps1` running so the save and
   cache writes are actually captured.
5. If the debugger is still wanted, apply the `0x406D1388` exception-ignore fix
   first; without it no breakpoint can ever be reached.

## 8. Files added by this analysis

- `05_patches_and_scripts/ps1/preflight_ck2_mj.ps1` — one-shot state report.
- `05_patches_and_scripts/ps1/watch_ck2_mj_v2.ps1` — corrected observer.
- `05_patches_and_scripts/WINDOWS_LIVE_DEBUG_GUIDE.md` — §0 and §6 added for the
  exception fix and the new scripts.
