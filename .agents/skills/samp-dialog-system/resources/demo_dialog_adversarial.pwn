// Adversarial dialog corpus — executed on a real open.mp server.
// @runtime-suite
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_dialog_guard"

new gChecks;
new gFailures;

stock Test(bool:condition, const label[])
{
    gChecks++;
    if (condition) return 1;

    gFailures++;
    printf("[DLG] FAIL: %s", label);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;

    gFailures++;
    printf("[DLG] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

stock TestSpoof()
{
    new reason;

    Test(DG_Open(0, 100, 5, 1000, 1000), "open dialog 100");
    Test(DG_IsOpen(0), "dialog is tracked as open");
    TestInt(100, DG_ActiveId(0), "active id is 100");

    Test(!DG_Open(0, 101, 5, 1000), "second dialog cannot open over the first");

    Test(!DG_CanRespond(0, 101, 0, 1000, reason), "response for another id is rejected");
    TestInt(DG_REASON_WRONG_ID, reason, "spoofed id reports WRONG_ID");

    Test(DG_CanRespond(0, 100, 3, 1000, reason), "valid item is accepted");
    TestInt(DG_REASON_OK, reason, "valid item reports OK");

    Test(!DG_CanRespond(0, 100, 5, 1000, reason), "list item past the end is rejected");
    TestInt(DG_REASON_BAD_ITEM, reason, "out-of-range item reports BAD_ITEM");

    Test(!DG_CanRespond(0, 100, -1, 1000, reason), "negative item is rejected");
    TestInt(DG_REASON_BAD_ITEM, reason, "negative item reports BAD_ITEM");
}

stock TestFreshness()
{
    new reason;

    DG_Reset(1);
    Test(DG_Open(1, 300, 2, 5000, 1000), "open with a one second budget");
    Test(DG_CanRespond(1, 300, 1, 6000, reason), "deadline itself is still valid");
    Test(!DG_CanRespond(1, 300, 1, 6001, reason), "one tick past the deadline expires");
    TestInt(DG_REASON_EXPIRED, reason, "late response reports EXPIRED");
}

stock TestReplay()
{
    new reason;

    DG_Reset(2);
    Test(DG_Open(2, 400, 4, 1000), "open dialog for replay test");
    Test(DG_Accept(2, 400, 2, 1500, reason), "first response is accepted");
    Test(!DG_IsOpen(2), "accepted dialog is closed");

    Test(!DG_CanRespond(2, 400, 2, 1600, reason), "replayed response is rejected");
    TestInt(DG_REASON_REPLAY, reason, "quick replay reports REPLAY");

    Test(!DG_CanRespond(2, 400, 2, 7000, reason), "late replay falls out of the window");
    TestInt(DG_REASON_NO_DIALOG, reason, "stale replay reports NO_DIALOG");

    Test(!DG_CanRespond(2, 999, 0, 1600, reason), "unknown id after closing is not a replay");
    TestInt(DG_REASON_NO_DIALOG, reason, "unknown id reports NO_DIALOG");
}

stock TestMessageBox()
{
    new reason;

    DG_Reset(3);
    Test(DG_Open(3, 500, 0, 1000), "message box opens with itemCount 0");
    Test(DG_CanRespond(3, 500, DG_BUTTON_CONFIRM, 1000, reason), "confirm button is legal");
    Test(DG_CanRespond(3, 500, DG_BUTTON_CANCEL, 1000, reason), "cancel button is legal");
    Test(!DG_CanRespond(3, 500, 2, 1000, reason), "third button does not exist");
    TestInt(DG_REASON_BAD_ITEM, reason, "invalid button reports BAD_ITEM");
}

stock TestResetAndArguments()
{
    new reason;

    DG_Reset(4);
    DG_Open(4, 600, 3, 1000);
    Test(DG_Reset(4) != 0, "reset clears the player");
    Test(!DG_IsOpen(4), "reset closes the dialog");
    Test(!DG_CanRespond(4, 600, 0, 1000, reason), "response after reset is rejected");
    TestInt(DG_REASON_NO_DIALOG, reason, "reset response reports NO_DIALOG");

    Test(!DG_Open(5, 0, 3, 1000), "dialog id 0 cannot be opened");
    Test(!DG_Open(5, 10, -1, 1000), "negative item count is refused");
    Test(!DG_Open(5, 10, 3, 1000, 0), "zero timeout is refused");
    Test(!DG_Open(-1, 10, 3, 1000), "negative player id is refused");
    Test(!DG_Open(DG_MAX_PLAYERS, 10, 3, 1000), "player id past the array is refused");
    Test(!DG_CanRespond(-1, 10, 0, 1000, reason), "negative player id cannot respond");
}

stock TestInputValidation()
{
    new value;

    Test(DG_IsCleanInput("hello", 32), "plain text is clean");
    Test(!DG_IsCleanInput("", 32), "empty input is rejected");
    Test(!DG_IsCleanInput("line1\nline2", 32), "newline is rejected");
    Test(!DG_IsCleanInput("tab\there", 32), "tab is rejected");
    Test(!DG_IsCleanInput("abcdefghijklmnopqrstuvwxyz0123456", 32), "overlong input is rejected");

    Test(DG_ParseAmount("123", value), "digits parse");
    TestInt(123, value, "parsed value is 123");
    Test(DG_ParseAmount("007", value), "leading zeros parse");
    TestInt(7, value, "leading zeros collapse to 7");
    Test(!DG_ParseAmount("-5", value), "negative amount is rejected");
    Test(!DG_ParseAmount("12a", value), "trailing letter is rejected");
    Test(!DG_ParseAmount("", value), "empty amount is rejected");
    Test(!DG_ParseAmount("1234567890", value), "ten digits overflow the guard");
    Test(DG_ParseAmount("999999999", value), "nine digits fit");
    TestInt(999999999, value, "nine-digit value is exact");
}

public OnGameModeInit()
{
    TestSpoof();
    TestFreshness();
    TestReplay();
    TestMessageBox();
    TestResetAndArguments();
    TestInputValidation();

    printf("[DLG] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
