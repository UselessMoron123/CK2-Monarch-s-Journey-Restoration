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

Materialized paths:
- Windows executables: `10_binary_artifacts/executables/windows/`
- Linux executable: `10_binary_artifacts/executables/linux/ck2`
- 2.6.1.1 debug drop: `10_binary_artifacts/debug_files/`

## 2. Patched states (Windows May 3.3.3, all 24,753,368 bytes)

| State | SHA-256 | Status |
|---|---|---|
| v1 (branch-only experiment) | `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c` | superseded |
| V2 (loader redirect) | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` | superseded |
| V3 (UI gates) | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` | superseded |
| V4 (offline challenges) | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` | superseded |
| V5 (save validator + tooltip) | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` | superseded (safe rollback target) |
| V6 (previous baseline / V7 revert target) | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | ✅ runtime-proven |
| V7 Continue | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` | ✅ in-game Continue proven (`0x009E5B8B` `75 2f→eb 2f`); useful revert target |
| V8 feat-rehydration bypasses | `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93` | ❌ applied on the user machine 2026-08-29, **premise disproven** (feats 0 in game *and* main-menu MJ tab). Both edits kept in V9; neither is the fix |
| **V9 cold-load feat fix (current baseline)** | `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687` | ✅ **runtime-proven 2026-08-30** (`0x007B7906` `e8 85 71 8f ff → b0 01 90 90 90`). See `V9_RUNTIME_RESULTS.md` |
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
| Bronzeman_llywelyn_gwynedd.ck2 | 1195.1.1 | llywelyn_gwynedd | *(not uploaded)* | user-side; preflight 2026-08-26: 3,682,972 B, `bronzeman=yes`, player King Llywelyn 'the Great' |
| Gwynedd1195_01_08.ck2 | 1195.1.8 | llywelyn_gwynedd | *(not uploaded)* | user-side; preflight 2026-08-26: 3,836,788 B, `bronzeman=yes`; **no feat cache after this session** |

## 5. Local feat-progress cache

| File | Detail | Path |
|---|---|---|
| `q847rsja8ndx.txt` | `feat_progress_storage.cpp` plaintext key=value; `user=152991562`, `user_id=453496064`, `category=697115649`; 33 counters, only `heretical_company=1` | `13_save_and_cache/` |
| `q847rsja8ndx_v6_secondlook.txt` | `user_id=84696387`, `category=-1991027533`; `established=4` (Bronze peak), `conquerer_from_bribir=1` | `13_save_and_cache/` |

Live path on the user machine: `C:\Users\UZWERG\Documents\Paradox Interactive\Crusader
Kings II\cache\q847rsja8ndx`. One snapshot of it hashes to
`3606E210F48EB16B668B06E24942B545E65B11531F28F28D08FF9FDDE404601F` (751 bytes,
`user_id=84696387`, `established=3`).

⚠️ **Four distinct `user_id` values** are on record for this one file —
`453496064`, `84696387`, `1148909174`, `1179784490` — several with identical feat
vectors. The full table and the withdrawal of the "identity drift is refuted"
conclusion are in `CONTRADICTIONS.md` §12.

**Semantics (see `FEAT_CACHE_PEAK_TIER_ICON.md`):** this cache stores the **lifetime
peak** per feat for the whole Windows profile — *not* per save. It is what drives the
medal and the "Best Result" figure; the save's `global_<featkey>` variables drive
"Current Progress". It applies to every save and every campaign until the file is
removed.

## 6. Patcher toolchain (V2–V9; V4–V6 hashes 2026-08-26, V7 hashes 2026-08-27, V8/V9 hashes 2026-08-30)

| File | SHA-256 |
|---|---|
| `patch_ck2_mj_v4.ps1` | `d1c8d41d9bd6c209a97a27fd86f342b7bb9345e193c6dd1e2d90db6383da5702` |
| `APPLY_CK2_MJ_V4.bat` | `576ed4822b8c0b53839209b541d05a72197b3fa8f1503e72989e707d2e435ed2` |
| `CHECK_CK2_MJ_V4.bat` | `904bc214b77fd4df744d9ff1a88c27b7db0f08e80a5df29123a3be9c4c723b35` |
| `REVERT_CK2_MJ_V4.bat` | `2e6cdc90439dc242e911da4f269af08c3ac2e71d67d2dc67ac5e61d224b37281` |
| `patch_ck2_mj_v5.ps1` | `06ee55f6348e3e28f0a38ccdde1a94185e59892ce55955add16a9d46c59562a5` |
| `APPLY_CK2_MJ_V5.bat` | `4eb1691bcc7c95497e38b9f540f00b685688527680f7fc6bbe048539948b6747` |
| `CHECK_CK2_MJ_V5.bat` | `f7f9f75ca24ff4308ceeb46f1b19bc808840e536be67e0e23eb8803a821de05e` |
| `REVERT_CK2_MJ_V5.bat` | `ee89486d3e3eb97c3130f21b42f79c2845f1d1add1b7811e42d9706fdab08ecf` |
| `patch_ck2_mj_v6.ps1` | `995ee9aa9db75d13a1374cfe4a6b575893d262acfd763032060d3b87fd956e3b` |
| `APPLY_CK2_MJ_V6.bat` | `f92ed979ede2d5bf25179ba89e494b28da41cb2285dea7a1cd527f68c7f4a4cc` |
| `CHECK_CK2_MJ_V6.bat` | `607e4f6c8a2cf3ddf82f9497187a7fce0cc014c9d1e3e216482dad034ec34013` |
| `REVERT_CK2_MJ_V6_TO_V5.bat` | `6ac6c9d846928f9c999f18640c2dda4a34e43979a882978307785d9295abf8c7` |
| `patch_ck2_mj_v7.ps1` | `6d2288ed44595b39f6d1eb95969d87dee1e948b7c2c12da9fddb131e4263e7e2` |
| `APPLY_CK2_MJ_V7.bat` | `1c06cc833438f0745d7b9db15eea56b24e1adc00fbfcfc59f3380fc1e07a6834` |
| `CHECK_CK2_MJ_V7.bat` | `438c6f36e1aa98429bd33b4c06374a7015d4254ad1908e3b2c6846bbc96adab9` |
| `REVERT_CK2_MJ_V7_TO_V6.bat` | `a4cc34a50e2b106f5ed7e03e7e2f7f5489fb8eeb130beed2ecaef4526732ad32` |
| `patch_ck2_mj_v8.ps1` | `66697afc71910b99de56c2b648125801b2357bb6eeeef579d87f5d3dfc437504` |
| `APPLY_CK2_MJ_V8.bat` | `1bd9651c8664f2ea4a2c2b8ada4da957a03a30b7f6e9bb1ae9f2ae4856073cc5` |
| `CHECK_CK2_MJ_V8.bat` | `aaa558aea85047f6557729caea11efa47b9d3d6cb658166f61572ad0aa054339` |
| `REVERT_CK2_MJ_V8_TO_V7.bat` | `f93108776860db3ffd7ec477c42034e19222034b326e3bdd652d971b89d1e2a2` |
| `patch_ck2_mj_v9.ps1` | `2a3a716acfc2eed2cc54b5eeaaf18a68f8593aed6f989a9a4d1bbe233317ecb0` |
| `APPLY_CK2_MJ_V9.bat` | `a6897de45cd0707b817425aaacf6db51bfca49781aaeeb7637feb0710bb9c791` |
| `CHECK_CK2_MJ_V9.bat` | `ad57654c8f28c620dcc1798a86646cc5045b3007002de12e0c68126cb916db0b` |
| `REVERT_CK2_MJ_V9_TO_V8.bat` | `1408084d615338a3e4e64edcb8c1ca713bd15a51a7d000845c295d0d3d60e7a2` |
| `RUN_APPLY_CK2_MJ_V9_INLINE.ps1` | `02ce982e02081c9dc76e3a3b10a8475c7584c6d71066d6a00f4de0f9b028a634` — **reconstructed 2026-08-30**; the V9 session claimed to have saved this file but never did. Body is verbatim from the chat; the hash covers the file *including* its provenance header, so it has no prior value to compare against |
| `py/build_v9_chain.py` | `77232f1150558303ba218c997ee666256e1d693bf4522e6fd9c5bb0b07176e28` — replays V2→V9 from the patcher sources asserting every hash; **re-run clean on 2026-08-30**, output `v9 61e4345b…` |

Debugger helpers (`05_patches_and_scripts/x64dbg/`):

| File | Size | SHA-256 |
|---|---:|---|
| `MJ_V8_CLEAN_TRACE.txt` | 1,665 | `49c4a60263d3b2f569875cc7f1687121c1891597380d0e4903be673578f37ec4` |
| `RUN_MJ_V8_CLEAN_TRACE.bat` | 3,088 | `5b2e79de8f1554bb7e14b18f2badb2532aa9714ec72b8ebeb867cc6a03d092e5` |
| `README_MJ_V8_CLEAN_TRACE.md` | 4,233 | `3394fafcbbe9193bc5a05776b25193ab30b61a607e496ce8bc6725e30016b27a` |
| `MJ_V9_CLEAN_TRACE.txt` | 2,115 | `06e0c5d6234142a697b7e4f84133ae3869e06a437a5853b251224aae3b91d77d` — ⚠️ still arms `DAILY_GATE` at `+666146`; see `CONTRADICTIONS.md` §13. Fixing it invalidates this hash and `README_MJ_V9_CLEAN_TRACE.md` |
| `RUN_MJ_V9_CLEAN_TRACE.bat` | 3,088 | `a3e5cfdb4fdbb833072567f16336ab42224debc05100fdd3af38cda71e7fb821` |
| `README_MJ_V9_CLEAN_TRACE.md` | 4,697 | `446d008eb73ce03d814de6b67a6ef01227a46e9d6ae2753b00aaa4437f7c4d0d` |

The three byte-identical copies of `MJ_V8_CLEAN_TRACE.txt`, `RUN_MJ_V8_CLEAN_TRACE.bat`
and the `01a044b2` patch that were sitting in `last log/` were removed during the
2026-08-30 ingest; the canonical copies above and in `11_git_patch/` were verified
identical with `cmp` first.

Test guides: `CK2_MJ_V5_load_test_guide.md` = `ef3c4335733dc516991ffa997fb1cac04bae020332098aad24d84ca8cb65a086`;
`CK2_MJ_V6_TEST_GUIDE.md` = `0d4d3d21f0f000210cbfaa1a30b5afb2f89311babee6e2996a2985ecded8ab87`;
`CK2_MJ_V7_TEST_GUIDE.md` = `e0e182c2180cf19a27cb35285a3c1867953cc151ad765a7ef705a962b1d87b5d`;
`CK2_MJ_V8_TEST_GUIDE.md` = `7cd3916caccea01bd68a5a8ed2f333a6f92a4ea43578ab16b0d7b3a8d4916880`
(⚠️ carries a 2026-08-30 SUPERSEDED banner; the pre-banner hash was `3ea0a08a…`.
V8's premise was disproven — read `V9_RUNTIME_RESULTS.md` §2 first);
`CK2_MJ_V9_TEST_GUIDE.md` = `ac93f8b81db65861c880e93fd2df39e362e2f217909d1a0ab13c9481b4f7e42a`
(current);
`CK2_MJ_windows_v4_test_guide.md` (now under `04_test_guides_and_reports/`) = `9e7664a52b18dba919dd939ff11da4f6cb65e13212c6010b1096a3a858d062cd`
— ⚠️ the old handoff recorded `3177eaef5298482de564278b1d79006a28f73ea9bb64ce84c5483505947c3234`
for the V4 guide; the current file hashes to `9e7664a5…` (edited after that hash was
taken; harmless, V4 superseded). Flagged 2026-08-26.

## 7. 2.6.1.1 debug/symbol files (PDB reference set — different build, 32-bit)

| File | Size | SHA-256 | Note |
|---|---:|---|---|
| `CK2game.exe` (2.6.1.1) | 16,535,040 | `ec4ea0393ef1f8f835d2594dd7e1249ebe850a31688dae56c94c875a0748e5a6` | `10_binary_artifacts/debug_files/`; 2016-08-30; GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1 |
| `ck2game.pdb` | 67,005,440 | `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` | `10_binary_artifacts/debug_files/pdb/`; exact-match symbols for the above |
| `ck2.pdb` | 64,770,048 | `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` | `10_binary_artifacts/debug_files/pdb/`; earlier live-branch build (2016-06-01), no matching EXE |

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
