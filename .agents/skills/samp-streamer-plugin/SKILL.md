---
name: samp-streamer-plugin
description: Modern 2026 Incognito Streamer Plugin Architecture for open.mp & SA-MP — priority-tiered Dynamic Objects, Streamer_UpdateEx anti-fall-through preloading, SetDynamicObjectMaterial/MaterialText retexturing, SetDynamicObjectNoCameraCol, Dynamic Actors replacing archaic pickups, O(1) Dynamic Area spatial dispatchers, and 1000+ player tick tuning.
---

# Modern 2026 Incognito Streamer Architecture (open.mp & SA-MP)

Incognito's Streamer Plugin is the spatial backbone of every modern open.mp / SA-MP server — powering custom MLO interiors, O(1) `[E]`/`[Y]` proximity interaction zones, `ox_doorlock` animated doors, living Dynamic Actors, and 3D physical loot drops while respecting the client's 1000-visible-object limit.

---

## 1. Modern Inclusion & Production Configuration

```pawn
#include <open.mp>
#include <streamer>
```
Deployment differs by build (2026):
- **Legacy plugin** (Incognito, SA-MP build) on an open.mp server → `plugins/streamer.so` + `config.json`
  `"pawn": { "legacy_plugins": ["streamer"] }`.
- **Native component port** (`OpenSamp/omp-streamer-component`) → drop the binary in
  `components/`, remove it from `legacy_plugins`, keep the same `#include <streamer>`
  and native calls.

Never run both at once: two streamers means two entity pools and duplicated objects.
```json
"pawn": {
  "legacy_plugins": ["streamer"]
}
```

### Mandatory `OnGameModeInit` Performance Tuning
```pawn
public OnGameModeInit()
{
    // Keep 80 slots headroom below GTA SA's hard 1000-object client cap (for props & Mobile stability)
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 920);
    Streamer_SetVisibleItems(STREAMER_TYPE_3D_TEXT_LABEL, 256);
    Streamer_SetVisibleItems(STREAMER_TYPE_ACTOR, 64);

    // Smooth streaming tick rate & cell size for dense RP cities
    Streamer_SetTickRate(50);
    Streamer_SetCellSize(200.0);
    return 1;
}
```

---

## 2. Priority-Tiered Dynamic Objects & Anti-Fall Preloading

Never let decorative plants or bottles steal visible object slots from custom MLO floors and walls:
```pawn
#define PRIO_FLOOR_WALL  (10)
#define PRIO_INTERACTIVE (5)
#define PRIO_CLUTTER     (0)

// Create structural MLO object with high priority and optional NoCameraCol
new STREAMER_TAG_OBJECT:gFloor = CreateDynamicObject(
    19377, 1500.0, -1700.0, 1500.0, 0.0, 0.0, 0.0,
    .worldid = 10, .interiorid = 1,
    .streamdistance = 250.0, .drawdistance = 250.0,
    .priority = PRIO_FLOOR_WALL
);
SetDynamicObjectNoCameraCol(gFloor); // Stops camera snapping inside tight custom rooms!

// Preload dynamic floors BEFORE releasing player gravity (eliminates falling into void!)
stock SafeEnterCustomInterior(playerid, Float:x, Float:y, Float:z, Float:a, worldid, interiorid)
{
    SetPlayerVirtualWorld(playerid, worldid);
    SetPlayerInterior(playerid, interiorid);
    Streamer_UpdateEx(playerid, x, y, z, worldid, interiorid, STREAMER_TYPE_OBJECT, 600, 1);
    SetPlayerPos(playerid, x, y, z + 0.15);
    SetPlayerFacingAngle(playerid, a);
    SetCameraBehindPlayer(playerid);
}
```

---

## 3. O(1) Spatial Triggers (`CreateDynamicSphere` + `E_STREAMER_EXTRA_ID`)

**2026 Modern Rule:** Replace archaic 2012 spinning pickups (`1239`) and ugly neon `{00FF00}` 3D text walls with clean **Dynamic Areas + `[E]`/`[Y]` FiveM Interaction Pills** and **Dynamic Actors**:

```pawn
enum E_ZONE_KIND
{
    ZONE_NONE = 0,
    ZONE_SAFEZONE,
    ZONE_INTERACT_ATM,
    ZONE_INTERACT_GARAGE,
    ZONE_INTERACT_NPC_SHOP
};

stock STREAMER_TAG_AREA:RegisterInteractPoint(E_ZONE_KIND:kind, entityId, Float:x, Float:y, Float:z, Float:radius = 2.2, worldid = 0, interiorid = 0)
{
    new STREAMER_TAG_AREA:area = CreateDynamicSphere(x, y, z, radius, worldid, interiorid);
    new payload[2];
    payload[0] = _:kind;
    payload[1] = entityId;
    Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, payload);
    return area;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    new payload[2];
    Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, payload);
    switch (E_ZONE_KIND:payload[0])
    {
        case ZONE_INTERACT_ATM: ShowFiveMInteractPill(playerid, "[Y] Access Bank ATM", payload[1]);
        case ZONE_INTERACT_GARAGE: ShowFiveMInteractPill(playerid, "[Y] Open Garage", payload[1]);
        case ZONE_SAFEZONE: SetPlayerSafeZone(playerid, true);
    }
    return 1;
}
```

---

## 4. Living Dynamic Actors (Modern Replacement for Static Pickups)

```pawn
new STREAMER_TAG_ACTOR:gTeller = CreateDynamicActor(
    141, 1499.88, -1709.84, 14.05, 180.0,
    .invulnerable = 1, .health = 100.0,
    .worldid = 0, .interiorid = 0, .streamdistance = 60.0
);
ApplyDynamicActorAnimation(gTeller, "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 0, 0);
```

---

## 5. Smooth Physical Doors & Vehicle Props
- **Hinged Doors (`MoveDynamicObject`):** Always add a `0.001` Z offset if rotating in place, otherwise GTA SA snaps rotation instantly instead of smoothly swinging!
- **Vehicle Props (`AttachDynamicObjectToVehicle`):** Track every attached object ID in a vehicle array and destroy all attachments in `OnVehicleDeath` / `DestroyVehicle`.
- **Material & Signage:** Always use **ARGB** (`0xAARRGGBB`) in `SetDynamicObjectMaterial` and `SetDynamicObjectMaterialText`, never RGBA!
- For advanced MLO retexturing, lighting, and in-game furniture editors, pair this skill with **`samp-mapping-dynamic-objects-pro`**.
