# Live CK2 observation and Continue debugging

This guide is for the exact May-2020 Windows CK2 3.3.3 test installation. Do not use
these addresses with CK2 3.3.5.1 or another build.

---

## Part 0 — READ FIRST: two problems found in the 2026-08-26 log drop

The logs from that session showed both tools failing silently. Fix these before
collecting any more evidence, or the next run will be just as empty. Full write-up:
`03_analysis/LATEST_LOGS_ANALYSIS_2026-08-26.md`.

### 0.0 Two things that are NOT the bug — do not chase them

- **"Challenges: Disabled" on the bronze-gauntlet tooltip is cosmetic** (case C17,
  *"stale account text; play works"*). Bronze has been earned with that tooltip on
  screen. It does not stop feats counting. Ignore it.
- **`[S_API FAIL] SteamAPI_Init() failed`** ×3 is expected offline and appears in
  the successful runs too.

### 0.1 x64dbg killed the game before it ever opened (14 launches, 14 failures)

Every session in `x64dbg log1/2/3.txt` **and the newest log supplied on 2026-08-26**
ended with:

```text
Исключение SetThreadName на ...  ("Task#0")
Процесс остановлен с кодом выхода 0x406D1388 (1080890248)
```

`0x406D1388` is `MS_VC_EXCEPTION` — the harmless magic exception a program raises
only to tell a debugger a thread's name. It is **not** a crash. Seeing it as the
*exit code* means the debugger swallowed it instead of passing it back to CK2, so
the process died at its first thread-naming call, long before the main menu. That
is why "x64dbg doesn't even open the game", and why no breakpoint was ever hit.

The game runs fine for 35 minutes **without** the debugger and dies at the same
instruction **with** it, every time — so the debugger setup is the cause.

**Fix A — use ATTACH mode. Do this one instead of fighting the settings.**

Attach skips the whole startup sequence, so the exception never arises. It also
suits the problem better: Continue lives in the main menu, so there is nothing
worth watching during startup anyway.

1. Start `CK2game.exe` **normally**, by double-clicking it. No debugger.
2. Wait for the main menu to appear.
3. Start **x64dbg** (the `x64dbg.exe` build — *not* `x32dbg.exe`).
4. **File → Attach**, select `CK2game.exe` in the list, click Attach.
5. Press **F9** once — the game unfreezes and keeps running.
6. Now set breakpoints (§6) and click Continue to trigger them.

**Fix B — only if you really want launch mode.**

1. Options → Preferences → **Exceptions** tab.
2. **Add range**: start `406D1388`, end `406D1388`.
3. Set that entry to **ignore / pass to program** — *not* "break". In some builds
   this is a "Ignore" checkbox; in others you must move it into the ignored list.
4. Do the same for `4000001E` and `40010006` if they show up.
5. Apply, then restart the session.

Shortcut rule: **F9 swallows an exception; Shift+F9 passes it to the program.**
If launch mode still dies, use Fix A — the newest log shows the settings change
had not taken effect.

One more benign note: `No symbols loaded for: ck2game.exe` is normal — CK2 ships
no PDB. The 2.6.1.1 PDBs in `10_binary_artifacts/` belong to a *different build*;
never force-load them onto 3.3.3 or every address will be wrong.

### 0.2 The old observer watched the wrong folders and captured nothing

`ck2_live_observer.log` was 15,530 lines: 15,526 of them a one-time inventory of the
game directory taken *before* launch, then only 4 process lines. **Zero** file-change
events across 35 minutes of play, because v1 dropped `save games`, `cache` and the
Paradox `logs` folder at startup (they did not exist yet) and never re-checked, and
because it looked for `%USERPROFILE%\Documents`, which is wrong on a redirected,
localised or OneDrive-backed profile.

**Use `ps1/watch_ck2_mj_v2.ps1` instead** — it re-resolves those folders every pass,
finds the real Documents location, hashes each `CK2game*.exe` at startup so the
actually-launched build is recorded, streams new `game.log` lines live, and prints
the feat counters whenever the cache file changes.

