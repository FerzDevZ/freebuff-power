---
name: samp-textdraw-fivem-modern-design
description: Master FiveM/NoPixel/QBox/Ox_lib-style Modern 2026 TextDraw UI/UX Design for SA-MP & open.mp — rounded corners via LD_BEAT:chit, 16:9 aspect-ratio math, Glassmorphism/Dark Slate palettes, HUD, Speedometer, Toast Notifications, Progress Bars, Context/Radial Menus, Inventory Grids, exact clickable hitboxes, and strict 256 PlayerTextDraw pool budgeting.
---

# FiveM-Style Modern 2026 TextDraw Design Master (SA-MP & open.mp)

Designing **FiveM / NoPixel 4.0 / QBox / Ox_lib** quality interfaces on SA-MP and open.mp's 640x480 TextDraw canvas is completely achievable when you master geometry, widescreen aspect compensation, layered sprite composition, and strict pool management.

---

## 1. Fundamental Coordinate & Widescreen Geometry (The Secret to Clean UI)

SA-MP renders TextDraws on a virtual **640.0 x 480.0** coordinate space that stretches horizontally on 16:9 monitors (`1920x1080`, `2560x1440`).
- **Standard 4:3 Ratio**: `4 / 3 = 1.333`
- **Modern 16:9 Ratio**: `16 / 9 = 1.777`
- **Aspect Correction Factor**: `1.333 / 1.777 = 0.75`

### The Golden Aspect-Ratio Rule
To make a **perfect circle** or **perfect square** on 16:9 widescreen displays (PC & modern Android phones), always multiply the horizontal width by **`0.75`**:
```pawn
#define TD_ASPECT_16_9 (0.75)

// Perfect 20px-tall square/circle on 16:9:
// Width = 20.0 * 0.75 = 15.0, Height = 20.0
PlayerTextDrawTextSize(playerid, td, 15.0, 20.0);
```

### Font & Alignment Standards (No Clunky 2012 Fonts)
| Font ID | Name | Modern 2026 Usage |
|---|---|---|
| `1` | Sans-Serif (Standard) | Clean body text, labels, buttons, notification copy (`LetterSize(0.18, 0.85)` to `(0.24, 1.1)`) |
| `2` | Bank Gothic / Bold Caps | Headers, Speedometer numbers, Keybind badges (`[E]`), Section titles |
| `4` | TXD Sprite (`FONT_SPRITE_DRAW`) | Solid rectangles (`LD_SPAC:white`), circles (`LD_BEAT:chit`), custom HUD icons |
| `5` | 3D Model Preview (`FONT_MODEL_PREVIEW`) | Inventory items, vehicles in garage/dealership, character previews |

**Mandatory Anti-Slop TextDraw Rules:**
- **ALWAYS** set `SetOutline(0)` and `SetShadow(0)` for crisp FiveM flat/glass typography (heavy black outlines look dated and muddy).
- **ALWAYS** set `SetProportional(1)` on text fonts (`1`, `2`, `3`).
- **NEVER** use pure neon colors (`0xFF0000FF`, `0x00FF00FF`, `0xFFFF00FF`) or generic purple gradients. Use a curated Dark Slate / Glassmorphic FiveM palette.

---

## 2. FiveM / NoPixel 2026 Color Palette Constants

```pawn
// Glassmorphic Dark Slate Surfaces (RGBA hex)
#define UI_BG_GLASS_DARK     0x0B0F19E6 // 90% opacity deep obsidian-slate
#define UI_BG_SURFACE        0x111827F0 // 94% opacity card surface
#define UI_BG_ELEVATED       0x1E293BF2 // 95% opacity elevated slot/header
#define UI_BG_HOVER          0x273549F5 // Hover/active slot highlight
#define UI_BORDER_SUBTLE     0xFFFFFF1C // Crisp 11% white glass hairline border

// Typography Hierarchy
#define UI_TEXT_PRIMARY      0xF8FAFCFF // High-contrast off-white (never harsh #FFF)
#define UI_TEXT_SECONDARY    0x94A3B8FF // Muted slate secondary label
#define UI_TEXT_MUTED        0x64748BFF // Disabled / hint text

// Semantic Accents (Emerald / Sky / Amber / Rose)
#define UI_ACCENT_PRIMARY    0x10B981FF // Emerald green (Primary CTA / Health / Cash)
#define UI_ACCENT_INFO       0x38BDF8FF // Sky cyan (Armour / Police / Info)
#define UI_ACCENT_WARN       0xF59E0BFF // Amber (Hunger / Fuel / Warning)
#define UI_ACCENT_DANGER     0xEF4444FF // Coral red (Error / Low HP / Stop)
#define UI_ACCENT_THIRST     0x0EA5E9FF // Ocean blue (Thirst / Nitro)
```

---

## 3. Pixel-Perfect Rounded Corners (`CreateRoundedCard`)

FiveM NUI cards have `border-radius`. In PAWN, you achieve **smooth rounded rectangles** using **6 sprites**: 4 corner circles (`LD_BEAT:chit`) + 2 intersecting rectangles (`LD_SPAC:white`).

