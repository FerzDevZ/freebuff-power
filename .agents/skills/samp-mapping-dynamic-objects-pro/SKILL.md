---
name: samp-mapping-dynamic-objects-pro
description: Modern 2026 MLO Mapping, Dynamic Objects & Interactive World Engineering for SA-MP & open.mp — Texture Studio retexturing (SetDynamicObjectMaterial & glowing SetDynamicObjectMaterialText), Streamer_UpdateEx anti-fall-through floor preloading, priority streaming, SetDynamicObjectNoCameraCol, physical ox_doorlock animated doors/elevators, vehicle/player prop attachments, live EditDynamicObject furniture editor, and Dynamic Actors replacing archaic pickups.
---

# Modern 2026 MLO Mapping & Dynamic Object Engineering (SA-MP & open.mp)

Stop building 2012 servers with flat default GTA textures, spinning yellow pickups (`1239`), floating neon green 3D text, and players falling through custom interior floors! Modern 2026 SA-MP/open.mp servers use **FiveM MLO-grade custom interiors**, **material retexturing**, **animated physical doors**, **Dynamic Actors**, and **zero-fall streaming architecture**.

---

## 1. Anti-Fall-Through Floor Preloading (`Streamer_UpdateEx`)

When teleporting a player into a custom mapped MLO interior (or high-altitude custom shell), standard `SetPlayerPos` drops the player into the void before dynamic floor objects stream in.

### The 2026 Production Teleport Pattern
```pawn
#include <open.mp>
#include <streamer>

// Guarantees custom dynamic floors/walls stream BEFORE gravity applies
stock TeleportToCustomMLO(playerid, Float:x, Float:y, Float:z, Float:angle, worldid, interiorid, preloadMs = 600)
{
    SetPlayerVirtualWorld(playerid, worldid);
    SetPlayerInterior(playerid, interiorid);

    // Freeze & stream ONLY objects around destination FIRST (freezeplayer = 1)
    Streamer_UpdateEx(playerid, x, y, z, worldid, interiorid, STREAMER_TYPE_OBJECT, preloadMs, 1);

    SetPlayerPos(playerid, x, y, z + 0.15);
    SetPlayerFacingAngle(playerid, angle);
    SetCameraBehindPlayer(playerid);
    return 1;
}
```

### Priority-Tiered Object Streaming (Critical Floors NEVER Pop Out)
Assign `E_STREAMER_PRIORITY` so structural surfaces ALWAYS win the 1000-visible-object client budget over clutter props:
```pawn
#define MAP_PRIO_STRUCTURE   (10) // Floors, walls, ceilings, stairs, doors
#define MAP_PRIO_INTERACTIVE (5)  // ATMs, vending machines, workbenches, safes
#define MAP_PRIO_DECOR       (0)  // Plants, paintings, mugs, bottles, rugs

stock STREAMER_TAG_OBJECT:CreateMLOObject(
    modelid,
    Float:x, Float:y, Float:z,
    Float:rx, Float:ry, Float:rz,
    worldid = 0, interiorid = 0,
    priority = MAP_PRIO_STRUCTURE,
    bool:noCamCol = false,
    Float:streamDist = 250.0,
    Float:drawDist = 250.0
)
{
    new STREAMER_TAG_OBJECT:obj = CreateDynamicObject(
        modelid, x, y, z, rx, ry, rz,
        worldid, interiorid, -1, streamDist, drawDist, -1, priority
    );
    if (noCamCol)
    {
        SetDynamicObjectNoCameraCol(obj); // Prevents camera snapping in tight hallways/interiors!
    }
    return obj;
}
```
> **Client Safety Cap:** Set `Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 920);` in `OnGameModeInit` to keep 80 object slots free as headroom for attached props, dynamic drops, and SA-MP Mobile stability!

---

## 2. MLO-Grade Retexturing & Glowing Signage (`Material` & `MaterialText`)

Turn basic GTA SA primitives (`19377`, `19447` walls, `19353` panels, `19475` boards) into luxury FiveM interiors (dark obsidian marble, glass partitions, warm oak slats, brushed aluminum, glowing neon signs):