### 0.3 Run the preflight first — it may end the investigation immediately

**Just double-click `RUN_PREFLIGHT.bat`.** Nothing to type, nothing to install; it
is read-only and takes seconds. Step-by-step instructions are in
`README_PREFLIGHT.md` next to it.

It reports which patch level **each** `CK2game*.exe` actually is (all patch states
share the same 24,753,368-byte size, so only the hash distinguishes them — and the
last session had **both** a `CK2game.exe` and a `CK2gameV6.exe` present, with
Windows launching the former), verifies the payload, locates the real save/cache
folders, prints current feat progress, and flags whether the feat cache's `user_id`
has drifted between runs.

### 0.4 Three separate Continue surfaces — do not conflate them

| Surface | Current state | Code path |
|---|---|---|
| **Paradox launcher** Continue | grey, unclickable (C25) | `pdx_launcher.lib` — `0x00DE47C0`, `0x00DE8BB0`, `0x0099F540` |
| **In-game main menu** Continue | **SOLVED (V7)** — loads save, no popup | execution `0x1409E6700` / patch `0x009E5B8B` |
| **MJ panel / Single Player** Continue | **SOLVED (V7)** | same engine path |

Do not conflate launcher grey with in-game Continue. Launch `CK2game.exe`
directly. Attach-mode proof: `07_runtime_logs/x64dbg/`.

---

## Part 1 — safe external observer (recommended first)

This only watches files and process start/exit. It does not inject, patch, or alter CK2.

1. Make a copy of the test game folder.
2. Copy `watch_ck2_mj.ps1` to the Windows computer. For example:
   `C:\Users\UZWERG\Desktop\watch_ck2_mj.ps1`
3. Right-click Start → **Windows PowerShell**.
4. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Users\UZWERG\Desktop
.\watch_ck2_mj.ps1 -GameRoot 'C:\Users\UZWERG\Desktop\SteamCrusader' -Output "$PWD\ck2_live_observer.log"
```

5. Leave that window open, start CK2, and reproduce the grey Continue button.
6. Exit CK2 normally, then press Ctrl+C in the observer window.
7. Send back `ck2_live_observer.log` and, if useful, the latest `game.log` and `error.log`.

If the game is installed elsewhere, change only `-GameRoot`. The script also watches the
usual Paradox log directory under Documents.

## Part 2 — choosing a debugger

Use **x64dbg** if you want a visual interface and easy breakpoint/log inspection. Use
**WinDbg Preview** if you prefer Microsoft tooling and command lines. Either is suitable.
Do not run both attached to CK2 simultaneously.

Download only from the official project/Microsoft source. For x64dbg, use the x64 build.
The game executable is 64-bit, so x32dbg is wrong.

Before attaching:

- keep CK2 offline;
- use the copied test installation;
- make sure it is the May 2020 3.3.3 executable;
- apply the known-good **V7** patch (V6 is the revert target);
- never use `wipe_feats`;
- do not save over your only evidence saves.

## Part 3 — x64dbg visual procedure

1. Start `x64dbg.exe` (the 64-bit one).
2. Use **File → Open**, select `CK2game.exe` in the copied test folder.
3. Press F9 to run until the main menu.
4. If the game starts paused, press F9 again.
5. Reproduce the problem: open the MJ panel and/or return to the main menu where
   Continue is grey.
6. Press Ctrl+G and enter each address below, one at a time. Because ASLR may move the
   module, use `CK2game.exe+9E4970` form when x64dbg accepts module expressions:

```text
CK2game.exe+9E4970   candidate helper (VA 1409E4970)
CK2game.exe+9E5500   save enumeration (VA 1409E5500)
CK2game.exe+E64E90   status/compatibility helper (VA 140D64E90)
CK2game.exe+8145EC   ordinary Continue caller (VA 1408145EC)
```

7. At each location press F2 to set a breakpoint. Set the first four listed above.
8. Press F9. If CK2 stops, look at the instruction highlighted and the registers.
9. Press F9 to continue. If it stops repeatedly during normal gameplay, temporarily
   disable that breakpoint with F2 and leave only the one being tested.
10. For each stop, use **Debug → Run until user code** only if the current location is
    inside a system DLL. Do not single-step through many instructions initially.

The useful evidence is a screenshot or text export showing:

- which address was hit;
- the highlighted instruction;
- `RAX`, `RCX`, `RDX`, `R8`, and `R9`;
- whether the stop happened while opening the menu or only at startup.

To inspect the probable return from `0x140D64E90`, set a breakpoint there, note the
registers on entry, press F9 once, then reproduce the Continue refresh. If it stops at
the helper, single-step with F8 only until it returns; record the value in `EAX`/`RAX`.
Do not use F7 (step into) unless asked, because it can enter thousands of library calls.

To detach without changing the executable: use **Debug → Run** first, close CK2, then
close x64dbg. A breakpoint exists only in debugger memory and is not written to the EXE.

## Part 4 — WinDbg Preview procedure

1. Open WinDbg Preview as administrator only if normal permissions fail.
2. File → Start debugging → Launch executable, select the copied `CK2game.exe`.
3. At the command box, enter:

```text
.symfix
.reload
bp CK2game+0x9e4970
bp CK2game+0x9e5500
bp CK2game+0xe64e90
bp CK2game+0x8145ec
.logopen /t C:\Users\UZWERG\Desktop\ck2_windbg.log
 g