```pawn
// Renders a rounded-corner FiveM card using 6 PlayerTextDraws.
// Returns the number of PlayerTextDraws consumed (always 6).
stock CreatePlayerRoundedBox(
    playerid,
    PlayerText:outIds[6],
    Float:x,
    Float:y,
    Float:width,
    Float:height,
    Float:radius,
    color
)
{
    new Float:rx = radius * TD_ASPECT_16_9; // Aspect-corrected horizontal radius
    new Float:ry = radius;
    new Float:diamX = rx * 2.0;
    new Float:diamY = ry * 2.0;

    // 1. Center horizontal strip (full width, height minus 2*ry)
    outIds[0] = CreatePlayerTextDraw(playerid, x, y + ry, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, outIds[0], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[0], width, height - diamY);
    PlayerTextDrawColor(playerid, outIds[0], color);

    // 2. Center vertical strip (width minus 2*rx, full height)
    outIds[1] = CreatePlayerTextDraw(playerid, x + rx, y, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, outIds[1], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[1], width - diamX, height);
    PlayerTextDrawColor(playerid, outIds[1], color);

    // 3. Top-Left corner circle
    outIds[2] = CreatePlayerTextDraw(playerid, x, y, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, outIds[2], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[2], diamX, diamY);
    PlayerTextDrawColor(playerid, outIds[2], color);

    // 4. Top-Right corner circle
    outIds[3] = CreatePlayerTextDraw(playerid, x + width - diamX, y, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, outIds[3], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[3], diamX, diamY);
    PlayerTextDrawColor(playerid, outIds[3], color);

    // 5. Bottom-Left corner circle
    outIds[4] = CreatePlayerTextDraw(playerid, x, y + height - diamY, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, outIds[4], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[4], diamX, diamY);
    PlayerTextDrawColor(playerid, outIds[4], color);

    // 6. Bottom-Right corner circle
    outIds[5] = CreatePlayerTextDraw(playerid, x + width - diamX, y + height - diamY, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, outIds[5], TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, outIds[5], diamX, diamY);
    PlayerTextDrawColor(playerid, outIds[5], color);

    return 6;
}
```
> **Pro Tip (Pool Optimization):** For static backgrounds (like a shared Inventory modal or Dealership frame that looks identical for all players), build the 6 rounded-corner primitives as **Global `TextDraw`s** instead of `PlayerTextDraw`s — this saves 6 slots per player out of the 256 limit!

---

## 4. Exact Clickable Hitbox Alignment (Zero Misclicks)

The #1 bug in SA-MP TextDraws is misaligned clickable hitboxes where hovering over Button B highlights Button A. Follow these exact rules:

### Rule A: Sprite Buttons (`FONT_SPRITE_DRAW` — Recommended for FiveM Buttons!)
When using `LD_SPAC:white` as a button backdrop:
- `PlayerTextDrawTextSize(playerid, td, width, height)` defines **BOTH** the visual sprite dimensions AND the exact clickable hitbox!
- Set `PlayerTextDrawSetSelectable(playerid, td, true)` ONLY on the background sprite, and set `false` on the overlay text label so the mouse never fights between overlapping selectables!

```pawn
// Clean FiveM Pill Button: Sprite handles click, Text is non-selectable overlay
stock PlayerText:CreateFiveMButton(playerid, Float:x, Float:y, Float:w, Float:h, const label[], bgColor, &PlayerText:labelOut)
{
    new PlayerText:btn = CreatePlayerTextDraw(playerid, x, y, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, btn, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, btn, w, h);
    PlayerTextDrawColor(playerid, btn, bgColor);
    PlayerTextDrawSetSelectable(playerid, btn, true);

    labelOut = CreatePlayerTextDraw(playerid, x + (w / 2.0), y + (h / 2.0) - 4.5, label);
    PlayerTextDrawFont(playerid, labelOut, TEXT_DRAW_FONT_1);
    PlayerTextDrawAlignment(playerid, labelOut, TEXT_DRAW_ALIGN_CENTER);
    PlayerTextDrawLetterSize(playerid, labelOut, 0.20, 0.90);
    PlayerTextDrawColor(playerid, labelOut, UI_TEXT_PRIMARY);
    PlayerTextDrawSetOutline(playerid, labelOut, 0);
    PlayerTextDrawSetShadow(playerid, labelOut, 0);
    PlayerTextDrawSetProportional(playerid, labelOut, true);
    PlayerTextDrawSetSelectable(playerid, labelOut, false);
    return btn;
}
```

### Rule B: Box-Based Text Buttons (`UseBox = 1`)
- If `Alignment == LEFT`: `TextSize(x + width, height)` (X is absolute right edge, Y is click box height!).
- If `Alignment == CENTER`: `TextSize(height, width)` (X and Y are **SWAPPED** by GTA SA engine!).
- **Recommendation:** Prefer Rule A (Sprite backdrop + Centered non-selectable text) to eliminate GTA SA's notorious centered-hitbox quirk.

