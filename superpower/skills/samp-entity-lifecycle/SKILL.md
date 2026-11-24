---
name: samp-entity-lifecycle
description: Entity pool ownership for SA-MP/open.mp — verified create/destroy semantics for actors, pickups, gangzones, 3D labels and checkpoints, plus an owner-tracked table for actors, pickups and gangzones that refuses double-tracking, cleans up per owner, and drops stale rows, proven by a runtime suite on a real omp-server.
---

# Entity lifecycle and pool ownership

Entity leaks do not throw errors. An actor created for a shop panel stays after
the player disconnects, the next player creates another, and the pool fills
silently until creation starts returning `INVALID_*`. Documentation does not tell
you whether `DestroyActor` actually frees the slot — a running server does.

## What the runtime suite verifies

`resources/demo_entity_lifecycle.pwn` executes on omp-server (60 assertions):

| Entity | Verified behaviour |
|---|---|
| Actor | create → `IsValidActor` true → destroy → invalid; double destroy returns false |
| Pickup | create → model reads back → destroy → invalid; recreate after destroy; (validity/model are open.mp-only) |
| Gangzone | create → destroy → invalid; double destroy refused |
| 3D label | delete → invalid; double delete refused |
| Player checkpoint | with no client, `SetPlayerCheckpoint` and `DisablePlayerCheckpoint` return false instead of pretending |
| Tracker | duplicate actor/pickup/gangzone refused, capacity stops cleanly, reset clears, per-owner cleanup destroys exactly that owner's entities (all kinds) and leaves others untouched |
| Stale rows | an entity destroyed behind the tracker's back is dropped on cleanup, not counted as destroyed or retried |

The legacy build compiles the same file with the open.mp-only validity natives
guarded out, because 0.3.7 has no `IsValidPickup`, `IsValidGangZone`,
`IsValid3DTextLabel`, or `IsPlayerCheckpointActive`.

## Owner-tracked entities

`resources/samp_entity_lifecycle.inc` keeps a small table of
`owner → kind + id`, covering actors, pickups and gangzones:

```pawn
new pickup = CreatePickup(1240, 2, x, y, z);
if (!EL_TrackPickup(playerid, pickup)) { DestroyPickup(pickup); return 0; }

new zone = GangZoneCreate(x1, y1, x2, y2);
if (!EL_TrackGangzone(playerid, zone)) { GangZoneDestroy(zone); }
...
public OnPlayerDisconnect(playerid, reason)
{
    EL_DestroyOwned(playerid);   // destroys every kind this owner still holds
    return 1;
}
```

Available: `EL_TrackActor/EL_TrackPickup/EL_TrackGangzone`,
`EL_ForgetActor/EL_ForgetPickup/EL_ForgetGangzone` (forget without destroying),
`EL_DestroyOwned(owner)`, `EL_OwnedCount(owner)`, `EL_TrackedCount()`, `EL_Reset()`.

Rules the implementation enforces, each pinned by an assertion:

- negative entity id, negative owner, or owner beyond `EL_MAX_OWNERS` is refused;
- the same kind+id cannot be tracked twice (double-destroy protection), while an
  actor and a pickup sharing a numeric id stay independent;
- a full table refuses tracking rather than silently tracking nothing;
- `EL_DestroyOwned` destroys all three kinds, counts only successful destroys, and
  drops entries whose entity is already gone instead of retrying them forever;
- forgetting removes one entry without touching the native pool, and forgetting an
  untracked entity returns false.

## Wiring it into a script

```pawn
#include <samp_entity_lifecycle>

// create
new actor = CreateActor(skin, x, y, z, angle);
if (!EL_TrackActor(playerid, actor))
{
    DestroyActor(actor);
    SendClientMessage(playerid, -1, "Terlalu banyak objek aktif.");
}
```

Call `EL_DestroyOwned` in `OnPlayerDisconnect` and before replacing a panel; call
`EL_Reset` only in tests — on a live server it would forget entities you still own.

## Limits

- Validity pre-checks exist only for actors: 0.3.7 has no `IsValidPickup` or
  `IsValidGangZone`, so a stale pickup/zone id is caught when destroy fails, not
  at tracking time. On open.mp the runtime assertions confirm cleanup validity.
- Capacity is compile-time (`EL_MAX_TRACKED`, default 32) across all kinds and
  per-process, not per-player.
- The suite runs headless: it proves pool/validity semantics, not how entities
  look in-game.
- Checkpoint assertions cover the disconnected-player path only; a real client is
  required for the visible checkpoint path.

## Runtime (open.mp)

- **open.mp server**: v1.6.7.3218 (latest stable, Oct 2026)
- **pawncc**: 3.10.10+ (open.mp compiler, `-Z` for warnings-as-errors)
- **Streamer Plugin**: v2.9.6+ (Incognito) for dynamic objects/areas/pickups
- **MySQL Plugin**: R41-4 (BlueG) or `mysql` component (open.mp native)
- **YSI 5.x**: y_commands, y_hooks, y_iterate, y_bit, y_inline, y_timers, y_groups
- **ColAndreas**: v1.5.0+ for collision/raycasting
- **SA-MP Legacy**: 0.3.7-R2 / 0.3.DL (backward compat)

### Compile Check (Gate)
```bash
# open.mp
pawncc -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn

# legacy (0.3.7)
pawncc -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn
```
Zero warnings, zero errors required.

