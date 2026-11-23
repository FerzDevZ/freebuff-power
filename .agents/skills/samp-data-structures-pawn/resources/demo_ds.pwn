// Compile + assertion fixture for samp_ds.inc.
// @runtime-suite
// Body is shared by both targets: demo_ds_omp.pwn defines OMP_BUILD first.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include <samp_ds>

// Minimal self-contained assertions: this fixture must compile alone, without
// pulling another skill's harness. In a gamemode, call samp_test.inc instead and
// forward CheckInt/Test to ST_CheckInt/ST_Check.
new gChecks;
new gFailures;

stock Test(condition, const label[])
{
    gChecks++;
    if (condition) return 1;
    gFailures++;
    printf("[DS] FAIL: %s", label);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;
    gFailures++;
    printf("[DS] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

stock TestQueue()
{
    new queue = DS_QueueNew();
    Test(queue >= 0, "queue allocates");

    new value = 0;
    Test(!DS_QueuePop(queue, value), "empty pop returns 0");
    Test(DS_QueueCount(queue) == 0, "empty queue counts 0");

    for (new i = 1; i <= 3; i++) DS_QueuePush(queue, i * 10);
    TestInt(10, DS_QueuePeek(queue, value) ? value : -1, "peek reads oldest without removing");
    TestInt(3, DS_QueueCount(queue), "count after three pushes");

    DS_QueuePop(queue, value);
    DS_QueuePop(queue, value);
    TestInt(30, DS_QueuePop(queue, value) ? value : -1, "FIFO order preserved");
    Test(!DS_QueuePop(queue, value), "queue drained");

    // Wrap-around: the ring must survive far more than one lap.
    for (new lap = 0; lap < 70; lap++)
    {
        if (!DS_QueuePush(queue, lap)) { Test(false, "push during wrap"); break; }
        if (!DS_QueuePop(queue, value) || value != lap) { Test(false, "wrap keeps order"); break; }
    }
    TestInt(0, DS_QueueCount(queue), "queue empty after wrap cycles");

    for (new i = 0; i < DS_QUEUE_CAP; i++) DS_QueuePush(queue, i);
    Test(DS_QueueIsFull(queue), "queue reports full at capacity");
    Test(!DS_QueuePush(queue, 999), "push on full queue rejected");
    TestInt(DS_QUEUE_CAP, DS_QueueCount(queue), "count capped at capacity");

    DS_QueueClear(queue);
    TestInt(0, DS_QueueCount(queue), "clear empties queue");
    Test(DS_QueueDestroy(queue), "queue destroy succeeds");
    Test(!DS_QueuePush(queue, 1), "destroyed queue rejects push");
    Test(!DS_QueueValid(-1), "invalid handle rejected");
}

stock TestArray()
{
    new array = DS_ArrayNew();
    Test(array >= 0, "array allocates");

    new value = 0;
    Test(!DS_ArrayTryGet(array, 0, value), "get on empty array returns 0");

    DS_ArrayPush(array, 5);
    DS_ArrayPush(array, 10);
    DS_ArrayPush(array, 15);
    TestInt(3, DS_ArrayCount(array), "count after pushes");
    TestInt(10, DS_ArrayGet(array, 1, -1), "get by index");
    TestInt(-1, DS_ArrayGet(array, 9, -1), "out-of-range get returns fallback");
    TestInt(5, DS_ArrayGet(array, -1, 5), "negative index returns fallback");

    Test(!DS_ArraySet(array, 3, 99), "set past end rejected");
    Test(DS_ArraySet(array, 2, 25), "set inside range accepted");
    TestInt(25, DS_ArrayGet(array, 2, -1), "set persists");

    TestInt(1, DS_ArrayFind(array, 10), "find existing value");
    TestInt(-1, DS_ArrayFind(array, 77), "find missing returns -1");

    Test(DS_ArrayRemoveAt(array, 1), "remove middle element");
    TestInt(2, DS_ArrayCount(array), "count after removal");
    TestInt(25, DS_ArrayGet(array, 1, -1), "removal shifts tail down");
    Test(!DS_ArrayRemoveAt(array, 5), "remove out of range rejected");

    for (new i = 0; i < DS_ARRAY_CAP; i++) DS_ArrayPush(array, i);
    Test(DS_ArrayIsFull(array), "array reports full");
    Test(!DS_ArrayPush(array, 1), "push on full array rejected");

    DS_ArrayClear(array);
    TestInt(0, DS_ArrayCount(array), "clear empties array");
    DS_ArrayDestroy(array);
    Test(!DS_ArrayPush(array, 1), "destroyed array rejects push");
}

stock TestMap()
{
    new map = DS_MapNew();
    Test(map >= 0, "map allocates");

    new value = 0;
    Test(!DS_MapGet(map, "Buffy", value), "missing key returns 0");

    Test(DS_MapSet(map, "Buffy", 7), "insert key");
    Test(DS_MapSet(map, "Angel", 3), "insert second key");
    TestInt(2, DS_MapCount(map), "count after two inserts");

    Test(DS_MapGet(map, "Buffy", value), "get inserted key");
    TestInt(7, value, "get returns stored value");
    Test(DS_MapHas(map, "Angel"), "has existing key");
    Test(!DS_MapHas(map, "Spike"), "has missing key is false");

    Test(DS_MapSet(map, "Buffy", 9), "overwrite existing key");
    TestInt(2, DS_MapCount(map), "overwrite does not grow count");
    DS_MapGet(map, "Buffy", value);
    TestInt(9, value, "overwrite replaces value");

    Test(!DS_MapSet(map, "", 1), "empty key rejected");
    Test(!DS_MapGet(map, "", value), "empty key lookup rejected");

    new longKey[DS_MAP_KEY_LEN + 8];
    for (new i = 0; i < DS_MAP_KEY_LEN + 7; i++) longKey[i] = 'x';
    longKey[DS_MAP_KEY_LEN + 7] = '\0';
    Test(!DS_MapSet(map, longKey, 1), "over-long key rejected");

    Test(DS_MapRemove(map, "Buffy"), "remove existing key");
    Test(!DS_MapGet(map, "Buffy", value), "removed key is gone");
    TestInt(1, DS_MapCount(map), "count after removal");
    Test(!DS_MapRemove(map, "Buffy"), "remove twice rejected");
    Test(!DS_MapRemove(map, "Ghost"), "remove missing key rejected");

    Test(DS_MapSet(map, "Buffy", 11), "reinsert after removal");
    DS_MapGet(map, "Buffy", value);
    TestInt(11, value, "reinserted value readable");
    Test(DS_MapHas(map, "Angel"), "untouched key survives tombstone reuse");

    // Collisions: more keys than slots would exhaust it, so stay below the cap
    // and assert every stored key is still readable through its probe chain.
    new key[16];
    new allFound = 1;
    for (new i = 0; i < DS_MAP_SLOTS - 4; i++)
    {
        format(key, sizeof key, "player_%d", i);
        if (!DS_MapSet(map, key, i)) { allFound = 0; break; }
    }
    for (new i = 0; i < DS_MAP_SLOTS - 4; i++)
    {
        format(key, sizeof key, "player_%d", i);
        if (!DS_MapGet(map, key, value) || value != i) { allFound = 0; break; }
    }
    Test(allFound, "probe chain keeps every key reachable");

    DS_MapDestroy(map);
    Test(!DS_MapHas(map, "Angel"), "destroyed map rejects lookups");
}

stock TestString()
{
    new builder = DS_StrNew();
    Test(builder >= 0, "string builder allocates");
    TestInt(0, DS_StrLen(builder), "builder starts empty");
    Test(!DS_StrWasTruncated(builder), "builder starts untruncated");

    Test(DS_StrAppend(builder, "hello"), "append fits");
    Test(DS_StrAppendJoined(builder, ", ", "world"), "joined append adds separator");
    TestInt(12, DS_StrLen(builder), "length after appends");

    new out[64];
    DS_StrCopy(builder, out, sizeof out);
    Test(strcmp(out, "hello, world", false) == 0, "copy returns built text");

    DS_StrReset(builder);
    TestInt(0, DS_StrLen(builder), "reset clears length");
    DS_StrAppendJoined(builder, ", ", "first");
    DS_StrCopy(builder, out, sizeof out);
    Test(strcmp(out, "first", false) == 0, "joined append skips leading separator");

    DS_StrReset(builder);
    DS_StrAppendInt(builder, -42);
    DS_StrAppend(builder, "/");
    DS_StrAppendFloat(builder, 3.5);
    DS_StrCopy(builder, out, sizeof out);
    Test(strcmp(out, "-42/3.50", false) == 0, "int and float append");

    DS_StrReset(builder);
    new big[DS_STR_CAP + 40];
    for (new i = 0; i < DS_STR_CAP + 39; i++) big[i] = 'a';
    big[DS_STR_CAP + 39] = '\0';
    Test(!DS_StrAppend(builder, big), "over-capacity append reports truncation");
    Test(DS_StrWasTruncated(builder), "truncation flag set");
    TestInt(DS_STR_CAP - 1, DS_StrLen(builder), "content clamped to capacity - 1");

    DS_StrCopy(builder, out, 8);
    TestInt(7, strlen(out), "copy respects small destination");
    Test(strcmp(out, "aaaaaaa", false) == 0, "copy stays NUL-terminated");

    Test(DS_StrAppend(-1, "x") == 0, "invalid builder rejects append");
    DS_StrDestroy(builder);
    Test(!DS_StrAppend(builder, "x"), "destroyed builder rejects append");
}

stock TestBits()
{
    new bits[DS_BITS_CELLS];
    DS_BitClearAll(bits);
    TestInt(0, DS_BitCount(bits), "bitset starts empty");

    Test(DS_BitSet(bits, 0), "set bit 0");
    Test(DS_BitSet(bits, 31), "set bit 31");
    Test(DS_BitSet(bits, 200), "set bit 200");
    TestInt(3, DS_BitCount(bits), "count after three sets");

    Test(DS_BitGet(bits, 31), "get set bit");
    Test(!DS_BitGet(bits, 30), "adjacent bit stays clear");
    Test(!DS_BitGet(bits, 32), "next cell unaffected");

    Test(DS_BitClear(bits, 31), "clear bit 31");
    Test(!DS_BitGet(bits, 31), "cleared bit reads 0");
    TestInt(2, DS_BitCount(bits), "count after clear");

    Test(!DS_BitSet(bits, DS_BITS_MAX), "index at max rejected");
    Test(!DS_BitSet(bits, -1), "negative index rejected");
    Test(!DS_BitGet(bits, DS_BITS_MAX), "out-of-range get returns 0");

    DS_BitClearAll(bits);
    TestInt(0, DS_BitCount(bits), "clear all empties bitset");
}

public OnGameModeInit()
{
    TestQueue();
    TestArray();
    TestMap();
    TestString();
    TestBits();

    printf("[DS] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
