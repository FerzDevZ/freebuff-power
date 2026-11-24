---
name: samp-crafting-system
description: Crafting system for SA-MP/open.mp — recipes, crafting benches, material gathering, and item creation. Use when building crafting, gathering, or item creation systems.
---

# SA-MP/Open.mp Crafting System (2026)

## When to Activate
- Building crafting bench system
- Implementing recipe system
- Adding material gathering
- Creating item creation flow
- Designing crafting UI

## Core Concepts

### 1. Recipe Structure
```pawn
enum E_RECIPE {
    recipe_id, recipe_name[64], recipe_result_item,
    recipe_result_qty, recipe_craft_time,
    recipe_materials[5], recipe_material_qty[5],
    recipe_required_level, recipe_bench_type
};
```

### 2. Crafting Flow
```pawn
stock StartCrafting(playerid, recipeid) {
    // Check materials
    for (new i = 0; i < 5; i++) {
        if (g_recipes[recipeid][recipe_materials][i] > 0) {
            if (GetPlayerItem(playerid, g_recipes[recipeid][recipe_materials][i]) < g_recipes[recipeid][recipe_material_qty][i]) {
                return SendClientMessage(playerid, -1, "Not enough materials.");
            }
        }
    }
    // Remove materials
    for (new i = 0; i < 5; i++) {
        if (g_recipes[recipeid][recipe_materials][i] > 0) {
            RemovePlayerItem(playerid, g_recipes[recipeid][recipe_materials][i], g_recipes[recipeid][recipe_material_qty][i]);
        }
    }
    // Start crafting timer
    g_crafting[playerid] = true;
    g_craft_timer[playerid] = SetTimerEx("FinishCraft", g_recipes[recipeid][recipe_craft_time] * 1000, false, "ii", playerid, recipeid);
    return 1;
}
```

### 3. Crafting Bench
```pawn
stock CreateCraftingBench(type, Float:x, Float:y, Float:z) {
    new objid = CreateDynamicObject(BENCH_MODEL, x, y, z, 0, 0, 0);
    // Create interaction area
    new areaid = CreateDynamicSphere(x, y, z, 2.0);
    g_bench_type[areaid] = type;
    return objid;
}
```

### 4. Material Gathering
```pawn
stock GatherMaterial(playerid, materialid) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    // Check if near gathering node
    if (IsNearGatheringNode(playerid, materialid)) {
        GivePlayerItem(playerid, materialid, 1);
        LogPlayerAction(playerid, "GATHER", "Material collected");
    }
}
```

## Key Rules
1. **Server-side materials** — validate all items
2. **Recipe validation** — check all materials before craft
3. **Crafting timer** — prevent instant crafting
4. **Bench proximity** — must be near crafting bench
5. **Log all crafts** — audit trail

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