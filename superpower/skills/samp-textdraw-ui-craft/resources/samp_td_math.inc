/* TextDraw layout math, no natives required.
 *
 * TextDraw coordinates always live in a 640x480 space regardless of the
 * player's resolution, so every layout decision is arithmetic: fitting a design
 * into an aspect, hitbox geometry, grid placement, easing. This file keeps those
 * formulas in one place and is verified numerically by demo_td_math.pwn.
 *
 * Conventions, stated because they are choices and not universal truths:
 *   - Hitboxes are half-open on the right/bottom edge in layout terms but the
 *     hit test is inclusive, matching how a player clicking the last pixel
 *     expects the control to react.
 *   - TDM_ALIGN_CENTER treats x as the visual centre of the box (TextDraw
 *     alignment 2 does this for text); sprites are left-anchored, so use
 *     TDM_HitboxSprite for them.
 *   - TDM_DesignToScreen uses "contain": the whole design stays visible,
 *     centred, with equal margins on the constrained axis.
 */
#if defined _samp_td_math_included
    #endinput
#endif
#define _samp_td_math_included

#define TDM_DESIGN_W        (640.0)
#define TDM_DESIGN_H        (480.0)

#define TDM_ALIGN_LEFT      (0)
#define TDM_ALIGN_CENTER    (1)
#define TDM_ALIGN_RIGHT     (2)

stock Float:TDM_Clamp(Float:value, Float:low, Float:high)
{
    if (value < low) return low;
    if (value > high) return high;
    return value;
}

stock Float:TDM_Clamp01(Float:value)
{
    return TDM_Clamp(value, 0.0, 1.0);
}

stock Float:TDM_Lerp(Float:from, Float:to, Float:t)
{
    return from + (to - from) * t;
}

/** Ease-out cubic: fast start, settles exactly at 1.0. */
stock Float:TDM_EaseOutCubic(Float:t)
{
    new Float:inverse = 1.0 - TDM_Clamp01(t);
    return 1.0 - inverse * inverse * inverse;
}

stock Float:TDM_EaseInOutQuad(Float:t)
{
    t = TDM_Clamp01(t);
    if (t < 0.5) return 2.0 * t * t;

    new Float:inverse = 1.0 - t;
    return 1.0 - 2.0 * inverse * inverse;
}

/** Width of a progress fill; negative or oversized ratios are clamped. */
stock Float:TDM_ProgressFill(Float:fullWidth, Float:ratio)
{
    if (fullWidth <= 0.0) return 0.0;
    return fullWidth * TDM_Clamp01(ratio);
}

stock TDM_HitboxSprite(Float:x, Float:y, Float:width, Float:height,
    &Float:minX, &Float:minY, &Float:maxX, &Float:maxY)
{
    minX = x;
    minY = y;
    maxX = x + width;
    maxY = y + height;
}

stock TDM_HitboxAligned(Float:x, Float:y, Float:width, Float:height, alignment,
    &Float:minX, &Float:minY, &Float:maxX, &Float:maxY)
{
    minY = y;
    maxY = y + height;

    switch (alignment)
    {
        case TDM_ALIGN_CENTER:
        {
            minX = x - width / 2.0;
            maxX = x + width / 2.0;
        }
        case TDM_ALIGN_RIGHT:
        {
            minX = x - width;
            maxX = x;
        }
        default:
        {
            minX = x;
            maxX = x + width;
        }
    }
}

stock bool:TDM_HitTest(Float:minX, Float:minY, Float:maxX, Float:maxY, Float:pointX, Float:pointY)
{
    return pointX >= minX && pointX <= maxX && pointY >= minY && pointY <= maxY;
}

stock bool:TDM_HitTestAligned(Float:x, Float:y, Float:width, Float:height, alignment,
    Float:pointX, Float:pointY)
{
    new Float:minX, Float:minY, Float:maxX, Float:maxY;
    TDM_HitboxAligned(x, y, width, height, alignment, minX, minY, maxX, maxY);
    return TDM_HitTest(minX, minY, maxX, maxY, pointX, pointY);
}

/** Uniform scale that keeps a design box fully inside the target resolution. */
stock Float:TDM_ContainScale(Float:sourceW, Float:sourceH, Float:targetW, Float:targetH)
{
    if (sourceW <= 0.0 || sourceH <= 0.0 || targetW <= 0.0 || targetH <= 0.0) return 0.0;

    new Float:scaleX = targetW / sourceW;
    new Float:scaleY = targetH / sourceH;
    return scaleX < scaleY ? scaleX : scaleY;
}

stock TDM_DesignToScreen(Float:x, Float:y, Float:sourceW, Float:sourceH,
    Float:targetW, Float:targetH, &Float:screenX, &Float:screenY, &Float:scale)
{
    scale = TDM_ContainScale(sourceW, sourceH, targetW, targetH);
    if (scale <= 0.0)
    {
        screenX = 0.0;
        screenY = 0.0;
        return 0;
    }

    new Float:offsetX = (targetW - sourceW * scale) / 2.0;
    new Float:offsetY = (targetH - sourceH * scale) / 2.0;
    screenX = offsetX + x * scale;
    screenY = offsetY + y * scale;
    return 1;
}

/**
 * Non-uniform mapping: the 4:3 design is stretched to the target, which is what
 * the game itself does with TextDraw coordinates on a widescreen display. Use
 * this when the design must fill the screen; use TDM_DesignToScreen when it must
 * keep its proportions.
 */
stock TDM_DesignToScreenStretch(Float:x, Float:y, Float:sourceW, Float:sourceH,
    Float:targetW, Float:targetH, &Float:screenX, &Float:screenY,
    &Float:scaleX, &Float:scaleY)
{
    if (sourceW <= 0.0 || sourceH <= 0.0 || targetW <= 0.0 || targetH <= 0.0)
    {
        screenX = 0.0;
        screenY = 0.0;
        scaleX = 0.0;
        scaleY = 0.0;
        return 0;
    }

    scaleX = targetW / sourceW;
    scaleY = targetH / sourceH;
    screenX = x * scaleX;
    screenY = y * scaleY;
    return 1;
}

/** Converts on-screen pixels to the 480-unit TextDraw space for a given height. */
stock Float:TDM_PixelsToUnits(Float:pixels, Float:screenH)
{
    if (screenH <= 0.0) return 0.0;
    return pixels * (TDM_DESIGN_H / screenH);
}

stock TDM_GridCell(index, columns, Float:cellW, Float:cellH, Float:gapX, Float:gapY,
    Float:originX, Float:originY, &Float:x, &Float:y)
{
    if (index < 0 || columns <= 0)
    {
        x = originX;
        y = originY;
        return 0;
    }

    new column = index % columns;
    new row = index / columns;
    x = originX + (cellW + gapX) * column;
    y = originY + (cellH + gapY) * row;
    return 1;
}

/** Slide from an off-screen offset into place; progress 1.0 lands exactly. */
stock Float:TDM_SlideInX(Float:targetX, Float:offset, Float:progress)
{
    return targetX + offset * (1.0 - TDM_EaseOutCubic(progress));
}
