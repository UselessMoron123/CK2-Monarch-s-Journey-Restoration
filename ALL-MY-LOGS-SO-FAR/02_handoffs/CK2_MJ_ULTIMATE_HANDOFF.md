# Crusader Kings II Monarch's Journey restoration — the single handoff

> **Status banner (2026-08-27):** The core restoration loop **and in-game Continue**
> are runtime-proven on Windows May-2020 3.3.3. Current baseline is **V7**
> SHA-256 `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`
> (`0x009E5B8B` `75 2f→eb 2f`). V6 `f5b7dfd6…` is the exact revert target.
> Paradox **launcher** Continue remains grey (case C25) — launch `CK2game.exe`
> directly. Read `00_START_HERE/STATUS.md` first; this file is deep background.
> **All artifacts are already in the connected repository** — do not ask the
> user to upload anything listed in §0.

## Instructions to the next Arena.ai Agent Mode session

Continue this reverse-engineering/restoration project from the state documented here.
Do **not** restart the investigation, ask the user to repeat old tests, or request
collections of files already stored in this repository. Everything is reachable from
`ALL-MY-LOGS-SO-FAR/` (§0 maps every artifact class to its folder).

In-game Continue is **done** (V7). Optional remaining work: launcher Continue (C25),
Phase 3 polish (C09–C12), Featured Rulers, local reward gallery. Do not restart V7.

This work is for personal restoration/interoperability of a retired game feature. Do not
redistribute any complete original or modified CK2 executable. Produce guarded patch
scripts that operate on the user's own verified executable.

---

# 0. Where everything lives (repo map — replaces all old "files to provide" lists)

| What you need | Where it is in this repo |
|---|---|
| Authoritative current state (read first) | `ALL-MY-LOGS-SO-FAR/00_START_HERE/STATUS.md` |
| Cases solved/unsolved map | `ALL-MY-LOGS-SO-FAR/00_START_HERE/CASES_AND_FINDINGS.md` |
| Screenshot catalogue (text, canonical) | `ALL-MY-LOGS-SO-FAR/00_START_HERE/SCREENSHOTS_CATALOG.md` |
| Phase plan / checkboxes | `ALL-MY-LOGS-SO-FAR/PLAN.md` |
| Research archives Parts 1–3 (session-by-session record) | `ALL-MY-LOGS-SO-FAR/01_research_archives/` |
| **Windows May-2020 3.3.3 exe (patch target, SHA `656f4f48…`)** | `ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/windows/CK2game333.exe` |
| Windows 3.3.2 / 3.3.5.1 exes, Linux 3.3.3 exe | `ALL-MY-LOGS-SO-FAR/10_binary_artifacts/executables/` |
| 2.6.1.1 debug drop (exe, dbghelp, extracted PDBs, RARs) | `ALL-MY-LOGS-SO-FAR/10_binary_artifacts/debug_files/` |
| Upload manifests (identity records) | `ALL-MY-LOGS-SO-FAR/10_binary_artifacts/upload_manifests/` |
| **Payload `monarchs`** (SHA `fc6ec025…`, 11 rulers / 33 challenges) | `ALL-MY-LOGS-SO-FAR/06_game_data/monarchs` (variants alongside) |
| Guarded patchers v2–v6 + check/revert/prepare helpers | `ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/{bat,ps1,py}` |
| Cumulative patch map (offsets/bytes/purpose) | `ALL-MY-LOGS-SO-FAR/03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv` |
| **Evidence saves** `Bosnia1173_03_03.ck2`, `Bronzeman_kulin_bosnia.ck2`, Pavao/Croatia saves, `.meta` | `ALL-MY-LOGS-SO-FAR/13_save_and_cache/` (+ `saves/` subfolder) |
| Feat-progress cache `q847rsja8ndx` (both states) | `ALL-MY-LOGS-SO-FAR/13_save_and_cache/` |
| Runtime logs (incl. v6 second-look boots, Bronze popup) | `ALL-MY-LOGS-SO-FAR/07_runtime_logs/` |
| Canonical artifact registry (every size/SHA) | `ALL-MY-LOGS-SO-FAR/03_analysis/MASTER_ARTIFACT_TABLE.md` |
| **V7 knowledge base (2.6.1.1 model → win333 anchors → ordered steps)** | `ALL-MY-LOGS-SO-FAR/03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` |
| Banned builds/helpers/approaches | `ALL-MY-LOGS-SO-FAR/03_analysis/BANNED_ARTIFACTS.md` |
| 3.3.5.1 port assessment (verdict: not feasible) | `ALL-MY-LOGS-SO-FAR/03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md` |
| Contradictions register | `ALL-MY-LOGS-SO-FAR/03_analysis/CONTRADICTIONS.md` |
| 2.6.1.1 PDB analysis (IDENTITY, SYMBOLS, SEARCH, TYPES) | `ALL-MY-LOGS-SO-FAR/03_analysis/` |
| Raw-log tear-down ledger (what was deleted → where content lives) | `ALL-MY-LOGS-SO-FAR/12_raw_chat_logs/INDEX.md` |
| Organization-pass audit trail | `RECON_NOTES_2026-08-26.md` (repo root) |

Every size/SHA in this handoff is also in `MASTER_ARTIFACT_TABLE.md` (the canonical
registry — check it first; it includes the V2–V6 patcher tool hashes).

---

# 1. User goal

