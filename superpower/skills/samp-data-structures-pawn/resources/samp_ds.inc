/**
 * samp_ds.inc — dependency-free data structures for Pawn (SA-MP 0.3.7 / open.mp).
 *
 * Pawn has no collection library. Gamemodes therefore reach for fixed arrays and
 * hand-written index math, which is where the classic crashes come from:
 * writing past the end, reading a slot that was never filled, and appending a
 * string with format() that silently truncates.
 *
 * These structures are slot-pooled so no malloc/include is required: the storage
 * is static, the handle is a small integer, and every operation validates its
 * handle. The compiler cannot catch an out-of-range array write at runtime, so
 * each function returns 0 instead of writing.
 *
 *   new queue = DS_QueueNew();
 *   DS_QueuePush(queue, 10);
 *   new value;
 *   if (DS_QueuePop(queue, value)) { ... }   // value == 10
 *
 *   new map = DS_MapNew();
 *   DS_MapSet(map, "Buffy", 7);
 *   new level;
 *   if (DS_MapGet(map, "Buffy", level)) { ... }   // level == 7
 *
 * Convention: a handle of -1 means "could not allocate"; every function accepts
 * it and returns 0. Ignoring a return value is the only remaining way to get
 * silent wrong behaviour, so the return values are part of the contract.
 */

#if defined _samp_ds_included
    #endinput
#endif
#define _samp_ds_included

/* Pool sizes are compile-time. Override with #define before the include when a
 * gamemode needs more, but keep them small: this memory is resident forever. */
#if !defined DS_MAX_QUEUES
    #define DS_MAX_QUEUES (4)
#endif
#if !defined DS_QUEUE_CAP
    #define DS_QUEUE_CAP (64)
#endif
#if !defined DS_MAX_ARRAYS
    #define DS_MAX_ARRAYS (4)
#endif
#if !defined DS_ARRAY_CAP
    #define DS_ARRAY_CAP (64)
#endif
#if !defined DS_MAX_MAPS
    #define DS_MAX_MAPS (2)
#endif
#if !defined DS_MAP_SLOTS
    #define DS_MAP_SLOTS (32)
#endif
#if !defined DS_MAP_KEY_LEN
    #define DS_MAP_KEY_LEN (33)
#endif
#if !defined DS_MAX_STRINGS
    #define DS_MAX_STRINGS (4)
#endif
#if !defined DS_STR_CAP
    #define DS_STR_CAP (128)
#endif
#if !defined DS_BITS_MAX
    #define DS_BITS_MAX (256)
#endif

#define DS_BITS_CELLS (DS_BITS_MAX / 32)

/* ------------------------------------------------------------------------- *
 * 1. FIFO queue (ring buffer)                                                *
 * ------------------------------------------------------------------------- */

static gDSQueueData[DS_MAX_QUEUES][DS_QUEUE_CAP];
static gDSQueueHead[DS_MAX_QUEUES];
static gDSQueueTail[DS_MAX_QUEUES];
static gDSQueueCount[DS_MAX_QUEUES];
static bool:gDSQueueUsed[DS_MAX_QUEUES];

stock DS_QueueNew()
{
    for (new i = 0; i < DS_MAX_QUEUES; i++)
    {
        if (!gDSQueueUsed[i])
        {
            gDSQueueUsed[i] = true;
            gDSQueueHead[i] = 0;
            gDSQueueTail[i] = 0;
            gDSQueueCount[i] = 0;
            return i;
        }
    }
    return -1;
}

stock DS_QueueDestroy(queue)
{
    if (queue < 0 || queue >= DS_MAX_QUEUES || !gDSQueueUsed[queue]) return 0;
    gDSQueueUsed[queue] = false;
    gDSQueueHead[queue] = 0;
    gDSQueueTail[queue] = 0;
    gDSQueueCount[queue] = 0;
    return 1;
}

