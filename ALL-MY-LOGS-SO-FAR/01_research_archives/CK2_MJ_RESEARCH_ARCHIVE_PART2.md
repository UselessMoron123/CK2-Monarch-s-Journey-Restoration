# RESEARCH ARCHIVE — CK2 Monarch's Journey — Part 2 (Windows deep-dive, feat-persistence root cause, the failed V6)

**Part 2 of the research · source: `new text doc(second).txt` (3,224-line conversation log) · continues `CK2_MJ_RESEARCH_ARCHIVE.md` (Part 1)**

> **How this document is built:** same skeleton as Part 1 so the files can be merged —
> A — Orientation · B — Story (timeline + how the theory evolved + patch lineage) · C — Knowledge base (facts, math, artifacts, offsets) · D — Attempts & dead ends · E — Open threads & future directions · F — Context (environment, safety, curiosities, method lessons, evidence inventory) · Merge notes.
> Every claim below comes from the log; all arithmetic was independently re-verified (marked ✅). Where this session's AI was wrong and later corrected, the error is recorded — wrong turns are data.

---

# A. ORIENTATION

## A0. Read this first (state for the next session)

- **Safe baseline: V5** (SHA `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535`) — panel, rulers, starting/playing Bronzeman challenges, live in-session progress, offline save loading all work.
- **BANNED: the V6 build `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff`.** It was shipped, tested by the user, and **failed** (save-parse corruption, crashes, feats not counting). Root cause: its trampoline called `0x1409e8200` during load — that function is a **vector append (write direction)**, not a deserializer. Never call `0x1409e8200` on the load path; never reuse hash `a6cb92b8…`. The broken V6 files were deleted from the session workspace on purpose.
- **The remaining bug is fully diagnosed** (feat progress is written to saves but the reader case is a compiled no-op — see C2), and **the materials for the fix are already uploaded and verified but NOT yet analyzed**: the Linux 3.3.3 `ck2` binary (5 Base64 parts, hash-verified ✅) and both test saves.
- The session's own closing recommendation: **start a fresh chat** with the Linux chunks + manifest + the two saves + this one-liner:
  > "V5 offline patch for CK2 3.3.3 Windows works. Remaining bug: feat/challenge progress resets to 0 on load because the save-reader case for token 0x3816 (feat_progress) is a no-op. The Windows writer and Linux binary are attached. I need a safe read trampoline. Don't reuse 0x1409e8200 — it's a vector append, not a deserializer (it corrupted the parse)."

## A1. Goal (unchanged)

Restore the retired **Monarch's Journey** mode of Crusader Kings II for personal offline Windows use. This part's specific goal: continue from the Part 1 handoff — analyze the May 3.3.3 Windows executable, interpret the V5 load test, and fix the last open defect: **challenge (feat) progress persistence across save/load**.

## A2. Status dashboard at the end of this part

| Area | State |
|---|---|
| MJ panel, 11 rulers, Bronzeman campaigns, live progress (V4 layer) | ✅ works |
| Loading Featured-Ruler saves offline (V5) | ✅ works — verified green by user, offline |
| Feat progress **persistence** across save/load | ❌ **root cause found** (reader no-op), fix **not shipped** |
| V6 persistence patch | ❌ **built, tested, FAILED, reverted** — banned (A0) |
| Launcher "Continue" button | ❌ still greyed (save name visible) — in-game Load works |
| Feat *counting* correctness (do challenges count real events?) | 🟡 **open question** — Bosnia "1" may have counted Kulin himself; Llywelyn test ran under corrupted V6 and proves nothing |
| Linux 3.3.3 binary + saves for the next analysis step | ✅ uploaded, hash-verified, **unanalyzed** |
| Reward gallery / Titus / CK3 cosmetics | ❌ dead server-side, out of scope (unchanged) |

## A3. Where this part sits in time (important for merging)

