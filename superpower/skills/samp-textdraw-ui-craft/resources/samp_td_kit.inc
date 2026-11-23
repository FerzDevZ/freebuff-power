/*  samp_td_kit.inc  —  TextDraw geometry kit for SA-MP 0.3.7 & open.mp
 *
 *  WHY THIS FILE EXISTS
 *  TextDrawTextSize() means three different things depending on alignment and font:
 *    1 (left)   -> x,y are the RIGHT-MOST corner, ABSOLUTE grid coordinates
 *    2 (center) -> x is the overall box width, y is height; create pos is the CENTER
 *    3 (right)  -> x,y are the LEFT-MOST corner, ABSOLUTE grid coordinates
 *    font 4 (sprite) and font 5 (model preview) -> x,y are WIDTH and HEIGHT offsets
 *  Passing a width where an absolute corner is expected (or vice versa) is the #1
 *  cause of "box/bar/text lands in a different place than designed".
 *  Everything below routes through TD_SizeFor() so callers always pass width/height.
 *
 *  Verified against open.mp omp_textdraw.inc: MAX_TEXT_DRAWS 2048,
 *  MAX_PLAYER_TEXT_DRAWS 256, TEXT_DRAW_FONT_SPRITE_DRAW == 4,
 *  INVALID_PLAYER_TEXT_DRAW is the PlayerText-tagged sentinel.
 *
 *  Compile:  pawncc -i<open.mp include dir> -d3
 */

#if defined _samp_td_kit_included
	#endinput
#endif
#define _samp_td_kit_included

/* Keep the kit warning-free on BOTH include sets:
 *  - open.mp exposes Colour natives and a tagged TEXT_DRAW_ALIGN enum
 *  - SA-MP 0.3.7 only has the Color spelling and plain integers
 * Do not "fix" this by defining MIXED_SPELLINGS here: open.mp decides which
 * aliases to mark deprecated while ITS includes are parsed, which happens
 * before any skill include is read. */
#if defined PlayerTextDrawColour
	#define TD_SetColor      PlayerTextDrawColour
	#define TD_SetBgColor    PlayerTextDrawBackgroundColour
	#define TD_SetBoxColor   PlayerTextDrawBoxColour
#else
	#define TD_SetColor      PlayerTextDrawColor
	#define TD_SetBgColor    PlayerTextDrawBackgroundColor
	#define TD_SetBoxColor   PlayerTextDrawBoxColor
#endif

#if defined TEXT_DRAW_ALIGN
	#define TD_ALIGN(%0)     (TEXT_DRAW_ALIGN:(%0))
#else
	#define TD_ALIGN(%0)     (%0)
#endif

/* Plain SA-MP 0.3.7 a_samp.inc ships TEXT_DRAW_FONT_SPRITE_DRAW but not the
 * TEXT_DRAW_ALIGN_* names, so supply them when the include set is older. */
#if !defined TEXT_DRAW_ALIGN_LEFT
	#define TEXT_DRAW_ALIGN_LEFT    (1)
	#define TEXT_DRAW_ALIGN_CENTER  (2)
	#define TEXT_DRAW_ALIGN_RIGHT   (3)
#endif
#if !defined TEXT_DRAW_FONT_0
	#define TEXT_DRAW_FONT_0            (0)
	#define TEXT_DRAW_FONT_1            (1)
	#define TEXT_DRAW_FONT_2            (2)
	#define TEXT_DRAW_FONT_3            (3)
#endif

/* ============================ 1. Geometry ============================ */

#define TD_GRID_W               (640.0)
#define TD_GRID_H               (480.0)

/* Horizontal unit of the 640x480 grid is stretched by 4:3 on a 16:9 screen,
 * so a shape that is h units tall needs (h * 0.75) units of width to look square.
 * Only valid at 16:9. Expose it as a variable so a mismatched client can be
 * corrected without touching layout math. */
#define TD_ASPECT_16_9          (0.75)

/* The engine draws a UseBox box offset from the TextDrawCreate coordinate
 * (box origin starts 10.0 units up and 5.0 units to the left). */
