/**
 * samp_json.inc — bounded JSON reader/writer for Pawn (SA-MP 0.3.7 / open.mp).
 *
 * A gamemode talking to an HTTP API receives a response body it did not write.
 * The two rules that keep that safe are:
 *
 *   1. Never trust the length. Every read is bounded by the destination size and
 *      by the NUL terminator, so a truncated or hostile body cannot overrun a
 *      buffer.
 *   2. Never trust the shape. A missing key, a number where a string was
 *      expected, or a half-received body must return 0 — not a zero value that
 *      looks like real data.
 *
 * This is an extractor first and a light shape-checker second: it reads what it
 * needs from a well-formed document and fails closed on anything else. It is not
 * a full JSON Schema implementation — see JSN_Validate for what it does cover.
 *
 *   new id;
 *   if (JSN_GetInt(body, "user.id", id)) { ... }
 *
 *   new name[32];
 *   if (!JSN_GetString(body, "user.name", name, sizeof name)) { ...absent... }
 *
 * Path syntax: dotted keys and numeric array indexes.
 *   "user.name"      object member
 *   "tags.0"         array element
 *   "list.1.id"      array of objects
 *
 * String escapes are decoded (\" \\ \/ \b \f \n \r \t and \uXXXX). A surrogate
 * pair (\uD83D\uDE00) becomes one 4-byte UTF-8 sequence; a lone or malformed
 * surrogate becomes '?' so the rest of the string survives. \u0000 also becomes
 * '?', because a NUL byte would end the Pawn string.
 *
 * Shape checking (optional, schema kept in a string so it can live in config):
 *
 *   new bad[JSN_MAX_PATH], reason;
 *   if (!JSN_Validate(body, "ok:bool|user.id:int|user.name:string|?user.email:string"
 *                           "|user.tags:array<string>|user.level:int[0..100]",
 *                     bad, sizeof bad, reason))
 *   {
 *       // reason == JSN_TYPE_MISSING -> required field absent
 *       // reason == JSN_TYPE_NUMBER  -> present but wrong type (kind)
 *       // bad holds the offending path, or "@document" / "@rule"
 *   }
 */

#if defined _samp_json_included
    #endinput
#endif
#define _samp_json_included

#if !defined JSN_MAX_SEGMENT
    #define JSN_MAX_SEGMENT (48)
#endif
#if !defined JSN_MAX_PATH
    #define JSN_MAX_PATH (96)
#endif
/* Longest type spec accepted: "array<object>[0..999]" and friends. */
#if !defined JSN_MAX_TYPE
    #define JSN_MAX_TYPE (32)
#endif

/* Value kinds reported by JSN_TypeOf and used as JSN_Validate reasons. */
#define JSN_TYPE_MISSING (0)
#define JSN_TYPE_STRING  (1)
#define JSN_TYPE_INT     (2)
#define JSN_TYPE_NUMBER  (3)
#define JSN_TYPE_BOOL    (4)
#define JSN_TYPE_ARRAY   (5)
#define JSN_TYPE_OBJECT  (6)
#define JSN_TYPE_NULL    (7)

/* JSN_Validate reasons that are not value kinds. */
#define JSN_SCHEMA_BAD_RULE      (-1)
#define JSN_SCHEMA_BAD_DOC       (-2)
#define JSN_SCHEMA_OUT_OF_RANGE  (-3)
#define JSN_SCHEMA_BAD_ELEMENT   (-4)

/* Set when a copy hit the destination limit. Reset before each response. */
static gJSNTruncated;

stock JSN_ResetState()
{
    gJSNTruncated = 0;
    return 1;
}

/** True when the last string copy lost characters. Check it before trusting text. */
stock JSN_WasTruncated()
{
    return gJSNTruncated;
}

/* ------------------------------------------------------------------------- *
 * Internal scanning primitives (no recursion, bounded by NUL)                *
 * ------------------------------------------------------------------------- */

stock JSN_SkipWs(const s[], &pos)
{
    while (s[pos] == ' ' || s[pos] == '\t' || s[pos] == '\n' || s[pos] == '\r') pos++;
}

