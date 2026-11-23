/**
 * samp_timer.inc — per-player timer bookkeeping for SA-MP 0.3.7 / open.mp.
 *
 * The three timer bugs that actually crash or leak servers:
 *   1. a player-bound timer that keeps running after disconnect -> writes to a
 *      recycled player id;
 *   2. the same slot started twice -> first id is lost, cannot be killed;
 *   3. a repeating timer that restarts itself later in the callback.
 *
 * This include owns one fixed slot table per player so all three are checkable.
 * It only tracks timers that receive the player id as their single argument
 * (SetTimerEx(..., "i", playerid)); timers with extra arguments stay manual.
 *
 *   new timer = TG_Start(playerid, TG_SLOT_HUD, 1000, true, "Timer_Hud");
 *   TG_Stop(playerid, TG_SLOT_HUD);
 *   // OnPlayerDisconnect:
 *   TG_StopAll(playerid);
 */

#if defined _samp_timer_included
    #endinput
#endif
#define _samp_timer_included

#if !defined TG_SLOTS
    #define TG_SLOTS (8)
#endif

static gTgTimer[MAX_PLAYERS][TG_SLOTS];
static gTgStarted[MAX_PLAYERS];

stock bool:TG_Track(playerid, slot, timerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return false;
    if (slot < 0 || slot >= TG_SLOTS) return false;
    if (timerid == 0) return false;

    if (gTgTimer[playerid][slot] != 0)
    {
        KillTimer(gTgTimer[playerid][slot]);
    }
    gTgTimer[playerid][slot] = timerid;
    gTgStarted[playerid]++;
    return true;
}

/** Starts a player-bound timer in `slot`, replacing whatever ran there. */
stock TG_Start(playerid, slot, interval, bool:repeat, const callback[])
{
    if (interval <= 0) return 0;
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if (slot < 0 || slot >= TG_SLOTS) return 0;

    new timerid = SetTimerEx(callback, interval, repeat, "i", playerid);
    if (timerid == 0) return 0;
    if (!TG_Track(playerid, slot, timerid)) return 0;
    return timerid;
}

stock bool:TG_Active(playerid, slot)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return false;
    if (slot < 0 || slot >= TG_SLOTS) return false;
    return gTgTimer[playerid][slot] != 0;
}

stock bool:TG_Stop(playerid, slot)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return false;
    if (slot < 0 || slot >= TG_SLOTS) return false;
    if (gTgTimer[playerid][slot] == 0) return false;

    KillTimer(gTgTimer[playerid][slot]);
    gTgTimer[playerid][slot] = 0;
    return true;
}

stock TG_StopAll(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    new stopped;
    for (new slot = 0; slot < TG_SLOTS; slot++)
    {
        if (gTgTimer[playerid][slot] != 0)
        {
            KillTimer(gTgTimer[playerid][slot]);
            gTgTimer[playerid][slot] = 0;
            stopped++;
        }
    }
    gTgStarted[playerid] = 0;
    return stopped;
}

stock TG_Count(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    new running;
    for (new slot = 0; slot < TG_SLOTS; slot++)
    {
        if (gTgTimer[playerid][slot] != 0) running++;
    }
    return running;
}

stock TG_TotalStarted(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    return gTgStarted[playerid];
}
