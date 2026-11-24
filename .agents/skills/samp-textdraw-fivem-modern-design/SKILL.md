---
name: samp-textdraw-fivem-modern-design
description: FiveM/NoPixel/Ox_lib-grade TextDraw UI design for SA-MP & open.mp — sprite-first composition (no boxed text for layout), 2026 dark-slate glass palette, rounded cards, HUD, speedometer, toasts, progress bars, radial menu, inventory grid, mobile-safe tap targets, and 256 PlayerTextDraw pool budgeting. All geometry goes through the compile-verified samp_td_kit.inc.
---

# FiveM-Style TextDraw Design (SA-MP & open.mp)

Aesthetic layer. Geometry, defaults and pool safety come from
`samp-textdraw-ui-craft` + `resources/samp_td_kit.inc`; never re-derive
`TextSize` math by hand here.

---

## 0. Runtime (open.mp v1.6.7.3218, Oct 2026)

- **Binary**: `omp-server` (32-bit), config `config.json`
- **Launcher**: v1.7.0 with smoother overlay, ENB compat, models cache folder, recently used nicknames
- **TextDraw editors 2026**: San-Andreas-Online/web-textdraw-editor (web, layer system, 449 sprites, export clean Pawn), abdulrahman1s/open-mp-ui-editor (web + Rust native component, Pawn callbacks, 640x448), Nexor's TextDraw Editor (in-game), Nickk's TextDraw Editor v5.0 (in-game, multilanguage)
- **Coordinate space**: 640x480 (16:9 widescreen = 640x448 visible); all editors produce raw TextDraw code — engine TextSize semantics NOT applied by any editor
- **Pool limits**: 2048 global TextDraws, 256 PlayerTextDraws per player
- **open.mp UI editor** (Oct 2026): visual browser editor + Rust native component, 449 sprite previews, Login/HUD/Inventory/Menu examples, independent per-player UI instances

## 1. Composition model: sprites are the layout, text is an overlay

Every FiveM-looking SA-MP UI is built from two element types only:

| Layer | Primitive | Why |
|---|---|---|
| Surface (card, pill, bar track, bar fill, divider, badge) | font 4 sprite `LD_SPAC:white` / `LD_BEAT:chit` | `TextSize(w,h)` is an offset → visual box == click box, deterministic |
| Content (label, number, unit) | text font 1/2, `UseBox = 0` | no box, no background, positioned by `LetterSize` |

A boxed text element (`UseBox = 1`) is offset by (−5, −10) by the engine and its
`TextSize.x` is an absolute corner. It is the single most common reason a
FiveM-style mockup turns into a misaligned mess in game. **Do not use boxes for
surfaces.** `TD_BoxedText` exists only for genuinely boxed legacy labels.

## 2. Palette (RGBA — alpha is the low byte)

```pawn
#define UI_BG_GLASS_DARK    0x0B0F19E6
#define UI_BG_SURFACE       0x111827F0
#define UI_BG_ELEVATED      0x1E293BF8
#define UI_BG_HOVER         0x273549F5
#define UI_BORDER_SUBTLE    0xFFFFFF1C

#define UI_TEXT_PRIMARY     0xF8FAFCFF
#define UI_TEXT_SECONDARY   0x94A3B8FF
#define UI_TEXT_MUTED       0x64748BFF

#define UI_ACCENT_OK        0x10B981FF
#define UI_ACCENT_INFO      0x38BDF8FF
#define UI_ACCENT_WARN      0xF59E0BFF
#define UI_ACCENT_DANGER    0xEF4444FF
```

Rules: no pure `#FF0000`/`#00FF00`/`#FFFF00`, no neon-violet gradient, no
outline+shadow on flat glass text (it muddies at 640x480).

## 3. Typography (letter size, proportional on)

