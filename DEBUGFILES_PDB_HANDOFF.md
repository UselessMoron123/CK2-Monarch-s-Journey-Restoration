# CK2 2.6.1.1 debug-files investigation — standalone handoff

## Mission

Investigate the supplied **Crusader Kings II 2.6.1.1 debug-symbol files** as a
self-contained archival/reverse-engineering task. The goal is to extract every
useful durable name, type, source-path, and subsystem relationship that can
improve later CK2 analysis.

This task is intentionally **not** a request to patch an executable, restore
Monarch’s Journey, bypass an online service, or redistribute game binaries.
Do not create or share a patched EXE. Produce only a compact, reproducible
symbol inventory and research notes.

## Why these files matter — and their limits

These PDBs come from CK2 **2.6.1.1**, an older build. They cannot directly
symbolize a 2020-era 3.3.3 executable unless an exact PDB/executable identity
match is established (which is not expected). They also predate Monarch’s
Journey, so do not expect direct symbols for `CNullGameSpark`, GameSparks,
`CHighlightedRuler*`, Monarch’s Journey panels, or modern Feat/Reward systems.

They may still be highly useful because core CK2 code likely retained older
structures and concepts: save discovery/selection, frontend/menu states,
Ironman rules, cloud/local save abstractions, GUI widgets, game-state loading,
and serialization. Historical names can be used as hypotheses when mapping
later stripped binaries, but never treated as proof of an exact 2020 address
or layout.

## Required input

The minimum useful upload is the full `debugfiles` folder, preserving original
filenames and subdirectories. Do not rename files or flatten the directory.

### Strongly preferred companion artifacts

1. **The exact 2.6.1.1 CK2 executable(s)** that the PDBs were built for,
   named as originally distributed. A PDB can be matched to an EXE through the
   CodeView record (PDB GUID, age, and filename). Without its exact EXE, we can
   still inventory public symbols and types, but cannot reliably map code
   addresses or validate the PDB/build relationship.
2. Any matching `.map`, `.dbg`, `.sym`, `.dll`, or `.exe` files from that same
   2.6.1.1 debug package.
3. A tiny `provenance.txt` if known: game version, platform, distribution,
   approximate date, and whether the folder is an unmodified original archive.

### Do not upload for this task

- current/patched game executables;
- Steam logs, user data, cloud data, account files, credentials, or tokens;
- generic screenshots;
- duplicate copies of the same PDB;
- unrelated Visual Studio or Windows PDBs.

If the full folder is too large, first upload the PDB for the principal game
EXE (`CK2game.exe`, `ck2.exe`, or similarly named) plus the exact matching EXE
and any `.map` file. List the omitted filenames and sizes.

## First: preserve and identify the files

1. Work read-only on originals. Copy them to analysis scratch space before
   converting/extracting anything.
2. Record for every file:
   - relative path;
   - size;
   - SHA-256;
   - detected format (PDB/MSF, EXE/PE, MAP, DBG, etc.).
3. If an EXE is supplied, inspect its PE debug directory and record:
   - CodeView format;
   - PDB filename embedded in the EXE;
   - PDB GUID/signature and age;
   - architecture and PE timestamp.
4. Parse the PDB stream metadata and determine whether its GUID/age matches the
   EXE. State the result clearly as **exact match**, **mismatch**, or
   **unverifiable (no matching EXE supplied)**.

Use standard offline tooling where available, for example LLVM
`llvm-pdbutil`, Ghidra’s PDB importer, DIA tooling on Windows, `pdbparse`, or
an MSF/PDB parser. Do not modify the original PDBs.

## Deliverables

Write the following small text/CSV/JSON artifacts; do not commit extracted
binaries or huge raw symbol dumps unless explicitly asked.

### 1. `analysis/debug2611/IDENTITY.md`

- file inventory with SHA-256;
- PDB version/format and architecture;
- PDB-to-EXE identity verdict;
- limitations and confidence level.

### 2. `analysis/debug2611/SYMBOL_SUMMARY.md`

A readable overview containing:

- total public/global/function/type symbol counts, if available;
- source-file path inventory grouped by subsystem;
- demangled class/namespace inventory;
- whether line tables, local variables, class fields, and vtable/type records
  are present;
- notable game subsystem names;
- a concise assessment of whether the material is rich enough to guide
  cross-version analysis.

### 3. `analysis/debug2611/SEARCH_RESULTS.md`

Search case-insensitively across symbol names, type names, source paths, and
strings exposed by the PDB. Include exact hits plus reasonable near hits for
these groups:

```text
# Save/load and Continue
continue
savegame
save_game
save games
loadgame
load_game
save select
save_select
CSave
CIronman
ironman
alternate_start
cloud
CloudStorage

# Frontend and GUI
frontend
mainmenu
main_menu
singleplayer
single_player
button
enable
disabled
window
gui

# Game state / serialization
GameState
gamestate
serializer
serialize
deserialize
metadata
meta

# Possible later-feature precursors
bronze
bronzeman
feat
ruler
highlight
challenge
reward
progress
Titus
GameSparks
```

For each meaningful hit, record the full demangled name, symbol kind, source
file/module if present, and address/RVA **only when tied to a verified matching
2.6.1.1 EXE**. Do not imply that an old RVA applies to another build.

### 4. `analysis/debug2611/TYPE_AND_VTABLE_NOTES.md`

Where type information is present, document only the most useful stable
objects:

- save selection / save metadata classes;
- save serialization interfaces;
- Ironman-related structures;
- frontend/menu/controller classes;
- generic GUI button/enable-state abstractions;
- local/cloud storage abstractions;
- game-state load lifecycle objects.

For each, include: exact type name, source file, known methods, inheritance,
interesting fields, and vtable ordering if recoverable. Clearly label layouts
as **2.6.1.1 only**, not cross-version facts.

### 5. `analysis/debug2611/SYMBOLS_FILTERED.csv`

A machine-readable, deliberately filtered symbol index, with columns:

```text
category,demangled_name,mangled_name,kind,module_or_source,address_or_rva,notes
```

Keep it focused on the search groups above. Avoid a multi-gigabyte full dump.

## Investigation directions

### Direction A — Save selection and the meaning of “Continue”

This is the most promising direction. Look for types/functions resembling:

- `CIronmanSaveSelect`;
- `C*SaveSelect*`, `C*SaveGame*`, `C*SaveMetadata*`;
- `GetContinueSave`, `CanContinue`, `FindLatestSave`, `LoadSave`; or
- methods that scan the `save games` directory.

Document the old decision flow: how candidates are enumerated, which metadata
makes a save invalid, how newest saves are selected, and which value ultimately
drives frontend button enablement. Even if class names changed later, this can
provide a semantic checklist for analysing a newer stripped build.

### Direction B — Frontend enable/disable propagation

Search for main-menu / single-player controller code and GUI button APIs.
Determine whether buttons are enabled by a generic predicate, a saved boolean,
or a state-machine callback. Capture source filenames and method names around
`Enable`, `Disable`, `SetEnabled`, `IsEnabled`, `Update`, and `Refresh`.

This may illuminate why a Continue button can remain visually disabled even
when a manual Load path works.

### Direction C — Save metadata and compatibility checks

Find structures/functions that read save `meta`, version fields, checksum,
DLC, cloud flags, Ironman flags, or alternate-start information. Distinguish
ordinary validity rules (corrupt archive, incompatible version) from account,
cloud, or game-mode checks. This helps avoid overly broad later patches.

### Direction D — Stable source-file taxonomy

The oldest symbols can map CK2’s code organization: `frontend.cpp`,
`savegame*.cpp`, `gamestate.cpp`, `ironman*.cpp`, etc. Build a source-path
catalogue. That taxonomy is useful when later binaries contain leftover debug
strings naming the same source file, even if their function addresses differ.

### Direction E — Feature chronology, not false positives

Search for `ruler`, `challenge`, `feat`, `bronze`, `reward`, and similar terms,
but treat them as chronology evidence. If absent, record the absence; it
supports the conclusion that the relevant feature had not yet been introduced.
If present, verify whether they refer to unrelated systems before claiming a
connection to Monarch’s Journey.

## Important technical rules

- A PDB is exact-build metadata. Never apply a 2.6.1.1 symbol address/RVA,
  field offset, branch location, or vtable index directly to a 3.3.x binary.
- Do not force a PDB into a non-matching executable in Ghidra/IDA and then
  report its labels as verified. Use it only as an historical naming reference
  unless GUID/age match.
- Demangle C++ names and retain the original mangled names in the CSV.
- Quote source-paths exactly but avoid publishing personal directory segments
  if any appear; replace the user-specific leading portion with `<buildroot>`.
- Prefer concise filtered reports over enormous uncurated output.
- Keep the work offline and do not download symbol files from third parties
  unless the user explicitly asks.

## Success criteria

This task succeeds if it answers all of these:

1. What exact debug material exists, and can it be matched to a 2.6.1.1 EXE?
2. Does it contain public names only, or rich types/line records/local symbols?
3. Which save-selection, frontend, serialization, Ironman, and GUI concepts
   can be named with confidence?
4. Is there a historically useful `Continue` / save-selection decision model?
5. Which insights are safe to carry forward as hypotheses, and which cannot
   be transferred beyond the 2.6.1.1 build?

The final conclusion must explicitly separate **verified facts about 2.6.1.1**
from **possible research leads for later CK2 versions**.
