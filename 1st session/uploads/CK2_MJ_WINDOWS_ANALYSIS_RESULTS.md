# CK2 Monarch's Journey — Windows May 3.3.3 binary analysis

## 0. Executive summary

The May 2020 Windows build **does** contain a working local parser for the
Monarch's Journey / highlighted-ruler payload (the same JSON keys Linux uses),
but it is **not** wired to read `common\monarchs_journey\monarchs.txt`. The local
implementation is a **debug/test stub** that is only selected when the player
"username" string is empty, and even then it reads a file literally named
`test.dds` out of the user's save-game directory. The path
`common/monarchs_journey` is registered in the VFS table but has **no code that
opens a file beneath it** — this is why a real `monarchs.txt` in the game folder
has no effect on Windows, regardless of `event_time_end`.

A two-byte, backup-safe patch forces the factory to construct the local stub;
an eight-byte companion patch renames the file it reads from `test.dds` to a
name of equal length (e.g. `monarchs.`). The user then drops the JSON payload
into their CK2 Documents folder under that name. This restores the
arrow/panel, the local ruler schedule, feat scripts and localizations. It
**does not** restore Titus/GameSparks account login or reward synchronization
(that backend is dead), but those are not required to view or play the local
challenges, exactly as on Linux.

The `INT_MAX` failure is fully reproduced in the Windows arithmetic (see §6);
use the 2030 control value `1893499200`.

---

## 1. Verified executable identity

