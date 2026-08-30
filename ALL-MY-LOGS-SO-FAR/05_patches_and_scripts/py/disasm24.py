#!/usr/bin/env python3
"""Correct RIP-relative reference scan for global byte VA 0x1416e3163."""
import struct

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00
TARGET = 0x1416e3163

def main():
    with open(EXE, "rb") as f:
        data = f.read()
    n = len(data)
    # (pattern, total_len) ; total_len = opcode+modrm+disp32(+imm)
    pats = [
        (b'\x80\x3d', 7),   # cmp byte ptr [rip+disp], imm8
        (b'\xc6\x05', 7),   # mov byte ptr [rip+disp], imm8
        (b'\x8a\x05', 6),   # mov r8, byte ptr [rip+disp]
        (b'\x88\x05', 6),   # mov byte ptr [rip+disp], r8
        (b'\x0f\xb6\x05', 7),  # movzx r32, byte ptr [rip+disp]
        (b'\x0f\xb7\x05', 7),  # movzx r32, word ptr [rip+disp]
        (b'\x8b\x05', 6),   # mov r32, dword ptr [rip+disp]
        (b'\x48\x8b\x05', 7),  # mov r64, qword ptr [rip+disp]
        (b'\x48\x8d\x05', 7),  # lea r64, [rip+disp]
        (b'\x8d\x05', 6),   # lea r32, [rip+disp]
        (b'\x80\x0d', 7),   # or byte ptr [rip+disp], imm8
        (b'\x80\x25', 7),   # and byte ptr [rip+disp], imm8
        (b'\x80\x05', 7),   # add byte ptr [rip+disp], imm8
        (b'\x80\x2d', 7),   # sub byte ptr [rip+disp], imm8
        (b'\x0f\xbe\x05', 7),  # movsx r32, byte ptr [rip+disp]
    ]
    hits = []
    for pat, tot in pats:
        i = 0
        while True:
            i = data.find(pat, i)
            if i < 0:
                break
            if i + tot <= n:
                disp = struct.unpack_from('<i', data, i + len(pat))[0]
                next_va = VA_BASE + i + tot
                if next_va + disp == TARGET:
                    hits.append((i, pat))
            i += 1
    print(f"RIP-relative refs to VA 0x{TARGET:016x} (raw 0x{TARGET - VA_BASE:016x}):")
    for raw, pat in hits:
        print(f"  raw 0x{raw:08x} VA 0x{VA_BASE+raw:016x}  pattern {pat.hex()}")

if __name__ == "__main__":
    main()
