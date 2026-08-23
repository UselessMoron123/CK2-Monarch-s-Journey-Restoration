# CK2 2.6.x debug PDBs — search results

Case-insensitive searches across: (a) all module-stream symbol names
(functions/data, plain names), (b) all demangled publics, (c) all defined type
names, (d) all source-file paths, (e) leaked string constants. Counts are given
for both PDBs. **Addresses (VA = image-base-absolute RVA for the 32-bit build)
are reported only for `ck2game.pdb`**, whose GUID/age verifiably match the
supplied 2.6.1.1 `CK2game.exe`. They are **2.6.1.1 facts only** — never
transferable to 3.3.x.

Legend: `GPROC/LPROC` = module-stream function records (plain source names,
with full type info in TPI); `PUB32` = linker public (mangled, demangled here;
99.7 % demangle coverage — see `SYMBOLS_FILTERED.csv` for the machine-readable
table, which includes the original mangled names).

## Group 1 — save/load and "Continue"

### 1a. The Continue decision chain (2.6.1.1, EXE-matched)

| VA (2.6.1.1 only) | kind | module (source obj) | name |
|---|---|---|---|
| `0x0099F540` | GPROC | `main.obj` | `` `anonymous namespace'::GetContinueSave(CDLCManager*) `` (launcher-side pre-scan helper) |
| `0x004B7430` | GPROC | `character.obj` | `CGameState::GetSaveGameVersion()` |
| `0x00AC7160` | GPROC/PUB32 | `savegameinterfaces.obj` | `static CString CIronmanSaveSelect::GetContinueSave(bool, CloudStorageContextCLOUDSTORAGE**, CDLCManager*)` |
| `0x00AC7770` | GPROC/PUB32 | `savegameinterfaces.obj` | `void CIronmanSaveSelect::UpdateContinueData(const CString*)` |
| `0x00AC6D80` | GPROC/PUB32 | `savegameinterfaces.obj` | `bool CIronmanSaveSelect::UpdateIronmanAndCharForContinue(CFile*)` |
| `0x00AC9BF0` | GPROC/PUB32 | `savegameinterfaces.obj` | `void CIronmanSaveSelect::RefreshContinueButton()` |
| `0x00AC9CC0` | GPROC | `savegameinterfaces.obj` | `void CIronmanSaveSelect::RefreshLoadButton()` |
| `0x00AC8D00` | GPROC/PUB32 | `savegameinterfaces.obj` | `void CIronmanSaveSelect::ContinueOnStartup(const CString&)` |
| `0x00AC8E00` | GPROC/PUB32 | `savegameinterfaces.obj` | `void CIronmanSaveSelect::OnContinue()` |
| `0x00AC70A0` | LPROC | `savegameinterfaces.obj` | `` anonymous-namespace `IsValidSave(const CSaveGameModel*, CDLCManager*)` `` |
| `0x00AC0ED0` | GPROC | `savegameinterfaces.obj` | `CSaveGameModel::CSaveGameModel(const CString&, const CString&, CloudFileCLOUDSTORAGE*, bool)` |
| `0x00AC22B0` | GPROC | `savegameinterfaces.obj` | `void CSaveGameModel::GetVersionStatus()` (contains strings `"2.6.1.1"`, `"2.1.0.0"`, `"UNSUPPORTED_VERSION"`, `"UNSUPPORTED_VERSION_2_1"`) |
| `0x00AC24D0` | GPROC | `savegameinterfaces.obj` | `CSaveGameModel::SetupDataFromFile()` |
| `0x00AC2140` | GPROC | `savegameinterfaces.obj` | `CSaveGameModel::SetupLocalFile()` |
| `0x00AC2060` | GPROC | `savegameinterfaces.obj` | `CSaveGameModel::SetupRemoteFile()` |
| `0x008FD8A0` | GPROC/PUB32 | `frontendview.obj` | `CContinueFailedDialog::CContinueFailedDialog(CFrontEnd*)` (+ `Update` @ `0x00880B30`) |
| `0x00DE47C0` | GPROC/PUB32 | `pdx_launcher.lib` | `CPdxLauncher::UpdateContinueSaveName()` |
| `0x00DE8BB0` | GPROC/PUB32 | `pdx_launcher.lib` | `CPdxLauncherGUI::OnContinue()` |

Direct call-graph edges (found by scanning all direct `call rel32` sites in the
verified 2.6.1.1 `.text`):

```
SDL_main (main.obj @0x0099F690)
  └─ anon::GetContinueSave @0x0099F540        (SteamAPI_Init, SCloudStorageContext boilerplate)
        └─ CIronmanSaveSelect::GetContinueSave @0x00AC7160   [static]

