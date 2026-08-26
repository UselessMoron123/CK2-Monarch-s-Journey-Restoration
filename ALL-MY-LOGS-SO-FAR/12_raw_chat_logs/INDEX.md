# Raw chat-log index

These are the original exported chat sessions. They **overlap and wrap around**
(the user worked in multiple sessions and called earlier ones "your father"), so
use this map before archiving any of them.

> **Cleanup 2026-08-26:** 6 additional raw transcripts in `logs to dissect.../` were **torn apart** into info pieces per PROMPT v3 and sorted where needed (see `DISSECTION_REPORT.md`). Their raw files are now deleted — no names remain. This INDEX updated to reflect that their content is preserved via organized files, not via raw log retention. If migrating to restoration project repo, do NOT copy raw staging files — copy organized tree only.

## Main research logs (already organized)

| File | Lines | Size | What it is | Covers | Archive status |
|---|---:|---:|---|---|---|
| `new text doc(first).txt` | 6,463 | 218 KB | **First/father session** — the original investigation | payload expiry → depot archaeology → Linux `CNullGameSpark` breakthrough → Windows v1–v5, ends on the persistence cliffhanger (context limit) | ✅ archived as **Part 1** (`01_research_archives/CK2_MJ_RESEARCH_ARCHIVE.md`) |
| `previous chat log.txt` | 6,463 | 218 KB | Re-export/near-duplicate of the above (same 6,463 lines; differs only by an "Arena…" footer) | same as Part 1 | duplicate source — no new archive needed |
| `previous chat log (2).txt` | 3,193 | 249 KB | **Second session ("son")** — picks up from the V5 handoff | Windows May333 exe upload, V5 patcher finalisation, **V6 build & the failed-V6 analysis** | ✅ archived as **Part 2** (`…_PART2.md`) — verify coverage |
| `new text doc(second).txt` | 3,224 | 251 KB | Another export of the same second session (3,193 vs 3,224 lines — minor header/footer differences) | same as Part 2 | duplicate source of Part 2 |
| `new text doc(third).txt` | 1,600 | 60 KB | Continuation/wrap-around session | Save forensics (both saves valid/distinct), V5 reconstruction, the **successful 5-branch V6** (`f5b7dfd6…`), 868-line ultimate handoff | ✅ archived as **Part 3** (`…_PART3.md`) |
| `new text doc(fourth).txt` | 411 | 21 KB | Short later session | V6 runtime verdict (loaded, interface stayed, "1" present), the **abandoned feat-V7** (`0074af70…`), cross-version/tracing plan, "second look" Pavao Bronze evidence | ✅ archived as **Part 3** |
| `new text doc(5).txt` | 124 | 5.6 KB | Shortest session | feat-V7 test plan only ("two yes/no results"), possible narrow V8 for `IsActiveForPlaythrough`; never applied — premise disproven by Pavao Bronze | ✅ folded into **Part 3** (§D1) |
| `chat_fragment_may333_v1v2_continue_greyed.txt` *(was `Новый текстовый документ1.txt`)* | 2,793 | 141 KB | Session fragment (Russian-named export) — appears to be an earlier-thread export | May333, v1/v2 era, Continue/Load/Multiplayer greyed-out analysis ("in-memory session dirty") | 🟡 check for net-new content vs Part 1; likely same father session, different slice |
| `chat_fragment_disasm_v4v5_continue_offsets.txt` *(was `Новый текстовый документ2.txt`)* | 5,108 | 283 KB | Disassembly-heavy session fragment | objdump of `0x1407bf…` xrefs, V4/V5 Continue-patch offset lists (byte maps like `7504 → 9090`) | 🟡 valuable raw offsets for the cumulative patch map — extract, then archive as Part 3/appendix |
| `command_sha256sum_v5_tooling.txt` *(was `Новый текстовый документ3.txt`)* | 25 | 8.2 KB | Not a chat — a command transcript | `sha256sum` of V5 tooling + payload; V5 readiness blurb; runtime-load pending | source fact for artifact table (hashes) |
| `report_fragment_v5_ready.txt` *(was `Новый текстовый документ4.txt`)* | 43 | 1.6 KB | Not a chat — a short report fragment | "V5 is ready" — account check in shared save validator; load-test steps for Bosnia save | source fact for Part 1/2 |

## Extra transcripts (renamed 2026-08-26, moved here 2026-08-26)

Six more raw exports, formerly in the top-level `adding just to make sure/` folder
(later than the sessions above). They were renamed from the generic
`Новый текстовый документ (N).txt` and now live in this folder (the loose
top-level folder has been removed):

