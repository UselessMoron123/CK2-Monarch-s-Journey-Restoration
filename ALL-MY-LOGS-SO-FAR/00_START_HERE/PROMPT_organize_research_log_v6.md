# Prompt for another AI — maintaining the CK2 Monarch's Journey research archive (v6: V7 Continue proven → ingest/maintenance)

**How to use:** paste everything below the line into the other AI, together with (or a short description of) the new material. If a genuinely **new raw chat export** arrives, also hand over `PROMPT_organize_research_log_v4.md`. This is the **operative** prompt; v1–v5 are history.

> **What changed vs v5 (delete this block when pasting):**
> v5 declared the 15-folder sort complete (still true) but described project state as
> “V6 proven, V7 = grey Continue, only remaining functional gap.” That is **wrong**.
> In-game Continue execution is proven as Continue-V7 SHA `57b18e43…`. v6 therefore:
> 1. Updates the state dashboard (V7 current; C25 launcher Continue optional).
> 2. Makes Continue **surfaces** first-class (launcher / in-game menu / MJ / SP).
> 3. Extends the naming-collision table with proven Continue-V7 vs abandoned feat-V7.
> 4. Tooling integrity: every file STATUS names must exist (APPLY_V7.bat was the miss).
> 5. `$KnownExe` / preflight is a **living register** — add every new proven hash.
> 6. x64dbg/observer logs: distill BPs/registers/`Application debug[…]`; discard inventories, TLS callbacks, ntdll stacks, repeated `406D1388` deaths.
> 7. Unguarded poke-scripts are not deliverables.
> 8. Living-docs **drift** after a “solved” banner is part of ingest, not optional.
> 9. Git patches of already-merged PRs → `11_git_patch/` provenance; never re-apply.
> 10. Saves mentioned only in preflight → MASTER metadata + “not uploaded”.

---

You are maintaining the **CK2 Monarch's Journey research archive**. The project:
**restoring retired Monarch's Journey / Featured Rulers / Bronzeman for personal
offline Windows use** via payload re-activation and hash-guarded patches
(v1→**v7**). **Current in-game baseline is V7 Continue**
`57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571`
(`0x009E5B8B` `75 2f→eb 2f`). V6 `f5b7dfd6…` is the exact revert target.
Remaining functional: Paradox **launcher** Continue (C25, separate program),
Phase 3 polish, FR/rewards as follow-ons. All material lives in
`ALL-MY-LOGS-SO-FAR/` (15 numbered subfolders + `README.md` + `PLAN.md`).

**Do not re-sort the tree.** Ingest new material without loss or duplication.

**Step 0 — Orient:**
- `00_START_HERE/STATUS.md` — current authoritative state (V7 in-game Continue proven).
- `00_START_HERE/PROMPT_organize_research_log_v4.md` — raw-log dissection (A–F); only if a raw export is involved.
- `03_analysis/MASTER_ARTIFACT_TABLE.md` — SHA-256 registry; check first.
- `03_analysis/BANNED_ARTIFACTS.md` — never resurrect trampoline V6 `a6cb92b8…` or feat-V7 `0074af70…`.
- `00_START_HERE/SCREENSHOTS_CATALOG.md` — canonical image record.

**Naming collision (key by SHA, never label):**

| Label | SHA-256 | Meaning | Status |
|---|---|---|---|
| “V6” trampoline | `a6cb92b8…` | injected code | ❌ BANNED |
| V6 | `f5b7dfd6…` | 5 save-list branches | ✅ V7 revert target |
| “V7” feat-update | `0074af70…` | two `74 0d→90 90` | 🟡 ABANDONED |
| **V7 Continue** | `57b18e43…` | `0x009E5B8B` `75 2f→eb 2f` | ✅ current in-game Continue |

**Continue surfaces (never conflate):** Paradox launcher (C25, `pdx_launcher.lib` /
`launcher-v2.sqlite`) vs in-game main menu vs MJ panel vs Single Player. V7
fixed engine **execution**, not the launcher.

**Step 1 — Classify and place** (15-folder map unchanged):

| Artifact class | Goes to | Notes |
|---|---|---|
| New patch/tool (.bat/.ps1/.py) | `05_patches_and_scripts/{bat,ps1,py}` | Guarded only; hash into MASTER; STATUS-named files must exist |
| New game data | `06_game_data/` | Key payload variants by SHA |
| New runtime log | `07_runtime_logs/` | Name by boot + purpose; hash-dedup |
| Debugger traces | `07_runtime_logs/x64dbg/` | Distill; do not keep four identical launch-deaths |
| New save / feat cache | `13_save_and_cache/` | SHA, date, `special_event`; if binary missing, MASTER metadata only |
| New screenshot | `14_screenshots_and_media/` | Catalog is canonical |
| New raw chat export | dissect then delete | v4 rules → EXTRACTS / Part N → INDEX ledger → `git rm` |
| New git patch of merged work | `11_git_patch/` | Provenance only; never re-apply |
| New exe / PDB | `10_binary_artifacts/` | Never commit patched CK2 executables |
| New analysis conclusion | fold into existing `03_analysis/` doc | Continue facts → `CONTINUE_SEMANTIC_REFERENCE.md` §F |

**Step 2 — Dedup by SHA-256**, never by name. Byte-identical → discard.

**Step 3 — Living documents.** After any ingest, if STATUS banner disagrees with
PLAN / README glance / CASES F5 / MASTER / preflight `$KnownExe`, **repair is
mandatory**. Always consider: STATUS, CASES, MASTER, PLAN, README, INDEX,
CONTINUE_SEMANTIC, BANNED wording, patch map, preflight KnownExe.

**Step 4 — Integrity + preservation:**
1. Runnable tooling: every `.bat`/`.ps1`/`.py` STATUS mentions exists under
   `05_patches_and_scripts/{bat,ps1,py}`. No `.txt` mirrors of patchers.
2. Unguarded one-liners that poke an offset without SHA guard are **not**
   deliverables. Keep the offset/byte in the patch map; throw the one-liner away.
3. Info-preservation: new facts live in the archive, not only in a dump folder.
4. Contradictions → `CONTRADICTIONS.md`; never silently pick a side.
5. Report: accepted / duplicate / distilled / living-docs touched / mismatches.

**Rules still binding from v4/v5:** preserve verbatim hashes/offsets; never invent;
noise vs evidence; banned vs abandoned; no public patched exes; the repo is the
handoff (no new per-session handoff files); when in doubt, git history retains
deleted raw files.

Output: short ingest report. If you dissected a raw export, title it Part N and
follow v4's A–F skeleton.
