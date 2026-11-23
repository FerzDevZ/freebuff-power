// Runtime numeric suite for samp_td_math.inc — executed on a real open.mp server.
// @runtime-suite
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_td_math"

new gChecks;
new gFailures;

stock TestFloat(Float:expected, Float:actual, const label[])
{
    gChecks++;
    if (floatabs(expected - actual) <= 0.0005) return 1;

    gFailures++;
    printf("[TD] FAIL: %s (expected %.4f, got %.4f)", label, expected, actual);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;

    gFailures++;
    printf("[TD] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

stock TestBool(bool:condition, const label[])
{
    gChecks++;
    if (condition) return 1;

    gFailures++;
    printf("[TD] FAIL: %s", label);
    return 0;
}

stock TestClamp()
{
    TestFloat(0.0, TDM_Clamp(-5.0, 0.0, 10.0), "clamp below range");
    TestFloat(10.0, TDM_Clamp(15.0, 0.0, 10.0), "clamp above range");
    TestFloat(5.0, TDM_Clamp(5.0, 0.0, 10.0), "clamp inside range");
    TestFloat(1.0, TDM_Clamp01(2.5), "clamp01 upper");
    TestFloat(0.0, TDM_Clamp01(-0.1), "clamp01 lower");
}

stock TestInterpolation()
{
    TestFloat(12.5, TDM_Lerp(10.0, 20.0, 0.25), "lerp quarter");
    TestFloat(20.0, TDM_Lerp(10.0, 20.0, 1.0), "lerp end");
    TestFloat(10.0, TDM_Lerp(10.0, 20.0, 0.0), "lerp start");

    TestFloat(0.0, TDM_EaseOutCubic(0.0), "ease-out starts at 0");
    TestFloat(0.875, TDM_EaseOutCubic(0.5), "ease-out midpoint");
    TestFloat(1.0, TDM_EaseOutCubic(1.0), "ease-out ends at 1");
    TestFloat(1.0, TDM_EaseOutCubic(2.0), "ease-out clamps past 1");

    TestFloat(0.125, TDM_EaseInOutQuad(0.25), "ease-in-out first half");
    TestFloat(0.5, TDM_EaseInOutQuad(0.5), "ease-in-out midpoint");
    TestFloat(0.875, TDM_EaseInOutQuad(0.75), "ease-in-out second half");
}

stock TestProgress()
{
    TestFloat(84.0, TDM_ProgressFill(200.0, 0.42), "progress 42%");
    TestFloat(200.0, TDM_ProgressFill(200.0, 1.5), "progress over 100% clamps");
    TestFloat(0.0, TDM_ProgressFill(200.0, -0.25), "progress negative clamps");
    TestFloat(0.0, TDM_ProgressFill(0.0, 0.5), "progress with no track");
}

stock TestHitboxes()
{
    new Float:minX, Float:minY, Float:maxX, Float:maxY;

    TDM_HitboxSprite(100.0, 50.0, 40.0, 20.0, minX, minY, maxX, maxY);
    TestFloat(100.0, minX, "sprite hitbox left");
    TestFloat(140.0, maxX, "sprite hitbox right");
    TestFloat(70.0, maxY, "sprite hitbox bottom");

    TDM_HitboxAligned(320.0, 200.0, 100.0, 30.0, TDM_ALIGN_CENTER, minX, minY, maxX, maxY);
    TestFloat(270.0, minX, "centered hitbox left edge");
    TestFloat(370.0, maxX, "centered hitbox right edge");

    TDM_HitboxAligned(320.0, 200.0, 100.0, 30.0, TDM_ALIGN_RIGHT, minX, minY, maxX, maxY);
    TestFloat(220.0, minX, "right-aligned hitbox left edge");
    TestFloat(320.0, maxX, "right-aligned hitbox right edge");

    TestBool(TDM_HitTestAligned(320.0, 200.0, 100.0, 30.0, TDM_ALIGN_CENTER, 320.0, 215.0),
        "click on the centre hits");
    TestBool(!TDM_HitTestAligned(320.0, 200.0, 100.0, 30.0, TDM_ALIGN_CENTER, 269.0, 215.0),
        "click one unit left of the box misses");
    TestBool(TDM_HitTest(10.0, 10.0, 20.0, 20.0, 20.0, 20.0), "hit test includes the far edge");
}

stock TestAspectFit()
{
    new Float:screenX, Float:screenY, Float:scale;

    TestFloat(2.25, TDM_ContainScale(640.0, 480.0, 1920.0, 1080.0), "16:9 scale is 2.25");
    TestFloat(2.5, TDM_ContainScale(640.0, 480.0, 1920.0, 1200.0), "16:10 is height-limited");
    TestFloat(1.5, TDM_ContainScale(640.0, 480.0, 1280.0, 720.0), "720p does not stretch to 2x");
    TestFloat(0.0, TDM_ContainScale(0.0, 480.0, 1920.0, 1080.0), "degenerate source has no scale");

    TestInt(1, TDM_DesignToScreen(0.0, 0.0, 640.0, 480.0, 1920.0, 1080.0, screenX, screenY, scale),
        "contain-fit maps the design origin into 16:9");
    TestFloat(240.0, screenX, "4:3 into 16:9 needs a 240-unit pillarbox");
    TestFloat(0.0, screenY, "16:9 is height-limited, so no vertical offset");
    TestFloat(2.25, scale, "reported scale matches");

    TestInt(1, TDM_DesignToScreen(320.0, 240.0, 640.0, 480.0, 1920.0, 1200.0, screenX, screenY, scale),
        "contain-fit maps the centre into 16:10");
    TestFloat(960.0, screenX, "16:10 centre stays horizontally centred");
    TestFloat(600.0, screenY, "16:10 centre y is 600");

    new Float:scaleX, Float:scaleY;
    TestInt(1, TDM_DesignToScreenStretch(0.0, 0.0, 640.0, 480.0, 1920.0, 1080.0, screenX, screenY, scaleX, scaleY),
        "stretch maps the design origin");
    TestFloat(0.0, screenX, "stretch origin has no pillarbox");
    TestFloat(3.0, scaleX, "stretch scales x by 3");
    TestFloat(2.25, scaleY, "stretch scales y by 2.25");

    TestInt(1, TDM_DesignToScreenStretch(640.0, 480.0, 640.0, 480.0, 1920.0, 1080.0, screenX, screenY, scaleX, scaleY),
        "stretch maps the far corner");
    TestFloat(1920.0, screenX, "stretched design fills the width");
    TestFloat(1080.0, screenY, "stretched design fills the height");

    TestInt(0, TDM_DesignToScreenStretch(1.0, 1.0, 0.0, 480.0, 1920.0, 1080.0, screenX, screenY, scaleX, scaleY),
        "stretch rejects a degenerate source");

    TestInt(1, TDM_DesignToScreen(0.0, 0.0, 640.0, 480.0, 1920.0, 1200.0, screenX, screenY, scale),
        "design origin maps into 16:10");
    TestFloat(160.0, screenX, "16:10 pillarbox offset is 160");
    TestFloat(0.0, screenY, "16:10 has no vertical offset");

    TestInt(0, TDM_DesignToScreen(1.0, 1.0, 0.0, 0.0, 1920.0, 1080.0, screenX, screenY, scale),
        "contain-fit rejects an invalid design");
}

stock TestUnitsAndGrid()
{
    TestFloat(48.0, TDM_PixelsToUnits(108.0, 1080.0), "108 px at 1080p is 48 units");
    TestFloat(10.0, TDM_PixelsToUnits(10.0, 480.0), "480p pixels are 1:1");
    TestFloat(0.0, TDM_PixelsToUnits(10.0, 0.0), "zero screen height is rejected");

    new Float:x, Float:y;
    TestInt(1, TDM_GridCell(2, 3, 100.0, 60.0, 10.0, 10.0, 20.0, 30.0, x, y),
        "grid cell resolves");
    TestFloat(240.0, x, "third cell of the first row");
    TestFloat(30.0, y, "first row shares the origin y");

    TestInt(1, TDM_GridCell(4, 3, 100.0, 60.0, 10.0, 10.0, 20.0, 30.0, x, y),
        "grid wraps to the next row");
    TestFloat(130.0, x, "wrapped cell x");
    TestFloat(100.0, y, "wrapped cell y");

    TestInt(0, TDM_GridCell(-1, 3, 100.0, 60.0, 10.0, 10.0, 20.0, 30.0, x, y),
        "negative index is rejected");
    TestFloat(20.0, x, "rejected index keeps the origin");
}

stock TestSlide()
{
    TestFloat(420.0, TDM_SlideInX(300.0, 120.0, 0.0), "slide starts at the offset");
    TestFloat(315.0, TDM_SlideInX(300.0, 120.0, 0.5), "slide is eased, not linear");
    TestFloat(300.0, TDM_SlideInX(300.0, 120.0, 1.0), "slide lands exactly on target");
}

public OnGameModeInit()
{
    TestClamp();
    TestInterpolation();
    TestProgress();
    TestHitboxes();
    TestAspectFit();
    TestUnitsAndGrid();
    TestSlide();

    printf("[TD] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
