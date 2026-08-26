# CK2 3.3.3 Linux Monarch's Journey loader findings

Analyzed binary: `ck2` from the May 2020 Linux depot

- Size: `27,729,272` bytes
- SHA-256: `99776be0b9b72b06a83ac7606e8df553dfcec4b4ce25ee40c7d1961ea12791a6`
- Format: ELF 64-bit x86-64

## Local loader

The Linux build always constructs `CNullGameSpark`. Its constructor immediately invokes `LoadLocalCache()` through virtual slot `+0x20`.

`CNullGameSpark::Download()`, `Reconnect()`, and `Update()` are no-ops. `GetHasFetchedPropertySet()` unconditionally returns true.

`LoadLocalCache()` calls the game's storage callback with:

- `GameSparksStorageLocation = 0`
- filename `monarchs.txt`

Storage location 0 resolves via `CDirectorySettings::GetOriginalDirectory(0x52)` to:

```text
common/monarchs_journey
```

The final path is therefore:

```text
common/monarchs_journey/monarchs.txt
```

It is the **original game directory**, not a mod override.

The loader accepts ordinary plaintext JSON. It can also recognize the game's optional XOR-obfuscated format, but obfuscation is not required.

## JSON schema and visibility gate

The root is parsed directly; no GameSparks response wrapper is expected. The decisive root fields are:

```json
{
  "can_see_highlighted_rulers": 1,
  "scheduled_rulers": [ ... ]
}
```

`can_see_highlighted_rulers` is copied into GUI-version slot 14, corresponding to `highlighted_ruler_version`. The databases and frontend view are instantiated only when this value is greater than zero.

Each element of `scheduled_rulers` is parsed for:

- `highlighted_ruler`
- `add_localisation`

The supplied snapshot has the expected structure.

## Frontend creation gates

The frontend constructs `CHighlightedRulerView` only when all of these are true:

1. `GetGuiVersion(HIGHLIGHTED_RULER)` is greater than zero.
2. `highlighted_ruler_window_main` and `upcoming_event_window` exist.
3. A current highlighted-ruler record exists.
4. `CalcCurrentHighlightedRulerViewState(...)` returns a nonzero state.

No POPS, Titus, Paradox-account, or login check occurs in this visibility path.

## Expiry calculation and the INT_MAX failure

With no upcoming event (the Linux local implementation always returns null), the state calculation is effectively:

```text
if current_ruler is null:
    return hidden

cutoff = signed_32bit(current_ruler.event_time_end + 172800)
return visible if current_unix_time < cutoff, otherwise hidden
```

The extra `172800` seconds are two days.

Using `2147483647` (`INT_MAX`) overflows the signed 32-bit addition:

```text
2147483647 + 172800 -> -2147310849
```

That corresponds to a date in 1901 after sign extension, so the view is treated as expired immediately. This conclusively explains why the `INT_MAX` reactivation payload failed.

The existing 2030 test value is safe:

- `event_time_end = 1893499200` = 2030-01-01 12:00 UTC
- visible cutoff = 2030-01-03 12:00 UTC

The largest mathematically safe expiration is `2147310847`, but a comfortably earlier date such as 2030 or 2037 should be used.

## `FEATURED_RULER_NOT_SUPPORTED_LINUX`

The localization key has one code reference, inside `CPdxLauncherGUI::UpdateTooltip()` for the launcher's Continue button. It is not referenced by the highlighted-ruler database or frontend creation gates and is not a global Linux disable branch.

## Consequences

- Native Linux 3.3.3 should show the interface with the supplied schema and a non-overflowing future timestamp.
- The previous Linux failure was not actually tested natively; the user only possesses the Linux depot on Windows.
- Windows 3.3.2/3.3.3 still needs separate executable analysis. The likely Windows problem is selection of the real, now-dead GameSparks implementation instead of `CNullGameSpark`.
- `FAILED TO FETCH FROM TITUS` concerns account-linked reward synchronization, not initial interface visibility.