Restore the retired Crusader Kings II Monarch's Journey mode locally on Windows, including
as much as possible of:

1. the Monarch's Journey arrow and ruler panel;
2. all locally available rulers and their challenge definitions;
3. Bronzeman campaign creation;
4. live challenge evaluation and tier progress;
5. save/load/Continue and persistent progress;
6. eventually, a local total-score and historical reward gallery.

The retired Paradox/Titus backend cannot grant CK3 cosmetics. Any reward-gallery
restoration would be a local historical/cosmetic reconstruction only.

---

# 2. User constraints and environment

- The user is on Windows and is not comfortable with technical PC procedures. Give
  literal, short, beginner-level steps.
- Verified working test root:

  ```text
  C:\Users\UZWERG\Desktop\SteamCrusader
  ```

- Exact working payload destination:

  ```text
  C:\Users\UZWERG\Desktop\SteamCrusader\gfx\monarchs
  ```

  The filename is extensionless.
- The user has no functioning Paradox login for this build. Keep Internet disconnected
  during tests: enabling it makes the obsolete client enter a different "Not Logged In"
  state and can interfere with controlled offline behavior.
- The chat uploader rejects EXE/DLL/SO/ZIP/RAR. GitHub (this repo) or Base64 `.txt`
  parts are used instead; prefer the repo — nothing common needs re-uploading.
- Minimize uploads, logs, and large generated files.
- The Bronzeman console being unavailable is normal, as in Ironman.
- Never tell the user to run `wipe_feats`; it irreversibly erases Featured Ruler progress.
- Do not require Linux/WSL unless there is no simple alternative.
- There is a separate newer/post-removal game installation. Do not apply May 2020 offsets to it.

---

# 3. Exact executable identities

## May 2020 Windows CK2 3.3.3 — patch target

Verified PE identity:

```text
Architecture: PE32+ x86-64
Image base: 0x140000000
.text VMA: 0x140001000
.text raw offset: 0x00000400
Linker timestamp: 2020-05-06 12:25:12 (build string 3.3.3, 2020-05-06 12:57:06 +0200)
File size: 24,753,368 bytes
```

For raw offsets in `.text` used below:

```text
VA = raw_file_offset + 0x140000c00
```

Exact hashes (also in `MASTER_ARTIFACT_TABLE.md`):

