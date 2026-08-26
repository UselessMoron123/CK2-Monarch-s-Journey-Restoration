# Reconstructed artifacts

The uploaded Base64 parts and RAR volumes have been materialized into the
original binary files. The source parts and volumes are retained, so each
result can be independently checked against its recorded identity.

## Base64 upload chunks

The manifests describe `CK2game.exe` for each Windows build. Version-qualified
names are used at the repository root so the otherwise-identical original
filename does not collide.

| Source parts | Materialized file | Size | SHA-256 | Verification |
|---|---|---:|---|---|
| `CK2game_win332_upload_chunks/CK2game_win332.base64.part001-004.txt` | `CK2game332.exe` | 24,727,272 | `83ba6a687270620633644bfdc93ecc2dd4c8579da66ee085e31af9aa0a506e75` | matches manifest |
| `CK2game_win333_upload_chunks/CK2game_win333.base64.part001-004.txt` | `CK2game333.exe` | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | existing file matches chunks and manifest |
| `CK2game_win3351_upload_chunks/CK2game_win3351.base64.part001-004.txt` | `CK2game3351.exe` | 24,236,024 | `a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d` | existing file matches chunks and manifest |
| `ck2_linux_upload_chunks/ck2_linux.base64.part001-005.txt` | `ck2` | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` | matches manifest |

The Base64 text was concatenated in numeric part order, whitespace was
removed, and the result was decoded without changing any bytes.

## RAR volumes

Each three-volume RAR5 set was tested and extracted from its `part1` volume;
the RAR reader followed the remaining volumes and verified the member CRC.

| Source volumes | Extracted file | Size | SHA-256 |
|---|---|---:|---|
| `debug files/ck2.part1.rar`, `part2.rar`, `part3.rar` | `debug files/ck2.pdb` | 64,770,048 | `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` |
| `debug files/ck2game.part1.rar`, `part2.rar`, `part3.rar` | `debug files/ck2game.pdb` | 67,005,440 | `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` |

The extracted PDBs are the debug-symbol files referenced by the existing
2.6.1.1 analysis. `ck2game.pdb` exactly matches `debug files/CK2game.exe`;
`ck2.pdb` is the earlier mismatched live-branch reference described in
`ALL-MY-LOGS-SO-FAR/03_analysis/IDENTITY.md`.

## Verify locally

From the repository root, the materialized files can be checked with:

```text
sha256sum CK2game332.exe CK2game333.exe CK2game3351.exe ck2 \
  "debug files/ck2.pdb" "debug files/ck2game.pdb"
```

The expected values are the hashes in the tables above. These are stock
artifacts reconstructed from the supplied uploads; no patched executable was
created.
