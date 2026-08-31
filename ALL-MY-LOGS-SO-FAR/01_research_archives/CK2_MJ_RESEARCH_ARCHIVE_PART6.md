# RESEARCH ARCHIVE — CK2 Monarch's Journey — Part 6 (V9 polish, DLC experiment, and 3.3.5.1 port)

Date: 2026-08-31. Source: the live Arena session on branch
`arena/01a0578f-ck2-monarch-s-journey-restorat`; no separate raw-chat export was
uploaded. This archive distils the session directly from its actions, user runtime
reports, repository diffs, and reproducible binary analysis.

---

# A. ORIENTATION

## A0. Read first

- **Playable restoration baseline remains V9**, Windows May-2020 3.3.3,
  SHA-256 `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`.
- V9 is runtime-proven: payload, Bronzeman, feats, saves, in-game Continue, cache,
  cold-load restoration, and live increases work.
- Never run `wipe_feats`; never apply 3.3.3 offsets to 3.3.5.1; do not redistribute
  complete executables; retain the banned/abandoned distinction.
- The active research direction is now **a 3.3.5.1 port or mod-like recreation**.
- Immediate technical question: confirm the surviving 3.3.5.1 feat-loader template,
  `CReader` ownership contract, database singleton construction, and
  `extend_featured_ruler` state writes.

| Label | SHA-256 | Meaning | Status |
|---|---|---|---|
| trampoline “V6” | `a6cb92b8…` | injected save-parser experiment | ❌ banned |
| V6 | `f5b7dfd6…` | five save-selection branches | ✅ proven |
| feat “V7” | `0074af70…` | abandoned two-branch feat attempt | 🟡 abandoned |
| Continue V7 | `57b18e43…` | in-game Continue execution | ✅ proven |
| V8 | `94d6fb40…` | wrong cold-load premise | ❌ disproven but two bytes remain upstream in V9 |
| V9 | `61e4345b…` | final eligibility gate forced true | ✅ current baseline |

## A1. Goal

Preserve and polish the completed V9 restoration, test whether payload-level DLC
requirements alone block four rulers, and reassess whether the useful native MJ feat
pipeline can be reused on CK2 3.3.5.1 through a mod, a small adapter, or both.

## A2. End-of-part dashboard

| Direction | End state |
|---|---|
| V9 trace tooling | ✅ corrected and re-hashed |
| Payload DLC declaration toggle | ✅ built, guarded, reversible, runtime-tested |
| `dlc024` Aquitaine/French ruler | ✅ starts and tracks without its payload declaration |
| Three `dlc007` Muslim rulers | 🟡 payload gate removed; immediate Game Over without gameplay support |
| Pure 3.3.5.1 mod-directory drop | ❌ no native feat-loader xref found |
| 3.3.5.1 native tracker/update/storage | ✅ survives, function-matched |
| 3.3.5.1 generic virtual input / `CReader` / low-level parser | ✅ survives, function-matched |
| Removed GameSparks-facing orchestration wrappers | ❌ no credible 3.3.5.1 equivalents |
| Hybrid native adapter + mod UI/setup | 🟢 plausible active direction |
| Entirely scripted normal mod | 🟢 safest fallback |
| Exact original main-menu panel | 🔴 separate high-difficulty reconstruction |

## A3. Chronology and repository identity

The session began at main merge `c4802ed`. Work was performed on the fixed Arena
branch. Relevant local commit labels observed during the session included:

- `9cdc164` — V9 trace polish;
- `cdf2914` / `ecff804` — DLC-test tooling and runtime account during intermediate
  turn snapshots;
- `2394c5b` — first 3.3.5.1 native-reuse audit;
- `895f944` — surviving feat-loader primitives mapped.

Repository content, not transient commit topology, is authoritative. This Part 6 and
the living documents preserve the cumulative result.

## A4. Story in one paragraph

After establishing that V9 had closed the last functional 3.3.3 defect, the session
first corrected a known debugger breakpoint typo. Attention briefly moved to the
cosmetic gauntlet and dirty-session Multiplayer button, then changed to the more useful
problem: playing DLC-marked rulers and ultimately moving MJ to latest CK2. A guarded
payload experiment proved that `required_dlcs` is the first grey-Play gate. Removing it
made the Aquitaine/French campaign work, while Muslim campaigns immediately ended due
to genuine missing ruler-playability support, though their feat scripts calculated
starting values before Game Over. The 3.3.5.1 port was then re-opened. Static analysis
confirmed that GameSparks networking is unnecessary, but its removed orchestration had
been the bridge from ruler payload to feat database. Crucially, function matching now
shows that update scheduling, tracker, database consumers, virtual input, `CReader`,
and the low-level feat parser survive. This makes a small native data adapter plus a
normal mod interface plausible, while a pure file drop and byte-offset port remain
closed.