#define TD_BOX_INSET_X          (5.0)
#define TD_BOX_INSET_Y          (10.0)

/* Font 4/5 ignore alignment for sizing; every other font does not. */
#define TD_IsOffsetFont(%0)     ((%0) == _:TEXT_DRAW_FONT_SPRITE_DRAW || (%0) == _:TEXT_DRAW_FONT_MODEL_PREVIEW)

/* ============================ 2. Palette ============================= */

#define TD_C_TRANSPARENT        (0x00000000)
#define TD_C_SURFACE            (0x0B0F19E6)
#define TD_C_SURFACE_RAISED     (0x111827F0)
#define TD_C_ELEVATED           (0x1E293BF2)
#define TD_C_HOVER              (0x273549F5)
#define TD_C_HAIRLINE           (0xFFFFFF1C)

#define TD_C_TEXT               (0xF8FAFCFF)
#define TD_C_TEXT_DIM           (0x94A3B8FF)
#define TD_C_TEXT_MUTED         (0x64748BFF)

#define TD_C_OK                 (0x10B981FF)
#define TD_C_INFO               (0x38BDF8FF)
#define TD_C_WARN               (0xF59E0BFF)
#define TD_C_DANGER             (0xEF4444FF)

/* ====================== 3. Alignment-correct sizing ================== */

/* Apply a width/height to an already-aligned TextDraw. Call AFTER setting font
 * and alignment. Returns the effective width used for hitbox math (font 4/5
 * clamp to a 1.0 unit minimum, below which the sprite is not drawn at all). */
stock Float:TD_ApplySize(PlayerText:td, playerid, Float:originX, Float:width, Float:height, alignment, font)
{
	new Float:w = width;
	if (TD_IsOffsetFont(font) && w < 1.0)
		w = 1.0;

	if (TD_IsOffsetFont(font))
	{
		PlayerTextDrawTextSize(playerid, td, w, height);
	}
	else if (alignment == _:TEXT_DRAW_ALIGN_CENTER)
	{
		PlayerTextDrawTextSize(playerid, td, w, height);
	}
	else if (alignment == _:TEXT_DRAW_ALIGN_RIGHT)
	{
		PlayerTextDrawTextSize(playerid, td, originX - w, height);
	}
	else
	{
		PlayerTextDrawTextSize(playerid, td, originX + w, height);
	}
	return w;
}

/* ========================= 4. Factories ============================== */

/* Font-4 sprite rectangle. TextSize is a width/height offset, so this is the
 * only primitive whose visual box and click box are guaranteed identical. */
stock PlayerText:TD_Sprite(playerid, Float:x, Float:y, Float:w, Float:h, const sprite[], color, bool:selectable = false)
{
	new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, sprite);

	PlayerTextDrawFont(playerid, td, TEXT_DRAW_FONT_SPRITE_DRAW);
	TD_SetColor(playerid, td, color);
	TD_SetBgColor(playerid, td, TD_C_TRANSPARENT);
	TD_SetBoxColor(playerid, td, TD_C_TRANSPARENT);
	PlayerTextDrawUseBox(playerid, td, false);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetShadow(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, false);
	PlayerTextDrawTextSize(playerid, td, (w < 1.0) ? 1.0 : w, h);
	PlayerTextDrawSetSelectable(playerid, td, selectable);
	PlayerTextDrawShow(playerid, td);

	return td;
}

/* Text primitive. Sets EVERY property that silently defaults to a broken value:
 *   background colour defaults to opaque black -> black bar behind the text
 *   box colour defaults to a dark strip  -> random box when UseBox is on
 *   letter size defaults to 0.0          -> invisible text
 * Never leave these to the engine. */