stock JSN_IsDelimiter(ch)
{
    return (ch == '\0' || ch == ',' || ch == '}' || ch == ']' || ch == ' '
        || ch == '\t' || ch == '\n' || ch == '\r');
}

/** pos must be at the opening quote. Leaves pos after the closing quote. */
stock JSN_SkipString(const s[], &pos)
{
    if (s[pos] != '"') return 0;
    pos++;
    while (s[pos] != '\0')
    {
        if (s[pos] == '\\')
        {
            pos++;
            if (s[pos] == '\0') return 0;
            pos++;
            continue;
        }
        if (s[pos] == '"')
        {
            pos++;
            return 1;
        }
        pos++;
    }
    return 0;
}

/** Skips any JSON value, including nested objects/arrays, without recursion. */
stock JSN_SkipValue(const s[], &pos)
{
    JSN_SkipWs(s, pos);

    new ch = s[pos];
    if (ch == '"') return JSN_SkipString(s, pos);

    if (ch == '{' || ch == '[')
    {
        new depth = 0;
        while (s[pos] != '\0')
        {
            new current = s[pos];
            if (current == '"')
            {
                if (!JSN_SkipString(s, pos)) return 0;
                continue;
            }
            if (current == '{' || current == '[') depth++;
            else if (current == '}' || current == ']')
            {
                depth--;
                if (depth == 0)
                {
                    pos++;
                    return 1;
                }
            }
            pos++;
        }
        return 0;
    }

    new start = pos;
    while (!JSN_IsDelimiter(s[pos])) pos++;
    return pos > start;
}

stock JSN_SegmentEquals(const s[], start, end, const key[])
{
    new length = end - start;
    new i = 0;
    while (key[i] != '\0')
    {
        if (i >= length || s[start + i] != key[i]) return 0;
        i++;
    }
    return i == length;
}

stock JSN_ValueStart(ch)
{
    return (ch == '"' || ch == '{' || ch == '[' || ch == 't' || ch == 'f'
        || ch == 'n' || ch == '-' || (ch >= '0' && ch <= '9'));
}

stock JSN_IsDigits(const text[])
{
    if (text[0] == '\0') return 0;
    for (new i = 0; text[i] != '\0'; i++)
    {
        if (text[i] < '0' || text[i] > '9') return 0;
    }
    return 1;
}

/** pos at '{'. On success pos is left at the matched value's first character. */
stock JSN_FindKey(const s[], &pos, const key[])
{
    if (s[pos] != '{') return 0;
    pos++;
    JSN_SkipWs(s, pos);
    if (s[pos] == '}')
    {
        pos++;
        return 0;
    }

    while (s[pos] != '\0')
    {
        JSN_SkipWs(s, pos);
        if (s[pos] != '"') return 0;

        new keyStart = pos + 1;
        if (!JSN_SkipString(s, pos)) return 0;
        new keyEnd = pos - 1;

        JSN_SkipWs(s, pos);
        if (s[pos] != ':') return 0;
        pos++;
        JSN_SkipWs(s, pos);

        if (JSN_SegmentEquals(s, keyStart, keyEnd, key)) return 1;

        if (!JSN_SkipValue(s, pos)) return 0;
        JSN_SkipWs(s, pos);
        if (s[pos] == ',')
        {
            pos++;
            continue;
        }
        if (s[pos] == '}')
        {
            pos++;
            return 0;
        }
        return 0;
    }
    return 0;
}

/** pos at '['. On success pos is left at element `index`'s first character. */
stock JSN_FindIndex(const s[], &pos, index)
{
    if (s[pos] != '[') return 0;
    pos++;
    JSN_SkipWs(s, pos);
    if (s[pos] == ']')
    {
        pos++;
        return 0;
    }

    new current = 0;
    while (s[pos] != '\0')
    {
        JSN_SkipWs(s, pos);
        if (current == index) return 1;

        if (!JSN_SkipValue(s, pos)) return 0;
        JSN_SkipWs(s, pos);
        if (s[pos] == ',')
        {
            pos++;
            current++;
            continue;
        }
        if (s[pos] == ']')
        {
            pos++;
            return 0;
        }
        return 0;
    }
    return 0;
}