CFrontEndState::Update (frontendview.obj @0x008FF310)
  └─ CIronmanSaveSelect::ContinueOnStartup @0x00AC8D00       (after CHistoryDataBase::ReadProvinceSetup)
        ├─ CIronmanSaveSelect::UpdateContinueData @0x00AC7770
        │     └─ anon::IsValidSave @0x00AC70A0  (per candidate save)
        │     └─ CIronmanSaveSelect::UpdateIronmanAndCharForContinue @0x00AC6D80
        ├─ (mismatch vs gAutoStartSave → new CContinueFailedDialog)
        └─ CIronmanSaveSelect::OnContinue @0x00AC8E00

CIronmanSaveSelect::RefreshContinueButton @0x00AC9BF0
  ← CIronmanSaveSelect::ViewSave; CConfirmSaveDelete::OnAccept
  └─ recomputes via UpdateContinueData(nullptr), then Enable()/Disable() on the "continue" button
```

Save enumeration internals seen in the verified disassembly of
`GetContinueSave`/`UpdateContinueData`: `VFSEnumerateFiles(dir, files, ".ck2", …)`,
`Stable_sort<string>` with comparator `SFileDateSort<std::greater<__int64>>`
(**newest file first**), `PHYSFS_getLastModTime` tie-breaks, `CArchiveFile` /
`CZipArchive` for local files ("meta" zip member probed by name),
`SCloudStorageContext::CountFiles/GetFiles` + `SCloudFile::Read` + `CMemoryFile`
for Steam cloud files. Meaning of "Continue" in 2.6.1.1: **the newest valid
`.ck2` across local `save games` and cloud storage**, where validity is
`anon::IsValidSave` (see `TYPE_AND_VTABLE_NOTES.md` §2) and meta parse of
`version`/`date`/`player`/`ironman`.

### 1b. Other save/load hits (selection)

| term | hits ck2game / ck2 | notable members (2.6.1.1 VAs) |
|---|---|---|
| `savegame` | 186 / 168 | `CGameState::GetSaveGameVersion` `0x004B7430`; `CGameState::WriteSaveGameMetaData(CWriter&)` `0x00937F40`; `CInGameIdler::SaveGameSelect` `0x00883240`; `CInGameIdler::SaveGame` `0x00884150`; `CGameState::SetIronmanFileName` `0x00901980`; `CAchievementsManager::VerifySavegame(CFile*)` `0x00402220`; `CSaveGameStatusUpdateCommand` family @ `gamestatecommands.obj` |
| `save_game` | 4 / 4 | string literals: `save_game.txt` etc. only |
| "save games" (string) | 2 | `??_C@..._save games` — the literal directory name string used by enumeration |
| `loadgame` | 46 / 46 | `CLoadGame`, `CLoadGameStart` classes; `CFrontEndState::LoadGame` @ `0x00900120`; `CIronmanSaveSelect::OnLoad` @ `0x00AC95D0`, `ViewSave` @ `0x00AC44C0`, `Show` @ `0x00AC4280` |
| `load_game` | 3 / 3 | launcher strings |
| `csave` | 186 / 159 | `CSaveGameItemBase`, `CSaveGameModel`, `CSaveGlobalEventTargetAsEffect`, `CSaveEventTargetAsEffect`, `CSaveSuccessionEffect`, `CConfirmSave`, `CConfirmSaveDelete`, `CConfirmLoadOldSave`, `CConfirmLoadOldSaveToConclave` … |
| `cironman` / `ironman` | 112+208 / 84+129 | full `CIronmanSaveSelect` (see type notes), `CGameRulesIronManIndicator`, `CIngameRulesIronManDisplay`, `CIsIronmanTrigger`, `TSavegameItem<CIronmanSaveSelect>`, `CGameState::SetIronmanFileName`, `IronmanMode` globals |
| `alternate_start` | 0 / 0 | **absent** (no alternate-start concept in 2.6.x) |
| `cloud` / `cloudstorage` | 255 / 271 | `pdx_cloudstorage.lib` module: `SCloudStorageContext::{Update,Validate,CountFiles,GetFiles,DeleteFile}`, `SCloudFile::Read`, `CloudStorageGetPublishedContent`, `CloudFileCLOUDSTORAGE`, `CloudStorageContextCLOUDSTORAGE`, Steam UGC callback glue, `CCloudStorageContext` wrappers; `CEU3Idler::ESaveStatusEnum` |

## Group 2 — frontend & GUI

| term | hits ck2game / ck2 | notable members |
|---|---|---|
| `frontend` | 526 / 514 | `CFrontEnd` (~129 methods; `DoSave` @ `0x008E7070`, `DoCloudSave` @ `0x008E7050`, `ShowWelcomeScreen` @ `0x008E8D20`; `ShowContinueFailed`/`LaunchGame` declared but inline-only in this build), `CFrontEndState` machine: `SinglePlayer` @ `0x009000B0`, `OpenTempSinglePlayer` @ `0x00900080`, `LoadGame` @ `0x00900120`, `MultiPlayer` @ `0x00900280`, `Update` @ `0x008FF310`), `CFrontEndView`, `CFrontendMultiplayerView`, `CFrontendSettingsScreen`; sources `frontend.cpp`, `frontendview.cpp`, `frontendcommands.cpp`, `frontendmultiplayerview.cpp`, `frontendsettings.cpp` |
| `mainmenu` / `main_menu` | 7+1 / 7+1 | only strings `mainmenu_panel`, `mainmenu_bottom_panel`, `mainmenu_top_panel` + `CInGameIdler::SetShowingMainMenuConfirm` — **no dedicated CMainMenu class in 2.6.x** (the menu is handled by the frontend state machine + generic GUI panels) |
| `singleplayer` / `single_player` | 6+2 / 6+2 | `CFrontEndState::SinglePlayer()`, `CFrontEndState::OpenTempSinglePlayer()` (`frontendview.obj`), strings `singleplayer`, `Launching SINGLEPLAYER…` |
| `button` | 5,853 / 5,447 | complete GUI stack: `CGuiObject`, `CFixedWindow::GetButton`, `TButton::{Enable,Disable,IsDisabled,SetState,GetState}` (vtable slots 0xDC/0xE0/0xE4 – verified in the matched binary), `CButton::<…>` concrete impls, `CButtonObserverGlue<T>`, `CCheckBox…`, `CButtonMenu…` |
| `enable` / `disabled` | 338+140 / 266+134 | generic enable API: `TButton::SetEnabled` (`buildview.obj` @ `0x00499F30`), `CGuiObject::SetEnableSound`, `CInGameIdler::EnableTopBarButtons`, `CBookmarkEntry::Enable`, plus ~80 diplomacy `C*Interaction::IsInteractionEnabled()` predicates (gameplay, unrelated to frontend enabling) |
| `window` | 2,423 / 2,253 | `CFixedWindow`, `CWindow` primitives, dialogs; exact list curated in CSV |
| `gui` | 2,530 / 2,401 | `CEU3Gui`/`CEU3Dialog`, `CGuiType`, `CGuiObject` families, observer-glue templates |

## Group 3 — game state / serialization

| term | hits ck2game / ck2 | notable |
|---|---|---|
| `gamestate` | 201 / 173 | `CGameState` (gamestate.obj: `SetGamespeed`, `ClearOpenPlayerEvents`, `WriteSaveGameMetaData`, `GetSaveGameVersion`, `CopyGameRulesFromSettings`…), `CCurrentGameState`, `gamestatecommands.obj` command classes |
| `serializer` | 9 / 9 | only EMotionFX's `MCore::AttributeSerializer` registry — **no game-level "serializer" naming in 2.6.x**; save writing is `CWriter`/`CReader`-driven |
| `serialize` | 12 / 12 | `CSerializedCommand` (multiplayer command queue), `CList<CSerializedCommand*>` |
| `deserialize` | 0 / 0 | **absent as a name** (reading is `CReader`/`ReadMember` style) |
| `metadata` | 4 / 3 | `CGameState::WriteSaveGameMetaData(CWriter&)` @ `0x00937F40` (gamestate.obj) — the meta-writer; plus two Steam SDK constants |
| `meta` (substring) | 310 / 309 | mostly unrelated: `CMetaserver*` (multiplayer lobby), templates; the save-meta name seen in code is the zip member `"meta"` (string) and token reads in `UpdateIronmanAndCharForContinue` |

## Group 4 — possible later-feature precursors (chronology evidence)

| term | hits ck2game / ck2 | verdict |
|---|---|---|
| `bronze` | 0 / 0 | **absent** — no Bronzeman/Bronze naming in 2.6.x |
| `bronzeman` | 0 / 0 | **absent** |
| `feat` | 90 / 98 | only unrelated: `CGovernment::GetFeatures`, `CReligion::GetFeatures`, `CCulture::GetFeatures`, `CGovernment`-era "features" lists; `D11_FEATURE`, SDL `FEATURE_*` constants, `agINTERNETFEATURELIST`. **No Monarch's-Journey "feat" concept.** |
| `ruler` | 427 / 395 | pre-existing gameplay only: `CAIRulerStrategy`, `CAnyPlayableRulerTrigger`, `CIsRulerTrigger`, `CRandomPlayableRulerEffect`, `CCharRulerLifeData`, sort functors. **No highlighted-ruler/featured-ruler system.** |
| `highlight` | 17 / 17 | renderer highlight colours (`CGraphicalObject::SetHighLightColor`) + gfx sprite names only |
| `challenge` | 0 / 0 | **absent** |
| `reward` | 0 / 0 (type names) | **absent** as a game system (a handful of unrelated script tokens only) |
| `progress` | 111 / 111 | unrelated: construction/unit/tech progress, `CProgressbarSprite`, `SetLoadScreenProgress` |
| `Titus` | 0 / 0 | **absent** |
| `GameSparks` | 0 / 0 | **absent** (2.6.x uses Steam + its own metaserver, not GameSparks) |

Feature-chronology conclusion: all Monarch's-Journey-relevant names are absent
from the 2016 builds, consistent with MJ having been developed against the
2.9/3.x line (2019). The 2016 builds are a "clean baseline": Continue/save-select
semantics here predate any GameSparks account coupling, which is precisely what
makes them useful as an analysis baseline (there is **no** account/cloud-gating
predicate in the 2.6.1.1 Continue path at all — see type notes §2).

## Near-hit notes

- `CSaveGameModel::GetVersionStatus` string set (`UNSUPPORTED_VERSION`,
  `UNSUPPORTED_VERSION_2_1`) shows 2.6.1.1's save-compat taxonomy: current
  version == "2.6.1.1", hard floor "2.1.0.0".
- `CConfirmLoadOldSave` / `CConfirmLoadOldSaveToConclave` document how old/DLC-gated
  saves are *confirmed* rather than blocked.
- `CContinueFailedDialog` (`frontendview.obj`) is the UX used when an
  auto/requested Continue cannot be satisfied.
- Identical-VA rows in reports are MSVC `/OPT:ICF` code folding (identical small
  functions share a body); VA→name picking shows the first name recorded.
