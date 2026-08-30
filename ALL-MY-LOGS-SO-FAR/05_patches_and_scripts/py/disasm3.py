#!/usr/bin/env python3
"""Byte-pattern xref scan + disassemble the final gate functions."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def find_rel_call_sites(data, target_va, mnem="call"):
    """Find positions p where bytes are: <mnem opcode> rel32 and p+len+rel == target_va."""
    op = 0xE8 if mnem == "call" else 0xE9  # E8 = call rel32, E9 = jmp rel32
    hits = []
    n = len(data)
    for p in range(0, n - 5):
        if data[p] == op:
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == target_va:
                hits.append((p, mnem, disp))
    return hits

def disasm_range(data, start_raw, end_raw, label=""):
    print(f"\n===== {label} raw 0x{start_raw:x}..0x{end_raw:x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[start_raw:end_raw], VA_BASE + start_raw):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()

    targets = {
        0x1407b8e60: "UpdateFeatProgress",
        0x1407b8370: "IsActiveForPlaythrough",
        0x1400af690: "final-achievement-helper",
        0x1400af050: "singleton-getter",
    }
    for target, name in targets.items():
        print(f"\n[+] callers of {name} (0x{target:016x}):")
        for p, m, d in find_rel_call_sites(data, target):
            print(f"    call at raw 0x{p:08x} (VA 0x{VA_BASE+p:016x})  disp={d:#x}")

    # The final gate function
    disasm_range(data, 0xEA050, 0xEA1A0, "0x1400af050 singleton getter / achievement-ish object")
    disasm_range(data, 0xEA690, 0xEA900, "0x1400af690 final gate (achievement eligibility helper)")
    disasm_range(data, 0xE1CEF0, 0xE1D050, "0x140e1daf8 (date-ish helper used in CalcShouldTrack)")

if __name__ == "__main__":
    main()
