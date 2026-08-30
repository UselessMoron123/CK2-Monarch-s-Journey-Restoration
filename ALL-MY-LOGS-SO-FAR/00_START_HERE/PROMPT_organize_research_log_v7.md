# MASTER ARCHIVE RULES — structure, tear-down, storage, preservation (v7, consolidated)

**This is the single continuous rulebook.** It merges, without loss, everything the
earlier instruction files said:

| Source | What it contributed | Kept here as |
|---|---|---|
| `PROMPT_organize_research_log_v4.md` | raw-log dissection: coverage sweep, A–F skeleton, 12 rules | §§4–6, §9 |
| `PROMPT_organize_research_log_v5.md` | ingest/maintenance mode, artifact-class→folder map, SHA dedup, living docs, integrity audit | §§2–3, §7–8 |
| `PROMPT_organize_research_log_v6.md` | state dashboard discipline, naming-collision table, Continue surfaces, trace distillation, tooling integrity, git-patch provenance, save metadata | §§1, §3, §7, §10 |
| v1–v3 | history only (superseded wording) | not restated; see the files |

**Operative status:** v7 supersedes v4/v5/v6 as the text to paste. v4/v5/v6 stay in
this folder as history (they are cited by older reports). If a rule below conflicts
with an older file, **this file wins**; if it conflicts with `STATUS.md` /
`MASTER_ARTIFACT_TABLE.md` / `BANNED_ARTIFACTS.md` about *facts*, those files win and
this file must be repaired.

---

## 0. The project in one sentence

Restore the retired **Monarch's Journey / Featured Rulers / Bronzeman** mode of
Crusader Kings II for **personal, fully offline Windows use**, via payload
re-activation, version archaeology and hash-guarded executable patches — while never
losing the research history that produced them.

**Hard rules that override everything else**

1. Never run `wipe_feats`.
2. Never redistribute a complete stock or patched `CK2game.exe` — deliver only
   guarded patchers that edit the user's own verified binary.
3. Never resurrect the **banned** trampoline V6 `a6cb92b8…` or the **abandoned**
   feat-V7 `0074af70…`.
4. Never apply May-2020 3.3.3 offsets to any other build (3.3.5.1 is a different
   layout; a byte-port was assessed **not feasible**).
5. Launch `CK2game.exe` directly. The Paradox launcher Continue is a separate case
   (**C25**) and stays grey.
6. Test offline. Bronzeman disables the console by design — no `feat_log`.
7. The user is **non-technical** and works by drag-and-drop on Windows: give
   copy-paste steps, never raw hex work for them to do by hand.

---

## 1. Orientation order (read before touching anything)

1. `00_START_HERE/STATUS.md` — authoritative current state (banner + dashboard).
2. `00_START_HERE/CASES_AND_FINDINGS.md` — solved / partial / unsolved / info map.
3. `03_analysis/MASTER_ARTIFACT_TABLE.md` — SHA-256 registry; **check it first for
   any artifact you are about to accept**.
4. `03_analysis/BANNED_ARTIFACTS.md` — never re-introduce these.
5. `03_analysis/CONTRADICTIONS.md` — settled disagreements; do not re-litigate.
6. `00_START_HERE/SCREENSHOTS_CATALOG.md` — canonical image record.
7. `12_raw_chat_logs/INDEX.md` — ledger of every raw export ever processed.
8. Deep background only when needed: `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`,
   `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md`.

**Naming collision — key every build by SHA-256, never by label alone:**

| Label | SHA-256 | Meaning | Status |
|---|---|---|---|
| "V6" trampoline | `a6cb92b8…` | injected code | ❌ BANNED |
| V6 | `f5b7dfd6…` | 5 save-list branches | ✅ proven; revert target |
| "V7" feat-update | `0074af70…` | two `74 0d→90 90` | 🟡 ABANDONED |
| V7 Continue | `57b18e43…` | `0x009E5B8B` `75 2f→eb 2f` | ✅ in-game Continue |
| V8 feat-rehydration | `94d6fb40…` | `0x00666546`, `0x007B786B` bypasses | ✅ applied, ❌ premise disproven |
| **V9 eligibility-gate force** | `61e4345b…` | `0x007B7906` `e8 85 71 8f ff→b0 01 90 90 90` | ✅ **current baseline** |

