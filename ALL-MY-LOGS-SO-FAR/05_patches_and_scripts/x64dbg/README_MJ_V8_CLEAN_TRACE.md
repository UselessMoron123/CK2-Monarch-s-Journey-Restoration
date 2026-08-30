# Clean V8 feat-path trace

This is a diagnostic helper for the confirmed May-2020 CK2 3.3.3 Windows V8
executable. It is **not a patch** and does not edit `CK2game.exe` on disk.

The helper uses x64dbg attach mode, clears the stale breakpoints that were visible
in the supplied log, installs only the seven `CRulerFeatTracker`/caller points, and
sets each point to log without stopping. It deliberately does not use single-step
mode.

## Files

- `RUN_MJ_V8_CLEAN_TRACE.bat` — checks the exact V8 SHA-256, finds the already-running
  CK2 process, starts x64dbg in attach mode, and copies the script command to the
  clipboard.
- `MJ_V8_CLEAN_TRACE.txt` — x64dbg script that clears old breakpoints and arms the
  focused logging points.

## Exact Windows procedure

1. Close CK2 and all x64dbg windows from the previous attempt. Do not delete the
   x64dbg database; the script clears its breakpoints in memory.
2. Keep the current confirmed V8 executable installed. The BAT refuses to attach to
   another hash. Do **not** apply a new patch for this test.
3. Start the Windows executable directly, not the separate Paradox launcher:

   `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe`

4. Wait until the normal CK2 main menu is visible. Do not load the save yet.
5. Put both files in one folder on the Windows machine. The easiest location is the
   x64dbg folder or the desktop. Double-click:

   `RUN_MJ_V8_CLEAN_TRACE.bat`

   The default paths are the paths from the supplied log. If necessary, pass the
   game and debugger paths as arguments:

   ```bat
   RUN_MJ_V8_CLEAN_TRACE.bat "C:\path\to\CK2game.exe" "C:\path\to\x64dbg.exe"
   ```

6. The BAT opens x64dbg attached to the running game and puts this command in the
   clipboard:

   ```text
   scriptexec "C:\path\to\MJ_V8_CLEAN_TRACE.txt"
   ```

7. In x64dbg, click the **bottom command box** (not the disassembly and not the
   Script tab), press **Ctrl+V**, and press **Enter once**. If x64dbg is currently
   paused at an attach/system event, press **F9 once first**, then paste the command.
8. The x64dbg log should contain this line:

   ```text
   [MJ] CLEAN V8 TRACE ARMED: stale breakpoints cleared; seven feat points logging without pauses.
   ```

   If `scriptexec` is not recognized by an old x64dbg build, enter:

   ```text
   scriptload "C:\path\to\MJ_V8_CLEAN_TRACE.txt"
   ```

   Then open the Script tab and press **Space** once to run the loaded script.
9. Press **F9** if the debugger is paused. Do not press F7, F8, or start Trace mode.
10. Now use the in-game main menu to load/Continue the Pavao save. Reproduce the
    cold-launch symptom. If practical, also wait one in-game day or perform one
    action that should add live progress.
11. Exit CK2 normally. The focused breakpoint lines will already be in the x64dbg
    Log view. Right-click inside the Log view and choose **Save**, saving it as for
    example:

    `C:\Users\UZWERG\Desktop\MJ_V8_CLEAN_TRACE_LOG.txt`

    If the Log view is not visible, use the x64dbg menu to show the Log view first.
12. Send only `MJ_V8_CLEAN_TRACE_LOG.txt` (or paste the lines beginning with
    `[MJ]`). Do not send the entire Documents folder and do not run `wipe_feats`.

## What the results mean

- `RESTORE_GATE` appears during cold Load/Continue: the restore caller reached its
  outer gate. Its `ZF` value is relevant at that instruction.
- `DAILY_GATE` appears after a day/action: the ordinary live-update caller reached
  its outer gate.
- `UPDATE_ENTRY` never appears even though a gate appears: the caller did not make
  the `UpdateFeatProgress` call.
- `CALC_RESULT` has `AL=0`: the inner calculation returned false to the update
  routine.
- `RULER_INFO_CHECK` has `RAX=0`: the current-ruler-info pointer is null at the
  downstream check.
- `CALC_FAIL_PATH` or `CALC_RETURN_PATH` appears: the inner predicate took a
  specific return route.
- None of the seven `[MJ]` lines appears: this run did not execute the expected V8
  feat path, so the log must include the hash line and the in-game action details;
  it is not evidence for a V9 patch.

The save/cache files remain untouched. Breakpoints exist only while the debugger is
attached and are not saved into the executable.
