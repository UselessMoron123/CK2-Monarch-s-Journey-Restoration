#!/usr/bin/env python3
"""Inspect sibling 0x1400af0c0 body + callers; callers of 0x14072d540; gate details."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def find_call_sites(data, target_va):
    hits = []
    n = len(data)
    for p in range(0, n - 5):
        if data[p] in (0xE8, 0xE9):
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == target_va:
                hits.append(p)
    return hits

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    print("[+] callers of eligibility loop 0x14072d540:")
    for p in find_call_sites(data, 0x14072d540):
        print(f"    raw 0x{p:08x} VA 0x{VA_BASE+p:016x}")
    print("[+] callers of sibling 0x1400af0c0:")
    for p in find_call_sites(data, 0x1400af0c0):
        print(f"    raw 0x{p:08x} VA 0x{VA_BASE+p:016x}")
    disasm_range(data, 0x1400AE4C0, 0x1400AE700, "sibling 0x1400af0c0 head through gate call")

if __name__ == "__main__":
    main()
