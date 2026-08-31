# RESEARCH ARCHIVE — CK2 Monarch's Journey — Part 5 (V8 disproven → clean trace → V9 proven)

Source material: the `last log/` staging folder (11 files, 1,716,243 bytes total),
torn apart 2026-08-30 under `00_START_HERE/PROMPT_organize_research_log_v7.md`.
Per-file disposition is in `12_raw_chat_logs/INDEX.md` and
`00_START_HERE/DISSECTION_REPORT_2026-08-30.md`; byte-level residue that exists
nowhere else is in `03_analysis/RAWLOG_NETNEW_EXTRACTS.md` §11.

---

## A. ORIENTATION

### A0 — read this first

**Current safe state (2026-08-30, after the user's V9 playtest):** the in-game
baseline is **V9**, SHA-256
`61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`
(Windows May-2020 3.3.3, 24,753,368 bytes). The user reports the cold-load feat
defect is **gone**: feats are present after a cold quit → relaunch → load, they
survive both a soft (resign) and a hard (quit-to-desktop) exit, and they increase
when the player does the right thing.

**Banned / abandoned (unchanged):** trampoline "V6" `a6cb92b8…` (❌ corrupts save
parsing), feat-"V7" `0074af70…` (🟡 premise disproven). Never run `wipe_feats`.
Never redistribute a complete stock or patched executable.

**Naming collision table (key by SHA, never by label):**

| Label | SHA-256 | What it was | Status |
|---|---|---|---|
| "V6" trampoline | `a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff` | injected code | ❌ BANNED |
| V6 | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | 5 save-list branches | ✅ proven, revert target |
| "V7" feat-update | `0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8` | two `74 0d→90 90` | 🟡 ABANDONED |
| V7 Continue | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` | `0x009E5B8B` `75 2f→eb 2f` | ✅ in-game Continue |
| V8 feat-rehydration | `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93` | `0x00666546` + `0x007B786B` gate bypasses | ✅ applied on user machine, ❌ **premise disproven** |
| **V9 eligibility force** | `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687` | `0x007B7906` `e8 85 71 8f ff → b0 01 90 90 90` | ✅ **current baseline, runtime-proven 2026-08-30** |

**Immediate next action:** nothing is blocking play. The one open question the user
raised is cosmetic/semantic — the challenge medal stays **Bronze** when an earlier
save (or a restarted campaign) is loaded, and the "Word has spread far and wide…"
notification does not fire again. That is explained (not a bug) in
`03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`.

### A1 — goal

Bring the retired Monarch's Journey feature back for personal offline Windows use
without losing the research trail; this part closes the last functional defect
(feats reading 0 after a cold load).

### A2 — status dashboard at the end of this part

| Area | State |
|---|---|
| Payload load, MJ panel, Bronzeman start | ✅ works (V2/V4 era) |
| Live challenge evaluation in a fresh campaign | ✅ works |
| Save write / Load Game / in-game Continue | ✅ works (V6 / V7) |
| **Feats after cold quit → relaunch → load** | ✅ **fixed by V9** (was the last functional defect) |
| Feats increase during play on a loaded save | ✅ works on V9 (user-confirmed) |
| Feats survive soft resign and hard quit | ✅ works on V9 (user-confirmed) |
| Medal tier / "Word has spread…" on an old save | 🟡 **INFO, not a defect** — cache stores lifetime peak per account, not per save |
| Paradox **launcher** Continue | ❌ open (**C25**), separate program |
| MP 2nd boot, grey map, flicker, missing arrow, C17 tooltip | ❌ open, secondary |

### A3 — where this part sits in time

Six distinct sessions, in Arena-branch UUID order (all after PR #12):

| # | Session branch | Raw file(s) in `last log/` | Arc |
|---|---|---|---|
| 1 | `arena/01a044b2-…` | `first first raw log.txt` (4,358 ln) and its truncated re-export `raw chat.txt` (4,346 ln) | feat-reset diagnosis → V8 built → preflight fix → `.bat` CRLF fix → PR request **rejected by the service** |
| 2 | `arena/01a04980-…` | `first raw log.txt` (497 ln) | landed the `01a044b2` patch: hash chain re-verified, **PR #13**, merge commit `96ba84b`, patch archived to `11_git_patch/` |
| 3 | `arena/01a049a4-…` | `another other raw log.txt` (1,142 ln) | "still didn't work" → wrote `NEXT_SESSION_HANDOFF_2026-08-29.md`, **PR #14** (commit `ab07419`, merge `910234875decd988ce55ed95e2401ce0f8c1b02a`) |
| 4 | *(no repo — pasted chat)* | `one more raw log.txt` (426 ln) | user applied V8 by hand from PowerShell; result **feats 0 in game *and* in the main-menu MJ tab**; cache pasted; `.bat` flicker root-caused |
| 5 | `arena/01a04d46-…` | `another raw log.txt` (3,743 ln) | evidence session: V8 confirmed installed, cache + save forensics, `RestoreDeviceObjects` gate found unpatched, clean-trace helper built, **PR #15** (squash, `f29287217b300be83a0c6334ccddc9a780bd5092`) |
| 6 | `arena/01a0534b-…` | `last log (for now).txt` (6,373 ln) + `x64dbg logs.txt` (the V8 clean trace) | trace analysis → stock-exe disassembly → **V9** built and delivered (**PR #16**, merge `d2f61bb9…`, merged 2026-08-30 16:38 UTC — added to §A3/§11.7 on 2026-08-31, was omitted in the first pass) |

Note the wrap-around: session 4 has no repo access (the user pasted the handoff and
renamed the patchers to `.txt`), so its facts arrive only as quoted transcript.
Sessions 2 and 3 both start from a *different* single "Add files via upload" commit
(`5b39d7d` and `b4cdb4a` respectively) because the user re-uploads the whole tree
through the GitHub web UI between sessions; the local clone is shallow (depth 1), so
authoritative history is the file contents, not `git log`.

Also note the merge-style drift: PRs #13/#14 used merge commits, PR #15 was
**squash**-merged. Neither is wrong; record which was used when citing a merge hash.

### A4 — one-paragraph story

V8 (two `IsActiveForPlaythrough` bypasses) was applied for real and *made things
worse*: feats read 0 in game **and** in the main-menu MJ tab, so the "cache is still
fine, only the in-game vector is empty" assumption died with it. A controlled
evidence pass then proved the executable really was V8, the disk cache was non-zero
and identity-stable, and every relevant save carried its `global_*` values — so the
failure had to be inside the tracking path. An automated attach-mode x64dbg trace
(seven logging breakpoints, no pauses) captured the same cold load twice: warm
`CALC_RETURN_PATH al=1`, cold `al=0`, with `CALC_FAIL_PATH` never firing. Static
disassembly of the stock exe then walked `CalcShouldTrackFeatProgress` gate by gate
and isolated the **final** eligibility call at raw `0x007B7906` (`call 0x1400AF690`)
as the only cold-path failure. V9 replaces that one 5-byte call with
`mov al,1; nop; nop; nop`. The user applied it and reported the defect gone.

---

## B. STORY

### B1 — timeline

1. **V8 applied by hand** (session 4). `patch_ck2_mj_v8.ps1 Verify` → `State: v7`,
   `SHA-256: 57b18e43…`, `RESULT: V7 BASELINE DETECTED; READY TO APPLY V8`.
   `Apply` → backup `CK2game.exe.before_mj_v8_from_v7_20260829_132333.bak`,
   `Set 0x00666546: 74 0d -> 90 90`, `Set 0x007b786b: 75 05 -> eb 05`,
   `RESULT: V8 FEAT-REHYDRATION PATCH APPLIED AND VERIFIED`,
   `SHA-256: 94d6fb40…`.
2. **User:** *"tried. feats are 0 in game, and even in main menu (in MJ tab) too
   now."* → revert to V7 advised and performed.
3. **User pastes the cache** (`cache/q847rsja8ndx`): `key=-2128831035`,
   `id=-2128831035`, `user_id=1179784490`, `conquerer_from_bribir=1`,
   `established=4`, all other 31 feats 0, `category=-1991027533`; also notes the
   GameSparks `Roaming` folder (`E349414h9BDm`) never reappeared.
4. **User:** *"and, no. reverted, did everything you said. feats 0 in game and in
   main menu mj tab"* → the "warm resign will restore the display" prediction fails.
5. **User:** *"yes, it picks up feats from game previously loaded. but when i do
   something that should give scores in them, it stays in place"* → **live
   evaluation and load-hydration are separate paths** (first time this is stated).
6. **`.bat` flicker root-caused** (session 4): `APPLY_CK2_MJ_V8.bat` line 34 wraps a
   `powershell.exe -Command "…(…)…"` inside a multi-line `if exist (…) ( … ) else (…)`
   block; cmd.exe terminates the block at the first `)` inside the PowerShell string
   and dies before `pause`. Direct PowerShell works because cmd's parser is bypassed.
   Rule adopted: keep PowerShell calls out of nested batch `if` blocks.
7. **Evidence session** (5). Cache enumeration of
   `C:\Users\UZWERG\Documents\Paradox Interactive\Crusader Kings II\cache`: exactly
   one feat-cache file, `q847rsja8ndx`, `MODIFIED: 08/29/2026 16:19:51`,
   `SHA256: 3606E210F48EB16B668B06E24942B545E65B11531F28F28D08FF9FDDE404601F`,
   `user_id=84696387`, `conquerer_from_bribir=1`, `established=3`,
   `category=-852858316`. A later snapshot of the same path:
   `LastWriteTime 29.08.2026 20:32:18`, `Length 751`, `established=3`.
8. **Executable confirmed V8** on the machine that runs the game:
   `State: v8 / Size: 24753368 bytes / SHA-256: 94d6fb40… / RESULT: CORRECT V8
   FEAT-REHYDRATION PATCH`. (An earlier hash in the same transcript was
   `57B18E43…` = V7, i.e. captured before the re-apply — a sequencing artefact, not
   a wrong binary.)
9. **Save forensics** (read-only ZIP scan of `global_*`): ten Pavao/Croatia saves,
   all carrying `global_conquerer_from_bribir=1.000` and `global_established` of
   2.000/3.000/4.000 (table in C4). "The save has no feat globals" is eliminated.
10. **User:** *"i tried on different saves. when i resign then load feats remain, but
    dont go up. i loaded first day save, had already bronze (highest what i got)
    score. when completely go out of game, then load, 0 everywhere - in mj tab and
    ingame too."* → three facts at once: warm load restores values, live progress is
    frozen on V7, and a **first-day save already shows the Bronze medal** (see
    `FEAT_CACHE_PEAK_TIER_ICON.md`).
11. **User:** *"it doesn't change, since it's not updating with new feats"* (about the
    cache across a confirmed-V8 cold load) → V8 did not erase the disk cache; the
    zero display is an in-memory/UI condition.
12. **First x64dbg attempt** (manual, launch-mode leftovers): the debugger stopped
    repeatedly at stale Continue breakpoints `+9E4970`, `+9E5500`, `+9E678B`,
    producing huge register dumps (`RIP 0x7FF7B78C4970`, `0x7FF7B78C5500`) with
    `R10 = "hethum_armenia"` / `"pavao_croatia"` — payload ruler keys in memory, not
    feat-path evidence. One line is genuinely valuable: x64dbg disabled the saved
    breakpoint at `0x7FF7B78C678B` with *"bytes do not match — expected `75 2F`,
    got `EB 2F`"*, i.e. **live in-memory proof that the V7 Continue patch is present**
    in the running process.
13. **Clean trace helper built** (session 5) → `MJ_V8_CLEAN_TRACE.txt` +
    `RUN_MJ_V8_CLEAN_TRACE.bat`: `bc/bphc/bpmc/bcdll/DeleteExceptionBPX`, then seven
    `bp`+`bplog`+`bpcond …,0` points, hash-gated attach to the already-running
    process. PR #15.
14. **The V8 clean trace** (`x64dbg logs.txt`, 504 lines): three
    `[MJ] CLEAN V8 TRACE ARMED` lines (log lines 250/264/278), then **four** `[MJ]`
    bursts — two warm (lines 373–377, 381–385) and two cold (lines 490–494, 498–502).
    Verbatim, cold burst #1:
    `[MJ] DAILY_GATE rip=00007FF7B7546146 rax=00000222E758CF80 al=80 zf=0 tf=1` →
    `[MJ] UPDATE_ENTRY rip=00007FF7B7698E60 rcx=00007FF7B87B7760 rdx=4` →
    `[MJ] RULER_INFO_CHECK rip=00007FF7B769848D rax=00000222A2B27050 zf=0` →
    `[MJ] CALC_RETURN_PATH rip=00007FF7B7698519 rax=…0 al=0 zf=0` →
    `[MJ] CALC_RESULT rip=00007FF7B7698E86 rax=…0 al=0 zf=0`.
    The warm bursts are identical except `al=1` on the last two lines.
    `CALC_FAIL_PATH` never fired in any burst. `Total loadtime was 779.015 seconds`
    sits between the warm and cold sets. **`RESTORE_GATE rip=00007FF7B76662E8 al=1`
    in both warm and cold** — i.e. `IsActiveForPlaythrough` returned **true** during
    the cold load at that call site, which independently kills V8's premise.
15. **Static disassembly** (session 6, capstone over the repo's stock
    `CK2game333.exe`, hash re-verified `656f4f48…`): the gate chain is walked end to
    end and the cold failure is pinned to the final `call 0x1400AF690`.
16. **V9 built**: `build_v9_chain.py` replays V2→V8 from the patcher sources,
    asserting every documented hash, then applies the V9 edit and prints
    `61e4345b…`. Deliverables: `patch_ck2_mj_v9.ps1`, `APPLY_/CHECK_/REVERT_*V9*.bat`,
    `MJ_V9_CLEAN_TRACE.*`, `README_MJ_V9_CLEAN_TRACE.md`,
    `V9_COLD_LOAD_FEATS_FIX.md`, `NEXT_SESSION_HANDOFF_2026-08-30.md`.
17. **Delivery friction:** the `.bat` route was still untrusted, so the user asked
    for a single PowerShell command. A guarded self-contained `Invoke-MJV9` function
    was pasted in chat (accepts V7 or V8, backs up, pre-checks all three sites,
    verifies the in-memory hash before writing, verifies the temp file, verifies the
    final file, then checks `gfx\monarchs`). The chat claimed it was also saved as
    `ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1` — **it was not**; reconstructed from the log
    during this ingest (see E4).
18. **User verdict (2026-08-30, this pass):** *"the result of v9 - it works, feats are
    present, don't reset after soft or hard quiting. they go up if i do the right
    thing."* Plus the one uncertainty about the Bronze medal on earlier saves.

### B2 — evolution of the mental model

| # | Theory | Killed / confirmed by |
|---|---|---|
| 1 | Identity drift: the feat cache is written under a changing `user_id`, so progress looks reset | **Partly refuted, partly re-opened.** Within one session `user_id=84696387` was stable and the preflight agreed. But four distinct `user_id` values now exist across captures of the same logical cache (`453496064`, `84696387`, `1148909174`, `1179784490`) with *identical feat vectors* — see `CONTRADICTIONS.md` §12 |
| 2 | The disk cache is wiped by the failed run | ❌ Refuted: cache non-zero (`established=3`) before and after a confirmed-V8 cold load, same file, same identity |
| 3 | The save lacks `global_*` values | ❌ Refuted: all ten Pavao/Croatia saves carry `global_conquerer_from_bribir=1.000` and `global_established` 2–4 |
| 4 | V8's premise — the two `IsActiveForPlaythrough` gates are the whole cold-load block | ❌ **Disproven.** With both bypasses active the cold path still returned `al=0`, and it did so at `CALC_RETURN_PATH`, i.e. *after* both bypassed gates |
| 5 | `special_event` is not restored into `[gameState+0x598]` on cold load, so the tracker sees a blank ruler | 🟡 **Not the operative cause of the traced failure** (ruler-info check passed, `RULER_INFO_CHECK rax=00000222A2B27050 zf=0`), but the *family* of the idea survives: the singleton's `+0x63` flag is written as `(id == 0x17A36D62)` by a playthrough-activation function — see C3 |
| 6 | The unpatched restore gate (raw `0x007856E8`, the "RESTORE" function at raw `0x7855C0`) is the cold-load blocker | ❌ **Refuted by the trace.** `RESTORE_GATE al=1` on the cold burst, and `UPDATE_ENTRY` followed it, so the restore path *did* call `UpdateFeatProgress`. `another raw log.txt` line 2207 states the opposite ("Restore gate false and no update entry … the unpatched 0x007856e8 gate is the direct cold-load blocker") — that was the pre-trace hypothesis and it is wrong |
| 7 | The final eligibility gate `0x1400AF690` returns 0 on a cold load because feature-availability data is not populated yet | ✅ **Confirmed** by elimination (every earlier gate passed, `CALC_FAIL_PATH` never fired) and by the V9 runtime result |
| 8 | Load-hydration and live challenge evaluation are the same path | ❌ Refuted by the user's own observation (step 5) — they are separate; V9 fixes the tracking gate, which is what both needed |

### B3 — lineage of the two new generations

| Gen | Edits (raw offset → bytes) | Hash | Runtime result | Verdict |
|---|---|---|---|---|
| **V8** | `0x00666546` `74 0d→90 90`; `0x007B786B` `75 05→eb 05` | `94d6fb40…` | cold load: feats 0 **in game and in the main-menu MJ tab**; live progress still frozen | ❌ premise disproven — **keep the bytes for the record, do not ship alone** |
| **V9** | V8 + `0x007B7906` `e8 85 71 8f ff → b0 01 90 90 90` | `61e4345b…` | feats present after cold quit→relaunch→load; survive soft and hard quit; increase on correct play | ✅ current baseline |

V8's *side effect* is itself evidence: forcing `UpdateFeatProgress` to run while the
playthrough is not recognised pushed zeroes into the display (main-menu MJ tab
included). That is why V9 keeps V8's bypasses but forces the *result* of the final
gate rather than widening the entry conditions further.

---

## C. KNOWLEDGE BASE

### C1 — the failing gate chain (Windows May-2020 3.3.3, verified by disassembly)

`UpdateFeatProgress` (raw `0x7B8260` / VA `0x1407B8E60`) begins with
`call CalcShouldTrackFeatProgress` (raw `0x7B8281`, VA `0x1407B8E81`), consumed by
`test al,al` at VA `0x1407B8E86` (the `CALC_RESULT` breakpoint) with a `je` bail to
`0x1407B932E`.

`CalcShouldTrackFeatProgress` (raw `0x7B7850` / VA `0x1407B8450`) checks, in order:

1. global MJ flag `[rip+0xF2AD08]` (VA `0x1416E3163`) → if set, return 1 (raw `0x7B785D`);
2. `IsActiveForPlaythrough` raw `0x7B7864` — V8 neutralises its result at raw
   `0x7B786B` (`75 05→eb 05`; the `jne` at VA `0x1407B846B` targets `0x1407B8472`);
3. ruler info via vtable `+0xD8`, null check raw `0x7B848D` (VA `0x1407B848D`) — passed;
4. date helper `0x140E1DAF8` + expiry `[rbx+0x20]` — passed;
5. gameState mode bytes `+0x500` / `+0x501` (Bronzeman/Ironman) — passed;
6. singleton flags via `0x1400AF050`: `[+0x60]==0` and `[+0x65]!=0` (the
   `CALC_FAIL_PATH` return at raw `0x7B78F8` / VA `0x1407B84F8`) — **never taken**;
7. **final gate raw `0x007B7906` (VA `0x1407B8506`): `call 0x1400AF690` → `setne al`
   → `ret`** (VA `0x1407B8519` = `CALC_RETURN_PATH`) — **the only cold-path failure**.

Exactly two direct callers of `UpdateFeatProgress` exist (byte-pattern xref scan):
daily site raw `0x666550` (VA `0x140667150`) and restore site raw `0x7856F2`
(VA `0x1407862F2`). Both are gated by `IsActiveForPlaythrough` with a global-flag
bypass. There is no third re-hydration path.

The restore caller lives in a function starting at raw `0x7855C0` (VA `0x1407861C0`)
— tentatively called "the RESTORE function" in the logs. Its earlier name
`CInGameIdler::RestoreDeviceObjects` was a **Linux-symbol guess**, not a confirmed
identity; the V9 session dropped the name. It frees a list of 0x58-byte nodes, sets
`[rsi+0x3F8]=0`, and has the same bypass shape as `DailyUpdate`:

```text
cmp  byte ptr [rip+0xF5CE84], 0
jne  0x1407862EA            ; global MJ flag → call UpdateFeatProgress unconditionally
VA 0x1407862E1  call 0x1407B8370   ; IsActiveForPlaythrough
VA 0x1407862E6  test al, al
VA 0x1407862E8  je   0x1407862F7   ; 74 0D at raw 0x007856E8 — STILL 74 0D in V8 and V9
VA 0x1407862F2  call 0x1407B8E60   ; UpdateFeatProgress
```

**The trace settles the direction of this gate:** the `RESTORE_GATE` breakpoint sits
exactly on that `je` and logged `al=1` on the cold burst, so
`IsActiveForPlaythrough` returned **true** there and `UpdateFeatProgress` was called.
Patching raw `0x007856E8` was considered as an extra V9 belt-and-braces edit and
**deliberately not applied** — the trace showed it was unnecessary.

The `DailyUpdate` gate in full (disassembly, stock exe):

```text
raw 0x0066653D  VA 0x14066713D  jne  0x140667148        ; global flag bypass
raw 0x0066653F  VA 0x14066713F  call 0x1407B8370        ; IsActiveForPlaythrough
raw 0x00666544  VA 0x140667144  test al, al
raw 0x00666546  VA 0x140667146  je   0x140667155        ; 74 0D  ← V8 turns this into 90 90
raw 0x00666548  VA 0x140667148  call 0x1407B8270        ; get ruler feat tracker
raw 0x0066654D  VA 0x14066714D  mov  rcx, rax
raw 0x00666550  VA 0x140667150  call 0x1407B8E60        ; UpdateFeatProgress
raw 0x00666555  VA 0x140667155  mov  rax, [rip+…]
raw 0x0066655C  VA 0x14066715C  cmp  byte ptr [rax+0x500], 0   ; Bronzeman/Ironman
raw 0x00666563  VA 0x140667163  je   0x14066717C
raw 0x00666565  VA 0x140667165  cmp  byte ptr [rax+0x501], 0
raw 0x0066656C  VA 0x14066716C  je   0x14066717C
raw 0x0066656E  VA 0x14066716E  test sil, sil
raw 0x00666571  VA 0x140667171  jne  0x14066717C
raw 0x00666573  VA 0x140667173  mov  rcx, rbx
raw 0x00666576  VA 0x140667176  call 0x140659AB0
```

### C2 — what the final gate `0x1400AF690` does (raw `0xAEA90`)

- `[this+0x64]!=0` → return true immediately (raw `0xAEAB7`). No writer for `+0x64`
  was found; init leaves it 0.
- A global-object/`r8b` path can return false early — not our path
  (`CalcShouldTrackFeatProgress` calls with `r8d=0`, `dl=1`).
- With `dl=1`: call the eligibility loop `0x14072D540` on `global+0x530` (or an
  allocated 0x428-byte object; offset `0xD0`/`0x120` chosen by `[global+0x581]`).
  If it returns 0 → the gate returns 0 (raw `0xAEB7D` → `0x1400AF6E1`).
- The **stock** tail at raw `0x000AEB83` (VA `0x1400AF783`) — verified with objdump
  against the repo's stock exe — is:

  ```text
  1400af783  cmp  byte ptr [rdi+0x61], 0
  1400af787  je   0x1400af795          ; -> xor esi,esi -> eax = 0
  1400af789  cmp  byte ptr [rdi+0x63], 0
  1400af78d  je   0x1400af795          ; -> eax = 0
  1400af78f  cmp  byte ptr [rdi+0x62], 0
  1400af793  je   0x1400af797          ; -> skips the xor -> eax = esi (non-zero)
  1400af795  xor  esi, esi
  1400af797  movzx eax, sil
  ```

  So stock returns non-zero **iff `+0x61!=0` and `+0x63!=0` and `+0x62==0`**.
- **Correction:** an earlier reading of this section said "`+0x62` is irrelevant
  here". That is false for stock, which requires `+0x62` to be **clear**.
- **This tail is not stock in any image from V4 onward.** V4 rewrote those 24 bytes
  (patch-map row `0x000aeb83`), and the rewrite is present in V4, V5, V6, V7, V8
  **and V9** (verified byte-for-byte across the replayed chain):

  ```text
  1400af783  xor  eax, eax
  1400af785  cmp  word ptr [rdi+0x61], 1   ; word compare => +0x61==1 AND +0x62==0
  1400af78a  jne  0x1400af79b              ; -> ret with eax = 0
  1400af78c  cmp  byte ptr [rdi+0x63], 0
  1400af790  jne  0x1400af798              ; -> inc eax -> 1
  1400af792  cmp  byte ptr [rdi+0x65], 0
  1400af796  jne  0x1400af79b              ; -> ret with eax = 0
  1400af798  inc  eax                      ; -> 1
  1400af79a  nop
  ```

  i.e. V4-onward returns 1 iff `word[+0x61]==1` **and** (`+0x63!=0` **or** `+0x65==0`).
  The `cmpw` preserves stock's "`+0x62` must be 0" while adding `+0x65` as an
  alternative to `+0x63`.
- Singleton `0x1400AF050` (raw `0xAE450`) lazily allocates a 0x68-byte object with
  defaults `+0x60=0, +0x61=1, +0x62=0, +0x63=1, +0x64=0, +0x65=0` (written as the
  dword `0x01000100` at `+0x60`), so at defaults `word[+0x61]==1` holds.
- The only `[+0x62]=1` writer is raw `0x767CB3` inside the function at raw `0x767B16`
  (VA `0x140768716`) that matches `recommended_dlc_list` / `YOUKICKED` / `ld` — the
  achievement-block/anti-cheat flag, **not** the cold gate.

**Consequence — a sharper root cause than "the gate returned 0".** In the traced V8
image the tail is the V4 version. With the singleton at defaults that condition is
*satisfied* (`word[+0x61]==1`; and `CALC_FAIL_PATH` never firing implies `+0x65==0`,
which alone satisfies the OR). The tail would therefore have returned 1 — so the cold
`al=0` did **not** come from the tail. It came from **earlier inside `0x1400AF690`**:
the feature-list eligibility walk `0x14072D540` returning 0. That is precisely the
"linked feature entries are not populated/available yet on a cold load" mechanism, and
it is why V9 — replacing the *call*, not any flag — is the correct minimal fix. It also
means the alternative candidate in C3 (`+0x63` cleared by the activation function) is
*not* the traced failure, though it remains a real mechanism worth knowing.

Two dependencies of that inference come from the V9 session's disassembly rather than
being re-derived in this ingest: the singleton defaults, and the polarity of the
`CALC_FAIL_PATH` test. Both are consistent with the trace; neither was independently
re-verified here.

### C3 — net-new lead: the playthrough-activation function and the magic id

Disassembly at VA `0x14080F370` (raw `0x80E770`) — recorded here for the first time;
it is the best remaining lead if a *cleaner* fix than V9 is ever wanted:

```text
0x14080F392  call 0x1400AF050              ; get the 0x68-byte singleton
0x14080F397  mov  rdx, [rip+0xED472A]      ; global object
0x14080F39E  mov  rdi, rax                 ; rdi = singleton
0x14080F3A1  mov  rcx, [rdx+0x1C0]
0x14080F3A8  call 0x140DA68F0              ; → al
0x14080F3AD  cmp  ebx, 0x17A36D62          ; ← magic id (396,936,034)
0x14080F3B3  mov  byte ptr [rdi+0x65], al  ; singleton+0x65 = "tracking enabled"
0x14080F3B6  mov  rbx, [rsp+0x30]
0x14080F3BB  sete cl
0x14080F3BE  mov  byte ptr [rdi+0x63], cl  ; singleton+0x63 = (id == 0x17A36D62)
0x14080F3C1  mov  rax, [rsi+0x30]
0x14080F3CA  mov  byte ptr [rax], 1        ; "ran once"
```

`ebx` comes from `[[rsi+0x28]+0x18]`. No direct `E8` callers were found — it is
reached through a vtable. Implications:

- `+0x65` (required non-zero by `CalcShouldTrackFeatProgress`) and `+0x63` (required
  non-zero by the final gate) are **both written here**, from one id comparison.
- `+0x63` *defaults to 1* and is only cleared by this function, so a cold-load
  failure through `+0x63` would mean the function ran while the current special-event
  id did **not** equal `0x17A36D62` — i.e. the "featured-ruler match is lost on cold
  load" idea, one level deeper than `gameState+0x598`.
- V9 is deliberately robust against **both** sub-causes: it replaces the whole gate
  *call*, so neither `0x14072D540` nor `+0x63` can veto tracking any more.
- `0x17A36D62` is unexplained. Candidate: a string/id hash for the MJ special event.
  Not yet verified — do not assert what it hashes.

### C4 — artifact and evidence tables

**Executables** (all 24,753,368 bytes; VA = raw + `0x140000C00`):

| State | SHA-256 | Note |
|---|---|---|
| stock May-2020 3.3.3 | `656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8` | re-verified by hash during the V9 disassembly |
| V5 | `29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535` | rollback target |
| V6 | `f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0` | revert target |
| V7 | `57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571` | Continue |
| V8 | `94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93` | applied on the user machine 2026-08-29 |
| **V9** | `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687` | **current** |

Chain replay: `build_v9_chain.py` applies V2→V8 from the patcher sources and asserts
every hash above before computing V9 — so the V9 hash is arithmetic, not a claim.

**Feat-cache states observed** (`cache\q847rsja8ndx`; all `key=id=-2128831035`):

| When / source | `user_id` | `established` | `conquerer_from_bribir` | `category` | Other |
|---|---|---|---|---|---|
| archived `q847rsja8ndx.txt` | 453496064 | 0 | 0 | 697115649 | `user=152991562`, `heretical_company=1` |
| archived `q847rsja8ndx_v6_secondlook.txt` | 84696387 | 4 | 1 | -1991027533 | Bronze peak |
| pasted 2026-08-29 (no-repo chat) | **1179784490** | 4 | 1 | -1991027533 | new `user_id` |
| enumerated 29.08 16:19:51 | 84696387 | 3 | 1 | -852858316 | file SHA-256 `3606E210F48EB16B668B06E24942B545E65B11531F28F28D08FF9FDDE404601F` |
| enumerated 29.08 20:32:18 | 84696387 | 3 | 1 | -852858316 | `Length 751` |
| other pasted blocks | **1148909174** | 4 / 2 | 1 | -1991027533 / 1474319405 | new `user_id` |

**Save inventory** — these ten saves live **only on the user's machine**; they were
never uploaded and are **not** in this repo. `13_save_and_cache/saves/` holds five
*different* saves (`Bosnia1173_03_03`, `Bronzeman_kulin_bosnia`,
`Bronzeman_pavao_croatia`, `Croatia1278_01_02`, `Croatia1278_01_10`). The table
below is a read-only ZIP scan of `global_*` reported in the chat, kept as evidence:

| File | Bytes | Modified | `global_established` | `global_conquerer_from_bribir` |
|---|---:|---|---|---|
| `Bronzeman_pavao_croatia.ck2` | 4,190,583 | 29.08 16:03:16 | 2.000 | 1.000 |
| `Croatia1278_01_03.ck2` | 4,242,851 | 29.08 16:05:42 | 4.000 | 1.000 |
| `Croatia1278_01_04.ck2` | 4,248,746 | 29.08 16:16:08 | 4.000 | 1.000 |
| `Bronzeman_pavao_croatia2.ck2` | 4,190,513 | 29.08 16:19:17 | 2.000 | 1.000 |
| `Croatia1278_01_02.ck2` | 4,221,738 | 29.08 16:20:02 | 3.000 | 1.000 |
| `Croatia1278_01_06.ck2` | 4,286,556 | 29.08 16:49:25 | 3.000 | 1.000 |
| `Croatia1278_01_08.ck2` | 4,317,958 | 29.08 16:50:15 | 3.000 | 1.000 |
| `Bronzeman_pavao_croatia3.ck2` | 4,190,690 | 29.08 16:51:59 | 2.000 | 1.000 |
| `Croatia1278_01_02(2).ck2` | 4,222,239 | 29.08 16:52:28 | 3.000 | 1.000 |
| `Croatia1278_01_04(2).ck2` | 4,246,852 | 29.08 16:54:51 | 3.000 | 1.000 |

`established` is state-based (count of landed dynasty members) so it legitimately
moves 4 → 3 → 2; the **cache stores the peak**, the save stores the current value.

**Cumulative patch map — new rows (V8, V9):**

| Raw offset | VA | Stock bytes | V8/V9 bytes | Purpose |
|---|---|---|---|---|
| `0x00666546` | `0x140667146` | `74 0D` | `90 90` (V8+) | `DailyUpdate` always calls `UpdateFeatProgress` |
| `0x007B786B` | `0x1407B846B` | `75 05` | `EB 05` (V8+) | `CalcShouldTrackFeatProgress` ignores `IsActiveForPlaythrough` |
| `0x007B7906` | `0x1407B8506` | `E8 85 71 8F FF` | `B0 01 90 90 90` (V9) | force the final eligibility gate to true |

### C5 — verified calculations (rule 2)

| Claim | Recomputation | Result |
|---|---|---|
| `VA = raw + 0x140000C00` | `0x7B7906 + 0x140000C00` | `0x1407B8506` ✅ |
| pre-patch bytes at the V9 site are `call 0x1400AF690` | rel32 = `0x1400AF690 − (0x1407B8506+5)` = `0xFF8F7185` → `E8 85 71 8F FF` | ✅ exact match |
| V9 is length-preserving | 5 bytes → 5 bytes (`B0 01 90 90 90`) | ✅ |
| `74 0D` at VA `0x140667146` jumps to `0x140667155` | `0x140667146 + 2 + 0x0D` | ✅ matches the disassembly |
| Trace ASLR base | six independent `rip − module_offset` values | all `0x00007FF7B6EE0000` ✅ |
| Stale Continue breakpoints | `0x7FF7B78C4970/…5500/…678B − base` | `+9E4970`, `+9E5500`, `+9E678B` ✅ (`+9E678B` = the V7 site, raw `0x009E5B8B`) |
| **`DAILY_GATE` breakpoint offset** | `module+0x666146` → VA `0x140666146` → **raw `0x665546`**; the patched `je` is raw `0x666546` = `module+0x667146`. Script typo: `666146` instead of `667146` | ⚠️ **`0x1000` off.** The bytes at raw `0x665545` are `48 89 BD 48 06 00 00` = `mov qword ptr [rbp+0x648], rdi` (VA `0x140666145`, 7 bytes), so raw `0x665546` is byte 2 of that instruction — an INT3 there still fires, with `rip` reported at the INT3 byte. It is inside a **different, larger function** (region A, VA ≈ `0x140665EF8`), and the xref scan proved region A does **not** call `UpdateFeatProgress` directly. So the logged `al=A0` / `al=80` are pointer bytes, not a flag, and the breakpoint proves only "this big function ran during load" — it does **not** prove the V8 byte at raw `0x666546` was in place, nor which caller entered `UpdateFeatProgress`. See `CONTRADICTIONS.md` §13 |
| payload `event_time_end` | `1893499200` | 2030-01-01 12:00:00 UTC ✅ (matches "push ends to 2030") |
| safe ceiling / INT_MAX | `2147310847` / `2147483647` | 2038-01-17 03:14:07 / 2038-01-19 03:14:07 ✅ ("hard wall 2038-01-17/19") |
| cache `key`/`id` | `2166136261 − 2³²` | `-2128831035` ✅ FNV-1a 32-bit offset basis |

### C6 — persistence model (now complete)

| Layer | Where | Scope | Lifetime |
|---|---|---|---|
| Challenge progress | `global_<featkey>` script variables inside the `.ck2` save | per save | as long as the save |
| Peak / "Best Result" | `Documents\Paradox Interactive\Crusader Kings II\cache\q847rsja8ndx` (`feat_progress_storage`) | per local `user_id`, **not** per save | until the file is removed |
| In-game counters | `CRulerFeatTracker` vectors `+0x108` (current) / `+0x120` (cached) | per process | re-hydrated by `UpdateFeatProgress` — the thing V9 unblocked |

Symbols (Linux 3.3.3, for reference): `CFeatProgressStorage::ReadCachedProgress`
`0xF46958`, `CacheProgress` `0xF460BC`, `SetNewProgress(CString,int,bool,bool)`
`0xF47220`, **`SetCachedProgressIfHigher(CString,int)` `0xF47534`** (peak semantics),
`ReadProgressFromKeyValueStorage` `0xF4731A`, `Update` `0xF46722`,
`CheckNeedsCache`, `WipeFeats` `0xF45F8A` (never call).

---

## D. ATTEMPTS & DEAD ENDS

| Direction | Verdict | What it proved |
|---|---|---|
| V8 = bypass both `IsActiveForPlaythrough` gates | ❌ | the gates were not the cold-load block; forcing the update with an unrecognised playthrough zeroed the display |
| "cache was wiped" | ❌ | cache non-zero before/after a confirmed-V8 cold load |
| "save lacks globals" | ❌ | ten saves carry the values |
| "wrong binary / BAT never applied" | ❌ | `State: v8`, `SHA-256: 94d6fb40…` on the game's own exe |
| Manual launch-mode x64dbg | ❌ (method) | stale DB breakpoints bury the signal; **attach mode + a clearing script** is the working method |
| Unpatched `RestoreDeviceObjects` gate as V9 target | 🟡 not needed | `RESTORE_GATE al=1`, `UpdateFeatProgress` entered — left unpatched, correctly |
| Alternative V9 (A): raw `0x007B7854` — force the global MJ flag so `CalcShouldTrackFeatProgress` returns 1 immediately | 🟡 recorded, not used | more invasive: also skips ruler-info, date and mode-byte checks |
| Chosen V9 (B): raw `0x007B7906` force the gate result | ✅ | surgical, robust against both candidate sub-causes, keeps every other safety check |

**Banned:** `a6cb92b8…`, `wipe_feats`, unguarded offset pokes, redistributing
executables. **Abandoned:** `0074af70…` (disproof: fresh Pavao Bronze without it),
V8-alone (disproof: this part, B3).

---

## E. OPEN THREADS & FUTURE DIRECTIONS

1. **Medal tier / repeat notification (the user's question).** Not a defect — see
   `03_analysis/FEAT_CACHE_PEAK_TIER_ICON.md`. Optional experiment: back up and
   rename the cache file, then reload the first-day save; the medal should drop to
   "not earned" and the next Bronze threshold crossing should fire
   `FEAT_LEVEL_1_COMPLETE_LOG` again. Cost: the recorded "Best Result" values.
2. **`user_id` instability re-opened.** Four values, identical feat vectors
   (`CONTRADICTIONS.md` §12). If the medal/best-result display ever behaves as if
   progress vanished, check `user_id` in the cache first.
3. **At ingest, `MJ_V9_CLEAN_TRACE.txt` still armed `DAILY_GATE` at `+666146`.** The V9 session
   intended `+667146`. Harmless (same function) but it should be corrected before
   the trace is used to prove anything about raw `0x666546`
   (`CONTRADICTIONS.md` §13).
4. **`RUN_APPLY_CK2_MJ_V9_INLINE.ps1`** was promised in chat and never written;
   reconstructed verbatim from the log during this ingest.
5. **`0x17A36D62`** — identify it (string hash? special-event id?) and find the
   vtable that reaches `0x14080F370`. Only worth doing if a cleaner-than-V9 fix is
   wanted.
6. **Optional V9 clean trace** — confirm `V9_GATE_FORCE` fires at
   `CK2game.exe+7B8506` and `CALC_RETURN_PATH al=1` on a cold load. The user's
   in-game result already settles the functional question; this is belt-and-braces.
7. Unchanged backlog: **C25** launcher Continue; C09–C12, C13, C17; Featured Rulers;
   local reward gallery; the five missing rulers (Liao, Basarab, Mindaugas, Botstain,
   Stefan).
8. **Maintenance deadlines:** payload `event_time_end` = 2030-01-01 12:00 UTC;
   regenerate before **2030-01-03**; never use INT_MAX (`+172800` overflows to 1901).

**Prepared first message for a future session (verbatim intent):**

> Baseline is V9 `61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687`
> and the cold-load feat defect is fixed: feats survive soft and hard quits and
> increase during play. Revert target V8 `94d6fb40…`, then V7 `57b18e43…`. Open
> items are cosmetic/secondary: the medal shows the account-wide peak from
> `cache\q847rsja8ndx` (see `FEAT_CACHE_PEAK_TIER_ICON.md`), launcher Continue (C25),
> and the Phase-3 polish list. Never run `wipe_feats`; launch `CK2game.exe` directly;
> test offline.

---

## F. CONTEXT

**Environment.** `C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe` (24,753,368 B),
payload `<game>\gfx\monarchs` (`fc6ec025…`, 101,949 B, 11 rulers / 33 challenges),
tools in `C:\Users\UZWERG\Desktop\ck2check`, x64dbg at
`C:\Users\UZWERG\Desktop\x64 dbg\release\x64\x64dbg.exe` (database
`…\db\CK2game.exe.dd64`, load 1703 ms), saves and cache under
`C:\Users\UZWERG\Documents\Paradox Interactive\Crusader Kings II\`. Offline;
`[S_API FAIL] SteamAPI_Init() failed` is expected. UI and PowerShell output are
Russian (`Точка останова … установлена`, `Поток … создан`, `Строка отладки: «…»`);
PowerShell errors arrive in Russian too.

**Benign noise fingerprints** (do not chase): `Kernel Debug[fixedwindow.cpp:1246]
Warning: Atempt to access nonexistant subwindow ruler / start_notification in window
2 open`; `internationalizedtext.cpp:1736/1748 Failed to find text key`
(`NUM`, `LIST`, `MAX`, `HEIR`, `DATE`, `TARGET`, `RELIGION`, `PRESTIGE`, `ACTIONS`,
`DISCONTENT_*`, `*_COALITION_*_INFAMY`); `Memory[frontend.cpp:1064] Memory used by
graphics 0MB`; `character.cpp:1624 CCharacter::~CCharacter -> Deleting playerdata for
char #470001`; TLS-callback breakpoints in `inputhost.dll` /
`windowmanagementapi.dll` / `libvorbis*` / `libogg`; `0x406D1388` thread-name
exception on launch.