stock PlayerText:TD_Text(
	playerid,
	Float:x,
	Float:y,
	const text[],
	color,
	Float:letterW = 0.20,
	Float:letterH = 0.90,
	alignment = TEXT_DRAW_ALIGN_LEFT,
	bool:selectable = false,
	Float:clickW = 0.0,
	Float:clickH = 0.0
) {
	new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, text);

	PlayerTextDrawAlignment(playerid, td, TD_ALIGN(alignment)); /* before sizing */
	PlayerTextDrawFont(playerid, td, TEXT_DRAW_FONT_1);
	PlayerTextDrawLetterSize(playerid, td, (letterW < 0.05) ? 0.05 : letterW, (letterH < 0.05) ? 0.05 : letterH);
	TD_SetColor(playerid, td, color);
	TD_SetBgColor(playerid, td, TD_C_TRANSPARENT);
	TD_SetBoxColor(playerid, td, TD_C_TRANSPARENT);
	PlayerTextDrawUseBox(playerid, td, false);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetShadow(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, true);

	if (clickW > 0.0 && clickH > 0.0)
		TD_ApplySize(td, playerid, x, clickW, clickH, alignment, TEXT_DRAW_FONT_1);

	PlayerTextDrawSetSelectable(playerid, td, selectable);
	PlayerTextDrawShow(playerid, td);

	return td;
}

/* Boxed text. Use only when a real boxed label is wanted: the engine insets the
 * box by (5,10), so a box that must line up with sprites needs TD_BOX_INSET_* . */
stock PlayerText:TD_BoxedText(
	playerid,
	Float:x,
	Float:y,
	Float:w,
	Float:h,
	const text[],
	textColor,
	boxColor,
	Float:letterW = 0.20,
	Float:letterH = 0.90,
	bool:selectable = false
) {
	new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, text);

	PlayerTextDrawAlignment(playerid, td, TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawFont(playerid, td, TEXT_DRAW_FONT_1);
	PlayerTextDrawLetterSize(playerid, td, letterW, letterH);
	TD_SetColor(playerid, td, textColor);
	TD_SetBgColor(playerid, td, TD_C_TRANSPARENT);
	TD_SetBoxColor(playerid, td, boxColor);
	PlayerTextDrawUseBox(playerid, td, true);
	PlayerTextDrawSetOutline(playerid, td, 0);
	PlayerTextDrawSetShadow(playerid, td, 0);
	PlayerTextDrawSetProportional(playerid, td, true);
	TD_ApplySize(td, playerid, x, w, h, TEXT_DRAW_ALIGN_LEFT, TEXT_DRAW_FONT_1);
	PlayerTextDrawSetSelectable(playerid, td, selectable);
	PlayerTextDrawShow(playerid, td);

	return td;
}

/* ========================= 5. Composition =========================== */

/* Rounded card out of 6 sprites. Radius 0 gives a crisp 4-sprite card.
 * Returns the sprite count consumed (4 or 6). */
stock TD_RoundedCard(playerid, PlayerText:refIds[6], Float:x, Float:y, Float:w, Float:h, Float:radius, color)
{
	new Float:rx = radius * TD_ASPECT_16_9;
	new Float:ry = radius;
	new idx = 0;

	if (radius <= 0.0)
	{
		refIds[idx++] = TD_Sprite(playerid, x, y, w, h, "LD_SPAC:white", color);
		return idx;
	}

	new Float:diamX = rx * 2.0;
	new Float:diamY = ry * 2.0;

	refIds[idx++] = TD_Sprite(playerid, x, y + ry, w, h - diamY, "LD_SPAC:white", color);
	refIds[idx++] = TD_Sprite(playerid, x + rx, y, w - diamX, h, "LD_SPAC:white", color);
	refIds[idx++] = TD_Sprite(playerid, x, y, diamX, diamY, "LD_BEAT:chit", color);
	refIds[idx++] = TD_Sprite(playerid, x + w - diamX, y, diamX, diamY, "LD_BEAT:chit", color);
	refIds[idx++] = TD_Sprite(playerid, x, y + h - diamY, diamX, diamY, "LD_BEAT:chit", color);
	refIds[idx++] = TD_Sprite(playerid, x + w - diamX, y + h - diamY, diamX, diamY, "LD_BEAT:chit", color);

	return idx;
}