/**
 * True when the body holds exactly one complete value and nothing after it.
 * This is what stops a response cut off mid-transfer from yielding a prefix
 * value: `{"a":1` is readable text but not a valid document.
 */
stock JSN_DocumentComplete(const s[])
{
    new pos = 0;
    JSN_SkipWs(s, pos);
    if (!JSN_ValueStart(s[pos])) return 0;
    if (!JSN_SkipValue(s, pos)) return 0;
    JSN_SkipWs(s, pos);
    return s[pos] == '\0';
}

/** Resolves a dotted path. pos lands on the value; 0 when absent or malformed. */
stock JSN_Seek(const s[], const path[], &pos)
{
    if (!JSN_DocumentComplete(s)) return 0;

    pos = 0;
    JSN_SkipWs(s, pos);

    if (path[0] == '\0') return 1;

    new segment[JSN_MAX_SEGMENT];
    new cursor = 0;

    while (path[cursor] != '\0')
    {
        new length = 0;
        while (path[cursor] != '\0' && path[cursor] != '.')
        {
            if (length >= JSN_MAX_SEGMENT - 1) return 0;
            segment[length++] = path[cursor++];
        }
        segment[length] = '\0';
        if (path[cursor] == '.') cursor++;
        if (length == 0) return 0;

        if (s[pos] == '{')
        {
            if (!JSN_FindKey(s, pos, segment)) return 0;
        }
        else if (s[pos] == '[')
        {
            if (!JSN_IsDigits(segment)) return 0;
            if (!JSN_FindIndex(s, pos, strval(segment))) return 0;
        }
        else
        {
            return 0;
        }

        JSN_SkipWs(s, pos);
    }
    return 1;
}

/* ------------------------------------------------------------------------- *
 * Readers                                                                    *
 * ------------------------------------------------------------------------- */

/** True when the path exists and points at something that looks like a value. */
stock JSN_Has(const s[], const path[])
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return 0;
    return JSN_ValueStart(s[pos]);
}

stock JSN_HexValue(ch)
{
    if (ch >= '0' && ch <= '9') return ch - '0';
    if (ch >= 'a' && ch <= 'f') return ch - 'a' + 10;
    if (ch >= 'A' && ch <= 'F') return ch - 'A' + 10;
    return -1;
}

/** Encodes one code point as UTF-8. Returns the new index, or -1 when it does not fit. */
stock JSN_WriteUtf8(dest[], size, idx, code)
{
    if (code < 0x80)
    {
        if (idx >= size - 1) return -1;
        dest[idx++] = code;
    }
    else if (code < 0x800)
    {
        if (idx >= size - 2) return -1;
        dest[idx++] = 0xC0 | (code >> 6);
        dest[idx++] = 0x80 | (code & 0x3F);
    }
    else if (code < 0x10000)
    {
        if (idx >= size - 3) return -1;
        dest[idx++] = 0xE0 | (code >> 12);
        dest[idx++] = 0x80 | ((code >> 6) & 0x3F);
        dest[idx++] = 0x80 | (code & 0x3F);
    }
    else
    {
        if (idx >= size - 4) return -1;
        dest[idx++] = 0xF0 | ((code >> 18) & 0x07);
        dest[idx++] = 0x80 | ((code >> 12) & 0x3F);
        dest[idx++] = 0x80 | ((code >> 6) & 0x3F);
        dest[idx++] = 0x80 | (code & 0x3F);
    }
    return idx;
}

stock JSN_Hex4(const s[], pos)
{
    new value = 0;
    for (new i = 0; i < 4; i++)
    {
        new digit = JSN_HexValue(s[pos + i]);
        if (digit < 0) return -1;
        value = (value << 4) | digit;
    }
    return value;
}

