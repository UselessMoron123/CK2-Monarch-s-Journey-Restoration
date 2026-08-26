# Crusader Kings II Monarch’s Journey restoration — ultimate handoff

## Instructions to the next Arena.ai Agent Mode session

Continue this reverse-engineering/restoration project from the state documented here. Do **not** restart the investigation, ask the user to repeat old tests, or request broad collections of files already stored in the connected GitHub repository.

The user has connected the next session to a GitHub repository containing Base64 text encodings of these stock CK2 executables:

- native Linux CK2 3.3.3 from May 2020;
- Windows CK2 3.3.2;
- Windows CK2 3.3.3 from May 2020, immediately before Monarch’s Journey was retired;
- Windows CK2 3.3.5.1/post-removal.

Locate each manifest, concatenate its numbered parts in order, Base64-decode it, and verify size/SHA-256 before analysis. Do not ask the user to upload those executables again through chat.

The immediate pending task is the **Windows V6 runtime test described below**. Finish save loading and persistence on exact May 2020 Windows 3.3.3 before attempting a port to 3.3.5.1 or reconstructing the cosmetic reward gallery.

This work is for personal restoration/interoperability of a retired game feature. Do not redistribute any complete original or modified CK2 executable. Produce guarded patch scripts that operate on the user’s own verified executable.

---

# 1. User goal

Restore the retired Crusader Kings II Monarch’s Journey mode locally on Windows, including as much as possible of:

1. the Monarch’s Journey arrow and ruler panel;
2. all locally available rulers and their challenge definitions;
3. Bronzeman campaign creation;
4. live challenge evaluation and tier progress;
5. save/load/Continue and persistent progress;
6. eventually, a local total-score and historical reward gallery.

The retired Paradox/Titus backend cannot grant CK3 cosmetics. Any reward-gallery restoration would be a local historical/cosmetic reconstruction only.

---

# 2. User constraints and environment

- The user is on Windows and is not comfortable with technical PC procedures. Give literal, short, beginner-level steps.
- Verified working test root:

  ```text
  C:\Users\UZWERG\Desktop\SteamCrusader
  ```

- Exact working payload destination:

  ```text
  C:\Users\UZWERG\Desktop\SteamCrusader\gfx\monarchs
  ```

  The filename is extensionless.

- The user has no functioning Paradox login for this build. Keep Internet disconnected during tests: enabling it makes the obsolete client enter a different “Not Logged In” state and can interfere with controlled offline behavior.
- The chat uploader rejects EXE/DLL/SO/ZIP/RAR. GitHub or Base64 `.txt` parts are used instead.
- Minimize uploads, logs, and large generated files.
- The Bronzeman console being unavailable is normal, as in Ironman.
- Never tell the user to run `wipe_feats`; it irreversibly erases Featured Ruler progress.
- `feat_log` was useful in a normal game but is not necessary for the current load test.
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
Linker timestamp: 2020-05-06 12:25:12
File size: 24,753,368 bytes
```

For raw offsets in `.text` used below:

```text
VA = raw_file_offset + 0x140000c00
```

Exact hashes:

| State | SHA-256 |
|---|---|
| Exact stock May 3.3.3 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` |
| Earlier branch-only experiment | `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c` |
| V2 | `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175` |
| V3 | `e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca` |
| V4 | `f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30` |
| V5 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| **V6 candidate** | **`f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0`** |

The V5 executable uploaded to the most recent session was reconstructed and independently verified against its exact expected hash. Restoring every known patch byte reproduced the exact stock-May hash.

## Native Linux May 2020 CK2 3.3.3

Previously reconstructed and fully verified:

```text
File: ck2
Size: 27,729,272 bytes
SHA-256: 99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6
Format: ELF 64-bit x86-64
Version/build string: CK2 3.3.3, 2020-05-06
```

The GitHub copy should be checked against this identity.

## Windows 3.3.2 and 3.3.5.1

Prior string analysis established:

- genuine Windows 3.3.2 build date: 2020-02-06;
- 3.3.2 contains the original remote GameSparks highlighted-ruler controller but not the static `common/monarchs_journey` local path;
- current/post-removal 3.3.5.1 identifies itself with build string `2021-09-21 16:13:22 +0200`;
- 3.3.5.1 retains many lower-level Bronzeman/feat/reward strings but lost or disabled higher-level initialization.

The next session should reconstruct these GitHub binaries and record their exact sizes/hashes in the repository’s analysis report, but this is lower priority than the V6 runtime test.

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

The filename has no extension.

The payload is ordinary plaintext JSON and contains:

```json
{
  "can_see_highlighted_rulers": 1,
  "scheduled_rulers": [ ... ]
}
```

It has eleven rulers and 33 challenge definitions:

1. Konan of Brittany
2. Llywelyn of Gwynedd
3. Sa’ad Mordechai
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

The payload’s eleven `event_time_end` fields use:

```text
1893499200 = 2030-01-01 12:00 UTC
```

Do not replace this with `2147483647`. The game calculates approximately:

```text
signed_32bit(event_time_end + 172800)
```

INT_MAX therefore overflows to a 1901-era signed value and hides the panel. This was the reason the earliest “reactivated” payload failed.

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

`FEATURED_RULER_NOT_SUPPORTED_LINUX` is only referenced in an old launcher Continue tooltip and is not a global Linux disable.

---

# 6. Windows local-loader root cause and V2

Windows May 3.3.3 contains `CNullGameSpark`, but the factory normally selects the dead online GameSparks implementation.

The Windows null loader originally requests:

```text
<game root>\gfx\test.dds
```

Storage location 0 maps to original-directory index 2, which is `gfx` in this Windows build.

There is a collision: the startup username-cache routine also uses `gfx\test.dds` before Monarch’s Journey initializes and may rewrite it. A JSON payload at that path is therefore unsafe. Globally renaming the shared string would rename both users and would not solve the collision.

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

Do not return to `common\monarchs_journey\test.dds`, `gfx\test.dds`, or any global string replacement. The proven Windows path is `gfx\monarchs`.

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

Runtime result:

- login prompt disappeared;
- Play became clickable;
- Play reached historical Game Rules;
- Bronzeman was requested/enabled;
- Challenges remained Disabled;
- Start was blocked due offline Steam/checksum eligibility;
- forced reward container showed `UI Missing Text` because the local payload contains no account reward catalogue.

---

# 8. V4: offline Bronzeman challenge mode and live progress

V4 retained the useful V2/V3 UI changes, restored `0x007c0d18` to stock, and added:

| Raw offset | Stock | V4/V5/V6 | Purpose |
|---|---|---|---|
| `0x007c0d23` | `eb 5c` | `90 90` | Hide both empty reward controls and obsolete login text offline |
| `0x00732b03` | `74 16` | `90 90` | Bypass retired Steam-active gate for challenge Start state |
| `0x007336b0` | `74 1d` | `90 90` | Challenge-enabled predicate |
| `0x007337e1` | `74 1d` | `90 90` | Start-warning predicate |
| `0x00737262` | `74 1b` | `90 90` | Challenge-tooltip heading |
| `0x007b78eb` | `75 0c` | `eb 0c` | In-game feat tracking |

The shared eligibility helper’s 24-byte Boolean tail at raw offset `0x000aeb83` was changed from:

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

All earlier rule checks remained intact. The stock checksum is still required when Steam is genuinely active. Normal achievement/Steam branches were not globally patched.

V4 runtime proof:

- Bronzeman Mode: Enabled;
- Challenges: Enabled;
- Start worked;
- the selected campaign loaded;
- the in-game Monarch’s Journey panel displayed all three challenges;
- live evaluation worked: `Heretical Company` reached `1/6`;
- `feat_log` showed `heretical_company=1` in memory.

The user later proved that save loading/persistence was still blocked, so V4 was a core live-tracking success but not a complete restoration.

---

# 9. Uploaded saves — exact proof

Two raw compressed CK2 saves were uploaded under `.txt` names because of uploader restrictions. They are ordinary ZIP-format `.ck2` files and can be read directly by Python `zipfile`.

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

Both archives and both `meta` entries are structurally valid. Their internal states are different.

After V5, selecting either save led to a fresh-looking 1 January campaign displaying `Heretical Company: 0/6`. Therefore neither archive was actually deserialized. If the March file had loaded, the date would be 3 March; if either save’s variables had loaded, progress would be 1/6.

The later “Game State is corrupted” menu tooltip is a secondary state after the failed/fallback transition. It does not mean the two save archives are corrupt.

---

# 10. V5: generic load validator — partial only

V5 added:

| Raw offset | Stock | V5 | Purpose |
|---|---|---|---|
| `0x009e3d4c` | `74 0b` | `eb 0b` | Generic valid-save predicate: skip the retired account check for a save containing Featured Ruler metadata |
| `0x009e1c2d` | `74 49` | `eb 49` | Normal save tooltip instead of `MONARCHS_JOURNEY_REQUIRES_LOGIN` |

Relevant function:

```text
Generic save predicate: VA 0x1409e4900–0x1409e4967
Patched branch: VA 0x1409e494c, raw 0x009e3d4c
```