---

# B. STORY

## B1. Timeline

1. Read `STATUS.md`, the latest handoff, V9 runtime results, cases, and `PLAN.md`.
   Conclusion: V9 is complete; the one concrete cleanup item was the incorrect
   `DAILY_GATE` address in the V9 x64dbg helper.
2. Corrected all three V9 helper commands from `CK2game.exe+666146` to
   `CK2game.exe+667146`. The old address was raw `0x665546`, mid-instruction; the
   corrected RVA maps to patched raw `0x666546`.
3. Re-hashed and documented the helper. Historical V8 trace evidence was retained
   unchanged rather than rewritten.
4. Considered C17 gauntlet tooltip and C09 Multiplayer. C17 is a narrow stale
   presentation predicate; C09 was previously reproduced outside Bronzeman and is
   probably a stock dirty-frontend reset problem. Neither was changed.
5. User redirected work toward 3.3.5.1 because DLC-marked rulers could not be tested
   on the DLC-less May installation.
6. Payload inspection found four `required_dlcs` declarations:
   Mordechai/Shajar/Arwa = `dlc007`; Louis/Louise Aquitaine entry = `dlc024`.
7. Built a guarded Apply/Verify/Revert payload toggle. It accepts only exact canonical
   or generated-test hashes, creates a verified timestamped backup, and never edits
   the executable or saves.
8. User runtime verdict: Muslim choices immediately Game Over; starting holdings can
   still score before termination. The Aquitaine/French ruler starts; raising a duke's
   opinion counted.
9. Clarified two challenge misunderstandings from the literal feat scripts:
   Mordechai has no “make Mongols like you” challenge; Mongols belong to a kill
   challenge. Llywelyn's English spouse must personally have a title or claim.
10. Reassessed delivery forms: normal scripted mod, generated mod, hybrid native
    tracker, small DLL adapter, reconstructed parser, copied old machine code, and
    GameSparks emulation. Ranked ordinary mod and native hybrid highest by value.
11. First 3.3.5.1 audit: `red_king/ruler_feats` and
    `common/monarchs_journey` each have only a `CDirectorySettings` constructor xref;
    no direct disk feat loader is exposed by those names.
12. Function matching then materially improved the outlook: native update and tracker
    survived at 0.990/1.000 similarity; both daily and restore callers remain.
13. Matched the low-level feat parser and the generic virtual-input/reader helpers at
    1.000 normalized similarity. The missing part is now bounded to the ruler-specific
    orchestration, activation, and frontend/setup.

## B2. Evolution of the model

| Model | Evidence | Verdict |
|---|---|---|
| “Port V9 offsets to latest” | 3.3.5.1 is a different layout and removed controller/parser wrappers | ❌ unsafe and structurally insufficient |
| “GameSparks server must be restored” | V9 works offline; only its local parser/orchestration is used | ❌ networking unnecessary |
| “Drop scripts into retained mod directories” | each directory literal is referenced only during directory-name construction | ❌ no loader found |
| “All native feat parsing was removed” | low-level parser, VFS input helper and readers match at 1.000 | ❌ disproven/refined |
| “A small adapter may feed surviving native systems” | tracker, callers, DB consumers, reader/parser survive | 🟢 plausible |
| “Exact MJ panel follows automatically if data loads” | most main-window/controller literals/code are absent | ❌ frontend remains separate |
| “Ordinary scripted mod can reproduce the experience” | CK2 scripting can hold challenge logic and save variables | 🟢 safest fallback, lower visual fidelity |

## B3. Session artifacts

| Artifact | Role | Status |
|---|---|---|
| `x64dbg/MJ_V9_CLEAN_TRACE.txt` | corrected V9 confirmation helper | ✅ canonical |
| `README_MJ_V9_CLEAN_TRACE.md` | corrected helper instructions/hash | ✅ canonical |
| `toggle_ck2_mj_payload_dlc_unlock.ps1` | guarded payload state toggle | ✅ runtime-tested transformation |
| `APPLY_MJ_PAYLOAD_DLC_TEST_UNLOCK.bat` | drag/drop Apply wrapper | ✅ |
| `REVERT_MJ_PAYLOAD_DLC_TEST_UNLOCK.bat` | drag/drop exact revert | ✅ |
| `MJ_PAYLOAD_DLC_TEST_UNLOCK_GUIDE.md` | user procedure and warning | ✅ |
| `DLC_TEST_UNLOCK_RUNTIME_RESULTS.md` | runtime verdict + condition clarifications | ✅ |
| `WINDOWS_3351_NATIVE_REUSE_AUDIT.md` | two-pass port analysis | 🟢 active |

---

# C. KNOWLEDGE BASE

## C1. GameSparks' actual role

