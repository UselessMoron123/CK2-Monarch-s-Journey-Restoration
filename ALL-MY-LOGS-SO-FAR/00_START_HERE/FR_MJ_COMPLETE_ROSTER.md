# Featured Rulers + Monarch’s Journey — complete roster reference

Authoritative **content** dump (no images required). Compiled from wiki text the
user pasted (Screenshot 1/2/3 content + full FR/MJ challenge tables) and cross-
checked against `06_game_data/descriptions and challenges.txt` and the live
payload keys in `06_game_data/monarchs`.

**Purpose:** one place to look up every ruler, bio, and Bronze/Silver/Gold
challenge when restoring MJ **or** Featured Rulers later — without re-reading
chat or screenshots.

Related:
- `FEATURED_RULERS.md` — UI/timeline/assets/restore checklist
- `CASES_AND_FINDINGS.md` — engineering status
- `06_game_data/monarchs` — JSON currently loaded by the V6 patch (11 rulers)

---

## 0. Mechanics (both systems)

| | Featured Rulers (pre-3.3) | Monarch’s Journey (3.3+, 2019-10-20) |
|---|---|---|
| Rollout | Remote subset of players; one (or few) highlighted at a time; replaced after a period | Biweekly new ruler; **previous stay playable** via arrows |
| Mode | Bronzeman (Ironman-like) | Bronzeman |
| Challenges | **None** on first six FR; full 3-tier sets from Bohemond onward | Always 3 challenges × Bronze/Silver/Gold |
| Score | Weak / friends leaderboard era | **2 points per tier** earned → CK3 cosmetics |
| Base | Original system | **Built on FR** (same highlighted-ruler machinery) |

### CK3 cosmetic ladder (MJ score) — confirmed

| Points | Reward |
|------:|--------|
| 10 | Wizard’s Beard |
| 20 | The Pageboy |
| 30 | Chaperon |
| 40 | Jester’s Hat |
| 55 | Cone Shaped Hennin |
| 70 | Medieval Mullet |
| **90** | **The Miller** |
| 110 | The Joan of Arc |

(Miller = **90**, not 70 — wiki + this dump agree. Older catalog note corrected.)

Max theoretical if every tier of every challenge on every ruler were earned is
far above 110; the ladder only needs 110 total score.

### Payload status legend
- **IN_PAYLOAD** — key present in current `gfx\monarchs` (V6 restore target, 11 rulers)
- **MJ_WIKI_ONLY** — full MJ entry in wiki/screenshots; **not** in current 11-key file
- **FR_ONLY** — Featured Rulers era; no challenges or short tagline only; not in payload
- **FR→MJ** — appeared in FR list and later got full MJ challenges (may still be missing from payload)

---

## 1. Featured Rulers roster (oldest → newest as listed)

Wiki intro: *characters of special interest, highlighted on main menu with a
custom description, eventually replaced after a period. Must be Bronzeman.*

### 1.1 Hugues de Lusignan — Count of Lusignan — 1066 — Catholic
- **Status:** FR_ONLY · Challenges: **None**
- **Tagline:** Join the Crusades as The Devil of Lusignan!
- **Shots:** `1 ruler.png` (Time Remaining 6 days; Wroth, Brave, Cynical)

### 1.2 Johann “the Blind” — King of Bohemia — 1337 — Catholic
- **Status:** FR_ONLY · Challenges: **None**
- **Tagline:** Become the Blind Warrior of Bohemia!
- **Shots:** `2 ruler…` (Blind, Crusader, Brave, Chaste, Tough Soldier; BLG can corrupt portrait)

### 1.3 Arwa Sulayhid — Sultana of Yemen — 1074 — Shia
- **Status:** FR→MJ · FR challenges: **None** · MJ: full set (§2.8) · **IN_PAYLOAD** as `arwa_yemen`
- **FR tagline:** Discover God’s Will in her lifetime!

### 1.4 Mindaugas — High Chief of Lithuania — 1236 — Romuva
- **Status:** FR→MJ · FR challenges: **None** · MJ: full set (§2.14) · **MJ_WIKI_ONLY** (not in current 11)
- **FR tagline:** Unravel the mystery of this King!

### 1.5 Charles de Anjou — King of Hungary — 1307 — Catholic
- **Status:** FR_ONLY · Challenges: **None**
- **Tagline:** Bring prosperity to the Kingdom of Hungary!
- **Shots:** `5 ruler.png`