stock DS_QueueValid(queue)
{
    return (queue >= 0 && queue < DS_MAX_QUEUES && gDSQueueUsed[queue]);
}

/** Returns 1 on success, 0 when the queue is full or the handle is invalid. */
stock DS_QueuePush(queue, value)
{
    if (!DS_QueueValid(queue) || gDSQueueCount[queue] >= DS_QUEUE_CAP) return 0;
    gDSQueueData[queue][gDSQueueTail[queue]] = value;
    gDSQueueTail[queue] = (gDSQueueTail[queue] + 1) % DS_QUEUE_CAP;
    gDSQueueCount[queue]++;
    return 1;
}

/** Returns 1 and writes the oldest value, 0 when empty. */
stock DS_QueuePop(queue, &value)
{
    if (!DS_QueueValid(queue) || gDSQueueCount[queue] == 0) return 0;
    value = gDSQueueData[queue][gDSQueueHead[queue]];
    gDSQueueHead[queue] = (gDSQueueHead[queue] + 1) % DS_QUEUE_CAP;
    gDSQueueCount[queue]--;
    return 1;
}

/** Reads the oldest value without removing it. */
stock DS_QueuePeek(queue, &value)
{
    if (!DS_QueueValid(queue) || gDSQueueCount[queue] == 0) return 0;
    value = gDSQueueData[queue][gDSQueueHead[queue]];
    return 1;
}

stock DS_QueueCount(queue)
{
    if (!DS_QueueValid(queue)) return 0;
    return gDSQueueCount[queue];
}

stock DS_QueueIsFull(queue)
{
    return DS_QueueValid(queue) && gDSQueueCount[queue] >= DS_QUEUE_CAP;
}

stock DS_QueueClear(queue)
{
    if (!DS_QueueValid(queue)) return 0;
    gDSQueueHead[queue] = 0;
    gDSQueueTail[queue] = 0;
    gDSQueueCount[queue] = 0;
    return 1;
}

/* ------------------------------------------------------------------------- *
 * 2. Growable index of integers (append, find, remove-shift)                 *
 * ------------------------------------------------------------------------- */

static gDSArrayData[DS_MAX_ARRAYS][DS_ARRAY_CAP];
static gDSArrayCount[DS_MAX_ARRAYS];
static bool:gDSArrayUsed[DS_MAX_ARRAYS];

stock DS_ArrayNew()
{
    for (new i = 0; i < DS_MAX_ARRAYS; i++)
    {
        if (!gDSArrayUsed[i])
        {
            gDSArrayUsed[i] = true;
            gDSArrayCount[i] = 0;
            return i;
        }
    }
    return -1;
}

stock DS_ArrayDestroy(array)
{
    if (array < 0 || array >= DS_MAX_ARRAYS || !gDSArrayUsed[array]) return 0;
    gDSArrayUsed[array] = false;
    gDSArrayCount[array] = 0;
    return 1;
}

stock DS_ArrayValid(array)
{
    return (array >= 0 && array < DS_MAX_ARRAYS && gDSArrayUsed[array]);
}

stock DS_ArrayPush(array, value)
{
    if (!DS_ArrayValid(array) || gDSArrayCount[array] >= DS_ARRAY_CAP) return 0;
    gDSArrayData[array][gDSArrayCount[array]] = value;
    gDSArrayCount[array]++;
    return 1;
}

stock DS_ArrayCount(array)
{
    if (!DS_ArrayValid(array)) return 0;
    return gDSArrayCount[array];
}

/** Returns 1 and writes the value; 0 when the index is out of range. */
stock DS_ArrayTryGet(array, index, &value)
{
    if (!DS_ArrayValid(array) || index < 0 || index >= gDSArrayCount[array]) return 0;
    value = gDSArrayData[array][index];
    return 1;
}

/** Convenience read with a fallback. Prefer DS_ArrayTryGet when 0 is a real value. */
stock DS_ArrayGet(array, index, fallback)
{
    new value;
    if (!DS_ArrayTryGet(array, index, value)) return fallback;
    return value;
}

