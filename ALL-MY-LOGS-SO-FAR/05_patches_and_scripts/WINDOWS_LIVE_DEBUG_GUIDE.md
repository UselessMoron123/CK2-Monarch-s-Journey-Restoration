# Live CK2 observation and Continue debugging

This guide is for the exact May-2020 Windows CK2 3.3.3 test installation. Do not use
these addresses with CK2 3.3.5.1 or another build.

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
- apply the known-good V6 patch only;
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

1. `ck2_live_observer.log`;
2. `ck2_windbg.log` or screenshots from x64dbg;
3. the last `game.log` and `error.log`;
4. exact description: “Continue grey from main menu”, “Continue grey from MJ panel”,
   or both;
5. whether manual Load still opens the same Bronzeman save.

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