### 1.6 Mauregato of Asturias — Count of Astorga — 769 — Catholic
- **Status:** FR_ONLY · Challenges: **None**
- **Tagline:** Secure the title of King and prevent the Kingdom from falling into noble hands!
- **Shots:** `6 ruler.png`

### 1.7 Bohemond d’Hauteville — Prince of Antioch — 1098 — Catholic
- **Status:** FR→MJ (first FR with challenges) · **MJ_WIKI_ONLY**
- **Tagline:** Opportunities fall upon this ruler like autumn rains!
- **Challenges:**

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Bye, Zantium! | Member of your dynasty becomes emperor of Byzantine Empire | — | — | Hold Emperor of Byzantine |
| Blood, sweat & tears | Bohemond personally in as many wars as possible. Crusade counts as two. Simultaneous wars do not count | 6 wars | 10 wars | 15 wars |
| Vassaline! | Landed vassals of your dynasty (progress while playing dynasty) | 10 | 20 | 30 |

### 1.8 Petronilla Jimena — Queen of Aragon — 1157 — Catholic
- **Status:** FR→MJ · **MJ_WIKI_ONLY**
- **Tagline:** Ruler as a child, last of a dynasty, can it be prolonged?
- **Challenges:**

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Arastrong! | Jimena dynasty living members | — | — | 75 living members |
| Arastay! | King titles held by Jimena (extra Jimena kings +1 each) | 3 | 4 | 5 |
| Aragonastop? | Children born to Jimena in her lifetime (live+dead; no out-of-wedlock) | 2 | 4 | 6 |

### 1.9 Llywelyn the Great — Gwynedd — 1195 — Catholic
- **Status:** FR→MJ · **IN_PAYLOAD** `llywelyn_gwynedd`
- **FR tagline:** Develop an Independent Wales and take it further!
- **MJ challenges:** see §2.2 (note small wording diffs FR vs MJ wiki rows)

### 1.10 Tamari — Queen of Georgia — 1184 — Orthodox
- **Status:** FR→MJ · **MJ_WIKI_ONLY**
- **Tagline:** Recreate the Golden Age of Georgia!
- **Challenges:**

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Megaloscheme | Reach Rank IV Saint Basil society (her lifetime) | — | — | Rank IV |
| Hot Tamari | Dynasty children married to King/Emperor tier (or their children) | 2 | 4 | 6 |
| Golden Girls | Dynasty artifacts (live members; no bastards unless legitimized; no alchemy ingredients) | 10 | 30 | 50 |

### 1.11 Nuno — Duke of Porto — 1066 — Catholic
- **Status:** FR→MJ · **MJ_WIKI_ONLY**
- **Tagline:** Become King… just try not to die on the way!
- **Challenges:**

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| King of Portugal | Form Portugal + ≥3 duchies (her/his lifetime) | — | — | Become King of Portugal |
| Money Order! | Simultaneously prosperous counties (directly owned) | 2 | 4 | 6 |
| Ahead of their time | “Colonies”: provinces disconnected from capital, distance ≥400 | 3 | 7 | 13 |

### 1.12 Mihajlo — King of Serbia — 1066 — Catholic
- **Status:** FR→MJ · **MJ_WIKI_ONLY**
- **Tagline:** Unite his nations and become the true King of the Slavs!
- **Challenges:**

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| A Serbian Dream | Keep k_serbia Serbian-cultured; Serbian ruler in ≥1 of Croatia/Hungary/Poland | — | — | Fulfil |
| With or Without Me? | Serbian Duke-tier vassals | 4 | 8 | 12 |
| Papal Support | Catholic bishops opinion ≥60; Pope ≥60 = +2 pts; must be Catholic | 4 bishops | 6 | 8 |

**FR-only with no challenge data ever published (need payload archaeology):**
Hugues, Johann Blind, Charles Hungary, Mauregato.

---

## 2. Monarch’s Journey roster (oldest → newest as listed)

Intro: patch **3.3** (2019-10-20); biweekly adds; arrows keep old rulers; Bronzeman;
Bronze/Silver/Gold = **2 score each**; unlocks CK3 cosmetics (ladder above).

### 2.1 Konan II de Rennes — Duke of Brittany — 1066 — Catholic · **IN_PAYLOAD** `konan_brittany`

**Bio:** Uphill struggle for Brittany; lost father as child; uncle usurped then
chained/imprisoned; threats from William the Conqueror; died to suspectedly
poisoned gloves invading Anjou.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Time Bending | Own listed Breton-sphere provinces (Cornwall, Devon, Anjou, Maine, Mortain, Caen, Leon, Kernev, Poher, Tregor, Domnoea, Broerec, Roazhon, Naoned, Retz) | 10 | 12 | all |
| Gloves Come Off! | Legitimate sons alive (his lifetime; non-legitimized don’t count) | 2 | 3 | 5 |
| Pre-Emptive Self-Defence | Kill de Normandie dynasty (William himself = 2 pts) | 3 | 5 | 7 |