```pawn
// Modern Luxury Interior Material Presets (modelid, txdname, texturename, argbColor)
// Notice ARGB format (0xAARRGGBB) — NOT RGBA!
stock ApplyModernMaterial(STREAMER_TAG_OBJECT:obj, materialIndex, const preset[])
{
    if (!strcmp(preset, "dark_marble", true))
        SetDynamicObjectMaterial(obj, materialIndex, 16150, "ufo_bar", "marble_01", 0xFF2B313C);
    else if (!strcmp(preset, "warm_oak", true))
        SetDynamicObjectMaterial(obj, materialIndex, 14826, "int_kitch", "cj_wood5", 0xFFD9C2A3);
    else if (!strcmp(preset, "matte_slate", true))
        SetDynamicObjectMaterial(obj, materialIndex, 19447, "wall_textures", "concrete_01", 0xFF141923);
    else if (!strcmp(preset, "frosted_glass", true))
        SetDynamicObjectMaterial(obj, materialIndex, 1649, "wglasssmash", "glass01", 0x88CFE8FF);
    else if (!strcmp(preset, "brushed_metal", true))
        SetDynamicObjectMaterial(obj, materialIndex, 19353, "metal_tex", "metal_dark", 0xFF3A4252);
}

// Crisp Transparent Neon/LED Signage on Flat Panel (e.g. model 19477 / 19482)
stock ApplyModernSignage(
    STREAMER_TAG_OBJECT:obj,
    const text[],
    fontSize = 48,
    argbTextColor = 0xFF10B981, // Emerald ARGB
    argbBackColor = 0x00000000  // Transparent background!
)
{
    SetDynamicObjectMaterialText(
        obj, 0, text,
        OBJECT_MATERIAL_SIZE_512x128,
        "Segoe UI", fontSize, 1,
        argbTextColor, argbBackColor,
        OBJECT_MATERIAL_TEXT_ALIGN_CENTER
    );
}
```

### Interior Lighting & Exterior Removal
- **Batch `RemoveBuildingForPlayer`** inside `OnPlayerConnect` (max ~1000 removals per client; never duplicate calls on reconnect/spawn!).
- **Custom Warm/Cool Lighting Props:** Use invisible/subtle GTA light emitter objects (`19281`–`19298`, `18656`–`18658`) recessed into custom ceilings for authentic FiveM ambient lighting.

---

## 3. Physical Animated Doors & Gates (`ox_doorlock` Style)

Replace instant teleport markers with **real swinging/sliding physical doors** that obey faction/key/lockpick permissions:

```pawn
enum E_DOOR_DATA
{
    bool:doorUsed,
    STREAMER_TAG_OBJECT:doorObj,
    STREAMER_TAG_AREA:doorArea,
    doorModel,
    Float:doorClosedPos[6], // x, y, z, rx, ry, rz
    Float:doorOpenPos[6],   // x, y, z, rx, ry, rz
    Float:doorSpeed,
    bool:doorLocked,
    bool:doorIsOpen,
    doorFactionId,
    doorRequiredItemId
};
new gDoors[MAX_DOORS][E_DOOR_DATA];

stock TogglePhysicalDoor(playerid, doorid)
{
    if (gDoors[doorid][doorLocked])
    {
        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0); // Locked rattle SFX
        Ox_Notify(playerid, "Door Locked", "You need an authorized keycard or lockpick.", "error", 2500);
        return 0;
    }

    gDoors[doorid][doorIsOpen] = !gDoors[doorid][doorIsOpen];
    if (gDoors[doorid][doorIsOpen])
    {
        // Note: MoveDynamicObject requires tiny Z delta (0.001) if ONLY rotating a hinged door!
        MoveDynamicObject(
            gDoors[doorid][doorObj],
            gDoors[doorid][doorOpenPos][0],
            gDoors[doorid][doorOpenPos][1],
            gDoors[doorid][doorOpenPos][2] + 0.001,
            gDoors[doorid][doorSpeed],
            gDoors[doorid][doorOpenPos][3],
            gDoors[doorid][doorOpenPos][4],
            gDoors[doorid][doorOpenPos][5]
        );
    }
    else
    {
        MoveDynamicObject(
            gDoors[doorid][doorObj],
            gDoors[doorid][doorClosedPos][0],
            gDoors[doorid][doorClosedPos][1],
            gDoors[doorid][doorClosedPos][2],
            gDoors[doorid][doorSpeed],
            gDoors[doorid][doorClosedPos][3],
            gDoors[doorid][doorClosedPos][4],
            gDoors[doorid][doorClosedPos][5]
        );
    }
    return 1;
}
```
> **GTA SA Engine Gotcha:** `MoveDynamicObject` will NOT smoothly interpolate rotation (`rx, ry, rz`) if `x, y, z` are 100% identical to the current position! Always add a `0.001` Z nudge when swinging a hinged door!

