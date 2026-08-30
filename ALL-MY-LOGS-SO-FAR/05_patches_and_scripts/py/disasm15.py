#!/usr/bin/env python3
"""Find the true start of the +0x62=1 writer function and its callers."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} (raw 0x{r0:x}..0x{r1:x}) =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def find_call_sites(data, target_va, mnem="call"):
    op = 0xE8 if mnem == "call" else 0xE9
    hits = []
    n = len(data)
    for p in range(0, n - 5):
        if data[p] == op:
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == target_va:
                hits.append((p, mnem))
    return hits

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    disasm_range(data, 0x140768900, 0x140768B80, "wider window before writer (look for prologue)")

if __name__ == "__main__":
    main()