**Method lessons / error ledger for this part**

| Wrong claim | Correction | How caught |
|---|---|---|
| "Identity drift is refuted" (STATUS, 2026-08-27) | four distinct `user_id` values exist for the same logical cache | cross-reading two raw logs from different sessions |
| `V9_COLD_LOAD_FEATS_FIX.md`: "`DAILY_GATE` (raw `0x666546`) executed" | the breakpoint was at raw `0x665546`; it proves the *function* ran, not the patched byte | VA↔raw conversion of the breakpoint offset |
| V9 session: "the `DAILY_GATE` offset was fixed in V9" | Delivered file still said `+666146`; canonical helper corrected to `+667146` and re-hashed 2026-08-31 | reading the delivered file; later repository repair |
| V9 session: "saved as `RUN_APPLY_CK2_MJ_V9_INLINE.ps1`" | no such file existed | tooling-integrity check (rule 11) |
| Earlier: "the `.bat` flicker is only a line-ending problem" | it is also cmd.exe mis-parsing PowerShell parentheses inside `if ( … )` | reading `APPLY_CK2_MJ_V8.bat` line 34 |
| Earlier: V8 would restore the main-menu display | V8 zeroed it | the user's own report |

**Evidence inventory.** `x64dbg logs.txt` = the cold/warm `[MJ]` bursts (the single
most important artifact of this part). `another raw log.txt` = cache/save forensics
and the V8 confirmation. `one more raw log.txt` = the V8 regression and the `.bat`
root cause. `first raw log.txt` / `another other raw log.txt` = PR #13/#14 landing
and the handoff. `last log (for now).txt` = the disassembly that produced V9.