| Role | Font | `LetterSize` |
|---|---|---|
| Micro badge / hotbar key | 2 | `0.16, 0.70` |
| Body / button label | 1 | `0.20, 0.90` |
| Card header / modal title | 2 | `0.26, 1.15` |
| Speedometer digits | 2 | `0.52, 2.10` |
| Unit suffix (`KM/H`) | 1 | `0.14, 0.62` |

Text is vertically centred by eye, not by formula: the engine's baseline is
~`LetterSize.y * 15` units below the create Y. Put the label at
`cardY + (cardH - letterSizeY * 15) / 2`.

## 4. Component blueprints

### A. Toast (top-right stack, 3 slots)
Card `150 x 34` at `x = 474`, `y = 18 + slot * 40`; 3-unit accent bar at the
left edge; title font 2 `0.18, 0.78`; body font 1 `0.16, 0.74`.
Expire by destroying the PlayerTextDraws — never hide-and-leak. 3 slots × 4
elements = 12 PlayerTD.

### B. Progress bar / skill check
Track sprite + fill sprite, same rect. Fill width `fullW * ratio`, minimum 1.0,
re-shown every update (`TD_BarSet`). Target-zone variant: second sprite
`zoneWidth` wide at `x + zoneStart`, `UI_ACCENT_WARN`; needle sprite 2 units wide
driven by a timer at 25–30 ms.

### C. Speedometer
Bottom-right, mirrored to the grid: digits at `x = 560`, `y = 420`; segmented
RPM as 10 sprites of `4 x 12` with a 2-unit gap. Update at 150–200 ms **only**
while `PLAYER_STATE_DRIVER`; destroy on exit. Never touch TextDraws inside
`OnPlayerUpdate`.

### D. Context prompt `[E]`
Keycap sprite `18 x 18` (`LD_SPAC:white` + Font 2 letter) at `x = 296`,
`y = 424`; label to its right; total width ≤ 120. Hide on action end. On mobile,
move it above the joystick zone and make the keycap ≥ 24 units tall.

### E. Radial menu
Nodes on an ellipse, not a circle: `x = 320 + rx*cos(a)`, `y = 240 + ry*sin(a)`
with `rx = 57`, `ry = 76` (the 0.75 correction applies to the radius, not the
angle). Node pill `64 x 18`, hub `LD_BEAT:chit` `20 x 27`. Always provide a
clickable centre close — mobile has no ESC.

### F. Inventory grid
5×4 slots of `54 x 54` with 6-unit gaps starting at `x = 150`, `y = 150`:
slot fill (font 5 model preview or icon sprite), 1-unit border sprite, keycap
badge, 3-unit durability bar. 20 slots × 4 = 80 PlayerTD + frame; keep a modal
under 140 and destroy everything on close.

### G. Radio / phone UI (signal bars + frequency + buttons)
Card `180 x 120` at `x = 230`, `y = 180`; 3 signal bars increasing height
(4×8, 4×12, 4×16) at `x = 245/252/259`, `y = 200/196/192`; title font 2
`0.22, 1.00` at `x = 280`, `y = 192`; frequency font 1 `0.18, 0.80` at
`x = 280`, `y = 208`; power button `LD_BEAT:chit` 24×24 at `x = 245`,
`y = 260` (TD_C_DANGER); refresh button 24×24 at `x = 275`, `y = 260`
(TD_C_INFO); close `LD_BEAT:cross` 16×16 at `x = 390`, `y = 185`.
Total: 14 PlayerTD. Update signal bars by recoloring, not recreating.
Reference: `resources/example_radio_ui.pwn` (compiles clean, both targets).

### H. HUD overlay (health / armor / money / wanted)
Bottom-left cluster: health bar track+fill `120 x 6` at `x = 20`, `y = 440`
(TD_C_DANGER fill); armor bar `120 x 6` at `x = 20`, `y = 428` (TD_C_INFO fill);
money text font 2 `0.26, 1.15` at `x = 20`, `y = 390` (TD_C_OK); wanted
stars as 6 `LD_SPAC:white` sprites `12 x 12` at `x = 20 + i*14`, `y = 410`
(TD_C_WARN when active, TD_C_TEXT_MUTED when inactive). Update at 250 ms only,
never in `OnPlayerUpdate`. Total: 16 PlayerTD.