---

## 5. FiveM Component Blueprints (2026 Standard)

### A. Ox_lib-Style Toast Notification (Top-Right Stack)
- Dimensions: `w = 138.0`, `h = 26.0`, positioned at `x = 492.0`, `y = 24.0 + (slot * 32.0)`.
- Layers:
  1. Dark glass card (`UI_BG_GLASS_DARK`)
  2. `2.5`px vertical accent bar on the left edge (`UI_ACCENT_PRIMARY` / `UI_ACCENT_DANGER` / `UI_ACCENT_INFO`)
  3. Bold title (`Font 2`, `LetterSize(0.17, 0.78)`)
  4. Subtitle body (`Font 1`, `LetterSize(0.16, 0.75)`, `UI_TEXT_SECONDARY`)
- Auto-dismiss via per-slot timer (`3500ms`–`5000ms`), destroying PlayerTextDraws immediately on expire.

### B. Smooth Animated Progress Bar (Skill-Check & Action Bar)
- Bottom-center (`x = 245.0, y = 398.0, w = 150.0, h = 14.0`).
- Track background (`UI_BG_GLASS_DARK`) + Fill sprite (`LD_SPAC:white`, `UI_ACCENT_PRIMARY`) whose width scales smoothly:
  ```pawn
  new Float:fillWidth = (float(elapsedMs) / float(totalMs)) * maxBarWidth;
  PlayerTextDrawTextSize(playerid, pBarFill[playerid], fillWidth, 10.0);
  PlayerTextDrawShow(playerid, pBarFill[playerid]); // Re-show to update size!
  ```
- **Skill-Check Variant (for Mining / Lockpick / Fishing):** Add a highlighted target zone sprite (`x = barX + zoneStart`, `w = zoneWidth`, `UI_ACCENT_WARN`) and a moving needle (`w = 2.0`). Player presses `KEY_YES` (`Y`) or `KEY_SPRINT` (`SPACE`) when needle is inside `[zoneStart, zoneStart + zoneWidth]`.

### C. Minimalist FiveM HUD & Speedometer
- **Bottom-Left Status Pills** (above minimap or beside minimap):
  - Compact vertical or horizontal capsule bars (`Health`, `Armour`, `Hunger`, `Thirst`, `Voice Indicator`).
  - Only update when values change by >= 1% (dirty-flag caching) — NEVER re-render every tick in `OnPlayerUpdate`!
- **Bottom-Right Digital Speedometer**:
  - Large clean speed digits (`Font 2`, `LetterSize(0.48, 2.0)`), muted `KM/H` unit label.
  - Segmented RPM / Fuel bar (`10` thin vertical bars or single smooth fill bar).
  - Crisp status indicators: `ENG` | `LCK` | `BELT` | `LGT` (color flips between `UI_TEXT_MUTED` and `UI_ACCENT_PRIMARY`).
  - Update timer: `150ms`–`200ms` while in vehicle (`PLAYER_STATE_DRIVER`), destroy on exit!

### D. Context Interaction Prompt (`[E] Open Garage`)
- Small floating pill at lower-center or left-center (`x = 275.0, y = 425.0`):
  - Bright keycap badge (`[Y]` or `[E]` or touch button on mobile) + dark glass pill with action text (`Open Mechanic Menu`).
  - Replaces legacy `/cmd` guesswork with instant FiveM ergonomics!

---

## 6. Strict Pool Budgeting (Never Crash the 256 Limit)

SA-MP & open.mp enforce a **hard limit of 256 `PlayerTextDraw`s per player** and **2048 Global `TextDraw`s**.

| UI Subsystem | Recommended Budget | Lifecycle Strategy |
|---|---|---|
| Persistent HUD (HP/Armour/Needs/Voice) | <= 22 PlayerTDs | Created on spawn, destroyed on disconnect |
| Vehicle Speedometer | <= 16 PlayerTDs | Created on enter driver seat, destroyed on exit |
| Toast Notifications (3 slots) | <= 12 PlayerTDs | Created on notify, destroyed on expire |
| Action Progress Bar / `[E]` Prompt | <= 6 PlayerTDs | Created on demand, destroyed immediately |
| Modal UI (Inventory / Bank / Phone / Shop) | <= 140 PlayerTDs | **Mutually exclusive**: close active modal & destroy ALL its PlayerTDs before opening another! |
| **Safety Headroom** | **>= 60 PlayerTDs** | Prevents `INVALID_PLAYER_TEXT_DRAW` silently breaking HUD |

### Mandatory Lifecycle Guard
```pawn
stock SafeDestroyPlayerTD(playerid, &PlayerText:td)
{
    if (td != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, td);
        td = PlayerText:INVALID_TEXT_DRAW;
    }
}
```
Always use a UI state enum (`E_ACTIVE_UI`: `UI_NONE`, `UI_INVENTORY`, `UI_PHONE`, `UI_DEALERSHIP`, `UI_BANK`) and call `CloseActiveUI(playerid)` before opening any new screen.
