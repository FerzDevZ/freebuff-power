// CLEAN: "%s" format, validated dialog id and bounded list index.
#include <open.mp>
#include "samp_dialog_guard.inc"

public OnPlayerText(playerid, text[])
{
    new buffer[144];
    format(buffer, sizeof buffer, "%s", text);
    SendClientMessage(playerid, -1, buffer);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new reason;
    if (!DG_CanRespond(playerid, dialogid, listitem, GetTickCount(), reason)) return 1;
    if (listitem < 0 || listitem > 4) return 1;
    if (!response) return 1;

    new message[128];
    format(message, sizeof message, "picked %d", listitem);
    SendClientMessage(playerid, -1, message);
    return 1;
}
