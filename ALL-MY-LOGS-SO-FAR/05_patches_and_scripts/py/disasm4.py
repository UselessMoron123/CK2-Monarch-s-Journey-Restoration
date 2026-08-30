#!/usr/bin/env python3
"""Correct-range disassembly: final gate 0x1400af690, singleton 0x1400af050, restore fn."""
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

    # 0x1400af050 -> raw 0xea450 ; 0x1400af690 -> raw 0xea390
    disasm_range(data, 0xEA450, 0xEAA00, "0x1400af050 singleton getter (raw 0xea450)")
    disasm_range(data, 0xEA390, 0xEA630, "0x1400af690 final gate (raw 0xea390)")

    # RESTORE function: bp RESTORE_GATE at raw 0x7856e8; UpdateFeatProgress call at raw 0x7856f2
    disasm_range(data, 0x7855C0, 0x7857C0, "RESTORE function (raw 0x7856e8 bp; calls IsActive@0x7856e1, Update@0x7856f2)")

    # DailyUpdate gate function F1 start: find its beginning. region A start ~ raw 0x665276
    disasm_range(data, 0x665260, 0x665340, "F1 possible start (raw 0x665276+)")

if __name__ == "__main__":
    main()
