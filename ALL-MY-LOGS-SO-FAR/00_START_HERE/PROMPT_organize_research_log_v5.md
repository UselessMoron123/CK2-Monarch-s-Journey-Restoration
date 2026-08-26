# Prompt for another AI — maintaining the CK2 Monarch's Journey research archive (v5: archive complete → ingestion/maintenance mode)

**How to use:** paste everything below the line into the other AI, together with (or a short description of) the new material. If a genuinely **new raw chat export** arrives (a whole session log never seen before), also hand over `PROMPT_organize_research_log_v4.md` — v5 covers the everyday case (discrete new artifacts), v4 covers full raw-log dissection. This is the **operative** prompt; v1–v4 are kept as history.

> **What changed vs v4, and why (delete this block when pasting):**
> v4 was written for the last "ingest a raw log part" phase. That phase is **finished**: the 186-file flat dump became the 15-subfolder tree, every raw chat export was dissected and deleted (`12_raw_chat_logs/` is now a tear-down ledger only), all patch tooling was verified intact, and the four executables + debug drop were materialized under `10_binary_artifacts/` and the Base64 intermediates removed. **The big sort is done — do not re-sort.** Work from now on is *ingestion and maintenance*: adding new, discrete material to a finished archive without breaking its cross-references. v5 therefore:
> 1. **Declares the sort complete** and lists what is already done, so no session re-does it or re-invents the folder layout.
> 2. **Adds the artifact-class → folder map** (all 15 subfolders) so new files land in their permanent home on the first try.
> 3. **Makes SHA-256 dedup mandatory** against `03_analysis/MASTER_ARTIFACT_TABLE.md` and the whole tree — no `(1)` copies, no re-adding of deleted duplicates, no loose mirrors.
> 4. **Codifies the screenshot policy** that emerged in the later passes: `00_START_HERE/SCREENSHOTS_CATALOG.md` is the canonical image record; image binaries are drop-in to `14_screenshots_and_media/` (subfolders A–H) and may be deleted after cataloging. Never keep un-cataloged screenshots.
> 5. **Adds the "living documents" rule**: after any ingestion, update `00_START_HERE/STATUS.md` (read-first), `00_START_HERE/CASES_AND_FINDINGS.md`, `03_analysis/MASTER_ARTIFACT_TABLE.md`, `PLAN.md`, the README read-order, and `12_raw_chat_logs/INDEX.md` (ledger). The archive is only as good as its pointers.
> 6. **Declares "the repo is the handoff"**: no new standalone handoff files per session. Canonical state = `00_START_HERE/STATUS.md`; deep background = `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`; V7 Continue analysis = `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md`. New facts update these files; they do not spawn new copies (the 2026-08-26 consolidation merged four handoffs into one, and the two V7 analysis notes into the semantic reference).
> 7. Keeps everything v4 got right: SHA-keyed builds + naming-collision table, banned vs abandoned distinction, runnable-tooling integrity check, living INDEX, info-preservation audit, contradictions protocol, and the dissect-or-verify-first rule for anything that *looks* already covered.

---

You are maintaining the **CK2 Monarch's Journey research archive** — a fully organized repository of a reverse-engineering project. The project: **restoring the retired "Monarch's Journey" mode of Crusader Kings II to run fully offline on Windows** (payload re-activation, version archaeology, binary analysis, hash-guarded executable patches named v1…v6; **V7 = the greyed-out Continue button**, the only remaining functional gap). All material lives in `ALL-MY-LOGS-SO-FAR/` (15 numbered subfolders + `README.md` + `PLAN.md`); the root also has `README.md`, `RECONSTRUCTED_ARTIFACTS.md`, and `RECON_NOTES_2026-08-26.md` (the audit trail of every organization pass).

The archive is **complete and self-contained**. Your job when handed new material is **not** to re-organize it, but to **ingest it without loss or duplication**:

**Step 0 — Orient (read these before touching anything):**
- `00_START_HERE/STATUS.md` — current authoritative state (V6 runtime-proven; V7 open).
- `00_START_HERE/PROMPT_organize_research_log_v4.md` — full raw-log dissection rules (A–F skeleton, 12 rules); only needed if a raw export is involved.
- `03_analysis/MASTER_ARTIFACT_TABLE.md` — canonical SHA-256 registry; check it first for any artifact you are about to accept.
- `03_analysis/BANNED_ARTIFACTS.md` — never re-introduce banned builds/helpers/approaches.
- `00_START_HERE/SCREENSHOTS_CATALOG.md` — canonical image record (screenshots referenced by case, not by file).

**Step 1 — Classify the new material and find its home:**

