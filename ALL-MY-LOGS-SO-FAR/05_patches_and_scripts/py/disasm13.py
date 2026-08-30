#!/usr/bin/env python3
"""Context around the sole [reg+0x62],1 write (raw 0x767cb3 / VA 0x1407688b3)."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} (raw 0x{r0:x}..0x{r1:x}) =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    # the +0x62=1 write is at raw 0x767cb3; show a wide window around it
    disasm_range(data, 0x1407687A0, 0x140768A80, "writer context (VA 0x1407688b3 = raw 0x767cb3)")

if __name__ == "__main__":
    main()
