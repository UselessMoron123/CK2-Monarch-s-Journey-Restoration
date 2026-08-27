# Ingest report — dump folders 2026-08-27

Follows `INGEST_PLAN_DUMP_2026-08-27.md`. Operative prompt is now **v6**.

## Material received
Three overlapping dump roots (no folder named `new`): `latest logs/`,
`latest latest logs/`, `new new logs/` (3-file subset). User also pasted
canonical `APPLY_CK2_MJ_V7.bat` + `patch_ck2_mj_v7.ps1` (ps1 already matched
archive byte-for-byte).

## Classified → verdict

| Item | Verdict | Now lives |
|---|---|---|
| `APPLY_CK2_MJ_V7.txt` | **accepted** (tooling hole) | `05_patches_and_scripts/bat/APPLY_CK2_MJ_V7.bat` |
| CHECK/REVERT V7 bats | **created** (match V6 trio; ps1 already had Verify/Revert) | `CHECK_CK2_MJ_V7.bat`, `REVERT_CK2_MJ_V7_TO_V6.bat` |
| `patch_ck2_mj_v7.ps1` (user paste / dump `.txt`) | **duplicate** of archive | unchanged `ps1/patch_ck2_mj_v7.ps1` |
| V5/V6 APPLY + v5/v6/v7.ps1 dump copies | **duplicate** | discarded |
| Unique Pavao-resume game logs | **accepted** | `07_runtime_logs/*_pavao_resume*` |
| dump `error.log` / `graphics.log` / `historical_setup_errors.log` | **duplicate** | discarded |
| `preflight check.txt` | **accepted** | `07_runtime_logs/preflight_two_runs_llywelyn.txt` |
| Llywelyn `.ck2` binaries | **not in dump** | MASTER §4 metadata only |
| attach x64dbg log | **accepted** | `07_runtime_logs/x64dbg/x64dbg_attach_bps_then_launch_death.txt` |
| one launch-death x64dbg log | **accepted** (representative) | `…/x64dbg_launch_death_406D1388.txt` |
| other launch-death x64dbg logs | **duplicate story** | discarded |
| git patches PR #10 / #11 | **accepted** provenance | `11_git_patch/` |
| dump preflight/watch v2 / RUN_PREFLIGHT | encoding/CRLF only | discarded; archive preflight **patched** for V7 hash |
| 1.88 MB observer + watch tail | noise (0 FILE CHANGED) | discarded after analysis already held conclusions |
| `watcher log.txt` | method note only | README_PREFLIGHT; discarded |
| `text of error messages.txt` | distilled | CASES F5; discarded with dump |
| `latest latest log1/log2.txt`, `what we wanted to do.txt` | dissected | EXTRACTS §10 + INDEX; discarded |
| `new new logs/` | dump-internal dups | discarded wholesale |

## Living docs touched
STATUS (body matches banner), CASES (C08 in-game SOLVED; **C25** launcher;
F5; work order), PLAN Phase 2 ✅ / Phase 3 current, README glance, MASTER
(V7 hash + Llywelyn metadata + V7 tool hashes), BANNED wording, patch map +
csv V7 row, CONTINUE_SEMANTIC §F, EXECUTABLE_IDENTITIES, preflight KnownExe
(`$GoodExe` = V7, `$AcceptableExe` = V6 or V7), README_PREFLIGHT, live-debug
guide 0.4, FEATURED_RULERS gate, ULTIMATE handoff banner/§3/§12/§18/§20,
INDEX, ORGANIZATION_HISTORY Turn 8, prompt **v6**, V7 test guide.

## Integrity
- `APPLY_CK2_MJ_V7.bat` now exists where STATUS always claimed it.
- Offset math: `0x1409E678B − 0x140000C00 = 0x009E5B8B` — matches patcher.
- No patched `CK2game.exe` committed.
- 15-folder layout unchanged.

## Mismatches flagged
None on V7 SHA/offset. Llywelyn saves and a Continue-success screenshot are
still user-side / catalog A empty.

## Dump folders
Deleted after unique bits were placed (`git rm -r` the three dump roots).
