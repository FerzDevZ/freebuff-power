// VULNERABLE: deprecated pool-size shim as a loop bound.
#include <open.mp>

public Broadcast(const message[])
{
    for (new i = 0; i < GetPlayerPoolSize(); i++)
    {
        if (IsPlayerConnected(i)) SendClientMessage(i, -1, message);
    }
    return 1;
}