Original logic near the patch:

```asm
cmp qword ptr [rcx+0x128], 0  ; Featured Ruler/special-event field
je  valid
call account_status
cmp dword ptr [rax+0x10], 3
jne invalid
valid:
mov al, 1
```

V5 correctly removed the visible login restriction and enabled the Load control, but runtime showed that it did not install the selected save as the active deserialize target.

---

# 11. New independent V5 disassembly and V6 root cause

The most recent session reconstructed the user’s exact tested V5 binary and independently disassembled every account-status xref in the save subsystem.

## Critical discovery

The generic predicate is not the only account check. The code duplicates the same check inside:

1. Continue’s candidate-selection loop; and
2. four paths in the main save-list scanning/selection routine.

Thus V5 allowed a save row and button to look valid, but the higher-level routine refused to write the Featured Ruler save record into the actual selection fields.

The save-list object later expects:

```text
object + 0x368: selected save name
object + 0x3a8: selected save record pointer
```

The unpatched account branches prevented these from being set for `special_event="kulin_bosnia"`. That explains the fallback to the January historical setup exactly.

## Relevant functions

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

## V6’s five new edits

V6 retains all V5 edits and adds:

| Raw offset | VA | V5 bytes | V6 bytes | Meaning |
|---|---|---|---|---|
| `0x009e4611` | `0x1409e5211` | `74 0f` | `eb 0f` | Continue candidate selection: skip Featured Ruler account check and take accepted-save path |
| `0x009e4f1e` | `0x1409e5b1e` | `0f 84 86 01 00 00` | `e9 87 01 00 00 90` | First save-list selection path: accepted-save target `0x1409e5caa` |
| `0x009e4fc3` | `0x1409e5bc3` | `74 0f` | `eb 0f` | Newer/current-save path: accepted-save target `0x1409e5bd4` |
| `0x009e5377` | `0x1409e5f77` | `0f 84 63 01 00 00` | `e9 64 01 00 00 90` | Named-save path: accepted-save target `0x1409e60e0` |
| `0x009e5452` | `0x1409e6052` | `74 0b` | `eb 0b` | Latest-save path: accepted-save target `0x1409e605f` |

Every edit is instruction-length preserving. The two six-byte conditional jumps become five-byte unconditional jumps plus one NOP. Static disassembly confirmed every boundary and target.

The V6 candidate was generated independently from the exact V5 binary and source-parsed back to verify apply/revert hashes:

```text
V5 input SHA-256:
29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535

V6 output SHA-256:
f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0

V6 reverse-normalized SHA-256:
29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535
```

Prepared V6 deliverables from the latest session:

```text
patch_ck2_mj_v6.ps1
APPLY_CK2_MJ_V6.bat
CHECK_CK2_MJ_V6.bat
REVERT_CK2_MJ_V6_TO_V5.bat
CK2_MJ_V6_TEST_GUIDE.md
```

Tool hashes:

```text
patch_ck2_mj_v6.ps1
995ee9aa9db75d13a1374cfe4a6b575893d262acfd763032060d3b87fd956e3b

APPLY_CK2_MJ_V6.bat
f92ed979ede2d5bf25179ba89e494b28da41cb2285dea7a1cd527f68c7f4a4cc

CHECK_CK2_MJ_V6.bat
607e4f6c8a2cf3ddf82f9497187a7fce0cc014c9d1e3e216482dad034ec34013

REVERT_CK2_MJ_V6_TO_V5.bat
6ac6c9d846928f9c999f18640c2dda4a34e43979a882978307785d9295abf8c7

CK2_MJ_V6_TEST_GUIDE.md
0d4d3d21f0f000210cbfaa1a30b5afb2f89311babee6e2996a2985ecded8ab87
```

The V6 patcher intentionally accepts only exact V5 or exact V6, creates a timestamped verified V5 backup, patches only the five new branches, verifies the full final SHA-256, and can revert exactly to V5.

---

# 12. Immediate pending V6 runtime test

Do this before any new binary work unless the user has already provided the result.

1. Keep Internet disconnected.
2. Close CK2 fully.
3. Put together:

   ```text
   APPLY_CK2_MJ_V6.bat
   patch_ck2_mj_v6.ps1
   ```

4. Drag the current exact V5 file onto the Apply BAT:

   ```text
   C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe
   ```

5. Require final hash:

   ```text
   f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0
   ```

6. Start that exact executable directly.
7. Use **Single Player → Load Game** first, not Continue.
8. Select `Bosnia1173_03_03.ck2`.
9. Load it without overwriting either evidence save.
10. Confirm both:

    ```text
    date = 3 March 1173
    Heretical Company = 1/6
    ```

