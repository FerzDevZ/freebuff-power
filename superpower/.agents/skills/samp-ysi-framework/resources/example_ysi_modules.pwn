/* YSI 5 module probe — official example for samp-ysi-framework.
 *
 * Proves that the patched YSI tree (.sdk/ysi) makes every headline module
 * buildable on Linux, on BOTH open.mp and legacy 0.3.7, with 0 warnings.
 * Used by bin/self-test.sh as a dual-target gate.
 */

#include <open.mp>
#include <YSI_Data/y_iterate>
#include <YSI_Coding/y_hooks>
#include <YSI_Coding/y_timers>
#include <YSI_Players/y_groups>
#include <YSI_Visual/y_commands>

new Iterator:ProbePlayers<MAX_PLAYERS>;

hook OnGameModeInit()
{
    Iter_Add(ProbePlayers, 0);
    foreach (new playerid : ProbePlayers) printf("probe player %d", playerid);
    new Group:g = Group_Create("probe");
    #pragma unused g
    defer ProbeTick(0);
    return 1;
}

timer ProbeTick[1000](playerid)
{
    #pragma unused playerid
    printf("probe tick");
}

YCMD:probe(playerid, params[], help)
{
    #pragma unused params, help
    printf("probe cmd %d", playerid);
    return 1;
}

public OnGameModeInit() { return 1; }

public OnPlayerConnect(playerid)
{
    Iter_Add(ProbePlayers, playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    Iter_Remove(ProbePlayers, playerid);
    return 1;
}
