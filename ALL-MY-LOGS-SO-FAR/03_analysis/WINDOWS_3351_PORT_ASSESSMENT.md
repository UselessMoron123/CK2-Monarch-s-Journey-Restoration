# Cross-version comparison & Windows 3.3.5.1 port assessment

Produced 2026-08-22 from static analysis of the four verified executables
(see `EXECUTABLE_IDENTITIES.md`). Method: string inventory + presence matrix,
`.pdata` function-boundary maps (win333: 48,965 functions, win3351: 47,410 —
~1,555 fewer), exhaustive RIP-relative/pointer-table xref scans on the Windows
binaries, and symbol-driven disassembly of the Linux 3.3.3 build (`.dynsym` is
intact) to recover semantics.

## 1. Headline verdict

**A byte-patch port of the restoration to Windows 3.3.5.1 is not feasible.**
The removed code is precisely the parts V2 depends on: the GameSparks client,
the payload JSON parser, and the virtual-file loader that fed feat definitions
into the game. Everything downstream (Bronzeman, feat tracking, feat storage,
save fields, Titus reward table) **survives** in 3.3.5.1 — but with no data
source feeding it. Restoring MJ on 3.3.5.1 would require code injection (a
synthetic payload feed), which this project deliberately avoids.

**The May-2020 3.3.3 build remains the correct restoration target.**
The user’s performance preference for 3.3.5.1 (“it lags less”) can’t be met by
offset porting; if it matters later, the safe option is a hybrid: 3.3.5.1 for
normal play, the patched May EXE for Monarch’s Journey runs (saves are
cross-loadable in at least the 3.3.3→3.3.4 range; 3.3.5.1 still parses
`bronzeman`/`special_event` save fields, but challenge definitions won’t
exist there, so MJ saves opened in 3.3.5.1 lose challenge evaluation).

## 2. What was removed in 3.3.5.1 (win) — evidence

| Component | 3.3.2 | 3.3.3 May | 3.3.5.1 | Evidence |
|---|---|---|---|---|
| GameSparks SDK (client, mbedTLS, RTTI `GSData/GSRequest/...`) | yes | yes | **gone** | 19 gamespark strings → 0 |
| Payload JSON parser (`scheduled_rulers`, `event_time_end`, `alert_level`, `camera_look_at`, `can_see_highlighted_rulers`) | yes | yes | **gone** | strings absent; xrefs in 333 at 0x140d74c40/0x140d7a790 (parser pair) |
| Virtual feat-script loader (`gs_virtual/feat_script`) | yes | yes | **gone** | string absent in 3351 |
| MJ main-menu panel UI (`highlighted_ruler_window_main`, `_char_tab`, `_feat_tab`, `_start`, `_continue`, `_restart`, `feat_window`, ...) | yes | yes | **gone** (only `_icon`, `_toggle_open`, `_toggle_close` remain) | string sets |
| `.text` size | 0xff1b82 | 0xff62a2 | 0xf98202 (**−376 KiB** vs May) | PE sections |
| `.rdata` size | 0x44c360 | 0x44d908 | 0x431e06 (−48 KiB) | PE sections |

The −517 KiB file shrink ≈ GameSparks SDK + mbedtls + MJ frontend controller
+ payload parser. No real source-file churn: the only `.cpp` debug-path diffs
are a Jenkins workspace rename (`ck2-live-steam` → `ck2`) and EMotionFX path
moves — confirming a targeted removal, not a refactor.

## 3. What SURVIVES in 3.3.5.1 — with live code references

All verified by string-xref into identified functions (3.3.5.1 VA → component):