/** pos at the opening quote. Returns 0 on unterminated string or truncation. */
stock JSN_DecodeString(const s[], pos, dest[], size)
{
    if (size <= 0) return 0;
    dest[0] = '\0';
    if (s[pos] != '"') return 0;
    pos++;

    new idx = 0;
    while (s[pos] != '\0')
    {
        new ch = s[pos];

        if (ch == '"')
        {
            dest[idx] = '\0';
            return 1;
        }

        if (ch == '\\')
        {
            pos++;
            new esc = s[pos];
            if (esc == '\0') break;

            if (esc == 'n') { ch = '\n'; pos++; }
            else if (esc == 't') { ch = '\t'; pos++; }
            else if (esc == 'r') { ch = '\r'; pos++; }
            else if (esc == 'b') { ch = 8; pos++; }
            else if (esc == 'f') { ch = 12; pos++; }
            else if (esc == '/') { ch = '/'; pos++; }
            else if (esc == '"') { ch = '"'; pos++; }
            else if (esc == '\\') { ch = '\\'; pos++; }
            else if (esc == 'u')
            {
                new code = JSN_Hex4(s, pos + 1);
                new consumed = 5;

                if (code < 0)
                {
                    code = '?';
                }
                else if (code >= 0xD800 && code <= 0xDBFF)
                {
                    /* High surrogate: valid only when a low surrogate follows. */
                    new next = pos + 5;
                    new low = -1;
                    if (s[next] == '\\' && s[next + 1] == 'u') low = JSN_Hex4(s, next + 2);

                    if (low >= 0xDC00 && low <= 0xDFFF)
                    {
                        code = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00);
                        consumed = 11;
                    }
                    else
                    {
                        code = '?';
                    }
                }
                else if (code >= 0xDC00 && code <= 0xDFFF)
                {
                    code = '?';   /* low surrogate without a high one */
                }
                else if (code == 0)
                {
                    code = '?';   /* a NUL byte would end the Pawn string */
                }

                pos += consumed;

                new before = idx;
                idx = JSN_WriteUtf8(dest, size, idx, code);
                if (idx < 0)
                {
                    idx = before;
                    dest[idx] = '\0';
                    gJSNTruncated = 1;
                    return 0;
                }
                continue;
            }
            else { ch = esc; pos++; }
        }
        else
        {
            pos++;
        }

        if (idx >= size - 1)
        {
            dest[idx] = '\0';
            gJSNTruncated = 1;
            return 0;
        }
        dest[idx++] = ch;
    }

    dest[idx] = '\0';
    return 0;
}

stock JSN_GetString(const s[], const path[], dest[], size)
{
    if (size <= 0) return 0;
    dest[0] = '\0';

    new pos;
    if (!JSN_Seek(s, path, pos)) return 0;
    return JSN_DecodeString(s, pos, dest, size);
}

/** Copies a bare scalar (number/true/false/null) into `dest`, bounded. */
stock JSN_CopyScalar(const s[], pos, dest[], size)
{
    if (size <= 0) return 0;
    dest[0] = '\0';

    new idx = 0;
    while (!JSN_IsDelimiter(s[pos]))
    {
        if (idx >= size - 1)
        {
            dest[idx] = '\0';
            gJSNTruncated = 1;
            return 0;
        }
        dest[idx++] = s[pos++];
    }
    dest[idx] = '\0';
    return idx > 0;
}

stock JSN_IsInteger(const text[])
{
    new i = 0;
    if (text[0] == '-') i = 1;
    if (text[i] == '\0') return 0;
    for (; text[i] != '\0'; i++)
    {
        if (text[i] < '0' || text[i] > '9') return 0;
    }
    return 1;
}

stock JSN_IsNumber(const text[])
{
    new i = 0;
    new digits = 0;

    if (text[i] == '-') i++;
    for (; text[i] >= '0' && text[i] <= '9'; i++) digits++;
    if (digits == 0) return 0;

    if (text[i] == '.')
    {
        i++;
        new fraction = 0;
        for (; text[i] >= '0' && text[i] <= '9'; i++) fraction++;
        if (fraction == 0) return 0;
    }

    if (text[i] == 'e' || text[i] == 'E')
    {
        i++;
        if (text[i] == '+' || text[i] == '-') i++;
        new exponent = 0;
        for (; text[i] >= '0' && text[i] <= '9'; i++) exponent++;
        if (exponent == 0) return 0;
    }

    return text[i] == '\0';
}

