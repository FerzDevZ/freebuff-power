---
name: samp-mapping-dynamic-objects-pro
description: Modern 2026 MLO Mapping, Dynamic Objects & Interactive World Engineering for SA-MP & open.mp — Texture Studio retexturing (SetDynamicObjectMaterial & glowing SetDynamicObjectMaterialText), Streamer_UpdateEx anti-fall-through floor preloading, priority streaming, SetDynamicObjectNoCameraCol, physical ox_doorlock animated doors/elevators, vehicle/player prop attachments, live EditDynamicObject furniture editor, and Dynamic Actors replacing archaic pickups.
---

# Modern 2026 MLO Mapping & Dynamic Object Engineering (SA-MP & open.mp)

Stop building 2012 servers with flat default GTA textures, spinning yellow pickups (`1239`), floating neon green 3D text, and players falling through custom interior floors! Modern 2026 SA-MP/open.mp servers use **FiveM MLO-grade custom interiors**, **material retexturing**, **animated physical doors**, **Dynamic Actors**, and **zero-fall streaming architecture**.

---

## 0. Runtime (open.mp v1.6.7.3218, Oct 2026)

- **Binary**: `omp-server` (32-bit), config `config.json`
- **NPC**: official NPC component (replaces FCNPC plugin) with vehicle position/rotation natives
- **Artwork**: `artwork.show_crc_logs` for TXD/DFF CRC logging (disabled by default)
- **C API**: native C++ SDK for custom components; Pawn natives callable from C++
- **Build**: Conan 2 support, macOS ARM build support
- **Launcher**: v1.7.0 with smoother overlay, ENB compat, models cache folder, recently used nicknames
- **Streamer**: legacy plugin via `legacy_plugins` OR native component port (`OpenSamp/omp-streamer-component`)
- **Custom models**: `artwork` block in `config.json` (replaces `artconfig.txt`)
- **Map editors 2026**: SA Map Studio v4.3.0 (all-in-one, AI integration, local test server), Texture Studio Remastered 2.0 (in-game, SQLite persistence), MapTogether (co-op, Claude AI, room generator), SanMap Studio (offline 3D, Three.js)

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

## 6. Compile-verified example

`resources/example_retextured_interior.pwn` demonstrates the full modern pattern:
- Data-table + loop instead of 200-line copy-paste `CreateDynamicObject`
- `SetDynamicObjectMaterial` retexturing with ARGB color (0xAARRGGBB)
- `invisible` texture to hide parts of models
- `grey-X-percent` for alpha/transparency
- `RemoveBuildingForPlayer` batch in `OnPlayerConnect`
- `Streamer_UpdateEx` anti-fall-through teleport
- Priority-tiered streaming (`MAP_PRIO_STRUCTURE = 10`)
Compiles clean on both open.mp and legacy targets.

## 7. Design-to-code pipeline (general, any interior/exterior)

When asked to build ANY new map (interior or exterior), follow this pipeline.
Do NOT copy-paste from examples; use the patterns as building blocks.

### Step 1: Parse the request
- Interior or exterior?
- What is the space? (shop, house, office, police station, hospital, etc.)
- Size/scale? (small room, large hall, multi-floor)
- Style? (modern, rustic, industrial, luxury, etc.)
- Special features? (doors, windows, lighting, props, vehicles)

### Step 2: Plan the space (ASCII floor plan)
```
┌─────────────────────────────────┐
│  [door]  ─── wall ───  [window] │
│  │                              │
│  [desk]   [chair]   [shelf]     │  <- furniture zone
│  │                              │
│  ─── wall ───  [door]  ─────── │
└─────────────────────────────────┘
```
- Define zones: entrance, main area, secondary rooms, exits
- Plan traffic flow: how players move through the space
- Plan lighting: where lights go, what they illuminate
- Plan props: what objects fill the space

### Step 3: Choose base models
Common base models for retexturing:
- 18765 (wall panel) - retexture for walls, floors, ceilings
- 18766 (wall panel variant) - different size/shape
- 18981 (floor tile) - retexture for floors
- 18762 (corner) - retexture for corners
- 19379 (window frame) - retexture for windows
- 19462 (door frame) - retexture for doors
- 19370 (pillar) - retexture for pillars
- 19443 (railing) - retexture for railings

### Step 4: Choose materials and textures
- Walls: `matcolours` grey-X-percent for solid colors, or `airportgnd_sfse` white for clean
- Floors: `traidman` wood, `airportgnd_sfse` white, or custom
- Ceilings: `invisible` to hide, or `airportgnd_sfse` white
- Glass: `grey-80-percent` or `invisible` with alpha
- Metal: `airportgnd_sfse` white with dark color
- Wood: `traidman` or `wood` textures
- Hiding parts: `invisible` texture

### Step 5: Place objects with precise coordinates
- Use a data table + loop for repeated elements
- Use precise rotations for diagonal walls (45°, 135°, etc.)
- Set priority: structures = 10, details = 5, props = 1
- Use `SetDynamicObjectMaterial` for retexturing
- Use `RemoveBuildingForPlayer` to clear vanilla
- Use `Streamer_UpdateEx` for anti-fall-through

### Step 6: Verify
1. Compile both targets (0 warnings, 0 errors)
2. Check object count (≤1000 per area)
3. Check streaming performance (no lag on entry)
4. Check collision (players can walk, doors open)
5. Check lighting (no dark spots, no over-bright)

### Interior design principles
- **Space planning**: Define zones, traffic flow, focal points
- **Lighting**: Use multiple light sources, avoid dark corners
- **Props**: Fill space but don't clutter; leave walkways clear
- **Scale**: Objects should be proportionate to the space
- **Consistency**: Use the same material palette throughout
- **Detail**: Add small details (papers, cups, signs) for realism

### Exterior design principles
- **Terrain**: Use `RemoveBuildingForPlayer` to clear, then add custom terrain
- **Buildings**: Use base models + retexturing for facades
- **Landscaping**: Add trees, bushes, fences, roads
- **Lighting**: Street lights, building lights, signs
- **Props**: Benches, trash cans, parking meters, etc.
- **LOD**: Use lower-detail models for distant objects

### Common interior types

**Shop (24/7, clothing, gun, etc.)**: Counter + shelves + products + door + lighting
**House/apartment**: Living room + kitchen + bedroom + bathroom + door + windows
**Office**: Desks + chairs + computers + filing cabinets + meeting room + door
**Police station**: Desks + cells + evidence room + armory + briefing room + door
**Hospital**: Beds + medical equipment + reception + pharmacy + door + windows
**Bank**: Counters + vault + ATMs + security + door + windows
**Restaurant**: Tables + chairs + kitchen + bar + door + windows
**Garage**: Vehicle spots + tools + lifts + door + lighting

### Common exterior types

**Building facade**: Walls + windows + door + roof + signs + lighting
**Parking lot**: Asphalt + lines + lights + barriers + vehicles
**Park**: Grass + trees + benches + paths + lights
**Street**: Road + sidewalks + buildings + lights + signs + vehicles
**Compound**: Fence + gate + buildings + parking + security

### Performance optimization
- **Object count**: ≤500 per streaming area, ≤1000 total
- **Draw distance**: Set appropriate draw distance per object
- **LOD**: Use lower-detail models for distant objects
- **Streaming**: Use priority tiers (structures 10, details 5, props 1)
- **Collision**: Only add collision where needed
- **Materials**: Reuse textures, avoid unique materials per object

## 8. Dynamic Actors Replacing Archaic Spinning Pickups

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

