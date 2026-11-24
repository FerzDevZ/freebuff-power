---
name: samp-anticheat-system
description: Server-side Anti-Cheat architecture for SA-MP & open.mp — speed hack, teleport detection, fly hack, weapon injection, health/armour hack, fake kill detection, RakNet packet validation, and SAMPCAC integration.
---

# SA-MP / open.mp Server-Side Anti-Cheat Skill

## Core Principles
1. **Never Trust the Client:** The client controls animation and physics simulation, but the server controls authoritative game states.
2. **Deterministic State Machine:** Disallow events that contradict the current player state (e.g., shooting while dead, entering vehicles without animation, dealing damage from impossible distances).
3. **Grace Periods & Desync Tolerance:** Always account for network jitter, vehicle collisions, and packet lag before auto-banning.

## Detection Modules

### 1. Speedhack & Teleport Detection (On-Foot & In-Vehicle)
Calculate positional displacement delta ($\Delta d$) over tick intervals.

```pawn
#define AC_MAX_ONFOOT_SPEED     12.0 // m/s (CJ sprint max ~10.5 m/s)
#define AC_MAX_VEHICLE_SPEED   110.0 // m/s (Fastest cars ~65 m/s, Infernus max ~70 m/s with nitrous)
#define AC_TELEPORT_THRESHOLD   75.0 // Sudden jump without teleport trigger

enum E_AC_PLAYER_DATA {
    Float:acLastX,
    Float:acLastY,
    Float:acLastZ,
    acLastTick,
    acWarningCount,
    bool:acIgnoreTeleport
};
new AntiCheatData[MAX_PLAYERS][E_AC_PLAYER_DATA];

public OnPlayerUpdate(playerid) {
    if (!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 1;
    if (GetPlayerState(playerid) == PLAYER_STATE_WASTED) return 1;

    // Check if player was legitimately teleported by admin or interior entrance
    if (AntiCheatData[playerid][acIgnoreTeleport]) {
        AntiCheatData[playerid][acIgnoreTeleport] = false;
        GetPlayerPos(playerid, AntiCheatData[playerid][acLastX], AntiCheatData[playerid][acLastY], AntiCheatData[playerid][acLastZ]);
        AntiCheatData[playerid][acLastTick] = GetTickCount();
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    new currentTick = GetTickCount();
    new timeElapsed = currentTick - AntiCheatData[playerid][acLastTick];

    if (timeElapsed >= 500) { // Every 500ms
        new Float:distance = VectorSize(
            x - AntiCheatData[playerid][acLastX],
            y - AntiCheatData[playerid][acLastY],
            z - AntiCheatData[playerid][acLastZ]
        );
        
        new Float:speed = (distance / float(timeElapsed)) * 1000.0; // units per second

        if (!IsPlayerInAnyVehicle(playerid)) {
            // On-Foot Check
            if (distance > AC_TELEPORT_THRESHOLD) {
                AntiCheat_Flag(playerid, "Teleport On-Foot", distance);
                SetPlayerPos(playerid, AntiCheatData[playerid][acLastX], AntiCheatData[playerid][acLastY], AntiCheatData[playerid][acLastZ]);
            } else if (speed > AC_MAX_ONFOOT_SPEED && GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID) {
                AntiCheat_Flag(playerid, "Speedhack On-Foot", speed);
            }
        } else {
            // Vehicle Check
            if (speed > AC_MAX_VEHICLE_SPEED) {
                AntiCheat_Flag(playerid, "Vehicle Speedhack", speed);
            }
        }

        AntiCheatData[playerid][acLastX] = x;
        AntiCheatData[playerid][acLastY] = y;
        AntiCheatData[playerid][acLastZ] = z;
        AntiCheatData[playerid][acLastTick] = currentTick;
    }

    return 1;
}

stock AntiCheat_Flag(playerid, const reason[], Float:metric) {
    AntiCheatData[playerid][acWarningCount]++;
    printf("[ANTICHEAT] Player %d (%s) flagged for %s (Value: %.2f) [Warn: %d/3]",
        playerid, PlayerData[playerid][pName], reason, metric, AntiCheatData[playerid][acWarningCount]);
    
    if (AntiCheatData[playerid][acWarningCount] >= 3) {
        new kickMsg[128];
        format(kickMsg, sizeof(kickMsg), "[ANTICHEAT] Anda dikeluarkan karena dugaan: %s.", reason);
        SendClientMessage(playerid, 0xFF0000FF, kickMsg);
        Kick(playerid);
    }
}
```

### 2. Weapon Injection Detection (Fake Weapon Spawning)
Prevent clients from injecting miniguns, RPGs, or combat shotguns via memory hacks (S0beit).

```pawn
new gServerIssuedWeapons[MAX_PLAYERS][13]; // 13 weapon slots

stock Server_GiveWeapon(playerid, weaponid, ammo) {
    new slot = GetWeaponSlot(weaponid);
    gServerIssuedWeapons[playerid][slot] = weaponid;
    GivePlayerWeapon(playerid, weaponid, ammo);
}

stock Server_ResetWeapons(playerid) {
    for (new s = 0; s < 13; s++) {
        gServerIssuedWeapons[playerid][s] = 0;
    }
    ResetPlayerWeapons(playerid);
}

// In periodic timer (every 1 second):
public AntiCheat_ScanWeapons(playerid) {
    new weapon, ammo;
    for (new slot = 0; slot < 13; slot++) {
        GetPlayerWeaponData(playerid, slot, weapon, ammo);
        if (weapon > 0 && ammo > 0) {
            if (weapon != gServerIssuedWeapons[playerid][slot]) {
                AntiCheat_Flag(playerid, "Weapon Injection", float(weapon));
                RemovePlayerWeapon(playerid, weapon);
            }
        }
    }
}
```

### 3. Health & Armour Desync / Godmode
- Maintain authoritative `Float:pServerHealth` and `Float:pServerArmour`.
- Hook `OnPlayerTakeDamage` and only deduct health server-side.
- If client health spontaneously increases without medkit/hospital events, flag godmode or health hack.

### 4. Fake Kill Detection
In `OnPlayerDeath(playerid, killerid, reason)`:
- Validate `killerid != INVALID_PLAYER_ID`.
- Check if distance between `playerid` and `killerid` is plausible for the given weapon `reason`.
- Drop death packet if killer is dead, spectator, or > 300m away with melee weapon.

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