| Field | Value |
|---|---|
| Original file name (manifest) | `CK2game333.exe` |
| Size | 24,753,368 bytes |
| SHA-256 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` |
| Format | PE32+ (x86-64), GUI subsystem |
| Image base | `0x140000000` |
| Linker timestamp | `0x5EB2ACA8` = **2020-05-06 12:25:12 UTC** |
| Sections | `.text`, `.rdata`, `.data`, `.pdata`, `.gfids`, `.tls`, `_RDATA`, `.rsrc`, `.reloc` |

The SHA-256 matches the manifest exactly. The build date matches the expected
pre-removal May 3.3.3 build (Linux build was 2020-05-06 12:57 +0200).

Section table (file offsets):

| Section | RVA | VSize | RawOff | RawSize |
|---|---|---|---|---|
| `.text` | `0x1000` | `0xff62a2` | `0x400` | `0xff6400` |
| `.rdata` | `0xff8000` | `0x44d908` | `0xff6800` | `0x44da00` |
| `.data` | `0x1446000` | `0x492274` | `0x1444200` | `0x297800` |
| `.pdata` | `0x18d9000` | `0x8f73c` | `0x16dba00` | `0x8f800` |
| `.gfids` | `0x1969000` | `0xb20` | `0x176b200` | `0xc00` |
| `.tls` | `0x196a000` | `0x9` | `0x176be00` | `0x200` |
| `_RDATA` | `0x196b000` | `0x23a0` | `0x176c000` | `0x2400` |
| `.rsrc` | `0x196e000` | `0x6858` | `0x176e400` | `0x6a00` |
| `.reloc` | `0x1975000` | `0x24458` | `0x1774e00` | `0x24600` |

---

## 2. Static strings and cross-references

All string RVAs/VA below were confirmed with both `strings` and RIP-relative
instruction scanning of `.text`.

| String | VA | Code xref(s) | Role |
|---|---|---|---|
| `common/monarchs_journey` | `0x1410a4638` | `0x1404ddadb` | VFS mount-table registration only |
| `scheduled_rulers` | `0x141160df0` | `0x140d74c8e`, `0x140d7aaaf` | JSON key, parsed by local loader |
| `can_see_highlighted_rulers` | `0x141160e08` | `0x140d74c70` | JSON key, parsed by local loader |
| `event_time_end` | `0x141160e28` | `0x140d75148`, `0x140d7b732` | JSON key, per-ruler parse |
| `highlighted_ruler_version` | `0x141160ef8` | `0x140d74459`, `0x140d74747` | `GetGuiVersion(14)` style check |
| `highlighted_ruler_window_main` | `0x1410d3998` | `0x14072840d` | Frontend window construction |
| `upcoming_event_window` | `0x1410d3960` | `0x140728447`, `0x1407c0736` | Frontend window construction |
| `gs_test` | `0x1410de038` | `0x140815ec8` | Command-line token |
| `<pineapple>` | `0x141060698` | (data) | Marker, not code |
| `test.dds` | `0x1410d6dd8` | `0x140d74a17` | Hardcoded local-cache filename |
| `gamesparks.userid` / `gamesparks.authtoken` | `0x14115fa38` / `0x14115fa50` | (data) | Account credentials storage |
| `Titus` | `0x1410d380c` | `0x14072a18d` | Titus progression |
| `LOG_IN_TO_PLAY_FEATURED_RULER` | `0x1410d8050` | (UI) | Gating text |

Notably **absent** from the entire binary:

- `CNullGameSpark` / `.?AVCNullGameSpark@@` — no MSVC RTTI for that name. The
  local class is anonymous in the Windows build (it still has a vtable — see §3).
- `monarchs.txt` — the literal filename does not appear anywhere.
- `LoadLocalCache`, `ParseGameSparksData`, `ParsePropertySetKeyData`,
  `GetHasFetchedPropertySet`, `GetGameSparksLocalFileNameWithPath` — these Linux
  symbol names are stripped on Windows, but their functional equivalents exist
  (see §3–§5).
- `FEATURED_RULER_NOT_SUPPORTED_LINUX` — absent, as expected on Windows.
- `GameSparks SDK C++ 1.0` and full RTTI for `GameSparks::Core::*` and
  `CGameSparkImplementation` are present, confirming the real online backend is
  statically linked.

---

## 3. GameSparks factory behavior (question 3 of the handoff)

### Factory: `CGameSparksInterface::CreateInstance` — `0x140d748c0`

Signature (x64): `void* CreateInstance(void* this, std::string* username, bool gs_test, ...)`.

Disassembly of the selection:

```
0x140d748db  mov  rbx, rcx               ; rbx = username std::string*
0x140d748de  mov  rcx, [rip+0xa721a3]    ; load existing singleton (if any)
0x140d748e5  test rcx, rcx
0x140d748e8  je   0x140d748f4
0x140d748ea  mov  rax, [rcx]
0x140d748ed  mov  edx, 1
0x140d748f2  call qword ptr [rax]        ; release old singleton
0x140d748f4  mov  [rip+0xa72189], 0
0x140d748ff  test rbx, rbx
0x140d74902  je   0x140d7492f            ; <<< BRANCH: username == null?
0x140d74904  mov  ecx, 0x5e0             ; sizeof(CGameSparkImplementation) = 1504
0x140d74909  call operator new
0x140d74913  movzx r8d, dil              ; gs_test
0x140d74917  mov  rdx, rbx               ; username
0x140d7491d  call CGameSparkImplementation::ctor (0x140d78c90)
...
0x140d74923  mov  [rip+0xa7215e], rax    ; singleton = real impl
...
0x140d7492f:                             ; username-null path
0x140d74934  mov  ecx, 0x288             ; sizeof(local stub) = 648
0x140d74939  call operator new
0x140d74941  call local_stub::ctor (0x140d74960)
0x140d74947  mov  [rip+0xa7213a], rax    ; singleton = local stub
```

**Behavior:** Windows branches between two implementations. Unlike Linux — which
*always* allocates the null implementation — Windows allocates the real
`CGameSparksImplementation` (1504 bytes) whenever a username string pointer is
passed. The local stub (648 bytes) is reached only when `username` is **null**.

### Is "username null" reachable in normal play?

The sole caller is `0x14081694c` inside the game's startup function
(`0x140814f20`–`0x140817cc7`), immediately after SDL/intro init:

```
0x140816933  call build_username_string (0x140778610)
0x140816939  lea  rcx, [rsp+0x40]        ; &username
0x14081693e  cmp  qword [rsp+0x50], 0
0x140816944  cmove rcx, r13              ; r13 = 0 -> pass null if empty
0x140816948  movzx edx, sil              ; gs_test bool
0x14081694c  call CreateInstance (0x140d748c0)
```

`0x140778610` always constructs a non-empty username string (it falls back to a
hashed machine id even with no profile), so in every real launch the factory
takes the **real GameSparks** branch. The local stub is dead code at runtime.

### `gs_test` handling

The `gs_test` command-line token is parsed at `0x140815ec8` (function
`0x140814f20`). It sets a byte that is passed as `dl`/`sil` to the factory. In
the real constructor `0x140d78c90` it is stored as `[rdi+0x2d0]` and selects the
GameSparks *test* vs *live* server URL — it does **not** select the local stub.
This matches the handoff's Linux finding.

---

## 4. The local implementation (Windows "null" object)

### Constructor: `0x140d74960`

```
0x140d74976  lea  rax, [rip+0x3ec23b]    ; vtable = 0x141160bb8
0x140d7497d  mov  [rcx], rax
...
0x140d749b2  lea  rax, [vfn_18]          ; +0x278
0x140d749b9  mov  [rbx+0x278], rax
0x140d749c0  lea  rax, [vfn_27]          ; +0x280
0x140d749c7  call LoadLocalCache (0x140d749e0)
```

### Vtable `0x141160bb8` (selected slots)

| Slot | Target | Behavior |
|---|---|---|
| 0 | `0x140d73d10` | scalar deleting destructor |
| 1,2,4,5,10–12,25 | `0x1400b0200` (`ret 0`) | no-op (Download/Reconnect/Update etc.) |
| 3 | `0x140d749e0` | **LoadLocalCache** — reads file + parses |
| 6 | `0x14026ecf0` | (connection-state getter) |
| 7 | `0x1402de7b0` | (connection-state getter) |
| 8 | `0x140d74b20` | returns `[this+0x30 + idx*4]` (gui-version array getter) |
| 9 | `0x1400aeb70` (`xor al,al; ret`) | returns **false** |
| 13 | `0x1400aeb90` (`xor eax,eax; ret`) | returns **0** |
| 14,15,17 | `0x1400aeb90` | return 0 |
| 16 | `0x140d73cc0` | returns `&[this+0x1d0]` (the scheduled_rulers vector) |
| 18 | `0x140d74b30` | returns `&[this+0x1e8]` (a std::string) |
| 19 | `0x140d74b40` | thread-safe static initializer (returns a fixed string) |
| 20 | `0x140d74ba0` | thread-safe static initializer |
| 26 | `0x1400aeb80` (`mov al,1; ret`) | returns **true** |
| 27 | `0x140d73cd0` | vector-empty test |
| 28 | `0x140d73d00` | set `[this+0x28]` |
| 29 | `0x140d74c00` | vector "next" iterator |
| 30 | `0x140d74c30` | vector "prev" iterator |
| 31 | `0x140d73c20` | (init) |
| 32–60 | `0x140e3f8f8` | pure-virtual handler / `_purecall` |

This is the Windows analogue of `CNullGameSpark`. The pure-virtual tail means
only slots 0–31 are defined — the object is a deliberately minimal stub.

### `LoadLocalCache` — `0x140d749e0` (the critical part)

```
0x140d74a13  lea  r8d, [rbx+8]
0x140d74a17  lea  rdx, [rip+0x3623ba]    ; "test.dds"
0x140d74a1e  lea  rcx, [rbp-0x11]
0x140d74a22  call std::string::assign (0x1400b0930)   ; filename = "test.dds"
...
0x140d74a37  call qword [rdi+0x278]      ; vfn_18 -> 0x140d74b30 returns &[this+0x1e8]
0x140d74a3d  ...                          ; (that std::string holds the BASE PATH)
0x140d74a4c  mov  rdx, rax
0x140d74a53  call path_append (0x1400b0e10)            ; path = base + "/" + "test.dds"
...
0x140d74ab4  lea  rcx, [rbp+0xf]         ; full path
0x140d74ac2  call file_exists (0x140dcebf0)
0x140d74ac7  mov  rbx, rax
0x140d74acd  je   skip
0x140d74acf  mov  rdx, rax
0x140d74ad2  mov  rcx, rdi
0x140d74ad5  call ParsePayload (0x140d74c40)
```

The base path at `[this+0x1e8]` is the user's CK2 Documents folder (the same
directory used for saves), built by the startup path helpers — **not** the game
install dir and **not** `common/monarchs_journey`. The filename is the literal
8-character string `test.dds` followed by a null, occupying 9 bytes at file
offset `0x10d55d8`. So on Windows the local loader reads:

```
%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\test.dds
```

and parses its contents as JSON regardless of the `.dds` extension. There is no
other caller of `0x140d749e0` (confirmed by direct-call scan).

---

## 5. The local parser — `0x140d74c40`

This is the Windows equivalent of Linux `ParseGameSparksData`/
`ParsePropertySetKeyData`. It is fully functional:

```
0x140d74c70  lea  rdx, "can_see_highlighted_rulers"
0x140d74c7a  call JsonObject::get (0x140dceb20)
0x140d74c84  mov  [rsp+0x98], eax        ; store bool
0x140d74c8e  lea  rdx, "scheduled_rulers"
0x140d74c98  call JsonObject::get
0x140d74ca8  call JsonArray::size (0x140dceb00)
... loop over array elements ...
0x140d74cc5  call JsonArray::get (0x140dceae0)
0x140d74cd2  call ParseScheduledRuler (0x140d75010)
```

`ParseScheduledRuler` at `0x140d75010` reads `event_time_end` (xref
`0x140d75148`) and the other per-ruler fields; a second xref to `event_time_end`
at `0x140d7b732` is the view-state consumer (§6). The parsed rulers are pushed
into the vector at `[this+0x1d0]`, which vtable slot 16
(`0x140d73cc0`) returns — i.e. the same accessor the UI uses.

**Conclusion:** the parser and data model are intact. The only defects are (a)
the factory never selects the object, and (b) it reads a misnamed file from the
wrong directory. Both are patchable.

---

## 6. Expiration arithmetic — `0x1407bc4a0`

The Windows view-state function is byte-for-byte equivalent in logic to the
Linux `CalcCurrentHighlightedRulerViewState`:

```
; rax/rdx = current unix time (seconds)
0x1407bc4ea  mov  eax, [rdi+0x20]        ; event_time_end (signed 32-bit)
0x1407bc4ed  add  eax, 0x15180           ; + 86400 (1 day)
0x1407bc4f4  cmp  rdx, rax
0x1407bc4f7  jl   visible_now            ; return 1
...
0x1407bc51c  mov  eax, [rbx+0x20]        ; next ruler's event_time_end
0x1407bc51f  add  eax, 0x2a300           ; + 172800 (2 days)   <<< at 0x1407bc520
0x1407bc526  cmp  rdx, rax
0x1407bc529  jge  expired
0x1407bc52b  mov  eax, 2                 ; upcoming
```

Return values: `0` = expired/hidden, `1` = active now, `2` = upcoming. The
addition is 32-bit (`add eax, imm32` followed by `cdqe`), so `2147483647 +
172800 = -2147310849` (signed overflow) and the ruler is treated as expired.
This confirms the handoff's INT_MAX diagnosis. The 2030 control value
`1893499200` is safe: cutoff = `1893672000` = 2030-01-03 12:00 UTC.

---

## 7. UI / version gate

- `highlighted_ruler_version` is checked by `0x140d74459` (returns error code
  `0xe` = 14 when the property-set version key is missing/zero) and again at
  `0x140d74747` in the key-registration switch. This is the Windows
  `GetGuiVersion(14)` path. The local stub returns the parsed value via vtable
  slot 8 (`[this+0x30 + 14*4]`), which `ParsePayload` populates from the
  `highlighted_ruler_version` JSON key — so a payload that sets it to a positive
  integer satisfies the gate.
- `highlighted_ruler_window_main` is constructed at `0x14072840d` and
  `upcoming_event_window` at `0x140728447` / `0x1407c0736`. `CHighlightedRulerView`
  RTTI/binder thunks are present at `0x1416db1c0` / `0x1416db260`.
- The "buy CK3" promo arrow you saw is the **upsell fallback** rendered when the
  property set reports no featured ruler; the main-menu branch that chooses
  between MJ and upsell reads the stub's scheduled-ruler vector (slot 16). With
  the stub populated, it takes the MJ branch.

---

## 8. Patch plan (minimal, backup-safe)

Two changes to a **copy** of `CK2game333.exe`:

### Patch A — force the local stub in the factory

| | Value |
|---|---|
| File offset | `0x00d73d02` |
| VA | `0x140d74902` |
| Original bytes | `74 2b` (`je 0x140d7492f`) |
| Patched bytes | `eb 2b` (`jmp 0x140d7492f`) |

This makes `CreateInstance` always take the username-null path, constructing the
648-byte local stub and never touching `CGameSparksImplementation` or the dead
GameSparks/Titus servers. `gs_test` becomes irrelevant.

### Patch B — rename the cache file (length-preserving)

| | Value |
|---|---|
| File offset | `0x010d55d8` |
| Original bytes | `74 65 73 74 2e 64 64 73 00` = `"test.dds\0"` |
| Patched bytes | `6d 6f 6e 61 72 63 68 73 2e` = `"monarchs.\0"` |

Length-preserving (9 bytes including null). The loader then reads
`%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\monarchs.` (the
extension is irrelevant — the contents are parsed as JSON). The name is chosen
to stay at exactly 9 bytes so no relocation/string-boundary is disturbed; the
file is written by the user, not by the game.

> **Why not `monarchs.txt`?** That string is 12 bytes; the static string is only
> 9 bytes before the next object, and overwriting would corrupt adjacent
> `.rdata`. The 8-char `monarchs.` is the longest equal-length replacement.
> The game ignores the extension when parsing.

### Payload placement and content

After patching, place the working Linux-format payload at:

```
%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\monarchs.
```

It must be plaintext JSON containing at minimum:

```json
{
  "highlighted_ruler_version": 1,
  "can_see_highlighted_rulers": 1,
  "scheduled_rulers": [
    { "event_time_end": 1893499200, ... }
  ]
}
```

Use `1893499200` (2030-01-01 12:00 UTC), **not** `2147483647`. The existing
Linux `monarchs.txt` content can be copied verbatim and renamed to `monarchs.`.

After first launch the game may write a `gamesparks.userid` /
`gamesparks.authtoken` cache file in the same folder; this is harmless and unused
by the stub.

### What works / what stays dead after patching

| Feature | Status |
|---|---|
| Monarch's Journey arrow + main panel | ✅ restored |
| Scheduled/upcoming ruler display | ✅ restored (local JSON) |
| Feat scripts, localizations, portraits | ✅ restored (read from game VFS as normal) |
| Local feat progress | ✅ works (stored in savegame, as on Linux) |
| `feat_log` console diagnostic | ✅ works |
| GameSparks/Titus account login | ❌ stays dead (server retired) |
| Reward/chest synchronization to Paradox account | ❌ stays dead |
| "Buy CK3" promo arrow | ❌ replaced by MJ arrow when data present |

The dead reward path is the same state as the native Linux 3.3.3 build and is
not needed to view or play local challenges.

### Risks

- The patch skips the real GameSparks constructor entirely. Any code path that
  calls an interface method beyond slot 31 on the returned object would hit
  `_purecall`; static analysis shows the interface consumer only uses slots 0–30
  (the same set the stub defines), matching Linux's `CNullGameSpark`.
- Steam achievements are unaffected (separate `steam_api`).
- Multiplayer/ironman: the local object returns "offline" status; this is the
  same state as an unreachable backend. No new risk vs. launching with no
  network.
- Reverting restores the exact original bytes; the patcher verifies SHA-256 and
  every original byte before writing and keeps a `.bak`.

---

## 9. Why the in-game `monarchs.txt` test failed

Your 2030 test with `<CK2 root>\common\monarchs_journey\monarchs.txt` could not
work on Windows because:

1. The factory always constructs `CGameSparksImplementation` (online), never the
   local stub (§3).
2. Even the local stub reads `test.dds` from the Documents folder, not
   `common/monarchs_journey/monarchs.txt` (§4).
3. The string `monarchs.txt` does not exist in the executable, and
   `common/monarchs_journey` is only a VFS mount registration with no file-open
   xref (§2).

So the file was never opened. This is a Windows-only divergence from Linux
3.3.3, where `CNullGameSpark::LoadLocalCache` reads the VFS path directly.

---

## 10. Deliverables in this folder

- `CK2game333.exe` — reconstructed original (verified SHA-256, unmodified).
- `CK2_MJ_WINDOWS_ANALYSIS_RESULTS.md` — this report.
- `patch_ck2_mj.py` — backup-safe Python patcher (apply/revert/verify).
- `patch_ck2_mj.ps1` — equivalent PowerShell patcher (no Python needed).
