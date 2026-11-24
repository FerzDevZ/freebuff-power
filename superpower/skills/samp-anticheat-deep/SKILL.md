---
name: samp-anticheat-deep
description: Advanced anti-cheat for SA-MP/open.mp — speed hack, teleport, fly hack, weapon injection, health hack, aimbot, and packet-level validation. Use when building anti-cheat systems or hardening servers.
---

# SA-MP/Open.mp Deep Anti-Cheat (2026)

## When to Activate
- Building server-side anti-cheat
- Detecting speed/teleport/fly hacks
- Validating weapon/health changes
- Implementing packet-level checks
- Hardening against known exploits

## Core Concepts

### 1. Speed Hack Detection
```pawn
stock CheckSpeedHack(playerid) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new Float:dist = GetDistanceBetweenPoints(x, y, z, g_last_pos[playerid][0], g_last_pos[playerid][1], g_last_pos[playerid][2]);
    new elapsed = GetTickCount() - g_last_pos_tick[playerid];
    if (elapsed > 0) {
        new Float:max_speed = 50.0; // units per second
        new Float:actual_speed = (dist / elapsed) * 1000.0;
        if (actual_speed > max_speed && !IsPlayerInAnyVehicle(playerid)) {
            // Speed hack detected
            BanPlayer(playerid, "Speed hack");
        }
    }
    g_last_pos[playerid][0] = x;
    g_last_pos[playerid][1] = y;
    g_last_pos[playerid][2] = z;
    g_last_pos_tick[playerid] = GetTickCount();
}
```

### 2. Teleport Detection
```pawn
stock CheckTeleport(playerid) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new Float:dist = GetDistanceBetweenPoints(x, y, z, g_last_pos[playerid][0], g_last_pos[playerid][1], g_last_pos[playerid][2]);
    if (dist > TELEPORT_THRESHOLD && !g_just_spawned[playerid]) {
        // Teleport detected
        Kick(playerid);
    }
}
```

### 3. Fly Hack Detection
```pawn
stock CheckFlyHack(playerid) {
    new Float:z;
    GetPlayerPos(playerid, _, _, z);
    new Float:ground_z = GetGroundZ(playerid);
    if (z - ground_z > FLY_THRESHOLD && !IsPlayerInAnyVehicle(playerid)) {
        // Fly hack detected
        BanPlayer(playerid, "Fly hack");
    }
}
```

### 4. Weapon Injection
```pawn
stock CheckWeaponHack(playerid) {
    new weapons[13][2];
    GetPlayerWeapons(playerid, weapons);
    for (new i = 0; i < 13; i++) {
        if (weapons[i][0] != 0 && !IsWeaponAllowed(weapons[i][0])) {
            // Weapon injection detected
            ResetPlayerWeapons(playerid);
            BanPlayer(playerid, "Weapon injection");
        }
    }
}
```

### 5. Health/Armor Hack
```pawn
stock CheckHealthHack(playerid) {
    new Float:hp, Float:armour;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, armour);
    if (hp > 100.0 + 0.1 || armour > 100.0 + 0.1) {
        // Health hack detected
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 0.0);
        BanPlayer(playerid, "Health hack");
    }
}
```

### 6. Aimbot Detection
```pawn
stock CheckAimbot(playerid) {
    // Track headshot ratio, snap angles, reaction time
    if (g_headshot_count[playerid] > 10 && g_total_shots[playerid] < 20) {
        // Suspicious headshot ratio
        LogSuspicious(playerid, "Possible aimbot");
    }
}
```

### 7. Packet-Level Validation (Pawn.RakNet)
```pawn
// Hook incoming sync packets
public OnIncomingPacket(playerid, packetid, BitStream:bs) {
    if (packetid == ID_PLAYER_SYNC) {
        // Validate position, health, weapon in packet
    }
    return 1;
}
```

## Key Rules
1. **Server-side validation** — never trust client state
2. **Threshold-based** — avoid false positives with tolerance
3. **Log before ban** — gather evidence
4. **Graceful degradation** — kick first, ban on repeat
5. **Update regularly** — cheaters adapt

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