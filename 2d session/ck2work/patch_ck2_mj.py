#!/usr/bin/env python3
"""
Backup-safe patcher for CK2 3.3.3 (May 2020) Windows - Monarch's Journey local mode.

Patches a COPY of CK2game333.exe to force the offline "null" GameSparks stub
and rename its local-cache file so the static monarchs_journey payload is read
from the user's Documents folder.

This only modifies the user's own executable for personal restoration of the
retired Monarch's Journey interface. It does not redistribute a modified binary.

Usage:
    python patch_ck2_mj.py apply  CK2game.exe
    python patch_ck2_mj.py revert CK2game.exe
    python patch_ck2_mj.py verify CK2game.exe

The expected ORIGINAL SHA-256 (May 2020 build, manifest):
    656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8
"""
import sys, os, hashlib, shutil, datetime

ORIG_SHA256 = "656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8"
ORIG_SIZE   = 24_753_368

# (offset, original_bytes, patched_bytes, description)
PATCHES = [
    (0x00d73d02,
     bytes.fromhex("742b"),
     bytes.fromhex("eb2b"),
     "factory: je -> jmp  (always select local/null GameSparks stub)"),
    (0x010d55d8,
     b"test.dds\x00",
     b"monarchs.\x00",
     "rename local cache file test.dds -> monarchs."),
]

def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def read_at(path, off, n):
    with open(path, "rb") as f:
        f.seek(off); return f.read(n)

def write_at(path, off, data):
    with open(path, "r+b") as f:
        f.seek(off); f.write(data)

def fail(msg):
    print("ERROR: " + msg); sys.exit(1)

def check_identity(path):
    if not os.path.isfile(path): fail(f"file not found: {path}")
    size = os.path.getsize(path)
    if size != ORIG_SIZE:
        fail(f"size mismatch: got {size}, expected {ORIG_SIZE}. "
             f"This patcher only supports the exact May 2020 CK2game333.exe.")
    digest = sha256(path)
    if digest.lower() != ORIG_SHA256:
        fail(f"SHA-256 mismatch:\n  got      {digest}\n  expected {ORIG_SHA256}\n"
             f"Refusing to patch an unknown binary.")
    return digest

def apply(path):
    digest = check_identity(path)
    # verify expected bytes at every offset BEFORE writing
    for off, orig, new, desc in PATCHES:
        got = read_at(path, off, len(orig))
        if got != orig:
            fail(f"unexpected bytes at 0x{off:x}: got {got.hex()}, expected {orig.hex()}\n  ({desc})")
    # backup
    bak = path + ".bak"
    if os.path.exists(bak):
        fail(f"backup already exists: {bak} (remove it manually if you intend to re-patch)")
    shutil.copy2(path, bak)
    print(f"backup created: {bak}")
    # apply
    for off, orig, new, desc in PATCHES:
        write_at(path, off, new)
        print(f"  patched 0x{off:08x}: {orig.hex()} -> {new.hex()}  ({desc})")
    new_digest = sha256(path)
    print("\npatch applied.")
    print(f"  original SHA-256: {digest}")
    print(f"  patched  SHA-256: {new_digest}")
    print("\nNow place your JSON payload (the Linux monarchs.txt content) at:")
    print(r"  %USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\monarchs.")
    print("Use event_time_end = 1893499200 (2030-01-01), NOT 2147483647.")

def revert(path):
    bak = path + ".bak"
    if not os.path.isfile(bak):
        fail(f"backup not found: {bak}")
    digest = sha256(bak)
    if digest.lower() != ORIG_SHA256:
        fail(f"backup SHA-256 does not match the known original; refusing to restore:\n  {digest}")
    shutil.copy2(bak, path)
    print(f"reverted {path} from backup.")
    print(f"  SHA-256: {sha256(path)}")

def verify(path):
    if not os.path.isfile(path): fail(f"file not found: {path}")
    digest = sha256(path)
    print(f"file:   {path}")
    print(f"size:   {os.path.getsize(path)}")
    print(f"sha256: {digest}")
    if digest.lower() == ORIG_SHA256:
        print("status: ORIGINAL (unpatched May 2020 build)")
        return
    patched = True
    for off, orig, new, desc in PATCHES:
        got = read_at(path, off, len(new))
        if got == new:
            print(f"  [PATCHED] 0x{off:08x}: {new.hex()}  ({desc})")
        else:
            patched = False
            print(f"  [UNKNOWN] 0x{off:08x}: got {got.hex()}  ({desc})")
    if patched:
        print("status: PATCHED (Monarch's Journey local mode)")
    else:
        print("status: UNKNOWN (not the original and not a clean patch)")

def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("apply","revert","verify"):
        print(__doc__); sys.exit(2)
    cmd, path = sys.argv[1], sys.argv[2]
    {"apply": apply, "revert": revert, "verify": verify}[cmd](path)

if __name__ == "__main__":
    main()
