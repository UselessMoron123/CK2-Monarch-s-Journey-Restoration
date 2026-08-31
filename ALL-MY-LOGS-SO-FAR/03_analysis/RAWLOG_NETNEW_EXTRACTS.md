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

## 10. V6-live-debug / V7-Continue chats (torn 2026-08-27)

Sources: dump `latest latest logs/latest latest log1.txt` (572 lines) and
`latest latest log2.txt` (17,752 lines). Most conclusions already live in
Part 4, `V7_RUNTIME_RESULTS.md`, `LATEST_LOGS_ANALYSIS_2026-08-26.md`. Residue
that was only in those exports:

| Fact | Value |
|---|---|
| Attach ASLR base A | `0x00007FF75EF20000` — BPs `+9E5500`, `+9E4970`, `+E64E90`, `+8145EC`, `+DE47C0`, `+DE8BB0`, `+99F540` |
| Attach ASLR base B | `0x00007FF73C980000` — INT3 `+8145EC`, `+9E4970`, `+9E5500`, `+9E678B` (V7 site hit live) |
| Registers at `+8145EC` / `+9E4970` | `RAX`/`R10`/`R11` = `"checksum"`; `RDX` = `"irst_on_top"` |
| D3D9 freeze workaround | `settings.txt` `fullScreen=no` / `borderless=yes` |
| Launch-mode death | `0x406D1388` (`MS_VC_EXCEPTION` / `SetThreadName`) even after ignore range — attach anyway |
| TLS callback BPs | `inputhost.dll` / `windowmanagementapi.dll` / vorbis/ogg — ignore |
| Telemetry / RPC | `prod-telemetry.paradox-interactive.com`; `RPC_S_SERVER_UNAVAILABLE` `000006BA` during load — benign |
| Watcher v2 fail | `CommandNotFoundException` from cwd `C:\Users\UZWERG` + sample `-GameRoot D:\CK2` |
| Llywelyn saves (not uploaded) | `Bronzeman_llywelyn_gwynedd.ck2` 1195.1.1 3,682,972 B; `Gwynedd1195_01_08.ck2` 1195.1.8 3,836,788 B; no feat cache |
| Error ledger | first analysis blamed C17 for feats=0 (**wrong**); claimed Continue symptom changed (**wrong**); wrong-binary killed by preflight (both exes = V6 `f5b7dfd6…`); APPLY_V7.bat documented but missing from `bat/` until this ingest |
| Do not promote | unguarded poke of `0x009e5b8b`; launcher-SQLite as proven |

---

## 11. V8-disproof / V9 chats (torn 2026-08-30, from `last log/`)

### 11.1 The playthrough-activation function and its magic id — **net-new**

Found while walking the eligibility chain inside `last log (for now).txt`
(`arena/01a0534b`, ~line 2150). This address and this constant appear in **no**
pre-existing document in the repo; the only other occurrence of `0x14080F370`
anywhere is as an address constant inside `05_patches_and_scripts/py/disasm18.py`.

```text
VA 0x14080F370 (raw 0x0080E770)   ; reached only through a vtable — no direct E8 callers
  +0x22  call 0x1400AF050              ; the 0x68-byte singleton (defaults +0x61=1, +0x63=1)
  +0x27  mov  rdx, [rip+0xED472A]      ; global object
  +0x2E  mov  rdi, rax
  +0x31  mov  rcx, [rdx+0x1C0]
  +0x38  call 0x140DA68F0              ; global,[global+0x1c0] → al
  +0x3D  cmp  ebx, 0x17A36D62          ; MAGIC ID = 396,936,034
  +0x43  mov  byte ptr [rdi+0x65], al  ; singleton+0x65 = "tracking enabled"
  +0x46  mov  rbx, [rsp+0x30]
  +0x4B  sete cl
  +0x4E  mov  byte ptr [rdi+0x63], cl  ; singleton+0x63 = (id == 0x17A36D62)
  +0x51  mov  rax, [rsi+0x30]
  +0x5A  mov  byte ptr [rax], 1        ; "ran once"
```

