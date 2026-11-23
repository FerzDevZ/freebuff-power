// CLEAN: bounded loop with a connectivity check.
#include <open.mp>

public Broadcast(const message[])
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i)) SendClientMessage(i, -1, message);
    }
    return 1;
}