| State | SHA-256 |
|---|---|
| Exact stock May 3.3.3 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` |
| Earlier branch-only experiment | `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c` |
| V2 | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` |
| V3 | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` |
| V4 | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` |
| V5 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| V6 (previous baseline / V7 revert target) | **`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`** |
| **V7 Continue (current in-game baseline)** | **`57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`** |
| ⛔ "V6" trampoline (Part 2) | `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff` — **BANNED** |
| ⚠️ "V7" feat-update candidate | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` — abandoned |

The V5 executable uploaded to the most recent session was reconstructed and independently
verified against its exact expected hash. Restoring every known patch byte reproduced the
exact stock-May hash.

## Native Linux May 2020 CK2 3.3.3

Previously reconstructed and fully verified:

```text
File: ck2
Size: 27,729,272 bytes
SHA-256: 99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6
Format: ELF 64-bit x86-64
Version/build string: CK2 3.3.3, 2020-05-06
```

## Windows 3.3.2 and 3.3.5.1

Prior string analysis established:

- genuine Windows 3.3.2 build date: 2020-02-06 (SHA `83ba6a68…`, 24,727,272 B);
- 3.3.2 contains the original remote GameSparks highlighted-ruler controller but not the
  static `common/monarchs_journey` local path;
- current/post-removal 3.3.5.1 identifies itself with build string `2021-09-21 16:13:22 +0200`
  (SHA `a0cc8e92…`, 24,236,024 B, −517 KiB vs May);
- 3.3.5.1 retains many lower-level Bronzeman/feat/reward strings but lost or disabled
  higher-level initialization.

Both are materialized under `10_binary_artifacts/executables/`; full analysis in
`03_analysis/EXECUTABLE_IDENTITIES.md` and `03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md`.

## Steam manifests for the last pre-retirement May build

```text
Common depot 203771: 7374899011992364670
Windows depot 210890: 8653648373486267886
Linux depot 210909: 4089811292004061988
```

---

# 4. Local ruler payload

Verified payload:

```text
Size: 101,949 bytes
SHA-256: fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e
```

Windows V2+ destination:

```text
<game root>\gfx\monarchs
```

The filename has no extension. The payload is ordinary plaintext JSON:

```json
{
  "can_see_highlighted_rulers": 1,
  "scheduled_rulers": [ ... ]
}
```

It has eleven rulers and 33 challenge definitions:

1. Konan of Brittany
2. Llywelyn of Gwynedd
3. Sa'ad Mordechai
4. Konstantinos of Samos
5. Louis the Stammerer
6. Shajar al-Durr
7. Pavao of Croatia
8. Arwa of Yemen
9. Harald Hardrada
10. Hethum of Armenia
11. Kulin of Bosnia

The final five official rulers are absent:

- Liao Hongji
- Basarab I
- Mindaugas
- Grand Mayor Botstain
- Stefan the First-Crowned

The payload's eleven `event_time_end` fields use:

```text
1893499200 = 2030-01-01 12:00 UTC
```

Do not replace this with `2147483647`. The game calculates approximately:

```text
signed_32bit(event_time_end + 172800)
```

INT_MAX therefore overflows to a 1901-era signed value and hides the panel. This was the
reason the earliest "reactivated" payload failed. (Payload expiry 2030-01-03 visible
window; ceiling 2147310847; hard wall 2038-01-17/19.)

---

# 5. Linux local-loader findings already proved

Native Linux CK2 3.3.3 contains a complete offline replacement:

```text
CNullGameSpark
CNullGameSpark::Download()
CNullGameSpark::LoadLocalCache()
CNullGameSpark::ParseGameSparksData()
CNullGameSpark::ParsePropertySetKeyData()
CNullGameSpark::GetHasFetchedPropertySet()
CNullGameSpark::GetHighlightedRulerInfo()
```

Exact behavior:

- `CGameSparksInterface::CreateInstance(...)` always constructs `CNullGameSpark` on Linux.
- The constructor immediately invokes `LoadLocalCache()`.
- `Download`, `Reconnect`, and `Update` are no-ops.
- `GetHasFetchedPropertySet()` always returns true.
- `LoadLocalCache()` requests storage location 0 and filename `monarchs.txt`.
- Storage location 0 resolves through the original-directory entry for:

  ```text
  common/monarchs_journey
  ```

- Exact Linux path:

  ```text
  <original game root>/common/monarchs_journey/monarchs.txt
  ```

- Plain JSON is accepted; an optional XOR/pineapple format exists but is unnecessary.
- `can_see_highlighted_rulers: 1` fills GUI-version integer slot 14 (`highlighted_ruler_version`).
- Initial panel creation has no POPS, Titus, Paradox-login, or account gate on Linux.

`FEATURED_RULER_NOT_SUPPORTED_LINUX` is only referenced in an old launcher Continue tooltip
and is not a global Linux disable.

---

# 6. Windows local-loader root cause and V2

Windows May 3.3.3 contains `CNullGameSpark`, but the factory normally selects the dead
online GameSparks implementation.

The Windows null loader originally requests:

```text
<game root>\gfx\test.dds
```

Storage location 0 maps to original-directory index 2, which is `gfx` in this Windows build.

There is a collision: the startup username-cache routine also uses `gfx\test.dds` before
Monarch's Journey initializes and may rewrite it. A JSON payload at that path is therefore
unsafe. Globally renaming the shared string would rename both users and would not solve
the collision.

V2 made two changes:

| Raw file offset | Stock | Patched | Purpose |
|---|---|---|---|
| `0x00d73d02` | `74 2b` | `eb 2b` | Force the local/null GameSparks factory branch |
| `0x00d73e1a` | `ba 23 36 00` | `21 fc 32 00` | Redirect only `CNullGameSpark::LoadLocalCache` from the shared `test.dds` string to the first eight bytes of an existing `monarchs_journey` string, yielding extensionless `monarchs` |

V2 runtime result:

- panel appeared;
- all eleven rulers loaded;
- all three challenge rows per ruler rendered;
- obsolete account UI still blocked Play/rewards.

Do not return to `common\monarchs_journey\test.dds`, `gfx\test.dds`, or any global string
replacement. The proven Windows path is `gfx\monarchs`.

---

# 7. V3: highlighted-ruler account UI gates

V3 retained V2 and added:

| Raw offset | Stock | V3 | Purpose |
|---|---|---|---|
| `0x007bd64e` | `75 04` | `90 90` | Enable Play after the legitimate local readiness checks pass |
| `0x007beacb` | `74 19` | `eb 19` | Normal Play tooltip instead of login tooltip |
| `0x007beea2` | `74 0c` | `eb 0c` | Normal Continue tooltip |
| `0x007befaf` | `74 2d` | `eb 2d` | Normal Restart path |
| `0x007c0d18` | `74 0b` | `eb 0b` | Forced online reward-container branch; later reverted because it exposed empty controls |

V3 observed runtime result (user transcript, hashes verified):

- login prompt gone;
- current ruler and all three challenge rows populated;
- Play enabled; Play opens historical Game Rules;
- Bronzeman enabled;
- **Challenges: Disabled**;
- Start blocked with `Challenges must be enabled`;
- actual checksum/modified-data and Steam-active requirements are red;
- main-menu checksum is `EDJH`, while setup identifies stock version `3.3.3 (SOHY)`;
- no crash or relevant fatal loader error.

V3 therefore proved the start route but did not create the internal challenge-enabled state.
V3 also exposed an unpopulated reward control showing `UI Missing Text`; `text2.log`
confirms the typo key `UI_ MISSING_TEXT` is undefined — default GUI content, not payload
decode failure.

---

# 8. V4: offline Bronzeman challenge mode and live progress

## 8.1 Edits

V4 retained the useful V2/V3 UI changes, restored `0x007c0d18` to stock, and added:

| Raw offset | VA | Stock | V4/V5/V6 | Purpose |
|---|---|---|---|---|
| `0x007c0d23` | `0x1407c1923` | `eb 5c` | `90 90` | Hide both empty reward controls and obsolete login text offline |
| `0x00732b03` | `0x140733703` | `74 16` | `90 90` | Bypass retired Steam-active gate for challenge Start state |
| `0x007336b0` | `0x1407342b0` | `74 1d` | `90 90` | Challenge-enabled predicate |
| `0x007337e1` | `0x1407343e1` | `74 1d` | `90 90` | Start-warning predicate |
| `0x00737262` | `0x140737e62` | `74 1b` | `90 90` | Challenge-tooltip heading |
| `0x007b78eb` | `0x1407b84eb` | `75 0c` | `eb 0c` | In-game feat tracking |

The shared eligibility helper's 24-byte Boolean tail at raw offset `0x000aeb83` was
changed from:

```text
80 7f 61 00 74 0c 80 7f 63 00 74 06 80 7f 62 00 74 02 33 f6 40 0f b6 c6
```

to:

```text
31 c0 66 83 7f 61 01 75 0f 80 7f 63 00 75 06 80 7f 65 00 75 03 ff c0 90
```

The effective final condition changed from approximately:

```text
save_ok && stock_checksum && !ruler_designer
```

to:

```text
save_ok && !ruler_designer && (stock_checksum || !steam_active)
```

All earlier rule checks remained intact. The stock checksum is still required when Steam
is genuinely active. Normal achievement/Steam branches were not globally patched. This is
VA `0x1400af783`.

## 8.2 The Game Rules / challenge-eligibility trace (why those five call sites)

The Monarch Play event already sets the true Bronzeman request flag. The remaining
failure was the challenge eligibility chain. Important functions:

- `0x1407341b0` — returns requested Bronzeman state, including frontend global `+0x2f9`.
- `0x140734290` — challenge-enabled predicate.
- `0x140733630` — Game Rules refresh/start-button enabled state.
- `0x1400af690` — shared rules/save/checksum/Ruler Designer eligibility helper.
- `0x14072d540` — evaluates the active rule set; called inside the helper and left intact.
- `0x1407b8450` — in-game feat tracking eligibility.

The challenge predicate requires:

1. Ironman or the real Bronzeman context;
2. active game rules that permit feats;
3. service byte `+0x61` true: save is valid;
4. service byte `+0x63` true: stocge predicate requires:

1. Ironman or the real Bronzeman context;
2. active game rules that permit feats;
3. service byte `+0x61` true: save is valid;
4. service byte `+0x63` true: stock checksum/no user modification;
5. service byte `+0x62` false: no Ruler Designer;
6. service byte `+0x65` true: Steam active.

The V3 screenshot exactly matches failures 4 and 6. The in-game tracker additionally
retains checks for a current ruler, non-expired ruler, actual Ironman/Bronzeman mode
(`+0x500/+0x501`), and service byte `+0x60` clear.

V4 does **not** force only the final Start button; it patches the challenge-enabled
predicate, button state, warning state, tooltip heading, and in-game feat tracker
consistently, preserving real Bronzeman/Ironman context, active game-rule evaluation,
valid-save requirement, no-Ruler-Designer requirement, selected-ruler and expiry checks,
in-game mode checks, and in-game feat progress code.

## 8.3 V4 runtime result — successful challenge restoration

- Game Rules allowed the campaign to start.
- The campaign loaded as Kulin of Bosnia in Bronzeman mode.
- The in-game pause-menu Monarch's Journey panel displays all three Kulin challenges.
- Progress is genuinely updating: the row shows `Heretical Courtiers: 1/6`, and its
  tooltip shows `Current Progress: 1` with Bronze/Silver/Gold thresholds `6/9/12`.
- The supplied local progress dump `/home/user/uploads/q847rsja8ndx.txt` (now
  `13_save_and_cache/q847rsja8ndx.txt`) independently records `heretical_company=1`
  while the other feat counters remain zero.
- No crash or Monarch/feat fatal error appears in the logs.

This proves V4 restored genuine in-session challenge evaluation, not merely an enabled
Start button. It does **not** prove durable storage (that came in V6).
The screenshot's absence of an individual progress bar is normal:
`highlighted_ruler_feat_window` contains textual progress and tooltip controls, not a bar.
The only bar in the stock GUI belongs to the separate account-level reward panel.

---

# 9. Uploaded saves — exact proof

Two raw compressed CK2 saves were uploaded under `.txt` names because of uploader
restrictions. They are ordinary ZIP-format `.ck2` files and can be read directly by
Python `zipfile`. Both now live in `13_save_and_cache/` (raw `.txt` names) with copies in
`13_save_and_cache/saves/` under their real names.

## March save

```text
Intended name: Bosnia1173_03_03.ck2
Archive size: 4,195,136 bytes
SHA-256: e25c1c90074b9c02c29163fb6f034241226f1432edfbe184c804aa330edd61c0
Main entry size: 24,272,124 bytes
Version: 3.3.3.0
Internal date: 1173.3.3
player id/type: 218800 / 66
bronzeman=yes
special_event="kulin_bosnia"
ironman="save games/Bosnia1173_03_03.ck2"
global_heretical_company=1.000
```

## January autosave

```text
Intended name: Bronzeman_kulin_bosnia.ck2
Archive size: 3,430,038 bytes
SHA-256: 5b7767b92483ec21bd86149aab8fe56577caf7f77a3a19ebf7bdaf0f3729d038
Main entry size: 20,608,047 bytes
Version: 3.3.3.0
Internal date: 1173.1.1
player id/type: 218800 / 66
bronzeman=yes
special_event="kulin_bosnia"
ironman="save games/Bronzeman_kulin_bosnia.ck2"
global_heretical_company=1.000
```

Both archives and both `meta` entries are structurally valid. Their internal states are
different. Later V6-era saves (Pavao of Croatia / Croatia 1278) are in
`13_save_and_cache/saves/` too — see `MASTER_ARTIFACT_TABLE.md` §4 for all hashes.

---

# 10. V5: generic load validator — partial only

## 10.1 Fresh-process loading result (the decisive clean test, Internet disabled)

There were no older saves and no intervening online login attempt.

- Outer launcher Continue is gray.
- In-game Single Player Continue is gray.
- Load Game lists and permits selection of both Kulin saves.
- Both show the bronze-hand/crown icons and say they were created while playing a
  Featured Ruler.
- Selecting either save disables Load with: `Monarch's Journey requires you to be logged
  in to a Paradox account.`
- `%APPDATA%\GameSparks\E349414h9BDm` exists but is empty.

Therefore the dirty-process warning was not the blocker, and save corruption is ruled out.
V4's highlighted-ruler account edits do not cover the generic saved-game selector.

## 10.2 V5 edits

| Raw offset | VA | Stock | V5 | Purpose |
|---|---|---|---|---|
| `0x009e3d4c` | `0x1409e494c` | `74 0b` | `eb 0b` | Generic valid-save predicate: skip the retired account check for a save containing Featured Ruler metadata |
| `0x009e1c2d` | `0x1409e282d` | `74 49` | `eb 49` | Normal save tooltip instead of `MONARCHS_JOURNEY_REQUIRES_LOGIN` |

Relevant function:

```text
Generic save predicate: VA 0x1409e4900–0x1409e4967
Patched branch: VA 0x1409e494c, raw 0x009e3d4c
```

Original logic near the patch (the exact May Linux binary's exported symbols exposed
`CIronmanSaveSelect::RefreshLoadButton()` calling a shared saved-game validator; mapping
that logic to the exact Windows executable identified this helper):

```asm
cmp qword ptr [rcx+0x128], 0  ; Featured Ruler/special-event field
je  valid
call account_status
cmp dword ptr [rax+0x10], 3
jne invalid
valid:
mov al, 1
```

V5 changes only the first conditional branch to an unconditional jump, so a save that has
already passed every earlier validation check no longer calls the retired account service
merely because its Featured Ruler identifier is nonempty. The first edit is referenced by
both continue-save parsing and `RefreshLoadButton`, so it was expected to cover manual
Load, in-game Continue, and startup Continue without globally changing account status.
The second edit is UI consistency only. OnAccept contains no additional account check.

V5 differs from V4 by exactly these two one-byte branch opcode changes. Applying all 16
recognized patch entries to the exact original produces the V5 SHA in §3. V5 correctly
removed the visible login restriction and enabled the Load control, but runtime showed
that it did not install the selected save as the active deserialize target (V5 result:
fresh-looking 1 January campaign with `Heretical Company: 0/6` — the "Game State is
corrupted" menu tooltip after the failed/fallback transition is secondary, the archives
are not corrupt).

---

# 11. V6: new independent disassembly and root cause

## 11.1 Critical discovery

The generic predicate is not the only account check. The code duplicates the same check
inside:

1. Continue's candidate-selection loop; and
2. four paths in the main save-list scanning/selection routine.

Thus V5 allowed a save row and button to look valid, but the higher-level routine refused
to write the Featured Ruler save record into the actual selection fields.

The save-list object later expects:

```text
object + 0x368: selected save name
object + 0x3a8: selected save record pointer
```

The unpatched account branches prevented these from being set for
`special_event="kulin_bosnia"`. That explains the fallback to the January historical
setup exactly.

## 11.2 Relevant functions

```text
Continue candidate selection:
  VA 0x1409e4970–0x1409e5342