`ebx` = `[[rsi+0x28]+0x18]` — the current playthrough's id. Both `+0x65` (must be
non-zero for `CalcShouldTrackFeatProgress` to pass its singleton check) and `+0x63`
(must be non-zero for the final gate `0x1400AF690` to return true) are written **here,
from one comparison**. `+0x63` defaults to 1, so this function is the only thing that
can *clear* it. That makes it the strongest remaining candidate for a cold-load
"special-event match is lost" mechanism — and the reason V9 replaces the gate *call*
rather than trying to repair the flag.

`0x17A36D62` is unexplained. Not verified as any particular hash — do not assert.

### 11.2 Feat-cache states (net-new rows)

| Capture | `user_id` | `established` | `conquerer_from_bribir` | `category` | Extra |
|---|---|---|---|---|---|
| pasted 2026-08-29 (no-repo chat) | `1179784490` | 4 | 1 | `-1991027533` | all other 31 feats 0 |
| enumerated 29.08 16:19:51 | `84696387` | 3 | 1 | `-852858316` | file SHA-256 `3606E210F48EB16B668B06E24942B545E65B11531F28F28D08FF9FDDE404601F` |
| enumerated 29.08 20:32:18 | `84696387` | 3 | 1 | `-852858316` | `Length 751` |
| pasted blocks (other run) | `1148909174` | 4 / 2 | 1 | `-1991027533` / `1474319405` | two states |

All carry `key = id = -2128831035` (FNV-1a 32-bit offset basis). Together with the two
already-archived captures (`453496064`, `84696387`) that is **four distinct `user_id`
values for one logical cache file** → `CONTRADICTIONS.md` §12.

Also net-new: the GameSparks `Roaming` folder `E349414h9BDm` did **not** reappear after
the failed V8 run (so the offline/online identity split is not what moved the cache).

### 11.3 Save inventory (net-new)

Ten Pavao/Croatia saves on the user machine, all with
`global_conquerer_from_bribir=1.000`; `global_established` = 2.000 (×3), 3.000 (×5),
4.000 (×2). Full table with sizes and timestamps in Part 5 §C4. Key inference: the
save stores the **current** value, the cache stores the **peak** — which is why
`Bronzeman_pavao_croatia.ck2` (day one, `global_established=2.000`) still shows Bronze.

### 11.4 `.bat` flicker — real root cause (net-new)

The earlier explanation (CRLF/LF line endings) is incomplete. `APPLY_CK2_MJ_V8.bat`
line 34 wraps `powershell.exe -Command "…(…)…"` inside a multi-line
`if exist (…) ( … ) else ( … )` block; cmd.exe ends the block at the first `)` inside
the quoted PowerShell string and terminates before `pause`, so the window closes with
no output. Direct PowerShell works because cmd's parser is out of the path.
Rule: never nest a parenthesised PowerShell command inside a multi-line batch `if`.

### 11.5 The unpatched restore gate (net-new disassembly)

```text
VA 0x1407862E1  call 0x1407B8370        ; IsActiveForPlaythrough
VA 0x1407862E6  test al, al
VA 0x1407862E8  je   0x1407862F7        ; 74 0D at raw 0x007856E8 — STILL 74 0D in V8 and V9
VA 0x1407862F2  call 0x1407B8E60        ; UpdateFeatProgress
```

Byte-pattern xref scan confirms exactly two direct callers of `UpdateFeatProgress`:
raw `0x666550` (daily) and raw `0x7856F2` (restore). The clean trace showed
`RESTORE_GATE al=1` on both warm and cold loads, so this gate was **not** the cold-load
blocker and was correctly left alone.

### 11.6 Debugger facts (net-new)

- Stale saved breakpoints at `CK2game.exe+9E4970`, `+9E5500`, `+9E678B`
  (`0x7FF7B78C4970` / `…5500` / `…678B` over base `0x7FF7B6EE0000`) produced huge
  register dumps with `R10 = "hethum_armenia"` / `"pavao_croatia"` — payload ruler
  keys in memory, not feat-path evidence.
