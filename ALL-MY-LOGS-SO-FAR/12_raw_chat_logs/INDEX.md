# Raw chat-log index (ALL raw logs torn apart 2026-08-26)

> **Status: this folder now holds NO raw files.** Every exported chat/session
> log and fragment in this repo was fully dissected on 2026-08-26 and its
> information sorted into the structured archive (`01_research_archives/`,
> `03_analysis/`, `02_handoffs/`). The raw `.txt` exports were **deleted**.
> Net-new byte-level facts that existed ONLY in the raw logs were preserved in
> `03_analysis/RAWLOG_NETNEW_EXTRACTS.md` before deletion.
>
> **Migration rule:** copy the organized tree only. Do NOT copy raw staging
> files. If the restoration project repo already has logs dissected here, key
> by SHA (see naming-collision table in Part 3 and `PROMPT_organize_research_log_v5.md` Step 0).

## How to trace any raw fact
1. The **research archives** are the self-sufficient record of every session:
   - Part 1 = `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE.md` (father session, v1–v5)
   - Part 2 = `…_PART2.md` (second session, V5, failed-V6)
   - Part 3 = `…_PART3.md` (successful V6, abandoned feat-V7, road to Continue)
2. **Byte-level extras only in the raw logs** → `03_analysis/RAWLOG_NETNEW_EXTRACTS.md`.
3. Analysis documents (`03_analysis/`) hold the distilled patch maps, Continue
   semantics, cross-version assessment, PDB/symbol notes, banned register.
4. This table maps each deleted raw file → the archive section it fed.

## Deleted raw files → where their content lives

| Deleted raw file | Lines | What it was | Content went to |
|---|---:|---|---|
| `new text doc(first).txt` | 6,463 | First/father session — the original investigation (payload expiry → depot archaeology → Linux `CNullGameSpark` → Windows v1–v5, persistence cliffhanger) | **Part 1** |
| `previous chat log.txt` | 6,463 | Re-export/near-dup of the above (differs only by "Arena…" footer) | duplicate source → Part 1 |
| `session_father_monarchs_expiry.txt` *(was (6))* | 6,327 | Another father-session export (reads `monarchs.txt`, discovers expiration switch) | Part 1 |
| `previous chat log (2).txt` | 3,193 | Second session ("son") — from the V5 handoff (Windows May333 upload, V5 finalise, V6 build & failed-V6 analysis) | **Part 2** + `RAWLOG_NETNEW_EXTRACTS.md` §1 |
| `new text doc(second).txt` | 3,224 | Another export of the second session (3,193 vs 3,224 lines) | duplicate source → Part 2 + `RAWLOG_NETNEW_EXTRACTS.md` §1 |
| `session_may333_exe_upload.txt` *(was (5))* | 3,189 | May-2020 3.3.3 exe base64 upload session | Part 2 + `RAWLOG_NETNEW_EXTRACTS.md` §1 |
| `session_v2_v5_recap_upload_checklist.txt` *(was (4))* | 1,540 | Reads `previous chat log.txt`; V2→V5 recap + upload checklist | Part 2 |
| `new text doc(third).txt` | 1,600 | Continuation/wrap-around — save forensics, V5 reconstruction, successful 5-branch V6 (`f5b7dfd6…`), 868-line ultimate handoff | **Part 3** |
| `new text doc(fourth).txt` | 411 | V6 runtime verdict, abandoned feat-V7, cross-version/tracing plan, "second look" Pavao Bronze | Part 3 |
| `new text doc(5).txt` | 124 | Shortest — feat-V7 test plan ("two yes/no results"), narrow V8 idea | Part 3 (§D1) |
| `session_featV7_test_plan.txt` *(was (2))* | 82 | feat-V7 two-question test plan (`IsActiveForPlaythrough`, narrow V8) | Part 3 D1 |
| `session_v6_runtime_crossversion_secondlook.txt` *(was (3))* | 370 | V6 runtime test + 4-exe cross-version + "second look" Pavao Bronze | Part 3 + `WINDOWS_3351_PORT_ASSESSMENT.md` |
| `session_featV7_patch_continue_to_V8.txt` *(was (1))* | 1,815 | feat-V7 candidate `0074af70…`; renames Continue fix to V8; cross-version + Linux feat-DB analysis | Part 3 D1, `BANNED_ARTIFACTS.md`, `WINDOWS_3351_PORT_ASSESSMENT.md`, **`RAWLOG_NETNEW_EXTRACTS.md` §2–7** |
| `chat_fragment_may333_v1v2_continue_greyed.txt` *(was `Новый…1`)* | 2,793 | May333 v1/v2 era — Continue/Load/Multiplayer greyed "dirty session", account check | Part 1 + `CONTINUE_SEMANTIC_REFERENCE.md` + `RAWLOG_NETNEW_EXTRACTS.md` §8 |
| `chat_fragment_disasm_v4v5_continue_offsets.txt` *(was `Новый…2`)* | 5,108 | Disassembly-heavy — objdump of `0x1407bf…` xrefs, V4/V5 offset byte maps | `WINDOWS_333_PATCH_MAP.md` + `RAWLOG_NETNEW_EXTRACTS.md` §9 |
| `command_sha256sum_v5_tooling.txt` *(was `Новый…3`)* | 25 | Command transcript — `sha256sum` of V5 tooling + payload | `MASTER_ARTIFACT_TABLE.md` (hashes) |
| `report_fragment_v5_ready.txt` *(was `Новый…4`)* | 43 | Short report — "V5 is ready", account check in shared save validator | Part 1/2 |

> **Earliest cleanup:** the separate `logs to dissect.../` set of six
> `Новый текстовый документ (N).txt` files (reorg/Part1/Part2/PDB-handoff/V7-
> CFG/debug-files investigation transcripts) was already torn apart and deleted
> in an earlier pass; their info is in `README.md`, `PLAN.md`, `ORGANIZATION_HISTORY.md`,
> `DISSECTION_REPORT.md`, `PROMPT_v2/v3`, `WINDOWS_333_PATCH_MAP.md`,
> `02_handoffs/`, and `03_analysis/` (IDENTITY/SYMBOL_*/SEARCH/TYPE_*/DEBUG_INVESTIGATION_TOOLS).

## Notes / cautions (for future sessions)
- ⚠️ **Naming collision across the wrap-around sessions:** "V6" means both the
  *banned* trampoline build `a6cb92b8…` (Part 2) and the *successful*
  5-branch save-selection build `f5b7dfd6…` (Part 3 / baseline). "V7" means both
  the *abandoned* feat-update patch `0074af70…` (Part 3) and the *current*
  Continue-button target (STATUS.md). Key builds by SHA, never label alone.
- The four `Новый…` files mixed genuine session fragments with command/report
  snippets; all were absorbed into Parts 1–2 and `RAWLOG_NETNEW_EXTRACTS.md`.
- Branch IDs seen in exports: `arena/01a02609…` (V6/feat-V7 sessions) and
  `arena/01a02a4a…` (feat-V7 test chat) — useful for chronology.
- Everything is preserved **by content** (archives + extraction doc), not by
  raw retention. If you need raw chat wording, it is recoverable from git
  history (files were deleted via `git rm`, so prior commits still hold them).