Main save-list scan/selection:
  VA 0x1409e5500–0x1409e66f6

Caller that refreshes/uses selected record:
  VA 0x1409e6700...

Generic validator already patched in V5:
  VA 0x1409e4900–0x1409e4967
```

The Continue helper is called from at least:

```text
0x1407bffa1  highlighted-ruler Continue path
0x1408145ec  normal frontend/launcher Continue path
0x140a0ba62  another Continue caller
```

## 11.3 V6's five new edits

V6 retains all V5 edits and adds:

| Raw offset | VA | V5 bytes | V6 bytes | Meaning |
|---|---|---|---|---|
| `0x009e4611` | `0x1409e5211` | `74 0f` | `eb 0f` | Continue candidate selection: skip Featured Ruler account check and take accepted-save path |
| `0x009e4f1e` | `0x1409e5b1e` | `0f 84 86 01 00 00` | `e9 87 01 00 00 90` | First save-list selection path: accepted-save target `0x1409e5caa` |
| `0x009e4fc3` | `0x1409e5bc3` | `74 0f` | `eb 0f` | Newer/current-save path: accepted-save target `0x1409e5bd4` |
| `0x009e5377` | `0x1409e5f77` | `0f 84 63 01 00 00` | `e9 64 01 00 00 90` | Named-save path: accepted-save target `0x1409e60e0` |
| `0x009e5452` | `0x1409e6052` | `74 0b` | `eb 0b` | Latest-save path: accepted-save target `0x1409e605f` |

Every edit is instruction-length preserving. The two six-byte conditional jumps become
five-byte unconditional jumps plus one NOP. Static disassembly confirmed every boundary
and target.

The V6 candidate was generated independently from the exact V5 binary and source-parsed
back to verify apply/revert hashes:

```text
V5 input SHA-256:
29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535

