# CK2 Monarch's Journey — V5 runtime result and feat-persistence root cause

## Status from the V5 offline load test (screenshots 224–229)

You confirmed, and the screenshots show:

- V5 checker reports the green **CORRECT V5 OFFLINE LOAD PATCH** (hash
  `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`).
- Test run fully offline.
- **Single Player → Load Game → `Bosnia1173_03_03.ck2` now loads successfully**
  into the map. The retired Paradox-account gate V5 targeted is defeated.
- In-game Monarch's Journey panel renders Kulin and all three challenges.
- But **Heretical Company shows `0/6`, Current Progress: 0**, whereas the V4
  session that wrote the save had advanced it to `1/6`.

So **V5 fixed loading**; the one thing that does not survive a save/load is
**challenge (feat) progress persistence**.

Screenshots 224 ("Continue failed!"), 225 ("Game State is corrupted"), and 227
("Challenges: Disabled" with red checksum/Steam rows) predate the V5 result or
are the gray Continue path; 228/229 are the successful V5 load. They are kept
for the record.

## Root cause: `feat_progress` is written but never read

The save section token `0x3816` is the string `"feat_progress"`, registered at
file region near `0x14009a65e`.

### Write side (works)

In the binary save **writer** (`0x1409dede0`), the `feat_progress` case at
`0x1409df82f` is fully implemented:

```
cmp eax, 0x3816            ; "feat_progress"
jne ...
; copies the 0x28-byte feat entry block, then:
lea  rcx, [rsi + 0x138]    ; the feat_progress vector in the game state
lea  rdx, [rbp - 0x80]
call 0x1409e8200           ; write vector (0x28 bytes per entry)
```

The helper `0x1409e8200` serializes `(end - begin)/0x28` entries of 40 bytes
each, and each entry is written by `0x1409e8320` (a string id + a uint32
counter at `+0x20`). This is why `Heretical Company = 1` was saved to disk.

### Read side (missing)

In the binary save **reader** (`0x14077f8b0`), the matching case is at
`0x1407824a5`:

```
cmp  r8d, 0x3816           ; "feat_progress"
jg   0x1407824ff
je   0x140782dc6           ; <<< jumps STRAIGHT to the function epilogue
sub  r8d, 0x3762           ; other tokens...
je   ...
```

The `je 0x140782dc6` lands on the shared epilogue (`mov rbx,[rsp+0x1430]; add
rsp,0x13f0; pop ...; ret`) and does **nothing else**. There is no call to any
deserializer for this token anywhere in the reader. Confirmed three ways:

1. The only code reference to immediate `0x3816` in the whole executable is the
   registration (`0x14009a666`), the write case (`0x1409df830`), and this read
   case (`0x1407824a8`).
2. The read case contains no call; it jumps directly to the epilogue.
3. A vector deserializer for these 40-byte entries exists at `0x140d75fd8` and
   calls the matching element reader `0x140d76860`, but **nothing references
   `0x140d75fd8`** — no direct call, no RIP-relative `lea`, no vtable pointer.
   It is dead code left in the binary.

Net effect: every time a save is loaded, the feat_progress vector stays empty,
so all challenges display `0/x` regardless of what was saved. This is a
build-level omission in the May Windows 3.3.3 binary (the corresponding Linux
build reads it; the Windows writer was left in but the reader case was routed
to the epilogue, almost certainly a retired-backend remnant).

It is **not** caused by V4/V5 patching; V5 only added the two save-selector
branches. It explains why progress reset after the clean-process reload.

## Fix design (V6)

Make the `0x3816` read case call a small routine that deserializes the
`feat_progress` vector into `[game_state + 0x138]`, mirroring the writer. The
unused reader `0x140d75fd8` is not directly callable with the reader's
register state, so the safe approach is a tiny trampoline in a code cave that:

1. sets up the destination vector at `[r13 + 0x138]` (r13 = game state in the
   reader);
2. passes the archive node for the current token (the reader already has it in
   the register/stack used by sibling cases);
3. invokes the element loop (the existing `0x140d75fd8` logic or an inlined
   equivalent using `0x140701be0`/`0x140d76860`);
4. jumps to the epilogue `0x140782dc6`.

The exact bytes for V6 are being finalized by disassembling the archive node
access used by sibling vector cases in `0x14077f8b0`. V6 will:

- keep all 16 V5 patch entries unchanged;
- add one branch redirection at file offset `0x007814ae`
  (`0x1407824ae`, currently `e9 .../eb ...` → jump to the new cave);
- place the cave in an `.text` int3 padding region or (preferred) expand via a
  verified code-cave with relocation;
- produce a new guarded hash that accepts original, V2, V3, V4, V5, and V6.

Because this patch adds new code rather than flipping branches, it is larger and
must be tested carefully: first verify it does not crash on a save that has
`feat_progress`, then on a save without it, then on a brand-new game. The
existing two Kulin saves are ideal for the first test.

## What is and isn't restored after V6

| Layer | V4/V5 today | After V6 |
|---|---|---|
| MJ arrow / panel / ruler list | works | works |
| Start a Bronzeman challenge game | works | works |
| Live in-session progress tracking | works | works |
| Load an MJ save offline | works (V5) | works |
| Progress restored after load | **resets to 0** | **restored** |
| Titus/GameSparks account rewards | dead | still dead (out of scope) |

## Immediate recommendation

Do **not** start a long challenge campaign expecting progress to survive until
V6 is in and tested. Short tests are fine. For now V5 is the safe baseline for
all other MJ functionality.

## Update (2026-08-20): V6 not shipped — stay on V5

After fully tracing the read path, there is **no in-binary reader** for the
40-byte feat_progress entries:

- Writer `0x1409df82f` → helper `0x1409e8200` writes a contiguous vector of
  0x28-byte entries via `0x1409e8320`.
- Read case `0x1407824ae` jumps straight to the epilogue (no-op).
- Candidate functions examined are not usable:
  - `0x1409e82a0` is a std::for_each-style post-processor over an already-built
    array, not an archive reader;
  - `0x140c38f30` is a template specialized on hardcoded tokens (0x2ae/0x2af…)
    for a different data type;
  - `0x140d75fd8` builds an in-memory hash map, not the game-state vector;
  - `0x1409e2e10` is the save-game browser/manager.

A correct fix therefore requires new deserialization code (appended section +
archive child-list walk + vector population). Without being able to runtime-test
on the user's machine, an error would crash on load or risk save corruption.

**Recommendation: keep V5 as the final version.** It restores the panel,
ruler list, starting/playing Bronzeman challenges, live in-session progress,
and offline loading. The only limitation is that feat counters reset if you
fully quit and reload; complete a challenge within one session to work around
it. Do not apply experimental V6 builds from other sources without backups.
