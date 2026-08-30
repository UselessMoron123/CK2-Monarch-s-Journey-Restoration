#!/usr/bin/env python3
"""Disassemble VA ranges computed in code (no manual arithmetic)."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00  # VA = raw + VA_BASE  =>  raw = VA - VA_BASE

def raw(va):
    return va - VA_BASE

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = raw(va_start), raw(va_end)
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} (raw 0x{r0:x}..0x{r1:x}) =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    print(f"[*] raw(0x1400af050) = 0x{raw(0x1400af050):x}")
    print(f"[*] raw(0x1400af690) = 0x{raw(0x1400af690):x}")

    # 0x1400af050: find its start first (look back 0x300 bytes)
    disasm_range(data, 0x1400aED00, 0x1400aF200, "0x1400af050 area incl. prior padding")
    disasm_range(data, 0x1400aF050, 0x1400aF690, "0x1400af050 body -> next fn")

if __name__ == "__main__":
    main()