stock DS_ArraySet(array, index, value)
{
    if (!DS_ArrayValid(array) || index < 0 || index >= gDSArrayCount[array]) return 0;
    gDSArrayData[array][index] = value;
    return 1;
}

/** Returns the first matching index, or -1. Linear: fine below ~64 entries. */
stock DS_ArrayFind(array, value)
{
    if (!DS_ArrayValid(array)) return -1;
    for (new i = 0; i < gDSArrayCount[array]; i++)
    {
        if (gDSArrayData[array][i] == value) return i;
    }
    return -1;
}

/** Removes by index and shifts the tail down, preserving order. */
stock DS_ArrayRemoveAt(array, index)
{
    if (!DS_ArrayValid(array) || index < 0 || index >= gDSArrayCount[array]) return 0;
    for (new i = index; i < gDSArrayCount[array] - 1; i++)
    {
        gDSArrayData[array][i] = gDSArrayData[array][i + 1];
    }
    gDSArrayCount[array]--;
    return 1;
}

stock DS_ArrayIsFull(array)
{
    return DS_ArrayValid(array) && gDSArrayCount[array] >= DS_ARRAY_CAP;
}

stock DS_ArrayClear(array)
{
    if (!DS_ArrayValid(array)) return 0;
    gDSArrayCount[array] = 0;
    return 1;
}

/* ------------------------------------------------------------------------- *
 * 3. String -> int map (open addressing, linear probing, tombstones)         *
 * ------------------------------------------------------------------------- */

static gDSMapKey[DS_MAX_MAPS][DS_MAP_SLOTS][DS_MAP_KEY_LEN];
static gDSMapValue[DS_MAX_MAPS][DS_MAP_SLOTS];
static gDSMapUsed[DS_MAX_MAPS][DS_MAP_SLOTS];
static gDSMapDeleted[DS_MAX_MAPS][DS_MAP_SLOTS];
static gDSMapCount[DS_MAX_MAPS];
static gDSMapUsedFlag[DS_MAX_MAPS];

stock DS_MapHash(const key[])
{
    new hash = 5381;
    for (new i = 0; key[i] != '\0'; i++)
    {
        hash = ((hash << 5) + hash) + key[i];
    }
    return hash & (DS_MAP_SLOTS - 1);
}

stock DS_MapNew()
{
    for (new i = 0; i < DS_MAX_MAPS; i++)
    {
        if (!gDSMapUsedFlag[i])
        {
            gDSMapUsedFlag[i] = true;
            gDSMapCount[i] = 0;
            for (new slot = 0; slot < DS_MAP_SLOTS; slot++)
            {
                gDSMapUsed[i][slot] = false;
                gDSMapDeleted[i][slot] = false;
                gDSMapKey[i][slot][0] = '\0';
                gDSMapValue[i][slot] = 0;
            }
            return i;
        }
    }
    return -1;
}

stock DS_MapDestroy(map)
{
    if (map < 0 || map >= DS_MAX_MAPS || !gDSMapUsedFlag[map]) return 0;
    gDSMapUsedFlag[map] = false;
    gDSMapCount[map] = 0;
    return 1;
}

stock DS_MapValid(map)
{
    return (map >= 0 && map < DS_MAX_MAPS && gDSMapUsedFlag[map]);
}

