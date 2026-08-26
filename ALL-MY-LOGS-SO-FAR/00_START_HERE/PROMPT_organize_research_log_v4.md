# Prompt for another AI — organizing a part of the CK2 Monarch's Journey research log (v4)

**How to use:** paste everything below the line (together with, or right before, the raw log file of that part) into the other AI. If that part covers a specific patch version or session, say so in one sentence at the top. This is the **operative** prompt; v1–v3 are kept only as history.

> **What changed vs v3, and why (delete this block when pasting):**
> v3 was strong (A0 read-first + naming-collision table, banned vs abandoned distinction, persistence model, runtime outcome matrix, folder/duplicate convention, personal-storage + pending-uploads, info-preservation audit, maintenance deadlines, cross-version assessment, PDB identity block, GitHub-session limits, screenshot catalog). v4 closes gaps found while **re-dissecting the already-archived raw fragments** (`chat_fragment_may333_*` and `chat_fragment_disasm_*`, which the INDEX flagged 🟡) and re-verifying that all runnable bats/ps1/py are intact:
> 1. **Dissect-or-verify-first, don't assume.** A raw file may *look* fully archived but still hold **net-new raw facts** (VAs, string addresses, symbol lists) not in any Part or analysis doc. Before marking a fragment "already sorted", do a **cross-reference sweep**: grep its addresses/strings/symbols against `01_research_archives/`, `03_analysis/`, `02_handoffs/`; anything present only in the raw file must be preserved — either folded into the right doc with a "source: raw fragment" pointer, or explicitly listed as raw evidence. (This pass found the Continue-xref disassembly set `0x1407bf650/…/0x1407be200`, the `load_button` VA `0x141078318`, and the broader Linux save/load `nm` symbol list — none were in any archive — and recorded them in `CONTINUE_SEMANTIC_REFERENCE.md` §E.)
> 2. **Tool-output-heavy fragments are first-class evidence.** Objdump/disassembly dumps, `grep -aob` string scans, `nm -C` symbol lists, and patcher-source-diff transcripts are **not noise to delete**; they are the only surviving record of exact offsets/VAs/bytes. Distill their *conclusions* into the normal archive (patch maps, helper analysis) and keep the raw file in `12_raw_chat_logs/` as the byte-level source, cross-referenced from the conclusion.
> 3. **Keep the INDEX a living map.** Update `12_raw_chat_logs/INDEX.md` status flags (🟡 → ✅ dissected + where conclusions live) every time a fragment is processed, so future passes don't re-check the same files.
> 4. **Runnable tooling integrity check.** Before finishing, verify every `.bat` / `.ps1` / `.py` that any log references exists **intact** in `05_patches_and_scripts/{bat,ps1,py}` (all patch generations v1–v6 + check/revert/prepare/dump helpers; no loose duplicates elsewhere in the repo, no `.txt`-mirror leftovers). These are the only things that touch the exe — they must never be lost to a dedup pass.

---

You are organizing a raw exported conversation log — a part of a larger reverse-engineering research project. The project: **restoring the retired "Monarch's Journey" mode of Crusader Kings II to run fully offline on Windows** (via payload re-activation, version archaeology, binary analysis, and hash-guarded executable patches; patch generations are named v1…v6, later parts may go higher — some generations FAILED and are banned, some ABANDONED). The logs are chats between a non-technical Windows user and an AI assistant, including file-upload listings, tool outputs, screenshot references, and AI-written reports. A single export may contain one chat that spans/overlaps other chats (the user works in several sessions and calls earlier ones e.g. "your father"); reconstruct the true chronology. Some logs are **cleanup/organization sessions** themselves (sorting files into subfolders, creating README/PLAN/INDEX, PRs). Some logs are **tool-output fragments** (objdump disassembly, grep scans, nm symbol lists, command transcripts) rather than prose chat — treat these as evidence, not noise.

**First, before writing anything, run a coverage sweep:** check whether this log/part is already captured in `01_research_archives/` (Parts 1–3), `03_analysis/`, `02_handoffs/`, and the `12_raw_chat_logs/INDEX.md` table. Identify exactly what is **net-new** vs already-distilled. Only the net-new facts need a new archive entry; the rest become a short "already covered — see X" note with a cross-reference. Then:

Your job: turn the raw log into ONE structured Markdown **research archive** file so that no important information is ever lost. Do not summarize away detail — compress only true noise. Future sessions (human or AI) will rely on this file exclusively, without access to the raw log. **Also perform an info-preservation audit**: did actions described in the log make it into main branch? Is info preserved via content vs git history?