- x64dbg disabled the `+9E678B` breakpoint with *"bytes do not match — expected
  `75 2F`, got `EB 2F`"* → **live in-memory proof that the V7 Continue patch was
  present** in the running process (that site is raw `0x009E5B8B`).
- x64dbg database: `C:\Users\UZWERG\Desktop\x64 dbg\release\x64\db\CK2game.exe.dd64`,
  loaded in 1703 ms. `0x406D1388` thread-name exception at launch is benign.
- **`DAILY_GATE` is armed at `+666146`, i.e. raw `0x665546`, not the patched
  `je` at raw `0x666546` (`+667146`)** — a `666146`-vs-`667146` typo in the trace
  script. The bytes at raw `0x665545` are `48 89 BD 48 06 00 00`
  (`mov qword ptr [rbp+0x648], rdi`, VA `0x140666145`), so the breakpoint is byte 2 of
  a 7-byte instruction inside a *different* function (region A, VA ≈ `0x140665EF8`)
  that the xref scan proved does **not** call `UpdateFeatProgress`. The logged
  `al=A0` / `al=80` are therefore pointer bytes. Consequence: the trace proves
  `UpdateFeatProgress` was entered, but **not** by the daily caller and **not** via the
  patched byte. See `CONTRADICTIONS.md` §13. The canonical
  `MJ_V9_CLEAN_TRACE.txt` was corrected and re-hashed on 2026-08-31; historical
  traces remain evidence of the typo.
- **`RESTORE_GATE al=1` on the cold burst** (log line 498, `rip=00007FF7B76662E8`,
  the `je` at raw `0x007856E8` immediately after `test al,al`) ⇒
  `IsActiveForPlaythrough` returned **true** during the cold load at that site, and
  `UPDATE_ENTRY` followed. This refutes the pre-trace claim in
  `another raw log.txt` line 2207 ("Restore gate false and no update entry … the
  direct cold-load blocker") and removes the last justification for patching
  raw `0x007856E8`.
- **`RULER_INFO_CHECK rax=00000222A2B27050 zf=0`** on all four bursts — the same
  non-null pointer warm and cold, so the ruler-info slot is not the difference.

### 11.0 The orchestrating session (`organisation log.txt`, `79d6007f`) — session transcript

`organisation log.txt` is the transcript of the **orchestrating session**
`arena/01a053d9` that created the v7 rulebook, Part 5, the V9 docs and merged
PR #17. It carries no hard facts that are not already in the archive (it *is*
the source of them), so nothing here is extracted as net-new; it is ledgered for
provenance in `12_raw_chat_logs/INDEX.md` and `DISSECTION_REPORT_2026-08-30.md`
and should not be re-archived.

### 11.7 Repository events (net-new)

| PR | Branch | Commit | Merge | Notes |
|---|---|---|---|---|
| #13 | `arena/01a04980-…` | — | `96ba84b` | landed the `01a044b2` patch; hash chain re-verified |
| #14 | `arena/01a049a4-…` | `ab07419` | `910234875decd988ce55ed95e2401ce0f8c1b02a` | `NEXT_SESSION_HANDOFF_2026-08-29.md` |
| #15 | `arena/01a04d46-…` | — | `f29287217b300be83a0c6334ccddc9a780bd5092` | **squash** merge; clean-trace helper |
| #16 | `arena/01a0534b-…` | — | `d2f61bb9b6a57abc724a8b27c53861f730324031` | **the V9 PR** — "V9: fix cold-load feat reset via feature-eligibility gate force"; 41 files, +2016/−6; patch chain (`patch_ck2_mj_v9.ps1`, APPLY/CHECK/REVERT bats), `MJ_V9_CLEAN_TRACE` x64dbg helper, `build_v9_chain.py`, `V9_COLD_LOAD_FEATS_FIX.md`, handoff, STATUS→V9; merged 2026-08-30 16:38 UTC by the V9 session itself (verified from `last log (for now).txt` + GitHub, 2026-08-31) |
| #17 | `arena/01a053d9-…` | — | `1fd74b558b8949ea99e7ebd918bf4f1b71f2f9c4` | "Consolidate organizing prompts to v7, dissect `last log/`, record V9 as proven baseline"; 26 files, +2426/−773; merged 2026-08-30 19:01 UTC |

