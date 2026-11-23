// Live HTTP + JSON fixture for open.mp's native HTTP().
// @runtime-suite
// @runtime-needs: http
//
// bin/self-test.sh serves http_fixture.json from a local python3 server and
// writes the chosen port into scriptfiles/http_port.txt. Legacy 0.3.7 has no
// HTTP native, so that target compiles a stub and is never executed.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include <samp_json>

#if defined OMP_BUILD

new gChecks;
new gFailures;
new gAnswered;
new gTimer;

stock Test(condition, const label[])
{
    gChecks++;
    if (condition) return 1;
    gFailures++;
    printf("[HTTP] FAIL: %s", label);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;
    gFailures++;
    printf("[HTTP] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

forward OnHttpFixtureResponse(index, responseCode, const data[]);
forward OnHttpFixtureTimeout();

stock ReadHttpPort()
{
    /* File natives resolve paths inside scriptfiles/, not the server root. */
    new File:handle = fopen("http_port.txt", io_read);
    if (!handle) return 0;

    new text[16];
    text[0] = '\0';
    fread(handle, text);
    fclose(handle);
    return strval(text);
}

public OnGameModeInit()
{
    new port = ReadHttpPort();
    if (port <= 0)
    {
        Test(0, "port file scriptfiles/http_port.txt missing or unreadable");
        printf("[HTTP] %d checks, %d failed", gChecks, gFailures);
        return 1;
    }

    new url[96];
    format(url, sizeof url, "127.0.0.1:%d/http-fixture.json", port);

    if (!HTTP(0, HTTP_GET, url, "", "OnHttpFixtureResponse"))
    {
        Test(0, "HTTP() refused to start the request");
        printf("[HTTP] %d checks, %d failed", gChecks, gFailures);
        return 1;
    }

    gTimer = SetTimer("OnHttpFixtureTimeout", 4000, false);
    return 1;
}

public OnHttpFixtureResponse(index, responseCode, const data[])
{
    if (gAnswered) return 1;
    gAnswered = 1;
    if (gTimer) { KillTimer(gTimer); gTimer = 0; }

    TestInt(0, index, "callback echoes the request index");
    TestInt(200, responseCode, "response code is 200");

    /* The body must be a complete document before anything is read from it. */
    Test(JSN_DocumentComplete(data), "body is one complete JSON document");

    new value;
    TestInt(1, JSN_GetInt(data, "value", value), "read int over the wire");
    TestInt(7, value, "int value matches the served fixture");

    new flag = -1;
    TestInt(1, JSN_GetBool(data, "ok", flag), "read bool over the wire");
    TestInt(1, flag, "bool value matches the served fixture");

    new name[32];
    TestInt(1, JSN_GetString(data, "user.name", name, sizeof name), "read nested string");
    Test(strcmp(name, "Local Fixture", false) == 0, "nested string matches");

    TestInt(2, JSN_CountArray(data, "user.tags"), "count array over the wire");
    TestInt(1, JSN_GetString(data, "user.tags.1", name, sizeof name), "read array element");
    Test(strcmp(name, "b", false) == 0, "array element matches");

    /* Escapes survive the transport: the server sends "\n", we get one byte. */
    TestInt(1, JSN_GetString(data, "note", name, sizeof name), "read escaped string");
    TestInt(11, strlen(name), "newline escape is one byte after transport");

    /* Fail-closed behaviour on a real body, not a synthetic string. */
    TestInt(0, JSN_GetInt(data, "user.name", value), "string is not accepted as int");
    TestInt(0, JSN_GetInt(data, "missing", value), "missing field fails closed");

    new bad[64];
    new reason;
    TestInt(1, JSN_Validate(data, "ok:bool|value:int[0..10]|user.name:string|user.tags:array<string>",
        bad, sizeof bad, reason), "served body passes schema rules");

    printf("[HTTP] %d checks, %d failed", gChecks, gFailures);
    return 1;
}

public OnHttpFixtureTimeout()
{
    if (gAnswered) return 1;
    gAnswered = 1;
    gTimer = 0;

    Test(0, "response did not arrive within 4s");
    printf("[HTTP] %d checks, %d failed", gChecks, gFailures);
    return 1;
}

#else

public OnGameModeInit()
{
    printf("[HTTP] legacy target: native HTTP() is unavailable, compile-only");
    return 1;
}

#endif
