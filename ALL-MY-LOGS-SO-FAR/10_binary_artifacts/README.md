# Binary artifacts

This folder contains the materialized executables and the complete 2.6.1.1
debug-symbol drop. The large Base64 upload parts were verified against their
manifests and removed after reconstruction; the small manifests remain as
identity records.

## Layout

```text
10_binary_artifacts/
├── executables/
│   ├── windows/
│   │   ├── CK2game332.exe       # Windows 3.3.2
│   │   ├── CK2game333.exe       # Windows 3.3.3, May 2020; patch target
│   │   └── CK2game3351.exe      # Windows 3.3.5.1
│   └── linux/
│       └── ck2                 # Linux 3.3.3, May 2020
├── debug_files/
│   ├── CK2game.exe             # matching 2.6.1.1 Windows executable
│   ├── dbghelp.dll             # supplied debug helper
│   ├── pdb/
│   │   ├── ck2.pdb             # June 2016 historical reference
│   │   └── ck2game.pdb         # exact symbols for CK2game.exe
│   └── rar_volumes/             # original three-volume source archives
├── upload_manifests/            # retained after Base64 parts were removed
└── test_versioned.dds           # existing loader-redirect binary artifact
```

## Identity records

See `upload_manifests/` for the four original upload size/hash records and
`../03_analysis/MASTER_ARTIFACT_TABLE.md` plus `../03_analysis/IDENTITY.md`
for the complete artifact table and debug-symbol identity analysis. The
source-to-output history is also recorded in the repository-root
`RECONSTRUCTED_ARTIFACTS.md`.

The stock executables and debug files are retained for this personal
reverse-engineering archive. No patched executable is stored here.
