# CK2 2.6.1.1 debug files — identity and provenance

Analysis of `debug files/` in this repository. All originals were treated read-only;
extraction/conversion was done on scratch copies. Analysis tooling: custom offline
MSF-7/PDB + PE parsers (Python), GNU objdump for read-only disassembly annotation.
No third-party symbol files were downloaded; no network symbol servers were used.

> Note on naming: the handoff describes "2.6.1.1 debug files". The evidence below
> **confirms** the `ck2game` pair as the CK2 **2.6.1.1** Windows/Steam build
> (2016-08-30, Reaper's Due era, not 2014). `ck2.pdb` is an *earlier* live-branch
> build (2016-06-01, pre-Continue-frontend).

## 1. File inventory

| relative path | size (bytes) | SHA-256 | detected format |
|---|---|---|---|
| `debug files/CK2game.exe` | 16,535,040 | `ec4ea0393ef1f8f835d2594dd7e1249ebe850a31688dae56c94c875a0748e5a6` | PE32 (x86) EXE, "MZ", 5 sections |
| `debug files/ck2.part1.rar` | 25,165,824 | `7e47fcfea055e5cb16b4490a93a7b7a1d09a20819e6507172c238201ec12bbda` | RAR5 multi-volume archive (part 1) |
| `debug files/ck2.part2.rar` | 25,165,824 | `32ef4568e09822a5b630ff041126ce69dae3cb702217765d5b3e1909bfbd2aaa` | RAR5 (part 2) |
| `debug files/ck2.part3.rar` | 14,438,896 | `6306a0d08da2e43ca5221413090c6a604113dfcbe115646dd2084e7303f943b3` | RAR5 (part 3, split-before flag) |
| `debug files/ck2game.part1.rar` | 25,165,824 | `4dee57896fe5cf9d9d3bb5c22290ac8c7f494062a02dc3f90767fb8c08a293e8` | RAR5 (part 1) |
| `debug files/ck2game.part2.rar` | 25,165,824 | `77ab8e662fb500d334f5d8377bc81fd10a82ef49d9199c020a9224ba696a269e` | RAR5 (part 2) |
| `debug files/ck2game.part3.rar` | 16,674,312 | `5a3eae8b30589fcba4bb9c2b9ec24d7ec762b39d67d81485924382be0c3c21b1` | RAR5 (part 3, split-before flag) |
| `debug files/dbghelp.dll` | 986,112 | `cf2647be9233f4a7248514cbd2541d5f7bebd61005bde1dca79c8e4234f53794` | PE32 (x86) DLL |

No duplicate PDB copies; exactly one PDB per archive set. No `.map/.dbg/.sym`
files were included in the drop.

### Extracted archive contents (CRC-verified by UnRAR during extraction)

| archive | member | size | SHA-256 |
|---|---|---|---|
| `ck2.part1-3.rar` | `ck2.pdb` | 64,770,048 | `ffe81233234846861733c8ffe04010553ca1c0b69c7eeb9246f03cd02c5206a9` |
| `ck2game.part1-3.rar` | `ck2game.pdb` | 67,005,440 | `90ade46ce95f318c966b1619f76d88c7931364e020c9f0bf1a005526cc466bd1` |

## 2. Executable identity (supplied `CK2game.exe`)

- PE machine **0x014C (I386, 32-bit x86)**, 5 sections
  (`.text` VA 0x401000 size 0xD119AD; `.rdata` 0x1113000; `.data` 0x12CF000;
  `.rsrc` 0x1A71000; `.reloc` 0x1A78000), image base 0x400000.
- PE timestamp **0x57C53AC6 = 2016-08-30 07:50:30 UTC**.
- Debug directory: one **CodeView RSDS** entry:
  - PDB path: `C:\jenkins\workspace\CK2-Live-R-Steam-Windows\ck2\game\CK2game.pdb`
  - GUID **DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6**, age **1**
- Game version string **"2.6.1.1"** is embedded in the binary (in the
  version-block region used by save files), and
  `CSaveGameModel::GetVersionStatus` compares against `"2.6.1.1"` with a
  `"2.1.0.0"` cutoff. The RSDS path's Jenkins job (`CK2-Live-R-Steam-Windows`)
  identifies it as the Steam Windows live/release-branch build.
- `dbghelp.dll`: Microsoft Debugging Tools for Windows build **6.4.0007.1**
  (vbl_core(jshay).050105-2304, 2005-01-12) — a VS2005-era `dbghelp`
  redistributable shipped beside the PDBs for symbol loading.

## 3. PDB identity

| property | `ck2game.pdb` | `ck2.pdb` |
|---|---|---|
| Container | MSF 7.00, block size 1024 | MSF 7.00, block size 4096 |
| Streams | 1261 | 1231 |
| impv (PDB version) | 20000404 (VC 7.0) | 20000404 (VC 7.0) |
| signature | 0x57C53AC6 (**= 2016-08-30**) | 0x560D4FCC (**= 2016-06-01**) |
| age | **1** | 4 |
| GUID | **DC5E6265-72D6-44D9-B181-5EFB6CDCA6E6** | 504A2C03-5D49-4887-88E9-E093B4140491 |
| DBI version | 19990903 | 19990903 |
| machine | x86 (I386) | x86 (I386) |
| modules | 1257 (stripped=No) | 1226 (stripped=No) |
| type records (TPI) | 284,334 (TI 0x1000–0x466AE) | 291,858 (TI 0x1000–0x48412) |
| named streams | `/LinkInfo`, `/names`, `/src/headerblock` | same + **`srcsrv`** |
| srcsrv | — (absent) | Subversion indexing: `http://svn-prod-01/svn/clausewitz/tags/CK2_live_steam_build/...` rev **9685**, srcsrv ini dated 2015-10-02 |
| toolchain (compilands) | Microsoft C/C++ Optimizing Compiler **cl 16.00.40219.1 (VS2010 SP1)** — 539 C++ TUs; a few 16.00.30319.1 (VS2010 RTM) modules; built under `CMAKE_BUILD_VS10` | same |

Both PDBs reference object paths under
`c:\jenkins\workspace\CK2-Live-R-Steam-Windows\ck2\CMAKE_BUILD_VS10\source\...`
(i.e. the same CMake/VS2010 build tree; normalised to `<buildroot>` in all
reports here).

## 4. PDB ↔ EXE identity verdict

- **`ck2game.pdb` ↔ supplied `CK2game.exe`: EXACT MATCH.** GUID and age are equal
  (`DC5E6265-…-A6E6`, age 1) and PDB signature equals the EXE's PE timestamp
  (0x57C53AC6). RVAs computed from this PDB **are** valid for the supplied
  2.6.1.1 binary. The embedded version string and build date make this the
  CK2 **2.6.1.1** (Reaper's Due era, live Steam win32 branch) build.
- **`ck2.pdb` ↔ supplied `CK2game.exe`: MISMATCH** (GUID/age/signature differ).
  No executable matching ck2.pdb's GUID was supplied → its address-space facts
  are **unverifiable**; treat it as an historical inventory only. Its content is
  a *2016-06-01 live-branch build* of the same tree (feature-leaner frontend —
  see `TYPE_AND_VTABLE_NOTES.md` §6).

## 5. Limitations and confidence

- **High confidence**: identities above are byte-level facts (RSDS/GUID/age/timestamps).
- The PDBs predate Monarch's Journey (2019/Q4, CK2 3.3.0): no GameSparks,
  `CNullGameSpark`, `CHighlightedRuler`, Feat/Reward/Bronzeman symbols exist in
  them (see `SEARCH_RESULTS.md`).
- 2.6.1.1 RVAs/offsets/vtable slots are **facts only for the matched 2.6.1.1
  EXE**; they must never be applied to any other build (3.3.x included).
- The matching proof means the supplied 2.6.1.1 EXE + PDB pair can be used as a
  fully-symbolised reference corpus for cross-version hypothesis building, which
  is exactly how the notes in this folder use them.