| Surviving component | 3.3.3 VA | 3.3.5.1 VA | Meaning |
|---|---|---|---|
| `CDirectorySettings` ctor registering `red_king/ruler_feats` and `common/monarchs_journey` | 0x1404dd200 | 0x1404dd640 | both directories still registered |
| `GetFeatLevelName` (`RULER_FEAT_LEVEL_`) | 0x1407b7220 | 0x1407ba3c0 | feat tier naming exists |
| `CFeatProgressStorage` asserts (`feat_progress_storage.cpp`) | 0x1406fe8f0 | 0x1406fe8e0 | persistent feat cache exists |
| `CRoadToTitusProgression` (6 funcs, `road_to_titus_progression.cpp`) | 0x140c32xxx | 0x140c2bxxx-0x140c2cxxx | local reward/score table exists |
| Save serialization of `special_event` + `bronzeman` | 0x14007df60 | 0x14007e3f0 | MJ saves still written/read |
| `extend_featured_ruler` flow (4 funcs) | 0x140726720+ | 0x140729ce0+ | MJ ruler-extend flow exists |
| MJ toggle handler (`highlighted_ruler_toggle_open`) | 0x1407c0310 | 0x1407bd7c0 | arrow open/close exists |
| Bronzeman UI (`_toggle`/`_indicator`/`_icon`) + `autosave_bronzeman` | 0x140732b20+ | 0x1407366d0+ | Bronzeman UI + autosave exist |
| Consoles `wipe_feats`, `feat_log`, `bronzeman_debug` (ptr-table registered) | 0x14144aa48 | 0x1413d5b38 | console commands exist |

## 4. Why no byte patch can bridge the gap (data-flow proof, from Linux symbols)

The 3.3.3 feat-definition pipeline is:

```text
CNullGameSpark::LoadLocalCache()            <- gfx\monarchs (our V2 redirect)
  -> ParseGameSparksData()                  <- JSON payload
  -> ParsePropertySetKeyData()
     -> ruler info struct, field +0x1c8 = feats_script (embedded PDX script)
CHighlightedRulerFeatDatabase::Init()       @ lin 0xff66bc
  -> CGameSparksInterface::AccessInstance() @ lin 0x1644e16
  -> vtable+0xe0  (get current highlighted-ruler info)
  -> [+0x1c8]     (feats_script CString)
  -> load as virtual file "gs_virtual/feat_script" (literal @ lin 0x18b4f27)
  -> TSingleObjectGameDatabase<CHighlightedRulerFeatDatabase>::LoadFile(CReader&, bool)
CCompleteHighlightedRulerFeatDatabase::Init() @ lin 0xff68e2 = same for ALL rulers
  (vtable+0x88 returns the ruler vector; iterates each +0x1c8 feats_script)
CRulerFeatTracker::ReloadFeatsDatabase()    @ lin 0xff7f7a
  -> guards on GetHasFetchedPropertySet (vtable+0xd8) and
     GetGuiVersion(0xE = highlighted_ruler_version, vtable+0x48)
  -> recreates both databases
```

In 3.3.5.1 the parser AND the `gs_virtual/feat_script` loader literal are
gone, so the surviving tracker/storage has **no possible data source** — there
is no file path, mod directory hook, or fallback that feeds
`CHighlightedRulerFeatDatabase`. (`red_king/ruler_feats` is registered in
`CDirectorySettings` in all builds, but in 3.3.3 nothing reads feat scripts
from it — the sole source is the payload string. It is not an input hook.)

## 5. Answers to the user’s specific questions

- **“Check all exes for big differences / something cut in earlier versions”:**
  3.3.2 (Feb 2020) has the *online* MJ stack only — no `CNullGameSpark` local
  loader, no `common/monarchs_journey`, no `can_see_highlighted_rulers`. The
  local/offline-capable loader was ADDED in the May 3.3.3 build (`.text` grew
  +18 KiB vs 3.3.2). Nothing MJ-relevant exists in 3.3.2 that 3.3.3 lacks;
  May 3.3.3 is strictly the best-equipped target. Linux 3.3.3 = same May code
  with the null loader as the DEFAULT (factory) implementation.
- **“Dig for the featured-ruler base feature”:** confirmed the MJ stack sits
  directly on the Featured-Ruler subsystem (`CHighlightedRulerFeat*`,
  `CHighlightedRuler*`, `CRulerFeatTracker`, `CFeatProgressStorage`,
  `CIronmanSaveSelect`, `CInGameIdler::HandleBronzemanAutosave`); all named
  and mapped via Linux `.dynsym` (see §6).
