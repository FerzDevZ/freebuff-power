---
name: samp-openmp-modern-guide
description: Comprehensive guide to open.mp/SA-MP development — how open.mp works, syntax, functions, enums, modern textdraw design (based on Nexor's Textdraw Editor), map/interior design (based on Map-Editor-V3), and modern UI patterns. Use when building any SA-MP/open.mp feature and need deep understanding of the platform.
---

# SA-MP/Open.mp Modern Development Guide (2026)

## 1. How Open.mp Works

### Architecture
```
SA-MP Client (GTA SA) <-> Network (UDP) <-> Open.mp Server (C++ Core)
                                                |
                                           Plugins (.so/.dll)
                                                |
                                           Gamemode (.amx)
                                                |
                                           Filterscripts (.amx)
```

### Server Lifecycle
1. **Config load** → `config.json` (open.mp) or `server.cfg` (legacy)
2. **Component init** → core, network, scripting, plugins
3. **Gamemode load** → `OnGameModeInit` callback
4. **Player connect** → `OnPlayerConnect` callback
5. **Game loop** → 1000 ticks/sec (default), callbacks dispatched
6. **Shutdown** → `OnGameModeExit` callback

### Config (open.mp v1.6.7.3218)
```json
{
    "network": { "port": 7777, "max_players": 1000, "bind": "0.0.0.0" },
    "rcon": { "password": "changeme", "port": 7776 },
    "game": { "gamemode": "main", "language": "en", "weather": 10, "time": "12:00" },
    "logging": { "level": "info", "file": "server.log" },
    "components": ["pawn", "mysql", "streamer", "colandreas"]
}
```

### PAWN Syntax Essentials
```pawn
// Variables
new gVar = 0;                    // global
static sVar = 0;                  // file-static
new const Float:PI = 3.14159;     // const

// Arrays
new arr[10];                      // fixed
new arr2[MAX_PLAYERS][MAX_ITEMS]; // 2D

// Enums
enum E_PLAYER { pName[24], pScore, Float:pHealth }
new gPlayer[MAX_PLAYERS][E_PLAYER];

// Tags (open.mp strict)
new Text:gText = Text:INVALID_TEXT_DRAW;
new PlayerText:gPText[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ... };

// Functions
stock MyFunc(playerid, const msg[]) {
    // stock = can be unused without warning
}
forward MyCallback(playerid);
public MyCallback(playerid) { return 1; }

// Hooks (YSI)
hook OnPlayerConnect(playerid) {
    // chained, multiple hooks allowed
    return 1;
}

// Timers (YSI)
timer MyTimer[1000](playerid) {
    // runs every 1000ms
}

// Iteration (YSI)
foreach (new i : Player) { /* all connected players */ }
foreach (new i : Vehicle) { /* all vehicles */ }
```

### open.mp vs SA-MP Differences
| Feature | SA-MP | open.mp |
|---------|-------|---------|
| Config | server.cfg | config.json |
| Compiler | pawncc 3.2.3664 | pawncc 3.10.10+ |
| Tags | loose (optional) | strict (required) |
| Natives | a_samp, a_players | omp (core), omp (components) |
| Components | plugins (.so/.dll) | components (.so/.dll) |
| TextDraw limit | 2048 global, 256/player | same (client limit) |
| Vehicle limit | 2000 | 2000 (configurable) |
| Object limit | 1000 (streamer) | streamer (unlimited) |
| MySQL | plugin (BlueG R41) | native component + plugin |
| Streamer | plugin (Incognito) | native + plugin |

### open.mp Native Functions (Key)
```pawn
// Player
SetPlayerPos(playerid, Float:x, Float:y, Float:z);
SetPlayerInterior(playerid, interiorid);
SetPlayerVirtualWorld(playerid, worldid);
SetPlayerHealth(playerid, Float:health);
SetPlayerArmour(playerid, Float:armour);
GivePlayerWeapon(playerid, weaponid, ammo);
ResetPlayerWeapons(playerid);

// Vehicle
CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay);
SetVehiclePos(vehicleid, Float:x, Float:y, Float:z);
SetVehicleZAngle(vehicleid, Float:angle);
RepairVehicle(vehicleid);
SetVehicleHealth(vehicleid, Float:health);

// Object (native, no streamer needed for basic)
CreateObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
SetObjectPos(objectid, Float:x, Float:y, Float:z);
SetObjectRot(objectid, Float:rx, Float:ry, Float:rz);

// TextDraw (see section 3)
// Dialog
ShowPlayerDialog(playerid, dialogid, style, caption[], info[], button1[], button2[]);

// Checkpoint
SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size);
DisablePlayerCheckpoint(playerid);

// Camera
SetPlayerCameraPos(playerid, Float:x, Float:y, Float:z);
SetPlayerCameraLookAt(playerid, Float:x, Float:y, Float:z);
SetCameraBehindPlayer(playerid);
```

## 2. Modern TextDraw Design (Nexor's Editor Style)

### Design Philosophy
- **Not kuno (outdated)**: Avoid plain text on black background, default fonts, no borders
- **Modern**: Rounded corners (LD_BEAT:chit), glassmorphism (semi-transparent boxes), gradients, icons
- **Consistent**: Use a design system with color palette, spacing, typography
- **Responsive**: Handle 16:9 widescreen (coordinates adjust automatically)

### Color Palette (Modern 2026)
```
Background:  0x1C1C1CFF (charcoal) with 0x00000088 overlay
Surface:     0x2D2D2DFF (dark gray)
Primary:     0x1E90FFFF (dodger blue) — main actions
Success:     0x2ECC71FF (emerald)
Warning:     0xF39C12FF (orange)
Error:       0xE74C3CFF (red)
Text:        0xFFFFFFFF (white) primary, 0xB0B0B0FF (gray) secondary
Accent:      0x9B59B6FF (purple) — highlights
```

### TextDraw Creation Pattern (Modern)
```pawn
stock CreateModernButton(playerid, Float:x, Float:y, const text[], Float:width = 120.0, Float:height = 30.0) {
    new PlayerText:btn = CreatePlayerTextDraw(playerid, x, y, text);
    PlayerTextDrawFont(playerid, btn, TEXT_DRAW_FONT_2);        // Clean font
    PlayerTextDrawLetterSize(playerid, btn, 0.25, 1.2);          // Readable size
    PlayerTextDrawColor(playerid, btn, 0xFFFFFFFF);              // White text
    PlayerTextDrawSetOutline(playerid, btn, 0);                  // No outline (modern)
    PlayerTextDrawSetShadow(playerid, btn, 0);                   // No shadow (modern)
    PlayerTextDrawAlignment(playerid, btn, TEXT_DRAW_ALIGN_CENTER);
    PlayerTextDrawBackgroundColor(playerid, btn, 0x00000000);    // Transparent bg
    PlayerTextDrawBoxColor(playerid, btn, 0x1E90FFFF);           // Blue box
    PlayerTextDrawUseBox(playerid, btn, true);
    PlayerTextDrawTextSize(playerid, btn, width, height);
    PlayerTextDrawSetSelectable(playerid, btn, true);
    return btn;
}
```

### Rounded Corners (LD_BEAT:chit technique)
```pawn
// Sprite: LD_BEAT:chit — 16x16 rounded corner
// Place 4 corners + 4 edges + center fill
stock CreateRoundedBox(playerid, Float:x, Float:y, Float:w, Float:h, color) {
    new PlayerText:corners[4], PlayerText:edges[4], PlayerText:center;
    // Top-left corner
    corners[0] = CreatePlayerTextDraw(playerid, x, y, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, corners[0], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawColor(playerid, corners[0], color);
    PlayerTextDrawTextSize(playerid, corners[0], 8.0, 8.0);
    // ... repeat for other corners (rotate via TextSize negative)
    // Top edge
    edges[0] = CreatePlayerTextDraw(playerid, x + 8, y, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, edges[0], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawColor(playerid, edges[0], color);
    PlayerTextDrawTextSize(playerid, edges[0], w - 16, 8.0);
    // ... etc
    return 1;
}
```

### Glassmorphism (Semi-transparent)
```pawn
// Use alpha < 0xFF for transparency
PlayerTextDrawBoxColor(playerid, td, 0x1C1C1C88);  // 53% opacity charcoal
PlayerTextDrawBackgroundColor(playerid, td, 0x00000000);  // fully transparent
```

### Progress Bar (Modern)
```pawn
stock CreateProgressBar(playerid, Float:x, Float:y, Float:width, Float:height, Float:percent, color) {
    new PlayerText:bg = CreatePlayerTextDraw(playerid, x, y, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, bg, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawColor(playerid, bg, 0x333333FF);
    PlayerTextDrawTextSize(playerid, bg, width, height);
    PlayerTextDrawUseBox(playerid, bg, false);
    
    new PlayerText:fill = CreatePlayerTextDraw(playerid, x, y, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, fill, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawColor(playerid, fill, color);
    PlayerTextDrawTextSize(playerid, fill, width * (percent / 100.0), height);
    PlayerTextDrawUseBox(playerid, fill, false);
    
    return fill;
}
```

### Clickable TextDraws (Modern Interaction)
```pawn
// Enable selectable
PlayerTextDrawSetSelectable(playerid, td, true);
// Handle click
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
    if (playertextid == gMyButton[playerid]) {
        // Handle click
        PlayerPlaySound(playerid, 1052, 0, 0, 0); // click sound
    }
    return 1;
}
```

### Nexor Editor Features (What makes textdraws look good)
1. **Grouping** — organize textdraws into named groups
2. **Undo/Redo** — iterate on design
3. **Import/Export** — share designs between projects
4. **Multi-language** — localize text content
5. **Index reordering** — clean up TD indices
6. **Sprite preview** — visualize sprites before placing
7. **Color picker** — precise ARGB color selection
8. **Box sizing** — visual resize handles

### TextDraw Limits (open.mp)
| Type | Limit |
|------|-------|
| Global textdraws | 2048 |
| Per-player textdraws | 256 |
| Shown per client | 2048 + 256 |
| Sprites per client | 100 |
| String length | 1024 chars |
| Color codes beyond 255th char | May crash client |

### Design Rules (Anti-Slop)
1. **No default white text on black** — use color palette
2. **No font 0/1 for UI** — use font 2 (clean) or 3 (bold)
3. **No outline 1 + shadow 1** — modern = outline 0, shadow 0 or 1
4. **No raw coordinates** — use a design grid (8px base)
5. **No 1:1 text size** — letter size 0.2-0.4, text size 1.0-1.5
6. **Always use box for backgrounds** — transparent text looks unfinished
7. **Add hover/active states** — clickable TDs need visual feedback
8. **Use sprites for icons** — LD_BEAT:chit, LD_SPAC:white, TXD sprites

## 3. Map & Interior Design (Map-Editor-V3 Style)

### Interior System
```pawn
// Set player interior
SetPlayerInterior(playerid, interiorid);
// Link vehicle to interior
LinkVehicleToInterior(vehicleid, interiorid);
// Set virtual world (separate dimension)
SetPlayerVirtualWorld(playerid, worldid);
```

### Interior IDs Reference
| ID | Interior | Example |
|----|----------|---------|
| 0 | Exterior (Los Santos) | Streets, outside buildings |
| 1 | 24/7 Shop | Convenience store |
| 2 | Ammu-Nation | Gun shop |
| 3 | Barber | Hair salon |
| 4 | Big Smoke's Crack Palace | Drug house |
| 5 | Burglary House | Various houses |
| 6 | Casino (Caligula's) | Casino interior |
| 7 | Cluckin' Bell | Fast food |
| 8 | Police Department | LSPD |
| 9 | Hospital | Medical |
| 10 | Gym | Fitness center |
| 11 | Mall | Shopping center |
| 12 | Motel Room | Budget inn |
| 13 | Nightclub | Club |
| 14 | Restaurant | Dining |
| 15 | Tattoo Parlor | Tattoos |
| 16 | Warehouse | Storage |
| 17 | School | Education |
| 18 | Stadium | Sports arena |
| 19 | Safe House | Player housing |

### Interior Coordinates (Common)
```
24/7 Shop:      2236.6997, -1078.9478, 1049.0234 (int 2)
Ammu-Nation:    316.5249, -169.6252, 999.6017 (int 6)
Barber:         411.6264, -22.9426, 1001.8047 (int 2)
Hospital:       1172.8519, -1323.5496, 15.4009 (int 0)
LSPD:           246.7839, 63.9001, 1003.6406 (int 6)
Motel Room:     446.3247, 509.9662, 1001.4195 (int 12)
```

### Map Editor Workflow (Map-Editor-V3)
1. **Place objects** → CreateObject with model + position + rotation
2. **Texture objects** → SetObjectMaterial (model, materialindex, modelid, txdname, texturename, color)
3. **Remove buildings** → RemoveBuildingForPlayer (modelid, x, y, z, radius)
4. **Create pickups** → CreatePickup (model, type, x, y, z)
5. **Create actors** → CreateActor (modelid, x, y, z, angle)
6. **Attach objects** → SetPlayerAttachedObject (player, index, modelid, bone, offset, rotation, scale)
7. **Save map** → export to file (objects, vehicles, pickups, actors)

### Object Material (Retexturing)
```pawn
// SetObjectMaterial(objectid, materialindex, modelid, txdname[], texturename[], color)
SetObjectMaterial(objectid, 0, 10101, "2notherbuildsfe", "sl_vicwall01", 0xFFFFFFFF);
// Material index: 0-15 (most objects have 1-4 materials)
// modelid: object model ID (used for texture resolution)
// txdname: TXD file name (from GTA SA or custom)
// texturename: texture name within TXD
// color: tint color (0xFFFFFFFF = no tint)
```

### Custom TXD (Texture Dictionary)
```pawn
// Load custom TXD (open.mp)
new txd = LoadTXD("mytextures.txd");
new texture = GetTexture(txd, "mytexture");
// Apply to object
SetObjectMaterial(objectid, 0, 0, "", "", 0xFFFFFFFF); // clear
// Then use SetObjectMaterial with custom texture
```

### Interior Design Principles
1. **Use existing interiors** — faster, no streaming needed
2. **Custom interiors** — use MLO (Map Load Object) with streamer
3. **Lighting** — adjust time/weather for atmosphere
4. **Props** — add furniture, decorations via objects
5. **Doors** — use ox_doorlock or custom door system
6. **Zones** — define enter/exit areas with streamer areas

### MLO (Map Load Object) Pattern
```pawn
// Load custom interior from .map file
stock LoadCustomInterior(const filename[]) {
    new File:f = fopen(filename, io_read);
    new line[256];
    while (fread(f, line)) {
        // Parse object lines: modelid, x, y, z, rx, ry, rz
        // CreateObject for each
    }
    fclose(f);
}
```

## 4. Modern UI Patterns (Not Kuno)

### Pattern 1: Card Layout (Bento Grid)
```pawn
// Instead of centered text, use cards with icons + labels
// Card 1: Top-left, Card 2: Top-right, Card 3: Bottom spanning
```

### Pattern 2: Toast Notifications
```pawn
stock ShowToast(playerid, const msg[], type = 0) {
    // type: 0=info, 1=success, 2=warning, 3=error
    new colors[] = { 0x3498DBFF, 0x2ECC71FF, 0xF39C12FF, 0xE74C3CFF };
    // Create TD at top of screen, slide down, auto-dismiss after 3s
    // Use timer to destroy
}
```

### Pattern 3: Modal Dialog (Not default dialog)
```pawn
// Instead of ShowPlayerDialog, create custom modal with:
// - Dark overlay (0x00000088 box covering screen)
// - Centered card (rounded box)
// - Title, content, buttons
// - Clickable buttons (selectable TDs)
```

### Pattern 4: HUD (Minimal, not cluttered)
```pawn
// Health bar: thin line at bottom-left, not big box
// Money: small text top-right
// Weapon: icon + ammo count, top-center
// Use opacity for non-critical info
```

### Pattern 5: Radial Menu (Modern interaction)
```pawn
// Instead of /commands, use radial menu (ox_lib style)
// Center button + 6-8 options around circle
// Trigger with key press, mouse to select
```

## 5. Code Quality Rules

### PAWN Best Practices
1. **Use tags** — `Text:`, `PlayerText:`, `Float:`, `bool:`
2. **Use YSI** — y_commands, y_hooks, y_iterate, y_timers
3. **Use streamer** — for objects, areas, pickups, actors
4. **Use MySQL prepared statements** — prevent SQL injection
5. **Use foreach** — instead of for loops over MAX_PLAYERS
6. **Use stock** — for helper functions (no unused warnings)
7. **Use const** — for immutable values
8. **Use enum** — for structured data (not parallel arrays)
9. **Use timer** — for recurring tasks (not SetTimer with string)
10. **Use hook** — for callbacks (not direct override)

### Naming Convention
```
g_ prefix: global variables (gPlayerData)
s_ prefix: static variables (sTimerCount)
E_ prefix: enums (E_PLAYER_DATA)
TD_ prefix: textdraw variables (TD_HealthBar)
p_ prefix: player-specific (pName, pScore)
```

### File Structure
```
gamemodes/
  main.pwn          # entry point, OnGameModeInit/Exit
  core/             # core systems (player, vehicle, object)
  features/         # feature modules (banking, jobs, crime)
  ui/               # textdraws, dialogs, menus
  data/             # database, cache, config
filterscripts/      # hot-reloadable scripts
include/            # shared includes
plugins/            # .so/.dll plugins
scriptfiles/        # runtime data files
```

## 6. Compile & Verify

### Dual-Target Compile
```bash
# open.mp target
pawncc -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn

# legacy SA-MP target
pawncc -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn
```

### Zero Warnings Policy
- `-d3` enables debug info + warnings
- `-Z` treats warnings as errors (strict)
- All code must compile with 0 warnings, 0 errors on BOTH targets

### Runtime (open.mp v1.6.7.3218)
- **Server**: v1.6.7.3218 (Oct 2026)
- **pawncc**: 3.10.10+ with `-Z` for warnings-as-errors
- **Streamer**: v2.9.6+ (Incognito) for dynamic objects/areas/pickups
- **MySQL**: R41-4 (BlueG) or native component
- **YSI**: 5.x (y_commands, y_hooks, y_iterate, y_bit, y_inline, y_timers, y_groups)
- **ColAndreas**: v1.5.0+ for collision/raycasting
- **SA-MP Legacy**: 0.3.7-R2 / 0.3.DL for backward compat