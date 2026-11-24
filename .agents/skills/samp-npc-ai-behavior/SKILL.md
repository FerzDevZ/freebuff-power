---
name: samp-npc-ai-behavior
description: NPC AI & behavior systems for SA-MP & open.mp — pathfinding (A* on navmesh), patrol routes, combat AI, dialogue trees, state machines for NPC behavior, NPC spawning/despawning lifecycle, and integration with ColAndreas for collision-aware movement. Use when creating NPCs, bots, AI-driven characters, or automated entities.
---

# SA-MP / open.mp NPC AI & Behavior Systems

## 1. Runtime

- **open.mp**: Official NPC component (replaces FCNPC plugin) — vehicle position/rotation natives, pathfinding support
- **Legacy**: FCNPC plugin (still works, but open.mp native preferred)
- **Collision**: ColAndreas for raycasting, Z-snap, obstacle detection
- **Pathfinding**: Custom A* on navmesh, or simplified waypoint-based movement

## 2. NPC Lifecycle

### 2.1 Creation
```pawn
// open.mp native NPC
new npcId = CreateNPC("BotName", skinId, x, y, z, angle);
// Or with streamer
new npcId = CreateDynamicNPC("BotName", skinId, x, y, z, angle, world, interior);
```

### 2.2 Ownership & Cleanup
- Track NPCs in owner-table (like actors/pickups)
- Despawn when no players nearby (streaming distance)
- Clean up on disconnect, gamemode exit, or owner disconnect

### 2.3 State Machine
```pawn
enum E_NPC_STATE {
    NPC_STATE_IDLE,
    NPC_STATE_PATROL,
    NPC_STATE_CHASE,
    NPC_STATE_ATTACK,
    NPC_STATE_FLEE,
    NPC_STATE_DEAD
}
```

## 3. Behavior Patterns

### 3.1 Patrol
- Define waypoint array per NPC
- Move between waypoints with `MoveNPC` or `NPC_GoTo`
- Pause at each waypoint (timer-based)
- Loop or reverse at end

### 3.2 Chase
- Detect player within radius (distance check)
- Move toward player position
- Update target position periodically (not every tick — performance)
- Stop chasing if player too far or out of line of sight

### 3.3 Combat
- Face target, play attack animation
- Apply damage with delay (not instant)
- Flee if health below threshold
- Cooldown between attacks

### 3.4 Dialogue
- Trigger on proximity (player near NPC)
- Show dialog or TextDraw conversation
- Branch based on player choices
- Remember conversation state per player

## 4. Anti-Patterns

- ❌ Moving NPCs every tick (OnPlayerUpdate) — use timers (500ms-1s intervals)
- ❌ Pathfinding through walls — always use ColAndreas raycast
- ❌ Spawning NPCs globally — use streamer for distance-based spawning
- ❌ No state machine — NPCs need clear states (idle/patrol/chase/attack/flee/dead)
- ❌ Hardcoded waypoints — use data tables for patrol routes

## 5. Gate

```bash
# Compile both targets
pawncc npc_ai.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx

# Runtime: NPC must move, detect player, respond to proximity
# Performance: ≤1ms per NPC update tick, ≤50 NPCs active simultaneously
```

---

## References

- open.mp NPC component: https://open.mp/docs
- FCNPC (legacy): https://github.com/ziggi/FCNPC
- ColAndreas: https://github.com/Pottus/ColAndreas

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

