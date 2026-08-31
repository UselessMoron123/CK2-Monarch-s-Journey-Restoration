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

## Second pass — function matching and call graph

### 6. `UpdateFeatProgress` survives almost intact

Instruction-normalized function matching found an unambiguous pair:

| Build | Function | Size | Normalized match |
|---|---:|---:|---:|
| May 3.3.3 | `0x1407B8E60–0x1407B933F` | `0x4DF` | reference |
| 3.3.5.1 | `0x1407BB600–0x1407BBACF` | `0x4CF` | **0.990** |

The missing 16 bytes are meaningful. May starts by calling
`CalcShouldTrackFeatProgress`; 3.3.5.1 instead checks one global feature-enabled byte
at `0x141666C03` and returns when it is zero. The remaining update body is effectively
the same and still walks the feat databases, runs script updates, records current
values, and reaches feat-progress storage.

Both engine update sites also survive:

- daily caller `0x1406675A6`: check global byte → tracker accessor
  `0x1407BABD0` → `UpdateFeatProgress`;
- restore/load caller `0x140789AA8`: the same sequence.

The tracker accessor itself matches exactly:

| May 3.3.3 | 3.3.5.1 | Size | Match |
|---:|---:|---:|---:|
| `0x1407B8270` | `0x1407BABD0` | `0x68` | **1.000** |

This proves 3.3.5.1 retains a callable native tracker and both normal scheduling
paths. It is not merely dead storage code.

### 7. The three native feat-database consumers survive

The matched update bodies expose corresponding singleton/database globals:

| Role in update | May 3.3.3 | 3.3.5.1 |
|---|---:|---:|
| primary feat-definition database | `0x1418D6C78` | `0x14185A770` |
| secondary/complete database | `0x1418D6CB0` | `0x14185A798` |
| current/level database helper | `0x1418D6C00` | `0x14185A6F0` |

The 3.3.5.1 update function dereferences all three in the same positions as May. The
problem is therefore population and activation, not absence of consumers.

### 8. The low-level `CReader` feat parser survives; its data-source wrappers do not

May's two `gs_virtual/feat_script` references are inside:

| May function | Size | Meaning |
|---|---:|---|
| `0x1407B7950–0x1407B7C3C` | `0x2EC` | initialize one highlighted-ruler feat database from the current ruler's embedded script |
| `0x1407B7C40–0x1407B808C` | `0x44C` | initialize the complete database by iterating ruler scripts |

Function matching found no credible 3.3.5.1 equivalents (best normalized scores
`0.707` and `0.560`, in unrelated regions). These are the removed GameSparks-facing
wrappers.

However, the second wrapper constructs an in-memory/VFS `CReader` and calls May
`0x1407B9850`. That low-level reader/database function has a same-size, instruction-
identical neighborhood counterpart in 3.3.5.1:

| May 3.3.3 | 3.3.5.1 | Size | Match |
|---:|---:|---:|---:|
| `0x1407B9850–0x1407B9CB3` | `0x1407BBF70–0x1407BC3D3` | `0x463` | **1.000** |

Several template instantiations share this normalized shape, so the exact C++ template
type still needs confirmation from vtables/call context. The neighborhood and field
usage make `0x1407BBF70` the strongest corresponding feat-database reader candidate.

This changes the port outlook: we probably do **not** need to reimplement feat-script
parsing. We need a small replacement for the removed wrapper which creates a `CReader`
from a local script and invokes the surviving database loader, then enables the global
feature byte.

### 9. Reader/VFS support also survives exactly

The May wrapper's helper calls were function-matched independently:

| Purpose in May wrapper | May 3.3.3 | 3.3.5.1 | Size | Match |
|---|---:|---:|---:|---:|
| construct reader wrapper (`CReader` path/object form) | `0x140C38080` | `0x140C32650` | `0xD8` | **1.000** |
| destroy/close reader wrapper | `0x140C38310` | `0x140C328E0` | `0xEB` | **1.000** |
| build/register the virtual in-memory input used before reader construction | `0x140C5CD70` | `0x140C57320` | `0x400` | **1.000** |

The corresponding May cleanup family around `0x140C5D170` is in the same surviving
3.3.5.1 subsystem neighborhood. This strongly suggests the engine still has all generic
VFS/reader primitives needed to parse a PDX feat script; what was removed is the
highlighted-ruler-specific orchestration and its source payload.

A proof of concept no longer needs to implement JSON, a parser, or a new file reader.
It can convert the existing JSON to one plain feat script externally, then use the
surviving VFS/reader and database calls. Exact argument ownership and destructor order
must be recovered before any runtime invocation.

### 10. Exact limits of a prospective native adapter

A minimum adapter would still have to:

1. select or receive a ruler identity;
2. read that ruler's plain PDX feat script from the mod directory;
3. construct the game-compatible `CReader` and target database instance;
4. call the surviving loader around `0x1407BBF70`;
5. populate both current and complete definitions as required;
6. set the feature-enabled state used at `0x141666C03`;
7. establish `special_event`/Bronzeman identity, probably with a scripted setup plus
   surviving `extend_featured_ruler` flow.

It would not by itself recreate the removed main-menu MJ panel. A practical hybrid
would use a normal mod for ruler selection and presentation, with the adapter only for
native challenge evaluation, cache, tiers, and notifications.

## Revised interim verdict

| Port idea | Second-pass result |
|---|---|
| Pure file drop with no hook | **Rejected:** directory registration has no feat-loader xref |
| Byte-only offset port | **Rejected:** the two data-source wrappers are removed |
| Small native data adapter + mod UI/setup | **More promising:** scheduler, tracker, databases, progress storage, and low-level reader survive |
| Entirely scripted mod | **Still safest and most maintainable fallback** |
| Exact original frontend | **Separate high-difficulty reconstruction** |

## Next static work

1. Confirm which of the identical `0x463` template instances is the exact feat target;
   `0x1407BBF70` is the neighborhood match but vtable identity must settle it.
2. Recover the exact ownership/argument contract across surviving virtual-input helper
   `0x140C57320`, reader constructor `0x140C32650`, loader candidate, and destructor
   `0x140C328E0`.
3. Identify construction/reset routines for globals `0x14185A770`, `0x14185A798`,
   and `0x14185A6F0`.
4. Trace `extend_featured_ruler` writes to determine whether it can establish
   `special_event` and Bronzeman mode without the old frontend.
5. Then choose between a minimal proof-of-concept adapter and the one-ruler scripted
   mod prototype.

## User input needed

None for static analysis. A 3.3.5.1 runtime test will be requested only after a
concrete loader invocation or mod-file experiment is ready.
