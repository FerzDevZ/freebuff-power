---
name: samp-data-structures-pawn
description: Dependency-free Pawn collections for SA-MP 0.3.7 & open.mp — slot-pooled FIFO queue, growable int array, string→int hash map with tombstones, bounded string builder that reports truncation instead of hiding it, and a caller-owned bitset; every operation validates its handle and returns 0 instead of writing out of range, with a compile- and run-verified assertion suite.
---

# Data Structures in Pawn (SA-MP / open.mp)

Pawn has no collection library, so gamemodes hand-roll arrays and index math.
That is where the crashes come from: writing past the end (the compiler will not
stop you), reading a slot that was never filled, and appending text with
`format()` that silently truncates.

`resources/samp_ds.inc` provides five structures with validated handles. No
`malloc`, no plugin, no extra include — static storage sized at compile time.

## 1. Which structure for which job

| Need | Use | Limit | Replaces |
|---|---|---|---|
| Pending work processed in order (tasks, damage events, report queue) | `DS_Queue` (ring buffer) | `DS_QUEUE_CAP` 64 | arrays + `head`/`count` bookkeeping that drifts |
| List that grows/shrinks with order preserved (online staff, active robberies) | `DS_Array` | `DS_ARRAY_CAP` 64 | `new arr[MAX]; new count;` + manual shift loops |
| Lookup by string (player name → id, item name → price, permission → level) | `DS_Map` | `DS_MAP_SLOTS` 32, key 32 chars | linear `strcmp` scans over parallel arrays |
| Building a message from pieces (log lines, `/stats` output, reason strings) | `DS_Str` | `DS_STR_CAP` 128 | chained `format()` + `strcat()` that truncates silently |
| 256 boolean flags per entity (toggles, permissions, visited checks) | `DS_Bit*` (caller-owned) | `DS_BITS_MAX` 256 | 256 `bool:` cells at 4 bytes each |

Rule of thumb: **`DS_Array` for ≤ 64 items and no key; `DS_Map` when you would
otherwise loop with `strcmp`; `DS_Queue` when order is the contract.**

## 2. Usage

```pawn
#include <samp_ds>

new gDamageQueue = -1;

public OnGameModeInit()
{
    gDamageQueue = DS_QueueNew();          // -1 when the pool is exhausted
    if (gDamageQueue == -1) return 0;      // fail loudly, do not ignore
    return 1;
}

stock QueueDamage(targetid, amount)
{
    if (!DS_QueuePush(gDamageQueue, targetid * 1000 + amount))
    {
        // Full: drop deliberately and log it. Silence here is data loss.
        printf("[queue] damage event dropped, full");
        return 0;
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    new packed;
    while (DS_QueuePop(gDamageQueue, packed))
    {
        // drain, oldest first
    }
    return 1;
}
```

Map with the failure mode spelled out:

```pawn
new gPrices = -1;
// setup
gPrices = DS_MapNew();
DS_MapSet(gPrices, "burger", 15);

// read
new price;
if (DS_MapGet(gPrices, "burger", price)) { /* price == 15 */ }
else { /* absent — do not treat 0 as "free" */ }
```

String builder that tells you it lost characters:

```pawn
new line = DS_StrNew();
DS_StrAppendJoined(line, ", ", "Buffy");
DS_StrAppendJoined(line, ", ", "Angel");
DS_StrAppend(line, " (");
DS_StrAppendInt(line, 7);
DS_StrAppend(line, ")");
new out[64];
DS_StrCopy(line, out, sizeof out);
if (DS_StrWasTruncated(line))
{
    printf("[ui] text did not fit, raise DS_STR_CAP");
}
```

## 3. Contract (this is the part that prevents crashes)

- A handle is `-1` when allocation fails; **every** function accepts it and
  returns `0`. Check the value returned by `DS_*New()` at startup, not at use.
- Mutating calls return `1` (did the work) or `0` (invalid handle, full, index
  out of range, key too long). They never write out of range.
- `DS_ArrayGet` returns a fallback on a bad index, so `0` is ambiguous —
  use `DS_ArrayTryGet` when `0` is a real value.
- The map stores **tombstones**: a removed slot stays `used` so probe chains keep
  working. `DS_MapCount` is the live count. Once `DS_MAP_SLOTS` is exhausted by
  live + tombstone slots, inserts return `0`; `DS_MapDestroy`/`DS_MapNew`
  compacts. Size the map for peak keys, not average.
- Keys match exactly (case-sensitive). Normalise player names at the call site if
  you need case-insensitive lookup; do not lowercase inside the map.
- The string builder keeps one cell for the NUL terminator: capacity is
  `DS_STR_CAP - 1` characters. Truncation sets a flag **and** returns `0` —
  both exist because one is for control flow, the other for a final check.

## 4. Pool sizing

Every pool is compile-time and resident forever:

```pawn
#define DS_MAX_QUEUES  (8)
#define DS_QUEUE_CAP   (128)
#define DS_MAP_SLOTS   (64)   // must stay a power of two
#define DS_ARRAY_CAP   (128)
#define DS_STR_CAP     (256)
#include <samp_ds>
```

`DS_MAP_SLOTS` must be a power of two — the hash mask depends on it. Sizing the
map at 32 for 200 item names is the single most common misuse: inserts then fail
with `0` and the lookup "randomly" returns nothing.

## 5. Verification (real, not assumed)

Both targets, then an actual server run:

```bash
cd .agents/skills/samp-data-structures-pawn/resources

# open.mp target
pawncc demo_ds_omp.pwn -i. -i"$OMP_STDLIB" -d3 -o/tmp/demo_ds.ompx

# legacy 0.3.7 stdlib target
pawncc demo_ds.pwn -i. -i"$SAMP_STDLIB" -i"$OMP_STDLIB" -d3 -o/tmp/demo_ds.legacy.amx

# run the suite: gamemodes/ds.amx + main_scripts ["ds 1"], then read the log
grep '\[DS\]' log.txt
```

Expected result: `[DS] 91 checks, 0 failed`, with 0 warnings on both builds.
Verified on open.mp 1.6.7.3218 — the suite is executed by `OnGameModeInit`, not
merely compiled.

The fixture prints failures as `[DS] FAIL: <label> (expected N, got M)`. The
counts are the evidence: a suite that prints nothing did not run, and "0 failed"
with 0 checks is not a pass — `gChecks` must match the expected total.

## 6. Wiring into the test harness

The fixture carries its own 10-line `Test`/`TestInt` helpers so it compiles
standalone. In a gamemode, delete them and forward to `samp-testing-harness`:

```pawn
stock Test(condition, const label[])            { return ST_Check(condition != 0, label); }
stock TestInt(expected, actual, const label[])  { return ST_CheckInt(expected, actual, label); }
```

## 7. What this does not solve

- No dynamic allocation: capacity is fixed at compile time. If a feature needs
  unbounded growth, model it as a stream (drop oldest) or move it to the database.
- No ordering guarantee for the map (hash order), no sorted array. Sorting 64
  ints is a two-loop insertion sort — write it at the call site, not here.
- No float keys, no struct values. Keep the value an `enum` index or a packed
  cell, and store the payload in a parallel array.
