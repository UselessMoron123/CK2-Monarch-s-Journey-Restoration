#!/usr/bin/env python3
"""Disassemble the lookup functions used by the eligibility loop 0x14072d540:
   0x14072c6c0 (type lookup) and 0x14072d010 (id lookup).
Raw = VA - 0x140000c00.
"""
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, va_start, va_end, label=""):
    r0, r1 = va_start - VA_BASE, va_end - VA_BASE
    print(f"\n===== {label} VA 0x{va_start:016x}..0x{va_end:016x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[r0:r1], va_start):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    # find prologue start by scanning back for 40 55 / 40 53 / int3 padding
    def find_start(va):
        raw = va - VA_BASE
        i = raw
        # walk back up to 0x100 bytes looking for int3 (cc) padding followed by a prologue
        best = raw
        for j in range(raw - 1, max(0, raw - 0x120), -1):
            if data[j] == 0xCC:
                best = j + 1
                break
        # if next bytes look like a function (48 89 5c 24 / 40 55 / 48 83 ec / 4c 8b dc)
        b = data[best]
        if b in (0x40, 0x48, 0x4C, 0x53, 0x57, 0x56):
            return best
        return raw
    s1 = find_start(0x14072c6c0)
    disasm_range(data, VA_BASE + s1, 0x14072c6c0 + 0x180, f"type lookup 0x14072c6c0 (start guess raw 0x{s1:x})")
    s2 = find_start(0x14072d010)
    disasm_range(data, VA_BASE + s2, 0x14072d010 + 0x180, f"id lookup 0x14072d010 (start guess raw 0x{s2:x})")

if __name__ == "__main__":
    main()
