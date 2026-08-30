#!/usr/bin/env python3
"""Check continuity of F1 between DAILY_GATE bp (raw 0x665546) and gate (raw 0x66653f)."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    # look for ret / int3 between raw 0x665600 and 0x666500
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    print("Instructions raw 0x665600..0x666540 (looking for ret/epilogue/int3):")
    r0, r1 = 0x665600, 0x666540
    for insn in md.disasm(data[r0:r1], VA_BASE + r0):
        m = insn.mnemonic
        if m in ("ret", "retn", "int3", "jmp", "push", "call") or "140667" in insn.op_str or insn.address - VA_BASE >= 0x666500:
            print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {m}\t{insn.op_str}")

if __name__ == "__main__":
    main()
