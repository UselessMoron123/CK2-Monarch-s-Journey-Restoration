# CK2 2.6.1.1 — type, vtable, and Continue/save-flow research notes

> **Scope rule.** Every layout, offset, VA and vtable slot in this file is a
> **2.6.1.1-only fact**, recovered from the exact-matched `ck2game.pdb` +
> `CK2game.exe` pair (GUID `DC5E6265-…-A6E6`, age 1). None of it may be applied
> verbatim to any other build. Rows marked *[TPI]* come from compiler type
> records; rows marked *[EXE]* were cross-checked against the actual 2.6.1.1
> machine code; [inference] is reading of that machine code.

Contents: §1 CIronmanSaveSelect · §2 the Continue decision model ·
§3 frontend enable/disable propagation · §4 save metadata & compatibility ·
§5 supporting classes · §6 cross-build drift & safe carry-forward hypotheses.

---

## §1 `CIronmanSaveSelect` — the save-select / Continue owner (2.6.1.1)

*[TPI] `class CIronmanSaveSelect`, size 0x290, 72 members, base:
`CReloadableInterface` (→ `CReloadDispatcher`). Source TU: `savegameinterfaces.obj`
(source path embedded in asserts: `..\..\source\savegameinterfaces.cpp`).*

### Fields (offsets from type records)

| off | type | name | role in Continue logic |
|---:|---|---|---|
| 0x20 | `CList<CString>` | `_SaveDirectoriesOpened` | |
| 0x30 | `const CString` | `_WindowName` | |
| 0x4C | `CButtonObserverGlue<CIronmanSaveSelect>` | **`_Continue`** | the Continue button binding |
| 0x78 | …Glue | `_Accept` | |
| 0xA4 | …Glue | `_Decline` | |
| 0xD0 | …Glue | `_Delete` | |
| 0xFC | …Glue | `_Back` | |
| 0x128 | …Glue | `_LocalSaveTab` | |
| 0x154 | …Glue | `_RemoteSaveTab` | local/cloud tab |
| 0x180 | `CCheckBoxObserverGlue<…>` | `_FileSelect` | |
| 0x1A0 | `CCheckBoxObserverGlue<…>` | `_DirectorySelect` | |
| 0x1C0 | `CFrontEnd*` | `_pFrontEnd` | |
| 0x1C4 | `CGameSetup*` | `_pGameSetup` | |
| 0x1C8 | `CFixedWindow*` | `_pWindow` | window hosting the widgets |
| 0x1CC | `TSavegameItem<CIronmanSaveSelect>*` | `_pSelectedItem` | |
| 0x1D0 | bool | `_bRemoteSaveTab` | |
| 0x1D1 | bool | `_bLoadGameMode` | |
| 0x1D2 | bool | `_bIsAccepted` | set by `OnContinue` |
| 0x1D4 | `CString` | **`_ContinueName`** | candidate save file name chosen for Continue |
| 0x1F0 | `CString` | **`_LastLocalSavedFile`** | newest local save path |
| 0x20C | `CloudFileCLOUDSTORAGE*` | **`_LastCloudSaveFile`** | newest cloud save handle |
| 0x210 | bool | **`_bContinueIronman`** | parsed from meta of candidate |
| 0x214 | `CRef<CCharacter>` | **`_ContinueChar`** | parsed from meta (`player=`) |
| 0x23C | bool | `_bIsContinue` | set by `OnContinue` |
| 0x23D | bool | **`_bIsContinueSaveValid`** | **the flag that gates the Continue button** |
| 0x240 | `CString` | `_FileName` | file chosen to load |
| 0x25C | `CloudFileCLOUDSTORAGE*` | `_hFile` | |
| 0x260 | bool | `_bIronman` | current selection |
| 0x264 | `CRef<CCharacter>` | `_Char` | |
| 0x28C | bool | `_bShowingConfirm` | |

### Methods (all non-virtual except where noted)

