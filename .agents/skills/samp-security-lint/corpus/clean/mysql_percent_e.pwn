// CLEAN: %e escapes the string value.
#include <open.mp>

public LoadAccount(playerid, const name[])
{
    new query[256];
    mysql_format(gHandle, query, sizeof query, "SELECT * FROM accounts WHERE name = '%e'", name);
    mysql_tquery(gHandle, query);
    return 1;
}
