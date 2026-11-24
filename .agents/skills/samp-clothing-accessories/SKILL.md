---
name: samp-clothing-accessories
description: Clothing and accessories system for SA-MP/open.mp — skin changes, clothing stores, accessory attachment, and outfit saving. Use when building clothing shops, accessory systems, or character customization.
---

# SA-MP/Open.mp Clothing & Accessories (2026)

## When to Activate
- Building clothing store system
- Implementing accessory attachment
- Creating outfit saving/loading
- Adding character customization
- Designing clothing UI

## Core Concepts

### 1. Skin System
```pawn
stock ChangeSkin(playerid, skinid, bool:save = true) {
    if (skinid < 0 || skinid > 311) return 0;
    SetPlayerSkin(playerid, skinid);
    if (save) {
        new query[128];
        mysql_format(g_db, query, sizeof(query), "UPDATE characters SET skin=%d WHERE id=%d", skinid, GetPlayerCharId(playerid));
        mysql_tquery(g_db, query);
    }
    return 1;
}
```

### 2. Accessory Attachment
```pawn
stock AttachAccessory(playerid, modelid, bone, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    new slot = GetFreeAccessorySlot(playerid);
    if (slot == -1) return 0;
    SetPlayerAttachedObject(playerid, slot, modelid, bone, x, y, z, rx, ry, rz);
    g_accessories[playerid][slot][acc_model] = modelid;
    g_accessories[playerid][slot][acc_bone] = bone;
    SaveAccessories(playerid);
    return slot;
}
```

### 3. Clothing Store
```pawn
stock ShowClothingStore(playerid, store_type) {
    // Show TextDraw UI with clothing items
    // Handle selection, preview, purchase
    // Apply skin/clothing on purchase
}
```

### 4. Outfit Saving
```pawn
stock SaveOutfit(playerid, const name[]) {
    new query[512];
    mysql_format(g_db, query, sizeof(query),
        "INSERT INTO outfits (char_id, name, skin, accessories) VALUES (%d, '%e', %d, '%e')",
        GetPlayerCharId(playerid), name, GetPlayerSkin(playerid), GetAccessoryJSON(playerid));
    mysql_tquery(g_db, query);
}
```

## Key Rules
1. **Server-side skin** — validate skin IDs
2. **Accessory limits** — max 10 per player
3. **Outfit persistence** — save to database
4. **Preview before buy** — show on player
5. **Anti-exploit** — prevent free clothing

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