- [EXE] `static CString GetContinueSave(bool bCloud, CloudStorageContextCLOUDSTORAGE**, CDLCManager*)` @ **0x00AC7160** — *static* (mangled `…@@SA…`), declared `virtual` in the type record listing is a class-level annotation quirk; the symbol encoding proves static.
- [EXE] `void UpdateContinueData(const CString*)` @ **0x00AC7770** — the core “compute the continuable save” pass.
- [EXE] `bool UpdateIronmanAndCharForContinue(CFile*)` @ **0x00AC6D80** — meta reader (version/date/player/ironman).
- [EXE] `void RefreshContinueButton()` @ **0x00AC9BF0** — the enable/disable pusher.
- [EXE] `void OnContinue()` @ **0x00AC8E00**, `void ContinueOnStartup(const CString&)` @ **0x00AC8D00**.
- Also: `Reload, Show, Hide, ViewSave, Start, OnSaveSelected(CSaveGameItemBase*), StartCommandLineSaveGame, IsAccepted, ResetIsAccepted, IsContinue, ResetIsContinue, GetFile, GetFileHandle, IsIronman, GetChar, GetSaveDirectoriesOpened, RefreshLoadButton, OnFileDeleted, OnAccept, OnDecline, SetShowingConfirm, Setup, UpdateLocal, UpdateRemote, OnLoad, OnDelete, OnBack, OnFileSelect, OnFileUpOrDown, OnDirectorySelect, ~dtor` (+ overloaded ctors). *[TPI]*

Binary vtable (`??_7CIronmanSaveSelect@@6B@` @ .rdata 0x011C4680): slot 0 =
`CIronmanSaveSelect::Reload` (0x00AC4480) — the only inherited
`CReloadableInterface` virtual it overrides; the class adds almost no virtual
surface itself. Fine-grained slot identity beyond that is unreliable because
MSVC `/OPT:ICF` folded many identical tiny bodies in this build.

---

## §2 Direction A — what “Continue” means in 2.6.1.1 (verified decision flow)

*[EXE] All pseudocode below is decompiled from the matched 2.6.1.1 binary and
annotated with PDB types; condensed but faithful.*

### Candidate enumeration — `CIronmanSaveSelect::GetContinueSave` (static)

```cpp
static CString CIronmanSaveSelect::GetContinueSave(bool bCloud,
        CloudStorageContextCLOUDSTORAGE** ctx, CDLCManager* dlc) {
    CString result = "";
    // local:
    CArray<CString> files;
    VFSEnumerateFiles(dir          /* "save games" (user dir) via VFS */,
                      files, ".ck2", /*recursive*/…);       // @0x00AC727E region
    Stable_sort(files, SFileDateSort<std::greater<__int64>>{}); // NEWEST FIRST (mtime)
    for (f : files) {
        PHYSFS_getLastModTime(f);
        CSaveGameModel m(f, dir, nullptr, false);            // ctor parses header/meta
        if (!anon::IsValidSave(&m, dlc)) continue;           // see below
        result = dir + "/" + f;  break;                      // first (newest) valid wins
    }
    // cloud (ctx from steam): SCloudStorageContext::CountFiles/GetFiles + SCloudFile::Read→CMemoryFile
    // same CSaveGameModel/IsValidSave gate; dir-local and cloud candidates compete by mtime.
    return result;
}
```