/** Inserts or updates. Returns 0 on invalid handle, bad key, or a full table. */
stock DS_MapSet(map, const key[], value)
{
    if (!DS_MapValid(map) || key[0] == '\0') return 0;
    if (strlen(key) >= DS_MAP_KEY_LEN) return 0;

    new start = DS_MapHash(key);
    new firstFree = -1;

    for (new probe = 0; probe < DS_MAP_SLOTS; probe++)
    {
        new slot = (start + probe) & (DS_MAP_SLOTS - 1);
        if (!gDSMapUsed[map][slot])
        {
            if (firstFree == -1) firstFree = slot;
            break;
        }
        if (gDSMapDeleted[map][slot])
        {
            if (firstFree == -1) firstFree = slot;
            continue;
        }
        if (strcmp(gDSMapKey[map][slot], key, false) == 0)
        {
            gDSMapValue[map][slot] = value;
            return 1;
        }
    }

    if (firstFree == -1) return 0;

    gDSMapUsed[map][firstFree] = true;
    gDSMapDeleted[map][firstFree] = false;
    gDSMapKey[map][firstFree][0] = '\0';
    strcat(gDSMapKey[map][firstFree], key, DS_MAP_KEY_LEN);
    gDSMapValue[map][firstFree] = value;
    gDSMapCount[map]++;
    return 1;
}

/** Returns 1 and writes the value when the key exists. */
stock DS_MapGet(map, const key[], &value)
{
    if (!DS_MapValid(map) || key[0] == '\0') return 0;

    new start = DS_MapHash(key);
    for (new probe = 0; probe < DS_MAP_SLOTS; probe++)
    {
        new slot = (start + probe) & (DS_MAP_SLOTS - 1);
        if (!gDSMapUsed[map][slot]) return 0;
        if (gDSMapDeleted[map][slot]) continue;
        if (strcmp(gDSMapKey[map][slot], key, false) == 0)
        {
            value = gDSMapValue[map][slot];
            return 1;
        }
    }
    return 0;
}

stock DS_MapHas(map, const key[])
{
    new ignored;
    return DS_MapGet(map, key, ignored);
}

/** Tombstones the slot so probe chains stay intact. Re-insertion reuses it. */
stock DS_MapRemove(map, const key[])
{
    if (!DS_MapValid(map) || key[0] == '\0') return 0;

    new start = DS_MapHash(key);
    for (new probe = 0; probe < DS_MAP_SLOTS; probe++)
    {
        new slot = (start + probe) & (DS_MAP_SLOTS - 1);
        if (!gDSMapUsed[map][slot]) return 0;
        if (gDSMapDeleted[map][slot]) continue;
        if (strcmp(gDSMapKey[map][slot], key, false) == 0)
        {
            gDSMapDeleted[map][slot] = true;
            gDSMapKey[map][slot][0] = '\0';
            gDSMapValue[map][slot] = 0;
            gDSMapCount[map]--;
            return 1;
        }
    }
    return 0;
}

stock DS_MapCount(map)
{
    if (!DS_MapValid(map)) return 0;
    return gDSMapCount[map];
}

/* ------------------------------------------------------------------------- *
 * 4. Bounded string builder (the fix for silent format() truncation)         *
 * ------------------------------------------------------------------------- */

static gDSStrBuffer[DS_MAX_STRINGS][DS_STR_CAP];
static gDSStrLen[DS_MAX_STRINGS];
static gDSStrTruncated[DS_MAX_STRINGS];
static bool:gDSStrUsed[DS_MAX_STRINGS];

stock DS_StrNew()
{
    for (new i = 0; i < DS_MAX_STRINGS; i++)
    {
        if (!gDSStrUsed[i])
        {
            gDSStrUsed[i] = true;
            gDSStrBuffer[i][0] = '\0';
            gDSStrLen[i] = 0;
            gDSStrTruncated[i] = 0;
            return i;
        }
    }
    return -1;
}

stock DS_StrDestroy(builder)
{
    if (builder < 0 || builder >= DS_MAX_STRINGS || !gDSStrUsed[builder]) return 0;
    gDSStrUsed[builder] = false;
    gDSStrBuffer[builder][0] = '\0';
    gDSStrLen[builder] = 0;
    gDSStrTruncated[builder] = 0;
    return 1;
}

stock DS_StrValid(builder)
{
    return (builder >= 0 && builder < DS_MAX_STRINGS && gDSStrUsed[builder]);
}

