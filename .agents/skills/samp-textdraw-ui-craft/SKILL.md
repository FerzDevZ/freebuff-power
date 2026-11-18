---
name: samp-textdraw-ui-craft
description: Modern 2026 TextDraw Engineering Foundations for open.mp & SA-MP — Global vs PlayerTextDraw pool budgeting, exact GTA SA 640x480 + 16:9 widescreen coordinate math, accurate clickable hitbox rules (sprite vs centered-text X/Y swap), curated GTA SA TXD sprite atlas + custom 0.3.DL/open.mp TXD sprites, Font 5 3D model preview calibration, smooth ease-out slide/fade animation engine, and TDEditor/TDW cleanup workflow.
---

# Modern 2026 TextDraw UI Craft & Foundations (open.mp & SA-MP)

Pair this foundation skill with **`samp-textdraw-fivem-modern-design`** for full FiveM / NoPixel 4.0 / Ox_lib UI kits.

---

## 1. Global `Text:` vs Per-Player `PlayerText:` Strategy

| Property | Global TextDraw (`Text:`) | PlayerTextDraw (`PlayerText:`) |
|---|---|---|
| Hard Engine Limit | **2048** server-wide | **256** per player |
| Best Use Cases | Static modal frames, rounded card backdrops, static icons, dividers, server logo | Dynamic numbers (speed, HP, cash), toast text, inventory item slots, progress fill |
| Click Callback | `OnPlayerClickTextDraw` | `OnPlayerClickPlayerTextDraw` |
| Pro Strategy | Put ALL static rounded borders & window frames here to save **30–60 PlayerTD slots**! | Create modals on open, destroy ALL immediately on close (`SafeDestroyPlayerTD`) |

---

## 2. Exact Coordinate, 16:9 Aspect & Clickable Hitbox Math

SA-MP's virtual canvas is **640.0 x 480.0**, stretched to 16:9 on modern monitors and phones.
- **16:9 Aspect Correction Factor:** Always multiply horizontal width of circles, squares, and rounded radii by **`0.75`** (`width = height * 0.75`).

### Exact Clickable Hitbox Rules (Fixes #1 SA-MP UI Bug!)
1. **Sprite Buttons (`TEXT_DRAW_FONT_SPRITE_DRAW`, e.g. `LD_SPAC:white`) — RECOMMENDED:**
   - `TextSize(width, height)` defines BOTH visual size AND exact pixel-perfect click region.
   - Make ONLY the backdrop sprite selectable; set `SetSelectable(false)` on the text label overlay!
2. **Left-Aligned Text Box (`TEXT_DRAW_ALIGN_LEFT` + `UseBox = 1`):**
   - `TextSize(posX + boxWidth, clickHeight)` — X is the **absolute right screen coordinate**, Y is the clickable height!
3. **Center-Aligned Text Box (`TEXT_DRAW_ALIGN_CENTER` + `UseBox = 1`):**
   - **CRITICAL GTA SA ENGINE QUIRK:** X and Y are **SWAPPED**!
   - `TextSize(clickHeight, boxWidth)` — First parameter is **HEIGHT**, second parameter is **WIDTH**!
   ```pawn
   // Centered button of width 120.0 and height 24.0:
   PlayerTextDrawAlignment(playerid, btn, TEXT_DRAW_ALIGN_CENTER);
   PlayerTextDrawTextSize(playerid, btn, 24.0, 120.0); // (Height, Width) — SWAPPED!
   ```

---

## 3. Curated GTA SA TXD Sprite Atlas & Custom TXD (0.3.DL / open.mp)

Render crisp vector-like icons and shapes with zero external downloads via `TEXT_DRAW_FONT_SPRITE_DRAW` (`Font 4`):

