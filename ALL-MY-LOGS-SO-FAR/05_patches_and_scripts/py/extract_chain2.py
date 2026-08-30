#!/usr/bin/env python3
"""Extract (offset, oldbytes, newbytes) for V2, V3, V4, V5 from their ps1 files."""
import re

def parse(path):
    src = open(path, encoding="utf-8-sig").read()
    blocks = re.findall(r"\[pscustomobject\]@\{(.*?)\}", src, re.S)
    out = []
    for b in blocks:
        name = re.search(r"Name\s*=\s*'([^']*)'", b)
        off = re.search(r"Offset\s*=\s*(0x[0-9a-fA-F]+)L", b)
        if not off:
            continue
        def bytesof(field):
            m = re.search(field + r"\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
            if not m:
                return None
            return bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", m.group(1)))
        old = bytesof(r"Original")
        new = bytesof(r"Patched")
        if old is None:
            old = bytesof(r"V[0-9]")
        # fallback: any V<k> = ...
        if new is None:
            # in v4/v5 files fields are named after the target version, e.g. V4/V5
            vs = re.findall(r"(V[0-9])\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
            if vs:
                # last one is usually the target
                new = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", vs[-1][1]))
        out.append((off.group(1), name.group(1) if name else "?", old, new))
    return out

for v in (2, 3, 4, 5):
    print(f"===== V{v} =====")
    for off, name, old, new in parse(f"ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v{v}.ps1"):
        print(f"  0x{off}  {name}")
        print(f"     old: {old.hex(' ') if old else None}")
        print(f"     new: {new.hex(' ') if new else None}")
