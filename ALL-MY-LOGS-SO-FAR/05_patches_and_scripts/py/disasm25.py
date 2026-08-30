#!/usr/bin/env python3
"""Context around the three reads of the global MJ flag VA 0x1416e3163."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    disasm_range(data, 0x1406670F0, 0x1406671A0, "daily fn flag read (raw 0x666536)")
    disasm_range(data, 0x1407862A0, 0x140786320, "RESTORE fn flag read (raw 0x7856d8)")
    disasm_range(data, 0x1407B8450, 0x1407B8520, "CalcShouldTrack flag read (raw 0x7b7854)")

if __name__ == "__main__":
    main()
