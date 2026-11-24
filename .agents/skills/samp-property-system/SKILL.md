---
name: samp-property-system
description: Property and housing system for SA-MP/open.mp — buy/sell property, enter/exit interiors, furniture placement, rent, and property management. Use when building housing, real estate, or property features.
---

# SA-MP/Open.mp Property System (2026)

## When to Activate
- Building house/property purchase system
- Implementing enter/exit interiors
- Adding furniture placement
- Creating rent/lease system
- Managing property ownership

## Core Concepts

### 1. Property Data
```pawn
enum E_PROPERTY {
    prop_id, prop_type, prop_owner,
    Float:prop_x, Float:prop_y, Float:prop_z,
    Float:prop_ix, Float:prop_iy, Float:prop_iz, // interior
    prop_price, prop_rent, prop_locked,
    prop_furniture_count, prop_last_access
};
```

### 2. Purchase Flow
```pawn
stock BuyProperty(playerid, propid) {
    if (g_player_money[playerid] < g_property[propid][prop_price]) return 0;
    GivePlayerMoney(playerid, -g_property[propid][prop_price]);
    g_property[propid][prop_owner] = GetPlayerSQLId(playerid);
    SaveProperty(propid);
    LogPropertyAction(playerid, "BUY", propid);
    return 1;
}
```

### 3. Enter/Exit Interior
```pawn
stock EnterProperty(playerid, propid) {
    SetPlayerPos(playerid, g_property[propid][prop_ix], g_property[propid][prop_iy], g_property[propid][prop_iz]);
    SetPlayerInterior(playerid, g_property[propid][prop_interior]);
    SetPlayerVirtualWorld(playerid, propid + 1000);
    return 1;
}
```

### 4. Furniture System
```pawn
stock PlaceFurniture(playerid, propid, modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    new objid = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, .worldid = propid + 1000);
    SaveFurniture(propid, modelid, x, y, z, rx, ry, rz);
    return objid;
}
```

### 5. Rent System
```pawn
stock ProcessRent(propid) {
    if (g_property[propid][prop_owner] == 0) return;
    new rent = g_property[propid][prop_rent];
    DeductFromOwner(g_property[propid][prop_owner], rent);
    if (GetOwnerBalance(g_property[propid][prop_owner]) < 0) {
        // Evict if can't pay
        EvictProperty(propid);
    }
}
```

## Key Rules
1. **Validate ownership** — before any property action
2. **Server-side interiors** — use virtual worlds for privacy
3. **Persist furniture** — save to database
4. **Rent collection** — automated via timer
5. **Anti-exploit** — prevent property duplication

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