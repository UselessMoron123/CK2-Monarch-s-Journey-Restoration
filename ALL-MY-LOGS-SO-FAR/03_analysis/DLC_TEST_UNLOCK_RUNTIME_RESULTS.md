# V9 payload DLC-test unlock — runtime results

Date: 2026-08-31. Baseline: V9 executable plus the guarded payload-only removal of
four `required_dlcs` declarations (`dlc007` for Mordechai, Shajar, and Arwa;
`dlc024` for Louis/Louise of Aquitaine).

## User verdict

- The payload edit removes the initial grey/DLC-marked Play obstruction.
- Choosing the three Muslim rulers leads to an **immediate game over** on this
  DLC-less installation. This is the expected downstream CK2 restriction when a
  Muslim ruler is started without the official gameplay DLC; removing a payload
  declaration does not install or emulate DLC.
- Some challenge values are nevertheless calculated before game over. Existing
  provinces, castles, temples, dynasty members, and titles can therefore produce
  non-zero initial values. This proves the feat scripts initialize before CK2 ends
  the unplayable campaign; it does not prove the campaign is usable.
- The Aquitaine/French king campaign starts successfully. Raising a vassal duke to
  the required opinion counted correctly.

## Result by payload requirement

| Requirement | Ruler(s) | Result |
|---|---|---|
| `dlc007` | Mordechai al-Dawla, Shajar al-Durr, Arwa of Yemen | Play gate bypassed, then immediate game over; initial score calculation may occur |
| `dlc024` | Louis/Louise of Aquitaine payload entry | Campaign starts; `why_dont_you_love_me` live count confirmed |

## Clarification of two apparently missed conditions

### Mordechai: opinion versus kills

The payload does **not** contain a challenge to make Mongols like the player.
Mongols occur only in `secret_stays_with_me`, a kill challenge: Mongol-culture kills
score one point, Muslim-religion kills score one point, a Mongol Muslim can score two,
and a hidden murder can add another point.

The opinion challenge is `peace`. It counts **direct vassals** with at least 60 opinion
only when their public religion differs from the player's religion:

```text
any_vassal
  prisoner = no
  opinion of ROOT >= 60
  religion != ROOT religion
```

Thus a mayor/burgher at 62 does not count merely for being a burgher or Mongol. They
must be a non-prisoner direct vassal and openly follow a different religion. In this
test the immediate game over also prevents a reliable later update.

### Llywelyn: English spouses

`love_spoons` counts a living Llywelyn's child only when that child's spouse:

1. has English culture, and
2. personally has at least one claim **or** at least one title.

A historical child and an English spouse are not sufficient by themselves. The spouse
must hold a title or claim. The check is also rooted in character `c_214714` (Llywelyn),
who must still be alive. Gender is not checked despite the prose commonly describing
English wives/girls.

## Conclusion

The payload DLC toggle works as designed and is useful diagnostically. It makes the
`dlc024` ruler playable on this installation, but cannot make Muslim rulers playable
without their official gameplay support. Keep this as an optional experiment rather
than changing the canonical V9 payload.
