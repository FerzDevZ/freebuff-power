// Compile fixture for samp_cmd.inc — must build with 0 warnings on both
// omp-stdlib and pawn-lang/samp-stdlib.
// Build with -dOMP_BUILD for the open.mp target; without it, legacy 0.3.7.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_cmd.inc"

COMMAND:heal(playerid, params[])
{
    if (!IsPlayerConnected(playerid)) return 0;
    new amount = params[0] ? strval(params) : 100;
    SetPlayerHealth(playerid, float(amount > 100 ? 100 : amount));
    SendClientMessage(playerid, 0x33AA33FF, "Healed.");
    return 1;
}

COMMAND:setlevel(playerid, params[])
{
    new level = strval(params);
    CMD_SetPlayerLevel(playerid, level);
    return 1;
}

COMMAND:admin(playerid, params[])
{
    #pragma unused params
    if (CMD_GetPlayerLevel(playerid) < 1) return 1;
    SendClientMessage(playerid, 0xFFFFFFFF, "Admin menu.");
    return 1;
}

public OnGameModeInit()
{
    CMD_Register("heal", 0, 500);
    CMD_Register("setlevel", 3, 0);
    CMD_Register("admin", 1, 1500);
    return 1;
}

public OnPlayerConnect(playerid)
{
    CMD_ResetPlayer(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    CMD_ResetPlayer(playerid);
    return 1;
}