### 2.2 Llywelyn the Great — Duke of Gwynedd — 1195 — Catholic · **IN_PAYLOAD** `llywelyn_gwynedd`

**Bio:** Unified Wales via war + diplomacy; marcher-lord border fights; peace
1234 until death 1240.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Dragon’s Fire | Completely control listed Welsh provinces | — | — | all (no partial) |
| Princes of Wales | Independent; hold k_wales; dynasty vassals duke+; Welsh culture; no unlegitimized bastards. **Note:** females don’t count even with full status of women | 3 | 6 | 9 |
| Love Spoons | Children married to English with titles/claims; both alive; his lifetime | 2 | 3 | 4 |

### 2.3 Saad Mordechai — High Chief of Baghdad — 1289 — Sunni (hist. Jewish physician) · **IN_PAYLOAD** `mordechai_al_dawla`

**Bio:** Jewish bridge for peace in Baghdad; cured Arghun Khan; safe haven for
Jews; hated by Mongol financiers and Muslims; murdered by enemies.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| One of Us! | Not practising Judaism yourself; openly Jewish councillors with ≥10 in job attribute; secret Jews don’t count | 2 | 3 | 4 |
| Peace! | 60+ opinion vassals of another open religion | 5 | 8 | 12 |
| Secret stays with Me | Secret Jew / public Sunni; kill Muslims and Mongols (duel/assassinate/execute); Mongol Muslim = 2; hidden complicity +1; stops if religion changes; his lifetime | 6 | 10 | 16 kill pts |

### 2.4 Konstantinos II — Doux of Samos — 1108 — Orthodox · **IN_PAYLOAD** `konstantinos_samos`

**Bio:** Beauty and bravery; married Theodora Komnene; sebastohypertatos;
founded Angelos dynasty (disastrous imperial line 1185–1204).

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Moving Up | Dynasty king titles | 2 | 3 | 4 |
| Lovely Rule! | Game score | 5000 | 10000 | 15000 |
| Kon Once, Kon Twice… | Alive children of dynasty; his lifetime | 3 | 7 | 10 |

### 2.5 Louis II the Stammerer — King of Aquitaine — 867 — Catholic · **IN_PAYLOAD** `louise_aquitaine`

**Bio:** Physical weakness; crowned twice (2nd by John VIII); three sons kings
of West Francia; last = Charles III the Simple.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| French Toast! | Hold France + Aquitaine de jure complete; form e_francia | — | — | fulfil (no partial) |
| His Unfulfilled Dream | Kill Germanic faith (reformed counts); Norse with Viking/Ravager/Seaking/Sea queen/Berserker/Shieldmaiden = 2 pts; his lifetime | 4 | 7 | 10 kill pts |
| Why Don’t You like Me? | Vassal dukes at +65 opinion; his lifetime | 4 | 6 | 8 |

### 2.6 Shajar al-Durr — Queen of Egypt — 1250 — Sunni · **IN_PAYLOAD** `shajar_egypt`

**Bio:** Second Muslim woman monarch; first of Mamluk Sultanate; short reign;
killed after Aybak murder involvement.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Heiroglyphics! | Dynasty size 80 | — | — | 80 (no partial) |
| Tutan-Kha-Doom! | Kill landed other-dynasty characters; her lifetime | 3 | 4 | 5 |
| Don’t Stop Me Now! | Queen titles while playing female of dynasty | 2 | 3 | 4 |

### 2.7 Paul (Pavao) I Šubić — Duke of Croatia — 1278 — Catholic · **IN_PAYLOAD** `pavao_croatia`

**Bio:** Conquered Bosnia; overlord of Croatia/Dalmatia/parts of Serbia; peace
with Venice; path to Charles I of Hungary.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Conquerer from Bribir! | Hold k_serbia + d_bosnia + d_croatia + d_hum, full de jure | — | — | all 4 (no partial) |
| Established | Landed dynasty members; his lifetime | 4 | 6 | 8 |
| Subic-Stantial Legacy | Great works built | 1 | 2 | 3 |

*(V6 playtest: Bronze on **Established** at 4 — shot 256 / cache `established=4`.)*

