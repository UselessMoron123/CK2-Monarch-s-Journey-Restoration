# RESEARCH ARCHIVE — CK2 Monarch's Journey — Part 4 (Dynamic x64dbg Tracing, the V7 Continue Breakthrough, and Launcher vs. Frontend Architecture)

**Part 4 of the research · sources: Live dynamic debugging session, x64dbg traces, register/stack memory dumps, engine log stream (`gamestatecommands.cpp`), and binary disassembly of `CK2game333.exe` · continues Parts 1, 2, and 3.**

---

# A. ORIENTATION & CURRENT STATE

## A1. Goal

Restore the retired **Monarch's Journey** mode of Crusader Kings II for personal, fully offline Windows use.
Prior to this session (Parts 1–3), V6 (`f5b7dfd6…`) successfully restored the core Monarch's Journey loop, payload decoding, offline Bronzeman campaign starts, live feat evaluation, tier reward granting (Bronze tier popup), save file writing, and manual save loading via Single Player $\rightarrow$ Load Game.
However, **Case C08 remained open**: the in-game "Continue" buttons (Main Menu, MJ Panel) failed with the `CONTINUE_FAILED_TITLE` / `CONTINUE_FAILED_DESC` popup ("Continue failed / Continuing from the Save Game…"), while the external Paradox Launcher Continue button remained greyed out.

## A2. Status Dashboard at the End of This Arc

| Area | State | Notes |
|---|---|---|
| Monarch's Journey panel & 11 payload rulers | ✅ Works | Decodes from local `gfx\monarchs` |
| Bronzeman start & live challenge tracking | ✅ Works | Tracks events in memory; verified on Kulin & Pavao |
| Feat global persistence across save/load | ✅ Works | Deserializes `global_*` values from `.ck2` saves |
| Local persistent peak cache (`cache/q847rsja8ndx`) | ✅ Works | Retains highest earned tiers across boots |
| Bronze rank milestone popup | ✅ Works | Proven in `game.log` at exact threshold |
| Manual load of Bronzeman/MJ saves | ✅ Works | Single Player $\rightarrow$ Load Game loads campaign |
| **In-game Continue button (Main Menu & MJ Panel)** | ✅ **SOLVED (V7)** | **Bypassed cloud-sync gate at `0x1409E678B` (`0x009E5B8B`)** |
| **External Paradox Launcher Continue button** | ⚠️ **Separate subsystem** | Launcher UI (`pdx_launcher.lib`) is independent of engine Continue; stays grey unless launcher database/JSON is populated |
| Secondary cosmetic quirks (multiplayer grey-map, hover flicker) | 🟡 Secondary | Non-blocking cosmetic flow items |

---

# B. STORY & EVOLUTION OF THE MENTAL MODEL

## B1. Timeline of Events

1. **Initial Debugger Attach & Exception Handling**:
   - Launching `CK2game.exe` directly inside `x64dbg` (`File -> Open`) resulted in abrupt termination with exception code `0x406D1388`.
   - Dynamic tracing identified this as the Microsoft Visual Studio `SetThreadName` exception, thrown intentionally by the Clauswitz engine to label threads (`Task#0`, `SDLAudioDev1`, etc.).
   - Attaching `x64dbg` to an already-running process at the Main Menu bypassed engine init exceptions cleanly.

2. **Display Freeze & Direct3D 9 Mode Discovery**:
   - When hitting breakpoints in Fullscreen mode, Direct3D 9 exclusive lock prevented Windows desktop switching, causing perceived machine freeze.
   - Setting `settings.txt` to `fullScreen=no` / `borderless=yes` enabled seamless `Alt+Tab` interaction during breakpoint suspension.

3. **Tracing Continue Helpers**:
   - Breakpoints placed on candidate selector `0x1409E4970` and save enumerator `0x1409E5500`.
   - Both functions hit repeatedly during Main Menu initialization and Continue interactions.
   - Live stack dump revealed active Monarch's Journey feat progress strings: `"Heretical Courtiers: 1/6"`, confirming challenge tracking logic active in memory.
   - Register inspection proved `0x1409E4970` successfully returned string buffers containing candidate save names (`Bosnia1173_01_02.ck2`).

4. **Isolating the Continue Failed Popup**:
   - String references for `CONTINUE_FAILED_TITLE` and `CONTINUE_FAILED_DESC` tracked to constructor `0x140726560` (`CContinueFailedPopup`).
   - Cross-referencing callers revealed `0x140726560` is invoked exclusively by `0x1409E6700` at `0x1409E67A9`.

