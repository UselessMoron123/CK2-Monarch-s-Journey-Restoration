# CK2 Monarch's Journey Windows 3.3.3 — corrected v2 findings

## Status

The user's runtime test conclusively showed that the earlier branch-only patch
was insufficient. The uploaded executable was reconstructed and independently
verified:

- Patched input size: `24,753,368`
- Patched input SHA-256: `854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c`
- Restoring `74 2b` at `0x00d73d02` produces the exact original SHA-256:
  `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8`

## Root cause found

The returned Windows report's Documents-path analysis was incorrect.
Independent disassembly shows:

1. `CNullGameSpark::LoadLocalCache` passes storage location `0` and filename
   `test.dds` to the load callback at `0x140778030`.
2. The callback's path builder at `0x140777ee0` maps location `0` through
   `GetOriginalDirectory(2)`.
3. The `CDirectorySettings` constructor initializes original-directory index 2
   to the literal `gfx` (`0x1404dd2fe` through `0x1404dd312`).
4. Therefore the unmodified Windows local loader requests:

   ```text
   <game folder>\gfx\test.dds
   ```

There is a second, more important collision: startup username generation at
`0x140778610` also reads and may rewrite the same location-0 `test.dds` before
the factory constructs the local GameSparks object. A JSON payload placed at
`gfx\test.dds` is not a valid username-cache record and can be replaced before
the local parser sees it.

This means neither merely forcing the local branch nor globally renaming the
shared `test.dds` string is sufficient.

## Correct v2 strategy

Patch only the filename reference inside `CNullGameSpark::LoadLocalCache`, not
the shared static string. Its existing assignment length is eight characters.
An existing read-only string `monarchs_journey` is reused; assigning its first
eight bytes produces the distinct filename `monarchs`.

### Patch 1 — force local implementation

- File offset: `0x00d73d02`
- Original: `74 2b`
- Patched: `eb 2b`

### Patch 2 — redirect only the local loader's filename reference

- Instruction VA: `0x140d74a17`
- Displacement file offset: `0x00d73e1a`
- Original displacement: `ba 23 36 00` → target `0x1410d6dd8`, `test.dds`
- Patched displacement: `21 fc 32 00` → target `0x1410a463f`, first eight
  bytes `monarchs`

This changes no instruction length and does not overwrite `.rdata`. Other
`test.dds` references, including the username cache, remain untouched.

### Finished v2 executable identity

- Size: `24,753,368`
- SHA-256: `1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175`

### Exact v2 payload path

```text
<game folder>\gfx\monarchs
```

The payload filename has no extension. The supplied `monarchs` file is the same
validated plain JSON as the 2030 control:

- Size: `101,949`
- SHA-256: `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`

## Parser confirmation

Independent disassembly confirms that the local parser:

- reads `can_see_highlighted_rulers`;
- reads and iterates `scheduled_rulers`;
- stores `can_see_highlighted_rulers` at temporary settings offset `+0x38`;
- copies that settings array to the local object's GUI-version array;
- therefore maps it to integer slot 14 (`0x38 / 4`), the highlighted-ruler GUI
  version.

The extra root key `highlighted_ruler_version` is not required. The supplied
payload's existing `can_see_highlighted_rulers: 1` is correct.

## Prepared files

- `APPLY_CK2_MJ_V2.bat` — drag-and-drop wrapper; applies v2 and installs the
  payload.
- `patch_ck2_mj_v2.ps1` — SHA-verified PowerShell patcher.
- `monarchs` — extensionless 2030 payload.
- Updated `check_ck2_mj.ps1` — recognizes original, branch-only, and v2 states
  and checks `gfx\monarchs`.
- Existing `CHECK_CK2_MJ.bat` — wrapper for the updated checker.

## Apply

Keep these three files together:

```text
APPLY_CK2_MJ_V2.bat
patch_ck2_mj_v2.ps1
monarchs
```

Drag the exact May executable onto `APPLY_CK2_MJ_V2.bat`. The patcher accepts
and fully normalizes/verifies the original, the earlier branch-only state, or
an already-complete v2 state. It creates:

- a backup of the current state; and
- a reconstructed original whose SHA-256 is checked against the exact May
  original.

The wrapper then copies and verifies `monarchs` at `gfx\monarchs` beside the
selected executable's game root.

Launch that exact executable directly. The old payload copies in
`common\monarchs_journey` and the CK2 user-data root are not used by this v2
loader and may be removed after successful testing.

## Revert

```powershell
powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v2.ps1 Revert .\CK2game_MJ.exe
```

The restored original SHA-256 must be:

```text
656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8
```

Do not use `wipe_feats`.