### 2.8 Arwa Sulayhid — Sultana of Yemen — 1074 — Shia · **IN_PAYLOAD** `arwa_yemen`

**Bio (MJ long form):** Noble Lady; first woman *hujja*; 68-year reign;
economy, schools, mosques.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Long Live the Queen! | Hold Sultanate of Yemen full de jure 100 years | — | — | 100 years (no partial) |
| God’s Will Be Done | Temples in realm; her lifetime | 5 | 8 | 12 |
| Dawn of a New Da’is! | Hindus → Shia via character interaction only; her lifetime | 2 | 4 | 6 |

*(Aux events LT.62001/62002 track Arwa conversion flags.)*

### 2.9 Harald IV Hardrade — King of Norway — 1066 — Catholic · **IN_PAYLOAD** `harald_norway`

**Bio:** Stiklestad at 15; exile; Yaroslav’s captain; Varangian commander;
died Stamford Bridge claiming England.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Harder Than Steel | Hold Norway + England full de jure | — | — | both (no partial) |
| Hide the Pain, Harold… | Kill Godwin dynasty (dynasty kills count) | 5 | 10 | 15 |
| With an Iron Fist | Revolts crushed | 4 | 8 | 12 |

### 2.10 Hethum I — King of Armenia — 1226 — Miaphysite · **IN_PAYLOAD** `hethum_armenia`

**Bio:** Married Isabella; Hethumids; Mongol diplomacy / gifts.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Not-So-Little Armenia | Kingdom size (provinces) | — | — | 8 (no partial) |
| Keep Your Friends Close… | Mongol culture characters at 60+ opinion | 3 | 6 | 9 |
| We Will Not Submit | Independent kingdom years, never tributary | 25 | 50 | 75 |

### 2.11 Kulin Kulinic — Doux of Bosnia — 1173 — Catholic · **IN_PAYLOAD** `kulin_bosnia`

**Bio:** Bosnian Age of Peace and Prosperity; de facto independence; balance
Hungary/Serbia/Pope.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Not-So Landlocked | Independent k_bosnia full de jure | — | — | fulfil (no partial) |
| Heretical Company | Open heretic courtiers (no prisoners) | 6 | 9 | 12 |
| Celebrating Our Indepedence Day! | Peace + independence years; resets on death or war | 4 | 8 | 12 |

*(V4/V5/V6 test ruler: Heretical Company 1/6 etc.)*

### 2.12 Liao Hongji — Khagan of Liao — 1066 — Buddhist · **MJ_WIKI_ONLY**

**Bio:** Emperor Daozong; ignored corruption; tricked into executing empress
Xiao Guanyin and crown prince via Yelu Yixin; too late to repair.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Lavish Spending | Temples managed by Buddhists | 4 | 8 | 12 |
| Land Mass! | Nomad provinces in realm | 100 | 150 | 200 |
| Clanky! | Clans opinion >60 | 2 | 3 | 4 |

### 2.13 Basarab I — King/High Chief of Wallachia — 1310 — Orthodox · **MJ_WIKI_ONLY**

**Bio:** First independent Wallachian ruler (disloyal to Hungary 1325); House
Basarab → line including Vlad III.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Voivodes of Wallachia | Dynasty duke vassals (no unlegitimized bastards) | 3 | 6 | 9 |
| So Much at Stake | Kills while character has Impaler trait | 3 | 6 | 10 |
| Castle Mania | Castles + royal palaces (each palace stage = 3 pts; palace must be active) | 4 | 8 | 12 |

### 2.14 Mindaugas — High Chief of Lithuania — 1236 — Romuva · **MJ_WIKI_ONLY**

**Bio:** Only King of Lithuania; mysterious rise; baptized Catholic; land for
papal recognition (Innocent IV).

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| A Christian King | Hold k_lithuania full de jure; Catholic; crowned by Pope | — | — | fulfil (no partial) |
| True Faith | Catholic provinces in realm | 4 | 6 | 8 |
| Writing History | Great Library book collections | 2 | 3 | 4 |

### 2.15 Botstain Stenkyrka — Grand Mayor of Gotland — 1066 — Catholic · **MJ_WIKI_ONLY**

**Bio:** Young grand mayor of rich trade republic; 50+ harbours; trade-post
networks.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Aegir’s Island! | Independent king; capital Gotland; full d_gotland; ≥20 cities; fully upgraded Family Palace | — | — | fulfil (no partial) |
| Embargo! | Trade posts with ≥ tier-2 on all buildings; his lifetime | 3 | 4 | 5 |
| Trading Cities | Trade posts as grand republic | 20 | 40 | 60 |