Called exactly once per scan from `` `anonymous namespace'::GetContinueSave(CDLCManager*) ``
in `main.obj` @ 0x0099F540 (which wraps it with `SteamAPI_Init` +
`SCloudStorageContext(true)` + `.Update()` boilerplate and the appid string
"CK2") — i.e. a launcher/startup pre-scan — and consumed by the frontend.

### The gate computation — `UpdateContinueData(const CString* forced)` @ 0x00AC7770

- Re-enumerates `save games` (`.ck2`), newest-first stable sort by
  `PHYSFS_getLastModTime`, same `SFileDateSort` comparator.
- Builds per-candidate models (`CSaveGameModel` for local fully-parsed files;
  `CSaveGameItemBase("savegameentry", …)` records as list rows) and filters with
  `` anonymous-namespace `IsValidSave(const CSaveGameModel*, CDLCManager*)` ``.
- Winner selection compares modification times (`jl`/`jg` chains on a
  `CEU3Date`/`__int64` mtime; the max stays).
- Writes: `_ContinueName` (0x1D4), `_LastLocalSavedFile` (0x1F0),
  `_LastCloudSaveFile` (0x20C), then parses the winner's meta through
  `UpdateIronmanAndCharForContinue(CFile*)` and finally sets
  **`_bIsContinueSaveValid` (0x23D)** according to success.
- Cloud path: `SCloudStorageContext::CountFiles/GetFiles` → `SCloudFile::Read` →
  `CMemoryFile`; local zip path: `CZipArchive::ListFileNames` and a string scan
  for the zip member literally named **`"meta"`**; if present it is inflated
  (`GetUncompressedFileSize`→`CMemoryFile`) and parsed.

### Validity predicate — `anon::IsValidSave` @ 0x00AC70A0 *[EXE, exact]*

```cpp
static bool IsValidSave(const CSaveGameModel* m, CDLCManager* dlc) {
    if (m->_bBroken)                       return false;  // +0xC8
    if (m->_VersionStatus.length() != 0)   return false;  // +0xBC: any status text = rejected
    if (!m->_bIsConclaveSave)              return true;   // +0xCD: ordinary save
    return g_ConclaveDLC || (dlc && dlc->HasDLC("Conclave"));
}
```

So in 2.6.1.1 an *ordinary* save is Continue-invalid only if (a) the header
parse marked it broken, or (b) it carries a non-empty `_VersionStatus`
diagnostic (too-old/new, see §4), or (c) it is a Conclave-era save without the
Conclave DLC owned. **There is no account check, no GameSparks check, no
cloud-presence check, no special-mode check** in the Continue eligibility of
2.6.1.1 — valuable negative knowledge for 3.3.x analysis.

### Meta reader — `UpdateIronmanAndCharForContinue(CFile*)` @ 0x00AC6D80 *[EXE]*

```cpp
file->Seek(0);                                   // vftable +0x2C op
uint32 magic = NSaveGame::GetMagix(file);        // header sniff
skip = magic in {0x11,0x21,0x31} ? strlen(sMagicPrefix)+6       // legacy binary
     : magic=='bin'||'txt'        ? strlen(sMagicPrefix)+3      // "CK2bin"/"CK2txt" style
     : 0;
CLexer* lex = NSaveGame::GetLexerToSaveGame(file);
CReader r(lex, tempName, true);
file->Seek(skip);
r.ReadSimpleStatement(); if (tok != token('version'))  → Log("…savegameinterfaces.cpp",1017,"File error: Missing Version"); return false;
r.ReadSimpleStatement(); if (tok != token('date'))     → Log(…,1027,"File error: Missing Date");    return false;
r.ReadSimpleStatement(); if (tok != token('player'))   → Log(…,1038,"File error: Missing Player");  return false;
                         else _ContinueChar  = r.Read<CRef<CCharacter>>();        // +0x214
r.ReadSimpleStatement(); if (tok == token('ironman'))  _bContinueIronman = true;  // +0x210
return true;
```

(Token IDs in the binary: 0x116 / 0x279B / 0x292D / 0x2F7F; the name mapping is
inferred from the adjacent log strings — order version,date,player,ironman.
The CRef<CCharacter> read is just the *character-name ref* used to display the
ruler for the Continue entry. *[inference on token names; code paths exact]*)

### Who drives what (direct-call evidence)

```
CFrontEndState::Update(frontendview.obj,0x008FF310)
  └─ ContinueOnStartup(&gAutoStartSave?)            // once frontend is up
        ├─ UpdateContinueData(&gAutoStartSave)      // forced candidate wins if provided
        ├─ if (_ContinueName != autoStart) → new CContinueFailedDialog(_pFrontEnd)
        ├─ if (_bContinueIronman) { spin-wait on frontend-ready flag; check achievements mgr flag }
        └─ OnContinue()                             // commits the load
OnContinue(): if (!_bIsContinueSaveValid) return;   // gate
              _bIsAccepted=_bIsContinue=true;
              _FileName=_LastLocalSavedFile; _hFile=_LastCloudSaveFile; …

RefreshContinueButton():                            // called by ViewSave & CConfirmSaveDelete::OnAccept
  UpdateContinueData(nullptr);
  _pWindow->GetButton("continue")->Enable()  if _bIsContinueSaveValid    // vtbl+0xDC = CButton::Enable
  _pWindow->GetButton("continue")->Disable() otherwise                   // vtbl+0xE0 = CButton::Disable
