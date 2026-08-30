# Contradictions & corrections register

The v2 working rules require recording both sides of every documented
disagreement plus a verdict, so a future session does not re-litigate settled
questions or trust a later-retracted claim. Entries are grouped by topic.
"Verdict" names the canonical source.

---

## 1. Does CK2 version 3.3.5.1 exist?

- **Claim A (Part 1, primary evidence):** the user's current build fingerprints
  as 3.3.5.1, build string `2021-09-21 16:13:22 +0200`, from string dumps.
- **Claim B (Part 2, S14):** "there is no CK2 version 3.3.5.1"; "CK2's last
  official patch was 3.3.3 (Sept 2020)."
- **Verdict:** **A is correct.** The current build is 3.3.5.1
  (`a0cc8e92…`). Claim B conflates the May-2020 3.3.3 patch target with the
  2020-09-02 *retirement update* and overlooks later patches. Canonical:
  `EXECUTABLE_IDENTITIES.md`, Part 1 C2.
- **Related:** 3.3.5.1 is nonetheless **not** a viable byte-patch target — the
  GameSparks/payload-parser/`gs_virtual/feat_script` loader was removed there.
  That is a separate conclusion from its existence.

## 2. Where does the Windows local loader read the payload?

- **Claim A (early Part 2 report):** the stub reads
  `%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\test.dds`.
