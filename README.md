# CK2-Monarch-s-Journey-Restoration

Reverse-engineering the retired **Monarch's Journey / Featured Rulers / Bronzeman**
mode of Crusader Kings II back to life for personal offline use on Windows.

## Start here
All organized material lives in **`ALL-MY-LOGS-SO-FAR/`** — read its `README.md`
first, then `00_START_HERE/STATUS.md` for current state.

- Organized archive: `ALL-MY-LOGS-SO-FAR/` (15 numbered subfolders + README + PLAN)
- Audit/history of every organization pass: `RECON_NOTES_2026-08-26.md`

## Materialized binaries
All binary material is now sorted under
[`ALL-MY-LOGS-SO-FAR/10_binary_artifacts/`](ALL-MY-LOGS-SO-FAR/10_binary_artifacts/):

- `executables/windows/` — `CK2game332.exe`, `CK2game333.exe`, and
  `CK2game3351.exe`
- `executables/linux/` — `ck2`
- `debug_files/` — the supplied 2.6.1.1 `CK2game.exe`, `dbghelp.dll`, extracted
  PDBs, and their original RAR volumes
- `upload_manifests/` — the four small identity manifests retained after the
  large Base64 parts were verified and removed

See [`RECONSTRUCTED_ARTIFACTS.md`](RECONSTRUCTED_ARTIFACTS.md) for the
source-to-output mapping, sizes, and verification hashes. Research notes and
patch scripts remain under `ALL-MY-LOGS-SO-FAR/`.
