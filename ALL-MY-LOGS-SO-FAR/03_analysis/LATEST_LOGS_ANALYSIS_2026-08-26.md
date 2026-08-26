# Analysis of `latest logs/` — 2026-08-26 session

Scope: every file in the repository-root folder `latest logs/` — the ten Paradox
game logs, both watcher logs, all x64dbg logs (including the 5th supplied in
chat), the two patch scripts, the error-message transcript, and
`what we wanted to do.txt`.

Method: each new log was diffed against the **archived logs of the known-good V6
run** in `07_runtime_logs/` (`*_v6sl.log` = the "second look" Pavao run that
granted Bronze).

> ### Correction notice — two claims in the first version of this file were WRONG
>
> The user corrected both, and the repository's own records confirm the user:
>
> 1. **"Challenges: Disabled" does NOT explain the feats.** It is case **C17**,
>    already classified in `00_START_HERE/CASES_AND_FINDINGS.md` as
>    *"PARTIAL **cosmetic** — stale account text; **play works**"*, and in
>    `V6_RUNTIME_RESULTS.md` §7 as *"tooltip-only inaccuracy"*. The user
>    independently confirms: *"previously 'challenges: disabled' didn't prevent
>    anything — I clearly remember earning points and getting notification about
>    reaching bronze level."* The tooltip is a red herring. **Retracted.**
> 2. **Continue's symptom has NOT changed.** Case **C08** already reads
>    *"Continue button greyed / **'Continue failed'**"* — both were recorded
>    together from the start. The launcher button is still grey and unclickable;
>    the in-game dialogs were present before and still are. **Retracted.**
>
> What survives from the first pass, unaffected: the loaded-save-vs-fresh-campaign
> finding (§2), the broken watcher (§4), the dead x64dbg sessions (§5), and the
> clean bill of health on the other eight logs (§7).

---

## 1. There are three separate "Continue" surfaces — keep them apart

Conflating these has caused confusion before. Per the user's own description:

| # | Surface | State | Note |
|---|---|---|---|
| 1 | **Paradox launcher** Continue (outer window, before the game starts) | **grey, unclickable** | save *name* is visible beside it |
| 2 | **In-game main menu** Continue | clickable → **"Continue failed!"** dialog | |
| 3 | **MJ panel** Continue, and **Single Player** menu Continue | clickable → **"Continue failed!"** dialog | SP menu has Continue / New Game / Load Game |

All three are longstanding (C08) and **all three predate this session.** Surface 1
is a different code path from 2/3: the launcher is `pdx_launcher.lib`
(`CPdxLauncher::UpdateContinueSaveName` `0x00DE47C0`,
`CPdxLauncherGUI::OnContinue` `0x00DE8BB0`), whereas 2/3 go through the frontend
path `0x1408145ec`. A fix for one will not necessarily fix the other.

Manual **Single Player → Load Game still works** (C07, SOLVED) — that remains the
usable route.

---

## 2. The one solid new finding: this session loaded a save, it did not start a campaign

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
... same first three lines ...
[history.cpp:212]: Executing History from 1066.9.15 to  1278.1.1   <-- fast-forward
[frontend.cpp:1328]: [[ Launching SINGLEPLAYER-game ]]
        Start-date: 1278.1.1
        Country: No Character