11. If manual Load succeeds, fully restart CK2 and separately test:
    - normal Single Player Continue;
    - Monarch’s Journey panel Continue.

The user should return one screenshot showing the March date and 1/6 progress if successful.

If V6 still fails, request only:

- patch-window text;
- screenshot immediately after selecting the March save but before pressing Load/Play;
- screenshot of the immediate result/error.

Do not request another broad log archive yet.

## Interpretation of possible V6 outcomes

### A. March 3 and 1/6 appear

Core save loading and variable restoration work. Then test save → full exit → Continue and verify 1/6 remains.

### B. March 3 appears but progress is 0/6

Actual deserialization works, but the feat reload/initialization path resets or ignores serialized global variables. Investigate Featured Ruler/feat initialization after load, not generic save validity. The save definitely contains `global_heretical_company=1.000`.

### C. The UI still shows January 1

The selected save record is still not reaching the deserialize call. Trace writes/reads of object fields `+0x368` and `+0x3a8`, the caller at `0x1409e6700`, and the actual load transition. Use Process Monitor only if path access remains uncertain; static analysis should remain primary.

### D. Manual Load works but normal Continue fails

Inspect callers of `0x1409e4970`, especially `0x1408145ec`, and the failure path at `0x1407bffa1`. V6 already patches the inline account branch inside `0x1409e4970`, so determine which other non-account predicate rejects Continue.

---

# 13. Reward gallery and score — separate later project

V4 intentionally hides both the obsolete login message and the empty reward container. The local ruler snapshot contains feat definitions/localisation but not the retired account reward catalogue/progression state.

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

Associated descriptions exist in `LT.csv`. Assets appear to remain in the game data.

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

That is expected and separate from local challenge tracking.

Do not start this work until V6 save persistence is resolved.

---

# 14. Porting to CK2 3.3.5.1 — later project

The user asked whether the restoration could be moved to the newest version with all DLC/Steam files. Do not apply May offsets to 3.3.5.1.

The GitHub repository now contains Base64 copies of 3.3.2, 3.3.3, and 3.3.5.1, enabling a proper cross-version analysis later.

Recommended later approach:

1. Reconstruct and verify all binaries.
2. Create binary-diff/function-matching reports for:
   - 3.3.2 remote-only GameSparks implementation;
   - May 3.3.3 Windows local/null implementation;
   - May 3.3.3 Linux symbol-rich null implementation;
   - 3.3.5.1 post-removal.
3. Match functions by constants, strings, control-flow shape, vtables, and call neighborhoods rather than copying raw offsets.
4. Determine whether 3.3.5.1 still has:
   - `CNullGameSpark` parser;
   - highlighted-ruler databases/view classes;
   - Bronzeman save serialization;
   - feat progress evaluation;
   - start/load handlers.
5. If code exists but initialization is disabled, write a separate hash-guarded 3.3.5.1 patcher.
6. If large controller portions were removed, prefer keeping the proven May 3.3.3 build rather than unsafe code injection.

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

The September 2020 retirement build reduced `CK2game.exe` by roughly 775 KiB, so some high-level component was removed or stripped. Do not assume the current build can be restored with the May two-byte factory patch.

---

# 15. Secondary known UI issues

- The ruler portrait tooltip can flicker because of overlapping/small GUI hit regions. This is secondary and does not indicate payload failure.
- The selection map being mostly gray is not a decisive failure. The meaningful tests are populated challenge rows, enabled mode, actual start/load, and live progress.
- Exposing the online reward container under V3 caused `UI Missing Text`; this was the unpopulated default control, not JSON corruption.
- Internet-enabled tests trigger obsolete account-state behavior. Use offline tests for consistency.
- An empty GameSparks folder named approximately `E349414h9BDm` was observed in AppData/Roaming; it has not provided useful cached property data.

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

`LT_featured_ruler.txt` only supplies helper events for Arwa’s conversion challenge.

Do not:

- patch the no-ruler fallback at `0x140727acc`;
- globally force account status to 3, because related pointers remain null;
- restore V3’s forced online reward-container branch;
- force only the final Start control;
- use `wipe_feats`;
- apply May offsets to an unknown or newer executable;
- ask for broad DLL/SO sets unless a critical function is proved to reside there;
- upload or expose `pdx_login.txt`, credentials, passwords, or tokens.

---

# 17. Repository hygiene and expected deliverables

Because the connected GitHub repository contains Base64 game executables, treat it carefully:

- verify every manifest and hash before disassembly;
- do not commit decoded executables if the repository is public;
- never commit a complete modified CK2 executable;
- distribute only patch scripts, analysis reports, hashes, and user-created/test data;
- delete reproducible giant disassembly dumps after extracting concise findings;
- keep a machine-readable patch table with raw offsets, VAs, original bytes, patched bytes, purpose, and expected hashes.

Recommended repository deliverables:

```text
analysis/EXECUTABLE_IDENTITIES.md
analysis/LINUX_NULL_GAMESPARK.md
analysis/WINDOWS_333_PATCH_MAP.md
analysis/WINDOWS_3351_PORT_ASSESSMENT.md       # later
patchers/v6/patch_ck2_mj_v6.ps1
patchers/v6/APPLY_CK2_MJ_V6.bat
patchers/v6/CHECK_CK2_MJ_V6.bat
patchers/v6/REVERT_CK2_MJ_V6_TO_V5.bat
tests/V6_RUNTIME_RESULTS.md
payload/monarchs                            # only if appropriate for the repo
```

After the V6 runtime result, update a concise authoritative status file rather than creating contradictory duplicate reports.

---

# 18. Files the user should additionally provide to the next session/repository

The executable Base64 parts alone are not sufficient context. The user should also place these small/current files in the connected repository or attach them to the next session:

## Required now

1. **This handoff**:

   ```text
   CK2_MJ_ULTIMATE_HANDOFF.md
   ```

2. **Current V6 tools**:

   ```text
   patch_ck2_mj_v6.ps1
   APPLY_CK2_MJ_V6.bat
   CHECK_CK2_MJ_V6.bat
   REVERT_CK2_MJ_V6_TO_V5.bat
   CK2_MJ_V6_TEST_GUIDE.md
   ```

3. **Verified payload**:

   ```text
   monarchs
   ```

   It must have SHA-256:

   ```text
   fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e
   ```

4. **Both evidence saves**, preferably under their real names because GitHub accepts binary files:

   ```text
   Bosnia1173_03_03.ck2
   Bronzeman_kulin_bosnia.ck2
   ```

   If the repository policy requires text, preserve the existing raw `.txt` versions and document that they are ZIP binaries, or Base64-encode them with manifests.

5. **The V6 runtime result**, once tested:

   - full text from the V6 patch window;
   - screenshot showing March 3 and 1/6 if successful;
   - otherwise the two narrowly requested screenshots described in section 12.

## Useful supporting evidence

6. Screenshots 224–229 from the V5 failure, especially:

   - Continue failure;
   - January 1 fallback;
   - 0/6 challenge panel;
   - save-selection screen.

7. The V5 patch transcript and current V5 patcher source, for provenance:

   ```text
   log when patching to v5.txt
   patch_ck2_mj_v5.ps1
   ```

8. Historical reward screenshots and `LT.csv`, only when the reward-gallery project begins.

## Not needed now

Do not additionally provide:

- old broad CK2 log collections;
- generic GUI/GFX files already understood;
- Steam runtime DLLs;
- POPS/online DLL/SO files;
- another copy of the same executable chunks;
- personal account/cache/token files.

---

# 19. Suggested first message to the next session

The user can paste this after attaching/committing the handoff:

> Read `CK2_MJ_ULTIMATE_HANDOFF.md` first and treat it as the authoritative project state. The GitHub repository contains Base64 manifests/parts for Linux May 3.3.3 and Windows 3.3.2, May 3.3.3, and 3.3.5.1. Do not restart the investigation or ask me to re-upload those binaries. The immediate pending task is the V6 runtime save-loading test. Help me perform or interpret that test first, then update the repository’s concise status report. Do not redistribute a modified executable and never tell me to run `wipe_feats`.

---

# 20. Current bottom line

Already working on exact May Windows 3.3.3:

- local eleven-ruler payload;
- Monarch’s Journey arrow/panel;
- challenge names/descriptions;
- Play and Bronzeman start;
- Challenges: Enabled;
- campaign start;
- live in-game challenge evaluation and 1/6 progress.

Not yet runtime-proved:

- actual deserialization of the selected Featured Ruler save;
- Continue after restart;
- persistent challenge progress across reload.

The strongest current static conclusion is that V5 patched only the generic save predicate while five duplicated account gates prevented the selected record from becoming the active load target. V6 patches exactly those five gates and is fully hash-verified, but awaits the user’s Windows runtime result.

Later, separate projects are:

- local score/reward-gallery reconstruction;
- completing the missing five rulers if a late payload can be recovered;
- assessing a safe 3.3.5.1 port using the newly available cross-version GitHub binaries.