GameSparks is important only because Paradox coupled several local functions to its
interface. The useful May chain was:

```text
local payload -> GameSparks-shaped JSON parser -> highlighted-ruler objects
-> embedded feats_script -> virtual gs_virtual/feat_script -> CReader
-> native feat database -> tracker/storage/tier UI
```

No server is needed. For 3.3.5.1, replace the left-hand orchestration rather than
rebuilding network communication.

## C2. DLC experiment

Canonical payload: 101,949 bytes,
`fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e`.
Generated test state: 101,761 bytes,
`1216a9eda59e35779171a616e489d6b1f823e6d4b62909a4924fafe8330e982b`.
Delta = 188 bytes, exactly four removed formatted declaration blocks.

The experiment distinguishes two gates:

1. local payload `required_dlcs` controls the MJ button/icon;
2. ordinary CK2 ruler playability still enforces unavailable gameplay support.

`dlc024` declaration removal was sufficient for the Aquitaine/French entry on this
installation. `dlc007` removal was not sufficient for Muslim gameplay.

## C3. Exact misunderstood conditions

Mordechai `peace` counts a direct, non-prisoner vassal at opinion ≥60 whose public
religion differs from ROOT. Mongols are used by `secret_stays_with_me`, which scores
kills by Mongol culture and Muslim religion, with overlapping/hidden-kill bonuses.

Llywelyn `love_spoons` requires living `c_214714`; each counted child must have a spouse
of English culture, and that spouse must personally have ≥1 claim or ≥1 title. Gender
is not tested.

## C4. V9 trace correction

```text
wrong x64dbg RVA: +666146 -> VA 0x140666146 -> raw 0x665546
right x64dbg RVA: +667146 -> VA 0x140667146 -> raw 0x666546
```

Corrected helper SHA-256:
`9bd5fc652eae425b3becd5508a806203c2ef2ab8d150f46a09ee16da58a24bfa`.
Updated helper README SHA-256:
`03bd75798024774c3a8b4c5e84dcd4a1437bc471b66ed4b52a5434a4f8994d45`.

## C5. 3.3.5.1 retained native pipeline

Target: 24,236,024-byte Windows 3.3.5.1,
`a0cc8e92287ac900b0552f5cca20df5acedf4773244923a77b15bcdbe143b13d`.

| Component | May 3.3.3 | 3.3.5.1 | Match/result |
|---|---:|---:|---|
| tracker accessor | `0x1407B8270` | `0x1407BABD0` | 1.000 |
| `UpdateFeatProgress` | `0x1407B8E60–0x1407B933F` | `0x1407BB600–0x1407BBACF` | 0.990 |
| low-level feat reader candidate | `0x1407B9850–0x1407B9CB3` | `0x1407BBF70–0x1407BC3D3` | 1.000; template identity pending |
| virtual input helper | `0x140C5CD70` | `0x140C57320` | 1.000 |
| reader constructor/wrapper | `0x140C38080` | `0x140C32650` | 1.000 |
| reader close/destructor | `0x140C38310` | `0x140C328E0` | 1.000 |
| current-ruler source wrapper | `0x1407B7950–0x1407B7C3C` | — | removed; best unrelated match 0.707 |
| complete-ruler source wrapper | `0x1407B7C40–0x1407B808C` | — | removed; best unrelated match 0.560 |

3.3.5.1 daily caller: `0x1406675A6`; restore caller: `0x140789AA8`.
Both check global byte `0x141666C03`, call accessor `0x1407BABD0`, then update
`0x1407BB600`.

Database correspondence from matched update bodies:

| Role | May | 3.3.5.1 |
|---|---:|---:|
| primary | `0x1418D6C78` | `0x14185A770` |
| complete/secondary | `0x1418D6CB0` | `0x14185A798` |
| current/level helper | `0x1418D6C00` | `0x14185A6F0` |

## C6. Retained directories and UI fragments

- `red_king/ruler_feats` VA `0x1410372F0`, sole direct xref `0x1404DDEE9`.
- `common/monarchs_journey` VA `0x1410372C0`, sole direct xref `0x1404DDF34`.
- Both xrefs are in `CDirectorySettings` `0x1404DD640–0x1404DDF54`.
- `RULER_FEAT_LEVEL_` remains active in `0x1407BA3C0–0x1407BA53D`.
- highlighted-ruler toggle handler survives at `0x1407BD7C0–0x1407BDB21`.
- Four `extend_featured_ruler` regions survive: `0x140729CE0`, `0x14072BC80`,
  `0x14072C540`, `0x14072E7E0` starts.

---

# D. ATTEMPTS & DEAD ENDS

