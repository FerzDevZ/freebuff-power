// VULNERABLE: dialogid is accepted from the client without validation.
#include <open.mp>

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused dialogid
    if (!response) return 1;

    new message[128];
    format(message, sizeof message, "picked %d", listitem);
    SendClientMessage(playerid, -1, message);
    return 1;
}