This log is **one chat session that wraps around the "father" session** (Part 1's T8–T9):

1. It **starts** right after the Part 1 handoff (T7): the user uploads the handoff + the Windows exe Base64 parts; this session performs the **first full Windows binary analysis** and writes `CK2_MJ_WINDOWS_ANALYSIS_RESULTS.md` + the first patcher (Patch A + Patch B plan).
2. The user then works in a **different chat** ("your father") that turns the analysis into the real v1→v5 patches, catches two errors in *this* session's report (see Merge notes), and ends at the V5 persistence cliffhanger — that work is archived in **Part 1**.
3. The user **returns to this session** with the father's outputs (screenshots 224–229, transcripts, V5 tools). From there this session: resolves the V5 test, finds the persistence root cause, builds V6, watches it fail at runtime, reverts, re-analyzes correctly, and prepares the Linux-binary handoff. **End of log.**

## A4. One-paragraph story

A fresh session reconstructed the May 2020 Windows executable from four Base64 chunks and proved by static analysis why the 2030-payload control test failed: the GameSparks factory always builds the online client, its local stub is unreachable dead code that reads a debug file `test.dds`, and `common/monarchs_journey` is a VFS registration with no file-open code. That analysis (minus two later-corrected details) became the v1/v2 patches. When the user returned with V5 test evidence, a four-question clarification round established that offline loading now works but progress resets to 0/6 — and disassembly found the exact reason: the save-reader case for token `0x3816` ("feat_progress") is a **no-op jump to the epilogue**, while the writer side is fully implemented. The first fix attempt (V6) redirected that case to a 24-byte trampoline calling an existing in-binary helper — byte-perfect, hash-verified, disassembly-checked, and **semantically wrong**: the helper appends *to* the in-memory vector (write direction), so calling it during load corrupted the save parser, producing "Unexpected token" errors, crashes on resign/bookmark, and non-counting feats. V6 was reverted; the user is back on a clean original. Post-mortem established the true save format (feat progress = archive **child nodes**, key string + counter, not a flat blob) and what a correct trampoline must do. The session refused to ship another untested patch, took delivery of the Linux 3.3.3 binary and both saves for the next attempt, and ended by recommending a fresh chat with a precise one-line brief.

---

# B. STORY

## B1. Timeline of this part

**S1 — Session start; missing parts + the 2030 control test.** User uploads the handoff, the manifest and `CK2game_may333_windows.base64.part001.txt`; parts 002–004 are missing. Two questions asked (how to upload; was the 2030 payload tested?). User: will upload one at a time; **2030 control payload tested on exact May 3.3.3 Windows — still no MJ interface, only the right-arrow that opens the "buy CK3" video.** This closes the last hope that a valid `event_time_end` alone activates anything on Windows.

**S2 — Executable reconstruction.** part001 decodes cleanly to 6,291,456 B (valid MZ/PE, linker timestamp `0x5EB2ACA8` = 2020‑05‑06 12:25:12 UTC ✅). Parts 002–004 arrive; full rebuild = **24,753,368 B, SHA‑256 `656f4f48…a635d8` — matches manifest exactly**. `pefile` + `capstone` installed.

**S3 — Windows binary analysis (repeatedly interrupted).** The session is cut off several times mid-disassembly ("you've got interrupted. continue", "and again interrupted..", "they interrupted you again(((") and switches to large scripted batches. Results (full detail in C1–C3): factory `CreateInstance` 0x140d748c0 always takes the real-client branch because the username string is never empty; the 648-byte local stub (vtable 0x141160bb8, no RTTI name) is runtime-dead and hardcodes `test.dds`; `common/monarchs_journey` (xref 0x1404ddadb) is VFS-mount-only with zero file-open xrefs; the JSON parser 0x140d74c40 is fully intact; the expiry math 0x1407bc4a0 matches Linux (INT_MAX overflow confirmed on Windows too). Deliverables: `CK2_MJ_WINDOWS_ANALYSIS_RESULTS.md` (436 lines), `patch_ck2_mj.py` (133 lines), `patch_ck2_mj.ps1` (145 lines) with **Patch A** (0x00d73d02: `74 2b`→`eb 2b`) and **Patch B** (0x010d55d8: `"test.dds\0"`→`"monarchs."\0`, length-preserving; `monarchs.txt` impossible — 12 B into a 9 B slot). Python patcher tested end-to-end on a copy (apply → patched hash `4a9623ba…` → revert → original). *(Two claims in this report were later corrected by the father session — see Merge notes.)*

**S4 — Return with the father's results (V5 test evidence).** User: *"we progressed a bit with your 'father'… I copied EVERYTHING he wrote after the last checkpoint"* — uploads screenshots (224)–(229), four transcript docs (`Новый текстовый документ1–4.txt`), the V5 patcher (.ps1 + 3 .bat). Screenshot read is initially ambiguous (224/226 "Continue failed!", 225 "Game State is corrupted", 227 V3-era "Challenges: Disabled", 228 Kulin in-game with Heretical Company 0/6, 229 Kulin bio). The AI independently verifies V5's two edits in the binary (0x009e3d4c `74 0B`→`EB 0B` in the shared validator 0x1409e494c; 0x009e1c2d `74 49`→`EB 49` tooltip) — correct.

**S5 — Four questions resolve the ambiguity.** User answers: checker green (`29556549…`); *"you probably looked wrong. everywhere 1173 year"* (the AI had misread the in-game date as 1 Jan 1175 — corrected); Load Game **worked — game opened**; **Internet disabled throughout**. Conclusion: **V5 fixed loading; the only remaining defect is feat-progress persistence (1/6 at save time → 0/6 after load).**

**S6 — Root cause found.** Save-token archaeology: token `0x3816` = `"feat_progress"` (registered 0x14009a666). Write side fully implemented (writer 0x1409dede0, case 0x1409df82f, vector at `[state+0x138]`, 40-byte entries). **Read side (reader 0x14077f8b0, case 0x1407824a5): `cmp r8d,0x3816; je 0x140782dc6` — jumps straight to the epilogue, reads nothing.** Only 3 references to the immediate exist (registration, write case, read case). A matching 40-byte-entry routine exists at 0x140d75fd8 but has **no references at all** — dead code. Report: `CK2_MJ_V5_RESULT_AND_V6_PLAN.md` (128 lines). Recommendation: stay on V5; "Want me to go ahead and build V6 now?"

**S7 — User: "let's go." → V6 construction saga.** Long build process with many false starts (each recorded in D2): appending a new PE section (blocked: Authenticode certificate overlay at file 0x1799400, `pefile` wouldn't emit appended section data); a 21-byte code cave at 0x140e20ca1 (too small after discovering `lea rcx,[r13+0x138]` needs 7 bytes, not 4); a wrong cave file offset (0xff72a2 vs correct **0xff66a2**, caught by a non-zero-bytes check); a wrong CAVE_VA constant (0x140ff62a2 vs correct 0x140ff72a2). Interim (wrong) theory: "the feat_progress node is a raw blob at `[node+0x588]` and helper `0x1409e8200` copies count×40-byte entries — it works for reading too." Final V6: branch `0x007818ae: 0F 84 12 09 00 00 → E9 EF 4D 87 00 90` + 24-byte trampoline at `0x00ff66a2`. Target hash `a6cb92b8…`.

**S8 — User supplies the real V5 patcher; patcher rebuilt from ground truth.** The session's own reconstruction of V5's patch 2 was wrong (5 bytes vs actual 4: `ba 23 36 00`). The user-uploaded `patch_ck2_mj_v5_ps1.txt` becomes the base; V6 = **16 V5 entries + 2 new entries = 18 patches**, generated by Python scripts (`build_patcher.py` → `make_patcher.py`, verified by `verify_patcher.py`: applying the 18 edits to the original reproduces the V6 hash exactly).

**S9 — Two deployment failures (text bugs, not patch bugs).** First run: PowerShell parse error L325 — doubled carriage returns (`\r\r\n`) from a bad line-ending conversion. Second run: parse error L163 — the generator had left a doubled comma `},,` and an extra `)`. Both fixed; final validation: braces 79/79, 18 entries, correct hash. Third run **applies cleanly** (full 18-line apply log in C5 — this log is also the first complete record of v5's two offsets, which Part 1 lacked).

**S10 — V6 runtime failure.** User report (verbatim symptoms): launcher Continue still greyed (save name seen); loaded via Single Player → Load Game "but like normal game… didn't see MJ interface"; **game closed when trying to resign**; **game closed when picking a different bookmark**; error log `savegamehelper.cpp:314` "Unexpected token: fem / dna / properties / culture / government / dynasty" in `save games/Bronzeman_llywelyn_gwynedd.ck2` (lines 18–25); **feats not counting** (Llywelyn run: marrying son to English woman didn't count; landing dynasty members as vassals didn't count) and the user's hypothesis: *"that time when I played bosnian ruler and there was '1' it could be that it just counted myself as first heretic from the start."*

**S11 — Diagnosis, revert, apology.** Cause: the trampoline called `0x1409e8200` during load — a **vector append**, not a deserializer — corrupting the archive parse state (hence parse errors, crashes, non-counting feats). "This is my mistake; I verified the bytes/hashes but misread the data direction of the helper." User told to revert; saves on disk fine (corruption was in-memory only). User: *"simple, i grabbed original exe and put it back. but what now?"*

**S12 — Correct post-mortem.** Re-analysis establishes: `0x1409e8200(dest_vec*, src_entry*)` appends **one** 0x28-byte entry (string via 0x1400b0930, counter from `[src+0x20]`, element copy 0x1409e8320, growth 0x1406bcdb0). The writer **iterates archive child nodes** (`[rbp+0xe8]`), building each entry on the stack (key from `[rbp+0xf4]`, counter via 0x140e4806c) before appending — so on disk, feat_progress is a **set of child nodes**, not a blob; `[node+0x588]` (used by token 0x27 via 0x140c39a60) is a *different* structure. Also checked and dismissed the red herring that 0x1409dede0 might be a bidirectional serializer (its outer 0x1409dcfa0 is the **save-game browser metadata** serializer — strings "games", "remote_tab", "local_tab", "savegameentry", "save_game", "load_game", "delete"). Decision: **do not ship another untested code-injection patch.** Write-up: `CK2_MJ_V6_FAILED_ROADCAUSE.md` (62 lines); broken V6 files removed.

**S13 — Provenance question.** User asks where the disassembled code comes from. Answer: entirely from the uploaded `CK2game333.exe` (4 Base64 parts → 24,753,368 B, hash-verified), read with pefile (PE structure) + Capstone (disassembly); all other uploads are context/evidence only.

**S14 — What else would help?** User offers Win 3.3.2, Linux 3.3.3, "latest Win". Ranking: **Linux 3.3.3 by far the most useful** (same version + save format; likely still contains the *working* feat_progress reader → port known logic instead of guessing; ELFs keep more symbols) — if Linux has the same no-op, that itself is informative. **Windows 3.3.2 second** (diff shows what the reader did before removal — a blueprint). "Latest Windows" not useful *(claim: "there is no CK2 version 3.3.5.1" — contradicts Part 1's fingerprinted current build; see Merge notes)*. Also very useful: **a save with non-zero feat progress** (Bosnia1173_03_03.ck2) to read the real on-disk bytes. Tool delivered: `prepare_linux_ck2_upload.bat` (generic Base64 chunker, 8 MB parts + manifest; works for any build).

**S15 — Linux binary + saves arrive; log ends.** Chat-limit discussion (user's theory: message-count based; prior chat ≈6,460 lines/≈223 KB; this chat ≈400+ messages/≈350–400 KB and "in the latter portion of its useful life"). User uploads `ck2_may333_linux` manifest + 5 parts + both saves (`Bosnia1173_03_03.txt`, `Bronzeman_kulin_bosnia.txt`). Linux binary verified: **27,729,272 B ✅, SHA‑256 `99776be0…12791a6` ✅, valid stripped ELF64 x86‑64.** Answered: the existing Windows upload .bat is generic (no per-version variant needed). Final recommendation: fresh chat + the one-liner brief (A0). Workspace at end: **108.9/128 MB, 40 files** (inventory in F5).

## B2. Evolution of the mental model in this part

| # | Working theory | What confirmed / killed it |
|---|---|---|
| 1 | (carried in) "Windows needs: force the local stub + give it the right file" | Confirmed by full static analysis; refined: stub reads hardcoded `test.dds` from a base path in `[this+0x1e8]` |
| 2 | "That base path is the Documents CK2 folder" | **Killed by the father session** (callback misread — real path is `gfx\` in the game dir; Part 1 T8). One of the two corrected errors |
| 3 | "Patch B: overwrite the `test.dds` string with `monarchs.` (9 B, length-preserving)" | Workable but **superseded** by the father's cleaner v2: change the LEA displacement at 0x00d73e1a to point at the existing `monarchs_journey` string — no .rdata string surgery at all |
| 4 | "0x140d75fd8 (dead, unreferenced) is the feat_progress deserializer and can be redirected to" | **Disproven twice**: on close reading it is an **in-memory hash-map builder** (element reader 0x140d76860), not callable with the reader's register state |
| 5 | "The feat_progress node is a raw blob at `[rcx+0x588]`; `0x1409e8200` copies count×40-byte entries and 'works for reading too'" | **Fatally wrong — the V6 failure.** `0x1409e8200` is a vector **append** (write direction); calling it during load corrupted the archive parse. `[node+0x588]` belongs to a different (string-list) structure |
| 6 | "Maybe 0x1409dede0 is a bidirectional serializer (so the empty read case is a red herring)" | **Disproven**: it is save-game-browser metadata (games/savegameentry/…) — unrelated to MJ |
| 7 | **Final model (current truth):** feat_progress is saved as **archive child nodes** (per-feat key string + uint32 counter), written by iterating `[rbp+0xe8]`; a correct reader trampoline must walk the node's children with the archive's own vtable API and append entries (alloc 0x140e204c0, size 0x28) into `[r13+0x138]`. Exact child-iteration calls **not yet identified** — that's the next session's job, ideally ported from the Linux binary | Open — materials in hand |

## B3. Patch lineage for this part

| Gen | Change (over V5) | Runtime result | What it proved |
|---|---|---|---|
| (this session's plan) A+B | A = factory branch 0x00d73d02 (identical to v1); B = string overwrite `test.dds\0`→`monarchs.\0` at 0x010d55d8 | never deployed in this form | A survived as v1; B superseded by v2's LEA-displacement redirect |
| **V6** | +2 edits: branch 0x007818ae (`0F 84 12 09 00 00` → `E9 EF 4D 87 00 90`) + 24-byte trampoline at 0x00ff66a2 calling `0x1409e8200` | **FAILED**: parse errors ("Unexpected token: fem/dna/properties/culture/government/dynasty"), crash on resign, crash on bookmark pick, feats not counting, MJ interface absent after load | Byte-level engineering was sound (hash + disassembly verified ✅, displacements recomputed correct ✅) — the **semantics of the reused helper were wrong**. New code injection must be semantically proven, not just statically checked. V6 reverted; build banned |

Trampoline bytes (for the record — **do not reuse**, kept so the failure is reproducible analytically):
```
48 8d 91 88 05 00 00   lea rdx,[rcx+0x588]   ; WRONG source model (blob)
49 8d 8d 38 01 00 00   lea rcx,[r13+0x138]   ; dest vector — correct
e8 4b 0f 9f ff         call 0x1409e8200      ; WRONG helper (append, write direction)
e9 0c bb 78 ff         jmp  0x140782dc6      ; reader epilogue — correct
```
Independently recomputed ✅: branch lands at 0x140ff72a2 (cave VA), call reaches 0x1409e8200, jmp reaches the epilogue 0x140782dc6 — the mechanism was exact; the *meaning* was not.

---

# C. KNOWLEDGE BASE (reference facts)

## C1. Windows May 3.3.3 — GameSparks factory & local stub (this part's analysis)

```
Factory: CGameSparksInterface::CreateInstance — 0x140d748c0
  0x140d748ff  test rbx, rbx            ; rbx = username std::string*
  0x140d74902  je   0x140d7492f         ; username==null -> local stub  [v1 patch point]
  0x140d74904  mov  ecx, 0x5e0          ; sizeof(real CGameSparksImplementation)=1504
  0x140d74934  mov  ecx, 0x288          ; sizeof(local stub)=648
Sole caller: 0x14081694c inside startup fn 0x140814f20–0x140817cc7 (~11 KB, main/app init)
  0x140816933  call 0x140778610         ; build_username_string — ALWAYS non-empty
                                        ; (falls back to hashed machine id) => stub dead at runtime
  0x140816944  cmove rcx, r13           ; passes null only if string empty — never happens
gs_test token: parsed at 0x140815ec8; stored at [rdi+0x2d0]; selects GameSparks
  test-vs-live server URL only — NOT an offline switch (confirms Part 1)
```

**Local stub (Windows analogue of CNullGameSpark) — ctor 0x140d74960, vtable 0x141160bb8, no RTTI name** (why "CNullGameSpark" is absent from Windows strings):

| Slot | Target | Behavior |
|---|---|---|
| 0 | 0x140d73d10 | scalar deleting destructor |
| 1,2,4,5,10–12,25 | 0x1400b0200 (`ret 0`) | no-ops (Download/Reconnect/Update…) |
| 3 | 0x140d749e0 | **LoadLocalCache** — reads file + parses |
| 6 / 7 | 0x14026ecf0 / 0x1402de7b0 | connection-state getters |
| 8 | 0x140d74b20 | `[this+0x30 + idx*4]` — GUI-version array getter (idx 14 = highlighted_ruler_version) |
| 9 | 0x1400aeb70 (`xor al,al; ret`) | returns false |
| 13,14,15,17 | 0x1400aeb90 | return 0 |
| 16 | 0x140d73cc0 | `&[this+0x1d0]` — the **scheduled_rulers vector** the UI consumes |
| 18 | 0x140d74b30 | `&[this+0x1e8]` — base-path std::string *(this session read it as Documents; corrected: gfx\)* |
| 19,20 | 0x140d74b40 / 0x140d74ba0 | thread-safe static initializers |
| 26 | 0x1400aeb80 (`mov al,1; ret`) | **returns true** (GetHasFetchedPropertySet analogue) |
| 27–31 | 0x140d73cd0 / 0x140d73d00 / 0x140d74c00 / 0x140d74c30 / 0x140d73c20 | vector ops / init |
| 32–60 | 0x140e3f8f8 | `_purecall` — interface consumers only use slots 0–31 (safe to swap in) |

**LoadLocalCache 0x140d749e0** (only caller: the ctor itself at 0x140d749ca): assigns filename `"test.dds"` (string VA 0x1410d6dd8; file 0x10d55d8 ✅) via std::string::assign 0x1400b0930 with length 8 (`lea r8d,[rbx+8]`), appends to base path from vtable slot 18 (path_append 0x1400b0e10), checks file_exists 0x140dcebf0, then calls the parser 0x140d74c40 at 0x140d74ad5. **Final deployed form (v2, father session): redirect via LEA displacement at 0x00d73e1a so the loader reads `gfx\monarchs` in the game folder.**

**Parser 0x140d74c40** — fully functional: reads `can_see_highlighted_rulers` (0x140d74c70), `scheduled_rulers` (0x140d74c8e), iterates JsonArray (size 0x140dceb00, get 0x140dceae0), per-ruler `ParseScheduledRuler` 0x140d75010 reads `event_time_end` (xref 0x140d75148); results into vector `[this+0x1d0]`.

**Expiry arithmetic 0x1407bc4a0** (Windows ≡ Linux): `event_time_end + 0x15180` (86400, "active" edge) and `+ 0x2a300` (172800, "upcoming" edge, at 0x1407bc51f/520), 32-bit → INT_MAX overflow confirmed. Returns 0=expired/hidden, 1=active, 2=upcoming.

**UI/version gate:** `highlighted_ruler_version` checked at 0x140d74459 (error code 0xe=14 if missing/zero) and 0x140d74747 (key-registration switch); windows built at 0x14072840d (`highlighted_ruler_window_main`) / 0x140728447 + 0x1407c0736 (`upcoming_event_window`); CHighlightedRulerView binder thunks 0x1416db1c0 / 0x1416db260. The "buy CK3" arrow is the upsell fallback when the property set reports no featured ruler.

## C2. The feat_progress persistence mechanism (the core discovery of this part)

```
Save token 0x3816 = "feat_progress" (decimal 14358); registration site 0x14009a666 (~0x14009a65e table).
Only 3 references to the immediate in the whole exe: registration, write case, read case.

WRITE side (works) — save writer 0x1409dede0, case at 0x1409df82f, call site VA 0x1409df969 (file 0x9ded69):
  [rsi+0x138]  = in-memory feat vector in game state; element 0x28 (40) bytes:
                 { MSVC std::string key (0x20 B); uint32 counter at +0x20; pad }
  Writer iterates archive CHILD NODES ([rbp+0xe8]); per child builds a stack entry at [rbp-0x80]:
    key string copied from [rbp+0xf4] via 0x1400b0930;
    counter written via 0x140e4806c (uint32, bidirectional primitive);
    appended via 0x1409e8200(vec, &local).
  Helpers: 0x1409e8200 = vector APPEND of ONE 0x28 entry (element copy 0x1409e8320:
    string assign + counter [src+0x20]→[dest+0x20]; growth via 0x1406bcdb0).
  => on-disk format: child nodes, each = feat key string + counter. NOT a flat blob.

READ side (the bug) — save reader 0x14077f8b0, case at 0x1407824a5:
  cmp r8d, 0x3816 ; je 0x140782dc6   <- jumps STRAIGHT to the function epilogue. No call, no read.
  Register state at the case: rcx = current archive NODE, rdi = archive reader, r13 = game state.
  Sibling cases: token 0x27 (case 0x1407824d1/d7) reads [rcx+0x588] (a std::string) via 0x140c39a60
    — string-list structure, NOT feat entries. Token 0x3805 write case calls 0x140c3ae10.
  Build-level omission in the May Windows binary (writer kept, reader routed to epilogue —
  a retired-backend remnant). NOT caused by V4/V5 patching. Explains the clean-process reset.

DEAD CODE: 0x140d75fd8 (calls element reader 0x140d76860) — referenced by nothing
  (no call, no lea, no vtable); close reading: builds an in-memory HASH MAP, not the save vector.
  Previous session's hope of repurposing it is closed.

WHAT A CORRECT FIX REQUIRES (design, not yet built):
  Trampoline at the 0x3816 read case that iterates the node's children with the archive's own
  child-walking API (vtable methods on the archive/node, same pattern the writer used via
  [rbp+0xe8]), reads key string + uint32 per child, allocates via 0x140e204c0 (ecx=0x28),
  appends into [r13+0x138], then jmp 0x140782dc6. Exact child-iteration calls NOT yet identified.
  Best path: read the working implementation in the Linux 3.3.3 binary (uploaded, verified)
  and/or inspect the real bytes in Bosnia1173_03_03.ck2 (uploaded).
```

## C3. Verified calculations (recomputed independently for this archive)

| Item | Value | Check |
|---|---|---|
| Linker timestamp | `0x5EB2ACA8` = 1,588,767,912 = **2020‑05‑06 12:25:12 UTC** | ✅ matches log |
| Base64 total | 33,004,492 chars → 3×8,388,608 + **7,838,668** (part004) | ✅ |
| part001 decode | 8,388,608 × 3/4 = **6,291,456 B** | ✅ |
| Full decode | 33,004,492 → 24,753,369 − 1 pad = **24,753,368 B** | ✅ matches manifest size |
| Object sizes | local stub `0x288` = 648 B; real impl `0x5E0` = 1504 B | ✅ |
| Section deltas (.text) | file↔VA: **+0xC00** (RVA 0x1000, raw 0x400) | ✅ (0x007818ae↔0x1407824ae; 0x00ff66a2↔0x140ff72a2) |
| Section deltas (.rdata) | file↔VA: **+0x1800** (RVA 0xff8000, raw 0xff6800) | ✅ (`test.dds` 0x1410d6dd8→0x10d55d8; `common/monarchs_journey` 0x1410a4638→0x10a2e38) |
| .text end padding | raw end 0xff6800 − (0x400+0xff62a2) = **0x15E B of zeros**; cave uses 24 | ✅ |
| Original read-case jump | `0F 84 12 09 00 00` at 0x1407824ae → 0x1407824ae+6+0x912 = **0x140782dc6** (epilogue) | ✅ |
| V6 branch | `E9 EF 4D 87 00` → 0x1407824ae+5+0x874DEF = **0x140ff72a2** (cave) | ✅ mechanically correct |
| V6 trampoline call | rel32 −0x60F0B5 from 0x140ff72b0 → **0x1409e8200** | ✅ |
| V6 trampoline jmp | rel32 −0x8744F4 from 0x140ff72b5 → **0x140782dc6** | ✅ |
| Instruction length gotcha | `lea rcx,[r13+0x138]` = **7 B** (`49 8d 8d 38 01 00 00`, REX.WB+SIB+disp32) — the "4-byte" assumption broke the 21-B cave plan | ✅ |
| Tokens | 0x3816=14358 (feat_progress) · 0x3805=14341 · 0x27=39 · 0x2ae/0x2af=686/687 (hardcoded in the specialized reader) | ✅ |
| Timestamps (re-confirmed from Part 1) | 1609502400=2021‑01‑01 12:00 · 1893499200=2030‑01‑01 12:00 · cutoff 1893672000=2030‑01‑03 12:00 · INT_MAX+172800 wraps to −2147310849 (≈1901‑12‑15, instantly expired) | ✅ |
| Linux transfer | 27,729,272 B → 5 Base64 parts; decoded & hash-verified in-session | ✅ |

## C4. Artifact identities (this part)

| Artifact | Size | SHA-256 |
|---|---|---|
| May Win `CK2game333.exe` original (reconstructed) | 24,753,368 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` ✅ |
| This session's A+B test patch (never deployed) | 24,753,368 | starts `4a9623ba…` (partial hash in log) |
| V5 (father's, user-verified green) | 24,753,368 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` |
| **V6 — FAILED, BANNED** | 24,753,368 | `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff` |
| Linux 3.3.3 `ck2` (re-uploaded, verified, unanalyzed) | 27,729,272 | `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6` ✅ |
| Payload `gfx\monarchs` (2030 JSON) | 101,949 *(size carried from Part 1)* | `fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e` — hash re-confirmed by this part's V6 apply log |
| Saves *(sizes carried from Part 1)* | 4,195,136 / 3,430,038 | `Bosnia1173_03_03.ck2` (1173.3.3 — the save holding feat progress "1") / `Bronzeman_kulin_bosnia.ck2` (1173.1.1) — both uploaded in this part as .txt |

New save encountered: `Bronzeman_llywelyn_gwynedd.ck2` — created during the failed V6 run; its header region shows the "Unexpected token" parse errors (evidence of V6 corruption; treat the file as suspect).

## C5. Complete 18-entry patch map (from the successful V6 apply log — the definitive cumulative record)

```
 v1  0x00d73d02  74 2b -> eb 2b      force local/null implementation (factory branch)
 v2  0x00d73e1a  ba 23 36 00 -> 21 fc 32 00   redirect local loader gfx/test.dds -> gfx/monarchs
 v3  0x007bd64e  75 04 -> 90 90      enable Play when local ruler ready (skip account status)
 v3  0x007beacb  74 19 -> eb 19      normal Play tooltip
 v3  0x007beea2  74 0c -> eb 0c      normal Continue tooltip
 v3  0x007befaf  74 2d -> eb 2d      normal Restart path
 v3  0x007c0d18  74 0b -> 74 0b      keep offline reward-container branch (undo v3 empty-reward exposure)
 v4  0x007c0d23  eb 5c -> 90 90      hide unpopulated reward container + obsolete login text
 v4  0x000aeb83  24-B rewrite:
     80 7f 61 00 74 0c 80 7f 63 00 74 06 80 7f 62 00 74 02 33 f6 40 0f b6 c6  ->
     31 c0 66 83 7f 61 01 75 0f 80 7f 63 00 75 06 80 7f 65 00 75 03 ff c0 90
     (ignore stock-checksum prerequisite only while Steam inactive)
 v4  0x00732b03  74 16 -> 90 90      Start-button Steam gate
 v4  0x007336b0  74 1d -> 90 90      challenge-enabled predicate Steam gate
 v4  0x007337e1  74 1d -> 90 90      Start warning predicate Steam gate
 v4  0x00737262  74 1b -> 90 90      challenge tooltip heading Steam gate
 v4  0x007b78eb  75 0c -> eb 0c      in-game feat tracking Steam gate
 v5  0x009e3d4c  74 0b -> eb 0b      shared Load/Continue validation: allow valid Featured-Ruler saves
 v5  0x009e1c2d  74 49 -> eb 49      normal save tooltip (drop MJ login requirement)
 V6  0x007818ae  0f 84 12 09 00 00 -> e9 ef 4d 87 00 90   route feat_progress token to trampoline  [BANNED]
 V6  0x00ff66a2  24×00 -> 48 8d 91 88 05 00 00 49 8d 8d 38 01 00 00 e8 4b 0f 9f ff e9 0c bb 78 ff  [BANNED]
```
**The two v5 offsets (0x009e3d4c, 0x009e1c2d) are recorded here for the first time — Part 1's C5 listed v5 as "offsets not recorded". This closes that gap.** Shared save validator VA: 0x1409e494c.

## C6. New/extended code-address map (Windows May 3.3.3)

| Address | Role |
|---|---|
| 0x140d748c0 / 0x140d74902 | factory / v1 branch point |
| 0x140d74960 / 0x141160bb8 | local stub ctor / vtable |
| 0x140d749e0 / 0x140d74c40 / 0x140d75010 | LoadLocalCache / JSON parser / ParseScheduledRuler |
| 0x1407bc4a0 (51f/520) | view-state expiry math (+86400 / +172800) |
| 0x140814f20–0x140817cc7 | startup/main-init function; factory call at 0x14081694c; gs_test parse 0x140815ec8 |
| 0x140778610 | username builder (always non-empty; per Part 1 also collides with gfx\test.dds) |
| 0x14077f8b0 | **top-level save reader** (game-state deserializer); feat case 0x1407824a5; epilogue 0x140782dc6 |
| 0x1409dede0 | save writer token switch; feat case 0x1409df82f; feat call site 0x1409df969 |
| 0x1409e494c | shared Load/Continue save validator (v5 patch site) |
| 0x1409e8200 / 0x1409e8320 / 0x1406bcdb0 | vector append / element copy / vector growth — **write direction only** |
| 0x140e4806c | uint32 bidirectional serialize primitive |
| 0x140e204c0 | entry allocator (ecx = size, 0x28 for feat entries) |
| 0x1400b0930 / 0x1400b0e10 | std::string assign / path append |
| 0x140d75fd8 + 0x140d76860 | DEAD: hash-map builder + its element reader — not a save reader |
| 0x140c39a60 / 0x140c3ae10 / 0x140c38f30 | string-list reader (token 0x27) / serializer (token 0x3805) / specialized child→vector reader (hardcoded tokens 0x2ae/0x2af — not generic) |
| 0x140c3b040 / 0x1407819b0 | archive "begin object" reader / sibling sub-object read case |
| 0x140910600 / 0x1406945e0 / 0x140701c30 | field-read primitive / for-each iterator / map lookup by key name |
| 0x1409e82a0 | vector post-processor, stride 0x20 (save-game lists — wrong stride for feats) |
| 0x1409dcfa0 | save-game browser metadata serializer (games/savegameentry/… — unrelated to MJ) |
| 0x14009a666 | save-token registration site (0x3816 = "feat_progress") |

---

# D. ATTEMPTS & DEAD ENDS

## D1. Direction ledger (each direction taken in this part, with its result)

| # | Direction | Result |
|---|---|---|
| 1 | 2030 payload control test at `<CK2 root>\common\monarchs_journey\monarchs.txt` on exact May Windows | ❌ nothing (only buy-CK3 arrow) — Windows never opens that path; decisive control |
| 2 | Reconstruct exe from 4 Base64 parts + hash-verify | ✅ exact match `656f4f48…` |
| 3 | Full static analysis (strings → xrefs → factory → stub → parser → expiry math) | ✅ complete Windows picture; explains every prior failure; basis of v1/v2 |
| 4 | Patch plan A (factory branch) + B (string overwrite) + guarded patchers (py/ps1) | 🟡 A became v1 as-is; B superseded by v2 LEA redirect; report contained 2 errors corrected by the father session |
| 5 | Interpret V5 load-test screenshots | ✅ after user Q&A: loading works, persistence broken (AI's date misread corrected by user) |
| 6 | Trace feat_progress serialization | ✅ **root cause: read case is a compiled no-op** (C2) |
| 7 | V6 via appended PE section | ❌ abandoned — Authenticode overlay at 0x1799400; pefile wouldn't emit section data; unnecessary (padding cave exists) |
| 8 | V6 via 21-B cave 0x140e20ca1 | ❌ trampoline is 26 B (instruction-length surprise) — doesn't fit |
| 9 | V6 via .text end padding (0x00ff66a2) + trampoline calling 0x1409e8200 | ❌ **shipped, ran, FAILED** (parse corruption, crashes, feats dead) — helper is write-direction; reverted; build banned |
| 10 | Patcher deployment (text generation) | 🟡 two self-inflicted failures (`\r\r\n`; `},,` + extra `)`) — fixed; lesson: validate generated scripts, not just patch bytes |
| 11 | Post-mortem re-analysis | ✅ correct model of writer/format/helpers; refused to ship another guess |
| 12 | "Would a mod fix it instead?" | ❌ closed — save-token reading is compiled C++; mods can't add deserializers |
| 13 | Gather better inputs (Linux 3.3.3, 3.3.2, saves) | ✅ Linux binary + both saves received & verified; ranked plan for next session |

## D2. Dead ends — closed with evidence (do not revisit)

- **Calling `0x1409e8200` on the load path** — it is a vector append; V6 proved it corrupts the archive parse at runtime. Any future trampoline must use the archive's child-iteration read API instead.
- **Hash `a6cb92b8…`** — do not run, do not derive from.
- **Reusing 0x140d75fd8** — in-memory hash-map builder, not a deserializer; not callable with the reader's register state.
- **0x140c38f30 as a generic child→vector reader** — hardcoded for tokens 0x2ae/0x2af with debug-assert behavior; not reusable.
- **0x1409e82a0 post-processor** — stride 0x20 (save-game lists), feat entries are 0x28.
- **`[node+0x588]` as the feat blob** — that field belongs to string-list tokens (0x27 → 0x140c39a60); feat progress is child nodes, not a blob.
- **0x1409dede0 / 0x1409dcfa0 as a bidirectional feat serializer** — save-game browser metadata.
- **Appending a new PE section** — Authenticode overlay after the sections + tooling friction; end-of-.text zero padding (0x15E B) is the right home for small caves.
- **Mod-based fix for save-token reading** — impossible by design.
- **String-overwrite filename patch (Patch B)** — superseded by v2's LEA-displacement redirect (no .rdata surgery).
- **Documents-folder payload location** — wrong (callback misread); the loader's base is `gfx\` in the game dir.

## D3. Disproven vs confirmed (one-liner index)

Confirmed: Windows parser intact; expiry math ≡ Linux; V5 loading fix works offline; writer serializes feat progress correctly; read case is a no-op; saves on disk unharmed by V6 (memory-only corruption); Linux binary & saves verified in workspace.
Disproven: blob-at-0x588 model; 0x1409e8200 readability; 0x140d75fd8 reusability; bidirectional-serializer red herring; "3.3.5.1 doesn't exist" (contradicts Part 1 — see Merge notes); AI's "1 Jan 1175" screenshot reading (user: everywhere 1173).

---

# E. OPEN THREADS & FUTURE DIRECTIONS

## E1. Open questions (ranked)

1. **Build a correct feat_progress reader (V6 attempt #2).** Everything needed is uploaded: Linux 3.3.3 `ck2` (verify whether its reader works and port the exact call sequence) and `Bosnia1173_03_03.ck2` (inspect real feat_progress bytes: child-node layout, key strings, counters). Design constraints already established (C2). Treat any new build as experimental: backups on, short tests, no long campaigns until save→quit→reload shows 1/6.
2. **Do feats actually count real gameplay events?** The only verified increment (Bosnia 1/6) may have been Kulin counting himself as the first heretic at start (user's hypothesis — unresolved). The Llywelyn observations (marriage/vassalage not counted) come from the corrupted V6 run and prove nothing. **Re-test counting on clean V5**: start a fresh Kulin Bronzeman game, check whether progress is already 1 before doing anything, then perform a real conversion and watch `feat_log`.
3. **Launcher "Continue" for MJ saves** — still greyed (name visible). In-game Load works; low priority.
4. **"Unexpected 77 gold" on a fresh start** — noted once during V5 test analysis, never investigated. Probably a screenshot-detail anomaly; verify against a clean V5 new game if convenient.
5. **Full 16-ruler roster / 3.3.5.1 port / reward gallery cosmetics** — unchanged from Part 1 E1 (not touched in this part).
6. **Windows 3.3.2 diff** — if the Linux binary somehow lacks the reader too, diffing Win 3.3.2 vs May 3.3.3 shows exactly what the reader did before it was stubbed (near-perfect blueprint). The generic upload .bat works for it unchanged.

## E2. Ideas beyond the immediate goal (new in this part)

- **The "port the reader from Linux" technique generalizes**: whenever a Windows build stubs a feature, the same-version Linux twin is the reference implementation — extend Part 1's "Linux as symbol map" lesson from *analysis* to *code transplant*.
- **The save-token switch map** (C2/C6) is reusable for other save-section mysteries (any token can be checked for write/read symmetry in minutes now that both switches are located).
- **Generic upload .bat** (`prepare_windows_may333_upload.bat` / `prepare_linux_ck2_upload.bat`): drag any file → 8 MB Base64 chunks + SHA-256 manifest. Works for any future binary (3.3.2, other games).
- **Guarded-patcher generator pattern**: build the next patcher by *editing the previous verified patcher* (ground truth) rather than regenerating from analysis notes — caught a real 4-vs-5-byte error this part.

## E3. Handoff to the next session (exact)

Attach: this archive (+ Part 1 archive), `ck2_may333_linux.manifest.txt` + parts 001–005, `Bosnia1173_03_03.txt`, `Bronzeman_kulin_bosnia.txt`, the V5 patcher set, payload `monarchs`. Opening brief (the session's own words):
> "V5 offline patch for CK2 3.3.3 Windows works. Remaining bug: feat/challenge progress resets to 0 on load because the save-reader case for token 0x3816 (feat_progress) is a no-op. The Windows writer and Linux binary are attached. I need a safe read trampoline. Don't reuse 0x1409e8200 — it's a vector append, not a deserializer (it corrupted the parse)."

State: *"Continue from the feat_progress reader design in C2; materials verified; do not revisit D2; the V6 hash a6cb92b8… is banned."*

---

# F. CONTEXT

## F1. Environment & constraints (as observed in this part)

- Same machine/user as Part 1: Windows, non-technical, Russian-locale (PowerShell errors arrive in Russian: "Непредвиденная лексема" = unexpected token; screenshots named "Снимок экрана (N).png").
- Game root for testing: `C:\Users\UZWERG\Desktop\SteamCrusader\` (exact May 3.3.3; payload at `…\gfx\monarchs`; backups `CK2game.exe.before_mj_v6_20260820_195934.bak`, `CK2game.exe.verified_may333_original.bak`).
- Uploads are text/image only → Base64-chunk protocol (8 MB parts + manifest with size + SHA-256).
- Chat sessions are short and get interrupted ("sessions with github are even shorter"); user's theory: the limit counts *messages* (user + assistant replies), not tool runs. This chat: ≈400+ messages / ≈350–400 KB at the estimate point; prior chat ≈6,460 lines / ≈223 KB. The session repeatedly switched to **large scripted batches** after being cut off mid-incremental-disassembly.
- Workspace at end: **108.9 MB / 128 MB, 40 files** — near budget; delete reproducible intermediates.
- Analysis toolchain: `pefile` (PE structure) + `capstone` (disassembly); packages can vanish between sessions (a fresh environment lost them mid-post-mortem — reinstall as first step).

## F2. Safety rules (additions to Part 1's list — all still in force)

- **Never apply or derive from V6 `a6cb92b8…`; never call `0x1409e8200` from a load-path patch.**
- The V6 patcher files were deliberately deleted from the session workspace so they can't be reused — don't reconstruct them from B3 out of curiosity.
- Patcher invariants kept throughout: hash+size+per-byte verification before writing, timestamped backups, verified-original backup, revert restores `656f4f48…` and re-verifies. This is why the failed V6 cost nothing but time: revert worked perfectly, saves on disk were untouched.
- V6-era saves (e.g. `Bronzeman_llywelyn_gwynedd.ck2`) may carry corruption artifacts from the broken session — prefer the two verified Kulin saves for tests.
- Unchanged from Part 1: never run `wipe_feats`; never share `pdx_login.txt`/tokens; distribute guarded patchers, never patched executables; stay offline during tests.

## F3. Curiosities & side-findings (this part)

- The local stub's vtable tail (slots 32–60) is `_purecall` — the object is a deliberately minimal dev fixture; consumers only ever use slots 0–31.
- `0x140778610` (username builder) falls back to a **hashed machine id** when no profile exists — the username is never empty, which is exactly why the stub is dead at runtime.
- Save-token IDs are plain integers compared in a binary-search switch tree; `feat_progress` = 0x3816 is the **highest/last** token, reached by direct comparison (0x1407824a5) rather than subtree routing.
- The save-game browser has its own serializer with strings `games`, `remote_tab`, `local_tab`, `save games`, `.ck2`, `savegameentry`, `save_game`, `load_game`, `delete` (0x1409dcfa0) — useful map of the launcher-side save UI data.
- Error-log fingerprint of archive corruption: `[savegamehelper.cpp:314]: Error: "Unexpected token: X, near line: N"` — if this ever appears again, suspect load-path patching first.
- Chat-limit lore: when the limit hits, the conversation stays readable but the assistant loses fine-grained working memory — hence the handoff-file discipline.

## F4. Method lessons (this part — several earned the hard way)

1. **Verify a helper's DATA DIRECTION before building a patch that calls it.** V6 had the right offsets, right bytes, right hash, right disassembly — and wrong semantics. Static byte-verification cannot substitute for semantic proof; for code-injection patches, demand a traced read/write direction and, ideally, a runtime test plan before shipping.
2. **"Dead code" ≠ "reusable code".** 0x140d75fd8 looked like the perfect orphaned deserializer; it was a hash-map builder. Read what a function *does*, not just what its shape suggests.
3. **Prefer porting proven logic over inventing new machine code.** The whole V6 detour existed because the working reader wasn't at hand — the Linux binary (same version) likely contains it. Ask for reference material *before* writing assembly.
4. **Use the user's real artifacts as ground truth.** Rebuilding the V5 patch list from memory introduced a 4-vs-5-byte error; the uploaded real patcher fixed it instantly.
5. **Ask targeted yes/no questions when evidence is ambiguous.** The 4-question round resolved the V5 test state (which screenshots were old, what actually loaded, offline status) in one exchange and corrected an AI misread (1175→1173).
6. **Screenshot readings are fallible — cross-check dates, counters and screen identity with the user** before building theories on them.
7. **Generated scripts need their own validation pass**: two deployment failures came from text-processing bugs (doubled CRs; stray comma/paren), not patch logic. Validate syntax + re-verify the produced hash after every regeneration.
8. **Cave arithmetic checklist**: file↔VA delta per section (.text +0xC00 here); instruction lengths (REX+SIB+disp32 surprises); confirm cave bytes are actually zero before use (this caught the 0xff72a2/0xff66a2 error).
9. **When a patch fails at runtime: revert first, diagnose second, apologize plainly, write the roadcause file** — the failure write-up (`CK2_MJ_V6_FAILED_ROADCAUSE.md`) preserved everything needed to avoid a repeat.
10. **Provenance transparency** (explaining exactly which upload the disassembly comes from and which tools read it) resolved user uncertainty and built trust — keep doing it.

## F5. Evidence inventory (end-of-log workspace, 40 files)

| Evidence | Proves |
|---|---|
| `CK2game_may333_windows.base64.part001–004.txt` + manifest | Windows binary identity/reconstruction |
| `CK2game333.exe` (workspace copy) | original, hash `656f4f48…` |
| `CK2_MJ_WINDOWS_ANALYSIS_RESULTS.md` (436 ln) | this session's Windows analysis (incl. the 2 later-corrected claims) |
| `patch_ck2_mj.py` / `patch_ck2_mj.ps1` | first A+B patcher pair (superseded by father's lineage) |
| `Снимок экрана (224)–(229).png` | V5 load-test evidence (224/226 Continue-failed; 225 corrupted-state; 227 V3-era setup; 228/229 successful V5 load with 0/6) |
| `Новый текстовый документ1–4.txt` | father-session transcripts (V3–V5 build) |
| `CK2_Monarchs_Journey_next_session_handoff.md`, `CK2_MJ_V5_load_test_guide.md` | handoff lineage |
| `APPLY/CHECK/REVERT_CK2_MJ_V5_bat.txt`, `patch_ck2_mj_v5_ps1.txt` | the real V5 toolchain (ground truth for the 16-entry map) |
| `CK2_MJ_V5_RESULT_AND_V6_PLAN.md` (128 ln) | root cause + original V6 design |
| `CK2_MJ_V6_FAILED_ROADCAUSE.md` (62 ln) | the V6 failure analysis (the authoritative post-mortem) |
| `build_v6.py` (surviving build script) | how the V6 test binary was produced |
| `Bosnia1173_03_03.txt`, `Bronzeman_kulin_bosnia.txt` | the two verified saves (Bosnia = the one with feat progress) |
| `ck2_may333_linux.manifest.txt` + `part001–005.txt` | Linux 3.3.3 binary (27,729,272 B, `99776be0…` ✅) — **unanalyzed** |
| `prepare_windows_may333_upload_bat.txt`, `prepare_linux_ck2_upload_bat.txt` | generic Base64 upload tools |
| `previous chat log.txt` | Part 1's raw log (for cross-reference) |
| User-side (not in workspace): V6 apply log (all 18 lines), error log with `savegamehelper.cpp:314` errors, `Bronzeman_llywelyn_gwynedd.ck2` | V6 deployment + runtime failure |

---

# MERGE NOTES (vs Part 1)

**New in this part (not in Part 1):** the complete factory/stub/parser/vtable analysis with addresses (C1); the feat_progress write/read mechanism and root cause (C2); v5's two patch offsets (C5 — closes Part 1's gap); shared validator VA 0x1409e494c; the V6 attempt and its full failure record; the correct save-format model (child nodes); Linux binary + saves verified and waiting; the ranked "what to upload" guidance; new method lessons (F4).

**Restated/confirmed:** exe identity & hashes; expiry math and INT_MAX overflow; payload hash `fc6ec025…`; V5 hash `29556549…`; gs_test semantics; Linux `ck2` identity `99776be0…`; save sizes; "buy CK3" upsell behavior; offline-only requirement.

**Contradictions & corrections to flag when merging:**
1. **Payload path:** this session's early report said the stub reads `%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\test.dds`. **Wrong** (callback misread) — Part 1's corrected finding stands: base is `gfx\` in the game dir; deployed payload is `<game folder>\gfx\monarchs` (re-confirmed by the V6 apply log).
2. **Filename patch method:** this session's Patch B (string overwrite at 0x010d55d8) was never deployed; the canonical v2 is the LEA-displacement redirect at 0x00d73e1a. Keep Part 1's C5 as the lineage of record; keep Patch B here only as a superseded alternative. *Precision note:* Part 1's T8 describes the first session's error as an "unsafe 10-byte-over-9-byte string patch", while the exported final Patch B in this log is already length-preserving (9 B, `"monarchs.\0"`) — the 10-byte variant was presumably an earlier iteration (the log records rejecting the 11-char `monarchs.txt` because "only 8 characters fit"), or a characterization difference in the father session. Either way, the string-overwrite approach as a whole is superseded.
3. **"There is no CK2 version 3.3.5.1"** (S14 answer) **contradicts Part 1**, which fingerprinted the user's current build as **3.3.5.1 (2021‑09‑21)** from its strings. Part 1's evidence is primary (string dump); treat the "doesn't exist" claim as an error of this session. Related: "CK2's last official patch was 3.3.3 (Sept 2020)" conflates the May 3.3.3 build with the 2020‑09‑02 retirement update — use Part 1's C2 table as canonical.
4. **feat counting:** Part 1 recorded "live progress 1/6 (Heretical Courtiers)" as ✅ working. This part adds doubt (self-count hypothesis) — downgrade to 🟡 pending a clean V5 re-test (E1.2), rather than deleting the Part 1 result.
5. Chronology: Part 1's T8–T9 (father session) happened **between** S3 and S4 of this log. When merging timelines, interleave: Part 2 S1–S3 → Part 1 T8–T9 → Part 2 S4–S15.
