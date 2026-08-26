# Executable and artifact identities — all verified

Verified 2026-08-22 by concatenating each `*_upload_chunks` folder’s numbered
Base64 parts in order, stripping CR/LF, decoding, and comparing SHA-256:

```bash
cat <folder>/<name>.base64.part*.txt | tr -d '\r\n ' | base64 -d > out
sha256sum out
```

## Stock executables (reconstructed from this repository) — ALL MATCH

| Binary | Size (bytes) | SHA-256 | Build string | Role |
|---|---:|---|---|---|
| Windows 3.3.2 | 24,727,272 | `83ba6a687270620633644bfdc93ecc2dd4c8579da66ee085e31af9aa0a506e75` | 2020-02-06 | Remote-GameSparks era; no local `common/monarchs_journey` path |
| Windows 3.3.3 (May 2020) | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | 2020-05-06 12:57:06 +0200 | **Patch target** (last build before MJ retirement) |
| Windows 3.3.5.1 | 24,236,024 | `a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d` | 2021-09-21 16:13:22 +0200 | Post-removal; −517 KiB vs May 3.3.3 |
| Linux 3.3.3 (May 2020) | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` | 2020-05-06 12:57:06 +0200 | Symbol-rich reference; native `CNullGameSpark` local loader |

The May Windows 3.3.3 matches the handoff’s verified stock identity exactly, and the
Linux binary matches its previously verified identity. PE details for the Windows patch
target: PE32+ x86-64, image base `0x140000000`, `.text` VMA `0x140001000`, raw `0x400`,
so **VA = raw_offset + 0x140000c00**.

## Patched-state hashes (May Windows 3.3.3)

| State | SHA-256 |
|---|---|
| V2 | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` |
| V3 | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` |
| V4 | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` |
| V5 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| **V6 (current, runtime-proven)** | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` |

## Ruler payload

`things parent AI asked to upload/monarchs` — 101,949 bytes, plain JSON,
SHA-256 `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`.
11 rulers, 33 challenges, all `event_time_end = 1893499200` (2030-01-01 12:00 UTC —
intentionally NOT INT_MAX; see handoff §4).

## Evidence saves

| File | Date | special_event | SHA-256 |
|---|---|---|---|
| Bosnia1173_03_03.ck2 | 1173.3.3 | kulin_bosnia | `e25c1c90074b9c02c29163fb6f034241226f1432edfbe184c804aa330edd61c0` |
| Bronzeman_kulin_bosnia.ck2 | 1173.1.1 | kulin_bosnia | `5b7767b92483ec21bd86149aab8fe56577caf7f77a3a19ebf7bdaf0f3729d038` |
| Bronzeman_pavao_croatia.ck2 | 1278.1.1 | pavao_croatia | `d6ee9fc10449c15a4f6eb40d065e71a592e3e01e9e5ce8af54fac9742898ce68` |
| Croatia1278_01_02.ck2 | 1278.1.2 | pavao_croatia | `da84b4d1be695dee53455a1c3a8e749de4014cedfdec131fa289533f17b3a51c` |
| Croatia1278_01_10.ck2 | 1278.1.10 | pavao_croatia | `68d0c993ca68d22250ee1ed93c345b04f7c30eb11df7f4622a85d2819e2b322f` |

All five are ordinary ZIP-format `.ck2` archives readable with Python `zipfile`
(main entry + `meta`), all `bronzeman=yes`, version `3.3.3.0`.

## Local feat-progress cache

`v6 second look/cache/q847rsja8ndx` — plaintext key=value store
(`feat_progress_storage.cpp`), `user_id=84696387`, 33 feat counters; nonzero:
`established=4` (Bronze peak), `conquerer_from_bribir=1`.

## V6 tool hashes — match handoff exactly

```text
patch_ck2_mj_v6.ps1            995ee9aa9db75d13a1374cfe4a6b575893d262acfd763032060d3b87fd956e3b
APPLY_CK2_MJ_V6.bat            f92ed979ede2d5bf25179ba89e494b28da41cb2285dea7a1cd527f68c7f4a4cc
CHECK_CK2_MJ_V6.bat            607e4f6c8a2cf3ddf82f9497187a7fce0cc014c9d1e3e216482dad034ec34013
REVERT_CK2_MJ_V6_TO_V5.bat     6ac6c9d846928f9c999f18640c2dda4a34e43979a882978307785d9295abf8c7
```

## Provenance and safety

The Base64 chunks and manifests remain the byte-level source of truth. At the user's
request, the stock files have also been materialized in the checkout as
`CK2game332.exe`, `CK2game333.exe`, `CK2game3351.exe`, and `ck2`; their hashes are
unchanged and are recorded above and in `RECONSTRUCTED_ARTIFACTS.md`. No patched
executable was created. Keep the chunk sources when moving these files so their
identities can be rechecked after copying.
