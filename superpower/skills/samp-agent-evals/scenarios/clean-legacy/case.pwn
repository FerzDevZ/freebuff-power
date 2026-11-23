#include <a_samp>

stock LegacyHealth(playerid)
{
    new Float:health;
    if (!GetPlayerHealth(playerid, health)) return -1;
    return floatround(health);
}
