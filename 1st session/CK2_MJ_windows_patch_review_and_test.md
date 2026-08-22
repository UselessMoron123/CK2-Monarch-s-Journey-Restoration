# CK2 3.3.3 Monarch's Journey — Windows patch review and cautious test plan

> **SUPERSEDED:** Runtime testing and independent disassembly of the uploaded
> Windows executable proved that the branch-only procedure below is incomplete.
> Use `CK2_MJ_windows_v2_findings.md`, `APPLY_CK2_MJ_V2.bat`, and
> `patch_ck2_mj_v2.ps1` instead. The corrected payload path is
> `<game folder>\gfx\monarchs`.

## Bottom line

**Do not run either patcher returned with the Windows report.** Both contain an
unsafe length mismatch in their second patch.

The safest candidate is a **single two-byte patch** to the verified exact May
2020 executable. It forces the factory to instantiate the already-present local
(null) GameSparks implementation. It leaves the loader's hardcoded filename as
`test.dds` and therefore avoids modifying static string storage at all.

Files prepared here:

- `patch_ck2_mj_minimal.ps1` — recommended Windows PowerShell patcher.
- `patch_ck2_mj_minimal.py` — equivalent Python 3 patcher.
- `test.dds` — plain-JSON 11-ruler payload with safe 2030 expiration values.

## Verified executable identity expected by the patchers

- Size: **24,753,368 bytes**
- SHA-256: **656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8**
- Build: exact pre-removal May 2020 Windows CK2 3.3.3

The identity values originate in the returned Windows report. The patchers
check the user's actual file before writing and refuse any mismatch.

## Review of the returned patch proposal

### Patch A: internally consistent and retained

- File offset: `0x00d73d02`
- Original: `74 2b` — `je` to the local/null branch when username is null
- Patched: `eb 2b` — unconditional short jump to the same local/null branch

The reported PE section mapping is internally consistent: VA `0x140d74902`
maps to raw offset `0x00d73d02`. This changes no instruction length and keeps
the same branch target.

### Patch B: unsafe as supplied and omitted

The original field is exactly nine bytes:

```
74 65 73 74 2e 64 64 73 00  =  test.dds\0
```

Both returned scripts try to write ten bytes:

```
6d 6f 6e 61 72 63 68 73 2e 00  =  monarchs.\0
```

That is not length-preserving. It writes one byte beyond the original field.
Writing only `monarchs.` without a NUL would also be unsafe because the string
would no longer terminate in its field. A valid same-size replacement would be
`monarchs\0` (eight characters plus NUL), but there is no need to take that
extra risk: the corrected patchers leave `test.dds` unchanged.

If either original returned patcher has already been run, restore the `.bak`
created by it before using the corrected minimal patcher.

## Important correction to the returned path analysis

The report did **not** actually establish its claimed Documents path.

In `LoadLocalCache`, the indirect call through the function pointer at object
offset `+0x278` is the storage **load callback**, which returns the file's
contents. It is not a getter returning a base directory. The later sequence the
report labels `file_exists` followed by `ParsePayload` instead matches:

1. test returned content for empty;
2. parse content with `cJSON_Parse`;
3. call the local payload parser with the returned JSON node.

This is also the exact structure of the independently disassembled Linux
`CNullGameSpark::LoadLocalCache`.

The strongest cross-platform evidence currently points to the install tree:
Linux passes `GameSparksStorageLocation = 0`, and the game's shared storage
callback maps location 0 to its original directory entry
`common/monarchs_journey`. The best-supported first Windows location is thus:

```
<FOLDER CONTAINING CK2game333.exe>\common\monarchs_journey\test.dds
```

The Windows callback body was not included in the returned report, so the
Documents alternative is retained only as a controlled fallback to test:

```
<actual CK2 user-data folder>\test.dds
```

The actual user-data folder is the one containing CK2's `settings.txt`, `logs`,
`save games`, etc. It may be redirected by OneDrive or a custom `-userdir`, so
do not assume that a literal `%USERPROFILE%\Documents` path is always correct.

For an exact path observation without trial-and-error, Microsoft Process
Monitor can be filtered to the patched executable and paths ending in
`\test.dds` during one launch.

## Payload

`test.dds` is plain JSON despite its extension. It is byte-for-byte identical
to `monarchs_reactivated_2030.txt`.

- Size: **101,949 bytes**
- SHA-256: **fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e**
- Rulers: 11
- `can_see_highlighted_rulers`: 1
- Every `event_time_end`: `1893499200`

The 2030 value is deliberate. Do not substitute `2147483647`: the game adds
172,800 seconds in signed 32-bit arithmetic, causing overflow and hiding the
ruler.

The local parser accepts ordinary JSON. Do not add the encrypted
`<pineapple>` marker.

## Recommended Windows procedure

Work on a copy of the exact May executable, not the only copy and not a newer
3.3.3 executable.

### 1. Put these files together temporarily

- `CK2game333.exe` (or whatever your exact May executable copy is named)
- `patch_ck2_mj_minimal.ps1`

### 2. Verify before writing

Open PowerShell in that folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Verify .\CK2game333.exe
```

Expected state: `original`, expected size, and the SHA-256 shown above. Stop if
the script refuses the file.

### 3. Apply the minimal patch

```powershell
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Apply .\CK2game333.exe
```

The script:

1. accepts only the exact original SHA-256 and size;
2. creates `CK2game333.exe.pre_mj_patch.bak`;
3. re-verifies that backup;
4. patches only `74 2b` to `eb 2b` at `0x00d73d02`;
5. verifies the full result by restoring the original bytes in memory and
   checking that the normalized SHA-256 equals the known original hash.

Record the patched SHA-256 printed by the script.

### 4. Install the payload at the best-supported first location

Copy the supplied `test.dds` to:

```text
<game folder>\common\monarchs_journey\test.dds
```

Keep the filename exactly `test.dds`; do not let Explorer turn it into
`test.dds.txt`.

For a clean path test, do **not** put a second copy in the user-data folder yet.

### 5. Launch the patched executable directly

Launch the patched exact-May executable directly for this first test. Confirm
that the Monarch's Journey frontend/panel and ruler data appear. A continuing
Titus fetch failure in logs is not by itself proof of failure; the local
GameSparks payload and Titus are separate.

This test is expected to restore the local challenge UI and data. It cannot
restore the retired server-side CK3 reward/perk grant service.

### 6. If the UI does not appear

Do not make any further executable edits. Copy the same `test.dds` into the
actual CK2 user-data root and launch once more. Report which placement works.
If neither works, revert and capture:

- the patcher's printed patched SHA-256;
- CK2's relevant log tail;
- preferably a Process Monitor line showing the attempted `test.dds` path.

That separates a path issue from a parser/UI issue without speculative binary
changes.

## Revert

```powershell
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Revert .\CK2game333.exe
```

The script refuses to restore unless the backup has the exact verified
original SHA-256. Afterward, remove the added `test.dds` file if desired.

Do **not** use the irreversible `wipe_feats` command.

## Python alternative

If Python 3 is already installed on Windows:

```powershell
python .\patch_ck2_mj_minimal.py verify .\CK2game333.exe
python .\patch_ck2_mj_minimal.py apply  .\CK2game333.exe
python .\patch_ck2_mj_minimal.py revert .\CK2game333.exe
```

Its validation, backup, normalized-hash verification, and one-patch policy are
equivalent to the PowerShell version.
