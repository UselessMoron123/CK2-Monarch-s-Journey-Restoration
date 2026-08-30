#!/usr/bin/env python3
"""Extract (Offset, oldBytes, newBytes) triples from patch_ck2_mj_v*.ps1 files."""
import re, sys

def parse_ps1(path):
    src = open(path, encoding="utf-8-sig").read()
    # find all pscustomobject blocks
    blocks = re.findall(r"\[pscustomobject\]@\{(.*?)\}", src, re.S)
    out = []
    for b in blocks:
        name = re.search(r"Name\s*=\s*'([^']*)'", b)
        off = re.search(r"Offset\s*=\s*(0x[0-9a-fA-F]+)L", b)
        # pairs: V5 = [byte[]](0x..,0x..)  -> capture all assignments
        assigns = dict(re.findall(r"(V[0-9])\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S))
        if not (off and assigns):
            continue
        def tobytes(s):
            return bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", s))
        entry = {"name": name.group(1) if name else "?", "offset": int(off.group(1), 16)}
        for k, v in assigns.items():
            entry[k] = tobytes(v)
        out.append(entry)
    return out

for v in (2, 3, 4, 5):
    print(f"===== V{v} =====")
    for e in parse_ps1(f"ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v{v}.ps1"):
        print(f"  0x{e['offset']:08x}  {e['name']}")
        for k in sorted(e):
            if k not in ("name", "offset"):
                print(f"     {k}: {e[k].hex(' ')}")