5. **Pinpointing the Root Cause**:
   - Analysis of `0x1409E6700`:
     1. Calls save refresh `0x1409E5500`.
     2. Matches candidate filename against cached save name via `0x1400B03A0` (`strcmp`). Filenames match (`EAX == 0`, `sete cl` $\rightarrow$ `CL = 1`).
     3. Checks `[rdi+0x3b0]` (cloud/autosave marker). If set, inspects context byte `[rsi+0x63]` (cloud sync state).
     4. Because servers are offline, `[rsi+0x63] == 0`, clearing `CL`.
     5. Instruction `0x1409E6789`: `test cl, cl; jne 0x1409E67BC`.
     6. Because `CL == 0`, `jne` fails, dropping into `0x140726560` to construct and display the error popup!

6. **Live Debugger Proof**:
   - At breakpoint `0x1409E678B`, setting `ZF = 0` forced the jump to `0x1409E67BC`.
   - The engine bypassed the error popup and immediately invoked `0x1409E67E0` (Game Load).
   - Real-time engine log verified immediate campaign load:
     ```text
     Application debug[gamestatecommands.cpp:149]: Added player 'MrHuman' (1)
     Application debug[gamestate.cpp:4653]: Adding human: MrHuman
     Application debug[gamestate.cpp:4288]: Setting character 'Kulin of d_bosnia(218800)' as human
     Application debug[controlcommands.cpp:136]: Local player will control 218800
     ```

7. **V7 Patch Release**:
   - Patch `0x009E5B8B`: `75 2F` (`jne`) $\rightarrow$ `EB 2F` (`jmp`).
   - Hash of verified V7 executable: `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`.

---

## B2. Evolution of the Mental Model

| Prior Theory | What the Data Showed | New Understanding |
|---|---|---|
| Continue button is grey because save scanning (`0x1409E5500`) fails or candidate selection (`0x1409E4970`) rejects the save. | Register dumps confirmed `0x1409E5500` and `0x1409E4970` execute cleanly, select `Bosnia1173_01_02.ck2`, and pass it to the frontend. | Save enumeration and candidate resolution were already functional in V6; the blockage was on the *execution/dispatch* path. |
| The "Continue failed" popup is caused by incompatible DLC, mod checksum mismatch, or corrupt save headers. | Disassembly revealed `0x140726560` is triggered directly by a single offline cloud sync flag (`[rsi+0x63] == 0`) inside `0x1409E6700`. | The popup error text is a generic fallback dialog; the save file is completely valid and parses without errors. |
| In-game Continue and Paradox Launcher Continue share the same code path. | In-game Continue is handled by Clausewitz engine code (`0x1409E6700`), whereas the launcher uses `pdx_launcher.lib` and reads local launcher SQLite/JSON state. | Fixing in-game Continue restores all frontend, MJ panel, and Single Player Continue buttons. The launcher Continue button is an external frontend concern. |

---

# C. KNOWLEDGE BASE & TECHNICAL SPECIFICATIONS

## C1. Full Disassembly of `0x1409E6700` (Continue Dispatch Routine)

