# Net-new facts extracted from raw chat logs (torn 2026-08-26)

**Purpose:** The `12_raw_chat_logs/` raw exports were fully dissected. Everything
below is content that existed **only in the raw logs** (verified by grepping the
entire archive/analysis/handoff corpus) and is preserved here so the raw files
can be removed without loss. Facts already captured in Parts 1–3 / `03_analysis`
/ `02_handoffs` are NOT repeated — this doc is only the net-new residue.

**Where the raw files went:** see `12_raw_chat_logs/INDEX.md` (per-file → where
it was distilled) and this doc (the byte-level extras). Source files are named
per row so you can trace any fact back to the original export.

---

## 1. feat_progress reader/writer case map (Windows May 3.3.3) — from Part-2 exports
Sources: `new text doc(second).txt`, `previous chat log (2).txt`, `session_may333_exe_upload.txt` (three near-identical exports of the same session). Part 2's archive records the *helper functions* (`0x140c38f30`, `0x140e4806c`, `0x140c3ae10`, writer `0x1409df82f`, reader `0x1407824a5`) but **not** the individual case-entry VAs below — those were only in the raw logs.

| Fact | Value | Notes |
|---|---|---|
| Working raw-blob token `0x3805` — read case | `0x140782404` | mirror target for the broken `0x3816` read |
| Working raw-blob token `0x3805` — write case | `0x1409df80a` | `lea rdx,[rsi+0x118]` (source field) → call `0x140c3ae10` (serializer) into `[rbp+0x4f8]` |
| `0x3816` (feat_progress) read-case region | starts `0x1407824d1` (token `0x3816-0x7b-1-0x27?`) | reader does **not** read `[rsi+0x138]` as a vector |
| sub-object reads inside `0x3816` case | `0x1407824eb` / `0x1407824ff` | "iterate children and append to vector" candidates |
| code cave / default-unknown-token path | `0x14078252a` | 8-byte cave; the V6-trampoline redirect point considered (Part 2) |
| writer function (feat_progress token) | `0x1409df974` | confirmed handles feat_progress section; earlier probe from `0x1409df900` |
| `0x1409e8200` inner loop | `0x1409e825f` | copies a `std::string` into a destination then advances the write pointer; calling it during load fed the archive string back as dest (corruption) |
| `Load` function `lea rdx` string target | `0x14105ff45` | string was empty in the raw read |

## 2. Windows 3.3.5.1 cross-version function addresses — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. The port-assessment doc
(`WINDOWS_3351_PORT_ASSESSMENT.md`) lists the *first* `extend_featured_ruler`
function VA (`0x140729ce0`) and the `test.dds` xref *count*; the full function
lists below were only in the raw log.

| Component | May 3.3.3 (win) VAs | 3.3.5.1 VAs |
|---|---|---|
| `extend_featured_ruler` flow (MJ bookmark/ruler-choose), 4 funcs | `0x140726720`, `0x140728770`, `0x140728fc0`, `0x14072ae70` | `0x140729ce0`, `0x14072bc80`, `0x14072c540`, `0x14072e7e0` |
| `test.dds` xrefs | 5 xrefs / 4 funcs | 2 xrefs from **1** func `0x14077bdc0` (username-cache use remains; `LoadLocalCache` use gone) |

## 3. Linux `.rodata` string addresses (feature database internals) — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. Resolved while disassembling
`CDirectorySettings` ctor and `GetContinueSave`.

| Address | String / role |
|---|---|
| `0x1869814` | `red_king/ruler_feats` (registered VFS directory, len `0x14`=20) |
| `0x186984f` | `common/monarchs_journey` (registered VFS directory, len `0x17`=23) |
| `0x1869829`, `0x1869838` | other directory-table names (len `0xe`, `0x16`) |
| `0x18697f3`, `0x186980a`, `0x19aaba4` | other directory/related string addresses |
| `0x18b4f27` | `gs_virtual/feat_script` — the **virtual-file name** the payload `feats_script` is mounted as in the VFS (payload → `gs_virtual/feat_script` → game-database loader) |

**Key insight (from §3):** the payload's `feats_script` is registered in the VFS
under the literal name `gs_virtual/feat_script`, and the DB loader reads it from
the VFS. `red_king/ruler_feats` and `common/monarchs_journey` are *registered
directory names* (like `common/wonders`). Whether a real on-disk folder under
`gs_virtual/` gets picked up depends on the VFS implementation — flagged as
untested in the raw log.

## 4. Linux `GetContinueSave` breadcrumbs — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. Complement to
`CONTINUE_SEMANTIC_REFERENCE.md` (which records the function address `0x121ac3a`).

