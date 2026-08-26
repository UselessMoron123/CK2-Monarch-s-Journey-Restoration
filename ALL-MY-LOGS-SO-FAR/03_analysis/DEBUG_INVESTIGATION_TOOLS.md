# Debug Files Investigation — Tooling and Scratch Artifacts

**Source:** `logs to dissect.../Новый текстовый документ (6).txt` (3,491 lines, 497,212 B) — the large debug-files investigation transcript.

## What was investigated

`10_binary_artifacts/debug_files/` folder (the materialized debug drop; hashes in `IDENTITY.md`):

| File | Size | SHA-256 | Format |
|---|---|---|---|
| `CK2game.exe` | 16,535,040 | `ec4ea0393ef1f8f835d2594dd7e1249ebe850a31688dae56c94c875a0748e5a6` | PE32 x86, 5 sections, timestamp 0x57C53AC6 = 2016-08-30 07:50:30 UTC |
| `ck2.part1.rar` | 25,165,824 | `7e47fcfea055e5cb16b4490a93a7b7a1d09a20819e6507172c238201ec12bbda` | RAR5 part 1 |
| `ck2.part2.rar` | 25,165,824 | `32ef4568e09822a5b630ff041126ce69dae3cb702217765d5b3e1909bfbd2aaa` | RAR5 part 2 |
| `ck2.part3.rar` | 14,438,896 | `6306a0d08da2e43ca5221413090c6a604113dfcbe115646dd2084e7303f943b3` | RAR5 part 3 |
| `ck2game.part1.rar` | 25,165,824 | `4dee57896fe5cf9d9d3bb5c22290ac8c7f494062a02dc3f90767fb8c08a293e8` | RAR5 part 1 |
| `ck2game.part2.rar` | 25,165,824 | `77ab8e662fb500d334f5d8377bc81fd10a82ef49d9199c020a9224ba696a269e` | RAR5 part 2 |
| `ck2game.part3.rar` | 16,674,312 | `5a3eae8b30589fcba4bb9c2b9ec24d7ec762b39d67d81485924382be0c3c21b1` | RAR5 part 3 |
| `dbghelp.dll` | 986,112 | `cf2647be9233f4a7248514cbd2541d5f7bebd61005bde1dca79c8e4234f53794` | PE32 DLL, dbghelp 6.4.0007.1 |

Extracted (CRC-verified via UnRAR):

- `ck2.pdb` 64,770,048 B SHA `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` — MSF 7.00 block 4096, 1231 streams, sig 0x560D4FCC = 2016-06-01, GUID `504A2C03-5D49-4887-88E9-E093B4140491`, age 4, srcsrv rev 9685, **mismatch** with supplied EXE
- `ck2game.pdb` 67,005,440 B SHA `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` — MSF 7.00 block 1024, 1261 streams, sig 0x57C53AC6 = 2016-08-30, GUID `DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6`, age 1, **exact match** with EXE

## Tooling used (scratch only, not committed to organized repo per spec)

Sandbox constraints: Python 3.11, gcc/g++/make present, apt blocked, network = PyPI + files.pythonhosted.org only, no 7z/unrar/bsdtar, no llvm-pdbutil, PEP-668 blocks system pip → venv.

**Custom offline parsers (Python, in `/home/user/scratch/tools/`):**

- `msf.py` — MSF 7.00 container, superblock, block map, directory, streams
- `pe.py` — PE headers, sections, timestamp, ImageBase, IMAGE_DIRECTORY_ENTRY_DEBUG → CodeView RSDS/NB10 (GUID/age/PDB path)
- `msvc_demangle.py` — MSVC mangling, 99.7% coverage of 64,653 mangled publics (handles `?`, `??_7` vftable, `??_R` RTTI, `??_C` strings, ctors/dtors, operators, templates `?$`, back-refs)
- `symdump.py` — all module symbol streams + global symrec → TSV (module, kind, name, seg:off, len, type)
- `tpi.py` — TPI stream (16-17 MB), type records, fieldlists (handles LF_PADx, LF_VFUNCOFF quirks), UDT inventory
- `classdump.py` — class layouts from TPI fieldlists + methodlists, JSON
- `search.py` — search groups from handoff (continue, savegame, ironman, cloud, frontend, gamestate, bronze, feat, reward, etc.)
- `make_csv.py` — filtered CSV, category/demangled/mangled/kind/module/address/notes, RVAs only for verified pair

**Disasm helpers (in `/home/user/scratch/disasm/`):**

- `xref.py` — direct-call xref scanner via `.pdata` + capstone
- `vtables.py` — binary vtable dump with symbol resolution
- `andis.py` — annotated disassembler (adds string refs, e.g. "save games", ".ck2", "meta", error strings)
- Annotated outputs: `continue_chain.annotated.txt` (2.4K lines), `key_vtables.log`

**RAR extraction:** unrar-cffi abi3 wheel from PyPI (`/home/user/scratch/unrar_wheel`), `cffi` dependency, in-process extraction with callback (handles multi-volume RAR5 seamlessly)

**Counts (ck2game.pdb):** 1,257 modules, 32,175 GPROC32 + 15,906 LPROC32 + 68,164 PUB32, 62,152 LDATA + 2,057 GDATA, 13,937 CONSTANT, locals (68K BPREL32 etc.), C13 LINES 43,055 in 1,041 modules, 284,334 TPI records, 13,364 defined types. ck2.pdb similar (1,226 modules, 291,858 type records).

## Deliverables produced (now in `03_analysis/`)

- `IDENTITY.md` — file inventory + verdicts (exact match vs mismatch) + limitations
- `SYMBOL_SUMMARY.md` — counts, presence of lines/locals/types, class inventory, subsystem taxonomy from source dirs, richness assessment, ck2 vs ck2game diff
- `SEARCH_RESULTS.md` — curated hits per group + absence table (bronze/feats/GameSparks/Titus/highlighted-ruler absent in 2016 builds)
- `TYPE_AND_VTABLE_NOTES.md` — class dumps (CIronmanSaveSelect size 0x290, fields `_bIsContinueSaveValid @ +0x23D`, etc., methods, decision flow pseudocode for GetContinueSave/UpdateContinueData/IsValidSave/RefreshContinueButton/OnContinue/ContinueOnStartup, enable propagation via `CButton::Enable` vtbl+0xDC / Disable +0xE0, meta/compat checks, cross-build drift)
- `SYMBOLS_FILTERED.csv` — 5,357 curated rows, mangled retained, RVA only for ck2game pair

**Method note:** Feature chronology discovered: CIronmanSaveSelect in ck2.pdb (June 2016) size 0x1F4, 48 members, NO Continue machinery — Continue machinery added between June 1 and Aug 30 2016 (Reaper's Due cycle). Bronze/bronzeman/feat/reward/challenge/Titus/GameSparks ALL ABSENT in 2016 builds.

## For restoration project repo migration

- The debug drop is retained in `10_binary_artifacts/debug_files/`, with extracted
  PDBs under `pdb/` and the original RAR volumes under `rar_volumes/`.
- Scratch tooling (`msf.py` etc.) is not needed in the organized repo — keep only
  the verified binary inputs and durable analysis deliverables.
- If restoration repo has old logs already dissected here, check `12_raw_chat_logs/INDEX.md` for overlap.
