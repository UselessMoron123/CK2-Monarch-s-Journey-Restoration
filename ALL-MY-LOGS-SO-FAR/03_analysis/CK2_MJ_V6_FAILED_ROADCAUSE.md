# V6 attempt — root cause and why it is NOT shipped

## Status

V6 binary `a6cb92b8…` was built and tested by the user. It was **BAD** and has
been reverted. It caused:

- save-load parse errors ("Unexpected token: fem/dna/properties/culture…");
- crashes on resign and on changing bookmark;
- feats not counting.

Cause: the trampoline called `0x1409e8200` during a load. That function is a
**vector append / insert into the in-memory vector**, not a deserializer of the
on-disk node. Invoking it on the archive corrupted the parser state. The hash
and disassembly were correct; the *semantics* (data direction / role) were wrong.

## Accurate read of the code

### Save writer (token 0x3816 "feat_progress") — `0x1409dede0`, case `0x1409df82f`

- `[rsi+0x138]` = the in-memory feat vector (game state), element size 0x28:
  `{ std::string key (0x20 bytes); uint32 counter at +0x20; padding }`.
- The writer iterates the archive's child nodes (`[rbp+0xe8]`), and for each
  child builds a local entry on the stack at `[rbp-0x80]`:
  - key string copied from `[rbp+0xf4]` via `0x1400b0930`,
  - counter written via `0x140e4806c` to `[rbp+0x4fc]` (= local+0x60? verify),
  - then `0x1409e8200(vec, &local)` appends that local entry into the vector.
- `0x1409e8200(dest_vec*, src_entry*)` is a vector APPEND: it copies one 0x28
  element (string via `0x1400b0930`, counter via `[src+0x20]`) into the vector
  (`0x1409e8320`) and advances `vec.end` by 0x28, growing via `0x1406bcdb0`.

### Save reader (token 0x3816) — `0x14077f8b0`, case `0x1407824a5`

- The case is `cmp r8d,0x3816; je epilogue` — a complete no-op. That is the bug.
- At this point: `rcx` = current archive NODE, `rdi` = archive reader,
  `r13` = game state (dest vector at `[r13+0x138]`).
- Sibling cases show `[rcx+0x588]` is a std::string field of the node (used by
  token 0x27 at `0x1407824d7` → `0x140c39a60`), but feat_progress is NOT a
  single string — it is written as a set of CHILD nodes, so its reader must walk
  the node's children (vtable methods on `[rdi+0x28]` / the node), not copy a
  blob.

### What a correct fix requires

A small trampoline at the `0x1407824a5` case that:

1. uses the archive abstraction (`rdi`, node `rcx`) to iterate feat_progress
   child nodes the same way `0x1409dede0`'s child loop does on write;
2. for each child, reads the key string and the uint32 counter;
3. allocates (`0x140e204c0`, ecx=0x28) and appends to `[r13+0x138]`.

The exact child-iteration + per-child read calls were not fully identified.
`0x140d75fd8` (the previously suspected "reader") builds an in-memory hash map,
not the vector, and is not directly callable here.

## Recommendation

Stay on V5 (`29556549…`). It is safe and provides panel, rulers, starting/
playing Bronzeman challenges, live in-session progress, and offline loading.
The only missing piece is cross-session feat persistence. Do not apply the
`a6cb92b8…` V6 build or any V6 derived from calling `0x1409e8200` on load.
