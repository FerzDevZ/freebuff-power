// VULNERABLE: %s interpolates an unescaped name into SQL.
#include <open.mp>

public LoadAccount(playerid, const name[])
{
    new query[256];
    mysql_format(gHandle, query, sizeof query, "SELECT * FROM accounts WHERE name = '%s'", name);
    mysql_tquery(gHandle, query);
    return 1;
}
