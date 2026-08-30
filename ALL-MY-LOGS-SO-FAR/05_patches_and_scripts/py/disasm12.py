#!/usr/bin/env python3
"""Continuous disasm from raw 0x665276 to 0x666600; print control-flow + notable lines."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    r0, r1 = 0x665276, 0x666600
    interesting = ("ret", "int3", "jmp", "je", "jne", "call", "lea rdx, [rip", "cmp byte ptr [rip")
    for insn in md.disasm(data[r0:r1], VA_BASE + r0):
        m, o = insn.mnemonic, insn.op_str
        show = False
        if m in ("ret", "int3"):
            show = True
        elif m in ("jmp", "je", "jne", "call"):
            show = True
        elif m in ("mov", "cmp", "lea") and "rip" in o and ("0x140667" in o or "0x14065" in o):
            show = True
        if show:
            print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {m}\t{o}")

if __name__ == "__main__":
    main()