**Continue surfaces — never conflate:** Paradox *launcher* (C25,
`pdx_launcher.lib` / `launcher-v2.sqlite`) ≠ in-game main menu ≠ MJ panel ≠
Single Player. V7 fixed engine *execution*, not the launcher.

---

## 2. The tree (do not re-sort it)

The 15-folder sort is **finished**. New material lands in its permanent home on the
first try; the layout is never re-invented.

| # | Folder | Contents |
|---|---|---|
| 00 | `00_START_HERE/` | STATUS, CASES, roster, FR notes, screenshot catalog, these prompt files, organization/dissection reports |
| 01 | `01_research_archives/` | Part 1…N structured research archives (the self-sufficient session record) |
| 02 | `02_handoffs/` | the one deep-background handoff + dated next-session handoffs |
| 03 | `03_analysis/` | patch maps, runtime results, semantic references, banned register, contradictions, net-new extracts |
| 04 | `04_test_guides_and_reports/` | in-game click paths and what the user actually observed |
| 05 | `05_patches_and_scripts/` | **the only things that touch the exe**: `bat/`, `ps1/`, `py/`, `x64dbg/` |
| 06 | `06_game_data/` | payload variants, loc CSVs, GUI/GFX, string dumps |
| 07 | `07_runtime_logs/` | game/error/system/setup logs (+ `x64dbg/` traces) |
| 08 | `08_steam_vdf/` | Steam manifests |
| 09 | `09_web_captures/` | GitHub / SteamDB HTML |
| 10 | `10_binary_artifacts/` | materialized executables, debug drop, PDBs, manifests |
| 11 | `11_git_patch/` | archived session patches — **provenance only, never re-apply** |
| 12 | `12_raw_chat_logs/` | `INDEX.md` ledger only (raw exports are torn apart, not kept) |
| 13 | `13_save_and_cache/` | `.ck2` saves, `.meta`, feat-cache token states |
| 14 | `14_screenshots_and_media/` | image drop zone; catalog is canonical, binaries optional |

---

## 3. Artifact class → home (first-try placement)

| Incoming class | Goes to | Notes |
|---|---|---|
| New patch/tool (`.bat`/`.ps1`/`.py`) | `05_patches_and_scripts/{bat,ps1,py}` | guarded only; hash into MASTER; every file a doc names must exist |
| Debugger trace / x64dbg script | `05_patches_and_scripts/x64dbg/` (helper) + `07_runtime_logs/x64dbg/` (captured log) | distill; never keep four identical launch deaths |
| New game data (payload, CSV, strings, GUI/GFX) | `06_game_data/` | key payload variants by SHA; never `gfx/test.dds`, never global string edits |
| New runtime log from a test boot | `07_runtime_logs/` | name by boot + purpose; same size ≠ same content — verify by hash |
| New save (`.ck2`/`.meta`) or feat-cache state | `13_save_and_cache/` | record archive SHA, uncompressed size, internal date, `special_event`, `bronzeman`, globals; if the binary is not uploaded, MASTER metadata only |
| New screenshot / media | `14_screenshots_and_media/` + `SCREENSHOTS_CATALOG.md` | catalog is canonical; binaries may be deleted after cataloging |
| New raw chat/session export | **dissect, then remove** | §5 process → Part N / net-new extracts → INDEX ledger |
| New executable / PDB / RAR | `10_binary_artifacts/` | hashes + manifests only in public text; redact builder paths to `<buildroot>` |
| New git patch of already-merged work | `11_git_patch/` | provenance; never re-apply |
| New analysis conclusion (no new artifact) | fold into the existing `03_analysis/` doc that owns the fact class | no parallel docs |

---

## 4. Before writing anything: the coverage sweep

A raw file may *look* fully archived and still hold **net-new raw facts**. Never
assume. For every incoming file:

1. Extract every `0x…` address, every 6–64-hex token, every SHA, every size, every
   mangled symbol, every user-runtime sentence.
2. Grep each against `01_research_archives/`, `02_handoffs/`, `03_analysis/`,
   `00_START_HERE/`, `12_raw_chat_logs/INDEX.md`.
3. Anything found **only** in the raw file is net-new and must be preserved: either
   folded into the owning doc with a `source: <raw file>` pointer, or listed in
   `03_analysis/RAWLOG_NETNEW_EXTRACTS.md`.
4. Everything already covered becomes one line — "already covered → see X" — not a
   re-write.
5. Report the sweep result (net-new vs restated) in the ingest report.

**Tool-output-heavy fragments are first-class evidence, not noise.** objdump /
capstone dumps, `grep -aob` scans, `nm -C` symbol lists, PowerShell transcripts,
x64dbg logs and patcher diffs are often the only surviving record of an exact
offset, VA or byte. Distil the conclusion into the normal archive and keep the
byte-level residue in the extracts doc.

---

## 5. Tearing a raw log apart (the A–F skeleton)

Output **one** Markdown file per session/arc, titled
`RESEARCH ARCHIVE — CK2 Monarch's Journey — Part <n> (<short description>)`, with
exactly this skeleton so parts can be merged:

- **A. ORIENTATION**
  - **A0 read-first:** current safe state; banned artifacts; naming-collision
    table (Label → SHA-256 → what it was → ✅ proven / ❌ banned / 🟡 abandoned /
    🟢 target); the immediate next action.
  - A1 goal in one sentence. A2 status dashboard as of the end of this part.
  - A3 where this part sits in time (overlaps, wrap-arounds, branch IDs
    `arena/01a0…`, PR numbers, GitHub-vs-chat session limits).
  - A4 one-paragraph story.
- **B. STORY**
  - B1 numbered timeline: action → observation (including interruption handling:
    "you've got interrupted. continue" → large scripted batches).
  - B2 evolution of the mental model — every working theory in turn and what
    confirmed or killed it. **Wrong theories are valuable; record them.**
  - B3 lineage table for any new patch generation/tool: what changed, runtime
    result, what it proved. Failed generations get full entries with exact bytes
    kept "for the record — do not reuse"; abandoned ones carry their disproof.
- **C. KNOWLEDGE BASE**
  - architecture/mechanics learned; version and content facts;
  - **all verified calculations** — recompute every timestamp, offset arithmetic,
    size delta, hash length, jump/branch displacement, instruction encoding,
    VA↔file-offset, expiry overflow, base64 size math; report any discrepancy;
  - complete artifact table (file, size, SHA-256, path, role, carried-over vs new;
    for saves also internal date, `special_event`, `bronzeman`, globals; for the
    payload also ruler/challenge counts and `event_time_end`; for exes also build
    string, PE/linker timestamps, GUID/age);
  - **complete cumulative patch-offset map** extracted from the deployment log
    (ground truth — it fills gaps the narrative leaves);
  - key code addresses/functions, including helpers whose **data direction** was
    established (read vs write — e.g. a vector-append writer must never be called
    on a load path);
  - **persistence model:** ordinary CK2 script globals vs the local feat cache
    (`q847rsja8ndx` / `feat_progress_storage`) vs save-token readers;
  - cross-version assessment if present (component matrix + feasible/not);
  - PDB identity block if debug files are present (inventory, CRC, PE identity,
    MSF streams, GUID/age, verdict, toolchain, limitations, confidence).
- **D. ATTEMPTS & DEAD ENDS** — ledger of directions taken with verdict
  (✅/❌/🟡) and what each proved; dead ends closed *with the evidence that closed
  them*; explicit **banned** list and **abandoned** list; operational-safety
  restatement.
- **E. OPEN THREADS & FUTURE DIRECTIONS** — ranked open questions (anomalies
  mentioned once and never resolved get numbered entries too); concrete next
  steps; deferred directions; maintenance deadlines (payload expiry
  **2030-01-03**, safe ceiling `2147310847`, hard wall 2038-01-17/19);
  materials received but **not yet analyzed**; the exact handoff for the next
  session (quote a prepared brief verbatim); personal-storage list; ranked pending
  uploads; runtime-outcome matrix if present.
