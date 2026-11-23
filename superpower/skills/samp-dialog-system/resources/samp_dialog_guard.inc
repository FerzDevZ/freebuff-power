/* Dialog state guard.
 *
 * The client can send OnDialogResponse for any dialog id at any time, in any
 * order, as often as it likes. This tracks what the server actually showed and
 * answers one question: may this response be handled?
 *
 * Time is passed in by the caller (`now`, GetTickCount semantics) so the logic
 * is deterministic and testable without a running server. Comparisons use
 * signed subtraction, so a 2^31 tick wrap does not turn a fresh dialog stale.
 */
#if defined _samp_dialog_guard_included
    #endinput
#endif
#define _samp_dialog_guard_included

#if !defined DG_MAX_PLAYERS
    #define DG_MAX_PLAYERS (MAX_PLAYERS)
#endif
#if !defined DG_DEFAULT_TIMEOUT
    #define DG_DEFAULT_TIMEOUT (60000)
#endif
#if !defined DG_REPLAY_WINDOW
    #define DG_REPLAY_WINDOW (5000)
#endif

#define DG_REASON_OK            (0)
#define DG_REASON_NO_DIALOG     (-1)
#define DG_REASON_WRONG_ID      (-2)
#define DG_REASON_EXPIRED       (-3)
#define DG_REASON_REPLAY        (-4)
#define DG_REASON_BAD_ITEM      (-5)

#define DG_BUTTON_CANCEL        (0)
#define DG_BUTTON_CONFIRM       (1)

static gDgActive[DG_MAX_PLAYERS];
static gDgItems[DG_MAX_PLAYERS];
static gDgDeadline[DG_MAX_PLAYERS];
static gDgLastAnswered[DG_MAX_PLAYERS];
static gDgAnsweredAt[DG_MAX_PLAYERS];

stock bool:DG_Open(playerid, dialogId, itemCount, now, timeout = DG_DEFAULT_TIMEOUT)
{
    if (playerid < 0 || playerid >= DG_MAX_PLAYERS) return false;
    if (dialogId <= 0 || itemCount < 0 || timeout <= 0) return false;
    if (gDgActive[playerid] != 0) return false;

    gDgActive[playerid] = dialogId;
    gDgItems[playerid] = itemCount;
    gDgDeadline[playerid] = now + timeout;
    return true;
}

stock bool:DG_IsOpen(playerid)
{
    if (playerid < 0 || playerid >= DG_MAX_PLAYERS) return false;
    return gDgActive[playerid] != 0;
}

stock DG_ActiveId(playerid)
{
    if (playerid < 0 || playerid >= DG_MAX_PLAYERS) return 0;
    return gDgActive[playerid];
}

stock DG_Close(playerid)
{
    if (playerid < 0 || playerid >= DG_MAX_PLAYERS) return 0;
    gDgActive[playerid] = 0;
    gDgItems[playerid] = 0;
    gDgDeadline[playerid] = 0;
    return 1;
}

/** Disconnect/reset: forget the open dialog and the replay memory. */
stock DG_Reset(playerid)
{
    if (playerid < 0 || playerid >= DG_MAX_PLAYERS) return 0;

    gDgActive[playerid] = 0;
    gDgItems[playerid] = 0;
    gDgDeadline[playerid] = 0;
    gDgLastAnswered[playerid] = 0;
    gDgAnsweredAt[playerid] = 0;
    return 1;
}

/** Order of the checks is part of the contract: identity before freshness, so a
 *  stale dialog never masks a spoofed id. */
stock bool:DG_CanRespond(playerid, dialogId, listitem, now, &reason)
{
    reason = DG_REASON_OK;

    if (playerid < 0 || playerid >= DG_MAX_PLAYERS)
    {
        reason = DG_REASON_NO_DIALOG;
        return false;
    }

    if (gDgActive[playerid] == 0)
    {
        if (dialogId != 0 && gDgLastAnswered[playerid] == dialogId
            && now - gDgAnsweredAt[playerid] < DG_REPLAY_WINDOW)
        {
            reason = DG_REASON_REPLAY;
            return false;
        }
        reason = DG_REASON_NO_DIALOG;
        return false;
    }

    if (dialogId != gDgActive[playerid])
    {
        reason = DG_REASON_WRONG_ID;
        return false;
    }

    if (now - gDgDeadline[playerid] > 0)
    {
        reason = DG_REASON_EXPIRED;
        return false;
    }

    /* itemCount 0 is a message box: only the two buttons are legal. */
    if (gDgItems[playerid] == 0)
    {
        if (listitem != DG_BUTTON_CANCEL && listitem != DG_BUTTON_CONFIRM)
        {
            reason = DG_REASON_BAD_ITEM;
            return false;
        }
        return true;
    }

    if (listitem < 0 || listitem >= gDgItems[playerid])
    {
        reason = DG_REASON_BAD_ITEM;
        return false;
    }
    return true;
}

/** Validates and closes in one step; a second call with the same id is a replay. */
stock bool:DG_Accept(playerid, dialogId, listitem, now, &reason)
{
    if (!DG_CanRespond(playerid, dialogId, listitem, now, reason)) return false;

    gDgLastAnswered[playerid] = dialogId;
    gDgAnsweredAt[playerid] = now;
    DG_Close(playerid);
    return true;
}

/** Rejects empty input, overlong input, and control bytes (newlines, tabs, NUL). */
stock bool:DG_IsCleanInput(const text[], maxLength)
{
    if (text[0] == '\0' || maxLength <= 0) return false;

    new length = 0;
    while (text[length] != '\0')
    {
        new byte = text[length];
        if (byte < 0x20 || byte == 0x7F) return false;
        length++;
        if (length > maxLength) return false;
    }
    return length > 0 && length <= maxLength;
}

/** Digits only, no sign, at most 9 digits. Returns false instead of wrapping. */
stock bool:DG_ParseAmount(const text[], &value)
{
    value = 0;
    if (text[0] == '\0') return false;

    for (new i = 0; text[i] != '\0'; i++)
    {
        new byte = text[i];
        if (byte < '0' || byte > '9') return false;
        if (i >= 9) return false;

        value = value * 10 + (byte - '0');
    }
    return true;
}