/** Strict: rejects "1.5", "true", and quoted numbers. */
stock JSN_GetInt(const s[], const path[], &value)
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return 0;

    new text[24];
    if (!JSN_CopyScalar(s, pos, text, sizeof text)) return 0;
    if (!JSN_IsInteger(text)) return 0;

    value = strval(text);
    return 1;
}

stock JSN_GetFloat(const s[], const path[], &Float:value)
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return 0;

    new text[24];
    if (!JSN_CopyScalar(s, pos, text, sizeof text)) return 0;
    if (!JSN_IsNumber(text)) return 0;

    value = floatstr(text);
    return 1;
}

/** Returns 1 for true/false (value 1/0), 0 when the path is not a boolean. */
stock JSN_GetBool(const s[], const path[], &value)
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return 0;

    new text[8];
    if (!JSN_CopyScalar(s, pos, text, sizeof text)) return 0;

    if (strcmp(text, "true", false) == 0)
    {
        value = 1;
        return 1;
    }
    if (strcmp(text, "false", false) == 0)
    {
        value = 0;
        return 1;
    }
    return 0;
}

/** Element count, 0 for an empty array, -1 when the path is missing or not an array. */
stock JSN_CountArray(const s[], const path[])
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return -1;
    if (s[pos] != '[') return -1;

    pos++;
    JSN_SkipWs(s, pos);
    if (s[pos] == ']') return 0;

    new count = 0;
    while (s[pos] != '\0')
    {
        if (!JSN_SkipValue(s, pos)) return -1;
        count++;

        JSN_SkipWs(s, pos);
        if (s[pos] == ',')
        {
            pos++;
            JSN_SkipWs(s, pos);
            continue;
        }
        if (s[pos] == ']') return count;
        return -1;
    }
    return -1;
}

/* ------------------------------------------------------------------------- *
 * Light shape validation: "path:type" rules separated by '|'                  *
 * ------------------------------------------------------------------------- */

/** Kind of the value at `path`, or JSN_TYPE_MISSING when absent/not a value. */
stock JSN_TypeOf(const s[], const path[])
{
    new pos;
    if (!JSN_Seek(s, path, pos)) return JSN_TYPE_MISSING;

    new ch = s[pos];
    if (ch == '"') return JSN_TYPE_STRING;
    if (ch == '[') return JSN_TYPE_ARRAY;
    if (ch == '{') return JSN_TYPE_OBJECT;

    new word[8];
    if (ch == 't' || ch == 'f' || ch == 'n')
    {
        if (!JSN_CopyScalar(s, pos, word, sizeof word)) return JSN_TYPE_MISSING;
        if (strcmp(word, "true", false) == 0 || strcmp(word, "false", false) == 0) return JSN_TYPE_BOOL;
        if (strcmp(word, "null", false) == 0) return JSN_TYPE_NULL;
        return JSN_TYPE_MISSING;
    }

    new number[24];
    if (!JSN_CopyScalar(s, pos, number, sizeof number)) return JSN_TYPE_MISSING;
    if (JSN_IsInteger(number)) return JSN_TYPE_INT;
    if (JSN_IsNumber(number)) return JSN_TYPE_NUMBER;
    return JSN_TYPE_MISSING;
}

/** 1 when `kind` satisfies the type name, 0 when it does not, -1 when the name is unknown. */
stock JSN_TypeMatches(kind, const typeName[])
{
    if (strcmp(typeName, "any", false) == 0) return kind != JSN_TYPE_MISSING;
    if (strcmp(typeName, "string", false) == 0) return kind == JSN_TYPE_STRING;
    if (strcmp(typeName, "int", false) == 0) return kind == JSN_TYPE_INT;
    if (strcmp(typeName, "number", false) == 0) return kind == JSN_TYPE_INT || kind == JSN_TYPE_NUMBER;
    if (strcmp(typeName, "bool", false) == 0) return kind == JSN_TYPE_BOOL;
    if (strcmp(typeName, "array", false) == 0) return kind == JSN_TYPE_ARRAY;
    if (strcmp(typeName, "object", false) == 0) return kind == JSN_TYPE_OBJECT;
    if (strcmp(typeName, "null", false) == 0) return kind == JSN_TYPE_NULL;
    return -1;
}