**Info-preservation audit.** Everything above now lives by content in
`01_research_archives/` (this file), `03_analysis/` (`V9_COLD_LOAD_FEATS_FIX.md`,
`V9_RUNTIME_RESULTS.md`, `FEAT_CACHE_PEAK_TIER_ICON.md`,
`RAWLOG_NETNEW_EXTRACTS.md` §11), `04_test_guides_and_reports/`,
`05_patches_and_scripts/` and `13_save_and_cache/README.md`. The three byte-identical
duplicates inside `last log/` (the `01a044b2` patch, `MJ_V8_CLEAN_TRACE.txt`,
`RUN_MJ_V8_CLEAN_TRACE.bat`) are already archived elsewhere; the raw chat exports are
kept in place but ledgered as dissected in `12_raw_chat_logs/INDEX.md`.

### Merge notes

- **New:** V8 runtime disproof, the V9 gate chain and fix, the V9 runtime verdict,
  the activation-function lead (§C3), the four `user_id` values, the ten-save
  inventory, the `.bat` parenthesis root cause, PR #13/#14/#15 and their merge
  hashes, the `DAILY_GATE` offset error, the medal/peak explanation.
- **Restated (already canonical elsewhere):** stock/V5–V7 hashes, the payload hash,
  the VA↔raw rule, the banned/abandoned register, the environment constants.
- **Conflicts:** recorded in `03_analysis/CONTRADICTIONS.md` §12 (identity drift) and
  §13 (trace breakpoint vs patch site), not silently resolved here.
