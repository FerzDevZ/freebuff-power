---
name: samp-vehicle-system
description: Vehicle system for SA-MP/open.mp — spawn/despawn lifecycle, fuel, damage, keys, garage, tuning persistence, and anti-exploit validation. Use when building vehicle systems, garages, or vehicle-related features.
---

# SA-MP/Open.mp Vehicle System (2026)

## When to Activate
- Building vehicle spawn/despawn system
- Implementing fuel consumption
- Adding vehicle keys/ownership
- Creating garage/parking system
- Persisting vehicle tuning/mods

## Core Concepts

### 1. Vehicle Data Structure
```pawn
enum E_VEHICLE {
    veh_id, veh_model, veh_owner,
    Float:veh_x, Float:veh_y, Float:veh_z, Float:veh_a,
    veh_color1, veh_color2, veh_paintjob,
    veh_fuel, veh_health, veh_locked,
    veh_engine, veh_lights,
    veh_mods[14], veh_plate[32],
    veh_last_used, veh_spawned
};
```

### 2. Vehicle Spawn with Persistence
```pawn
stock SpawnPlayerVehicle(playerid, slot) {
    new vid = CreateVehicle(g_vehicles[playerid][slot][veh_model],
        g_vehicles[playerid][slot][veh_x],
        g_vehicles[playerid][slot][veh_y],
        g_vehicles[playerid][slot][veh_z],
        g_vehicles[playerid][slot][veh_a],
        g_vehicles[playerid][slot][veh_color1],
        g_vehicles[playerid][slot][veh_color2], -1);
    SetVehicleHealth(vid, g_vehicles[playerid][slot][veh_health]);
    // Apply mods
    for (new i = 0; i < 14; i++) {
        if (g_vehicles[playerid][slot][veh_mods][i] > 0)
            AddVehicleComponent(vid, g_vehicles[playerid][slot][veh_mods][i]);
    }
    return vid;
}
```

### 3. Fuel System
```pawn
stock UpdateVehicleFuel(vehicleid) {
    new Float:speed = GetVehicleSpeed(vehicleid);
    new Float:consumption = 0.0;
    if (speed > 0) consumption = 0.01 + (speed / 1000.0);
    g_vehicle_fuel[vehicleid] -= consumption;
    if (g_vehicle_fuel[vehicleid] <= 0) {
        g_vehicle_fuel[vehicleid] = 0;
        // Turn off engine
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
    }
}
```

### 4. Vehicle Keys
```pawn
stock bool:HasVehicleKey(playerid, vehicleid) {
    // Check if player owns this vehicle or has a copy
    if (g_vehicle_owner[vehicleid] == GetPlayerSQLId(playerid)) return true;
    // Check shared keys
    for (new i = 0; i < MAX_SHARED_KEYS; i++) {
        if (g_shared_keys[playerid][i] == vehicleid) return true;
    }
    return false;
}
```

### 5. Garage System
```pawn
stock ParkVehicle(playerid, vehicleid) {
    new Float:x, Float:y, Float:z, Float:a;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, a);
    // Save to DB
    new query[512];
    mysql_format(g_db, query, sizeof(query),
        "UPDATE vehicles SET pos_x=%.4f, pos_y=%.4f, pos_z=%.4f, pos_a=%.4f, fuel=%d, health=%.1f, locked=%d WHERE id=%d",
        x, y, z, a, g_vehicle_fuel[vehicleid], GetVehicleHealth(vehicleid), g_vehicle_locked[vehicleid], g_vehicle_db_id[vehicleid]);
    mysql_tquery(g_db, query);
    DestroyVehicle(vehicleid);
}
```

### 6. Anti-Exploit
- **Server-side fuel** — never trust client fuel
- **Validate vehicle creation** — check ownership before spawning
- **Rate limit tuning** — prevent rapid mod spam
- **Distance check** — player must be near vehicle to interact
- **Log all vehicle actions** — spawn, despawn, tuning, transfer

## Key Rules
1. **All vehicle state server-side** — fuel, health, mods
2. **Validate ownership** — before any vehicle interaction
3. **Persist on park/exit** — save state to database
4. **Anti-dupe** — prevent vehicle duplication exploits
5. **Log everything** — audit trail for vehicle actions

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