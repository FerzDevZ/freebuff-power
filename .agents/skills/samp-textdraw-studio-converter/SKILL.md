---
name: samp-textdraw-studio-converter
description: Professional TextDraw Production Workflow for open.mp & SA-MP — converting Figma/FiveM mockups (1920x1080 -> 640x480) and refactoring raw TDEditor/iTD/TDW exports into clean, modular, anchor-based open.mp PAWN code with automatic Global vs PlayerTextDraw splitting, loop compression, and visual HTML5 16:9 preview verification.
---

# TextDraw Studio & Figma-to-PAWN Conversion Workflow (open.mp 2026)

Stop shipping ugly 400-line raw `Textdraw0..Textdraw99` exports from old TDEditor tools! Use a repeatable studio pipeline to turn **Figma FiveM mockups** or **TDEditor/iTD/TDW exports** into clean, maintainable, pool-safe `open.mp` modules.

---

## 1. Exact Figma `1920x1080` -> SA-MP `640x480` Conversion Formulas

Design your FiveM-style HUD, Inventory, Phone, or Speedometer comfortably in **Figma on a `1920 x 1080` frame**, then map every pixel mathematically:

```text
sampX = (figmaX / 1920.0) * 640.0    // Simply divide Figma X by 3.0!
sampY = (figmaY / 1080.0) * 480.0    // Multiply Figma Y by 0.4444!
sampW = (figmaW / 1920.0) * 640.0    // Already preserves exact 16:9 proportions!
sampH = (figmaH / 1080.0) * 480.0
```
> **Magical Benefit:** Because `(640/1920) / (480/1080) = 0.3333 / 0.4444 = 0.75`, dividing Figma X/W by `3.0` and multiplying Figma Y/H by `4/9` (`0.4444`) **AUTOMATICALLY applies the 16:9 aspect-ratio correction**! A `60x60px` circle in Figma (`1920x1080`) becomes `w = 20.0, h = 26.67` in SA-MP — rendering as a **perfect circle** on 16:9 monitors!

### Typography Size Mapping (Figma `px` -> SA-MP `LetterSize`)
| Figma Font Size (1080p) | Recommended SA-MP `LetterSize(x, y)` | Typical Usage |
|---|---|---|
| `12px` – `14px` | `(0.15, 0.72)` – `(0.17, 0.80)` | Micro badges, hotbar numbers, subtle hints |
| `16px` – `18px` | `(0.19, 0.88)` – `(0.21, 0.96)` | Body text, button labels, toast copy |
| `22px` – `26px` | `(0.25, 1.15)` – `(0.29, 1.32)` | Card headers, modal titles |
| `44px` – `56px` | `(0.48, 2.05)` – `(0.58, 2.40)` | Digital Speedometer digits |

---

## 2. The 5-Step Refactoring Protocol for Raw TDEditor / iTD / TDW Dumps

Whenever you inherit or export raw TextDraw code:
1. **Extract Semantic Anchor Constants:**
   - Replace `CreatePlayerTextDraw(playerid, 482.5, 312.0, ...)` with `const Float:HUD_X = 482.5; const Float:HUD_Y = 312.0;` and write every child element relative to `HUD_X + dx, HUD_Y + dy`.
2. **Split Static vs Dynamic (Global vs PlayerTD):**
   - Static backgrounds, rounded frames, dividers, headers, and static icons -> **`Text:` Global TextDraw** (`OnGameModeInit`).
   - Dynamic values, clickable per-player slots, and progress fills -> **`PlayerText:`** (created on open, destroyed on close).
3. **Compress Repeated Grid Elements into Loops:**
   - Turn 20 copy-pasted inventory slots (220 lines) into a clean 15-line `for (new row = 0; row < 4; row++) for (new col = 0; col < 5; col++)` loop!
4. **Normalize Aesthetics & Hitboxes:**
   - Strip `SetOutline(1)` / `SetShadow(1)` bloat -> set `Outline(0)`, `Shadow(0)`, `Proportional(1)`.
   - Replace centered-text click boxes with `LD_SPAC:white` sprite buttons so hitboxes never misalign.
   - Replace raw hex numbers with named palette `#define`s (`UI_BG_GLASS_DARK`, `UI_ACCENT_PRIMARY`).
5. **Visual Verification Before Entering GTA SA:**
   - Run **`freepi-power samp td-preview <file.pwn>`** to render an instant 16:9 HTML5 Canvas mockup showing every element, bounding box, clickable hitbox, and total PlayerTD budget!
