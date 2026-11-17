---
name: samp-filterscript-engineering
description: Complete architecture for building standalone, hot-reloadable Filterscripts in SA-MP and open.mp — lifecycle management, CallRemoteFunction IPC, dynamic resource deallocation, and multi-script coordination.
---

# SA-MP / open.mp Filterscript Engineering Skill

## Overview
Filterscripts are auxiliary scripts running in parallel with the main gamemode in their own AMX virtual machine. They can be dynamically loaded, unloaded, or reloaded at runtime (`/rcon loadfs <name>`, `/rcon unloadfs <name>`) without rebooting the server.

---

## Anatomy of a Production Filterscript

```pawn
// filterscripts/speed_trap.pwn
#define FILTERSCRIPT
#include <open.mp>
#include <streamer>

#define MAX_SPEED_TRAPS 50
#define SPEED_LIMIT_KMH 90.0

enum E_TRAP_DATA {
    bool:tActive,
    Float:tX, Float:tY, Float:tZ,
    STREAMER_TAG_AREA:tAreaID,
    STREAMER_TAG_OBJECT:tCameraObj
};
new TrapData[MAX_SPEED_TRAPS][E_TRAP_DATA];
new gTrapCount = 0;

public OnFilterScriptInit() {
    print("--------------------------------------");
    print(" [FilterScript] Speed Trap Radar v1.0 ");
    print("--------------------------------------");

    // Initialize speed trap zones
    CreateSpeedTrap(1544.20, -1675.80, 13.50);
    CreateSpeedTrap(2020.10, 1005.40, 10.80);
    return 1;
}

public OnFilterScriptExit() {
    print("[FilterScript] Unloading Speed Trap Radar...");

    // MANDATORY CLEANUP: Prevent ghost objects and memory leaks
    for (new i = 0; i < gTrapCount; i++) {
        if (TrapData[i][tActive]) {
            DestroyDynamicArea(TrapData[i][tAreaID]);
            DestroyDynamicObject(TrapData[i][tCameraObj]);
            TrapData[i][tActive] = false;
        }
    }
    gTrapCount = 0;
    return 1;
}

stock CreateSpeedTrap(Float:x, Float:y, Float:z) {
    if (gTrapCount >= MAX_SPEED_TRAPS) return -1;

    new id = gTrapCount++;
    TrapData[id][tActive] = true;
    TrapData[id][tX] = x;
    TrapData[id][tY] = y;
    TrapData[id][tZ] = z;

    TrapData[id][tAreaID] = CreateDynamicSphere(x, y, z, 15.0);
    TrapData[id][tCameraObj] = CreateDynamicObject(18880, x, y, z, 0.0, 0.0, 0.0);
    return id;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid) {
    if (!IsPlayerInAnyVehicle(playerid)) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(vehicleid, vx, vy, vz);

    new Float:speed = VectorSize(vx, vy, vz) * 181.5; // Convert to km/h

    if (speed > SPEED_LIMIT_KMH) {
        new fineAmount = floatround((speed - SPEED_LIMIT_KMH) * 20.0);
        
        // Notify Gamemode via IPC to deduct money
        CallRemoteFunction("OnPlayerSpeedViolation", "iif", playerid, fineAmount, speed);
    }
    return 1;
}
```

---

## Cross-Script Inter-Process Communication (IPC)

Because global variables are isolated within each AMX instance, scripts must communicate via exported public callbacks:

### 1. In Gamemode (`main.pwn`):
```pawn
forward OnPlayerSpeedViolation(playerid, fineAmount, Float:recordedSpeed);
public OnPlayerSpeedViolation(playerid, fineAmount, Float:recordedSpeed) {
    new msg[128];
    format(msg, sizeof(msg), "[RADAR] Anda terdeteksi melaju %.1f km/h (Batas: 90 km/h). Denda: $%d.",
        recordedSpeed, fineAmount);
    SendClientMessage(playerid, 0xFF0000FF, msg);

    // Deduct cash from gamemode's player struct
    PlayerData[playerid][pCash] -= fineAmount;
    return 1;
}
```

### 2. Format Specifiers for `CallRemoteFunction`
- `"i"` / `"d"` : Integer / Cell
- `"s"` : String (e.g. `"Hello"`)
- `"f"` : Float (e.g. `12.5`)
- `"b"` : Boolean (`true` / `false`)

---

## Best Practices & Safety Invariants
1. **Always Implement `OnFilterScriptExit`:** Clean up every dynamic object, text draw, area, and timer.
2. **Never Return 0 in Unhandled Callbacks:** Always return `1` so subsequent filterscripts and the gamemode receive the event.
3. **Check Connection Status:** When handling delayed timers in filterscripts, verify `IsPlayerConnected(playerid)`.