| Attempt/direction | Verdict | Durable lesson |
|---|---|---|
| silently trust V9 `DAILY_GATE` label | ❌ | breakpoint number spaces must be converted; helper fixed |
| globally rewrite challenge-disabled localization | 🟡 not done | would lie in genuinely disabled games; patch predicate if pursued |
| blindly force Multiplayer button | 🟡 rejected | dirty state may be protective; repair reset, not appearance |
| remove payload DLC declarations | ✅ diagnostic | unlocks first gate only; does not grant gameplay DLC |
| use removed declarations as canonical payload | ❌ | keep optional; Muslim campaigns remain unusable here |
| latest-version pure folder drop | ❌ | retained names are registration only |
| latest-version V9 offset translation | ❌ | removed wrappers/controller make offsets insufficient |
| GameSparks service emulation | ❌ for 3.3.5.1 | client/parser removed; solves the wrong layer |
| copy 3.3.3 machine code wholesale | 🔴 avoid | relocation, ABI, globals, unwind and ownership risk |
| native adapter using surviving primitives | 🟢 active | narrower than originally feared, but ABI proof required |
| scripted normal mod | 🟢 fallback | highest maintainability; lower native fidelity |

No new executable patch was authored or applied in this part.

---

# E. OPEN THREADS & FUTURE DIRECTIONS

1. **Confirm loader identity.** Several `0x463` template instances normalize
   identically; settle the highlighted-ruler feat instance via vtables and caller
   neighborhood before invoking anything.
2. **Recover ownership contract.** Map arguments and lifetime across virtual helper
   `0x140C57320`, reader `0x140C32650`, loader candidate, and destructor
   `0x140C328E0`.
3. **Map singleton construction/reset** for `0x14185A770`, `0x14185A798`, and
   `0x14185A6F0`.
4. **Trace `extend_featured_ruler`.** Determine whether it can establish
   `special_event`, selected identity, and Bronzeman without the removed frontend.
5. **Choose proof of concept:**
   - preferred high-fidelity: one-ruler mod setup + minimal native data adapter;
   - safe fallback: one-ruler fully scripted mod, beginning with Louis/Aquitaine's
     vassal-duke opinion challenge.
6. Exact main-menu UI is deferred until gameplay/tracking works on 3.3.5.1.
7. C17 and C09 remain secondary and were not altered.

No user upload is currently required. Ask for a 3.3.5.1 runtime test only after a
concrete guarded experiment exists.

---

# F. CONTEXT, METHODS, AND PRESERVATION

## F1. Environment and policy

- User tests on Windows and prefers drag-and-drop instructions.
- Static work uses repository copies; user binaries are never modified remotely.
- Tests remain offline for the V9 path.
- Complete executables stay private; only guarded transforms are deliverables.
- Scratch disassemblies and temporary Python environments are reproducible and were
  removed rather than committed.

## F2. Confidence discipline

- **Runtime-proven:** V9 behavior; DLC payload gate removal; Aquitaine start/tracking;
  Muslim immediate Game Over; initial score calculation before termination.
- **Static-proven:** string xrefs, function boundaries, caller addresses, normalized
  matches, absent source wrappers.
- **Strong candidate, not yet proven:** `0x1407BBF70` as the exact feat template
  instance; native adapter feasibility.
- **Design proposal:** hybrid mod/adapter and scripted-mod fallback.

## F3. Information-preservation audit

- V9 correction lives in helper, README, MASTER, PLAN, contradiction register,
  runtime report and the 2026-08-30 dissection addendum.
- DLC tooling lives under `05_patches_and_scripts`; procedure under `04`; runtime
  verdict under `03`; dashboard and plan updated.
- Port facts live in `WINDOWS_3351_NATIVE_REUSE_AUDIT.md`; this Part 6 supplies the
  chronological/evolution record.
- No raw current-session export exists, so `12_raw_chat_logs/INDEX.md` receives a
  direct-session ledger entry rather than pretending a deleted file existed.
- Dead ends are retained with evidence and status rather than erased.
- Referenced runnable tools exist; generated DLC-test state hashes are registered.
- No scratch `.venv`, 241 MB objdump listing, or one-off matcher was retained because
  each is reproducible from the verified executable and the distilled addresses are
  preserved here.

## F4. Instruction evolution

The user's original goal was not merely tidiness: preserve evolution, failed attempts,
results, calculations, future directions, and enough context for the next AI while
removing conversational noise. Controlled self-improvement of the organization prompt
is therefore good **when versioned and additive**. The operative v8 rulebook adds:

- direct-session distillation when no raw export exists;
- fact/inference/proposal confidence labels;
- explicit decision records for changing the active research direction;
- reproducibility rules for large scratch outputs;
- a requirement to keep dead ends discoverable without letting them dominate STATUS;
- a navigation audit after every new project branch.

Older prompts remain as history; factual dashboards continue to outrank prompt text.
