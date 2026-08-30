#!/usr/bin/env python3
"""Deep-disassemble CalcShouldTrackFeatProgress + find callers of UpdateFeatProgress."""
import struct
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

EXE = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"
VA_BASE = 0x140000C00

def disasm_range(data, start_raw, end_raw, label=""):
    print(f"\n===== {label} raw 0x{start_raw:x}..0x{end_raw:x} =====")
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    for insn in md.disasm(data[start_raw:end_raw], VA_BASE + start_raw):
        print(f"  raw 0x{insn.address - VA_BASE:08x}  VA 0x{insn.address:016x}  {insn.mnemonic}\t{insn.op_str}")

def find_callers(data, target_va):
    """Scan .text-like region for E8 rel32 calls to target_va and jmp rel32."""
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    start = 0x400
    end = len(data)
    hits = []
    for insn in md.disasm(data[start:end], VA_BASE + start):
        if insn.mnemonic in ("call", "jmp") and insn.op_str.startswith("0x"):
            try:
                dst = int(insn.op_str, 16)
            except ValueError:
                continue
            if dst == target_va:
                hits.append((insn.address - VA_BASE, insn.mnemonic))
    return hits

def main():
    with open(EXE, "rb") as f:
        data = f.read()

    # Full CalcShouldTrackFeatProgress: raw 0x7b7850 .. 0x7b7a60
    disasm_range(data, 0x7b7850, 0x7b7b20, "CalcShouldTrackFeatProgress full")

    # Compute the global flag address for the cmp at raw 0x7b7854
    cmp_va = VA_BASE + 0x7b7854
    disp = struct.unpack_from("<i", data, 0x7b7854 + 3)[0]
    flag_va = cmp_va + 7 + disp
    print(f"\n[+] cmp byte ptr [rip+disp] at raw 0x7b7854 -> global flag VA 0x{flag_va:016x} (raw 0x{flag_va - VA_BASE:08x})")

    # callers of UpdateFeatProgress 0x1407b8e60
    print("\n[+] callers of UpdateFeatProgress (0x1407b8e60):")
    for raw, mnem in find_callers(data, 0x1407b8e60):
        print(f"    {mnem} at raw 0x{raw:08x} (VA 0x{VA_BASE+raw:016x})")

    # callers of IsActiveForPlaythrough 0x1407b8370
    print("\n[+] callers of IsActiveForPlaythrough (0x1407b8370):")
    for raw, mnem in find_callers(data, 0x1407b8370):
        print(f"    {mnem} at raw 0x{raw:08x} (VA 0x{VA_BASE+raw:016x})")

    # region around raw 0x665300: find function start (int3 padding) and full body
    disasm_range(data, 0x665240, 0x665400, "Function containing DAILY_GATE bp (raw 0x665546) - start")

if __name__ == "__main__":
    main()
