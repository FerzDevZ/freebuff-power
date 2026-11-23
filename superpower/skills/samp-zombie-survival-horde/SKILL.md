---
name: samp-zombie-survival-horde
description: Zombie survival blueprint for SA-MP/open.mp — wave state machine, horde spawning within actor/NPC budgets, loot and extraction economy, infection and downed states, safe zones, and the performance and anti-exploit rules that decide whether the mode survives 50 players.
---

# Zombie survival horde

Zombies are the easy part. The mode breaks on entity budgets, timer cost, and
players killing the wave manager by disconnecting mid-spawn.

## Wave state machine

```
IDLE ──start──▶ PREP (30s) ──▶ ACTIVE ──all dead──▶ REWARD ──▶ IDLE
                                  │
                                  └──players wiped──▶ FAILED ──▶ IDLE
```

- one global wave counter and one state variable, not a timer per zombie;
- `PREP` announces the wave, `ACTIVE` spawns in batches, `REWARD` pays and resets;
- the state must survive a restart only if the mode is persistent — otherwise
  reset to `IDLE` explicitly and say so in the log.

## Horde budget

SA-MP actors are static: they can play animations and be damaged, but they cannot
walk toward players. Moving hordes need an NPC plugin (FCNPC and its open.mp
successors); check what your server actually loads before designing around it.

Budget rules:

- cap concurrent zombies (`MAX_ZOMBIES`) below the actor/NPC pool limit, leaving
  headroom for player-owned entities;
- spawn in batches per wave tick, not all at once — a 200-actor burst stalls the
  tick;
- one timer drives the horde (movement/attack decisions), interval sized to the
  budget, never one timer per zombie;
- despawn by distance and by wave end; track ids in one array so a disconnect or
  `/endwave` can clean up deterministically;
- if the plugin is missing, the mode must disable the horde and log why instead of
  spawning nothing silently.

Static-actor fallback: zombies guard spawn points and loot rooms. It is less
exciting but honest, and it runs on a vanilla server.

## Loot and extraction

- loot nodes are pickups or streamed objects with a respawn timer per node;
- rarity table lives in data, not in `if` chains;
- extraction is a location + hold timer + reward; it must be cancellable and must
  re-check the player is alive and inside the zone at completion;
- money/XP is granted server-side only after the server verifies the objective,
  never from a client message.

## Infection and downed state

```pawn
// server decides, client only displays
ApplyPlayerInfection(playerid, sourceid);   // your module
```

- infection is a timed state with a visible symptom and a cure item;
- downed is a state, not `SetPlayerHealth(playerid, 0)` — a downed player can be
  revived within a window, then dies;
- damage hooks (`OnPlayerTakeDamage`) must ignore friendly fire and suicide paths
  explicitly;
- never trust a client's "I was bitten" message.

## Safe zones

Use gangzones or polygon areas for safe zones, and check membership on the server
before applying damage or spawning zombies there. A safe zone that only exists in
the UI is not a safe zone.

## Performance checklist

- measure `GetTickCount()` around the horde tick and log it when it exceeds the
  budget;
- no `foreach` over all players inside a per-zombie loop;
- distance checks with squared distance, not `floatpower`;
- streamer for loot objects, not 500 global objects;
- wave logic in one callback/timer; disconnect cleanup removes that player's
  targeting entries.

## Anti-exploit

- loot pickup validates distance and node state;
- extraction validates zone, timer, and aliveness;
- wave rewards are idempotent (a player cannot claim twice);
- zombie damage ignores invalid/despawned ids instead of crashing.

## Limits

- No fixture: horde behaviour needs a running server plus an NPC plugin, which this
  repo's headless suite does not ship.
- Plugin APIs differ between FCNPC forks; treat the plugin call names as your
  server's, not as natives guaranteed by open.mp.
- Balance numbers in examples are illustrative; tune against your own player count.
