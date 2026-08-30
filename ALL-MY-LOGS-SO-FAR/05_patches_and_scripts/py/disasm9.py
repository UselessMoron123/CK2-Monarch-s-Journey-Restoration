#!/usr/bin/env python3
"""Real 0x1400af690 body + rest of 0x1400af0c0."""
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
    disasm_range(data, 0x1400af690, 0x1400afA60, "0x1400af690 (raw 0xaea90) FULL BODY")
    disasm_range(data, 0x1400af2c4, 0x1400af430, "tail of 0x1400af0c0 fn (bail path)")

if __name__ == "__main__":
    main()
