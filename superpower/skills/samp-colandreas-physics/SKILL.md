---
name: samp-colandreas-physics
description: Server-side GTA SA Map Collision & Raycasting Physics for SA-MP & open.mp via ColAndreas — CA_RaycastLine line-of-sight verification, anti-silent-aim bullet validation, CA_FindZ_For2DCoord elevation math, and obstacle pathfinding.
---

# SA-MP / open.mp ColAndreas Physics & Raycasting Skill

## Overview
By default, the SA-MP server has zero knowledge of the GTA San Andreas 3D physical world — all collision detection runs client-side. **ColAndreas** loads the complete GTA SA map collision mesh directly into the server's RAM, enabling authoritative server-side physics, raycasting, and anti-cheat validation.

---

## 1. Setup & Inclusion
- Plugin: `ColAndreas.so` (Linux) or `ColAndreas.dll` (Windows)
- Pawn Include: `#include <colandreas>`
- Initialization in `OnGameModeInit`:
  ```pawn
  public OnGameModeInit() {
      CA_Init(); // Loads collision database into server memory
      print("[ColAndreas] Collision mesh loaded successfully.");
      return 1;
  }
  ```

---

## 2. Server-Side Bullet Raycasting (Anti-Silent Aim / Wallshot)
Validate whether a bullet fired by a player has a clear line-of-sight to the victim, or if it illegally traveled through a solid building, ground, or wall:

```pawn
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {
    if (hittype == BULLET_HIT_TYPE_PLAYER) {
        new Float:ox, Float:oy, Float:oz; // Origin (Muzzle)
        GetPlayerLastShotVectors(playerid, ox, oy, oz, fX, fY, fZ);

        new Float:hitX, Float:hitY, Float:hitZ;
        // CA_RaycastLine returns the model ID of hit object, or 0 if path is clear
        new hitObject = CA_RaycastLine(ox, oy, oz, fX, fY, fZ, hitX, hitY, hitZ);

        if (hitObject != 0) {
            // Bullet hit a solid world obstruction before reaching the victim!
            new Float:distObstacle = VectorSize(ox - hitX, oy - hitY, oz - hitZ);
            new Float:distVictim = VectorSize(ox - fX, oy - fY, oz - fZ);

            if (distObstacle < (distVictim - 0.5)) {
                // Illegal wall penetration detected!
                AntiCheat_Flag(playerid, "Wallshot / Silent-Aim", distObstacle);
                return 0; // Cancel damage event
            }
        }
    }
    return 1;
}
```

---

## 3. Ground Elevation Detection (`CA_FindZ_For2DCoord`)
Find the exact ground height for any coordinate. Essential for:
- Preventing vehicle spawns from clipping into the floor or spawning in the sky.
- Anti-Airbreak: checking if an on-foot player's Z coordinate is abnormally far above the actual ground terrain.

```pawn
stock SpawnVehicleOnGround(modelid, Float:x, Float:y, Float:angle, c1, c2) {
    new Float:groundZ;
    // Raycasts downward from height 1000.0 to find terrain surface
    CA_FindZ_For2DCoord(x, y, groundZ);
    
    // Spawn vehicle slightly above ground to let wheels settle naturally
    return CreateVehicle(modelid, x, y, groundZ + 0.5, angle, c1, c2, -1);
}

stock bool:IsPlayerFlying(playerid) {
    new Float:px, Float:py, Float:pz, Float:groundZ;
    GetPlayerPos(playerid, px, py, pz);
    CA_FindZ_For2DCoord(px, py, groundZ);

    // If player is on-foot, not parachuting, and > 8 meters above physical ground
    if (GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID &&
        GetPlayerWeapon(playerid) != 46 && // Parachute
        (pz - groundZ) > 8.0) 
    {
        return true;
    }
    return false;
}
```

---

## 4. Line-of-Sight Check (NPC Visibility / Dynamic Doors)
Check if two players or an NPC can see each other:

```pawn
stock bool:HasLineOfSight(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2) {
    new Float:hx, Float:hy, Float:hz;
    // Returns 0 if no obstacle between point 1 and point 2
    return (CA_RaycastLine(x1, y1, z1, x2, y2, z2, hx, hy, hz) == 0);
}
```

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