| TXD:Sprite | Modern 2026 Usage |
|---|---|
| `LD_SPAC:white` | Crisp flat cards, progress fills, hairline borders (`0xFFFFFF1A`), accent bars |
| `LD_BEAT:chit` | Perfect circles (with `0.75` X correction), rounded card corners, radio dots, status nodes |
| `LD_BEAT:left` / `LD_BEAT:right` | Carousel arrows, pagination, character selector arrows |
| `LD_BEAT:cross` | Clean `[X]` modal close icon |
| `HUD:radar_centre` / `HUD:radar_waypoint` | GPS / navigation pin icons |
| `LD_CHAT:thumbup` / `LD_CHAT:badchat` | Notification status badges |
| `LD_DRV:gold` / `LD_DRV:silver` | Job mastery rank badges |

### Custom Crisp PNG/TXD Icons (open.mp & SA-MP 0.3.DL)
For authentic FiveM SVG-grade icons (heart, armor shield, fuel pump, lock, microphone, smartphone icons):
1. Pack 64x64 / 128x128 transparent PNGs into a custom `.txd` (e.g. `hud_icons.txd`) via Magic.TXD (DXT5 alpha compression).
2. Register in `artconfig.txt` / `AddSimpleModel` with FastDL CDN (`config.json -> artwork.cdn`).
3. Draw via `CreatePlayerTextDraw(playerid, x, y, "mdl-2001:icon_heart")` (`Font 4`) with `0xFFFFFFFF` or semantic tint color!

---

## 4. Font 5 (3D Model Preview) Calibration

```pawn
// Clean FiveM Inventory Slot Tile (transparent background + clean isometric angle)
PlayerTextDrawFont(playerid, slotTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
PlayerTextDrawSetPreviewModel(playerid, slotTD, 348); // Desert Eagle
PlayerTextDrawSetPreviewRot(playerid, slotTD, -15.0, 0.0, -35.0, 0.92); // Crisp 3/4 showcase angle
PlayerTextDrawBackgroundColor(playerid, slotTD, 0x1E293BE8); // Glass slate slot fill
PlayerTextDrawTextSize(playerid, slotTD, 36.0, 44.0); // Aspect-balanced card tile
```
> **Vehicle Previews:** Use `PlayerTextDrawSetPreviewVehCol(playerid, td, color1, color2)` so Dealership & Garage previews display the player's **exact** vehicle paint color!

---

## 5. Smooth Ease-Out Animation Engine (Slide-In / Fade-In)

Static pop-in TextDraws feel stiff. Animate Toasts, Speedometers, and Progress Bars cleanly with **Cubic Ease-Out** over `8`–`10` steps (`25ms`–`30ms` interval):
```pawn
// Cubic ease-out: t in [0.0 .. 1.0] -> smooth deceleration like CSS cubic-bezier(0.22, 1, 0.36, 1)
stock Float:EaseOutCubic(Float:t)
{
    new Float:inv = 1.0 - t;
    return 1.0 - (inv * inv * inv);
}

// Smooth RGBA alpha interpolation (fade-in 0x00 -> targetAlpha)
stock SetColorAlpha(rgbaColor, alphaByte)
{
    return (rgbaColor & 0xFFFFFF00) | (alphaByte & 0xFF);
}
```
> Always re-call `PlayerTextDrawShow(playerid, td)` after `PlayerTextDrawColor` or `PlayerTextDrawTextSize` so the client updates the rendered frame immediately.

---

## 6. Refactoring Exported TDEditor / iTD / TDW Code
Never paste raw TDEditor dumps (`Textdraw0`, `Textdraw1` ... `Textdraw87`) straight into production:
1. Replace hardcoded magic numbers with base anchor variables (`const Float:BASE_X = 480.0;`) so the whole widget moves cleanly by changing 1 constant.
2. Convert repeated identical cards/slots into a `for` loop (`for (new i = 0; i < MAX_SLOTS; i++)`).
3. Move static background shapes to Global `TextDraw`s and strip redundant default calls (`Outline(0)`, `Shadow(0)`).
