# How to run the preflight check — step by step

This check is **read-only**. It does not patch, launch, move, or delete anything.
It only looks at files and prints a report. It cannot break your game.

It answers four questions in one go:

1. Which `CK2game*.exe` files exist, and **exactly which patch level each one is**
   (stock / V1 / V2 / V3 / V4 / V5 / **V6** / banned).
2. Is the `gfx\monarchs` payload present and correct?
3. Where are your real save / cache / log folders?
4. What do your feat counters say right now — and has the cache identity changed?

---

## The easy way (recommended)

### Step 1 — get the two files onto Windows

You need these two, and they must keep their relative positions:

```text
RUN_PREFLIGHT.bat
ps1\preflight_ck2_mj.ps1
```

The simplest approach is to download the whole
`ALL-MY-LOGS-SO-FAR\05_patches_and_scripts` folder and keep it intact — then
`RUN_PREFLIGHT.bat` and the `ps1` subfolder are already arranged correctly.

If you prefer to copy just the two files, put them like this, for example on the
Desktop:

```text
C:\Users\UZWERG\Desktop\ck2check\RUN_PREFLIGHT.bat
C:\Users\UZWERG\Desktop\ck2check\ps1\preflight_ck2_mj.ps1
```

(Putting `RUN_PREFLIGHT.bat` and `preflight_ck2_mj.ps1` side by side in the *same*
folder, with no `ps1` subfolder, also works — the .bat checks both places.)

### Step 2 — unblock the files (Windows marks downloads as untrusted)

For **each** of the two files:

- right-click the file → **Properties**
- if you see an **Unblock** checkbox at the bottom, tick it
- click **OK**

If there is no Unblock checkbox, there is nothing to do — skip it.

### Step 3 — double-click `RUN_PREFLIGHT.bat`

That is it. A black window opens, prints the report, and waits.

If Windows SmartScreen shows a blue "Windows protected your PC" box:
click **More info** → **Run anyway**. (It says this about every unsigned .bat file.)

### Step 4 — send me the output

Right-click the black window's title bar → **Edit** → **Select All**, then
**Edit** → **Copy**, and paste it to me. Or just photograph the screen.

---

## If your game is somewhere else

The .bat defaults to `C:\Users\UZWERG\Desktop\SteamCrusader`. To check a different
folder, **drag your CK2 game folder onto `RUN_PREFLIGHT.bat`** and drop it. The
dragged path overrides the default.

---

## The manual way (if you would rather use PowerShell directly)

1. Press **Start**, type `powershell`, and click **Windows PowerShell**.
2. Paste these two lines, pressing Enter after each. Change the paths if needed:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
& "C:\Users\UZWERG\Desktop\ck2check\ps1\preflight_ck2_mj.ps1" -GameRoot "C:\Users\UZWERG\Desktop\SteamCrusader"
```

`Set-ExecutionPolicy -Scope Process Bypass` applies **only to that one window** and
reverts the moment you close it. It changes nothing permanently.

---

## Reading the result

**Section 2 — EXECUTABLES.** This is the important one.

```text
  CK2game.exe   <-- this is the one Windows launches by default
    sha256  : f5b7dfd6...
    state   : V6 CURRENT BASELINE (runtime-proven)      <-- green = good
```

Every patch state is the same 24,753,368 bytes, so **only the hash tells them
apart.** If the report shows `CK2game.exe` as *stock* or *V5* while a separate
`CK2gameV6.exe` is the good one, then the game you have been launching is not the
patched one. Fix: copy `CK2gameV6.exe` over `CK2game.exe`, or launch
`CK2gameV6.exe` directly.

**Section 6 — FEAT CACHE.** Shows the identity fields and any non-zero counters:

```text
    user_id  = 84696387
    category = -1991027533
    NON-ZERO FEATS: conquerer_from_bribir=1, established=4
```

The script remembers this between runs. To test whether your progress identity is
stable:

1. run the preflight,
2. play a short session and exit,
3. run the preflight again.

If it reports **`user_id CHANGED`**, that alone can make earned progress look
reset — and that becomes the thing to fix.

**Section 7 — VERDICT.** Plain-language list of anything suspicious.

---

## Things worth knowing

- The **"Challenges: Disabled"** gauntlet tooltip is a known **cosmetic** bug
  (case C17). Bronze has been earned with it on screen. It is not your problem.
- Never run the console command `wipe_feats` — it is irreversible.
- Keep the game offline for these tests, as before.