stock DS_StrReset(builder)
{
    if (!DS_StrValid(builder)) return 0;
    gDSStrBuffer[builder][0] = '\0';
    gDSStrLen[builder] = 0;
    gDSStrTruncated[builder] = 0;
    return 1;
}

/** Returns 1 when the whole text fit, 0 when it was truncated or invalid. */
stock DS_StrAppend(builder, const text[])
{
    if (!DS_StrValid(builder)) return 0;

    new room = DS_STR_CAP - 1 - gDSStrLen[builder];
    new need = strlen(text);
    new whole = 1;

    if (need > room)
    {
        need = room;
        gDSStrTruncated[builder] = 1;
        whole = 0;
    }

    for (new i = 0; i < need; i++)
    {
        gDSStrBuffer[builder][gDSStrLen[builder] + i] = text[i];
    }
    gDSStrLen[builder] += need;
    gDSStrBuffer[builder][gDSStrLen[builder]] = '\0';
    return whole;
}

stock DS_StrAppendInt(builder, value)
{
    new temp[16];
    format(temp, sizeof temp, "%d", value);
    return DS_StrAppend(builder, temp);
}

/** Two decimals, no thousands separator — format for logs, not for money UI. */
stock DS_StrAppendFloat(builder, Float:value)
{
    new temp[24];
    format(temp, sizeof temp, "%.2f", value);
    return DS_StrAppend(builder, temp);
}

/** Separator-aware append: skips the separator when the builder is empty. */
stock DS_StrAppendJoined(builder, const separator[], const text[])
{
    if (!DS_StrValid(builder)) return 0;
    if (gDSStrLen[builder] > 0)
    {
        if (!DS_StrAppend(builder, separator)) return 0;
    }
    return DS_StrAppend(builder, text);
}

/** Copies the content out, always NUL-terminated, never overflows `size`. */
stock DS_StrCopy(builder, dest[], size)
{
    if (size <= 0) return 0;
    dest[0] = '\0';
    if (!DS_StrValid(builder)) return 0;

    new limit = size - 1;
    new length = gDSStrLen[builder];
    if (length > limit)
    {
        length = limit;
        gDSStrTruncated[builder] = 1;
    }

    for (new i = 0; i < length; i++)
    {
        dest[i] = gDSStrBuffer[builder][i];
    }
    dest[length] = '\0';
    return 1;
}

stock DS_StrLen(builder)
{
    if (!DS_StrValid(builder)) return 0;
    return gDSStrLen[builder];
}

/** True once any append or copy lost characters. Check it before trusting UI text. */
stock DS_StrWasTruncated(builder)
{
    if (!DS_StrValid(builder)) return 0;
    return gDSStrTruncated[builder];
}

/* ------------------------------------------------------------------------- *
 * 5. Bitset (caller owns the array)                                          *
 * ------------------------------------------------------------------------- */

/* Caller-side declaration: new flags[DS_BITS_CELLS]; */

stock DS_BitSet(bits[], index)
{
    if (index < 0 || index >= DS_BITS_MAX) return 0;
    bits[index / 32] |= (1 << (index & 31));
    return 1;
}

stock DS_BitClear(bits[], index)
{
    if (index < 0 || index >= DS_BITS_MAX) return 0;
    bits[index / 32] &= ~(1 << (index & 31));
    return 1;
}

stock DS_BitGet(const bits[], index)
{
    if (index < 0 || index >= DS_BITS_MAX) return 0;
    return (bits[index / 32] >>> (index & 31)) & 1;
}

stock DS_BitClearAll(bits[])
{
    for (new i = 0; i < DS_BITS_CELLS; i++) bits[i] = 0;
    return 1;
}

stock DS_BitCount(const bits[])
{
    new total = 0;
    for (new i = 0; i < DS_BITS_CELLS; i++)
    {
        for (new bit = 0; bit < 32; bit++)
        {
            if ((bits[i] >>> bit) & 1) total++;
        }
    }
    return total;
}
