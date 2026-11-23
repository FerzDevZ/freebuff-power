// CLEAN: explicit id comparison and index bounds.
#include <open.mp>

new gActiveDialog[MAX_PLAYERS];

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext
    if (dialogid != gActiveDialog[playerid]) return 1;
    if (listitem < 0 || listitem >= 6) return 1;
    if (!response) return 1;

    gActiveDialog[playerid] = 0;
    return 1;
}
