#!/usr/bin/env python3
"""RESTORE fn, UpdateFeatProgress prologue, 0x1400af050 true start, date helper."""
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

    # RESTORE function containing raw 0x7856e1 (call IsActive) / 0x7856e8 (je = RESTORE_GATE bp) / 0x7856f2 (call Update)
    disasm_range(data, 0x7855C0, 0x7857C0, "RESTORE function (bp at raw 0x7856e8)")

    # UpdateFeatProgress prologue
    disasm_range(data, 0x7b8a60, 0x7b8ba0, "UpdateFeatProgress (0x1407b8e60) prologue")

    # true start of 0x1400af050: look before raw 0xea450
    disasm_range(data, 0xEA3E0, 0xEA470, "Before 0x1400af050 (raw 0xea450) - find prologue")

    # date-ish helper
    disasm_range(data, 0xE1CEF0, 0xE1D060, "0x140e1daf8 (raw 0xe1cef8)")

if __name__ == "__main__":
    main()
