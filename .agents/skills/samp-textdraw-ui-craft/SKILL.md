---
name: samp-textdraw-ui-craft
description: Advanced TextDraw & HUD Engineering for SA-MP & open.mp — Global vs Player TextDraws, responsive 640x480 coordinate math, clickable buttons, texture sprites (Font 4), 3D preview models (Font 5), and dynamic progress bars.
---

# SA-MP / open.mp TextDraw UI Craft Skill

## 1. Global vs PlayerTextDraw Selection
| Property | Global TextDraw (`Text:`) | PlayerTextDraw (`PlayerText:`) |
|---|---|---|
| Scope | Shared across entire server | Unique per player |
| Max Limits | 2048 global limit | 256 per player limit |
| Best Use Cases | Static server logo, watermarks, static frames | Dynamic health, cash, speedometer, inventory |
| Clickable Callback | `OnPlayerClickTextDraw` | `OnPlayerClickPlayerTextDraw` |
| Destruction | `TextDrawDestroy` | `PlayerTextDrawDestroy` |

## 2. Coordinate & Aspect Ratio Math (640×480 Grid)
The SA-MP UI canvas is strictly mapped to `0.0`–`640.0` on the X axis, and `0.0`–`480.0` on the Y axis:

- **Letter Size:** Controls font width and height.
  ```pawn
  PlayerTextDrawLetterSize(playerid, textdraw, 0.28, 1.20);
  ```
- **Clickable Hitbox (`TextSize`):**
  - For centered text (`Alignment = 2`), `TextSize` defines the total width centered on X.
  - For left-aligned text (`Alignment = 1`), `TextSize` is the right coordinate (or width depending on use).
  ```pawn
  PlayerTextDrawAlignment(playerid, btn, 2); // Center aligned
  PlayerTextDrawTextSize(playerid, btn, 120.0, 25.0); // 120 width, 25 height hitbox
  PlayerTextDrawSetSelectable(playerid, btn, true);
  ```

## 3. Font 4 (GTA Texture Sprites)
Render in-game icons, gradients, and backgrounds without external downloads:

```pawn
new PlayerText:gCardBg[MAX_PLAYERS];

stock CreateCard(playerid, Float:x, Float:y, Float:w, Float:h) {
    gCardBg[playerid] = CreatePlayerTextDraw(playerid, x, y, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, gCardBg[playerid], 4); // Texture font
    PlayerTextDrawColor(playerid, gCardBg[playerid], 0x1A1A1AE6); // Semi-transparent dark slate
    PlayerTextDrawTextSize(playerid, gCardBg[playerid], w, h);
    PlayerTextDrawShow(playerid, gCardBg[playerid]);
}
```

Common built-in texture names:
- `LD_BEAT:chit` : Clean rounded box
- `hud:radar_spray` : Spray can icon
- `hud:radar_modGarage` : Wrench / repair icon
- `hud:radar_light` : Traffic light icon

## 4. Font 5 (3D Preview Models)
Render real-time 3D skins, vehicles, or weapon models inside UI panels:

```pawn
new PlayerText:gSkinPreview[MAX_PLAYERS];

stock ShowSkinSelector(playerid, skinid) {
    gSkinPreview[playerid] = CreatePlayerTextDraw(playerid, 240.0, 150.0, "_");
    PlayerTextDrawFont(playerid, gSkinPreview[playerid], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawTextSize(playerid, gSkinPreview[playerid], 160.0, 160.0);
    PlayerTextDrawSetPreviewModel(playerid, gSkinPreview[playerid], skinid);
    PlayerTextDrawSetPreviewRot(playerid, gSkinPreview[playerid], -10.0, 0.0, 30.0, 1.0); // Pitch, Roll, Yaw, Zoom
    PlayerTextDrawSetPreviewVehCol(playerid, gSkinPreview[playerid], 1, 1);
    PlayerTextDrawShow(playerid, gSkinPreview[playerid]);
}
```

## 5. Dynamic Progress Bars (Health, Armor, Fuel)
Using standard textdraw clipping or `pawn-progressbar`:

```pawn
new PlayerText:gFuelBar[MAX_PLAYERS];
#define FUEL_BAR_MAX_WIDTH 80.0

stock UpdateFuelBar(playerid, Float:currentFuel, Float:maxFuel) {
    new Float:fraction = currentFuel / maxFuel;
    if (fraction < 0.0) fraction = 0.0;
    if (fraction > 1.0) fraction = 1.0;

    new Float:newWidth = FUEL_BAR_MAX_WIDTH * fraction;
    PlayerTextDrawTextSize(playerid, gFuelBar[playerid], newWidth, 5.0);
    PlayerTextDrawShow(playerid, gFuelBar[playerid]); // Refresh display
}
```

## 6. Click Handler Pattern
```pawn
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
    if (playertextid == gLoginButton[playerid]) {
        CancelSelectTextDraw(playerid);
        Auth_ProcessLogin(playerid);
        return 1;
    }
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if (clickedid == INVALID_TEXT_DRAW) {
        // Player pressed ESC key to cancel/close menu
        UI_CloseActiveMenu(playerid);
        return 1;
    }
    return 0;
}
```
