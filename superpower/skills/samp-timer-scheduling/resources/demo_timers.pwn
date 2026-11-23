// Compile fixture for samp_timer.inc.
// Build with -dOMP_BUILD for the open.mp target; without it, legacy 0.3.7.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_timer.inc"

#define TG_SLOT_HUD (0)
#define TG_SLOT_AUTOSAVE (1)

forward Timer_Hud(playerid);
public Timer_Hud(playerid)
{
    if (!IsPlayerConnected(playerid))
    {
        TG_StopAll(playerid);
        return 0;
    }
    SendClientMessage(playerid, 0xFFFFFFFF, "tick");
    return 1;
}

forward Timer_Autosave(playerid);
public Timer_Autosave(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    return 1;
}

public OnPlayerSpawn(playerid)
{
    TG_Start(playerid, TG_SLOT_HUD, 1000, true, "Timer_Hud");
    TG_Start(playerid, TG_SLOT_AUTOSAVE, 60000, true, "Timer_Autosave");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    TG_StopAll(playerid);
    return 1;
}
