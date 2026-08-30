# `11_git_patch/` — what these `.patch` files are, and why they don't apply

**Do not try to `git apply` these.** They are turn-end diff captures, kept as
provenance, not as installable patches.

## Why they fail

Every file in this folder was verified on 2026-08-30 with `git apply --check`
from the repository root. All four fail, for two reasons:

| File | Size | `git apply --check` result |
|---|---:|---|
| `01a02609-65fe-77a0-a60c-da626bfcba68.patch` | 38,798 | `things parent AI asked to upload/CK2_MJ_ULTIMATE_HANDOFF.md: No such file or directory` — targets a staging folder that was ingested and removed |
| `01a03e8a-ac93-76b7-a133-6a98f2d15a3a.patch` | 105,548 | `already exists in working directory` + `patch does not apply` |
| `01a03f95-541f-7c0f-8ab5-c6879d3a5e06.patch` | 43,205 | `patch does not apply` (`CASES_AND_FINDINGS.md`, `STATUS.md`) |
| `01a044b2-855a-71fb-8d40-d584a0ce8e2a.patch` | 28,583 | `already exists in working directory` + `patch does not apply` |

## Why they are redundant

Each one is the diff Arena captured at the end of a session. The user then
uploaded the resulting state as a fresh commit, so **every change in these
diffs is already present in the committed tree.** They describe history that has
already happened; there is nothing left for them to apply.

This was established at the time in `last log/another other raw log.txt`
(lines 228, 242, 292, 394, 429), e.g.:

> "the patch file is a redundant capture: its changes are already in the tree
> (I confirmed STATUS.md is already at the 'after' blob … and `git apply --check`
> reports every file 'already exists / patch does not apply')."

## Why they are kept anyway

- **Provenance.** They record exactly what a given session changed, in the
  session's own ordering, which the squashed `Add files via upload` commits do
  not preserve.
- **Recovery.** If a document is ever lost or truncated, the diff is a second
  copy of its text at a known point in time. Several were used as a
  reconstruction source during the 2026-08-27 ingest.
- **Cheap.** ~216 KB total.

## What to use instead

- Current truth: read the documents themselves, starting at
  `../00_START_HERE/STATUS.md`.
- Canonical history: `git log` on the repository (note the local clone may be
  shallow — `git fetch --unshallow` first if you need the full chain).
- Patch bytes for the executable: `../05_patches_and_scripts/ps1/`, keyed by
  SHA-256, and replayable end-to-end via
  `../05_patches_and_scripts/py/build_v9_chain.py`.
