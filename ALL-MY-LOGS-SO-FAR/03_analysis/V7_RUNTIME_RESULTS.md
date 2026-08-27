# V7 Runtime Results & Continue Fix Analysis

## 1. Executive Summary

- **Problem (Case C08)**: Clicking "Continue" in the Main Menu or Monarch's Journey interface displayed the `CONTINUE_FAILED_TITLE` / `CONTINUE_FAILED_DESC` popup ("Continue failed / Continuing from the Save Game...").
- **Root Cause**: The Continue execution routine at `0x1409E6700` finds and validates the save (`Bosnia1173_01_02.ck2`), but at `0x1409E6785` it inspects a cloud sync state byte (`movzx ecx, byte ptr [rsi+0x63]`). Because official Paradox servers are offline, `cl == 0`, causing conditional jump `0x1409E678B` (`75 2f`: `jne 0x1409E67BC`) to fail and invoke the `CContinueFailedPopup` dialog constructor at `0x140726560`.
- **Solution (V7 Patch)**: Change the conditional jump at `0x1409E678B` (file offset `0x009E5B8B`) from `75 2f` (`jne`) to `eb 2f` (`jmp`).
- **Live Verification**: With the jump taken, `CK2game.exe` immediately invoked `0x1409E67E0`, deserialized `Bosnia1173_01_02.ck2`, initialized the game world, created titles, attached human control to Kulin of Bosnia (`218800`), and loaded the map with zero errors.

---

## 2. Dynamic Disassembly Breakdown (`0x1409E6700`)

```assembly
00000001409E6700:
   1409e6700:   rex push rdi
   1409e6702:   sub    rsp, 0x30
   1409e6706:   mov    QWORD PTR [rsp+0x20], -2
   1409e670f:   mov    QWORD PTR [rsp+0x48], rbx
   1409e6714:   mov    QWORD PTR [rsp+0x50], rsi
   1409e6719:   mov    rbx, rdx            ; RDX = candidate save filename ("Bosnia1173_01_02.ck2")
   1409e671c:   mov    rdi, rcx            ; RCX = this (Ironman / Save controller)
   1409e671f:   call   0x1409e5500        ; save-list enumeration
   1409e6724:   call   0x1400af050        ; context provider -> RSI
   1409e6729:   mov    rsi, rax
   1409e672c:   lea    rdx, [rdi+0x368]    ; expected save name in structure
   1409e6733:   mov    rcx, rbx            ; candidate save name
   1409e6736:   call   0x1400b03a0        ; std::string::compare / strcmp
   1409e673b:   test   eax, eax
   1409e673d:   sete   cl                 ; CL = 1 if filenames match
   1409e6740:   test   eax, eax
   1409e6742:   jne    0x1409e6789        ; if not matched -> jump to fail check
   1409e6744:   cmp    BYTE PTR [rdi+0x3b0], al
   1409e674a:   je     0x1409e6789
   1409e674c:   mov    rcx, QWORD PTR [rdi+0x340]
   1409e6753:   mov    rax, QWORD PTR [rcx+0x368]
   1409e675a:   cmp    BYTE PTR [rax+0x80], 0x0
   ...
   1409e6785:   movzx  ecx, BYTE PTR [rsi+0x63] ; Cloud sync status
   1409e6789:   test   cl, cl
   1409e678b:   jne    0x1409e67bc        ; [PATCHED IN V7: 75 2F -> EB 2F]
   ; --- Failure branch (CContinueFailedPopup) ---
   1409e678d:   mov    rbx, QWORD PTR [rdi+0x340]
   1409e6794:   mov    ecx, 0x148
   1409e6799:   call   0x140e204c0        ; operator new(0x148)
   1409e679e:   mov    QWORD PTR [rsp+0x40], rax
   1409e67a3:   mov    rdx, rbx
   1409e67a6:   mov    rcx, rax
   1409e67a9:   call   0x140726560        ; CContinueFailedPopup constructor
   1409e67ae:   nop
   1409e67af:   mov    rdx, rax
   1409e67b2:   mov    rcx, rbx
   1409e67b5:   call   0x14063b8e0        ; Show dialog popup
   1409e67ba:   jmp    0x1409e67c4
   ; --- Success branch (Load Save) ---
   1409e67bc:   mov    rcx, rdi
   1409e67bf:   call   0x1409e67e0        ; Execute actual game load
   1409e67c4:   mov    rbx, QWORD PTR [rsp+0x48]
   1409e67c9:   mov    rsi, QWORD PTR [rsp+0x50]
   1409e67ce:   add    rsp, 0x30
   1409e67d2:   pop    rdi
   1409e67d3:   ret
```

---

## 3. Live Debugger Trace & Verification Log

```text
Application debug[gamestatecommands.cpp:149]: Added player 'MrHuman' (1)
Application debug[gamestate.cpp:4653]: Adding human: MrHuman
Application debug[gamestate.cpp:4654]: CALL_STACK
Application debug[title.cpp:11945]: Creating title b_dyn_2603643 based on --- on date 1173.1.2
Application debug[title.cpp:11945]: Creating title b_dyn_2603644 based on --- on date 1173.1.2
Application debug[title.cpp:11945]: Creating title b_dyn_2603645 based on --- on date 1173.1.2
Application debug[title.cpp:11945]: Creating title b_dyn_2603646 based on --- on date 1173.1.2
Application debug[controlcommands.cpp:45]: Changing control state of MrHuman(1)
Application debug[controlcommands.cpp:59]: Human MrHuman set as primary local
Application debug[gamestate.cpp:4288]: Setting character 'Kulin of d_bosnia(218800)' as human
Application debug[controlcommands.cpp:136]: Local player will control 218800
```

---

## 4. Hash Verification & Artifact Summary

| Artifact | SHA-256 | Notes |
|---|---|---|
| Stock May 2020 Win 3.3.3 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | Original baseline |
| V5 Baseline | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` | Offline challenge tracking + manual load |
| V6 Baseline | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | Save-list filtering |
| **V7 Executable** | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` | **Fully working Continue button** |