---

## 4. Vehicle & Player Tactical Attachments

### A. Vehicle Attachments (`AttachDynamicObjectToVehicle`)
Used for Police Lightbars (`19419`/`19620`), Flatbed Tow Cargo (`2912`/`1271`), Roof Racks, Neon Underglow (`18647`–`18652`), and Custom Tuning Parts:
```pawn
new STREAMER_TAG_OBJECT:crate = CreateDynamicObject(2912, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
AttachDynamicObjectToVehicle(crate, vehicleid, 0.0, -1.65, 0.35, 0.0, 0.0, 0.0);
```
> **Cleanup Invariant:** Always track attached dynamic object IDs in a `VehAttachments[MAX_VEHICLES][MAX_VEH_ATTACH]` array and destroy every one inside `OnVehicleDeath` / `DestroyVehicle` so orphaned objects never float at `(0.0, 0.0, 0.0)`.

### B. Player Props (`SetPlayerAttachedObject`)
- Carrying crate/box (`model 2912`, bone `6` Right Hand + `SPECIAL_ACTION_CARRY`)
- Smartphone (`model 18867`, bone `6` + `SPECIAL_ACTION_USECELLPHONE`)
- Backpack (`model 3026` / `371`, bone `1` Spine)
- Holstered Rifle on back (`model 356`, bone `1` Spine when weapon not in hand)

---

## 5. Live In-Game Furniture & Mapping Editor (`EditDynamicObject`)

Give admins and homeowners a true **FiveM Housing Furniture Gizmo Editor**:
```pawn
hook OnPlayerEditDynamicObject(
    playerid,
    STREAMER_TAG_OBJECT:objectid,
    EDIT_RESPONSE:response,
    Float:x, Float:y, Float:z,
    Float:rx, Float:ry, Float:rz
)
{
    if (response == EDIT_RESPONSE_FINAL)
    {
        // Validate furniture stays strictly inside player's owned house boundary!
        if (!IsPointInHouseBounds(playerid, x, y, z))
        {
            RestoreOriginalFurniturePos(playerid, objectid);
            Ox_Notify(playerid, "Out of Bounds", "Furniture must stay inside your property.", "error", 3000);
            return 1;
        }
        SetDynamicObjectPos(objectid, x, y, z);
        SetDynamicObjectRot(objectid, rx, ry, rz);
        SaveFurnitureToMySQL(playerid, objectid, x, y, z, rx, ry, rz);
        Ox_Notify(playerid, "Saved", "Furniture position updated.", "success", 2500);
    }
    else if (response == EDIT_RESPONSE_CANCEL)
    {
        RestoreOriginalFurniturePos(playerid, objectid);
    }
    return 1;
}
```

---

## 6. Dynamic Actors Replacing Archaic Spinning Pickups

NEVER place floating yellow `1239` info pickups for shops, banks, or job bosses. Spawn living **Dynamic Actors** (`CreateDynamicActor`) with idle animations + `ox_target` / `[E]` interaction:
```pawn
new STREAMER_TAG_ACTOR:npc = CreateDynamicActor(
    211, // Store Clerk skin
    -27.95, -91.62, 1003.54, 0.0,
    .invulnerable = 1, .health = 100.0,
    .worldid = shopWorld, .interiorid = shopInt,
    .streamdistance = 50.0
);
ApplyDynamicActorAnimation(npc, "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 0, 0);
// Register a 2.5m Streamer Dynamic Sphere + Third-Eye Target on this Actor!
```
