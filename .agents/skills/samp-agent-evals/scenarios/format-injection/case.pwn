#include <open.mp>

public OnPlayerText(playerid, text[])
{
    new buffer[144];
    format(buffer, sizeof buffer, text);
    SendClientMessage(playerid, -1, buffer);
    return 1;
}
