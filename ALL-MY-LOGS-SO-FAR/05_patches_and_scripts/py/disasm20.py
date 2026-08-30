#!/usr/bin/env python3
"""Exact bytes: CalcShouldTrackFeatProgress entry (raw 0x7b7850) and the
eligibility loop 0x14072d540 (raw 0x72c940)."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def dump(data, va_start, va_end, label):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        raw = insn.address - VA_BASE
        print(f"  raw 0x{raw:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    dump(data, 0x1407B8450, 0x1407B8460, "CalcShouldTrackFeatProgress entry (first bytes)")
    dump(data, 0x14072D540, 0x14072D640, "eligibility loop 0x14072d540 (full)")

if __name__ == "__main__":
    main()