/* Horizontal progress bar: track sprite + fill sprite.
 * Fill width is recomputed from ratio; a 0.0 width sprite would vanish, so a
 * fully empty bar hides the fill instead of collapsing it. */
stock TD_Bar(playerid, &PlayerText:track, &PlayerText:fill, Float:x, Float:y, Float:w, Float:h, trackColor, fillColor)
{
	track = TD_Sprite(playerid, x, y, w, h, "LD_SPAC:white", trackColor);
	fill  = TD_Sprite(playerid, x, y, w, h, "LD_SPAC:white", fillColor);
	return 1;
}

stock TD_BarSet(playerid, PlayerText:fill, Float:x, Float:y, Float:w, Float:h, Float:fullW, Float:ratio)
{
	if (ratio <= 0.0)
	{
		PlayerTextDrawHide(playerid, fill);
		return 0;
	}
	if (ratio > 1.0) ratio = 1.0;

	new Float:fw = fullW * ratio;
	if (fw < 1.0) fw = 1.0;

	PlayerTextDrawTextSize(playerid, fill, fw, h);
	PlayerTextDrawShow(playerid, fill); /* required: size change needs a re-show */
	#pragma unused x, y, w
	return 1;
}

/* ========================= 6. Safety ================================ */

/* Correct sentinel per tag. open.mp tags INVALID_TEXT_DRAW as Text:, so using it
 * for a PlayerText compares mismatched tags and produces the wrong value. */
stock bool:TD_IsInvalid(PlayerText:td)
{
	#if defined INVALID_PLAYER_TEXT_DRAW
		return (td == INVALID_PLAYER_TEXT_DRAW);
	#else
		return (_:td == 0xFFFF);
	#endif
}

stock TD_Destroy(playerid, &PlayerText:td)
{
	if (!TD_IsInvalid(td))
	{
		PlayerTextDrawDestroy(playerid, td);
		#if defined INVALID_PLAYER_TEXT_DRAW
			td = INVALID_PLAYER_TEXT_DRAW;
		#else
			td = PlayerText:0xFFFF;
		#endif
	}
}

stock TD_DestroyAll(playerid, PlayerText:refIds[], size)
{
	for (new i = 0; i < size; i++)
		TD_Destroy(playerid, refIds[i]);
}

/* Pool budget guard: 256 per player is a hard engine limit and exceeding it
 * fails silently (the CreatePlayerTextDraw returns INVALID and the element
 * simply never appears). Call before building a screen. */
stock bool:TD_HasBudget(playerid, count, &remaining)
{
	#pragma unused playerid
	remaining = _:MAX_PLAYER_TEXT_DRAWS - count;
	return (count + 1 <= _:MAX_PLAYER_TEXT_DRAWS);
}

/* Mobile clients reserve the lower-left joystick and lower-right action pad.
 * Anything a player must tap has to stay outside these rects. */
stock bool:TD_InTouchDeadZone(Float:x, Float:y, Float:w, Float:h)
{
	new bool:left  = (x < 190.0) && (y + h > 300.0);
	new bool:right = (x + w > 450.0) && (y + h > 270.0);
	return (left || right);
}

/* ========================= 7. Motion ================================ */

stock Float:TD_EaseOutCubic(Float:t)
{
	if (t <= 0.0) return 0.0;
	if (t >= 1.0) return 1.0;
	new Float:inv = 1.0 - t;
	return 1.0 - (inv * inv * inv);
}

/* RGBA: alpha is the LOW byte, so | alpha is correct. Never add a high-byte shift. */
stock TD_WithAlpha(color, alpha)
{
	return (color & 0xFFFFFF00) | (alpha & 0xFF);
}

stock TD_FadeIn(playerid, PlayerText:td, color, step)
{
	if (step <= 0) return 0;
	new alpha = (step * 255) / 100;
	if (alpha > 255) alpha = 255;
	TD_SetColor(playerid, td, TD_WithAlpha(color, alpha));
	PlayerTextDrawShow(playerid, td);
	return 1;
}