- **Claim B (Part 1 / V6 apply log):** the base path is `gfx\` in the **game
  directory**; the deployed payload is `<game folder>\gfx\monarchs`
  (extensionless).
- **Verdict:** **B is correct.** A was a callback misread (the function was a
  path-builder for `gfx`, not a Documents getter). The username-cache routine
  also collides on `gfx\test.dds`, which is why the payload must be `gfx\monarchs`
  via the v2 LEA redirect. Canonical: Part 1 C1/C5, Part 2 Merge note 1.

## 3. How should the loader filename be patched?

- **Patch B (Part 2 early):** overwrite the `test.dds\0` string at
  `0x010d55d8` with `monarchs.\0` (9 bytes, length-preserving).
- **v2 (father session, canonical):** change the LEA displacement at
  `0x00d73e1a` (`ba 23 36 00` → `21 fc 32 00`) to point the loader at the
  existing `monarchs_journey` string, requiring **no .rdata string surgery**.
- **Verdict:** **v2 is canonical.** Patch B is a recorded superseded
  alternative; the organized patcher set uses v2. (Part 1's "10-byte over
  9-byte string patch" characterization refers to an even earlier unsafe
  iteration; the exported Patch B was already length-safe but still superseded.)

## 4. INT_MAX timestamps

- **Early attempt:** set `event_time_end = 2147483647` (INT_MAX) to "never
  expire."
- **Correct model:** visibility is `now < int32(event_time_end + 172800)`;
  INT_MAX + 172800 overflows signed-32 to a 1901 date, instantly hiding the
  panel. Use `1893499200` (2030-01-01); safe ceiling `2147310847`; regenerate
  before 2030-01-03.
- **Verdict:** INT_MAX is **harmful**, not a fix.

## 5. "V6" — which build?

- **Part 2 "V6":** 18-patch build with a code-injection trampoline
  (`a6cb92b8…`) that corrupted save parsing — **banned**.
- **Part 3 / STATUS "V6":** 5 narrow save-selection branches
  (`f5b7dfd6…`) — **the current runtime-proven baseline**.
- **Verdict:** Two different builds share the label. Always key by SHA. The
  successful V6 is the baseline; the trampoline V6 is banned. Canonical:
  `BANNED_ARTIFACTS.md`, Part 3 naming table.

## 6. "V7" — which effort?

- **Raw logs `fourth`/`(5)` "V7":** two-branch live-feat-update patch
  (`0074af70…`), never shipped, premise disproven by the Pavao Bronze playtest.
- **STATUS / current "V7":** the **Continue-button enable fix** (no patcher
  yet), seeded by the 2.6.1.1 PDB work.
- **Verdict:** different efforts. The Continue-V7 is the real target; the
  feat-V7 is abandoned. Canonical: Part 3 D1, `CONTINUE_SEMANTIC_REFERENCE.md`.

## 7. Is feat progress persistence broken?

- **Part 1 cliffhanger:** progress resets to 0/6 after restart → "persistence
  is the remaining bug."
- **Part 2 root cause:** save-reader case for token `0x3816` is a no-op;
  hypothesized as the persistence bug (motivated the banned trampoline).
- **Part 3 / V6 evidence:** V6 `f5b7dfd6…` (which never touches the reader)
  restores saved globals (3 March / 1/6) and peak progress persists via the
  local cache `q847rsja8ndx`; a fresh Pavao campaign grants Bronze and resumes
  after full restart.
- **Verdict:** **Observable persistence works on V6.** The token-0x3816 no-op
  did not block the restoration path in practice (challenge progress is in
  ordinary script globals + the local cache). The banned trampoline solved a
  problem that did not manifest, using the wrong-direction helper. Canonical:
  Part 3 C3.

## 8. Do feats count real gameplay events?

- **Part 1:** live progress 1/6 (Heretical Courtiers) recorded as working.
- **Part 2 doubt:** the Bosnia "1" might have been Kulin counting himself at
  start; Llywelyn non-counts came from the corrupted V6 run (prove nothing).
- **Part 3 evidence:** Pavao's `global_established` advanced 2 → 4 across the
  first days and Bronze was granted at exactly the payload threshold 4.
- **Verdict:** **feats count real events.** The self-count doubt is retired;
  the Llywelyn data is invalid (corrupted build). Canonical: V6_RUNTIME_RESULTS,
  Part 3 D1.

## 9. The V5 "two saves look identical" symptom

- **Apparent:** after V5, selecting either save showed a 1 January / 0-6
  campaign → looked like the save was corrupt or the wrong file loaded.
- **Actual:** both saves were valid and distinct (different dates, both had
  `global_heretical_company=1`). V5 had patched only the *generic* validator;
  five duplicated account gates in the save-selection layer prevented the
  selected record from being installed (object `+0x368`/`+0x3a8`), so CK2 fell
  back to a fresh 1 Jan setup. The "Game State corrupted" tooltip was a
  secondary state.
- **Verdict:** not corruption; **selection-layer rejection**, fixed by V6.
  Canonical: Part 3 S1–S3, C1.

## 10. Screenshot / AI misreads (method notes, not technical contradictions)

- AI misread the in-game date as "1 Jan 1175"; user corrected: "everywhere 1173."
- Screenshots 224–229 were initially ambiguous (old V3-era setup vs V5 result);
  resolved by a 4-question clarification round.
- **Verdict:** cross-check dates/counters/screen identity with the user before
  theorizing; targeted yes/no questions resolve ambiguous evidence.

## 11. Native Linux runtime

- **Occasional phrasing implies Linux was run/tested.**
- **Fact:** Native Linux CK2 was **never executed** (user is Windows-only); all
  Linux findings are static disassembly used as a symbol map.
- **Verdict:** Linux is a reference, not a runtime-tested platform.

## 12. Feat-cache `user_id` — "identity drift is refuted" is withdrawn

- **Claim (canonical):** `FEAT_RESET_QUIT_VS_RESIGN.md` line 22 states
  "**Identity drift is refuted.** `user_id=84696387` is identical to the archived
  value," on the strength of one capture.
- **Conflict:** four distinct `user_id` values are now on record for the *same* cache
  file (`…\cache\q847rsja8ndx`), several with **identical** feat vectors:

| `user_id` | `established` | `conquerer_from_bribir` | `category` | Source |
|---|---|---|---|---|
| `453496064` | 0 | 0 | `697115649` | `13_save_and_cache/q847rsja8ndx.txt` (archived) |
| `84696387` | 4 → 3 → 3 | 1 | `-1991027533` / `-852858316` | `13_save_and_cache/q847rsja8ndx_v6_secondlook.txt`; enumerated 29.08 16:19:51 and 20:32:18 |
| `1179784490` | 4 | 1 | `-1991027533` | pasted by the user 2026-08-29 (`another raw log.txt`) |
| `1148909174` | 4 / 2 | 1 | `-1991027533` / `1474319405` | pasted blocks, same log |

- **Verdict:** the single-capture refutation does not hold. What *is* still true is
  that `user_id` was stable **within** the session that produced it, and that the
  preflight's identity check agreed at that time. What is not established is that
  `user_id` is stable across boots/installs. **Do not assert either way.**
  Practical rule: if the medal or "Best Result" ever reads as if progress vanished,
  read `user_id` from the cache first. Tracked as an open item, not a resolved case.

## 13. The `DAILY_GATE` trace breakpoint is not at the patched byte

- **Claim:** `V9_COLD_LOAD_FEATS_FIX.md` says the trace's `DAILY_GATE`
  (raw `0x666546`) executed, and the V9 session claimed the offset had been corrected.
- **Fact:** the script arms `bp CK2game.exe+666146` → VA `0x140666146` → **raw
  `0x665546`**. The V8/V9-patched `je` is at raw `0x666546` = `+667146`. That is a
  `666146`-vs-`667146` typo, off by `0x1000`.
- Raw `0x665546` is the **second byte** of a 7-byte `mov qword ptr [rbp+0x648], rdi`
  (VA `0x140666145`, bytes `48 89 BD 48 06 00 00`) inside a *different* function
  (VA ≈ `0x140665EF8`) which the xref scan proved does **not** call
  `UpdateFeatProgress`. An INT3 there still fires, with `rip` reported at the INT3
  byte — which is why the log shows `al=A0` and `al=80` (pointer bytes, not a flag).
- **Still true:** the trace proves `UpdateFeatProgress` was entered, and the four
  breakpoints that matter (`UPDATE_ENTRY`, `RULER_INFO_CHECK`, `CALC_FAIL_PATH`,
  `CALC_RETURN_PATH`, `CALC_RESULT`) are all correctly placed and unaffected. The V9
  conclusion stands on those, not on `DAILY_GATE`.
- **Not true:** that the V8 byte at raw `0x666546` was exercised, or which caller
  entered `UpdateFeatProgress`.
- `MJ_V9_CLEAN_TRACE.txt` **still carries the typo** (verified 2026-08-30).
  Fixing it changes the file's SHA-256, which `README_MJ_V9_CLEAN_TRACE.md`
  publishes — fix and re-hash together, never silently.

## 14. What V8 did to the display, and what it did to the cache

- **Claim (written at the time):** V8 "calculated 0 progress for all 33 challenges and
  pushed those 0s into the local feat cache (`cache/q847rsja8ndx`), **wiping out**
  the main-menu display."
- **Fact:** the very next message in the same log is the user's paste of that cache
  file, and it still reads `conquerer_from_bribir=1` / `established=4`
  (`user_id=1179784490`). The cache was **not** wiped.
- **Verdict:** V8 pushed zeroes **to the display**, not to the cache. The corrected
  wording from the same session ("pushed those 0s to the display") is canonical.
- **Related, weaker claim:** that the whole cold-load defect was caused by
  `special_event` being blank at `gameState+0x598`. The clean trace showed the
  ruler-info check passing (`rax=00000222A2B27050`, `zf=0`) and
  `IsActiveForPlaythrough` returning **true** at the restore caller
  (`RESTORE_GATE al=1` on the cold burst). It remains a reasonable description of why
  the *display* went blank under V8; it is **not** what was measured for the tracking
  failure. The measured failure is the final gate at raw `0x007b7906`.
