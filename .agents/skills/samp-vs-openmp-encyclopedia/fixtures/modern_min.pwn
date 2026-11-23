// Modern open.mp fixture: unified header, bool: returns, open.mp-only natives.
#include <open.mp>

public OnGameModeInit()
{
    new bool:connected = IsPlayerConnected(0);
    new vehicleid = GetPlayerVehicleID(0);
    new driver = GetVehicleDriver(vehicleid);

    #pragma unused connected, driver
    return 1;
}
