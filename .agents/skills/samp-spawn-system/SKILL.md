---
name: samp-spawn-system
description: Spawn and character selection system for SA-MP/open.mp — character creation, skin selection, spawn points, and session management. Use when building character selection, spawn systems, or session management.
---

# SA-MP/Open.mp Spawn & Character System (2026)

## When to Activate
- Building character selection screen
- Implementing spawn point system
- Creating character creation flow
- Adding skin/clothing selection
- Managing player sessions

## Core Concepts

### 1. Character Selection (Cinematic)
```pawn
stock ShowCharacterSelect(playerid) {
    // Cinematic camera swoop
    InterpolateCameraPos(playerid, CAM_START_X, CAM_START_Y, CAM_START_Z, CAM_END_X, CAM_END_Y, CAM_END_Z, 3000, CAMERA_MOVE);
    // Show character actors
    for (new i = 0; i < g_char_count[playerid]; i++) {
        g_char_actor[playerid][i] = CreateActor(g_char_skin[playerid][i], CHAR_X + (i * 2.0), CHAR_Y, CHAR_Z, 0.0);
    }
    // Show TextDraw UI with character names
    ShowCharacterTD(playerid);
}
```

### 2. Spawn Point System
```pawn
enum E_SPAWN_POINT {
    spawn_x, spawn_y, spawn_z, spawn_a,
    spawn_interior, spawn_vw, spawn_type
};

stock SpawnPlayerAt(playerid, spawn_index) {
    SetPlayerPos(playerid, g_spawns[spawn_index][spawn_x], g_spawns[spawn_index][spawn_y], g_spawns[spawn_index][spawn_z]);
    SetPlayerFacingAngle(playerid, g_spawns[spawn_index][spawn_a]);
    SetPlayerInterior(playerid, g_spawns[spawn_index][spawn_interior]);
    SetPlayerVirtualWorld(playerid, g_spawns[spawn_index][spawn_vw]);
    return 1;
}
```

### 3. Skin Selection
```pawn
stock ChangeSkin(playerid, skinid) {
    if (skinid < 0 || skinid > 311) return 0;
    SetPlayerSkin(playerid, skinid);
    // Save to DB
    new query[128];
    mysql_format(g_db, query, sizeof(query), "UPDATE characters SET skin=%d WHERE id=%d", skinid, GetPlayerCharId(playerid));
    mysql_tquery(g_db, query);
    return 1;
}
```

### 4. Session Management
```pawn
stock OnPlayerLogin(playerid) {
    g_session_start[playerid] = gettime();
    g_session_active[playerid] = true;
    // Load character data
    LoadPlayerCharacter(playerid);
    // Show spawn selection
    ShowSpawnSelect(playerid);
}
```

## Key Rules
1. **Server-side spawn** — validate spawn points
2. **Skin validation** — check valid skin IDs (0-311)
3. **Session tracking** — log login/logout
4. **Character limit** — max 3 characters per account
5. **Spawn protection** — brief invulnerability after spawn

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