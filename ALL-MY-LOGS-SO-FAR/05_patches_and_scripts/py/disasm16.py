#!/usr/bin/env python3
"""Find callers of the +0x62 writer function (VA 0x140768716) and dump its string keys."""
import struct

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00
TARGET = 0x140768716

def read_cstr(data, va):
    raw = va - VA_BASE
    end = data.find(b"\x00", raw)
    if end == -1:
        return "<no-nul>"
    return data[raw:end].decode("utf-8", errors="replace")

def main():
    with open(EXE, "rb") as f:
        data = f.read()

    print(f"[+] callers of writer function 0x{TARGET:x}:")
    n = len(data)
    for p in range(0, n - 5):
        if data[p] == 0xE8:
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == TARGET:
                print(f"    call at raw 0x{p:08x} (VA 0x{VA_BASE+p:016x})")
    # also indirect? report jmp too
    for p in range(0, n - 5):
        if data[p] == 0xE9:
            disp = struct.unpack_from("<i", data, p + 1)[0]
            if (VA_BASE + p + 5 + disp) == TARGET:
                print(f"    jmp  at raw 0x{p:08x} (VA 0x{VA_BASE+p:016x})")

    # the 20-char key: lea rdx,[rip+0x96c3fd] at VA 0x14076879c, len 7
    tgt = 0x14076879c + 7 + 0x96c3fd
    print(f"\n[+] key string (len 0x14) at VA 0x{tgt:x}: {read_cstr(data, tgt)!r}")
    # also dump the two known ones for completeness
    t1 = 0x140768800 + 7 + 0x96c379
    t2 = 0x140768864 + 7 + 0x96c2f5
    print(f"[+] key (len 0x18) at VA 0x{t1:x}: {read_cstr(data, t1)!r}")
    print(f"[+] key (len 0x10) at VA 0x{t2:x}: {read_cstr(data, t2)!r}")

if __name__ == "__main__":
    main()
