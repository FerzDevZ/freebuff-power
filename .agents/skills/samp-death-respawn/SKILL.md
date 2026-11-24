---
name: samp-death-respawn
description: Death and respawn system for SA-MP/open.mp — death handling, hospital spawn, death camera, death messages, and respawn timers. Use when building death mechanics, respawn systems, or hospital features.
---

# SA-MP/Open.mp Death & Respawn System (2026)

## When to Activate
- Building death/respawn mechanics
- Implementing hospital spawn
- Creating death camera/spectate
- Adding death messages/notifications
- Designing respawn timers

## Core Concepts

### 1. Death Handler
```pawn
public OnPlayerDeath(playerid, killerid, reason) {
    // Log death
    LogPlayerAction(playerid, "DEATH", reason);
    // Death camera
    SetPlayerCameraLookAt(playerid, ...);
    // Respawn timer
    g_respawn_timer[playerid] = SetTimerEx("RespawnPlayer", RESPAWN_DELAY, false, "i", playerid);
    // Notify
    new msg[128];
    format(msg, sizeof(msg), "%s died. (%s)", GetPlayerNameEx(playerid), GetWeaponName(reason));
    SendDeathMessage(playerid, killerid, reason);
    return 1;
}
```

### 2. Respawn
```pawn
forward RespawnPlayer(playerid);
public RespawnPlayer(playerid) {
    g_respawning[playerid] = true;
    // Spawn at hospital
    SpawnPlayerAtHospital(playerid);
    // Reset state
    ResetPlayerWeapons(playerid);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);
    ClearAnimations(playerid);
    g_respawning[playerid] = false;
}
```

### 3. Hospital Spawn
```pawn
stock SpawnPlayerAtHospital(playerid) {
    new hospital = GetNearestHospital(playerid);
    SetPlayerPos(playerid, g_hospitals[hospital][h_x], g_hospitals[hospital][h_y], g_hospitals[hospital][h_z]);
    SetPlayerFacingAngle(playerid, g_hospitals[hospital][h_a]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
}
```

### 4. Death Penalty
```pawn
stock ApplyDeathPenalty(playerid) {
    // Lose % of cash
    new loss = GetPlayerMoney(playerid) / 10; // 10%
    GivePlayerMoney(playerid, -loss);
    // Lose items
    DropPlayerItems(playerid);
    // Respawn with reduced HP
}
```

### 5. Respawn Protection
```pawn
stock GiveSpawnProtection(playerid, seconds) {
    g_spawn_protected[playerid] = true;
    SetTimerEx("RemoveSpawnProtection", seconds * 1000, false, "i", playerid);
    // Visual indicator (TextDraw)
    ShowSpawnProtectionTD(playerid);
}
```

## Key Rules
1. **Server-side death** — validate all death events
2. **Hospital spawn** — always spawn at designated point
3. **Death penalty** — configurable per server
4. **Respawn protection** — prevent spawn killing
5. **Log all deaths** — for statistics and evidence

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