Session branch ids seen in `last log/`: `arena/01a044b2`, `arena/01a04980`,
`arena/01a049a4`, `arena/01a04d46`, `arena/01a0534b` (+ the orchestrating
`arena/01a053d9`). The earlier PR request from
`arena/01a044b2` was **rejected by the service** (no branch to push to), which is why
`arena/01a04980` re-did the landing. (PR #16 was missing from the first pass of this
table and was added 2026-08-31 during the `last log/` pre-deletion verification.)

### 11.9 — Second-pass recovery (2026-08-30): what the §11 sweep missed

A re-read of the raw exports looking specifically for **"things that aren't
needed"** — dead ends, redundant artifacts, abandoned approaches — recovered
material the original sweep did not capture. All of it now lives in
`V9_DESIGN_ALTERNATIVES_AND_V8_DEPENDENCY.md` and `11_git_patch/README_GIT_PATCH.md`.

| Item | Source | Was it in the archive? |
|---|---|---|
| **V8's `0x007B786B` byte is mandatory in the shipped V9** — reverting it makes the V9 byte unreachable, so the fix silently stops working | `last log (for now).txt:2963` | ❌ No. Archive said only that V9 "keeps V8's bypasses … for the record", never that one of them is load-bearing |
| **Abandoned alternative V9 design at raw `0x007B785B`** (`74 07`→`90 90`, the flag gate), under which V8's `0x007B786B` byte *would* be dead code | `last log (for now).txt` — **~40 occurrences** (lines 417, 2293, 2778–2809, 3439–3720, 4281, 4415) | ❌ No. `7b785b` had **zero** archive hits despite appearing ~40 times in the source |
| `0x14080F370` writes singleton `+0x63 = (id == 0x17A36D62)` and `+0x65 = al`; no direct callers (vtable dispatch); **not** the cold gate | `last log (for now).txt:4120` | 🟡 Half. The constant `0x17A36D62` survived in Part 5 §B2, but the **function address existed only inside the scratch script `py/disasm18.py`** and in no document |
| The four `11_git_patch/*.patch` files are **redundant turn-end captures** whose changes are already committed | `another other raw log.txt:228,242,292,394,429` | ❌ No. Folder had no README; re-verified 2026-08-30, all four fail `git apply --check` |
| **V8's first edit resurrects a banned patch.** `0x00666546: 74 0d→90 90` is byte-identical to the banned "V7 feat-update" candidate's first edit, whose precondition ("reproducible fresh-campaign failure") was never met | `BANNED_ARTIFACTS.md` §B1 vs V8 patch table | ❌ No cross-reference existed; the ban is vindicated by V8's disproof, not overturned |
| Region raw `0x665600`+ is data/padding; `call qword ptr [rax+0x388d8d48]` there is mid-instruction junk from a misaligned linear sweep | `last log (for now).txt:1467` | ❌ No. Same failure mode as `CONTRADICTIONS.md` §13 (mis-armed `DAILY_GATE`) |

**Methodology correction for future sweeps.** The §11 "How this was verified"
note claims every `0x…` token absent from the corpus was listed. That did not
hold:

- `0x7B785B` appeared ~40 times in the source and was **not** listed — a
  6-hex-digit address is easy to lose among the per-instruction byte noise the
  sweep deliberately discarded.
- `0x14080F370` was suppressed because it "matched" the corpus — but its only
  match was the scratch script `py/disasm18.py`, not a document.

**Rule going forward:** treat `05_patches_and_scripts/py/disasm*.py` as
*scratch*, not corpus. A fact that exists only inside a scratch script is
**unarchived** — scratch scripts get pruned, documents do not.

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
