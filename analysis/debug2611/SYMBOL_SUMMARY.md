# CK2 2.6.x debug PDBs — symbol & type inventory summary

Two PDBs analysed. `ck2game.pdb` is the exact-match symbol file for the supplied
CK2 **2.6.1.1** `CK2game.exe` (see `IDENTITY.md`). `ck2.pdb` is an earlier
live-branch build (2016-06-01) with no matching EXE. Both are **full `/Zi`
PDBs** (not public-symbol-only, not stripped).

## 1. Symbol counts

| record kind (code) | ck2game.pdb (2.6.1.1) | ck2.pdb (2016-06-01) |
|---|---:|---:|
| Global functions `S_GPROC32` | 32,175 | 28,776 |
| Static/local functions `S_LPROC32` | 15,906 | 14,668 |
| **Total out-of-line functions** | **48,081** | **43,444** |
| Public symbols `S_PUB32` (linker publics; mangled) | 68,164 (64,653 mangled) | 61,794 |
| Global/thread data `S_(G)LDATA32`,`GTHREAD32` | 62,152 LDATA + 2,057 GDATA | 56,641 LDATA + 1,790 GDATA |
| Local variables (`S_BPREL32`+`S_REGREL32`+`S_REGISTER`+`S_LOCAL`) | 68,150 + 5,901 + 28,624 + 2,706 | 60,713 + 4,845 + 26,147 + 2,698 |
| Enum/const records `S_CONSTANT` | 13,937 | 13,680 |
| UDT name records `S_UDT` | 4,018 | 4,246 |
| Labels/blocks/thunks/callsite/etc. | 190k misc | 178k misc |
| Source-line (C13 LINES) subsections | 43,055 across 1,041 modules | 38,884 across 1,012 modules |
| Static CRT/SDK exports records | 584 | 584 |

Demangling: a custom MSVC demangler handled **99.7 %** of the 64,653 mangled
public symbols of ck2game.pdb (failures are all exotic std::/boost template
monsters; their mangled text is retained in the CSV).

## 2. Type information (TPI stream)

ck2game.pdb: **284,334 type records** (ck2.pdb: 291,858) including:

| record family | count (ck2game) |
|---|---:|
| LF_CLASS definitions+declarations | 21,411 |
| LF_STRUCTURE | 9,426 |
| LF_UNION / LF_ENUM | 119 / 1,697 |
| LF_FIELDLIST (member lists with offsets) | 12,932 |
| LF_MFUNCTION (full method signatures) | 126,691 |
| LF_POINTER / LF_MODIFIER / LF_PROCEDURE / LF_ARGLIST… | balance |
| LF_VTSHAPE | 79 |

**13,364 distinct named types have full definitions** (12,414 in ck2.pdb),
including definitions for all Clausewitz engine and CK2 game classes touched by
this investigation. Class fields with offsets, base classes (incl. virtual
bases), full method signatures, and per-class introduced-virtual lists are all
recoverable, as are plain function signatures for every GPROC/LPROC.

Also present: **line tables** (per-module C13 LINES + FILECHKSMS for 1,041
modules), **local variables and register/stack frame info** (S_BPREL32,
S_REGREL32, S_LOCAL + DEFRANGE records), **frame pointers/SEH unwind**
(FRAMEPROC 48k), and per-function debug begin/end markers. This is the richest
usable class of PDB — essentially full source-level debug info minus source
bodies.

## 3. Source-file taxonomy

1,010 distinct source directories referenced in ck2game.pdb (1,061 in ck2.pdb),
with ~293k file references across 1,257 modules (ck2game.pdb). Layout (all paths
normalised; builder prefix replaced by `<buildroot>`):

- **Game code**: `<buildroot>\ck2\CMAKE_BUILD_VS10\source\CK2.dir\Release\*.obj`
  — the CK2 game itself (`frontend`, `frontendview`, `frontendcommands`,
  `frontendmultiplayerview`, `frontendsettings`, `savegameinterfaces`,
  `gamestate`, `gamestatecommands`, `gamesetup`, `loadscreen`, `ck_application`,
  ~1,100 more).
