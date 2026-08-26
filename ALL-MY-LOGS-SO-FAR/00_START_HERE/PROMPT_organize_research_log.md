# Prompt for another AI — organizing a part of the CK2 Monarch's Journey research log

**How to use:** paste everything below the line (together with, or right before, the raw log file of that part) into the other AI. If that part covers a specific patch version or session, say so in one sentence at the top.

---

You are organizing a raw exported conversation log — a part of a larger reverse-engineering research project. The project: **restoring the retired "Monarch's Journey" mode of Crusader Kings II to run fully offline on Windows** (via payload re-activation, version archaeology, binary analysis, and hash-guarded executable patches; patch generations are named v1…v5, later parts may go higher). The logs are chats between a non-technical Windows user and an AI assistant, including file-upload listings, tool outputs, screenshots references, and AI-written reports.

Your job: turn the raw log into ONE structured Markdown **research archive** file so that no important information is ever lost. Do not summarize away detail — compress only true noise. Future sessions (human or AI) will rely on this file exclusively, without access to the raw log.

**Produce exactly this structure** (same skeleton as the other parts, so files can be merged):

- **A. ORIENTATION** — goal in one sentence; status dashboard (works / broken / open) *as of the end of this part*; one-paragraph story of this part.
- **B. STORY** — B1 timeline of this part (numbered events: action → observation); B2 evolution of the mental model (each working theory in turn and what confirmed or killed it — wrong theories are valuable, record them); B3 if new patch generations/tools appear: lineage table (what changed, runtime result, what it proved).
- **C. KNOWLEDGE BASE** — architecture/mechanics learned; version & content facts; **all verified calculations** (recompute every timestamp, offset arithmetic, size delta, hash length you find — report any discrepancy with the log); complete artifact table (file, size, SHA-256, path); complete patch-offset map (offset, original bytes, patched bytes, purpose); key code addresses/functions.
- **D. ATTEMPTS & DEAD ENDS** — chronological attempt ledger with verdicts (✅/❌/🟡); dead ends closed WITH the evidence that closed them; disproven theories.
- **E. OPEN THREADS & FUTURE DIRECTIONS** — open questions ranked; concrete next steps; deferred/unexplored directions the log mentions or implies; ideas beyond the original goal (adjacent opportunities, reusable techniques, maintenance deadlines like expiring timestamps); what to hand the next session.
- **F. CONTEXT** — environment & constraints (OS, paths, upload limits, offline requirement, user skill level); safety rules (e.g. never run `wipe_feats`, never share `pdx_login.txt`/tokens, never distribute patched executables — only guarded patchers); curiosities/side-findings not needed for the goal (hidden console commands, dev codenames, embedded source filenames, stock-game quirks); method lessons; evidence inventory (which uploads/screenshots/logs prove which conclusion, screenshot numbers mapped to milestones).

**Rules:**
1. Preserve verbatim: all SHA-256 hashes, file sizes, file offsets and byte patterns, timestamps/unix values, version/build strings, function addresses, exact file paths, console commands, parser keys, error-log lines.
2. Every numeric claim from the log must be independently recomputed where possible (dates from unix times, overflow arithmetic, deltas). Flag mismatches explicitly.
3. Never invent facts. If something is ambiguous or unresolved at the part's end, record it as an open question — an unresolved ending is a finding, not a failure.
4. Noise to remove: upload receipts and "part N arrived" confirmations, greetings/thanks, repeated file lists, full script/batch sources (record only purpose + identifying hash), duplicate explanations, session-housekeeping chatter — but keep the *facts* those contained.
5. Where this part overlaps earlier parts, note it under a final "Merge notes" heading (what is new vs. restated, any contradictions with earlier conclusions).
6. If the log ends mid-problem, the last section must state exactly where it stopped and the immediate next action.

Output: a single Markdown file titled `RESEARCH ARCHIVE — CK2 Monarch's Journey — Part <n> (<short description>)`.
