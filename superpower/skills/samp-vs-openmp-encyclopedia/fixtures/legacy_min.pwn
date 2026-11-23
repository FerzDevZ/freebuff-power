// Legacy 0.3.7 fixture: resolves <a_samp> against the old stdlib only.
#include <a_samp>

#define MAX_ROUTE 8

stock LegacyHealth(playerid)
{
    new Float:health;
    if (!GetPlayerHealth(playerid, health)) return -1;
    return floatround(health);
}

public OnGameModeInit()
{
    new route[MAX_ROUTE];
    route[0] = LegacyHealth(0);
    #pragma unused route
    return 1;
}
