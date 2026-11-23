#include <open.mp>

public OnPlayerText(playerid, text[])
{
    new buffer[144];
    format(buffer, sizeof buffer, "%s", text);
    SendClientMessage(playerid, -1, buffer);
    return 1;
}

public Broadcast(const message[])
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i)) SendClientMessage(i, -1, message);
    }
    return 1;
}
