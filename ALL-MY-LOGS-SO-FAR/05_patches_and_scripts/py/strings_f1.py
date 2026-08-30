#!/usr/bin/env python3
"""Dump string literals referenced inside F1 (raw 0x665276..0x6665bc)."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def read_cstr(data, va):
    raw = va - VA_BASE
    if raw < 0 or raw >= len(data):
        return None
    end = data.find(b"\x00", raw)
    if end == -1:
        return None
    b = data[raw:end]
    if not b or len(b) > 64:
        return None
    try:
        s = b.decode("utf-8")
        if all(32 <= ord(c) < 127 for c in s):
            return s
    except Exception:
        pass
    return None

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    r0, r1 = 0x665276, 0x6665bc
    seen = set()
    for insn in md.disasm(data[r0:r1], VA_BASE + r0):
        if insn.mnemonic == "lea" and insn.op_str.startswith("rdx, [rip + "):
            try:
                disp = int(insn.op_str.split("0x")[1], 16)
            except Exception:
                continue
            tgt = insn.address + insn.size + disp
            s = read_cstr(data, tgt)
            if s and s not in seen:
                seen.add(s)
                print(f"  VA 0x{insn.address:016x}: {s!r}")

if __name__ == "__main__":
    main()
