# Clean V9 feat-path trace

This is a diagnostic helper for the confirmed May-2020 CK2 3.3.3 Windows **V9**
executable. It is **not a patch** and does not edit `CK2game.exe` on disk.

V8 bypassed the `IsActiveForPlaythrough()` gates, but a cold
quit → relaunch → Load/Continue still showed feats at 0. Disassembly of the
stock exe (and the V8 clean trace) pinned the remaining failure to the **final
eligibility gate** inside `CalcShouldTrackFeatProgress()`:

- `UpdateFeatProgress` (VA `0x1407b8e60`, raw `0x7b8260`) calls
  `CalcShouldTrackFeatProgress` (VA `0x1407b8450`, raw `0x7b7850`).
- On a cold load every earlier check passes (ruler-info non-null, date not
  expired, game-mode bytes set, singleton flags `[+0x60]==0` and `[+0x65]!=0`),
  but the final call at raw `0x7b7906` (VA `0x1407b8506`):
  `call 0x1400af690` — the "all linked feature entries visible/available"
  eligibility check — returns 0, because the feature entries' availability
  flag bytes (`+0x58`/`+0x59`) are not populated yet at that moment on a cold
  load. The warm in-session load has them set, so the same call returns 1.

V9 therefore replaces that one call with `mov al,1; nop; nop; nop`:

```
raw 0x007b7906:  e8 85 71 8f ff   (call 0x1400af690)  ->  b0 01 90 90 90
```

Everything else from V8 is kept. Expected V9 SHA-256:

```
61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687
```

## Files

- `RUN_MJ_V9_CLEAN_TRACE.bat` — checks the exact V9 SHA-256, finds the
  already-running CK2 process, starts x64dbg in attach mode, and copies the
  script command to the clipboard.
- `MJ_V9_CLEAN_TRACE.txt` — x64dbg script that clears old breakpoints and arms
  the focused logging points (the eight `[MJ]` lines).

## Exact Windows procedure

1. Close CK2 and all x64dbg windows from the previous attempt. Do not delete
   the x64dbg database; the script clears its breakpoints in memory.
2. Keep the current confirmed V9 executable installed. The BAT refuses to
   attach to another hash.
3. Start the Windows executable directly, not the separate Paradox launcher:

   `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`

4. Wait until the normal CK2 main menu is visible. Do not load the save yet.
5. Put both files in one folder on the Windows machine (the x64dbg folder or
   the desktop works). Double-click:

   `RUN_MJ_V9_CLEAN_TRACE.bat`

   If the default paths are wrong, pass them as arguments:

   ```bat
   RUN_MJ_V9_CLEAN_TRACE.bat "C:\path\to\CK2game.exe" "C:\path\to\x64dbg.exe"
   ```

6. The BAT opens x64dbg attached to the running game and puts this command in
   the clipboard:

   ```text
   scriptexec "C:\path\to\MJ_V9_CLEAN_TRACE.txt"
   ```

7. In x64dbg, click the **bottom command box** (not the disassembly and not
   the Script tab), press **Ctrl+V**, and press **Enter once**. If x64dbg is
   paused at an attach/system event, press **F9 once first**, then paste.
8. The x64dbg log should contain:

   ```text
   [MJ] CLEAN V9 TRACE ARMED: stale breakpoints cleared; eight feat points logging without pauses.
   ```

   If `scriptexec` is not recognized by an old x64dbg build, enter:

   ```text
   scriptload "C:\path\to\MJ_V9_CLEAN_TRACE.txt"
   ```

   then open the Script tab and press **Space** once to run it.
9. Press **F9** if paused. Do not press F7/F8 and do not enable Trace mode.
10. Load/Continue the Pavao save from the in-game main menu (the cold-launch
    repro). Wait one in-game day if practical.
11. Exit CK2 normally. Right-click inside the x64dbg Log view and choose
    **Save**, e.g.:

    `C:\Users\UZWERG\Desktop\MJ_V9_CLEAN_TRACE_LOG.txt`

12. Send only `MJ_V9_CLEAN_TRACE_LOG.txt` (or paste the `[MJ]` lines). Do not
    send the whole Documents folder and do not run `wipe_feats`.

## What the results mean (V9)

- `V9_GATE_FORCE` fires on the cold path: execution reached the forced-true
  point at `CK2game.exe+7b8506`.
- `CALC_RETURN_PATH` has `AL=1` on the cold load: `CalcShouldTrackFeatProgress`
  now returns true where it previously returned 0, so `UpdateFeatProgress`
  proceeds.
- `CALC_RESULT` has `AL=1`: `UpdateFeatProgress` accepted the result.
- If `CALC_RETURN_PATH` still shows `AL=0`, the failure moved elsewhere and the
  log must include the full `[MJ]` burst plus the hash line.
- If `UPDATE_ENTRY` does not appear at all, the caller gate is still stopping
  the update; the log must include the hash line and the in-game actions.
- `RULER_INFO_CHECK` with `RAX=0` would mean the ruler-info pointer is null at
  the downstream check (did not happen in the V8 trace).

The save/cache files remain untouched. Breakpoints exist only while the
debugger is attached and are not saved into the executable.