```

There must not be a space before `g` when entering it; the space above is only for
readability. The executable module may appear as `CK2game` or `CK2game.exe`; use `lm`
to see the exact name.

When a breakpoint hits, enter:

```text
.echo ==== BREAKPOINT ====
.bph
r rax rcx rdx r8 r9
u @rip L8
.logappend C:\Users\UZWERG\Desktop\ck2_windbg.log
 g
```

For a focused status-helper experiment, remove the noisy breakpoints with `bc *`, then
use:

```text
bp CK2game+0xe64e90 ".echo STATUS_HELPER; r rax rcx rdx r8 r9; u @rip L6; gc"
g
```

The `gc` command continues automatically after logging. Stop with Ctrl+Break if it
loops too often. Close the log with `.logclose` before sending it.

## What to send back

Best bundle, in priority order:

1. **the full console output of `preflight_ck2_mj.ps1`** — highest value by far;
2. `ck2_live_observer_v2.log` (from the v2 observer, not v1);
3. `ck2_windbg.log` or screenshots from x64dbg;
4. the last `game.log` and `error.log`;
5. **a photo/screenshot of the bronze-gauntlet "Challenges" tooltip**, showing which
   rows are `(X)` and which are `(*)` — this single image identifies the failing
   predicate faster than any log;
6. exact wording of the Continue failure: is the button **grey/unclickable**, or does
   it click and show the **"Continue failed!"** dialog? These are different bugs and
   the answer changed between sessions;
7. whether manual Load still opens the same Bronzeman save.

Only one observer log is needed — in the last drop `watch_ck2_mj LOG.txt` turned out
to be nothing more than the final 1,479 lines of `ck2_live_observer.log`.

Do not send passwords, account files, or your entire Documents directory.

## Interpretation

- Breakpoint at `0x1409e5500` never hits: the frontend is not running the expected
  save-enumeration path, or the wrong executable/build is running.
- Enumeration hits, but candidate helper is never reached: the rejection is earlier.
- `0x140D64E90` returns a negative value at `0x1409E4DC1` or `0x1409E5A71`: this is
  probably the remaining compatibility/status gate.
- Candidate routines run and produce a non-empty save, but Continue stays grey: likely
  frontend refresh/order or a separate boolean enable predicate.
- CK2 crashes: preserve the debugger log and the last `game.log`; do not immediately
  restart and overwrite the evidence.