[characterinteraction.cpp:4648]: ... chosen to be Cardinal  (x9)
[messagehandler.cpp:623]: ... has become Count of Imotski.
[messagehandler.cpp:623]:
Congratulations!
You earned the rank of Bronze in the "Established" challenge.
```

Three hard differences:

1. **The fast-forward `Executing History … to 1278.1.1` line is missing.** History
   is fast-forwarded to the bookmark only when a **new campaign** starts.
2. **Date is 1278.1.8, a week past the bookmark**, and `Country` is a named
   character rather than `No Character`.
3. **`messagehandler.cpp:623` count: 6 in the working run, 0 in the new run.**

So the only session that ever granted Bronze was a **fresh campaign**; this one
**resumed a save**. That is a real behavioural difference between the working
and non-working runs, and it is the strongest lead available.

---

## 3. Leading hypothesis for the feats: the local cache may be keyed to an identity that changed

The peak progress store is `cache/q847rsja8ndx` (`feat_progress_storage.cpp`),
a plaintext key=value file. The repository holds **two** captured states:

| File | `user_id` | `category` | `established` | `heretical_company` |
|---|---:|---:|---:|---:|
| `q847rsja8ndx.txt` | **453496064** | 697115649 | 0 | 1 |
| `q847rsja8ndx_v6_secondlook.txt` | **84696387** | -1991027533 | 4 | 0 |

The filename is identical, and `key`/`id` are identical in both
(`-2128831035`, which is the FNV-1a 32-bit offset basis reinterpreted as signed —
i.e. the hash of an empty string). But **`user_id` and `category` differ between
the two captures.**

That is suspicious. If the game derives `user_id` from account/Steam state that
is unavailable offline, the value may be unstable across installs or runs. A
changed `user_id` could make the game treat the stored progress as belonging to
someone else and start from zero — which would look exactly like "feats reset",
**and would not come back on unpause**, because the counters it is reading are a
different set.

**This is a hypothesis, not a conclusion.** It is cheap to test: `preflight_ck2_mj.ps1`
now prints the live `user_id`/`category` and compares them against both known
values. If today's `user_id` matches neither — or changes between two launches —
the hypothesis is confirmed and the fix is an identity-stability patch, not a
save-validity patch.

### Alternative still open

The other candidate is simply **which binary ran**. The observer recorded two
same-sized executables in the game root:

```text
size=24753368 ...\CK2game.exe        <-- this is the one that was launched
size=24753368 ...\CK2gameV6.exe
```

Every patch state (stock, V1–V6) is exactly 24,753,368 bytes, so size proves
nothing — only SHA-256 does, and nothing hashed them. If `CK2game.exe` is not
the V6 baseline, behaviour will differ from the proven run. The preflight
settles this in seconds.

---

## 4. The watcher captured nothing — three bugs

`ck2_live_observer.log` is 15,530 lines, of which **15,526 are a one-time
inventory** taken before launch. The rest:

```text
Observer started / Watching: C:\Users\UZWERG\Desktop\SteamCrusader
PROCESS START pid=3804   PROCESS EXIT pid=3804   PROCESS START pid=5064
```

**Zero `FILE CHANGED` events, zero log lines, across 35 minutes of play.** Causes,
all in `ps1/watch_ck2_mj.ps1`:

1. `$paths` is built **once** and filtered with `Test-Path`. `save games`,
   `cache` and the Paradox `logs` folder did not exist at that instant, so they
   were dropped **permanently**. The three folders worth watching were never watched.
2. It looks for `$env:USERPROFILE\Documents`, which is wrong on a redirected,
   localised or OneDrive-backed profile. The inventory confirms **no `cache`, no
   `save games`, no `logs`** anywhere under the game root, so the real data lives
   in the user profile — wherever that actually is.
3. A recursive `Get-ChildItem` over ~15,500 files every second cannot keep pace.

`watch_ck2_mj LOG.txt` is merely the **last 1,479 lines of the same file** — a
console-scrollback copy. Only one of the two ever needs sending.

Replacement: `ps1/watch_ck2_mj_v2.ps1`.

---

## 5. x64dbg: 14 launches, 14 identical deaths — including the newest log

The log supplied in chat is byte-for-byte the same story as the previous four:

```text
Поток 1016 создан, Точка входа: ck2game.00007FF75FD6BBA8
Исключение SetThreadName на 00007FFEE02DCD29 (3F8, "Task#0")
Исключение SetThreadName на 00007FFEE02DCD29 (3F8, "Task#0")
Поток ... завершен (x5)
Процесс остановлен с кодом выхода 0x406D1388 (1080890248)
```

`0x406D1388` is `MS_VC_EXCEPTION` — the magic exception a program raises purely
to tell a debugger a thread's name. It is **not** a crash condition. The process
exit code being *equal to* that exception code means the process terminated on
it instead of continuing.

The game runs fine for 35 minutes **without** the debugger, and dies at the same
instruction **with** it, every single time — so the debugger setup is the cause,
not the game.

**The exception-ignore fix has evidently not taken effect yet** (the newest log is
unchanged). Rather than fight the settings dialog, use **attach mode**, which
sidesteps startup exceptions entirely and is better suited to this problem
anyway — the Continue button lives in the main menu, so there is nothing worth
watching during startup:

1. Start `CK2game.exe` **normally** (no debugger) and wait for the main menu.
2. Start **x64dbg** (the x64 build, not x32dbg).
3. **File → Attach**, pick `CK2game.exe`, attach.
4. Press **F9** once so the game is running again.
5. Set breakpoints (`Ctrl+G`, then `F2`), then click Continue to trigger them.

If launch-mode is required later, set the exception rule first:
Options → Preferences → **Exceptions** → *Add range* → start `406D1388`,
end `406D1388` → mark it **ignored / passed to the program**, not "break".
Also ignore `4000001E` and `40010006` if they appear. Remember the shortcut
difference: **F9 swallows an exception; Shift+F9 passes it to the program.**

Benign and not worth chasing (present in successful runs too):
`[S_API FAIL] SteamAPI_Init() failed` ×3, and
`No symbols loaded for: ck2game.exe` (CK2 ships no PDB; the 2.6.1.1 PDBs in
`10_binary_artifacts/` are a *different build* and must never be force-loaded
onto 3.3.3).

---

## 6. Breakpoints worth setting once the debugger actually attaches

For surfaces 2/3 (in-game "Continue failed!"):

```text
CK2game.exe+9E5500   save enumeration / continue data setup
CK2game.exe+9E4970   candidate construction & validity
CK2game.exe+E64E90   status/compatibility helper (watch the sign of EAX on return)
CK2game.exe+8145EC   ordinary frontend Continue caller
```

For surface 1 (grey launcher button) the relevant symbols are different and
have **not** been exercised yet:

```text
CK2game.exe+DE47C0   CPdxLauncher::UpdateContinueSaveName
CK2game.exe+DE8BB0   CPdxLauncherGUI::OnContinue
CK2game.exe+99F540   anon::GetContinueSave(CDLCManager*)  (launcher pre-scan)
```

The launcher shows the save *name* but keeps the button grey, which means the
pre-scan finds a candidate and something later disables the control — the same
enable/disable shape as `RefreshContinueButton` in the 2.6.1.1 reference model.

---

## 7. Everything else: verified clean

| Log | Verdict |
|---|---|
| `setup.log` | Same content as the working V6 run, only re-ordered. `Version: 3.3.3 (SOHY)`, `Hash: f516e46`, `2020-05-06` — **correct build**. |
| `text.log` | Same content, re-ordered. `FEAT_HIGHSCORE_TT`/`FEAT_CURRENT_TT` duplicate warnings appear 4× in **both** runs — pre-existing. MJ challenge strings load in 5 languages → **the payload is being read**. |
| `error.log` | 220 lines, **all** `dynasty.cpp:1663 … invalid texture in coat of arms`. Byte-identical to an archived run. **No save/load/parser errors whatsoever.** |
| `system.log` | Identical to the working run except two extra `alt tab` lines — an interactive session. |
| `ai.log` | `Human takes control of Duke Pavao of Croatia` — correct featured ruler. |
| `system_interface.log` | 78 `size x: 0 and y: 0` warnings — **identical count** to the working run. Pre-existing cosmetic. |
| `graphics.log`, `historical_setup_errors.log`, `message.log` | Stock noise only. |
| `patch_ck2_mj_v5/v6.txt` | Correct guarded patchers: hash-gated, verified backup, in-memory hash check, atomic verified write. They cannot silently produce a wrong binary — but they only patch the file dragged onto them, which is the `CK2game.exe` / `CK2gameV6.exe` question above. |

---

## 8. Next steps, in order

1. **Run the preflight** (`RUN_PREFLIGHT.bat`, double-click). Confirms which
   binary is live, and prints `user_id`/`category` from the feat cache.
2. **Launch twice, comparing `user_id` between runs.** If it changes, §3 is
   confirmed and that becomes the V7 target instead of Continue.
3. **One fresh Bronzeman campaign** — the only configuration ever proven to
   grant Bronze. If feats accrue there but not in the resumed save, the problem
   is save-scoped; if they fail in both, it is identity- or binary-scoped.
4. Re-test Continue with `watch_ck2_mj_v2.ps1` running.
5. Debugger work only after attach-mode is confirmed working.

## 9. Files added

- `05_patches_and_scripts/RUN_PREFLIGHT.bat` — double-click launcher.
- `05_patches_and_scripts/ps1/preflight_ck2_mj.ps1` — read-only state report.
- `05_patches_and_scripts/ps1/watch_ck2_mj_v2.ps1` — corrected observer.
- `05_patches_and_scripts/WINDOWS_LIVE_DEBUG_GUIDE.md` — Part 0 rewritten.