stock JSN_SetError(dest[], size, const text[])
{
    if (size <= 0) return 0;
    new i = 0;
    for (; text[i] != '\0' && i < size - 1; i++) dest[i] = text[i];
    dest[i] = '\0';
    return 1;
}

/**
 * Reads one rule at `cursor`: `[?]path:type`. Returns 1 on a rule, 0 at the end,
 * -1 when the rule is malformed (no colon, empty path/type, or buffer overflow).
 */
stock JSN_NextRule(const rules[], &cursor, path[], pathSize, typeName[], typeSize, &optional)
{
    while (rules[cursor] == '|' || rules[cursor] == ' ' || rules[cursor] == '\t'
        || rules[cursor] == '\n' || rules[cursor] == '\r') cursor++;
    if (rules[cursor] == '\0') return 0;

    optional = 0;
    if (rules[cursor] == '?') { optional = 1; cursor++; }

    new p = 0;
    new t = 0;
    new seenColon = 0;
    new overflow = 0;

    while (rules[cursor] != '\0' && rules[cursor] != '|')
    {
        new ch = rules[cursor++];
        if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') continue;

        if (ch == ':' && !seenColon)
        {
            seenColon = 1;
            continue;
        }

        if (!seenColon)
        {
            if (p >= pathSize - 1) overflow = 1;
            else path[p++] = ch;
        }
        else
        {
            if (t >= typeSize - 1) overflow = 1;
            else typeName[t++] = ch;
        }
    }

    path[p] = '\0';
    typeName[t] = '\0';

    if (overflow || !seenColon || p == 0 || t == 0) return -1;
    return 1;
}

stock JSN_IsNumericKind(kind)
{
    return kind == JSN_TYPE_INT || kind == JSN_TYPE_NUMBER;
}

/** Parses the numeric bound in spec[start..end); integers stay exact. */
stock Float:JSN_ParseBound(const spec[], start, end)
{
    new text[24];
    new t = 0;
    for (new k = start; k < end; k++)
    {
        if (t >= sizeof text - 1) return 0.0;
        text[t++] = spec[k];
    }
    text[t] = '\0';
    return floatstr(text);
}

/**
 * Scans one bound at spec[i]: optional '-', digits, optional '.' + digits.
 * Returns the end index, or -1 when the shape is malformed. A bare '.' or a
 * trailing '.' ("1.", "1.2.3") is rejected rather than silently truncated.
 */
stock JSN_ScanBound(const spec[], i)
{
    if (spec[i] == '-') i++;

    new digits = i;
    while (spec[i] >= '0' && spec[i] <= '9') i++;
    if (i == digits) return -1;

    /* '.' belongs to the bound only when a fraction digit follows, otherwise it
     * is the first dot of the '..' range separator. */
    if (spec[i] == '.' && spec[i + 1] >= '0' && spec[i + 1] <= '9')
    {
        i++;
        while (spec[i] >= '0' && spec[i] <= '9') i++;
    }

    return i;
}

/**
 * Splits a type spec into its parts. Accepted shapes:
 *   "int"  "array<string>"  "int[0..10]"  "number[0.5..1.5]"  "array<int>"
 * Range bounds are decimal numbers (signs allowed), inclusive. Returns 0 when the
 * spec is malformed (unknown shape, nested element, reversed range, missing part).
 */
