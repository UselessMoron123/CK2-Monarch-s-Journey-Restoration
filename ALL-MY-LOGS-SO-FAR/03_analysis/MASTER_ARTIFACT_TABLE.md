# Master artifact table — CK2 Monarch's Journey

One canonical registry of every verified artifact: file → size → SHA-256 →
location in this archive → role. Compiled 2026-08-24 by consolidating
`EXECUTABLE_IDENTITIES.md`, `WINDOWS_333_PATCH_MAP.md` (+ `.csv`), the Part 1–3
archives, and the upload manifests. This is the lookup table a future session
should check first; it supersedes the scattered hash lists.

> Addressing reminder (win333 PE32+): image base `0x140000000`, `.text` VMA
> `0x140001000`, raw `0x400` ⇒ **VA = raw_file_offset + 0x140000c00** for `.text`.

---

## 1. Stock executables

| Binary | Size (bytes) | SHA-256 | Build / date | Role |
|---|---:|---|---|---|
| Windows 3.3.2 | 24,727,272 | `83ba6a687270620633644bfdc93ecc2dd4c8579da66ee085e31af9aa0a506e75` | 2020-02-06 | Remote-GameSparks era; no local `common/monarchs_journey` path |
| **Windows 3.3.3 (May 2020)** | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | 2020-05-06 12:57:06 +0200 (linker 12:25:12 UTC) | **Patch target** — last build before MJ retirement |
| Windows 3.3.5.1 | 24,236,024 | `a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d` | 2021-09-21 16:13:22 +0200 | Post-removal; −517 KiB vs May; byte-port infeasible |
| Linux 3.3.3 (May 2020) | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` | 2020-05-06 | Symbol-rich reference; native `CNullGameSpark` |

## 2. Patched states (Windows May 3.3.3, all 24,753,368 bytes)

| State | SHA-256 | Status |
|---|---|---|
| v1 (branch-only experiment) | `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c` | superseded |
| V2 (loader redirect) | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` | superseded |
| V3 (UI gates) | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` | superseded |
| V4 (offline challenges) | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` | superseded |
| V5 (save validator + tooltip) | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` | superseded (safe rollback target) |
| **V6 (current baseline)** | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | ✅ runtime-proven |
| ⛔ "V6" trampoline (Part 2) | `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff` | **BANNED** — see `BANNED_ARTIFACTS.md` |
| ⚠️ "V7" feat-update candidate | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` | abandoned (premise disproven) |

## 3. Payload & game data

| Artifact | Size | SHA-256 | Path in archive | Role |
|---|---:|---|---|---|
| Ruler payload `monarchs` / `gfx\monarchs` | 101,949 | `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` | `06_game_data/monarchs` (+ variants) | 11 rulers / 33 challenges; 2030 timestamps; the active payload |

## 4. Evidence saves (all ZIP `.ck2`, `bronzeman=yes`, version 3.3.3.0)

| File | In-game date | special_event | Archive SHA-256 | Path |
|---|---|---|---|---|
| Bosnia1173_03_03.ck2 | 1173.3.3 | kulin_bosnia | `e25c1c90074b9c02c29163fb6f034241226f1432edfbe184c804aa330edd61c0` | `13_save_and_cache/` (`.txt`) |
| Bronzeman_kulin_bosnia.ck2 | 1173.1.1 | kulin_bosnia | `5b7767b92483ec21bd86149aab8fe56577caf7f77a3a19ebf7bdaf0f3729d038` | `13_save_and_cache/` (`.txt`) |
| Bronzeman_pavao_croatia.ck2 | 1278.1.1 | pavao_croatia | `d6ee9fc10449c15a4f6eb40d065e71a592e3e01e9e5ce8af54fac9742898ce68` | user-side (V6 second-look) |
| Croatia1278_01_02.ck2 | 1278.1.2 | pavao_croatia | `da84b4d1be695dee53455a1c3a8e749de4014cedfdec131fa289533f17b3a51c` | user-side |
| Croatia1278_01_10.ck2 | 1278.1.10 | pavao_croatia | `68d0c993ca68d22250ee1ed93c345b04f7c30eb11df7f4622a85d2819e2b322f` | user-side |

## 5. Local feat-progress cache

| File | Detail | Path |
|---|---|---|
| `q847rsja8ndx` | `feat_progress_storage.cpp` plaintext key=value; `user_id=84696387`; 33 counters, nonzero `established=4` (Bronze peak), `conquerer_from_bribir=1` | `13_save_and_cache/` |

## 6. V6 patcher toolchain (hashes match handoff §11)

| File | SHA-256 |
|---|---|
| `patch_ck2_mj_v6.ps1` | `995ee9aa9db75d13a1374cfe4a6b575893d262acfd763032060d3b87fd956e3b` |
| `APPLY_CK2_MJ_V6.bat` | `f92ed979ede2d5bf25179ba89e494b28da41cb2285dea7a1cd527f68c7f4a4cc` |
| `CHECK_CK2_MJ_V6.bat` | `607e4f6c8a2cf3ddf82f9497187a7fce0cc014c9d1e3e216482dad034ec34013` |
| `REVERT_CK2_MJ_V6_TO_V5.bat` | `6ac6c9d846928f9c999f18640c2dda4a34e43979a882978307785d9295abf8c7` |

## 7. 2.6.1.1 debug/symbol files (PDB reference set — different build, 32-bit)

| File | Size | SHA-256 | Note |
|---|---:|---|---|
| `CK2game.exe` (2.6.1.1) | 16,535,040 | `ec4ea0393ef1f8f835d2594dd7e1249ebe850a31688dae56c94c875a0748e5a6` | 2016-08-30; GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1 |
| `ck2game.pdb` | 67,005,440 | `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` | exact-match symbols for the above |
| `ck2.pdb` | 64,770,048 | `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` | earlier live-branch build (2016-06-01), no matching EXE |

These are a **semantic reference only**. None of their 32-bit VAs transfer to
win333; use them for the Continue control-flow model (see
`CONTINUE_SEMANTIC_REFERENCE.md`).

## 8. Depot / manifest identity (May 2020 last-pre-removal build)

| Depot | Manifest |
|---|---|
| Common 203771 | `7374899011992364670` |
| Windows 210890 | `8653648373486267886` |
| Linux 210909 | `4089811292004061988` |

Steam app 203770. Retirement update: 2020-09-02 (`CK2game.exe` −775 KiB).
