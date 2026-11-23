/**
 * samp_test.inc — tiny assertion harness for Pawn (SA-MP 0.3.7 / open.mp).
 *
 * A gamemode cannot use a framework runner, so the cheapest reliable pattern is:
 * run assertions from a test entry script, print results to the server log, and
 * write a one-line report file that CI can read without parsing log noise.
 *
 *   ST_Reset();
 *   ST_CheckInt(100, ClampHealth(150), "health clamps above cap");
 *   ST_Check(strcmp(GetName(), "Buffy", true) == 0, "name match");
 *   new failed = ST_Summary("damage");
 *   ST_WriteReport("scriptfiles/test-damage.report", "damage");
 *
 * Exit code: the server exits 0 whatever the assertions do, so CI must fail on
 * the report file content, not on the process status.
 */

#if defined _samp_test_included
    #endinput
#endif
#define _samp_test_included

#if !defined ST_MAX_FAILURES
    #define ST_MAX_FAILURES (24)
#endif
#if !defined ST_LABEL_LEN
    #define ST_LABEL_LEN (72)
#endif

static gSTChecks;
static gSTFailures;
static gSTLabels[ST_MAX_FAILURES][ST_LABEL_LEN];

stock ST_Reset()
{
    gSTChecks = 0;
    gSTFailures = 0;
    for (new i = 0; i < ST_MAX_FAILURES; i++) gSTLabels[i][0] = '\0';
    return 1;
}

stock ST_Check(bool:condition, const label[])
{
    gSTChecks++;
    if (condition) return 1;

    gSTFailures++;
    if (gSTFailures <= ST_MAX_FAILURES)
    {
        strcat(gSTLabels[gSTFailures - 1], label, ST_LABEL_LEN);
    }
    printf("[TEST] FAIL: %s", label);
    return 0;
}

stock ST_CheckInt(expected, actual, const label[])
{
    new composed[ST_LABEL_LEN + 40];
    format(composed, sizeof composed, "%s (expected %d, got %d)", label, expected, actual);
    return ST_Check(expected == actual, composed);
}

stock ST_CheckFloat(Float:expected, Float:actual, const label[])
{
    new composed[ST_LABEL_LEN + 40];
    format(composed, sizeof composed, "%s (expected %.3f, got %.3f)", label, expected, actual);
    return ST_Check(floatcmp(expected, actual) == 0, composed);
}

stock ST_Count()
{
    return gSTChecks;
}

stock ST_Failures()
{
    return gSTFailures;
}

/** Prints a summary line and returns the failure count (0 == suite passed). */
stock ST_Summary(const suite[])
{
    printf("[TEST] %s: %d checks, %d failed", suite, gSTChecks, gSTFailures);
    for (new i = 0; i < gSTFailures && i < ST_MAX_FAILURES; i++)
    {
        printf("[TEST]   - %s", gSTLabels[i]);
    }
    return gSTFailures;
}

/** Writes `PASS|FAIL <suite> checks=N failures=N` plus one line per failure. */
stock ST_WriteReport(const path[], const suite[])
{
    new File: report = fopen(path, io_write);
    if (!report) return 0;

    fwrite(report, (gSTFailures == 0) ? "PASS " : "FAIL ");
    fwrite(report, suite);

    new line[64];
    format(line, sizeof line, " checks=%d failures=%d\n", gSTChecks, gSTFailures);
    fwrite(report, line);

    for (new i = 0; i < gSTFailures && i < ST_MAX_FAILURES; i++)
    {
        fwrite(report, " - ");
        fwrite(report, gSTLabels[i]);
        fwrite(report, "\n");
    }

    fclose(report);
    return 1;
}