V6 output SHA-256:
f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0

V6 reverse-normalized SHA-256:
29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535
```

Prepared V6 deliverables (now in `05_patches_and_scripts/`, hashes in
`MASTER_ARTIFACT_TABLE.md` §6):

```text
patch_ck2_mj_v6.ps1
APPLY_CK2_MJ_V6.bat
CHECK_CK2_MJ_V6.bat
REVERT_CK2_MJ_V6_TO_V5.bat
CK2_MJ_V6_TEST_GUIDE.md
```

The V6 patcher intentionally accepts only exact V5 or exact V6, creates a timestamped
verified V5 backup, patches only the five new branches, verifies the full final SHA-256,
and can revert exactly to V5.

## 11.4 V6 runtime result — CONFIRMED (2026-08-26, user-tested)

The planned outcome matrix (A: March 3 + 1/6; B: March 3 but 0/6; C: still January 1;
D: Load works but Continue fails) resolved as **case A, plus more**:

- Old V4-era save `Bosnia1173_03_03.ck2` loaded via Single Player → Load Game: **3 March
  1173** and **Heretical Company 1/6** — feat globals (`global_heretical_company`) really
  deserialize; interface persists.
- A new Bronzeman campaign as a *different* featured ruler (Pavao of Croatia, 1278.1.1):
  live evaluation (`global_established` 2 → 4 across the first days), **Bronze tier
  granted** at the exact payload threshold (established levels {4 6 8} → Bronze at 4),
  save writing works (`bronzeman=yes`, `special_event="pavao_croatia"`, feat globals
  serialized), resume-after-restart via Load Game works.
- Persistent local feat cache: `cache/q847rsja8ndx` (`feat_progress_storage`) stores peak
  values (`established=4`, `conquerer_from_bribir=1`) across sessions.
- Full evidence chain: `03_analysis/V6_RUNTIME_RESULTS.md`; Bronze popup in
  `07_runtime_logs/game_v6sl.log`; screenshots catalogued (catalog **A** section).

**At that time still broken:** in-game Continue popped “Continue failed!” (fixed in
V7, next section). Launcher Continue stayed grey (still C25).

---

# 12. V7 — in-game Continue execution (SOLVED)

## 12.1 State of knowledge (consolidated)

The complete V7 knowledge base is `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` (built
2026-08-23/26 from the 2.6.1.1 exact-match PDB model, the win333 disassembly, and the
Linux 3.3.3 semantic reference). The two earlier V7 notes (`02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md`
and `03_analysis/V7_CONTINUE_CFG.md`) were merged into it on 2026-08-26; start there, not
with new exploration.

Summary:

- The three Continue UI paths (`0x1407bffa1` MJ, `0x1408145ec` normal frontend,
  `0x140a0ba62`) converge on shared helper `0x1409e4970`, but Continue has **multiple
  independent layers** (enumeration → metadata/status checks → candidate validity →
  newest/current comparison → candidate installation `+0x368`/`+0x3a8` → frontend
  enable-state). The first-pass correction: `0x1409e4970–0x1409e5342` (candidate
  construction/selection) and `0x1409e5500–0x1409e66f6` (separate larger scan/selection
  routine, invoked at `0x1409e671f`) are **not** one calling the other.
- 2.6.1.1 PDB proves the old Continue path had **no account/online check**; the win333
  failure is a newer predicate. Manual Load and Continue legitimately diverge.
- Rejection-path breadcrumbs inside the shared region: `0x1409e4f35`, `0x1409e4f42`,
  `0x1409e4fba` (rejection branches in the `0x1409e4970` region); `0x1409e4900` (distinct
  validity helper, has the V5/V6 edits); **`0x1409e4dc1` / `0x1409e5a71` — signed
  status/compatibility result checks (strongest current candidates for the remaining
  blocker)**.
- Ordered analysis steps, hypotheses to test in order, and guardrails: see
  `CONTINUE_SEMANTIC_REFERENCE.md` §C/§D. Do **not** re-patch the V5/V6 branches; do not
  globally force the button enabled or fabricate account state.

## 12.2 What was built (2026-08-27)

Live tracing showed the remaining failure was **execution**, not enable-state:
`0x1409E6700` reads `[rsi+0x63]` (cloud-sync) and constructs `CContinueFailedPopup`
(`0x140726560`) when the byte is 0 offline. V7: raw `0x009E5B8B` `75 2f→eb 2f`.
SHA `57b18e43…`. Guarded `patch_ck2_mj_v7.ps1` + APPLY/CHECK/REVERT bats +
`CK2_MJ_V7_TEST_GUIDE.md`. Evidence: `V7_RUNTIME_RESULTS.md`, Part 4.

Launcher Continue is **C25**, not this section.

---

# 13. Reward gallery and score — separate later project

V4 intentionally hides both the obsolete login message and the empty reward container.
The local ruler snapshot contains feat definitions/localisation but not the retired
account reward catalogue/progression state.

Historical reward order and score thresholds shown in screenshots/localisation:

| Score | Reward |
|---:|---|
| 10 | Wizards Beard |
| 20 | The Pageboy |
| 30 | Chaperon |
| 40 | Jesters Hat |
| 55 | Cone Shaped Hennin |
| 70 | Medieval Mullet |
| 90 | The Miller |
| 110 | The Joan of Arc |

Further disassembly showed the May executable itself hardcodes eight reward entries
(`REWARD_NAME_1..8`, `REWARD_DESC_1..8`) and their sprites (male/female hair, beard, hat,
chest, veil, etc.), plus local-storage keys `RTT_Rewards` and `ck2_rtt_reward_score`
(also present in the string dumps under `06_game_data/`). This makes a later local display
plausible, but persistence/load had to be solved first (it now is, via V6). Do not claim
CK3 cosmetic rewards are locally restored.

A later local cosmetic reconstruction could:

- calculate total earned score from completed bronze/silver/gold tiers;
- display the historical progress bar;
- populate reward icons, names, descriptions, and thresholds;
- store local gallery state.

It cannot grant or synchronize CK3 entitlements through the dead Titus backend.

Prior logs consistently contain:

```text
[road_to_titus_progression.cpp:301]: FAILED TO FETCH FROM TITUS
```

That is expected and separate from local challenge tracking. Do not start this work
until you explicitly start the reward-gallery project.

---

# 14. Porting to CK2 3.3.5.1 — later project

The user asked whether the restoration could be moved to the newest version with all
DLC/Steam files. Do not apply May offsets to 3.3.5.1. The full assessment is
`03_analysis/WINDOWS_3351_PORT_ASSESSMENT.md` — verdict: **byte-patch port not feasible**
(payload parser + `gs_virtual/feat_script` loader + GameSparks SDK removed; downstream
Bronzeman/feat machinery survives but has no data source). May 3.3.3 stays the
restoration target; hybrid usage recommended for performance.

Recommended later approach:

1. Reconstruct and verify all binaries (already done — `10_binary_artifacts/`).
2. Create binary-diff/function-matching reports for the four builds.
3. Match functions by constants, strings, control-flow shape, vtables, and call
   neighborhoods rather than copying raw offsets.
4. Determine whether 3.3.5.1 still has `CNullGameSpark` parser, highlighted-ruler
   databases/view classes, Bronzeman save serialization, feat progress evaluation,
   start/load handlers.
5. If code exists but initialization is disabled, write a separate hash-guarded 3.3.5.1
   patcher.
6. If large controller portions were removed, prefer keeping the proven May 3.3.3 build
   rather than unsafe code injection.

Known 3.3.5.1 retained strings/components include:

```text
common/monarchs_journey
red_king/ruler_feats
extend_featured_ruler
highlighted_ruler_toggle_open
highlighted_ruler_toggle_close
RULER_FEAT_LEVEL_
RULER_FEAT_
feat_progress
autosave_bronzeman
MONARCHS_JOURNEY_REQUIRES_LOGIN
ck2\source\feat_progress_storage.cpp
ck2\source\road_to_titus_progression.cpp
```

The September 2020 retirement build reduced `CK2game.exe` by roughly 775 KiB, so some
high-level component was removed or stripped.

---

# 15. Secondary known UI issues

- The ruler portrait tooltip can flicker because of overlapping/small GUI hit regions
  (`v6 second look/flickering….mp4`). Secondary; does not indicate payload failure.
- The selection map being mostly gray is not a decisive failure. The meaningful tests are
  populated challenge rows, enabled mode, actual start/load, and live progress.
- Exposing the online reward container under V3 caused `UI Missing Text`; this was the
  unpopulated default control, not JSON corruption.
- Internet-enabled tests trigger obsolete account-state behavior. Use offline tests for
  consistency.
- An empty GameSparks folder named approximately `E349414h9BDm` was observed in
  AppData/Roaming; it has not provided useful cached property data.
- Other cosmetic/flow items (Phase 3): MP button breaks on second boot /
  after resign-to-menu; gray map on first boot; MJ arrow absent in some boots; MJ
  interface disappears if a Bronzeman save is entered via the random-ruler path; no
  featured-ruler crown in Bronzeman. (Cases C09–C12/C13/C17 in `CASES_AND_FINDINGS.md`.)

---

# 16. Dead ends — do not repeat

Do not re-investigate these as activation mechanisms:

```text
mainmenu_rtt.gui / .gfx
LT_featured_ruler.txt
generic main-menu GUI files
achievements.txt
achievement_events.txt
common\monarchs_journey\test.dds on Windows
gfx\test.dds as a payload location
global replacement of test.dds
INT_MAX expiration timestamps
```

`LT_featured_ruler.txt` only supplies helper events for Arwa's conversion challenge.

Do not:

- patch the no-ruler fallback at `0x140727acc`;
- globally force account status to 3, because related pointers remain null;
- restore V3's forced online reward-container branch;
- force only the final Start control;
- return to V3's reward-exposure branch;
- use `INT_MAX` timestamps; adding two days overflows signed 32-bit arithmetic;
- use the returned unsafe global-string patchers;
- put JSON at `gfx\test.dds`; username caching can overwrite it;
- use `wipe_feats`;
- apply May offsets to an unknown or newer executable;
- call `0x1409e8200` (vector-append helper) from any read/load path — write-direction;
- ask for broad DLL/SO sets unless a critical function is proved to reside there;
- upload or expose `pdx_login.txt`, credentials, passwords, or tokens;
- ask the user to re-upload anything already in the repo (§0).

---

# 17. Repository hygiene and expected deliverables

The repo holds real game executables (materialized under `10_binary_artifacts/`):

- verify every manifest/hash before disassembly;
- do not commit decoded executables if the repository is public; never commit a complete
  modified CK2 executable;
- distribute only patch scripts, analysis reports, hashes, and user-created/test data;
- delete reproducible giant disassembly dumps after extracting concise findings;
- keep the machine-readable patch table (`03_analysis/WINDOWS_333_PATCH_MAP.md` + `.csv`)
  with raw offsets, VAs, original bytes, patched bytes, purpose, and expected hashes.

Current deliverable layout (matches the organized tree):

```text
03_analysis/           identity, patch map, banned register, Continue semantics, V6 results, 3.3.5.1 assessment
04_test_guides_and_reports/   in-game click-path guides (V5, V6, + per-version notes)
05_patches_and_scripts/       guarded bat/ps1/py patchers v2–v6 (only things that touch the exe)
06_game_data/          monarchs payload + variants, loc CSVs, GUI/GFX, string dumps
07_runtime_logs/       game/error/system logs from test boots
10_binary_artifacts/   materialized executables + debug drop + upload manifests
13_save_and_cache/     evidence saves + feat cache
14_screenshots_and_media/  image drop zone (catalog is the canonical text record)
```

After any new runtime result, update the concise authoritative status file
(`00_START_HERE/STATUS.md`) rather than creating contradictory duplicate reports.

---

# 18. Suggested first message to the next session

The user can paste this (everything needed is already in the repo):

> Read `ALL-MY-LOGS-SO-FAR/00_START_HERE/STATUS.md` first and treat it as the
> authoritative project state; then read `ALL-MY-LOGS-SO-FAR/02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`
> for deep background, and `ALL-MY-LOGS-SO-FAR/03_analysis/CONTINUE_SEMANTIC_REFERENCE.md`
> as the Continue knowledge base (V7 in-game path is solved — see §F). All executables,
> payload, saves, cache, logs, and patch tooling are already in the repo (handoff §0).
> Do not restart the investigation, do not ask me to re-upload artifacts, and never
> tell me to run `wipe_feats`. Current baseline is V7 `57b18e43…`. Optional next:
> launcher Continue (C25), Phase 3 polish, or Featured Rulers. Launch CK2game.exe
> directly. Do not redistribute a modified executable.

---

# 19. Handoff lineage (what was merged 2026-08-26)

This file is the **single** handoff. Older handoffs were consolidated so a new session
reads exactly one document:

- `CK2_Monarchs_Journey_next_session_handoff.md` (V5-era, 303 lines) — superseded by this
  file; its unique facts (Game-Rules eligibility trace §8.2, clean-process V5 test §10.1,
  V4 runtime details §8.3, hardcoded reward keys §13, V4/V5 tool hashes → now
  `MASTER_ARTIFACT_TABLE.md` §6) were merged here. **Deleted** (recoverable from git
  history).
- `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md` and `03_analysis/V7_CONTINUE_CFG.md` — their
  content (caller table, two-helper correction, rejection-path breadcrumbs, confidence
  levels) was merged into `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md`. **Deleted**.
- `02_handoffs/DEBUGFILES_PDB_HANDOFF.md` — retained with a "completed" banner: it is the
  mission brief for the finished 2.6.1.1 PDB investigation (results live in
  `03_analysis/IDENTITY.md`, `SYMBOL_SUMMARY.md`, `SEARCH_RESULTS.md`,
  `TYPE_AND_VTABLE_NOTES.md`, `SYMBOLS_FILTERED.csv`).

Flagged discrepancy recorded during the merge: the V4 test-guide SHA-256 claimed in the
old handoff (`3177eaef5298482de564278b1d79006a28f73ea9bb64ce84c5483505947c3234`) does
not match the file now at
`04_test_guides_and_reports/CK2_MJ_windows_v4_test_guide.md` (`9e7664a5…`) — the file was
edited at some point after that hash was recorded; harmless (V4 is superseded by V5/V6)
but kept on record. All other V4/V5 tool hashes were recomputed against the files in
`05_patches_and_scripts/` and **match byte-for-byte**.

---

# 20. Current bottom line

Already working on exact May Windows 3.3.3 (**V7**, SHA `57b18e43…`; V6 `f5b7dfd6…` revert):

- local eleven-ruler payload;
- Monarch's Journey arrow/panel;
- challenge names/descriptions;
- Play and Bronzeman start;
- Challenges: Enabled;
- campaign start;
- live in-game challenge evaluation and tier progress (Bronze grant proven);
- save writing with `bronzeman=yes` + `special_event` + feat globals;
- manual Load with full deserialization (3 March 1173, Heretical Company 1/6);
- persistent local feat-progress cache across sessions;
- **in-game Continue** (main menu / MJ / Single Player) — no popup; loads Bronzeman.

Not yet working:

- **Paradox launcher Continue** (C25) — grey; launch `CK2game.exe` directly.

Later, separate projects are:

- local score/reward-gallery reconstruction (hardcoded rewards + `RTT_Rewards`/
  `ck2_rtt_reward_score` keys found; Linux `CRoadToTitusProgression::SetupRewards` @
  `0x1444e92` has the local reward table);
- completing the missing five rulers if a late payload can be recovered;
- assessing a safe 3.3.5.1 port using the materialized cross-version binaries (current
  verdict: not feasible).