| Artifact class | Goes to | Notes |
|---|---|---|
| New patch/tool (.bat/.ps1/.py) | `05_patches_and_scripts/{bat,ps1,py}` | Guarded patchers only; never loose in root; hash into `MASTER_ARTIFACT_TABLE.md` |
| New game data (payload, CSV, strings, GUI/GFX) | `06_game_data/` | Payload variants keyed by SHA; never `gfx/test.dds`, never global string edits |
| New runtime log from a test boot | `07_runtime_logs/` | Name by boot + purpose (e.g. `error_v6sl.log`); same-size ≠ same content — verify by hash, keep variants |
| New save (.ck2/.meta) or feat cache | `13_save_and_cache/saves/` (or cache root) | Record archive SHA, uncompressed size, internal date, `special_event`, globals |
| New screenshot/media | `14_screenshots_and_media/` (A–H) | Update `SCREENSHOTS_CATALOG.md` (case + intent) — the catalog is canonical, binaries optional |
| New chat/session export (raw) | → **dissect, then delete** | Follow v4 rules: cross-reference sweep → net-new facts into `01_research_archives/` or `03_analysis/RAWLOG_NETNEW_EXTRACTS.md` → update `12_raw_chat_logs/INDEX.md` ledger → `git rm` the raw file |
| New executable / PDB / RAR | `10_binary_artifacts/` | **Never commit decoded binaries to a public repo** — hashes/manifests/guarded patchers only; redact builder paths to `<buildroot>` |
| New analysis conclusion (not a new artifact) | `03_analysis/` (or fold into the existing consolidated doc it belongs to) | Do not create parallel docs for facts that fit existing ones (e.g. Continue facts → `CONTINUE_SEMANTIC_REFERENCE.md`) |

**Step 2 — Dedup by content, not by name:**
1. Compute SHA-256 of the incoming file.
2. Check `MASTER_ARTIFACT_TABLE.md`, then `find . -type f | xargs sha256sum` (or `cmp` for pairs).
3. Byte-identical → **discard** (note it in the ledger; do not keep a `(1)` copy). Unique content → **place**, then record the hash + role in `MASTER_ARTIFACT_TABLE.md` (or the doc that owns the fact class).
4. If the material is already *represented* in the archive (conclusions distilled) but the raw file is new to the repo, prefer folding the net-new facts into the right doc with a "source: …" pointer, then delete the raw file (git history retains it).

**Step 3 — Keep the living documents in sync.** After any ingestion, update (only what changed):
- `00_START_HERE/STATUS.md` — state dashboard, next actions, "Authoritative files" pointers.
- `00_START_HERE/CASES_AND_FINDINGS.md` — solved/unsolved/partial map.
- `03_analysis/MASTER_ARTIFACT_TABLE.md` — every accepted artifact's size/SHA/path/role.
- `PLAN.md` — tick/untick phases; keep "current" pointer right.
- `ALL-MY-LOGS-SO-FAR/README.md` — read-order/folder descriptions only if the tree changes.
- `12_raw_chat_logs/INDEX.md` — ledger entry for any raw material processed.
- `03_analysis/CONTINUE_SEMANTIC_REFERENCE.md` — any new V7/Continue fact (it is the single V7 knowledge base).

**Step 4 — Integrity + preservation audit (always finish with these):**
1. **Runnable tooling integrity:** confirm every `.bat`/`.ps1`/`.py` referenced by anything you touched exists intact under `05_patches_and_scripts/{bat,ps1,py}` and that no loose `.txt`-mirror copies exist. These are the only things that touch the exe — they must never be lost to a dedup pass.
2. **Info-preservation audit:** is the new info preserved *by content* in the archive (not only in a raw file or git history)? Are actions reflected in the organized tree?
3. **Contradictions protocol:** if the new material conflicts with the archive, list both claims with evidence pointers, state which is primary, never silently pick a side (append to `03_analysis/CONTRADICTIONS.md` if it is a real contradiction).
4. Report exactly what you accepted, what you discarded as duplicate, what you merged where, and any hash/claim that did not verify (flag mismatches explicitly — recompute dates from unix times, size deltas, offset arithmetic, expiry math, base64 size math whenever the material contains numbers).

**Rules (from v4, still binding):**
1. Preserve verbatim: SHA-256 hashes, sizes, offsets/byte patterns, timestamps, version/build strings, function addresses, exact paths, console commands, parser keys, save-token IDs, error-log lines, and the user's runtime reports — primary evidence.
2. Never invent facts; an unresolved end is a finding, not a failure.
3. Noise to remove: upload receipts, greetings, repeated file lists, session housekeeping — but keep the *facts* those contained. Tool-output fragments (objdump/grep/nm/patcher transcripts) are evidence, not noise — distill conclusions and cross-reference the raw byte-level facts.
4. Key every build by SHA-256, never by label alone (V6/V7 each name two different builds across the wrap-around sessions — see the naming-collision table in `MASTER_ARTIFACT_TABLE.md` / Part 3 A0).
5. Distinguish **banned** (tested, corrupting — never reuse, delete files) from **abandoned** (built, premise disproven — keep hash + disproof for the record).
6. Binary policy: never commit decoded executables, RARs, PDBs, or patched binaries — only hashes, manifests, guarded patchers. Redact builder paths to `<buildroot>`.
7. **The repo is the handoff.** Do not write a new "next session" handoff document; update `STATUS.md` (state) and, if needed, the single deep-background handoff `02_handoffs/CK2_MJ_ULTIMATE_HANDOFF.md`. If a whole new sub-project arrives (e.g. reward gallery), give it its own section in the existing docs — not a parallel archive.
8. When in doubt about deleting anything: it is recoverable from git history (this repo's pattern since the raw-log tear-down); prefer content preservation over raw retention.

Output: a short report listing — material received → classified → dedup verdict (accepted / duplicate / net-new facts extracted) → where each piece now lives → living-docs updated → integrity check result → any flagged mismatches. If you dissected a raw export, title the report per the Part convention (`RESEARCH ARCHIVE — CK2 Monarch's Journey — Part <n>`) and follow v4's A–F skeleton.