| File | Lines | What it is | Archived as |
|---|---:|---|---|
| `session_father_monarchs_expiry.txt` *(was (6))* | 6,327 | Original "father" session — reads `monarchs.txt`, discovers the expiration switch | Part 1 |
| `session_may333_exe_upload.txt` *(was (5))* | 3,189 | May-2020 3.3.3 exe base64 upload session | Part 2 |
| `session_v2_v5_recap_upload_checklist.txt` *(was (4))* | 1,540 | Reads `previous chat log.txt`; V2→V5 recap + upload checklist | Part 2 |
| `session_v6_runtime_crossversion_secondlook.txt` *(was (3))* | 370 | V6 runtime test + 4-exe cross-version + "second look" Pavao Bronze | Part 3 |
| `session_featV7_patch_continue_to_V8.txt` *(was (1))* | 1,815 | feat-V7 candidate `0074af70…`; renames Continue fix to V8 | Part 3 D1 / `BANNED_ARTIFACTS.md` |
| `session_featV7_test_plan.txt` *(was (2))* | 82 | feat-V7 two-question test plan (`IsActiveForPlaythrough`, narrow V8) | Part 3 D1 |

These six are **different files** from the "logs to dissect" `Новый текстовый
документ (1)–(6).txt` already torn apart and deleted (see cleanup table below) —
the naming collision was the reason for the rename.

## Notes / cautions
- The two **6,463-line** files (`first` and `previous chat log`) are the Part 1
  source; the two **~3,200-line** files (`second` and `previous chat log (2)`)
  are the Part 2 source; `third`/`fourth`/`(5)` are the **Part 3** source.
  All three archives live in `01_research_archives/`.
- ⚠️ **Naming collision across the wrap-around sessions:** "V6" means both the
  *banned* trampoline build `a6cb92b8…` (Part 2) and the *successful*
  5-branch save-selection build `f5b7dfd6…` (Part 3 / current baseline). "V7"
  means both the *abandoned* feat-update patch `0074af70…` (Part 3) and the
  *current* Continue-button target (STATUS.md). Key builds by SHA, never label.
- The four `Новый…` files mix genuine session fragments with command/report
  snippets; they are evidence sources already absorbed into Parts 1–2 and need
  no separate archive.
- Branch IDs seen in exports: `arena/01a02609…` (V6/feat-V7 sessions) and
  `arena/01a02a4a…` (feat-V7 test chat) — useful to disambiguate chronology.

## Cleanup logs (torn apart 2026-08-26, now deleted — content preserved)

| Original file | Lines | What it was | Where its info went | Status |
|---|---|---|---|---|
| `Новый текстовый документ (1).txt` / logs to dissect (1) | 196 | Reorg session — 186-file flat dump → 15 subfolders, 28 duplicates via `cmp`, README/PLAN/INDEX, PR #1 `e2d3a8f` → merge `ab8dae6` | `README.md`, `PLAN.md`, `12_raw_chat_logs/INDEX.md`, `00_START_HERE/ORGANIZATION_HISTORY.md`, `DISSECTION_REPORT.md` | ✅ torn apart, raw deleted |
| `Новый текстовый документ (2).txt` / logs to dissect (2) | 934 | Part 2 archiving session (PROMPT v1 + Part1 archive + second.txt 3,224 lines) | `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART2.md`, `PROMPT_organize_research_log_v2.md` → v3, `WINDOWS_333_PATCH_MAP.md` (v5 offsets gap closed) | ✅ torn apart, raw deleted |
| `Новый текстовый документ (3).txt` / logs to dissect (3) | 1,075 | Part 1 archiving session (first.txt 6,463 lines) | `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE.md`, `PROMPT_organize_research_log.md` | ✅ torn apart, raw deleted |
| `Новый текстовый документ (4).txt` / logs to dissect (4) | 273 | Repo health-check — full picture assessment, upload guide, DEBUGFILES handoff, V7 triage initial, PR #3 `baf5cda` | `02_handoffs/DEBUGFILES_PDB_HANDOFF.md`, `02_handoffs/V7_CONTINUE_INITIAL_TRIAGE.md`, `00_START_HERE/UPLOAD_GUIDE.md`, `03_analysis/IDENTITY.md` etc. | ✅ torn apart, raw deleted |
| `Новый текстовый документ (5).txt` / logs to dissect (5) | 180 | V7 triage continuation — CFG analysis, feat-V7 candidate `0074af70…` offsets `0x00666546` + `0x007856e8`, `things parent AI.../` | `03_analysis/V7_CONTINUE_CFG.md` (recovered, 112 lines), `03_analysis/BANNED_ARTIFACTS.md` (now includes offsets), `00_START_HERE/UPLOAD_GUIDE.md`, Part 3 D1 | ✅ torn apart, raw deleted |
| `Новый текстовый документ (6).txt` / logs to dissect (6) | 3,491 | Debug files investigation — RAR5 extraction, MSF/PDB parsers, 5 deliverables | `03_analysis/IDENTITY.md`, `SYMBOL_SUMMARY.md`, `SEARCH_RESULTS.md`, `TYPE_AND_VTABLE_NOTES.md`, `SYMBOLS_FILTERED.csv`, `03_analysis/DEBUG_INVESTIGATION_TOOLS.md` | ✅ torn apart, raw deleted |

**Result:** `logs to dissect.../` folder now empty and deleted. No raw log names remain — info fully sorted per PROMPT v3 A-F skeleton + preservation audit. For migration to restoration project repo: copy organized tree only, do NOT copy raw staging folder. If restoration repo has old logs already dissected here, key by SHA (see naming collision table in Part 3 and PROMPT v3 A0).
