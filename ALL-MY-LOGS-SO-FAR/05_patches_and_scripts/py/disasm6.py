#!/usr/bin/env python3
"""Correct UpdateFeatProgress disasm (raw 0x7b8260 = VA 0x1407b8e60)."""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, start_raw, end_raw, label=""):
    print(f"\n===== {label} raw 0x{start_raw:x}..0x{end_raw:x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[start_raw:end_raw], VA_BASE + start_raw):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    # UpdateFeatProgress: VA 0x1407b8e60 -> raw 0x7b8260
    disasm_range(data, 0x7B8260, 0x7B83C0, "UpdateFeatProgress entry (raw 0x7b8260 = VA 0x1407b8e60)")

if __name__ == "__main__":
    main()
