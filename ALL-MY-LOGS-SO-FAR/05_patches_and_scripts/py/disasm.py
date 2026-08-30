#!/usr/bin/env python3
"""Disassemble regions of the stock CK2 3.3.3 Windows exe at raw offsets.

Raw offset -> VA mapping for this PE: VA = raw + 0x140000c00
(image base 0x140000000, .text raw 0x400 -> RVA 0x1000, so raw 0x400 == VA 0x140001000).
"""
import sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00  # VA = raw + this

def disasm_region(data, start_raw, end_raw, label=""):
    print(f"\n===== {label} raw 0x{start_raw:x}..0x{end_raw:x} =====")
    code = data[start_raw:end_raw]
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = False
    for insn in md.disasm(code, VA_BASE + start_raw):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    print(f"size: {len(data)}")
    # regions of interest
    disasm_region(data, 0x665300, 0x665600, "DailyUpdate region A (call site near raw 0x66553f?)")
    disasm_region(data, 0x666500, 0x666800, "DailyUpdate region B (patched gate raw 0x666546)")
    disasm_region(data, 0x7b7850, 0x7b7a60, "CalcShouldTrackFeatProgress (raw 0x7b7850-...)")
    disasm_region(data, 0x7b8a60, 0x7b8b20, "UpdateFeatProgress entry (raw 0x7b8a60+)")
    disasm_region(data, 0x9e5b00, 0x9e5d00, "Continue execution V7 patch raw 0x9e5b8b")

if __name__ == "__main__":
    main()