stock JSN_ParseTypeName(const spec[], base[], baseSize, element[], elementSize,
    &hasElement, &Float:minValue, &Float:maxValue, &hasRange)
{
    hasElement = 0;
    hasRange = 0;
    minValue = 0;
    maxValue = 0;
    element[0] = '\0';

    new i = 0;
    new b = 0;
    while (spec[i] != '\0' && spec[i] != '[' && spec[i] != '<')
    {
        if (b >= baseSize - 1) return 0;
        base[b++] = spec[i++];
    }
    base[b] = '\0';
    if (b == 0) return 0;

    if (spec[i] == '<')
    {
        i++;
        new e = 0;
        while (spec[i] != '\0' && spec[i] != '>')
        {
            new ch = spec[i];
            /* One level only: array<array<int>> is not supported. */
            if (ch == '<' || ch == '[' || ch == ']') return 0;
            if (e >= elementSize - 1) return 0;
            element[e++] = ch;
            i++;
        }
        element[e] = '\0';
        if (spec[i] != '>' || e == 0) return 0;
        i++;
        hasElement = 1;
    }

    if (spec[i] == '[')
    {
        i++;
        new start = i;
        new stop = JSN_ScanBound(spec, i);
        if (stop < 0) return 0;
        minValue = JSN_ParseBound(spec, start, stop);
        i = stop;

        if (spec[i] != '.' || spec[i + 1] != '.') return 0;
        i += 2;

        start = i;
        stop = JSN_ScanBound(spec, i);
        if (stop < 0) return 0;
        maxValue = JSN_ParseBound(spec, start, stop);
        i = stop;

        if (spec[i] != ']') return 0;
        i++;
        hasRange = 1;
    }

    if (spec[i] != '\0') return 0;
    if (hasElement && hasRange) return 0;      /* range on an array is meaningless */
    if (hasRange && minValue > maxValue) return 0;
    return 1;
}

stock JSN_InRange(const body[], const path[], kind, Float:minValue, Float:maxValue)
{
    if (kind == JSN_TYPE_INT)
    {
        new number;
        if (!JSN_GetInt(body, path, number)) return 0;
        return float(number) >= minValue && float(number) <= maxValue;
    }

    new Float:number;
    if (!JSN_GetFloat(body, path, number)) return 0;
    return number >= minValue && number <= maxValue;
}

/**
 * Checks every element of the array at `path`. Writes the failing element path
 * into `failed`. Element type names are validated by the caller.
 */
stock JSN_ElementsMatch(const body[], const path[], const elementType[], failed[], failedSize)
{
    new count = JSN_CountArray(body, path);
    if (count < 0) return 0;

    new elementPath[JSN_MAX_PATH];
    for (new i = 0; i < count; i++)
    {
        if (strlen(path) + 16 >= sizeof elementPath)
        {
            JSN_SetError(failed, failedSize, "@rule");
            return 0;
        }
        format(elementPath, sizeof elementPath, "%s.%d", path, i);

        new elementKind = JSN_TypeOf(body, elementPath);
        if (JSN_TypeMatches(elementKind, elementType) != 1)
        {
            JSN_SetError(failed, failedSize, elementPath);
            return 0;
        }
    }
    return 1;
}

/**
 * Checks a document against `path:type` rules. Optional rules start with '?'.
 *
 * Returns 1 when every rule holds. On failure it returns 0, writes the offending
 * path (or "@document" / "@rule") into `invalid`, and sets `reason` to
 * JSN_TYPE_MISSING (required field absent), the actual value kind on a type
 * mismatch, JSN_SCHEMA_BAD_RULE, or JSN_SCHEMA_BAD_DOC.
 *
 * Types: any, string, int, number (int or float), bool, array, object, null.
 * Nested fields are addressed with the same dotted paths as the readers; object
 * members are checked only for the paths you name.
 *
 * Two suffixes extend a type:
 *   array<string>   every element must have that type (one level, no nesting)
 *   int[0..100]     inclusive numeric bounds; allowed on int and number.
 *                   Bounds may be decimal (number[0.5..1.5]) and negative;
 *                   an int field is compared against them numerically.
 *
 * A typo in a type name, a nested array spec, a range on a non-numeric field,
 * or reversed bounds is a bad rule, never a pass.
 */
