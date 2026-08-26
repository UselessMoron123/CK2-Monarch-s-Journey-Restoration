# CK2-Monarch-s-Journey-Restoration

Reverse-engineering the retired **Monarch's Journey / Featured Rulers / Bronzeman**
mode of Crusader Kings II back to life for personal offline use on Windows.

## Start here
All organized material lives in **`ALL-MY-LOGS-SO-FAR/`** — read its `README.md`
first, then `00_START_HERE/STATUS.md` for current state.

- Organized archive: `ALL-MY-LOGS-SO-FAR/` (15 numbered subfolders + README + PLAN)
- Audit/history of every organization pass: `RECON_NOTES_2026-08-26.md`

## Materialized binaries
- `CK2game332.exe`, `CK2game333.exe`, `CK2game3351.exe` — Windows 3.3.2,
  May-2020 3.3.3, and 3.3.5.1 executables reconstructed from the upload parts
- `ck2` — Linux May-2020 3.3.3 executable reconstructed from its upload parts
- `debug files/CK2game.exe` — supplied 2.6.1.1 executable
- `debug files/ck2.pdb` and `debug files/ck2game.pdb` — PDBs extracted from the
  corresponding RAR volume sets; `dbghelp.dll` is retained beside them

The original Base64 parts, manifests, and RAR volumes are retained as
provenance. See [`RECONSTRUCTED_ARTIFACTS.md`](RECONSTRUCTED_ARTIFACTS.md) for
source-to-output mapping, sizes, and verification hashes. Research notes and
patch scripts remain under `ALL-MY-LOGS-SO-FAR/`.
