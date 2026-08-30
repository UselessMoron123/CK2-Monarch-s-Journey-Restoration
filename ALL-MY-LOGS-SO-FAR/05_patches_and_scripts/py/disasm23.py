#!/usr/bin/env python3
"""Scan for all RIP-relative references to global byte VA 0x1416e3163
(the 'MJ tracking forced-on' flag read at CalcShouldTrackFeatProgress entry).
Also scan raw 0x7b7854..0x7b7864 to confirm the flow."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00
TARGET = 0x1416e3163

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    hits = []
    n = len(data)
    # scan for any instruction whose RIP-relative target == TARGET
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    md.detail = True
    for insn in md.disasm(data, VA_BASE):
        raw = insn.address - VA_BASE
        for op in insn.operands:
            if op.type == 3 and op.imm == TARGET:  # CS_OP_MEM, mem.disp holds target for rip-relative
                hits.append((raw, insn.mnemonic, insn.op_str))
                break
    print(f"RIP-relative refs to VA 0x{TARGET:016x}:")
    for raw, m, ops in hits:
        print(f"  raw 0x{raw:08x} VA 0x{VA_BASE+raw:016x}: {m}\t{ops}")
    if not hits:
        print("  (none found via linear disasm; trying byte-pattern scan)")
        # fallback: search for 80 3D / C6 05 / 8A 05 / 88 05 / 0F B6 05 with disp32 == TARGET-(next)
        pats = [b'\x80\x3d', b'\xc6\x05', b'\x8a\x05', b'\x88\x05', b'\x0f\xb6\x05', b'\x0f\xb7\x05', b'\x8b\x05', b'\x48\x8b\x05', b'\x48\x8d\x05', b'\x8d\x05']
        for pat in pats:
            i = 0
            while True:
                i = data.find(pat, i)
                if i < 0: break
                if i + 2 + 4 <= n:
                    disp = struct.unpack_from('<i', data, i + 2)[0]
                    next_va = VA_BASE + i + len(pat) + 4
                    if next_va + disp == TARGET:
                        print(f"  raw 0x{i:08x} VA 0x{VA_BASE+i:016x}: prefix {pat.hex()} disp={disp:#x} -> TARGET")
                i += 1
    print()
    # also confirm entry flow
    print("CalcShouldTrackFeatProgress entry:")
    for insn in md.disasm(data[0x7b7850-0x400:0x7b7850-0x400+0x40], 0x1407B8450):
        print(f"  raw 0x{insn.address-VA_BASE:08x} VA 0x{insn.address:016x} {insn.mnemonic}\t{insn.op_str}")

if __name__ == "__main__":
    main()
