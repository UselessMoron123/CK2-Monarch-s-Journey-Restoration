#!/usr/bin/env python3
"""Extract RIP-relative string literals used near the +0x62=1 write."""
import struct

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def read_cstr(data, va):
    raw = va - VA_BASE
    if raw < 0 or raw >= len(data):
        return f"<OOB va=0x{va:x}>"
    end = data.find(b"\x00", raw)
    if end == -1:
        return "<no-nul>"
    b = data[raw:end]
    try:
        return b.decode("utf-8", errors="replace")
    except Exception:
        return repr(b)

def rip_target(data, va_of_lea, insn_len, disp):
    return va_of_lea + insn_len + disp

def main():
    with open(EXE, "rb") as f:
        data = f.read()

    # lea rdx,[rip+0x96c379] at VA 0x140768800 (len 0x18); lea rdx,[rip+0x96c2f5] at VA 0x140768864 (len 0x10)
    for va_lea, disp, ln in [(0x140768800, 0x96c379, 0x18), (0x140768864, 0x96c2f5, 0x10)]:
        tgt = rip_target(data, va_lea, 7, disp)
        s = read_cstr(data, tgt)
        print(f"  lea@{va_lea:#x} -> VA {tgt:#x} (raw 0x{tgt-VA_BASE:x}) len={ln:#x}: {s!r}")

    # also the first lea at 0x140768800's predecessor: lea rdx,[rip+?] at 0x140768800? handled.
    # check for a third string: the [rbx+0x6c10] check path - find lea at 0x1407687c8? no.
    # dump strings around raw 0x7687c0..0x7687d0 region? skip.

if __name__ == "__main__":
    main()
