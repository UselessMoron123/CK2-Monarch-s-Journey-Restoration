# DISSECTION REPORT — 2026-08-30

Source material: the staging folder `last log/` (9 `.txt` exports,
1,827,795 bytes, 23,146 lines — plus the three byte-identical artifact copies
listed in §1 that were removed to their canonical homes).
Instructions applied: `00_START_HERE/PROMPT_organize_research_log_v7.md`
(consolidation of v4 §1–§10 + v5 §4–§7 + v6 §8–§13), rules 2, 3, 6, 7, 8, 11, 12.
Companion ledger: `12_raw_chat_logs/INDEX.md`.
Prior reports of this kind: `DISSECTION_REPORT_2026-08-26.md`,
`INGEST_PLAN_DUMP_2026-08-27.md`, `INGEST_REPORT_DUMP_2026-08-27.md`
(there is no 2026-08-29 ingest report — that session produced
`02_handoffs/NEXT_SESSION_HANDOFF_2026-08-29.md` instead).

**This folder holds seven distinct work/new sessions plus two artifact copies.**
Of the nine `.txt` exports, eight are the source sessions below; the ninth,
`organisation log.txt`, is the **orchestrating session itself** (the pass that
wrote this report, the v7 rulebook, Part 5, and merged PR #17). It was
overlooked in the first pass and is ledgered here as that session's own
transcript. All were read in full; nothing is left unexamined.

---

## 1. Disposition, file by file

| # | File | Bytes / SHA-256 (short) | Session | Disposition |
|---|---|---|---|---|
| 1 | `last log (for now).txt` | 6,373 ln / `728924ac` | `arena/01a0534b` — trace analysis → stock-exe disassembly → **V9 built & delivered** | **KEPT** in place as the raw V9 session; all facts extracted to Part 5 §B/§C and `03_analysis/V9_RUNTIME_RESULTS.md`; verbatim inline patcher reconstructed to `05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` |
| 2 | `x64dbg logs.txt` | 504 ln / `cbca3154` | trace output of the V8 clean run | **KEPT** in place as the primary V8 runtime evidence; content transcribed into `03_analysis/V9_RUNTIME_RESULTS.md` §"What the clean trace showed" and the breakpoint/`bplog` templates into `README_MJ_V9_CLEAN_TRACE.md` |
| 3 | `first first raw log.txt` | 4,358 ln / `f6d231e5` | `arena/01a044b2` — V8 built, preflight fixed, CRLF fix, PR request **rejected by the service** | **KEPT** (superset of #4); net-new residue in `RAWLOG_NETNEW_EXTRACTS.md` §11.6 |
| 4 | `raw chat.txt` | 4,346 ln / `823eceb3` | same session | **DUPLICATE by content**: a strict prefix of #3 (first 4,346 lines identical; #3 has 12 extra trailing lines). Kept on disk, flagged in `12_raw_chat_logs/INDEX.md` as *do not quote separately* |
| 5 | `another raw log.txt` | 3,743 ln / `d80e225a` | `arena/01a04d46` — V8 confirmed installed, cache/save forensics, `RestoreDeviceObjects` gate, clean-trace helper, **PR #15** | **KEPT**; facts → Part 5 §B/§C4, §11.2/§11.3 |
| 6 | `another other raw log.txt` | 1,142 ln / `67c78a63` | `arena/01a049a4` — `NEXT_SESSION_HANDOFF_2026-08-29.md`, **PR #14** | **KEPT**; facts → `02_handoffs/` + §11.7 |
| 7 | `one more raw log.txt` | 426 ln / `3d2267be` | *no repo* — user applied V8 by hand | **DUPLICATE by content**: identical to lines 8–433 of #5 (verified by `diff`), but it carries the **verbatim cache dump** and the **`.bat` flicker root cause** that are not in the archived docs. Net-new residue preserved in §11.2/§11.4, so it is safe to delete |
| 8 | `first raw log.txt` | 497 ln / `5179eb08` | `arena/01a04980` — hash chain re-verified, **PR #13** | **KEPT**; facts → §11.7, Part 5 §A3 |
| 8b | `organisation log.txt` | 1,757 ln / `79d6007f` | `arena/01a053d9` — **the orchestrating session** (wrote this report, v7 rulebook, Part 5, V9 docs; created + merged **PR #17**) | **LEDGERED HERE** (was omitted in the first pass). Its content is the very meta-narrative that produced the rest of this archive, so it is net-new as a *session transcript* rather than as extra hard facts; the facts it uses (V9 hash `61e4345b…`, gate `0x1400AF690`, bronze-cache answer) are all in Part 5 / V9 docs. Flagged as *do not re-archive* |
| 9 | `01a044b2-855a-71fb-8d40-d584a0ce8e2a.patch` | 28,583 B / `9e6d7545` | artifact | **BYTE-IDENTICAL DUPLICATE** of `11_git_patch/01a044b2-….patch` (`cmp` clean) — the archived copy is canonical |
| 10 | `MJ_V8_CLEAN_TRACE.txt` | 1,665 B / `49c4a602` | artifact | **BYTE-IDENTICAL DUPLICATE** of `05_patches_and_scripts/x64dbg/MJ_V8_CLEAN_TRACE.txt` |
| 11 | `RUN_MJ_V8_CLEAN_TRACE.bat` | 3,088 B / `5b2e79de` | artifact | **BYTE-IDENTICAL DUPLICATE** of `05_patches_and_scripts/x64dbg/RUN_MJ_V8_CLEAN_TRACE.bat` |

Duplicate detection: SHA-256/MD5 over all 11 files, then `cmp` for byte identity and
`diff` for prefix/nested relationships. Note that #4 and #7 are duplicates that
**SHA-256 cannot see** (different length, same content region) — hence rule 12's
requirement to check by content, not just by hash.

---

## 2. Net-new facts, and where each one went

| Fact | Source | Now lives in |
|---|---|---|
| V9 edit, hash, chain replay, gate disassembly | #1 | Part 5 §C1–§C5; `03_analysis/V9_COLD_LOAD_FEATS_FIX.md` |
| The final eligibility gate `0x1400AF690` semantics (`+0x64`, `+0x61/+0x63`, `0x14072D540`) | #1 | Part 5 §C2 |
| **Activation function VA `0x14080F370`, magic id `0x17A36D62`, `ebx=[[rsi+0x28]+0x18]`, no direct callers** | #1 | `RAWLOG_NETNEW_EXTRACTS.md` §11.1 + Part 5 §C3 |
| V8 clean trace: warm `al=1` / cold `al=0`, `CALC_FAIL_PATH` never fired, `RESTORE_GATE al=1`, base `0x7FF7B6EE0000`, 779.015 s | #2 | `V9_RUNTIME_RESULTS.md`; Part 5 §B1 step 14 |
| **V8 runtime disproof: "feats are 0 in game, and even in main menu (in MJ tab) too now"** | #7 | Part 5 §B1 steps 1–2; `CONTRADICTIONS.md` §14 |
| **"it picks up feats from game previously loaded. but when i do something that should give scores in them, it stays in place"** | #7 | Part 5 §B2 #8 — separates load-hydration from live evaluation |
| `.bat` flicker cause = cmd.exe terminates `if exist (…)` at the first `)` inside a nested PowerShell string (`APPLY_CK2_MJ_V8.bat` line 34) | #7 | `RAWLOG_NETNEW_EXTRACTS.md` §11.4; Part 5 §B1 step 6, §F error ledger |
| Cache state `user_id=1179784490`, `established=4`, `category=-1991027533` | #7 | `RAWLOG_NETNEW_EXTRACTS.md` §11.2; Part 5 §C4 |
| Cache state `user_id=84696387` at 16:19:51 with file SHA-256 `3606E210F48EB16B668B06E24942B545E65B11531F28F28D08FF9FDDE404601F` | #5 | §11.2; Part 5 §C4 |
| Ten-save `global_*` inventory | #5 | §11.3; Part 5 §C4 |
| `RestoreDeviceObjects` gate raw `0x007856E8` (still `74 0D` in V8) + the only two `UpdateFeatProgress` callers | #5 | Part 5 §C1; `RAWLOG_NETNEW_EXTRACTS.md` §11.5 |
| GameSparks `Roaming` folder `E349414h9BDm` never reappeared | #7 | §11.2 |
| Stale Continue breakpoints `+9E4970` / `+9E5500`; x64dbg `bytes do not match — expected 75 2F, got EB 2F` (live proof of the V7 patch) | #5 | §11.6 |
| PR #13 (`96ba84b`), PR #14 (`ab07419` / `910234875decd988ce55ed95e2401ce0f8c1b02a`), PR #15 (`f29287217b300be83a0c6334ccddc9a780bd5092`, squash) | #8, #6, #5 | §11.7; Part 5 §A3 |
| `DAILY_GATE` breakpoint is at raw `0x665546`, not the patched `0x666546` | #1, #2 (analysis) | `CONTRADICTIONS.md` §13; Part 5 §C5 |
| The inline `Invoke-MJV9` patcher text | #1 | **reconstructed** → `05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` |
| x64dbg DB path `…\release\x64\db\CK2game.exe.dd64`, load 1703 ms, `0x406D1388` benign | #5 | §11.6; Part 5 §F |
| `event_time_end=1893499200` = 2030-01-01 12:00:00 UTC; `2147310847` = 2038-01-17 03:14:07 | #1 | Part 5 §C5 (recomputed) |

---

## 3. Documents created in this pass

| File | Why |
|---|---|
| `00_START_HERE/PROMPT_organize_research_log_v7.md` | the consolidated single instruction document (user request) |
| `01_research_archives/CK2_MJ_RESEARCH_ARCHIVE_PART5.md` | the V8-disproof → clean-trace → V9-proven arc, complete |
| `03_analysis/V9_RUNTIME_RESULTS.md` | V9 is now the proven baseline; V8 is recorded as applied-but-disproven |
| `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md` | answers the Bronze-medal / missing-notification question |
| `04_test_guides_and_reports/CK2_MJ_V9_TEST_GUIDE.md` | first-time V9 apply/verify/revert steps |
| `05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` | the file the V9 session claimed to have saved but did not |
| `00_START_HERE/DISSECTION_REPORT_2026-08-30.md` | this report |

## 4. Documents updated in this pass

`00_START_HERE/STATUS.md` · `00_START_HERE/CASES_AND_FINDINGS.md` ·
`00_START_HERE/ORGANIZATION_HISTORY.md` · `03_analysis/MASTER_ARTIFACT_TABLE.md` ·
`03_analysis/CONTRADICTIONS.md` (§12–§14 added) ·
`03_analysis/RAWLOG_NETNEW_EXTRACTS.md` (§11 added) ·
`02_handoffs/NEXT_SESSION_HANDOFF_2026-08-30.md` (pointer banner) ·
`12_raw_chat_logs/INDEX.md` · `PLAN.md` · root `README.md`.

---

## 5. Corrections made to existing documents (rule 11)

1. `V9_COLD_LOAD_FEATS_FIX.md` claimed the `DAILY_GATE` breakpoint (raw `0x666546`)
   executed. The breakpoint offset `+666146` resolves to raw **`0x665546`**. An
   addendum has been appended there; see `CONTRADICTIONS.md` §13.
2. `MJ_V9_CLEAN_TRACE.txt` still arms `+666146` even though the V9 session claimed
   the fix. Left as-is on disk (it is the file whose hash is published in
   `README_MJ_V9_CLEAN_TRACE.md`), documented instead.
3. The V9 session's claim that the inline patcher was "also saved as
   `ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1`" was false. The file now exists,
   reconstructed verbatim from `last log (for now).txt`.
4. `STATUS.md` / `CASES_AND_FINDINGS.md` still declared V8 the "next test" and
   identity drift "refuted". Both updated.

## 6. Nothing lost

Every raw export in `last log/` remains on disk with a ledger entry (see
`12_raw_chat_logs/INDEX.md`), including `organisation log.txt` — the *one* file
the first pass overlooked, now ledgered here and added to the ledger. The three
byte-identical artifact copies were removed from `last log/` because identical
canonical copies exist at `11_git_patch/` and `05_patches_and_scripts/x64dbg/`
(verified by `cmp`, hashes above). No raw chat export was deleted.

> **2026-08-31 addendum — verification pass and deletion.** The nine exports were
> re-verified against the archive (hex-address sweep with VA/RVA normalization,
> full-SHA sweep, filename/PR sweep). Exactly one gap was found and fixed:
> **PR #16** (the V9 PR, `d2f61bb9…`, merged 2026-08-30 16:38 UTC) was absent from
> `RAWLOG_NETNEW_EXTRACTS.md` §11.7 and Part 5 §A3 — added to both. Planned-but-
> never-delivered filenames (`V8_CLEAN_TRACE_VERDICT_2026-08-30.md`,
> `MJ_V9_GATE_TRACE.*`) were confirmed to be session plans only; their content
> lives in `V9_RUNTIME_RESULTS.md` / the delivered `MJ_V9_CLEAN_TRACE.*` helpers.
> Per user request, the `last log/` folder was then deleted; all nine files stay
> recoverable in git history (tracked at `fdefa19`).

**Correction (2026-08-30):** the original inventory line said "11 files,
1,716,243 bytes, 21,437 lines" and listed only eight `.txt` exports. The actual
folder holds **nine** `.txt` exports (1,827,795 bytes, 23,146 lines); the ninth is
`organisation log.txt` (`79d6007f`, 1,757 lines), the transcript of the
orchestrating session `arena/01a053d9` that created this very archive and merged
PR #17. Its findings are not re-archived (they are the archive); it is ledgered
here for provenance so a future session does not re-dissect it.

**Second-pass correction (2026-08-30).** "Nothing lost" was over-claimed. A
re-read of `last log (for now).txt` aimed specifically at *dead ends, redundant
artifacts and abandoned approaches* recovered six items the first pass had not
archived. The two that matter most:

- V8's `0x007B786B` byte is **mandatory** in the shipped V9 — it sits upstream of
  the V9 edit in the same function, so reverting it makes the V9 fix
  unreachable. The first pass recorded only that V9 "keeps V8's bypasses … for
  the record", which reads as optional. It is not.
- An **abandoned alternative V9 design at raw `0x007B785B`** (`74 07`→`90 90`)
  was considered and rejected. Its address appears **~40 times** in the source
  log yet had **zero** archive hits. Under that design V8's `0x007B786B` byte
  *would* be dead code — so "is that byte redundant?" has opposite answers
  depending on which design is in use.

Full list, plus the methodology correction (scratch `disasm*.py` files must not
be counted as corpus): `03_analysis/RAWLOG_NETNEW_EXTRACTS.md` §11.9 and
`03_analysis/V9_DESIGN_ALTERNATIVES_AND_V8_DEPENDENCY.md`.
