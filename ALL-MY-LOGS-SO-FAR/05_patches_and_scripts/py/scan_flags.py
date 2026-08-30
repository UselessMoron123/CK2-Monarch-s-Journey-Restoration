#!/usr/bin/env python3
"""Find writes of byte 1 to [reg+0x62], [reg+0x65], [reg+0x64], [reg+0x61] across .text."""
import re

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def scan(data, off):
    """C6 /0 ib  => mov byte ptr [modrm+disp8], imm8 ; C6 40 65 01 etc."""
    hits = []
    for m in re.finditer(rb"\xC6", data):
        p = m.start()
        if p + 4 > len(data):
            continue
        modrm = data[p+1]
        # mod=01 (disp8), reg=000, rm in 0..7
        if (modrm & 0xC7) != 0x40:  # mod=01, reg=000 -> 0x40; rm bits vary
            continue
        disp = data[p+2]
        imm = data[p+3]
        if disp in (0x62, 0x65, 0x64, 0x61, 0x60, 0x63) and imm == 1:
            reg = modrm & 7
            regname = ["rax","rcx","rdx","rbx","rsp","rbp","rsi","rdi"][reg]
            hits.append((p, f"mov byte ptr [{regname}+0x{disp:x}], 1"))
    return hits

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    print(f"size {len(data)}")
    hits = scan(data, 0)
    for p, desc in hits:
        print(f"  raw 0x{p:08x}  VA 0x{VA_BASE+p:016x}  {desc}")
    print(f"total: {len(hits)}")

if __name__ == "__main__":
    main()