stock JSN_Validate(const body[], const rules[], invalid[], invalidSize, &reason)
{
    reason = 0;
    if (invalidSize > 0) invalid[0] = '\0';

    if (!JSN_DocumentComplete(body))
    {
        reason = JSN_SCHEMA_BAD_DOC;
        JSN_SetError(invalid, invalidSize, "@document");
        return 0;
    }

    new cursor = 0;
    new path[JSN_MAX_PATH];
    new typeName[JSN_MAX_TYPE];
    new optional;
    new step = 1;

    while (step > 0)
    {
        step = JSN_NextRule(rules, cursor, path, sizeof path, typeName, sizeof typeName, optional);
        if (step == 0) break;
        if (step < 0)
        {
            reason = JSN_SCHEMA_BAD_RULE;
            JSN_SetError(invalid, invalidSize, "@rule");
            return 0;
        }

        new kind = JSN_TypeOf(body, path);
        if (kind == JSN_TYPE_MISSING)
        {
            if (optional) continue;
            reason = JSN_TYPE_MISSING;
            JSN_SetError(invalid, invalidSize, path);
            return 0;
        }

        new baseType[16];
        new elementType[16];
        new hasElement;
        new hasRange;
        new Float:minValue;
        new Float:maxValue;

        if (!JSN_ParseTypeName(typeName, baseType, sizeof baseType, elementType, sizeof elementType,
                hasElement, minValue, maxValue, hasRange))
        {
            reason = JSN_SCHEMA_BAD_RULE;
            JSN_SetError(invalid, invalidSize, "@rule");
            return 0;
        }

        new matches = JSN_TypeMatches(kind, baseType);
        new elementKnown = 1;
        if (hasElement) elementKnown = JSN_TypeMatches(JSN_TYPE_STRING, elementType);

        if (matches < 0 || elementKnown < 0 || (hasRange && !JSN_IsNumericKind(kind))
            || (hasElement && strcmp(baseType, "array", false) != 0))
        {
            reason = JSN_SCHEMA_BAD_RULE;
            JSN_SetError(invalid, invalidSize, "@rule");
            return 0;
        }
        if (!matches)
        {
            reason = kind;
            JSN_SetError(invalid, invalidSize, path);
            return 0;
        }

        if (hasRange && !JSN_InRange(body, path, kind, minValue, maxValue))
        {
            reason = JSN_SCHEMA_OUT_OF_RANGE;
            JSN_SetError(invalid, invalidSize, path);
            return 0;
        }

        if (hasElement && !JSN_ElementsMatch(body, path, elementType, invalid, invalidSize))
        {
            reason = JSN_SCHEMA_BAD_ELEMENT;
            return 0;
        }
    }
    return 1;
}

/* ------------------------------------------------------------------------- *
 * Writer: escape text before putting it inside a JSON body                    *
 * ------------------------------------------------------------------------- */

stock JSN_HexDigit(value)
{
    if (value < 10) return '0' + value;
    return 'A' + (value - 10);
}

/**
 * Escapes `src` for use inside a JSON string. Never writes past `size - 1`.
 * Returns 1 when everything fit, 0 on truncation (check JSN_WasTruncated).
 */
stock JSN_Escape(dest[], size, const src[])
{
    if (size <= 0) return 0;
    dest[0] = '\0';

    new idx = 0;
    for (new i = 0; src[i] != '\0'; i++)
    {
        new ch = src[i];

        /* Worst case is \u00XX (6 chars) plus the terminator. */
        if (idx + 7 > size)
        {
            dest[idx] = '\0';
            gJSNTruncated = 1;
            return 0;
        }

        if (ch == '"' || ch == '\\')
        {
            dest[idx++] = '\\';
            dest[idx++] = ch;
        }
        else if (ch == '\n') { dest[idx++] = '\\'; dest[idx++] = 'n'; }
        else if (ch == '\r') { dest[idx++] = '\\'; dest[idx++] = 'r'; }
        else if (ch == '\t') { dest[idx++] = '\\'; dest[idx++] = 't'; }
        else if (ch < 0x20)
        {
            dest[idx++] = '\\';
            dest[idx++] = 'u';
            dest[idx++] = '0';
            dest[idx++] = '0';
            dest[idx++] = JSN_HexDigit((ch >> 4) & 0x0F);
            dest[idx++] = JSN_HexDigit(ch & 0x0F);
        }
        else
        {
            dest[idx++] = ch;
        }
    }

    dest[idx] = '\0';
    return 1;
}
