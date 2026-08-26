# Save files & local feature cache

Two things live here: real `.ck2` save games and the local
`q847rsja8ndx` feature/achievement cache token.

## Saves (`saves/`)
Full Ironman/Bronzeman save binaries, rescued 2026-08-26 from
`things parent AI asked to upload/` and `v6 second look/save games/`.

| Save | Date | Player | Notes |
|---|---|---|---|
| `Bosnia1173_03_03.ck2` | 1173.3.3 | Doux Kulin of Bosnia | pairs with `Bosnia1173_03_03.txt.meta` |
| `Bronzeman_kulin_bosnia.ck2` | — | Kulin (Bronzeman) | pairs with `Bronzeman_kulin_bosnia.txt.meta` |
| `Bronzeman_pavao_croatia.ck2` | — | Pavao (Bronzeman), Croatia | v6 "second look" run |
| `Croatia1278_01_02.ck2` | 1278.1.2 | Croatia | v6 second look |
| `Croatia1278_01_10.ck2` | 1278.1.10 | Croatia | v6 second look |

The two `.txt.meta` files here are the CK2 meta payloads that accompany the
first two saves.

## Cache token
`q847rsja8ndx` is the local Monarch's Journey feature-cache. Two **distinct
states** are kept (do not overwrite one with the other):

| File | user_id | heretical_company | established | category |
|---|---|---|---|---|
| `q847rsja8ndx.txt` | 453496064 | 1 | 0 | 697115649 |
| `q847rsja8ndx_v6_secondlook.txt` | 84696387 | 0 | 4 | -1991027533 |

`_v6_secondlook` is the later "second look" Pavao Bronze run state
(`established=4`, `conquerer_from_bribir=1`) — evidence that Bronze progress
persisted across boots.
