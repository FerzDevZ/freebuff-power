---
name: samp-teleport-system
description: Teleport and fast travel system for SA-MP/open.mp — location teleport, waypoints, vehicle teleport, and anti-exploit validation. Use when building teleport commands, fast travel, or location systems.
---

# SA-MP/Open.mp Teleport System (2026)

## When to Activate
- Building teleport commands (/tp, /goto, /bring)
- Implementing fast travel system
- Creating waypoint navigation
- Adding vehicle teleport
- Preventing teleport exploits

## Core Concepts

### 1. Location Teleport
```pawn
stock TeleportPlayer(playerid, Float:x, Float:y, Float:z, interior = 0, vw = 0) {
    // Fade out
    SetPlayerCameraPos(playerid, x, y, z + 50);
    SetPlayerCameraLookAt(playerid, x, y, z);
    // Teleport
    SetPlayerPos(playerid, x, y, z);
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);
    // Fade in
    SetCameraBehindPlayer(playerid);
    return 1;
}
```

### 2. Named Locations
```pawn
enum E_LOCATION {
    loc_name[64], Float:loc_x, Float:loc_y, Float:loc_z,
    loc_interior, loc_vw, loc_type
};

stock TeleportToLocation(playerid, loc_index) {
    TeleportPlayer(playerid, g_locations[loc_index][loc_x], g_locations[loc_index][loc_y], g_locations[loc_index][loc_z],
        g_locations[loc_index][loc_interior], g_locations[loc_index][loc_vw]);
    return 1;
}
```

### 3. Vehicle Teleport
```pawn
stock TeleportVehicle(vehicleid, Float:x, Float:y, Float:z) {
    SetVehiclePos(vehicleid, x, y, z);
    // Teleport all passengers
    for (new i = 0; i < MAX_PLAYERS; i++) {
        if (IsPlayerInVehicle(i, vehicleid)) {
            SetPlayerPos(i, x, y, z);
        }
    }
    return 1;
}
```

### 4. Anti-Exploit
```pawn
stock bool:CanTeleport(playerid) {
    if (g_teleport_cooldown[playerid] > gettime()) return false;
    if (g_player_jailed[playerid]) return false;
    if (IsPlayerInEvent(playerid)) return false;
    return true;
}
```

### 5. Waypoint System
```pawn
stock SetWaypoint(playerid, Float:x, Float:y, Float:z) {
    SetPlayerCheckpoint(playerid, x, y, z, 5.0);
    g_waypoint[playerid][0] = x;
    g_waypoint[playerid][1] = y;
    g_waypoint[playerid][2] = z;
    g_has_waypoint[playerid] = true;
}
```

## Key Rules
1. **Server-side teleport** — never trust client position
2. **Cooldown** — prevent teleport spam
3. **Validation** — check if player can teleport
4. **Logging** — log all teleports
5. **Anti-exploit** — check jail/event status

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