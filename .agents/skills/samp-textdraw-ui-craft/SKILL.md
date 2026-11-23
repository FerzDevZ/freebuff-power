---
name: samp-textdraw-ui-craft
description: TextDraw engine truth for SA-MP 0.3.7 & open.mp 2026 — TextSize semantics per alignment/font (the real cause of broken layout, oversized boxes, misplaced bars and dead hitboxes), default BackgroundColor/BoxColor/LetterSize traps, 640x480 + 16:9 geometry, pool limits (2048 global / 256 per player), INVALID_PLAYER_TEXT_DRAW sentinel, and a compile-verified Pawn kit (resources/samp_td_kit.inc).
---

# TextDraw Engine Truth (open.mp & SA-MP)

Use this skill **before** any TextDraw layout work. Pair with
`samp-textdraw-fivem-modern-design` for aesthetics and
`samp-textdraw-layout-debugger` when a layout already renders wrong.

> Non-negotiable: **do not hand-write `TextDrawTextSize` math.** Use
> `resources/samp_td_kit.inc`, which is compiled in CI against both
> open.mp's `omp-stdlib` and the legacy `pawn-lang/samp-stdlib`.

---

## 1. The four behaviours of `TextDrawTextSize` (the actual root cause)

Verified against open.mp docs and `omp_textdraw.inc`:

| Alignment / font | `TextSize.x` means | `TextSize.y` means |
|---|---|---|
| `TEXT_DRAW_ALIGN_LEFT` (1) | **absolute right-most corner** on the 640 grid | height |
| `TEXT_DRAW_ALIGN_CENTER` (2) | **overall box width**, box centred on the create X | height |
| `TEXT_DRAW_ALIGN_RIGHT` (3) | **absolute left-most corner** on the 640 grid | height |
| font 4 (sprite) / font 5 (model preview) | **width offset** | height offset |

Consequences that produce exactly the symptoms people report:

- Passing `width` where an absolute corner is expected makes the box end at
  `x = width` instead of `x = createX + width`. A 150-unit card at x=480 becomes a
  box from 480 to 150 → inverted/tiny/huge depending on the element. **This is the
  "kadang besar kadang kecil" bug.**
- Out-of-order calls: `TextSize` is interpreted using the alignment/font that are
  active **at call time**. Setting alignment after sizing silently shifts the box.
- Font 4/5 are the exception: `(w, h)` are always offsets, so a sprite card and a
  boxed label at the same coordinates will never line up. Mixing them per element
  is why text, bar and box drift apart.

**Rule:** set `Font` → `Alignment` → `TextSize`, in that order, and only through
`TD_Sprite` / `TD_Text` / `TD_BoxedText` from the kit.

## 2. Defaults that break layouts silently

| Property | Engine default | Symptom |
|---|---|---|
| `LetterSize` | `0.0, 0.0` | text is created but **invisible** ("tulisannya di mana?") |
| `BackgroundColor` | opaque black | black bar behind text, looks 2012-era |
| `BoxColor` | dark strip | an unexpected box when `UseBox = 1` |
| `TextSize` on font 4 | not set | sprite never renders → invisible button, dead hitbox |
| `TextSize` on a selectable element | not set | click region is 0 units, clicks never land |

The kit sets all of these explicitly. If you write raw natives, set them yourself.

## 3. Box inset (why boxes look shifted)

The engine draws a `UseBox` box offset from the create coordinate — it starts
**10.0 units up and 5.0 units to the left**. Two elements that share a create
coordinate therefore do **not** share a visual corner. Either compensate with
`TD_BOX_INSET_X` / `TD_BOX_INSET_Y`, or (preferred) build surfaces from font-4
sprites and never use boxes for layout.

## 4. Geometry

- Grid: `640.0 x 480.0`.
- On a 16:9 screen the horizontal unit is stretched by 4:3, so a square/circle of
  height `h` needs `h * 0.75` units of width. `TD_ASPECT_16_9` is that constant.
- The 0.75 factor is **only** valid at 16:9. At 4:3 it is 1.0, at 21:9 ≈ 0.64.
  If a client is not 16:9, correct once globally instead of per element.
