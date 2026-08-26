# Reconstructed artifacts

The uploaded Base64 parts and RAR volumes were materialized into the original
binary files. The Base64 parts were then removed after a second full audit;
the small manifests and RAR volumes remain as provenance. The materialized
files are sorted under `ALL-MY-LOGS-SO-FAR/10_binary_artifacts/`.

## Base64 upload chunks

The manifests describe `CK2game.exe` for each Windows build. Version-qualified
filenames are used so the otherwise-identical original filename does not
collide. The original part files are no longer present; their manifests are
retained in `10_binary_artifacts/upload_manifests/`.

| Retained manifest | Materialized file | Size | SHA-256 | Verification |
|---|---|---:|---|---|
| `10_binary_artifacts/upload_manifests/CK2game_win332.manifest.txt` | `10_binary_artifacts/executables/windows/CK2game332.exe` | 24,727,272 | `83ba6a687270620633644bfdc93ecc2dd4c8579da66ee085e31af9aa0a506e75` | rebuilt from 4 parts; second audit passed |
| `10_binary_artifacts/upload_manifests/CK2game_win333.manifest.txt` | `10_binary_artifacts/executables/windows/CK2game333.exe` | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | rebuilt from 4 parts; existing file and second audit passed |
| `10_binary_artifacts/upload_manifests/CK2game_win3351.manifest.txt` | `10_binary_artifacts/executables/windows/CK2game3351.exe` | 24,236,024 | `a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d` | rebuilt from 4 parts; existing file and second audit passed |
| `10_binary_artifacts/upload_manifests/ck2_linux.manifest.txt` | `10_binary_artifacts/executables/linux/ck2` | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` | rebuilt from 5 parts; second audit passed |

During the second audit, every numbered part was present, the combined
Base64 character count matched its manifest, strict Base64 decoding succeeded,
and the decoded size and SHA-256 matched. The resulting Windows files have an
`MZ`/PE header and the Linux file has an ELF header.

## RAR volumes

Each three-volume RAR5 set was tested and extracted from its `part1` volume;
the RAR reader followed the remaining volumes and verified the member CRC.
The original volumes are now in
`10_binary_artifacts/debug_files/rar_volumes/`.

| Source volumes | Extracted file | Size | SHA-256 |
|---|---|---:|---|
| `10_binary_artifacts/debug_files/rar_volumes/ck2.part1-3.rar` | `10_binary_artifacts/debug_files/pdb/ck2.pdb` | 64,770,048 | `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` |
| `10_binary_artifacts/debug_files/rar_volumes/ck2game.part1-3.rar` | `10_binary_artifacts/debug_files/pdb/ck2game.pdb` | 67,005,440 | `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` |

The second audit confirmed all RAR volume sizes and SHA-256 values, RAR5
signatures, exact member names, and CRC tests. The extracted PDBs are the
debug-symbol files referenced by the existing 2.6.1.1 analysis.
`ck2game.pdb` exactly matches the debug `CK2game.exe`; `ck2.pdb` is the
earlier mismatched live-branch reference described in
`ALL-MY-LOGS-SO-FAR/03_analysis/IDENTITY.md`.

## Verify locally

From the repository root, the materialized files can be checked with:

```text
sha256sum \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game332.exe \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game3351.exe \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/linux/ck2 \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/debug_files/pdb/ck2.pdb \
  ALL-MY-LOGS-SO-FAR/10_binary_artifacts/debug_files/pdb/ck2game.pdb
```

The expected values are the hashes in the tables above. These are stock
artifacts reconstructed from the supplied uploads; no patched executable was
created.
