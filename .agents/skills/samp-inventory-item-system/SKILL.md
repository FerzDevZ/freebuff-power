---
name: samp-inventory-item-system
description: Designing robust Grid & Weight-based Inventory Systems for SA-MP & open.mp — slot architectures, item dropping in 3D space with streamer pickups, vehicle trunk/glovebox storage, item usage delegates, and MySQL persistence.
---

# SA-MP / open.mp Inventory & Item System Skill

## Overview
A production roleplay or survival server requires a modular, transaction-safe inventory system. Players need to store, consume, drop, and transfer items into vehicle trunks, house lockers, or other players.

---

## 1. Inventory Data Structure & Definitions

```pawn
// constants/inventory.inc
#define MAX_INVENTORY_SLOTS 20
#define MAX_PLAYER_WEIGHT   30.0 // kg

enum E_ITEM_DATA {
    itemModelID,            // GTA Object model for 3D drops
    itemName[32],
    Float:itemWeight,       // Weight per single unit in kg
    bool:itemIsStackable,
    itemMaxStack
};

enum E_PLAYER_INVENTORY {
    invItemID,              // 0 = empty slot
    invAmount,
    invExtraData            // e.g. weapon ammo or item durability
};
new PlayerInventory[MAX_PLAYERS][MAX_INVENTORY_SLOTS][E_PLAYER_INVENTORY];

// Master item registry table
new const gItemRegistry[][E_ITEM_DATA] = {
    {0, "Empty", 0.0, false, 0},
    {2702, "Smartphone", 0.2, false, 1},
    {19822, "First Aid Kit", 1.5, true, 5},
    {2703, "Repair Kit", 5.0, false, 1},
    {2843, "Bottled Water", 0.5, true, 10},
    {2768, "Cheeseburger", 0.3, true, 10},
    {2038, "Lockpick", 0.1, true, 20}
};
```

---

## 2. Weight Calculation & Safe Item Addition

```pawn
stock Float:Inventory_GetTotalWeight(playerid) {
    new Float:total = 0.0;
    for (new s = 0; s < MAX_INVENTORY_SLOTS; s++) {
        new id = PlayerInventory[playerid][s][invItemID];
        if (id > 0) {
            total += gItemRegistry[id][itemWeight] * float(PlayerInventory[playerid][s][invAmount]);
        }
    }
    return total;
}

stock bool:Inventory_AddItem(playerid, itemid, amount = 1) {
    if (itemid <= 0 || amount <= 0) return false;

    // 1. Weight capacity check
    new Float:addedWeight = gItemRegistry[itemid][itemWeight] * float(amount);
    if ((Inventory_GetTotalWeight(playerid) + addedWeight) > MAX_PLAYER_WEIGHT) {
        SendClientMessage(playerid, 0xFF0000FF, "[INVENTORY] Kapasitas beban Anda telah melebihi batas maksimal!");
        return false;
    }

    // 2. Check for existing stackable slot
    if (gItemRegistry[itemid][itemIsStackable]) {
        for (new s = 0; s < MAX_INVENTORY_SLOTS; s++) {
            if (PlayerInventory[playerid][s][invItemID] == itemid) {
                PlayerInventory[playerid][s][invAmount] += amount;
                Inventory_SaveSlot(playerid, s);
                return true;
            }
        }
    }

    // 3. Find first empty slot
    for (new s = 0; s < MAX_INVENTORY_SLOTS; s++) {
        if (PlayerInventory[playerid][s][invItemID] == 0) {
            PlayerInventory[playerid][s][invItemID] = itemid;
            PlayerInventory[playerid][s][invAmount] = amount;
            Inventory_SaveSlot(playerid, s);
            return true;
        }
    }

    SendClientMessage(playerid, 0xFF0000FF, "[INVENTORY] Slot tas Anda sudah penuh!");
    return false;
}
```

---

## 3. Dropping Items in 3D Space (Incognito Streamer)
When a player drops an item, spawn a dynamic 3D object and label in the game world:

```pawn
#define MAX_DROPPED_ITEMS 500

enum E_DROPPED_ITEM {
    bool:dActive,
    dItemID,
    dAmount,
    STREAMER_TAG_OBJECT:dObject,
    STREAMER_TAG_3D_TEXT_LABEL:dLabel,
    STREAMER_TAG_PICKUP:dPickup
};
new DroppedItems[MAX_DROPPED_ITEMS][E_DROPPED_ITEM];

stock DropItem(playerid, slot) {
    new id = PlayerInventory[playerid][slot][invItemID];
    new amount = PlayerInventory[playerid][slot][invAmount];
    if (id == 0) return;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // Spawn 3D dropped entity slightly in front of player
    new freeIdx = -1;
    for (new i = 0; i < MAX_DROPPED_ITEMS; i++) {
        if (!DroppedItems[i][dActive]) { freeIdx = i; break; }
    }
    if (freeIdx == -1) return;

    DroppedItems[freeIdx][dActive] = true;
    DroppedItems[freeIdx][dItemID] = id;
    DroppedItems[freeIdx][dAmount] = amount;
    
    new labelText[64];
    format(labelText, sizeof(labelText), "{FFFF00}%s (%dx)\n{FFFFFF}Tekan ~k~~VEHICLE_ENTER_EXIT~", gItemRegistry[id][itemName], amount);

    DroppedItems[freeIdx][dObject] = CreateDynamicObject(gItemRegistry[id][itemModelID], x, y, z - 0.9, 0.0, 0.0, 0.0);
    DroppedItems[freeIdx][dLabel] = CreateDynamic3DTextLabel(labelText, 0xFFFFFFFF, x, y, z, 10.0);

    // Clear player inventory slot
    PlayerInventory[playerid][slot][invItemID] = 0;
    PlayerInventory[playerid][slot][invAmount] = 0;
    Inventory_SaveSlot(playerid, slot);

    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, false, false, false, false, 0);
}
```

---

## 4. Vehicle Trunk & Storage
Store items inside vehicle trunks with secure access verification:

```pawn
stock Trunk_StoreItem(playerid, vehicleid, slot) {
    // Verify vehicle trunk is open
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (boot != 1) {
        return SendClientMessage(playerid, 0xFF0000FF, "[BAGASI] Buka bagasi kendaraan terlebih dahulu (/trunk)!");
    }
    // Transfer item logic to vehicle_inventory table
}
```

## Inventory Invariants
- **Atomic Operations:** When transferring items between players or into trunks, update both parties inside a database transaction to prevent item duplication exploits.
- **Bounds Checking:** Always clamp `slot` index between `0` and `MAX_INVENTORY_SLOTS - 1`.

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

