#!/usr/bin/env python3
"""Backup-safe minimal Monarch's Journey patcher for exact May 2020 CK2 3.3.3.

This applies ONLY the two-byte factory-branch patch. It deliberately leaves the
9-byte "test.dds\0" field untouched; the supplied payload must therefore be
named test.dds.
"""

from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import shutil
import sys
import tempfile

EXPECTED_SIZE = 24_753_368
EXPECTED_ORIGINAL_SHA256 = (
    "656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8"
)

PATCHES = (
    {
        "offset": 0x00D73D02,
        "original": bytes.fromhex("74 2b"),
        "patched": bytes.fromhex("eb 2b"),
        "description": "force the local/null GameSparks implementation",
    },
)


class PatchError(RuntimeError):
    pass


def sha256_bytes(data: bytes | bytearray) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def read_identity(path: Path) -> tuple[int, str]:
    if not path.is_file():
        raise PatchError(f"File not found: {path}")
    return path.stat().st_size, sha256_file(path)


def bytes_at(data: bytes | bytearray, offset: int, length: int) -> bytes:
    return bytes(data[offset : offset + length])


def classify(path: Path) -> tuple[str, str]:
    size, actual_hash = read_identity(path)
    if size != EXPECTED_SIZE:
        raise PatchError(
            f"Wrong file size: {size:,} bytes; expected {EXPECTED_SIZE:,}. "
            "Refusing to touch this file."
        )

    if actual_hash == EXPECTED_ORIGINAL_SHA256:
        return "original", actual_hash

    data = bytearray(path.read_bytes())
    for patch in PATCHES:
        got = bytes_at(data, patch["offset"], len(patch["patched"]))
        if got != patch["patched"]:
            raise PatchError(
                f"Unknown executable. SHA-256 is {actual_hash}; bytes at "
                f"0x{patch['offset']:08x} are {got.hex(' ')}, not the expected "
                f"patched bytes {patch['patched'].hex(' ')}."
            )
        data[patch["offset"] : patch["offset"] + len(patch["original"])] = patch[
            "original"
        ]

    normalized_hash = sha256_bytes(data)
    if normalized_hash != EXPECTED_ORIGINAL_SHA256:
        raise PatchError(
            "The patch bytes are present, but other bytes differ from the verified "
            f"May executable. Normalized SHA-256: {normalized_hash}."
        )
    return "patched", actual_hash


def backup_path_for(exe: Path) -> Path:
    return exe.with_name(exe.name + ".pre_mj_patch.bak")


def verify_original_backup(backup: Path) -> None:
    size, digest = read_identity(backup)
    if size != EXPECTED_SIZE or digest != EXPECTED_ORIGINAL_SHA256:
        raise PatchError(
            f"Existing backup is not the verified original: {backup}\n"
            f"Size: {size:,}; SHA-256: {digest}"
        )


def apply_patch(exe: Path) -> None:
    state, digest = classify(exe)
    if state == "patched":
        print(f"Already patched and fully verified. SHA-256: {digest}")
        return

    backup = backup_path_for(exe)
    if backup.exists():
        verify_original_backup(backup)
        print(f"Reusing verified original backup: {backup}")
    else:
        shutil.copy2(exe, backup)
        verify_original_backup(backup)
        print(f"Created and verified backup: {backup}")

    # Build and verify a temporary file before atomically replacing the target.
    fd, temp_name = tempfile.mkstemp(prefix=exe.name + ".", suffix=".tmp", dir=exe.parent)
    os.close(fd)
    temp = Path(temp_name)
    try:
        shutil.copy2(exe, temp)
        with temp.open("r+b") as f:
            for patch in PATCHES:
                f.seek(patch["offset"])
                got = f.read(len(patch["original"]))
                if got != patch["original"]:
                    raise PatchError(
                        f"Pre-write byte check failed at 0x{patch['offset']:08x}: "
                        f"got {got.hex(' ')}"
                    )
                f.seek(patch["offset"])
                f.write(patch["patched"])
                print(
                    f"Applied at 0x{patch['offset']:08x}: "
                    f"{patch['original'].hex(' ')} -> {patch['patched'].hex(' ')} "
                    f"({patch['description']})"
                )
            f.flush()
            os.fsync(f.fileno())

        temp_state, temp_hash = classify(temp)
        if temp_state != "patched":
            raise PatchError("Internal verification did not classify the result as patched.")
        os.replace(temp, exe)
        print(f"Patched file SHA-256: {temp_hash}")
        print("Full normalized-hash verification: PASS")
        print("The hardcoded filename remains test.dds (no unsafe string patch was used).")
    finally:
        if temp.exists():
            temp.unlink()


def revert_patch(exe: Path) -> None:
    backup = backup_path_for(exe)
    verify_original_backup(backup)

    fd, temp_name = tempfile.mkstemp(prefix=exe.name + ".", suffix=".tmp", dir=exe.parent)
    os.close(fd)
    temp = Path(temp_name)
    try:
        shutil.copy2(backup, temp)
        size, digest = read_identity(temp)
        if size != EXPECTED_SIZE or digest != EXPECTED_ORIGINAL_SHA256:
            raise PatchError("Temporary restore copy failed verification.")
        os.replace(temp, exe)
    finally:
        if temp.exists():
            temp.unlink()

    print(f"Restored verified original from: {backup}")
    print(f"SHA-256: {EXPECTED_ORIGINAL_SHA256}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("verify", "apply", "revert"))
    parser.add_argument("game_exe", type=Path, help="Path to the exact May 2020 CK2 executable")
    args = parser.parse_args()
    exe = args.game_exe.expanduser().resolve()

    try:
        if args.operation == "verify":
            state, digest = classify(exe)
            print(f"State: {state}")
            print(f"Size: {exe.stat().st_size:,} bytes")
            print(f"SHA-256: {digest}")
            if state == "patched":
                print("Full normalized-hash verification: PASS")
        elif args.operation == "apply":
            apply_patch(exe)
        else:
            revert_patch(exe)
        return 0
    except (OSError, PatchError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
