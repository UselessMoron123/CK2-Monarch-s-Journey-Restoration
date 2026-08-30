#!/usr/bin/env python3
"""Replay the exact V2->V3->V4->V5->V6->V7->V8->V9 chain from stock,
asserting the documented SHA at each step, and print the V9 hash."""
import hashlib
import re

STOCK = "ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe"

SHA = {
    2: '1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175',
    3: 'e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca',
    4: 'f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30',
    5: '29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535',
    6: 'f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0',
    7: '57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571',
    8: '94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93',
}

def sha(b):
    return hashlib.sha256(b).hexdigest()

def apply_patches(data, patches):
    for off, old, new in patches:
        assert data[off:off+len(old)] == old, f"pre-check fail at {off:#x}: got {data[off:off+len(old)].hex()} want {old.hex()}"
        data = data[:off] + new + data[off+len(old):]
    return data

def blocks(src):
    return re.findall(r"\[pscustomobject\]@\s*\{(.*?)\}", src, re.S)

def parse_v2v3(path):
    src = open(path, encoding="utf-8-sig").read()
    out = []
    for b in blocks(src):
        m_off = re.search(r"Offset\s*=\s*(0x[0-9a-fA-F]+)L", b)
        if not m_off:
            continue
        off = int(m_off.group(1), 16)
        m_old = re.search(r"Original\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
        m_new = re.search(r"Patched\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
        if not m_old or not m_new:
            continue
        old = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", m_old.group(1)))
        new = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", m_new.group(1)))
        out.append((off, old, new))
    return out

def parse_vN(path, field):
    src = open(path, encoding="utf-8-sig").read()
    out = []
    for b in blocks(src):
        m_off = re.search(r"Offset\s*=\s*(0x[0-9a-fA-F]+)L", b)
        if not m_off:
            continue
        off = int(m_off.group(1), 16)
        m_new = re.search(field + r"\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
        if not m_new:
            continue
        new = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", m_new.group(1)))
        out.append((off, None, new))
    return out

def parse_v8():
    src = open("ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v8.ps1", encoding="utf-8-sig").read()
    v6, v7, v8 = [], [], []
    for b in blocks(src):
        m_off = re.search(r"Offset\s*=\s*(0x[0-9a-fA-F]+)L", b)
        if not m_off:
            continue
        off = int(m_off.group(1), 16)
        def field(name):
            m = re.search(name + r"\s*=\s*\[byte\[\]\]\((.*?)\)", b, re.S)
            return bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})", m.group(1))) if m else None
        v5b, v6b, v7b, v8b = field("V5"), field("V6"), field("V7"), field("V8")
        if v5b is not None and v6b is not None:
            v6.append((off, v5b, v6b))
        if v6b is not None and v7b is not None:
            v7.append((off, v6b, v7b))
        if v7b is not None and v8b is not None:
            v8.append((off, v7b, v8b))
    return v6, v7, v8

def main():
    data = open(STOCK, "rb").read()
    print(f"stock      {sha(data)}")

    p = parse_v2v3("ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v2.ps1")
    data = apply_patches(data, p)
    assert sha(data) == SHA[2], "V2 hash mismatch"
    print(f"v2         {sha(data)}")

    p3all = parse_v2v3("ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v3.ps1")
    v2_offs = {o for o, _, _ in p}
    p3 = [(o, old, new) for (o, old, new) in p3all if o not in v2_offs]
    data = apply_patches(data, p3)
    assert sha(data) == SHA[3], "V3 hash mismatch"
    print(f"v3         {sha(data)}")

    p4 = parse_vN("ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v4.ps1", "V4")
    pats4 = [(off, data[off:off+len(new)], new) for off, _, new in p4]
    data = apply_patches(data, pats4)
    assert sha(data) == SHA[4], "V4 hash mismatch"
    print(f"v4         {sha(data)}")

    p5 = parse_vN("ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/patch_ck2_mj_v5.ps1", "V5")
    pats5 = [(off, data[off:off+len(new)], new) for off, _, new in p5]
    data = apply_patches(data, pats5)
    assert sha(data) == SHA[5], "V5 hash mismatch"
    print(f"v5         {sha(data)}")

    v6p, v7p, v8p = parse_v8()
    data = apply_patches(data, v6p)
    assert sha(data) == SHA[6], "V6 hash mismatch"
    print(f"v6         {sha(data)}")
    data = apply_patches(data, v7p)
    assert sha(data) == SHA[7], "V7 hash mismatch"
    print(f"v7         {sha(data)}")
    data = apply_patches(data, v8p)
    assert sha(data) == SHA[8], "V8 hash mismatch"
    print(f"v8         {sha(data)}")

    # V9: force the final gate inside CalcShouldTrackFeatProgress:
    #   raw 0x7b7906: e8 85 71 8f ff (call 0x1400af690) -> b0 01 90 90 90 (mov al,1; nop;nop;nop)
    v9 = [(0x007b7906, bytes.fromhex("e8 85 71 8f ff"), bytes.fromhex("b0 01 90 90 90"))]
    data = apply_patches(data, v9)
    print(f"v9         {sha(data)}")

if __name__ == "__main__":
    main()
