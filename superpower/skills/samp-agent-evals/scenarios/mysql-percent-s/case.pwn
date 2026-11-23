#include <open.mp>

public LoadAccount(const name[])
{
    new query[200];
    mysql_format(gHandle, query, sizeof query, "SELECT * FROM accounts WHERE name = '%s'", name);
    mysql_tquery(gHandle, query);
    return 1;
}