- **F. CONTEXT** — environment and constraints (OS, paths, upload limits, offline
  requirement, 128 MB / 10 K-file workspace budget, chat and GitHub session limits,
  user skill level, Russian locale handling for `Новый…` / `Снимок экрана`
  filenames and Russian PowerShell errors); safety rules (incl. banned builds and
  functions); curiosities and side findings; **method lessons with an error ledger**
  (every place the log's AI or the user was wrong, the wrong claim, the correction,
  how it was caught); evidence inventory (which upload proves which conclusion,
  screenshot numbers → milestones, documents written with line counts, end-of-log
  file list, folder/duplicate convention); screenshot-catalog reference;
  **info-preservation audit** (did the described actions reach main? content vs git
  history; PR merge status; intentional exclusions; file counts).

If the source is a folder holding several session logs, also produce
`00_START_HERE/DISSECTION_REPORT_<date>.md` — one row per log: what it was, what it
proved, where each fact now lives, preservation status.

---

## 6. The twelve binding rules (from v4, still in force)

1. **Preserve verbatim:** SHA-256 hashes, file sizes, file offsets and byte
   patterns, timestamps/unix values, version and build strings, function addresses,
   exact file paths, console commands, parser keys, save-token IDs, error-log lines
   — and **the user's runtime reports** (crash triggers, UI states, log excerpts),
   which are primary evidence.
2. **Recompute every numeric claim** where possible (dates from unix times, overflow
   arithmetic, deltas, branch displacements, section-offset conversions, base64 size
   math). Flag mismatches explicitly. A patch that is byte-perfect but semantically
   wrong is a key finding — record mechanics and semantics separately.
3. **Never invent facts.** An ambiguous or unresolved ending is recorded as an open
   question; an unresolved ending is a finding, not a failure.
4. **Noise to remove:** upload receipts and "part N arrived" confirmations,
   greetings/thanks, repeated file lists, duplicate explanations, session
   housekeeping — but keep the *facts* those contained. Streaming "thinking out
   loud" collapses into the conclusions it reached, keeping every wrong turn that
   changed direction. Tool-output fragments are **not** noise.
5. **Contradictions protocol:** where a part conflicts with an earlier part (or with
   itself at different moments), list both claims with evidence pointers, state
   which evidence is primary, and never silently pick a side. Real contradictions go
   into `03_analysis/CONTRADICTIONS.md`; per-part merge notes carry what is new vs
   restated.
6. If a log ends mid-problem, the last section states exactly where it stopped, what
   materials are already in hand, and the immediate next action.
7. Where the session produced its own recommendation or a prepared brief for the next
   session, **quote it verbatim** rather than paraphrasing.
8. **Banned (tested, corrupting — never reuse) ≠ abandoned (built, premise
   disproven, never shipped).** Record disproof evidence for abandoned builds.
9. **Binary policy:** never commit decoded executables, RARs, PDBs or patched
   binaries into public text — only hashes, manifests and guarded patchers. Redact
   builder paths to `<buildroot>`.
10. **Naming:** key every build by SHA-256; include the naming-collision table in A0.
11. **Runnable-tooling integrity:** before finishing, confirm every `.bat`/`.ps1`/`.py`
    referenced by the log exists intact under `05_patches_and_scripts/{bat,ps1,py}`
    and that no loose `.txt`-mirror copies survive. Report the check.
12. **Living INDEX:** update `12_raw_chat_logs/INDEX.md` (status → ✅ + where the
    conclusions live) for every fragment processed in the pass.

---

## 7. Dedup, storage and preservation

**Dedup by content, never by name:**

1. Compute SHA-256 of the incoming file.
2. Check `MASTER_ARTIFACT_TABLE.md`, then the whole tree.
3. Byte-identical → **discard** (record it in the ledger; never keep a `(1)` copy,
   never keep a `.txt` mirror of a patcher).