### I. Login / auth screen
Centred card `280 x 200` at `x = 180`, `y = 140`; title font 2 `0.30, 1.30`
at `x = 320`, `y = 150` (centred); 2 input fields as bordered boxes
`240 x 28` at `x = 200`, `y = 190/230` (TD_C_ELEVATED fill + TD_C_HAIRLINE
border); login button `LD_BEAT:chit` `120 x 32` at `x = 260`, `y = 280`
(TD_C_OK); register link text at `x = 320`, `y = 320`. Total: 12 PlayerTD.
All tappable targets outside mobile dead zones.

## 5. Budget

| Subsystem | Ceiling |
|---|---|
| Persistent HUD | 22 |
| Speedometer | 16 |
| Toasts (3) | 12 |
| Prompt / progress | 6 |
| Modal (one at a time) | 140 |
| **Headroom to keep** | **≥ 60** |

Enforce single-modal with a UI state enum and `CloseActiveUI(playerid)` before
open. Exceeding 256 fails silently — the element just never appears.

## 6. Motion

`TD_EaseOutCubic` over 8–10 steps at 25–30 ms. Animate `TextSize` (bars) or
`Color` alpha (fades), never create/destroy per frame. Re-show after every
change.

## 7. Design self-check before shipping

1. Every surface is a font-4 sprite → `td-preview` shows box == hitbox.
2. No raw `TextDrawTextSize` in the diff; only kit calls.
3. `td-preview` prints zero `ERROR`/`WARN` layout diagnostics.
4. Both-target `pawncc` build has 0 warnings.
5. Tap targets outside the Android dead zone; nothing important below `y = 400`
   on the left third.
6. Palette only from constants; no element uses default background.

## 8. Design-to-code pipeline (general, any UI)

When asked to build ANY new TextDraw UI, follow this pipeline. Do NOT copy-paste
from examples; use the kit primitives and blueprints as building blocks.

### Step 1: Parse the request
- What is the UI for? (HUD, menu, dialog, inventory, map, settings, etc.)
- Who sees it? (all players, one player, specific faction)
- What data does it show? (static text, dynamic values, list items)
- What interactions? (clickable buttons, selectable rows, drag)
- Mobile or PC? (affects dead zones and tap target sizes)

### Step 2: Sketch the layout (ASCII)
```
┌─────────────────────────────────┐
│  [icon]  Title        [close]   │  <- header row
│  ─────────────────────────────  │  <- divider
│  [label]  Value                 │  <- data row
│  [label]  Value                 │
│  [button]  [button]             │  <- action row
└─────────────────────────────────┘
```
Every UI has: header, body, footer. Map each to kit primitives.

### Step 3: Choose components from the blueprint library
Use the blueprints in §5 (A-I) as starting points. For a UI not covered by any
blueprint, decompose it into: containers (TD_RoundedCard), text (TD_Text),
icons (TD_Sprite), bars (TD_Bar), buttons (TD_Sprite + TD_Text overlay).

### Step 4: Assign coordinates using the grid system
- Canvas: 640x480 (16:9 widescreen)
- Standard padding: 8 units between elements
- Standard card radius: 6 units (chit sprite)
- Standard button height: 24-32 units
- Standard text height: font 2 = 12 units, font 1 = 10 units
- Always leave 8-unit margin from screen edges

### Step 5: Generate code using the kit
Every element = one kit call. No raw TextDraw* calls in the diff.
```pawn
TD_RoundedCard(ui, x, y, w, h, TD_C_SURFACE, TD_C_HAIRLINE);
TD_Text(ui, x+8, y+8, "Title", TD_C_TEXT, 0.22, 1.00);
TD_Sprite(ui, x+w-24, y+8, 16, 16, "LD_BEAT:cross", TD_C_TEXT_MUTED);
```