**Produce exactly this structure** (same skeleton as the other parts, so files can be merged):

- **A. ORIENTATION**
  - **A0 "read this first"**: current safe state, **banned artifacts** (failed build hashes, unsafe helpers that must never be called), **naming collision table** (Label → SHA-256 → What it was → Status: ✅ runtime-proven / ❌ BANNED / 🟡 ABANDONED / 🟢 current target), and the immediate next action.
  - A1 goal in one sentence.
  - A2 status dashboard (works / broken / open) *as of the end of this part*.
  - A3 where this part sits in time relative to other parts/sessions (note any overlap or wrap-around, branch IDs like `arena/01a02609…`, PR numbers, GitHub vs chat session limits).
  - A4 one-paragraph story of this part.

- **B. STORY**
  - B1 timeline of this part (numbered events: action → observation, include interruption handling: "you've got interrupted. continue" → large scripted batches).
  - B2 evolution of the mental model (each working theory in turn and what confirmed or killed it — wrong theories are valuable, record them).
  - B3 if new patch generations/tools appear: lineage table (what changed, runtime result, what it proved) — **failed generations get full entries with exact bytes kept "for the record — do not reuse"**, abandoned generations marked with disproof.

- **C. KNOWLEDGE BASE**
  - Architecture/mechanics learned; version & content facts.
  - **All verified calculations** (recompute every timestamp, offset arithmetic, size delta, hash length, **jump/branch displacement, instruction encoding, VA↔file-offset, expiry overflow, base64 size math** you find — report any discrepancy).
  - Complete artifact table (file, size, SHA-256, path, role — mark carried over vs newly stated; **for saves:** archive SHA, uncompressed size, internal date, `special_event`, `bronzeman=yes`, globals like `global_heretical_company`; **for payload:** size, SHA, ruler count, `event_time_end` values, expiry handling; **for exes:** build string, PE timestamp, linker timestamp, size, GUID/age if PDB present).
  - **Complete patch-offset map — extract definitive cumulative table from any deployment/apply/patcher log (ground truth, may fill gaps narrative left)**.
  - Key code addresses/functions (including helpers whose **data direction** was established — read vs write, e.g. `0x1409e8200` = vector append write-direction, must never be called on load path).
  - **Persistence model:** distinguish ordinary CK2 script globals vs local feat cache (`q847rsja8ndx` / `feat_progress_storage`) vs save token reader (e.g. token `0x3816` no-op).
  - **Cross-version assessment** if present: component matrix (GameSparks SDK, payload parser, `gs_virtual/feat_script` loader, MJ panel controller, Bronzeman/feat machinery) + verdict (feasible / not feasible).
  - **PDB identity block if debug files present:** file inventory (relative path, size, SHA-256, format: PE32, RAR5 multi-volume, etc.), extracted contents (CRC-verified), PE identity (machine, sections, timestamp, RSDS GUID/age/PDB path with `<buildroot>` redaction), PDB identity (MSF 7.00, block size, streams, impv, sig, age, GUID, DBI ver, modules, type records, srcsrv), **verdict exact match / mismatch / unverifiable**, toolchain (e.g. cl 16.00.40219.1 VS2010 SP1), limitations and confidence.

- **D. ATTEMPTS & DEAD ENDS**
  - Ledger of **directions taken, each with verdict (✅/❌/🟡) and what it proved**.
  - Dead ends closed WITH evidence that closed them; disproven theories.
  - **Explicit "do not revisit / banned" list** (failed build hashes, unsafe helpers, superseded approaches) **plus "abandoned" list** (built but premise disproven, never shipped — e.g. feat-V7 `0074af70…` disproven by fresh Pavao Bronze).
  - Operational safety restatement.

- **E. OPEN THREADS & FUTURE DIRECTIONS**
  - Open questions ranked (including **anomalies mentioned once and never resolved** — they get numbered entries too).
  - Concrete next steps; deferred/unexplored directions the log mentions or implies.
  - Ideas beyond original goal (adjacent opportunities, reusable techniques, maintenance deadlines like expiring timestamps: **payload expiry 2030-01-03, ceiling 2147310847, hard wall 2038-01-17/19**).
  - **Flag any materials received/verified but NOT yet analyzed** (e.g. Linux 3.3.3 binary 27,729,272 B SHA `99776be0…` uploaded, verified, unanalyzed).
  - **Exact handoff for next session, quoting any prepared brief verbatim**.
  - **Personal storage list:** exes, Base64+manifests, PDB, screenshots, saves, patch scripts (what user should keep outside repo).
  - **Pending useful uploads ranked:** full late payload with 5 missing rulers (Liao, Basarab, Mindaugas, Botstain, Stefan), reward gallery material, V7 test capture after patch, PDB for exact May build.
  - **Outcome matrix for runtime tests** (e.g. A-D: correct date + restored value + interface persistence + live eval) if present.

