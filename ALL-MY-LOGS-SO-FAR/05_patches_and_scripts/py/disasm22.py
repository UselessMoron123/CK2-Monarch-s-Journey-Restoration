#!/usr/bin/env python3
"""Correct sibling disasm (VA 0x1400af0c0), callers of CalcShouldTrack 0x1407b8450,
and resolve the [rip+0xf2ad08] flag target."""
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
    print("[+] callers of CalcShouldTrackFeatProgress 0x1407b8450:")
    for p in find_call_sites(data, 0x1407b8450):
        print(f"    raw 0x{p:08x} VA 0x{VA_BASE+p:016x}")
    print("[+] callers of gate 0x1400af690 (recheck):")
    for p in find_call_sites(data, 0x1400af690):
        print(f"    raw 0x{p:08x} VA 0x{VA_BASE+p:016x}")
    # resolve flag target: cmp byte [rip+0xf2ad08] at VA 0x1407b8454 (7-byte insn)
    insn_va = 0x1407B8454
    print(f"[+] flag target = 0x{insn_va + 7 + 0xf2ad08:016x}")
    # sibling body: VA 0x1400af0c0 (raw 0xae4c0)
    disasm_range(data, 0x1400AF0C0, 0x1400AF260, "sibling 0x1400af0c0 head")

if __name__ == "__main__":
    main()