### 2.16 Stefan Nemanjić — King of Serbia — 1196 — Orthodox · **MJ_WIKI_ONLY**

**Bio:** First-Crowned; kingdom status; with Saint Sava founded Serbian Orthodox Church.

| Challenge | Description | Bronze | Silver | Gold |
|---|---|---|---|---|
| Saint-King | Create saintly bloodline (godly or wicked) | — | — | create (no partial) |
| The First of Many | King titles held | 2 | 4 | 6 |
| God is Good to Me | Dynasty beatified/saints | 2 | 3 | 4 |

---

## 3. Coverage matrix (restore planning)

### In current V6 payload (11) — playable offline today
```
konan_brittany, llywelyn_gwynedd, mordechai_al_dawla, konstantinos_samos,
louise_aquitaine, shajar_egypt, pavao_croatia, arwa_yemen, harald_norway,
hethum_armenia, kulin_bosnia
```

### MJ wiki complete but missing from payload (need late dump or authoring) — 5
```
Liao Hongji, Basarab I, Mindaugas, Botstain Stenkyrka, Stefan Nemanjić
```
(= the “five missing rulers” already called out in STATUS / archives.)

### FR-era with published challenges but not in payload — extra beyond the five
```
Bohemond, Petronilla, Tamari, Nuno, Mihajlo
(+ Mindaugas overlaps the five)
```

### FR-only, never got published challenge tables
```
Hugues de Lusignan, Johann the Blind, Charles de Anjou, Mauregato of Asturias
```
These need binary/payload archaeology or stay tagline-only Bronzeman starts.

### Overlap note
Arwa, Llywelyn, Mindaugas appear on **both** FR and MJ lists (FR first as
tagline-only or early form; MJ with long bio + full feats). Payload carries
the **MJ** shape.

---

## 4. Challenge design patterns (useful when authoring JSON)

| Pattern | Examples |
|---|---|
| Binary “fulfil / no partial” gold-only | Dragon’s Fire, French Toast, Not-So Landlocked, A Christian King, Aegir’s Island, Saint-King, Long Live the Queen (time), Heiroglyphics size |
| Lifetime-gated (stops on death / only original character) | Gloves Come Off, Love Spoons, Aragonastop, Secret stays with Me, Tutan-Kha-Doom, Established, Embargo, Dawn of a New Da’is |
| Dynasty-persistent (any ruler of dynasty) | Vassaline, Time Bending, most conquest/holding feats |
| Kill-point formulas | William = 2; Mongol Muslim = 2; hidden complicity +1; Norse trait = 2 |
| Opinion thresholds | 60+ (Peace, Papal, Mongols, Clanky); 65+ (Why Don’t You like Me) |
| Culture/religion locks | Princes of Wales (Welsh), Serbian Dream, One of Us / Secret Jew, True Faith Catholic |
| Typo preserved from PDX | “Conquerer”, “Indepedence”, “Heiroglyphics”, “aliment”→ailment in bios |

Parser keys accepted by the binary (from Research Archive) still apply when
authoring missing rulers:  
`can_see_highlighted_rulers, scheduled_rulers, highlighted_ruler, add_localisation,
key, event_time_end, alert_level, title, startdate, dynasty_id, feats_script,
required_dlcs, traits, portrait, age, female, coa_dynasty, dna, properties,
religion, culture, government, map, provinces, color, camera_position, camera_look_at`.

---

## 5. What this dump does *not* contain

- Portrait DNA / properties / camera / map polygons (only in binary payload)
- Exact `feats_script` CK2 script bodies (only human descriptions here)
- FR “Time Remaining” derivation formula (likely from `event_time_end` − now)
- Leaderboard / Steam friends backend
- Real CK3 unlock grants (server-side Titus — dead)

For DNA/camera of the **11**, use `06_game_data/monarchs`. For the missing
five + FR-only, hunt a late-Aug 2020 / pre-removal payload or reconstruct
from character history IDs + GUI defaults.

---

## 6. Suggested use

| Goal | Use sections |
|---|---|
| Play current V6 | §2.1–2.11 only; ignore missing |
| Complete MJ 16-ruler dream | Author §2.12–2.16 into payload using §4 schema |
| Featured Rulers “museum” | §1 + FR chrome notes in `FEATURED_RULERS.md`; FR_ONLY may be tagline-only starts |
| Reward gallery UI | Ladder in §0; no server needed for **display** |
| Challenge debugging | Match in-game name to tables here (e.g. Heretical Company = Kulin) |
