# Banned / do-not-reuse artifact register

A build, hash, or approach lands here when it was shipped (or nearly shipped)
and **proved wrong at runtime or by re-analysis**. The v2 working rules require
this register so no future session rebuilds a known-bad artifact. Key every
entry by its SHA-256, not its generation label (labels collide — see Part 3).

---

## B1. Executable builds

| Label as used | SHA-256 | Size | Why banned |
|---|---|---:|---|
| **"V6" (Part 2 trampoline)** | `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff` | 24,753,368 | Code-injection trampoline at `0x00ff66a2` called `0x1409e8200` during the save-**read** path. That helper is a vector **append** (write direction), not a deserializer — it corrupted archive parsing: `"Unexpected token: fem/dna/properties/culture/government/dynasty"`, crashes on resign/bookmark change, feats not counting. Reverted; V6 patcher files deliberately deleted. See `CK2_MJ_V6_FAILED_ROADCAUSE.md` and Part 2 C2/B3. |
| **"V7" feat-update candidate** | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` | 24,753,368 | Two-branch patch on top of V6 targeting "live feat updates after load." Raw offsets `0x00666546: 74 0d → 90 90` and `0x007856e8: 74 0d → 90 90` (duplicated outer gates skipping live feat-update routine). Premise (tracker dead after load) was **disproven** by a fresh Pavao Bronzeman campaign granting Bronze at exact payload threshold and persisting. Built/pushed as `cb1df83` / `c70a453` on `arena/01a02609…` (files `patch_ck2_mj_v7.ps1` + `APPLY_CK2_MJ_V7.bat` + `CHECK_CK2_MJ_V7.bat` + `REVERT_CK2_MJ_V7_TO_V6.bat` + `CK2_MJ_V7_TEST_GUIDE.md` in `things parent AI asked to upload/`) but **never shipped or committed to organized repo**; do not resurrect without reproducible fresh-campaign failure. See Part 3 D1, `logs to dissect.../(5).txt`, and `DISSECTION_REPORT.md`. |

> These are **not** the current V6/V7. Current in-game Continue baseline = V7
> `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`
> (`0x009E5B8B` `75 2f→eb 2f`). V6 `f5b7dfd6e23b…` is the exact revert target
> (5 save-selection branches, no injected code). See `00_START_HERE/STATUS.md`.

## B2. Helpers that must not be called from a load path

| Address (win333) | Role | Must not be used for |
|---|---|---|
| `0x1409e8200` | vector **append** of one 0x28 feat entry (write direction; element copy `0x1409e8320`, growth `0x1406bcdb0`) | deserializing feat_progress on load — this is exactly what corrupted V6 |
| `0x140d75fd8` (+element reader `0x140d76860`) | in-memory **hash-map builder**, unreferenced dead code | a save deserializer (not callable with the reader's register state) |
| `0x140c38f30` | hardcoded child→vector reader for tokens 0x2ae/0x2af with debug-assert behavior | a generic feat child-node reader |
| `0x1409e82a0` | vector post-processor, stride 0x20 (save-game lists) | feat entries (stride 0x28) |
| `0x1409dede0` / outer `0x1409dcfa0` | save-game **browser metadata** serializer (games/savegameentry/…) | feat serialization (red herring) |

## B3. Patches / approaches proven wrong

| Approach | Why closed |
|---|---|
| `INT_MAX` (`2147483647`) as `event_time_end` | overflows the signed-32 `+172800` visibility check to a 1901 date → panel instantly hidden. Use `1893499200` (2030); ceiling `2147310847`. |
| Payload at `common\monarchs_journey\monarchs.txt` on Windows | string/path absent from the Windows May binary's open path (Linux-only). |
| Payload at `gfx\test.dds` | the startup username-cache routine reads/rewrites that same path before MJ inits → collision by design. |
| Global rename of the `test.dds` string | renames both the loader and the username cache; breaks the cache. Use the v2 LEA-displacement redirect instead. |
| String-overwrite filename patch (Patch B, `0x010d55d8` `test.dds\0`→`monarchs.\0`) | superseded by v2's LEA redirect at `0x00d73e1a` (no .rdata surgery). |
| Globally forcing account status 3 | related pointers stay null; patch only the specific UI/save branches. |
| Reinstating V3's forced online reward-container branch (`0x007c0d18`) | exposes empty `UI_ MISSING_TEXT` controls; reward data is server-side and dead. |
| Forcing only the final Start button | earlier eligibility predicate still blocks; patch the chain (v4 approach). |
| Mod-based fix for save-token reading | save-token reading is compiled C++; mods cannot add deserializers. |
| Appending a new PE section for code caves | Authenticode overlay at file `0x1799400` + tooling friction; end-of-.text zero padding (`0x15E` bytes at `0x00ff66a2`) is the right home for small caves. |
| Calling a "deserializer" helper without proving its data direction | the root lesson of the banned V6 — static byte/hasht verification cannot substitute for semantic proof of read/write direction. |
| Applying May-2020 offsets to 3.3.5.1 (or any other build) | different build; the guarded patchers refuse by hash. 3.3.5.1 byte-port is infeasible anyway (parser/SDK removed). |

## B4. Operational safety (unchanged, restated for the register)

- **Never run `wipe_feats`** ("Wipe out all CK2 Featured Ruler feats. WARNING: CANNOT BE UNDONE!").
- Never upload/share `pdx_login.txt`, tokens, or account data.
- Never commit decoded executables or redistribute stock/patched CK2 binaries; distribute only guarded patchers + payload.
- Never overwrite the two Kulin evidence saves (`Bosnia1173_03_03.ck2`, `Bronzeman_kulin_bosnia.ck2`); don't open newer saves in the old build.
- Test **offline** only; Internet on switches the obsolete client to a failed state.
