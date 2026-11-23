// Adversarial command corpus — executed on a real open.mp server.
// Dispatch's happy path needs a connected client, so this suite covers what can
// be exercised headlessly: sanitisation, rejection paths, registry limits,
// metadata, and parameter delivery into a real callback.
// @runtime-suite
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_cmd.inc"

new gChecks;
new gFailures;
new gEcho[128];

COMMAND:echo(playerid, params[])
{
    #pragma unused playerid
    format(gEcho, sizeof gEcho, "%s", params);
    return 1;
}

stock Test(bool:condition, const label[])
{
    gChecks++;
    if (condition) return 1;

    gFailures++;
    printf("[CMD] FAIL: %s", label);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;

    gFailures++;
    printf("[CMD] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

/* Sanitisation is a private static, so it is exercised through the public
 * registry: two spellings that normalise to the same name must share a slot. */
stock TestSanitize()
{
    new heal = CMD_Register("Heal");
    Test(heal >= 0, "uppercase command registers");
    TestInt(heal, CMD_Register("heal"), "lowercase spelling maps to the same slot");
    TestInt(heal, CMD_Register("heal!"), "punctuation is stripped before comparison");
    TestInt(heal, CMD_Register("heal%n"), "format specifier stops the name");
    TestInt(-1, CMD_Register("!!!"), "punctuation-only name is refused");
    TestInt(-1, CMD_Register(""), "empty name is refused");

    new longName[64];
    for (new i = 0; i < 40; i++) longName[i] = 'a';
    longName[40] = '\0';
    new truncated = CMD_Register(longName);
    Test(truncated >= 0, "overlong command name registers");

    new prefix[CMD_NAME_LEN];
    for (new i = 0; i < CMD_NAME_LEN - 1; i++) prefix[i] = 'a';
    prefix[CMD_NAME_LEN - 1] = '\0';
    TestInt(truncated, CMD_Register(prefix), "name is truncated to CMD_NAME_LEN - 1");
}

stock TestRegistry()
{
    new heal = CMD_Register("heal");
    Test(heal >= 0, "command registration succeeds");
    Test(CMD_Count() >= 1, "registry reports at least one command");

    new before = CMD_Count();
    TestInt(heal, CMD_Register("HEAL"), "re-registering returns the same slot");
    TestInt(before, CMD_Count(), "re-registering does not grow the registry");

    TestInt(0, CMD_SetCooldown("nosuchcommand", 100), "cooldown for unknown command fails");
    TestInt(1, CMD_SetCooldown("heal", 50), "cooldown for a known command is set");
}

stock TestMetadata()
{
    TestInt(0, CMD_SetPlayerLevel(-1, 3), "level for a negative player fails");
    TestInt(1, CMD_SetPlayerLevel(0, 5), "level is set");
    TestInt(5, CMD_GetPlayerLevel(0), "level reads back");
    TestInt(0, CMD_GetPlayerLevel(MAX_PLAYERS), "level past the array is 0");

    TestInt(1, CMD_ResetPlayer(0), "player reset succeeds");
    TestInt(0, CMD_GetPlayerLevel(0), "reset clears the level");

    TestInt(0, CMD_Block(-1, true), "blocking a negative player fails");
    TestInt(1, CMD_Block(0, true), "player can be blocked");
    TestInt(1, CMD_Block(0, false), "player can be unblocked");
    TestInt(0, CMD_ResetPlayer(-1), "reset for a negative player fails");
}

stock TestDispatchRejections()
{
    Test(!CMD_OnCommand(0, "heal"), "command without slash is rejected");
    Test(!CMD_OnCommand(0, "/"), "bare slash is rejected");
    Test(!CMD_OnCommand(0, "/!!!"), "punctuation-only command is rejected");
    Test(!CMD_OnCommand(0, "/nosuchcommand"), "unknown command is rejected");
    Test(!CMD_OnCommand(-1, "/echo hi"), "negative player is rejected");
    Test(!CMD_OnCommand(MAX_PLAYERS, "/echo hi"), "player past the array is rejected");
    Test(!CMD_OnCommand(0, "/echo hi"), "disconnected player is rejected");

    new longText[128];
    new longName[100];
    for (new i = 0; i < 99; i++) longName[i] = 'z';
    longName[99] = '\0';
    format(longText, sizeof longText, "/%s", longName);
    Test(!CMD_OnCommand(0, longText), "100-character command name is rejected");
}

stock TestParameterDelivery()
{
    new params[] = "a b";
    cmd_echo(0, params);
    Test(strcmp(gEcho, "a b", false) == 0, "parameters reach the callback intact");

    new injection[] = "100%s %n {FFFFFF}";
    cmd_echo(0, injection);
    Test(strcmp(gEcho, injection, false) == 0, "format specifiers are not interpreted");

    new longParams[200];
    for (new i = 0; i < 199; i++) longParams[i] = 'a';
    longParams[199] = '\0';
    cmd_echo(0, longParams);
    TestInt(sizeof gEcho - 1, strlen(gEcho), "oversized parameters truncate to the buffer");
    Test(gEcho[sizeof gEcho - 1] == '\0', "truncated parameters stay terminated");
}

stock TestRegistryLimit()
{
    new name[CMD_NAME_LEN];
    new registered = 0;

    for (new i = 0; i < CMD_MAX_REGISTERED + 8; i++)
    {
        format(name, sizeof name, "c_%d", i);
        if (CMD_Register(name) >= 0) registered++;
    }

    TestInt(CMD_MAX_REGISTERED, CMD_Count(), "registry stops at its fixed capacity");
    TestInt(-1, CMD_Register("overflow_last"), "registration past capacity is refused");
    Test(registered > 0, "bulk registration registered at least one command");
}

public OnGameModeInit()
{
    TestSanitize();
    TestRegistry();
    TestMetadata();
    TestDispatchRejections();
    TestParameterDelivery();
    TestRegistryLimit();

    printf("[CMD] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