### Step 6: Verify
1. Compile both targets (0 warnings, 0 errors)
2. Run td-preview (0 ERROR/WARN)
3. Check pool budget (≤256 per player)
4. Check mobile dead zones
5. Check all 8 interaction states

### Component system (build ANY UI from these 5 primitives)

| Primitive | Kit function | Use for |
|-----------|-------------|---------|
| Rounded card | TD_RoundedCard | Containers, panels, modals |
| Text label | TD_Text | Titles, values, descriptions |
| Sprite icon | TD_Sprite | Icons, buttons, badges |
| Progress bar | TD_Bar | Health, armor, loading, durability |
| Boxed text | TD_BoxedText | Input fields, highlighted rows |

### Common UI patterns (compose from primitives)

**Dialog / popup**: RoundedCard + title text + body text + 2 buttons (Sprite + Text)
**List / menu**: RoundedCard + header + N rows (each: text + optional icon) + scroll indicator
**Form / input**: RoundedCard + label + input box (BoxedText) + submit button
**HUD element**: Sprite(s) + text, positioned at screen edge, minimal footprint
**Notification / toast**: Small RoundedCard + icon + text, auto-dismiss after N ms
**Tabbed interface**: Header with tab buttons + content area that swaps on click
**Grid**: N×M cells (each: Sprite fill + border + optional badge)
**Progress tracker**: Bar + label + percentage text
**Map overlay**: Full-screen RoundedCard + map sprite + marker sprites + legend
**Settings panel**: RoundedCard + section headers + toggle switches + sliders

### Dynamic content handling
- **Lists > 10 items**: Use pagination (show 10, prev/next buttons)
- **Scrolling**: Use TD_Bar as scrollbar, update content on scroll position change
- **Live data**: Update text with PlayerTextDrawSetString, never recreate
- **Animations**: TD_EaseOutCubic over 8-10 steps, animate TextSize or Color alpha

### Responsive design (mobile vs PC)
- PC: full 640x480 canvas, small tap targets OK (8x8 minimum)
- Mobile: avoid bottom-left (y > 400, x < 120), use larger tap targets (24x24 min)
- Android safe zone: top 40 units, bottom 60 units, left 20 units
- Widescreen (16:9): use full width, center content horizontally

## 9. Modern TextDraw editors (2026)

| Editor | Type | Features |
|--------|------|----------|
| **San-Andreas-Online/web-textdraw-editor** | Web (browser) | Layer system, drag/resize, snap-to-grid, 449 sprite previews, export clean Pawn for both Global and Player TextDraws, no server required |
| **abdulrahman1s/open-mp-ui-editor** | Web + Rust native component | Visual editing, 449 sprite previews, Login/HUD/Inventory/Menu examples, independent per-player UI instances, Pawn callbacks, 640x448 coordinate space |
| **Nexor's TextDraw Editor** | In-game (filterscript) | Clickable interface, sprite selector (300+), preview models, templates, undo/redo |
| **Nickk's TextDraw Editor v5.0** | In-game (filterscript) | Multilanguage, progress bar support, sprite selector, templates, quick selection |

**Important**: All editors produce raw TextDraw code. The engine TextSize semantics (see `samp-textdraw-ui-craft` §1) are NOT applied by any editor. Always re-check with `td-preview` and compile both targets.

## 10. Compile-verified examples

- `resources/example_radio_ui.pwn` — radio/phone UI (14 PlayerTD, signal bars,
frequency display, power/refresh/close buttons). Compiles clean on both targets.
- `resources/fixture_ui.pwn` (in `samp-textdraw-ui-craft`) — basic card + bar +
text + close button. The canonical reference for kit usage.