| Fact | Value |
|---|---|
| Linux `CIronmanSaveSelect::GetContinueSave` | `0x121ac3a`, size 0x7df (≈2,015 B) |
| Signatures used | `GetContinueSave(bool, ..., CDLCManager*)` and `(bool, CloudStorageContext**, CDLCManager*)` — note the **bool first arg** |
| Interesting string constants inside | `0x18a1a70`, `0x18a28b6`, `0x19d1188`, `0x186975e`, `0x194e44d` |
| Confirmed behavior | scans `"save games/*.ck2"` newest-first with an **`alternate_start` exclusion** |
| Windows analog | one of the V6-patched regions — `0x1409e4970` (Continue candidate selection) / `0x1409e5500` (scan); the enable predicate likely calls GetContinueSave and it returns false for Featured-Ruler saves (the account branch `0x1409e5211` was patched inline but the button stays gray → **enable predicate elsewhere**) |

## 5. Feature-database load machinery (Linux, for the reward-gallery / FR follow-ons) — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. Addresses recovered while
tracing `CRulerFeatTracker::ReloadFeatsDatabase`.

| Linux address | Function |
|---|---|
| `0xff7f7a` | `CRulerFeatTracker::ReloadFeatsDatabase` (146 B) |
| `0xff800c` | `TSingleObjectGameDatabase::LoadFile(CReader&, bool)` |
| `0xff8912` | `TSingleObjectGameDatabase::LoadFile(char const*, bool)` (`LoadFileEPKcb`) |
| `0xff82d4` / `0xff865a` | `TSingleObjectGameDatabase::Init` (single-object / complete variants) |
| `0xff8748` / `0xff87c0` | `TGameDatabase::CreateInstance` |
| `0xff8b2a` | Complete-database `LoadFile` variant |
| `0x17ed028` / `0x17ed1e0` | `CReader` from string buffer ("Reader over memory") |
| `0x17f5990` | `CString` ctor from literal |
| `0x1820150` | another literal (empty-string or `csv`-ish constant) |

## 6. `.pdata` function-count reconciliation — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. Refines the number quoted in
`WINDOWS_3351_PORT_ASSESSMENT.md` (which said "~1,555 fewer" from a different
measurement).

| Build | `.pdata` size | Entries (÷12) |
|---|---|---|
| May 3.3.3 win | `0x8f73c` | 48,666 |
| 3.3.5.1 win | `0x8ae58` | 46,753 |
| **Δ** | `−0x48E4` (−18.6 KB) | **≈1,913 fewer functions** |

## 7. feat-V7 patch VA mapping (offset → VA) — from feat-V7 session
Source: `session_featV7_patch_continue_to_V8.txt`. The offsets `0x00666546` /
`0x007856e8` are already in `BANNED_ARTIFACTS.md`; the **VA forms** were only in
the raw log.

| raw offset | VA | bytes |
|---|---|---|
| `0x00666546` | `0x140667146` | `74 0d` → `90 90` |
| `0x007856e8` | `0x1407862e8` | `74 0d` → `90 90` |

## 8. Windows May-3.3.3 string→VA map — from may333 fragment
Source: `chat_fragment_may333_v1v2_continue_greyed.txt` (`grep -aob` scan). The
`load_button` VA `0x141078318` was already recorded in
`CONTINUE_SEMANTIC_REFERENCE.md` §E; the rest were only in the raw log.

| String | file offset | VA |
|---|---|---|
| `load_button\0` | `0x1076b18` | `0x141078318` |
| `continue_button\0` | `0x10c7190` | `0x1410c8990` |
| `LOG_IN_TO_PLAY_FEATURED_RULER\0` | `0x10d8050` | `0x1410d9850` |
| `featured_ruler\0` | `0x10d1ccf` | `0x1410d34cf` |
| `bronzeman\0` | `0x10c8a51` | `0x1410ca251` |
| `CORRUPT` | `0x1005425` | `0x141006c25` |

## 9. Continue-frontend xref disassembly set — from disasm fragment
Source: `chat_fragment_disasm_v4v5_continue_offsets.txt`. Raw `objdump` of the
Continue/Load frontend xrefs at VA `0x1407bf650`, `0x1407bfa20`, `0x1407bfb20`,
`0x1407bd550`, `0x1407be200` (each a ~0x1c0-B window). Also cross-referenced in
`CONTINUE_SEMANTIC_REFERENCE.md` §E. The `objdump` byte-dump itself is
reproducible from `CK2game333.exe` and need not be preserved verbatim.

---

## How this was verified
For every raw export, all `0x…` addresses, 6–64-hex-char tokens, and mangled
symbols were extracted and tested against the combined corpus
(`01_research_archives/`, `03_analysis/`, `02_handoffs/`, `00_START_HERE/`,
patch maps, CSVs). Rows above are exactly those that appeared in **no** corpus
file, cross-checked for context to ensure they are real facts rather than
objdump line-address noise. The ~3,000 "tokens" in the two disassembly-heavy
fragments that were pure per-instruction byte addresses (reproducible from the
EXE) were intentionally discarded.