- Mobile clients reserve the lower-left joystick and lower-right action pad.
  Anything tappable must pass `TD_InTouchDeadZone()`.

## 5. Pool limits (hard engine limits, they fail silently)

| Pool | Limit | Failure mode |
|---|---|---|
| `MAX_TEXT_DRAWS` | 2048 (global) | `TextDrawCreate` returns `INVALID_TEXT_DRAW`, nothing draws |
| `MAX_PLAYER_TEXT_DRAWS` | 256 per player | `CreatePlayerTextDraw` returns `INVALID_PLAYER_TEXT_DRAW`, nothing draws |

Sentinel tags matter: open.mp tags `INVALID_TEXT_DRAW` as `Text:`. Comparing it
against a `PlayerText:` produces a mismatched-tag comparison — use the kit's
`TD_IsInvalid()` / `TD_Destroy()`.

## 6. Canonical usage (compiles on both targets)

```pawn
#include <open.mp>            // or <a_samp> for 0.3.7
#include "samp_td_kit.inc"

new PlayerText:gCard[6];
new PlayerText:gTrack, PlayerText:gFill;
new PlayerText:gLabel, PlayerText:gClose;

public OnPlayerConnect(playerid)
{
    new remaining;
    if (!TD_HasBudget(playerid, 10, remaining))
        return SendClientMessage(playerid, 0xEF4444FF, "UI budget habis");

    TD_RoundedCard(playerid, gCard, 470.0, 20.0, 150.0, 64.0, 6.0, TD_C_SURFACE);
    gLabel = TD_Text(playerid, 480.0, 26.0, "GARAGE", TD_C_TEXT, 0.22, 0.95);
    TD_Bar(playerid, gTrack, gFill, 480.0, 60.0, 130.0, 6.0, TD_C_ELEVATED, TD_C_OK);
    gClose = TD_Sprite(playerid, 596.0, 24.0, 18.0, 18.0, "LD_BEAT:cross", TD_C_TEXT_DIM, true);

    SelectTextDraw(playerid, 0x38BDF8AA);
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (playertextid == gClose)
    {
        TD_DestroyAll(playerid, gCard, 6);
        TD_Destroy(playerid, gLabel);
        TD_Destroy(playerid, gTrack);
        TD_Destroy(playerid, gFill);
        TD_Destroy(playerid, gClose);
        CancelSelectTextDraw(playerid);
    }
    return 1;
}
```

Progress bars: after changing `TextSize` you **must** re-show the TextDraw or the
client keeps drawing the old width (`TD_BarSet` already does this).

## 7. Style rules that keep it from looking 2012

- `SetOutline(0)` + `SetShadow(0)` on flat UI; `SetProportional(1)` on text fonts.
- Palette in `UI_*`/`TD_C_*` constants only; no raw hex scattered through code.
- RGBA, alpha is the **low** byte (`0xRRGGBBAA`). `TD_WithAlpha()` handles it.
- Static frames → global `Text:`; only per-player values → `PlayerText:`.

## 8. Gate (run these, do not eyeball)

```bash
# 1. geometry + defaults audit of a .pwn (renders HTML + prints Layout gate diagnostics)
freepi-power samp td-preview path/to/ui.pwn

# 2. compile both targets, must be 0 warnings
pawncc ui.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/ui.amx
pawncc ui.pwn -i"$LEGACY_STDLIB" -i"$PAWN_CORE_INCLUDE" -d3 -o/tmp/ui_legacy.amx

# 3. legacy-pattern audit
freepi-power samp audit .
```

The kit's own fixture (`resources/fixture_ui.pwn`) is the reference for a layout
that passes all three.

## References

- `resources/samp_td_kit.inc` — all primitives, alignment-aware sizing, pool guard.
- `resources/fixture_ui.pwn` — compiles clean on open.mp and 0.3.7; also carries the
  `TD_PREVIEW_MIRROR` block that `td-preview` reads.
- open.mp function docs: `TextDrawTextSize`, `PlayerTextDrawTextSize`,
  `TextDrawAlignment` (the notes list the alignment behaviour verbatim).
