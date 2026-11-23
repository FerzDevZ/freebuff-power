---
name: samp-textdraw-studio-converter
description: Figma/MTA-style mockup and TDEditor/iTD/TDW export conversion into maintainable open.mp & SA-MP TextDraw modules — exact 1920x1080 to 640x480 mapping, anchor extraction, global-vs-player splitting, loop compression, preview-mirror blocks, and a compile+preview gate before the code reaches a server.
---

# Mockup → PAWN TextDraw Conversion (open.mp 2026)

Turns a design (Figma, Photoshop, a FiveM screenshot, or a raw editor dump) into
a module that renders the same in game. Geometry rules live in
`samp-textdraw-ui-craft`; this skill is the conversion procedure.

---

## 1. Design frame → grid

Design at **1920 × 1080** and convert arithmetically:

```text
sampX = figmaX / 3.0          // 1920 -> 640
sampY = figmaY * (4.0 / 9.0)  // 1080 -> 480
sampW = figmaW / 3.0
sampH = figmaH * (4.0 / 9.0)
```

A 60×60 px circle becomes `w = 20.0, h = 26.67`. That is correct: 20 grid units
on a 16:9 screen is 60 px wide and 26.67 units is 60 px tall. Do **not** "fix"
the aspect by multiplying the result by 0.75 again — the conversion already
carries it. `TD_ASPECT_16_9` is only for hand-authored circles measured in grid
units directly.

Font size: `LetterSize.y ≈ figmaPx / 32` on a 1080p frame (`16 px ≈ 0.50` is too
large at 640×480 — verify with `td-preview`, not with arithmetic alone).

## 2. Convert in this order

1. **Classify each layer** — surface / text / icon / value.
   Surface → font-4 sprite. Text → font 1 or 2, no box. Icon → sprite or font 5.
2. **Extract anchors** — one base constant per component:
   `#define GARAGE_X (470.0)` / `#define GARAGE_Y (20.0)`; every child is
   `GARAGE_X + dx`. A component must be movable by editing two numbers.
3. **Split global vs player** — static frames → global `Text:` created once;
   per-player values, fills and clickable slots → `PlayerText:`.
4. **Compress loops** — 20 inventory slots become two nested `for` loops over a
   `new PlayerText:slot[MAX_SLOTS]` array.
5. **Emit kit calls** — `TD_Sprite` / `TD_Text` / `TD_RoundedCard` / `TD_Bar`.
6. **Add a preview mirror** — `td-preview` only parses inline
   `CreatePlayerTextDraw`, so repeat the final coordinates in a
   `#if defined TD_PREVIEW_MIRROR` block (see
   `samp-textdraw-ui-craft/resources/fixture_ui.pwn`).

## 3. Refactoring a raw TDEditor / iTD / TDW dump

Raw dumps fail in four predictable ways:

| Dump smell | Consequence | Fix |
|---|---|---|
| `Textdraw0 .. Textdraw87` globals | per-player state leaks between players | move dynamic values to `PlayerText:` |
| `TextDrawTextSize(td, 120.0, 18.0)` with left alignment | box renders from createX to 120 | pass `createX + 120` (or use the kit) |
| `SetOutline(1)` + `SetShadow(1)` everywhere | muddy 2012 look | 0/0 for flat UI |
| no `BackgroundColor` | black strip behind each label | transparent (`TD_C_TRANSPARENT`) |
| repeated identical slots | 400 unmaintainable lines | loop + array |

Never paste a dump straight into a gamemode. Convert, then delete the dump.

## 4. Gate

```bash
pawncc ui.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/ui.amx          # 0 warnings
freepi-power samp td-preview ui.pwn                       # layout diagnostics
freepi-power samp audit .                                 # legacy patterns
```

`td-preview` refuses to run silently on 0 elements: if your layout lives inside
`stock` helpers, add the mirror block or you get no verification at all.

## 5. Acceptance checklist

- Changing one anchor moves the whole component without overlap.
- `td-preview` reports 0 errors and 0 warnings.
- Player TD count for the screen ≤ 140 with ≥ 60 headroom.
- Every tappable element is a sprite with `TextSize` set and outside the mobile
  dead zone.
- Static layers are global; only dynamic layers are per-player.
- Both-target compile clean; no `#include <a_samp>` left in an open.mp project.
