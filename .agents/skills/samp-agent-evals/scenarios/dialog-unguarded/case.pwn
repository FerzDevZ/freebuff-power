#include <open.mp>

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused dialogid, inputtext
    if (!response) return 1;
    new message[96];
    format(message, sizeof message, "picked %d", listitem);
    SendClientMessage(playerid, -1, message);
    return 1;
}