4. Same size ≠ same content (boot logs routinely share a size) — verify by hash and
   keep genuine variants.
5. Unique → place it, then record hash + size + role in `MASTER_ARTIFACT_TABLE.md`
   (or in the doc that owns that fact class).
6. If the material is already *represented* by distilled conclusions but the raw
   file is new to the repo, fold the net-new facts into the right doc with a
   `source: …` pointer, then remove the raw file (git history retains it).

**Preservation standard:** information must live **by content** in the organized
tree — not only inside a dump folder, a raw export, or git history. "It's in git
history" is a safety net, not a filing system.

**Living documents — repair is mandatory after any ingest.** If the STATUS banner
disagrees with PLAN / README glance / CASES / MASTER / preflight `$KnownExe`, fix
it in the same pass. Always consider: `STATUS.md`, `CASES_AND_FINDINGS.md`,
`MASTER_ARTIFACT_TABLE.md`, `PLAN.md`, `README.md`, `12_raw_chat_logs/INDEX.md`,
`CONTINUE_SEMANTIC_REFERENCE.md`, `BANNED_ARTIFACTS.md` wording,
`WINDOWS_333_PATCH_MAP.md` (+ `.csv`), `ps1/preflight_ck2_mj.ps1` `$KnownExe`.

**Debugger-trace hygiene:** distil breakpoints, registers and
`Application debug[…]` lines; discard module inventories, TLS-callback stops, ntdll
stacks and repeated `406D1388` (`MS_VC_EXCEPTION` / `SetThreadName`) launch deaths.
Keep the `[MJ]` bursts verbatim — they are the evidence.

**The repo is the handoff.** Do not spawn a new parallel archive per session. New
facts update the existing docs; a dated next-session handoff is written only when
the user asks to carry context outside GitHub.

---

## 8. Finish every pass with the integrity + preservation audit

1. **Runnable tooling:** every `.bat`/`.ps1`/`.py` that any doc or log names exists
   in `05_patches_and_scripts/`. Unguarded one-liners that poke an offset without a
   SHA guard are **not** deliverables — keep the offset/byte in the patch map and
   throw the one-liner away.
2. **Info-preservation audit:** is the new info preserved by content? Are the
   actions reflected in the tree?
3. **Contradictions:** appended where real; both sides kept.
4. **Numeric verification:** recompute what the material asserts; flag mismatches.
5. **Report:** accepted / duplicate / distilled / net-new / living-docs touched /
   mismatches / tooling check result.

---

## 9. Method lessons worth re-reading before a new pass

- Use `cmp`/hashes byte-for-byte, not size or name.
- Keep Russian-named exports as they are; map them via the catalog/INDEX instead of
  renaming (preserves provenance).
- Use `git mv` for renames so history follows.
- Workspace budget is 128 MB / 10 K files — delete reproducible intermediates.
- GitHub sessions are shorter than chat sessions; handoff discipline matters.
- A `.bat` that "flickers and closes" is a **cmd.exe parse error**, not a mystery:
  either LF-only line endings, or PowerShell parentheses inside a multi-line
  `if ( … )` block. Keep `.bat` files CRLF and keep PowerShell calls out of nested
  `if` blocks; always provide a direct-PowerShell fallback.
- A breakpoint address and a patch offset are different number spaces:
  x64dbg `module+X` is an **RVA**, while patch docs quote **raw file offsets**;
  for this PE `VA = raw + 0x140000c00`, so `module+X` ↔ `raw = X − 0xC00`.
  Always convert before claiming a breakpoint proves a patch ran.
- Cross-check dates, counters and screen identity with the user before theorising;
  targeted yes/no questions resolve ambiguous evidence faster than more theory.

---

## 10. Output shape

- A raw-log tear-down → `RESEARCH ARCHIVE … Part <n>` (A–F) +
  `DISSECTION_REPORT_<date>.md` when several logs are involved.
- A discrete-artifact ingest → a short ingest report: material received →
  classified → dedup verdict → where each piece now lives → living docs updated →
  integrity check → flagged mismatches.