- **Engine**: `<buildroot>\clausewitzii\*` — Clausewitz-II engine split into
  static libs: `clausewitzlib` (core containers/file/lexer/persistent/GUI,
  7,477 file refs under `graphics\` alone), `pdx_core` (fixed point, strings,
  VFS/files), `pdx_gfx`, `pdx_achievements`, `pdx_cloudstorage`
  (Steam Remote Storage wrapper), `pdx_math`, etc.
- **Third-party**: `<buildroot-libs>\external_libs\*` (a builder-machine library root) (~158k refs: boost, Lua,
  luabind, SDL, EMotionFX, PhysFS, curl, libzip, miniz, ogre?, Eigen, etc.),
  MSVC10 CRT/SDK (`dd\vctools\crt_bld`, `program files (x86)\microsoft sdks\*`).
- One personal dev path appears: `c:\users\henrik\documents\...` (~2k file refs;
  normalised as `<user>` in dumps).

The taxonomy is directly reusable for later-version string matching: leaked
assert paths such as `..\..\source\savegameinterfaces.cpp`, `frontend.cpp`,
`gamestate.cpp`, `ironman`/`save` flows name the same translation units in
2.6.1.1 and later builds.

## 4. Demangled class/namespace inventory (top-level shape)

13,364 defined type names. Largest root namespaces/classes (by census of
defined types and GPROC/LPROC methods):

- ~2,600 defined `C*` gameplay/engine classes (CCharacter, CGameState,
  CFrontEnd*, CInGameIdler, CEU3Idler, CWar, CEvent*, CTrigger/CEffect
  families, C*Interaction diplomacy classes, CSiege&combat, CAI*, CBookmark*,
  CDLCManager, CMetaserver* …).
- Frontend/GUI layer: `CFrontEnd`, `CFrontEndState`, `CFrontEndView`,
  `CHistorySelect...`, `CCharacterSelectionView`, `CPickEraScreen`,
  `CGameSetup`, **`CIronmanSaveSelect`**, `CSaveGameModel`,
  `CSaveGameItemBase`, `CLoadGame`, `CContinueFailedDialog`, `CGuiObject`,
  `CFixedWindow`, `TButton`, `CButton`, `C*ObserverGlue` binding templates.
- Engine subsystems: `ClausewitzII.lib`-hosted CGuiObject/CGuiType GUI
  primitives, CFile/CArchiveFile/CMemoryFile/CZipArchive, CLexer/CReader,
  cloud (`SCloudStorageContext`, `SCloudFile`, `CCloudStorage...`), achievements
  manager, EU3-inherited idler/state classes.
- STL (VS2010 flavour), boost 1.5x, EMotionFX, SDL2-era, Lua 5.1x, Eigen —
  all present as fully type-annotated third-party code.

Notable for feature chronology: **zero** hits for `bronze`, `bronzeman`,
`reward`, `challenge`, `titus`, `gamespark`, `highlighted ruler` —
see `SEARCH_RESULTS.md` for the complete negative/positive evidence table.

## 5. Is this material rich enough for cross-version analysis?

**Yes — exceptionally so.** This is a full public+private symbol/type/line/local
PDB for an exact-match 2.6.1.1 binary. It can:

- name and fully type ~48k functions and ~62k data objects in 2.6.1.1;
- document **exact** 2.6.1.1 algorithms from annotated disassembly (address
  validation is possible because the PDB is an exact match);
- provide *semantic* anchors (class/member/function/source-file names) that
  survive into 3.3.x builds as hypotheses, to be confirmed against the newer
  stripped binaries' string tables and call patterns;
- but **cannot** provide any 2020-era address, offset, or vtable index; all such
  numbers here are 2.6.1.1-only.

`ck2.pdb` offers the same for a June-2016 build and additionally carries srcsrv
SVN indexing (`clausewitz/tags/CK2_live_steam_build` rev 9685) — useful
provenance, but no symbol addresses may be trusted from it (no matched EXE).
