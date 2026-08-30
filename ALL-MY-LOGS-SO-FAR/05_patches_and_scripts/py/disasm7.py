#!/usr/bin/env python3
"""Correct disassembly of 0x1400af050 (raw 0xa4450) and 0x1400af690 (raw 0xa6690)."""
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

    # Find the start of 0x1400af050: look before raw 0xa4450
    disasm_range(data, 0xA4300, 0xA4520, "Before 0x1400af050 (raw 0xa4450)")
    disasm_range(data, 0xA4450, 0xA4A00, "0x1400af050 (raw 0xa4450) body")

    # 0x1400af690 -> raw 0xa6690
    disasm_range(data, 0xA6550, 0xA66A0, "Before 0x1400af690 (raw 0xa6690)")
    disasm_range(data, 0xA6690, 0xA6B00, "0x1400af690 (raw 0xa6690) body")

if __name__ == "__main__":
    main()
