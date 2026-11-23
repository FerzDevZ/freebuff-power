// Compile + assertion fixture for samp_test.inc.
// @runtime-suite
// Body is shared by both targets: demo_tests_omp.pwn defines OMP_BUILD first.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_test.inc"

// Pure functions are the part of a gamemode that can be asserted without a
// client attached. Keep damage/economy/parsing math pure for exactly this.
static ClampHealth(value)
{
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
}

static ParseAmount(const text[], fallback)
{
    if (text[0] == '\0') return fallback;
    new value = strval(text);
    return value <= 0 ? fallback : value;
}

public OnGameModeInit()
{
    ST_Reset();

    ST_CheckInt(100, ClampHealth(150), "health clamps above 100");
    ST_CheckInt(0, ClampHealth(-25), "health clamps below 0");
    ST_CheckInt(55, ClampHealth(55), "health keeps in-range value");
    ST_CheckInt(10, ParseAmount("", 10), "empty amount falls back");
    ST_CheckInt(250, ParseAmount("250", 10), "valid amount parses");

    new failed = ST_Summary("core-math");
    ST_WriteReport("scriptfiles/test-core-math.report", "core-math");
    printf("[TEST] suite finished, failures=%d", failed);
    return 1;
}
