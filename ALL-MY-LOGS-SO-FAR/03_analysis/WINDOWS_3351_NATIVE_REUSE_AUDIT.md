# Windows 3.3.5.1 native-reuse audit — first pass

Date: 2026-08-31. Target SHA-256:
`a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d`
(24,236,024 bytes). This continues, rather than replaces,
`WINDOWS_3351_PORT_ASSESSMENT.md`.

## Question

Can a normal CK2 mod, or a small native redirect plus mod files, feed ruler/challenge
data into the feat machinery which survives in 3.3.5.1?

## Method

- verified PE image and section mapping;
- exhaustive string occurrence search;
- GNU objdump xrefs for retained MJ/feat strings;
- `.pdata` lookup for containing function boundaries;
- comparison with known May-3.3.3 and Linux-3.3.3 semantics.

No 3.3.3 offsets were applied to 3.3.5.1 and no executable was modified.

## Findings

### 1. The two promising directory names are registration fields, not loaders

`red_king/ruler_feats` (`VA 0x1410372F0`) has one code xref:

- `0x1404DDEE9`, inside `0x1404DD640–0x1404DDF54`.

`common/monarchs_journey` (`VA 0x1410372C0`) also has one code xref:

- `0x1404DDF34`, in the same function.

The function is the large `CDirectorySettings` constructor. Both references have the
same repeated form as neighboring directory strings:

```text
lea rcx, [rdi + field]
mov r8d, literal_length
lea rdx, [directory_string]
call CString assignment/constructor
```

There are no other direct code references to either literal. Therefore these strings
prove only that VFS directory names remain registered. They do **not** expose a
surviving disk-to-feat-database load path.

This materially weakens the easiest hybrid proposal: simply placing challenge files
under those mod directories is unlikely to initialize the native highlighted-ruler
feat database.

### 2. Native feat display/storage helpers genuinely survive

`RULER_FEAT_LEVEL_` (`VA 0x14106C148`) is referenced at `0x1407BA45B`, inside
function `0x1407BA3C0–0x1407BA53D`. Its code constructs the localization key from a
numeric level and resolves it, matching the previously identified `GetFeatLevelName`.
This is active implementation code, not merely an orphaned string.

The executable also retains `feat_progress_storage.cpp`, Bronzeman save/autosave
strings, `feat_progress`, reward progression, and the four `extend_featured_ruler`
functions already mapped in the earlier assessment. Thus the downstream system remains
a plausible native target if definitions can be supplied.

### 3. The retained highlighted-ruler GUI is only a fragment

`highlighted_ruler_toggle_open` (`VA 0x14106C2C0`) is referenced at
`0x1407BD887`, inside function `0x1407BD7C0–0x1407BDB21`. Toggle-close and a generic
`highlighted_ruler_icon` also survive.

The full May-3.3.3 main-window string family and controller are absent. A working data
feed alone therefore would not automatically restore the original main-menu panel.
At best, native tracking could be paired with a new scripted/in-game presentation;
at worst, a new frontend controller would also be required.

### 4. `extend_featured_ruler` is not the missing loader

The one retained command literal has five xrefs across the four already-known
functions:

| Function | Literal xref(s) |
|---|---|
| `0x140729CE0–0x14072BC39` | `0x14072AC85` |
| `0x14072BC80–0x14072C536` | `0x14072C052` |
| `0x14072C540–0x14072C9A8` | `0x14072C86E`, `0x14072C941` |
| `0x14072E7E0–0x14072E931` | `0x14072E810` |

This is retained bookmark/ruler-extension flow. It may help start or extend a selected
ruler, but there is no evidence that it parses payload JSON or loads a feat script.

### 5. The original payload bridge remains absent

The first pass reconfirms that 3.3.5.1 contains none of the decisive input literals:

- payload schema keys such as `scheduled_rulers` and `feats_script`;
- `gs_virtual/feat_script`;
- the broad GameSparks parser/client string family.

The May path depended on those components to construct highlighted-ruler objects and
feed an embedded PDX script to `TSingleObjectGameDatabase::LoadFile`. Their absence is
why GameSparks matters architecturally even though no network service is needed.

## Interim verdict

| Port idea | First-pass result |
|---|---|
| Pure mod files in `red_king/ruler_feats` or `common/monarchs_journey` | **No direct loader found; unlikely without an additional hook** |
| Small redirect to an already surviving feat-file loader | **Not yet found; still worth function-level search** |
| Reuse native tracking/cache with a small injected data adapter | **Plausible, but requires object/database ABI work** |
| Recreate MJ as ordinary scripted mod | **Still the highest-confidence route** |
| Restore exact native main-menu MJ | **Requires more than feeding data; controller/UI code is missing** |

## Next static work

1. Function-match the May and 3.3.5.1 neighborhoods around `GetFeatLevelName`, feat
   progress storage, Bronzeman, and highlighted-ruler toggle code.
2. Locate all 3.3.5.1 callers that create, clear, or query the surviving feat tracker.
3. Search those call graphs for a generic `CReader`/`TGameDatabase::LoadFile` route,
   not merely string xrefs.
4. Determine whether `extend_featured_ruler` can establish the native
   `special_event`/ruler identity independently of the removed controller.
5. If no definition loader survives, stop pursuing a byte-only hybrid and build the
   one-ruler scripted-mod prototype before considering a DLL adapter.

## User input needed

None for static analysis. A 3.3.5.1 runtime test will be requested only if a concrete
file path, hook, or observable native initialization point is found.
