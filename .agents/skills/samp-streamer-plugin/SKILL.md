---
name: samp-streamer-plugin
description: Incognito Streamer Plugin API for SA-MP and open.mp — dynamic objects, pickups, map icons, 3D text labels, areas, actors, and vehicles. Stream distance optimization, draw distances, interior/virtual world isolation, and event callbacks.
---

# SA-MP / open.mp Streamer Plugin Skill

## Overview
Incognito's Streamer Plugin breaks SA-MP's native engine limits (e.g., 1000 objects, 1024 3D text labels) by dynamically allocating and streaming entities to players based on spatial position, virtual world, and interior.

### Inclusion & Dependency Order
```pawn
#include <a_samp>
#include <streamer>
```
In `server.cfg`:
```ini
plugins streamer
```
Or in `config.json` (`open.mp`):
```json
"legacy_plugins": ["streamer"]
```

## Dynamic Objects
Overcoming SA-MP's 1000 object limit:
```pawn
// CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz,
//   worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_OBJECT_SD, Float:drawdistance = STREAMER_OBJECT_DD)
new STREAMER_TAG_OBJECT:gGateObject;

public OnGameModeInit() {
    gGateObject = CreateDynamicObject(
        980,                       // Model ID (Barrier Gate)
        1544.68, -1675.29, 13.55,  // Pos X, Y, Z
        0.0, 0.0, 90.0,            // Rot X, Y, Z
        0, 0,                      // Virtual World, Interior (0 = main world)
        -1,                        // Player ID (-1 = visible to all)
        250.0,                     // Stream distance (250m)
        300.0                      // Draw distance (300m)
    );
    return 1;
}

// Move object (smooth animation)
stock OpenGate() {
    MoveDynamicObject(gGateObject, 1544.68, -1675.29, 19.00, 3.5, 0.0, 0.0, 90.0);
}

// Object movement callback
public OnDynamicObjectMoved(STREAMER_TAG_OBJECT:objectid) {
    if (objectid == gGateObject) {
        printf("[Streamer] Gate finished moving.");
    }
    return 1;
}
```

## Dynamic 3D Text Labels
Eliminate hard 1024 label limit:
```pawn
new STREAMER_TAG_3D_TEXT_LABEL:gBankLabel;

public OnGameModeInit() {
    gBankLabel = CreateDynamic3DTextLabel(
        "{00FF00}[ BANK OF SAN ANDREAS ]\n{FFFFFF}Tekan {FFFF00}'Y'{FFFFFF} untuk mengakses ATM",
        0xFFFFFFFF,
        1499.88, -1709.84, 14.05,
        15.0,                       // Draw distance (meters)
        INVALID_PLAYER_ID, INVALID_VEHICLE_ID,
        0,                          // Test line of sight (0 = through walls)
        0, 0,                       // World 0, Interior 0
        -1, 15.0                    // Stream distance
    );
    return 1;
}
```

## Dynamic Pickups
```pawn
new STREAMER_TAG_PICKUP:gJobPickup;

public OnGameModeInit() {
    gJobPickup = CreateDynamicPickup(
        1239, // Info icon model
        1,    // Type 1 = always exists & respawns
        1481.18, -1771.55, 18.79,
        0, 0, -1, 100.0
    );
    return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, STREAMER_TAG_PICKUP:pickupid) {
    if (pickupid == gJobPickup) {
        SendClientMessage(playerid, 0x00FFFFFF, "Ketik {FFFF00}/applyjob{00FFFFFF} untuk mendaftar pekerjaan ini.");
    }
    return 1;
}
```

## Dynamic Areas & Triggers (Zones)
Used for safe zones, green zones, faction territories, and automated doors.

```pawn
new STREAMER_TAG_AREA:gGreenZone;

public OnGameModeInit() {
    // 3D Cylinder or Circle: (Float:x, Float:y, Float:size, worldid, interiorid, playerid)
    gGreenZone = CreateDynamicCircle(1481.18, -1771.55, 45.0, 0, 0, -1);
    return 1;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid) {
    if (areaid == gGreenZone) {
        SetPlayerArmedWeapon(playerid, 0); // Disarm
        SendClientMessage(playerid, 0x00FF00FF, "[SAFEZONE] Anda telah memasuki Green Zone. Senjata dinonaktifkan.");
    }
    return 1;
}

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid) {
    if (areaid == gGreenZone) {
        SendClientMessage(playerid, 0xFF0000FF, "[SAFEZONE] Anda telah meninggalkan Green Zone.");
    }
    return 1;
}
```

## Performance & Optimization Best Practices
1. **Tune Stream Distances:**
   - Small props / furniture: `50.0 - 100.0`
   - Medium buildings / structures: `200.0 - 300.0`
   - Map icons: `100.0`
   - 3D Text labels: `10.0 - 20.0` (never exceed 25m to prevent screen clutter)
2. **Interior & Virtual World Isolation:**
   - Always assign explicit `worldid` and `interiorid` to avoid rendering entities for players outside those dimensions.
3. **Streamer Tick Rate:**
   - In `server.cfg`, keep `stream_rate 1000` (1 second tick) or `stream_distance 250.0` for 100+ concurrent players.
