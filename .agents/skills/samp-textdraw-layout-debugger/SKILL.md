---
name: samp-textdraw-layout-debugger
description: Diagnose a TextDraw layout that renders wrong in SA-MP/open.mp — oversized or tiny boxes, bars in the wrong place, invisible text, dead click areas, elements shifted between resolutions. Maps each visible symptom to its exact engine cause (TextSize alignment semantics, box inset, default BackgroundColor/BoxColor/LetterSize, font 4 vs boxed text, pool exhaustion) and gives the minimal fix.
---

# TextDraw Layout Debugger

Use when the design looks right in a mockup/editor but renders wrong in game.
Fix causes, never nudge coordinates until it "looks okay".

---

## 1. Symptom → cause table

| Symptom | Cause | Fix |
|---|---|---|
| Box/card is huge, tiny, or inverted | `TextSize(x)` passed as width while alignment is LEFT (x must be the **absolute** right corner) | use `TD_ApplySize` / `TD_Sprite`; or pass `createX + width` |
| Text sits far from its card | text uses `UseBox = 1`; engine insets the box by (−5, −10) | drop the box, use a sprite surface + plain text |
| Bar fill starts somewhere else / wrong length | fill `TextSize` changed without re-showing, or width passed as corner | `TD_BarSet` (re-shows automatically) |
| Text completely invisible | `LetterSize` left at default `0.0, 0.0` | set `0.18–0.24, 0.85–1.0` |
| Black strip behind every label | `BackgroundColor` default is opaque black | set transparent (`TD_C_TRANSPARENT`) |
| Unexpected dark rectangle | `UseBox = 1` with default `BoxColor` | set box color or remove box |
| Click lands on the neighbour button | overlap, or hitbox ≠ visual box because of box/left-align mismatch | make the backdrop the only selectable sprite, label `selectable = false` |
| Clicks never register | selectable element has no `TextSize` (0-unit region) | set `TextSize`, keep ≥ 1.0 |
| Element missing entirely after adding a screen | 256 PlayerTD exceeded → `CreatePlayerTextDraw` returned `INVALID_PLAYER_TEXT_DRAW` | destroy closed screens; move static layers to global `Text:` |
| Fine on 16:9, broken on 4:3 / ultra-wide | hardcoded `0.75` aspect applied per element | apply correction globally per client aspect |
| Layout correct in editor, wrong in game | editor draws `TextSize` as width/height for all fonts | trust `td-preview` (engine rules) not the editor canvas |

## 2. Deterministic procedure (5 minutes)

```bash
# 1. Render + diagnostics. Prints "Layout gate: N masalah -> ..." in the page
#    and refuses to pretend success when it parsed 0 elements.
freepi-power samp td-preview path/to/ui.pwn /tmp/ui.html

# 2. Grep for the three raw natives that cause most of it
rg -n 'TextDraw(TextSize|Alignment|UseBox)' path/to/ui.pwn

# 3. Compile both targets (a tag/mismatch problem is a layout problem too)
pawncc ui.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/ui.amx
```

`td-preview` flags, in order of severity:

- `ERROR ... align LEFT tapi TextSize.x < Create.x` → inverted box/hitbox.
- `ERROR ... selectable tanpa TextSize` → dead click area.
- `ERROR ... LetterSize tidak diset` → invisible text.
- `WARN ... BackgroundColor default hitam opaque` → black strip.
- `WARN ... UseBox aktif tapi BoxColor tidak diset`.
- `WARN ... create pos di luar kanvas`.

## 3. Worked example

Reported: "card 150×64 at (470,20) renders as a thin sliver, the bar is at the
wrong end, the title is missing".

```pawn
// What was generated (wrong)
new PlayerText:c = CreatePlayerTextDraw(p, 470.0, 20.0, "LD_SPAC:white");
PlayerTextDrawFont(p, c, TEXT_DRAW_FONT_SPRITE_DRAW);
PlayerTextDrawTextSize(p, c, 150.0, 64.0);   // sprite -> offset: this one is OK
new PlayerText:t = CreatePlayerTextDraw(p, 480.0, 26.0, "GARAGE");
PlayerTextDrawTextSize(p, t, 130.0, 20.0);   // box on LEFT alignment: broken
PlayerTextDrawUseBox(p, t, 1);
```

The sprite is fine; the label is not. With LEFT alignment `TextSize.x = 130` is a
corner on the 640 grid, so the box spans 480→130 — it collapses and drags the
visual anchor. Title has no `LetterSize`, so it is invisible.

```pawn
// Fixed (kit)
TD_Sprite(p, 470.0, 20.0, 150.0, 64.0, "LD_SPAC:white", TD_C_SURFACE);
TD_Text(p, 480.0, 31.0, "GARAGE", TD_C_TEXT, 0.22, 0.95);
```

No coordinates were "nudged"; two causes were removed.

## 4. Escalation

- Still wrong after the gate is clean? Suspect the **client**, not the script:
  different aspect ratio, mobile safe zone, or an ENB/mod altering projection.
  Reproduce at 1920×1080 first, then at 1024×768.
- Hitbox correct but highlight wrong: the selectable element is behind another
  sprite. Selection order follows creation/priority — make the intended target
  the last created selectable element in that stack.
- Random disappearance under load: pool exhaustion, not streaming. Count
  PlayerTDs per player with the preview badge.

## 5. Rules to hand back to the author

1. Never write `TextDrawTextSize` by hand in UI code.
2. Set `Font` → `Alignment` → `TextSize`.
3. Sprite surfaces only; no boxes for layout.
4. Every selectable element is a sprite with explicit size.
5. Destroy on close; budget before build.