```

---

## §3 Direction B — frontend enable/disable propagation (2.6.1.1)

*[EXE]* `CIronmanSaveSelect::RefreshContinueButton` in full:

```
push ebp …                        ; standard prologue, SEH
xor  ebx,ebx ; push ebx ; mov esi(this=CIronmanSaveSelect*)
call CIronmanSaveSelect::UpdateContinueData(0)
push "continue"                   ; widget name string @0x011C44F0
cmp  byte [esi+0x23D],bl          ; _bIsContinueSaveValid
je   @disable
  ecx = _pWindow (esi+0x1C8); call [ecx.vtbl+0x3C]("continue")
                                ; → CFixedWindow::GetButton → TButton*
  call [result.vtbl+0xDC]       ; → CButton::Enable()      (verified)
else:
  ... call [result.vtbl+0xE0]   ; → CButton::Disable()     (verified)
```

Key facts for 2.6.1.1:

1. **Enable state is *pushed*, not polled.** The frontend does not read a saved
   boolean on draw; `RefreshContinueButton` writes `CButton::Enable()/Disable()`
   whenever the save view is shown/updated (callers: `ViewSave`,
   `CConfirmSaveDelete::OnAccept`) and at startup the whole chain runs in
   `CFrontEndState::Update`.
2. The button predicate is a **recomputed decision**, not a persisted flag:
   it derives from `_bIsContinueSaveValid`, freshly computed by
   `UpdateContinueData(nullptr)` → `UpdateIronmanAndCharForContinue` + `IsValidSave`.
3. **GUI enable API** (vtable indices verified against the binary's own tables):
   - `CFixedWindow::GetButton(const CString&) → TButton*` = **vftable +0x3C**
     (of CFixedWindow; base `CGuiObject`-family). [EXE: `0x00D65780`]
   - `TButton/CButton` abstract slots: `GetState`+0xD4, `SetState`+0xD8,
     **`Enable()`+0xDC**, **`Disable()`+0xE0**, `IsDisabled()`+0xE4**.
     [TPI vbase_off 212/216/220/224/228; EXE CButton vtable @0x011F40D8 confirm.]
   - `TButton::SetEnabled(bool)` exists as a non-virtual helper (`buildview.obj`
     @ `0x00499F30`) used by tooling code; the Continue path uses the virtual
     Enable/Disable.
4. There is **no `CMainMenu` class** in 2.6.x: the main menu is the frontend
   state machine (`CFrontEndState`) + generic `mainmenu_panel` widgets in
   `.gui` script. Frontend states: `CFrontEndState::{SinglePlayer, LoadGame,
   MultiPlayer, OpenTempSinglePlayer, Nudge, Settings, Tutorial, Credits, …}`
   (see §5). `CIronmanSaveSelect::Show` is invoked from
   `CFrontEndState::LoadGame` and `CGameSetup::{Start,Update,ViewSave,
   ToggleLocalRemote}`.
5. Why a Continue button can look dead although a manual Load works (2.6.1.1
   semantics): any of these will do it — newest-save candidate marked
   `_bBroken`, any `_VersionStatus` text, Conclave-gated without DLC, meta read
   failure (missing version/date/player), or no save newer than nothing.
   In later builds the *same push architecture* persists, so a *new* predicate
   silently forcing Disable is the exact failure shape that can leave Continue
   gray while Load works — this is a **semantic hypothesis for 3.3.x**, not an
   address claim.

---

## §4 Direction C — save metadata & compatibility rules (2.6.1.1)

- Save container: zip with a member literally named **`meta`** (searched by
  `CZipArchive::ListFileNames`) + the main gamestate member; also plain-text
  `CK2txt`-style and legacy binary magics handled by `NSaveGame::GetMagix`
  (0x11/0x21/0x31, `bin`/`txt` literal compare). *[EXE]*
- Meta fields consumed by the Continue path: `version`, `date`, `player`,
  optional `ironman` (see §2). These map to `_ContinueChar` /
  `_bContinueIronman`. *[EXE]*
- `CSaveGameModel` (size 0xD0) caches per-file display/validity data:
  fields `_FileName`(0x04) `_FullPath`(0x20) **`_Version`**(0x3C)
  `_Date`(0x58) `_Char`(0x5C) `_hFile`(0x84) `_pCoA`(0x88) `_Title`(0x8C)
  `_nFileSize`(0xA8) **`_VersionStatus`**(0xAC) then booleans
  **`_bBroken`**(0xC8) **`_bReadShield`**(0xC9) `_bDirectory`(0xCA)
  **`_bIronman`**(0xCB) `_bSynced`(0xCC) **`_bIsConclaveSave`**(0xCD)
  `_bPaganCoA`(0xCE). [TPI]
- `CSaveGameModel::GetVersionStatus()` @ 0x00AC22B0 embeds **`"2.6.1.1"`** (the
  build's own version), **`"2.1.0.0"`** (hard floor), and status strings
  **`"UNSUPPORTED_VERSION"`** / **`"UNSUPPORTED_VERSION_2_1"`**; result text
  non-empty ⇒ not continuable (§2) and shown in the list UI. *[EXE]*
- Confirm dialogs for soft blocks: `CConfirmLoadOldSave`,
  `CConfirmLoadOldSaveToConclave`, `CConfirmSave`, `CConfirmSaveDelete` — none of
  them are Continue-path blockers; they gate *load/save/delete* actions. [TPI]
- `CGameState::WriteSaveGameMetaData(CWriter&)` @ 0x00937F40 (gamestate.obj) is
  the meta-**writer**; `CGameState::GetSaveGameVersion()` @ 0x004B7430. *[EXE]*
- DLC compatibility enters Continue only via the `Conclave` string check inside
  `IsValidSave` (DLC presence queried through `CDLCManager::HasDLC`). *[EXE]*

Ordinary validity rules are therefore cleanly separated in 2.6.1.1:
**corruption** (`_bBroken`) · **version** (`_VersionStatus`, 2.1.0.0 floor) ·
**DLC gate** (Conclave only) · **meta completeness** (version/date/player).
No account/online terms exist in this flow at 2.6.1.1.

---

## §5 Supporting classes (layouts 2.6.1.1-only)

**`class CFrontEndState` : CFrontEndView, size 0x2A8** — frontend state machine;
button-glue members `_OpenTempSinglePlayer`(0x0C) `_Settings`(0x38)
`_SinglePlayer`(0x64) `_LoadGame`(0x90) `_MultiPlayer`(0xBC) `_Nudge`(0xE8)
`_Content`(0x114) `_IngameStoreDLC`(0x140) `_Exit`(0x16C) `_Homepage`/`_Forum`/
`_Facebook`/`_Twitter`/`_Credits`/`_Tutorial`, `_nSteamDepotID`(0x2A0),
`_bHasShownWelcomeScreen`(0x2A4), `_bHasShownEula`(0x2A5). Methods:
Initialize/Show/Hide/**Update**/OpenTempSinglePlayer/OpenSettings/
SinglePlayer/LoadGame/MultiPlayer/Nudge/Credits/EndGame/…/ValidateProvinceSetup/
ReadProvinceSetup. [TPI]

**`class CFrontEnd` : CEU3Idler,CReloadDispatcher,CLostDeviceInterface, size ~0x10D0** —
129 methods incl. `Idle/Render/Reload/LaunchGame/EndGame/DoSave/DoCloudSave/
AddSave/NotifyLoadStart/ShowContinueFailed/PreformeGameStart/ReadyForGameStart/
ChangeState(CFrontEndView::EViewState)/ShowCurrentViewState/ShowWelcomeScreen/
ShowEulaDialog`… [TPI]

**`CSaveGameItemBase` : CStandardlistboxItem, size 0x148** — one listbox row with
`_Select`(0xF8) glue; virtuals `OnSelect` (vtbl slot +0x30 area) + dtor. [TPI]
**`TSavegameItem<CIronmanSaveSelect>`** — concrete row used in the select window.

**`CLoadGame` / `CLoadGameStart` : CCommand (sizes 0x54/0x50)** — command-queue
load requests: `Execute/WriteMembers/ReadMember/Clone/IsValid/MustSynch/
GetSpecificTokenType`. [TPI]

**`struct SCloudStorageContext`** (engine `pdx_cloudstorage.lib`) — Steam
RemoteStorage wrapper: app id, `ISteamUser*`,`ISteamRemoteStorage*`,
`_Files`/`_Contents` arrays, `_bEnabled/_bConnected/_bStatsValid`,
methods `Update/GetQuota/InitFiles/SynchFiles/CountFiles/GetFiles/CountDirectories/
GetDirectories/CreateFile/GetFile/ValidateFile/DeleteFile/Validate/…`.
**`struct SCloudFile`** — `_Path/_FileName/_FullPath/_nFileSize/_nTimeStamp/
_StreamHandle/_bSynched`; `Read(char*,int)/Write/UnSync/OpenStream/CloseStream/
WriteToStream`. [TPI]

**`class CGameState` : CPersistent, size ~0x4D8** — the live game state with
`WriteSaveGameMetaData/WriteMembers/ReadMember/InitPostRead/GetPlayer/SetPlayer/
GetGamespeed/SetGamespeed/DailyUpdate/Tick/RefreshKnowledge/VerifyIntegrity/…`
(156 methods listed in TPI; see CSV).
**`CCurrentGameState`** — active-state façade (`ScopedDisableOfCharacterVassalCaching`,
`SetCharactersHaveDiedByEvent`, …).

**Ironman UI indicators:** `CGameRulesIronManIndicator`, `CIngameRulesIronManDisplay`
(checkbox glue; in-game rules display) — display-only; no decision role in save
eligibility.

**Ironman path naming:** `CGameState::SetIronmanFileName` @ 0x00901980
(gamesetup.obj); ironman naming handled at *game start*, not at Continue.

---

## §6 Cross-build drift and what is safe to carry to 3.3.x

### Verified cross-PDB drift (ck2.pdb 2016-06-01 vs ck2game.pdb 2016-08-30)

- `CIronmanSaveSelect` **grew: 0x1F4 → 0x290** and the entire Continue surface
  was added in that window: fields `_Continue`, `_ContinueName`,
  `_LastLocalSavedFile`, `_LastCloudSaveFile`, `_bContinueIronman`,
  `_ContinueChar`, `_bIsContinue`, `_bIsContinueSaveValid`; methods
  `GetContinueSave`, `UpdateContinueData`, `UpdateIronmanAndCharForContinue`,
  `RefreshContinueButton`, `OnContinue`, `ContinueOnStartup`,
  `StartCommandLineSaveGame`, `IsContinue/ResetIsContinue`. In the June build
  the class had only Accept/Decline/Delete/tab logic.
- So the auto-Continue frontend itself was **introduced during the 2.6.x
  (Reaper's Due) cycle, H1-2016** — already a reworked flow by 2.6.1.1.
- Type/record counts otherwise move only slightly (13,364 vs 12,414 defined
  types; 48,081 vs 43,444 functions) — same architecture, same file names.

### Safe carry-over to 2020-era binaries (hypotheses, must be re-verified there)

- **Concepts**: newest-valid-save Continue selection; meta parse keys
  (`version/date/player/ironman`); broken-flag + version-status + DLC-gate as
  the *baseline* eligibility stack; push-based button enabling via a window
  `GetButton("continue")→Enable/Disable`; a launcher pre-scan of continue name.
- **Names to look for in 3.3.x**: `CIronmanSaveSelect` (still present in the
  Linux 3.3.2 per project notes — `GetContinueSave`), `CSaveGameModel`,
  `CSaveGameItemBase`, `CFrontEndState`, `CFixedWindow::GetButton`,
  `CButton::Enable/Disable`, source names `savegameinterfaces.cpp`,
  `frontendview.cpp`, `frontend.cpp`, `gamestate.cpp`, and strings
  `"save games"`, `".ck2"`, `"meta"`, `"continue"`, `"savegameentry"`,
  `"UNSUPPORTED_VERSION*`, `"File error: Missing …"`.
- **Semantics for the 3.3.x bug shape**: if a 3.3.x binary still pushes
  `Enable/Disable` from a `Refresh`-style routine driven by one computed flag,
  then *any* new failing sub-predicate (including a dead online/account branch)
  pins Continue disabled while Load (which doesn't consult that flag) still
  works. The 2.6.1.1 model predicts the correct replacement check is “does an
  eligible newest save exist”, not account state.

### Not transferable

Every VA/RVA, field offset, structure size, vtable slot index and branch
location in this folder. Apply **none** of it to 3.3.x; re-derive from the
3.3.x binary itself. The 2.6.1.1 numbers exist here only because the PDB↔EXE
identity was proven.