```assembly
00000001409E6700:
   1409e6700:   rex push rdi
   1409e6702:   sub    rsp, 0x30
   1409e6706:   mov    QWORD PTR [rsp+0x20], -2
   1409e670f:   mov    QWORD PTR [rsp+0x48], rbx
   1409e6714:   mov    QWORD PTR [rsp+0x50], rsi
   1409e6719:   mov    rbx, rdx            ; RDX = candidate filename ("Bosnia1173_01_02.ck2")
   1409e671c:   mov    rdi, rcx            ; RCX = this
   1409e671f:   call   0x1409e5500        ; Refresh / enumerate save list
   1409e6724:   call   0x1400af050        ; Context retrieval -> RSI
   1409e6729:   mov    rsi, rax
   1409e672c:   lea    rdx, [rdi+0x368]    ; Structure's cached save name
   1409e6733:   mov    rcx, rbx            ; Candidate save name
   1409e6736:   call   0x1400b03a0        ; std::string::compare
   1409e673b:   test   eax, eax
   1409e673d:   sete   cl                 ; CL = 1 if match
   1409e6740:   test   eax, eax
   1409e6742:   jne    0x1409e6789        ; Jump if mismatch
   1409e6744:   cmp    BYTE PTR [rdi+0x3b0], al
   1409e674a:   je     0x1409e6789
   1409e674c:   mov    rcx, QWORD PTR [rdi+0x340]
   1409e6753:   mov    rax, QWORD PTR [rcx+0x368]
   1409e675a:   cmp    BYTE PTR [rax+0x80], 0x0
   1409e6761:   jne    0x1409e6785
   1409e6763:   mov    ecx, 0xa
   1409e6768:   call   Sleep              ; Spinwait for async state
   1409e676e:   mov    rax, QWORD PTR [rdi+0x340]
   1409e6775:   mov    rcx, QWORD PTR [rax+0x368]
   1409e677c:   cmp    BYTE PTR [rcx+0x80], 0x0
   1409e6783:   je     0x1409e6763
   1409e6785:   movzx  ecx, BYTE PTR [rsi+0x63] ; Cloud sync flag (0 offline)
   1409e6789:   test   cl, cl
   1409e678b:   jne    0x1409e67bc        ; [V7 PATCH: 75 2F -> EB 2F]
   ; --- Failure branch: constructs CContinueFailedPopup ---
   1409e678d:   mov    rbx, QWORD PTR [rdi+0x340]
   1409e6794:   mov    ecx, 0x148
   1409e6799:   call   operator new(0x148)
   1409e679e:   mov    QWORD PTR [rsp+0x40], rax
   1409e67a3:   mov    rdx, rbx
   1409e67a6:   mov    rcx, rax
   1409e67a9:   call   0x140726560        ; CContinueFailedPopup constructor
   1409e67ae:   nop
   1409e67af:   mov    rdx, rax
   1409e67b2:   mov    rcx, rbx
   1409e67b5:   call   0x14063b8e0        ; Display popup dialog
   1409e67ba:   jmp    0x1409e67c4
   ; --- Success branch: Load Save ---
   1409e67bc:   mov    rcx, rdi
   1409e67bf:   call   0x1409e67e0        ; Perform Game Load
   1409e67c4:   mov    rbx, QWORD PTR [rsp+0x48]
   1409e67c9:   mov    rsi, QWORD PTR [rsp+0x50]
   1409e67ce:   add    rsp, 0x30
   1409e67d2:   pop    rdi
   1409e67d3:   ret
```

## C2. Complete Lineage & Executable Hashes

| Version | Description | Target / Difference | SHA-256 |
|---|---|---|---|
| **Original** | May 2020 Win 3.3.3 | Unmodified stock executable | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` |
| **V5** | Offline Core Patch | 15 branch/pointer patches (payload decode, feat tracking, offline load) | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| **V6** | Save Selection Patch | 5 narrow save-list branch patches on top of V5 | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` |
| **V7** | **Continue Fix Patch** | **1 byte patch on top of V6 (`0x009E5B8B`: `75 2f` $\rightarrow$ `eb 2f`)** | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` |

---

# D. ATTEMPTS & DEAD ENDS

## D1. Direct x64dbg Execution (`File -> Open`)
- **Attempt**: Opening `CK2game.exe` directly in `x64dbg` before engine initialization.
- **Failure**: Engine thread naming throws `0x406D1388` exceptions (`Task#0`, `SDLAudioDev1`), causing process abort.
- **Resolution**: Launch `CK2game.exe` normally, then attach `x64dbg` via `File -> Attach`.

## D2. Direct3D 9 Fullscreen Deadlock During Debugger Break
- **Attempt**: Stepping through breakpoints while game is running in exclusive fullscreen.
- **Failure**: Direct3D 9 retains exclusive hardware display context; Windows cannot bring debugger to foreground.
- **Resolution**: Set `fullScreen=no` and `borderless=yes` in `Documents\Paradox Interactive\Crusader Kings II\settings.txt`.

---

# E. ARCHITECTURAL NOTE: LAUNCHER VS. IN-GAME CONTINUE

- **In-Game Continue (Main Menu / MJ Panel / Single Player)**:
  - Completely resolved by the V7 patch.
  - Interacts directly with Clausewitz engine memory, save directory enumeration, and deserialization routines.
- **Paradox Launcher Continue Button**:
  - Managed by the external Electron/Chromium launcher (`pdx_launcher.lib`).
  - Reads a separate local SQLite database / JSON metadata file (`launcher-v2.sqlite`) to track the last-played save.
  - Remains greyed out if the launcher database has no record of the save, but this does not affect the game itself in any way when launched directly.

---

# F. SUMMARY OF MILESTONES DELIVERED

1. **Case C08 Formally Resolved**: In-game Continue is fully operational offline without error popups.
2. **Deterministic V7 Patch Script Created**: `patch_ck2_mj_v7.ps1` and `APPLY_CK2_MJ_V7.bat` verify prerequisites, back up the previous build, and validate the exact SHA-256 hash.
3. **Full Knowledge Base Updated**: `CASES_AND_FINDINGS.md`, `STATUS.md`, and research archives reflect verified live findings.