- **“Maybe a patch for the newest version (it lags less)”:** not achievable by
  patching — see §1/§4. Recommend hybrid usage instead.

## 6. Bonus: recovered component map (Linux 3.3.3 dynsym — use for future work)

```text
CNullGameSpark::LoadLocalCache/ParseGameSparksData/ParsePropertySetKeyData
  0x1644f2a / 0x1644ffa / (see handoff)
CGameSparksInterface::AccessInstance/CreateInstance   0x1644e16 / dyn
CHighlightedRulerFeat ctor/GetName/GetDesc/ReadMember 0xff6262/0xff63d8/0xff64b2/0xff658c
CHighlightedRulerFeatDatabase::Init                   0xff66bc
CCompleteHighlightedRulerFeatDatabase::Init           0xff68e2
CRulerFeatTracker: ReloadFeatsDatabase 0xff7f7a, UpdateFeatProgress 0xff78a6,
  GetFeatLevel 0xff7c68, RecalcScore 0xff7cc2, SetFeatProgress 0xff7dfe,
  IsActiveForPlaythrough 0xff6d46, CalcShouldTrackFeatProgress 0xff6e38
CFeatProgressStorage: CacheProgress 0xf460bc, ReadCachedProgress 0xf46958,
  ReadProgressFromKeyValueStorage 0xf4731a, WipeFeats 0xf45f8a
SendFeatCompleteMessage 0xff6ee0 / SendFeatLevelCompleteMessage 0xff7213
GetFeatLevelName 0xff6144
CIronmanSaveSelect::GetContinueSave 0x121ac3a   <- scans "save games"/"*.ck2",
  builds "alternate_start" exclusion; V7 target
CInGameIdler::HandleBronzemanAutosave 0xeb5584
Onexecute_BronzemanDebug 0xc301e6, OnExecute_WipeFeats 0xc39c86, OnExecute_FeatLog 0xc48697
CRoadToTitusProgression: SetupRewards 0x1444e92 (LOCAL reward table, 2.5 KB),
  CalcRequiredScoreToReward 0x1445c7e, rewards SRoadToTitusReward(name,desc,icon,cost)
```

## 7. V7 breadcrumbs (Continue button stays grayed)

- User-confirmed failure mode: Continue control **grayed out** (enable-state),
  not a click no-op. V6 patched the inline account branch inside the Continue
  candidate helper (`0x1409e4970` region) and manual Load works — so the
  remaining gate is whatever the frontend’s *can-continue* predicate reads
  (likely `CIronmanSaveSelect::GetContinueSave(...)` ≈ the
  `0x1409e5500–0x1409e66f6` scan in win terms, or the caller at
  `0x1408145ec`).
- Linux reference: `CIronmanSaveSelect::GetContinueSave(bool, CloudStorageContext**,
  CDLCManager*, CString*, CloudFile**, const CString*, CString*, CRulerFeatTracker*)`
  at `0x121ac3a` (2015 bytes). Disassemble its win333 counterpart around
  `0x1409e5500` for the non-account early-outs (alternate-start exclusion,
  newest-save comparisons, CRulerFeatTracker argument).
- `SSaveGameFeatProgress` vector (savegameinterfaces) serializes per-save feat
  state — `global_<feat>` variables load correctly (user-confirmed 1/6).

## 8. Reproduction recipes

```bash
# reconstruct binaries (see EXECUTABLE_IDENTITIES.md)
cat <folder>/<name>.base64.part*.txt | tr -d '\r\n ' | base64 -d > out
# cross-version string matrix / xrefs: python3 with pefile+capstone+numpy
#   .pdata → function bounds; numpy int32 window scan → exhaustive RIP xrefs;
#   pointer tables: 8-byte LE VA search in .rdata/.data
# Linux semantics: pyelftools .dynsym + capstone (non-PIE, absolute immediates)
```