- **F. CONTEXT**
  - Environment & constraints (OS, paths, upload limits, offline requirement, workspace budget 128 MB, chat/message limits, **GitHub session limits**, user skill level, **Russian locale handling** for `Новый…` and `Снимок экрана` filenames, PowerShell errors in Russian).
  - Safety rules (e.g. never run `wipe_feats`, never share `pdx_login.txt`/tokens, never distribute patched executables — only guarded patchers; **plus banned builds/functions**).
  - Curiosities/side-findings not needed for goal (hidden console commands, dev codenames, embedded source filenames, stock-game quirks, error-log fingerprints like `savegamehelper.cpp:314` "Unexpected token").
  - Method lessons — **including error ledger: every place log's AI (or user) was wrong, what wrong claim was, what correction was, how caught**.
  - Evidence inventory (which uploads/screenshots/logs prove which conclusion, screenshot numbers mapped to milestones, **documents written during session with line counts**, end-of-log workspace file list, **folder convention + duplicate handling**: byte-for-byte verification via `cmp`, `(1)` suffix, boot log variants same size different content all kept, `99_duplicates/` removed, 15 subfolders, README/PLAN/INDEX creation, PR numbers).
  - **Screenshot catalog reference** (e.g. `SCREENSHOTS_CATALOG.md` drop zones A-H, filename→case cheat sheet).
  - **Info preservation audit:** did actions described in log make it into main branch? Compare content vs git history (squashed `cad3e23` vs original commits `e2d3a8f`, `baf5cda`, `3218e77`, `cb1df83`, `09f2d51`), PR merge status, intentional exclusions (banned/abandoned builds, large binaries, scratch tooling), file counts.

**Rules:**
1. Preserve verbatim: all SHA-256 hashes, file sizes, file offsets and byte patterns, timestamps/unix values, version/build strings, function addresses, exact file paths, console commands, parser keys, save-token IDs, error-log lines, and **user's runtime reports (crash triggers, UI states, log excerpts) — primary evidence**.
2. Every numeric claim from log must be independently recomputed where possible (dates from unix times, overflow arithmetic, deltas, branch displacements, section-offset conversions, base64 size math). Flag mismatches explicitly. A patch that is byte-perfect but semantically wrong is a key finding — record mechanics and semantics separately.
3. Never invent facts. If something is ambiguous or unresolved at part's end, record as open question — unresolved ending is finding, not failure.
4. Noise to remove: upload receipts and "part N arrived" confirmations, greetings/thanks, repeated file lists, duplicate explanations, session-housekeeping chatter — but keep *facts* those contained. Streaming "thinking out loud" fragments collapsed into conclusions they reached, keeping every wrong turn that changed direction. **Tool-output fragments are NOT noise — keep them as evidence and cross-reference their unique VAs/strings/symbols.**
5. **Contradictions protocol:** where this part conflicts with earlier parts (or itself at different moments), list both claims with evidence pointers, state which evidence is primary, and never silently pick a side — put under final "Merge notes" heading together with what is new vs restated.
6. If log ends mid-problem, last section must state exactly where it stopped, what materials already in hand, and immediate next action.
7. Where session's own recommendation or prepared brief for next session exists, quote it verbatim rather than paraphrasing.
8. **Distinguish banned (corrupts) vs abandoned (premise disproven)** — record disproof evidence for abandoned.
9. **Binary policy:** never commit decoded executables, RARs, PDBs, or patched binaries — only hashes, manifests, and guarded patchers. Redact builder paths to `<buildroot>`.
10. **Naming:** key every build by SHA-256, never label alone. Include naming collision table in A0.
11. **Runnable tooling integrity:** before finishing, confirm every `.bat`/`.ps1`/`.py` referenced by the log exists intact under `05_patches_and_scripts/{bat,ps1,py}` and that no loose `.txt`-mirror copies survive. Report the check.
12. **Living INDEX:** update `12_raw_chat_logs/INDEX.md` (status → ✅ + where conclusions live) for every fragment processed this pass.

Output: a single Markdown file titled `RESEARCH ARCHIVE — CK2 Monarch's Journey — Part <n> (<short description>)`. If source is a cleanup folder with multiple session logs, also produce `DISSECTION_REPORT.md` summarizing each log's actions and preservation status.
