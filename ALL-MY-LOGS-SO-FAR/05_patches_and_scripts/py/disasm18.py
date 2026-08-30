#!/usr/bin/env python3
"""Find callers of the activation function 0x14080f370 and inspect caller context."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def find_call_sites(data, target_va):
    hits = []
    n = len(data)
    for p in range(0, n - 5):
        if data[p] == 0xE8:
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == target_va:
                hits.append(p)
        if data[p] == 0xE9:
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
    print("[+] callers of activation fn 0x14080f370:")
    for p in find_call_sites(data, 0x14080f370):
        print(f"    at raw 0x{p:08x} (VA 0x{VA_BASE+p:016x})")
    # also, who reads/writes [gameState-ish +0x28]+0x18? skip; instead dump the caller context for the first hit
    hits = find_call_sites(data, 0x14080f370)
    if hits:
        p = hits[0]
        disasm_range(data, VA_BASE + p - 0x40, VA_BASE + p + 0x30, "caller context")

if __name__ == "__main__":
    main()
