---
name: samp-textdraw-fivem-modern-design
description: FiveM/NoPixel/Ox_lib-grade TextDraw UI design for SA-MP & open.mp — sprite-first composition (no boxed text for layout), 2026 dark-slate glass palette, rounded cards, HUD, speedometer, toasts, progress bars, radial menu, inventory grid, mobile-safe tap targets, and 256 PlayerTextDraw pool budgeting. All geometry goes through the compile-verified samp_td_kit.inc.
---

# FiveM-Style TextDraw Design (SA-MP & open.mp)

Aesthetic layer. Geometry, defaults and pool safety come from
`samp-textdraw-ui-craft` + `resources/samp_td_kit.inc`; never re-derive
`TextSize` math by hand here.

---

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
