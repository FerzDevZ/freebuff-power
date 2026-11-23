/**
 * samp_cmd.inc — dependency-free command dispatcher for SA-MP 0.3.7 and open.mp.
 *
 * Why this exists: the usual `strcmp` ladder inside OnPlayerCommandText is O(n)
 * per keystroke and silently accepts any level, any rate. This dispatcher wires
 * command name -> public function through `funcidx`, so adding a command costs
 * one macro and zero edits to a central table.
 *
 *   #include "samp_cmd.inc"
 *
 *   COMMAND:heal(playerid, params[])
 *   {
 *       #pragma unused params
 *       SetPlayerHealth(playerid, 100.0);
 *       return 1;
 *   }
 *
 *   public OnGameModeInit()
 *   {
 *       CMD_Register("heal", 0, 500);   // name, required level, cooldown ms
 *       CMD_Register("setlevel", 3, 0);
 *       return 1;
 *   }
 *
 * If the gamemode already owns OnPlayerCommandText, define CMD_NO_AUTO_HOOK
 * before including this file and forward manually:
 *   return CMD_OnCommand(playerid, cmdtext) ? 1 : 0;
 */

#if defined _samp_cmd_included
    #endinput
#endif
#define _samp_cmd_included

#if !defined CMD_MAX_REGISTERED
    #define CMD_MAX_REGISTERED (96)
#endif
#if !defined CMD_NAME_LEN
    #define CMD_NAME_LEN (32)
#endif
#if !defined CMD_PARAM_LEN
    #define CMD_PARAM_LEN (128)
#endif
#if !defined CMD_DEFAULT_COOLDOWN
    #define CMD_DEFAULT_COOLDOWN (250)
#endif

static gCmdName[CMD_MAX_REGISTERED][CMD_NAME_LEN];
static gCmdLevelRequired[CMD_MAX_REGISTERED];
static gCmdCooldown[CMD_MAX_REGISTERED];
static gCmdRegistered;

static gCmdPlayerLevel[MAX_PLAYERS];
static gCmdBlocked[MAX_PLAYERS];
static gCmdLastTick[MAX_PLAYERS];
static gCmdLastIndex[MAX_PLAYERS];

/** Lowercase `name`, keep [a-z0-9_], stop at the first other byte. Returns the
 *  number of characters consumed so the caller can find the parameter block. */
static CMD_Sanitize(const src[], dest[], size)
{
    new copied;
    for (new i = 0; src[i] != '\0' && copied < size - 1; i++)
    {
        new c = src[i];
        if (c >= 'A' && c <= 'Z') c += 32;
        if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_')
        {
            dest[copied++] = c;
        }
        else
        {
            break;
        }
    }
    dest[copied] = '\0';
    return copied;
}

static CMD_Find(const name[])
{
    for (new i = 0; i < gCmdRegistered; i++)
    {
        if (!strcmp(gCmdName[i], name, true)) return i;
    }
    return -1;
}

/** Optional metadata. Dispatch works without registration; registering is how
 *  you attach a level and a cooldown. Re-registering updates the entry. */
stock CMD_Register(const name[], level = 0, cooldown = CMD_DEFAULT_COOLDOWN)
{
    new clean[CMD_NAME_LEN];
    if (CMD_Sanitize(name, clean, sizeof clean) == 0) return -1;

    new index = CMD_Find(clean);
    if (index == -1)
    {
        if (gCmdRegistered >= CMD_MAX_REGISTERED) return -1;
        index = gCmdRegistered++;
        strcat(gCmdName[index], clean, CMD_NAME_LEN);
    }
    gCmdLevelRequired[index] = level;
    gCmdCooldown[index] = cooldown;
    return index;
}

stock CMD_SetCooldown(const name[], cooldown)
{
    new clean[CMD_NAME_LEN];
    if (CMD_Sanitize(name, clean, sizeof clean) == 0) return 0;
    new index = CMD_Find(clean);
    if (index == -1) return 0;
    gCmdCooldown[index] = cooldown;
    return 1;
}

stock CMD_Count()
{
    return gCmdRegistered;
}

stock CMD_SetPlayerLevel(playerid, level)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCmdPlayerLevel[playerid] = level;
    return 1;
}

stock CMD_GetPlayerLevel(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    return gCmdPlayerLevel[playerid];
}

stock CMD_Block(playerid, bool:blocked)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCmdBlocked[playerid] = blocked;
    return 1;
}

/** Call from OnPlayerDisconnect and OnPlayerConnect: a recycled slot must not
 *  inherit the previous player's level, block flag or cooldown clock. */
stock CMD_ResetPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCmdPlayerLevel[playerid] = 0;
    gCmdBlocked[playerid] = false;
    gCmdLastTick[playerid] = 0;
    gCmdLastIndex[playerid] = -1;
    return 1;
}

stock bool:CMD_OnCommand(playerid, const cmdtext[])
{
    if (cmdtext[0] != '/') return false;
    if (playerid < 0 || playerid >= MAX_PLAYERS) return false;
    if (!IsPlayerConnected(playerid)) return false;

    new name[CMD_NAME_LEN];
    new consumed = CMD_Sanitize(cmdtext[1], name, sizeof name);
    if (consumed == 0) return false;

    new function[CMD_NAME_LEN + 4];
    format(function, sizeof function, "cmd_%s", name);
    if (funcidx(function) == -1) return false;

    if (gCmdBlocked[playerid])
    {
        SendClientMessage(playerid, 0xFF4444FF, "[CMD] Perintah diblokir sementara.");
        return true;
    }

    new index = CMD_Find(name);
    if (index != -1 && gCmdPlayerLevel[playerid] < gCmdLevelRequired[index])
    {
        SendClientMessage(playerid, 0xFF4444FF, "[CMD] Level anda tidak mencukupi.");
        return true;
    }

    new tick = GetTickCount();
    if (index != -1 && gCmdLastIndex[playerid] == index)
    {
        if (tick - gCmdLastTick[playerid] < gCmdCooldown[index]) return true;
    }
    gCmdLastIndex[playerid] = index;
    gCmdLastTick[playerid] = tick;

    new params[CMD_PARAM_LEN];
    new start = 1 + consumed;
    while (cmdtext[start] == ' ') start++;
    strmid(params, cmdtext, start, strlen(cmdtext), sizeof params);

    CallLocalFunction(function, "is", playerid, params);
    return true;
}

#if !defined CMD_NO_AUTO_HOOK
public OnPlayerCommandText(playerid, cmdtext[])
{
    return CMD_OnCommand(playerid, cmdtext) ? 1 : 0;
}
#endif

#define COMMAND:%0(%1) forward cmd_%0(%1); public cmd_%0(%1)
