// Compile + assertion fixture for samp_json.inc.
// @runtime-suite
// Body is shared by both targets: demo_json_omp.pwn defines OMP_BUILD first.
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include <samp_json>

// Self-contained assertions so this fixture compiles alone. In a gamemode,
// forward these to samp-testing-harness instead.
new gChecks;
new gFailures;

stock Test(condition, const label[])
{
    gChecks++;
    if (condition) return 1;
    gFailures++;
    printf("[JSON] FAIL: %s", label);
    return 0;
}

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;
    gFailures++;
    printf("[JSON] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

stock TestFloat(Float:expected, Float:actual, const label[])
{
    gChecks++;
    if (floatcmp(expected, actual) == 0) return 1;
    gFailures++;
    printf("[JSON] FAIL: %s (expected %.3f, got %.3f)", label, expected, actual);
    return 0;
}

// Pawn does not concatenate adjacent string literals, so the document is one line.
static const SAMPLE[] = "{\"ok\":true,\"count\":3,\"user\":{\"id\":42,\"name\":\"Buffy \\\"B\\\" Summers\",\"level\":7,\"balance\":1234.5,\"vip\":false,\"tags\":[\"admin\",\"dev\",\"test\"],\"last\":\"line1\\nline2\"}}";

stock TestScalars()
{
    new value = 0;

    TestInt(1, JSN_GetInt(SAMPLE, "user.id", value), "read nested int");
    TestInt(42, value, "nested int value");

    TestInt(1, JSN_GetInt(SAMPLE, "count", value), "read root int");
    TestInt(3, value, "root int value");

    TestInt(0, JSN_GetInt(SAMPLE, "user.missing", value), "missing key returns 0");
    TestInt(0, JSN_GetInt(SAMPLE, "user.name", value), "string is not accepted as int");
    TestInt(0, JSN_GetInt(SAMPLE, "user.balance", value), "float is not accepted as int");

    new Float:amount = 0.0;
    TestInt(1, JSN_GetFloat(SAMPLE, "user.balance", amount), "read float");
    TestFloat(1234.5, amount, "float value");
    TestInt(1, JSN_GetFloat(SAMPLE, "user.level", amount), "integer is a valid float");
    TestFloat(7.0, amount, "integer-as-float value");
    TestInt(0, JSN_GetFloat(SAMPLE, "user.name", amount), "string is not accepted as float");

    new flag = -1;
    TestInt(1, JSN_GetBool(SAMPLE, "ok", flag), "read true");
    TestInt(1, flag, "true is 1");
    TestInt(1, JSN_GetBool(SAMPLE, "user.vip", flag), "read false");
    TestInt(0, flag, "false is 0");
    TestInt(0, JSN_GetBool(SAMPLE, "count", flag), "number is not a boolean");

    TestInt(1, JSN_Has(SAMPLE, "user.tags"), "has existing path");
    TestInt(0, JSN_Has(SAMPLE, "user.nope"), "has missing path");
    TestInt(1, JSN_Has(SAMPLE, ""), "root document exists");
    new root[8];
    TestInt(0, JSN_GetString(SAMPLE, "", root, sizeof root), "root object is not a string");
}

stock TestStrings()
{
    new name[64];

    TestInt(1, JSN_GetString(SAMPLE, "user.name", name, sizeof name), "read string");
    Test(strcmp(name, "Buffy \"B\" Summers", false) == 0, "escaped quotes decoded");

    TestInt(1, JSN_GetString(SAMPLE, "user.last", name, sizeof name), "read string with escape");
    TestInt(11, strlen(name), "newline escape becomes one byte");
    Test(name[5] == '\n', "newline decoded at position 5");

    TestInt(1, JSN_GetString(SAMPLE, "user.tags.0", name, sizeof name), "array index 0");
    Test(strcmp(name, "admin", false) == 0, "array element 0");
    TestInt(1, JSN_GetString(SAMPLE, "user.tags.2", name, sizeof name), "array index 2");
    Test(strcmp(name, "test", false) == 0, "array element 2");

    TestInt(0, JSN_GetString(SAMPLE, "user.tags.9", name, sizeof name), "array index past end");
    TestInt(0, JSN_GetString(SAMPLE, "user.tags.x", name, sizeof name), "non-numeric index rejected");
    TestInt(0, JSN_GetString(SAMPLE, "user.id", name, sizeof name), "number is not accepted as string");

    // Bounded copy: a destination smaller than the value must fail, not overflow.
    new small[5];
    JSN_ResetState();
    TestInt(0, JSN_GetString(SAMPLE, "user.name", small, sizeof small), "small destination fails");
    TestInt(1, JSN_WasTruncated(), "truncation flag set");
    TestInt(4, strlen(small), "destination stays NUL-terminated");
    JSN_ResetState();
    TestInt(0, JSN_WasTruncated(), "reset clears truncation flag");

    // \uXXXX for a BMP character becomes UTF-8 (Café, 2 bytes for e-acute).
    new doc[64];
    format(doc, sizeof doc, "{\"city\":\"Caf\\u00e9\"}");
    new city[16];
    TestInt(1, JSN_GetString(doc, "city", city, sizeof city), "unicode escape decoded");
    TestInt(5, strlen(city), "two-byte UTF-8 sequence");
    TestInt(195, city[3], "first UTF-8 byte");
    TestInt(169, city[4], "second UTF-8 byte");
}

stock TestArrays()
{
    TestInt(3, JSN_CountArray(SAMPLE, "user.tags"), "count array elements");
    TestInt(-1, JSN_CountArray(SAMPLE, "user"), "object is not an array");
    TestInt(-1, JSN_CountArray(SAMPLE, "missing"), "missing path is not an array");

    static const EMPTY[] = "{\"list\":[]}";
    TestInt(0, JSN_CountArray(EMPTY, "list"), "empty array counts 0");

    static const OBJECTS[] = "{\"list\":[{\"id\":1},{\"id\":2,\"name\":\"two\"}]}";
    new value = 0;
    TestInt(1, JSN_GetInt(OBJECTS, "list.0.id", value), "read through array of objects");
    TestInt(1, value, "first object id");
    TestInt(1, JSN_GetInt(OBJECTS, "list.1.id", value), "read second object");
    TestInt(2, value, "second object id");

    new name[16];
    TestInt(1, JSN_GetString(OBJECTS, "list.1.name", name, sizeof name), "read second object string");
    Test(strcmp(name, "two", false) == 0, "second object string value");
    TestInt(0, JSN_GetInt(OBJECTS, "list.5.id", value), "object array index past end");
}

stock TestEdgeCases()
{
    new value = 0;
    new text[16];

    static const NEGATIVE[] = "{\"n\":-15}";
    TestInt(1, JSN_GetInt(NEGATIVE, "n", value), "read negative int");
    TestInt(-15, value, "negative int value");

    static const SPACED[] = "{ \"a\" : 1 , \"b\" : 2 }";
    TestInt(1, JSN_GetInt(SPACED, "b", value), "whitespace between tokens tolerated");
    TestInt(2, value, "whitespace document value");

    static const SLASHED[] = "{\"u\":\"a\\/b\"}";
    TestInt(1, JSN_GetString(SLASHED, "u", text, sizeof text), "read escaped slash");
    Test(strcmp(text, "a/b", false) == 0, "escaped slash decoded");

    static const QUOTED_NUMBER[] = "{\"s\":\"42\"}";
    TestInt(0, JSN_GetInt(QUOTED_NUMBER, "s", value), "quoted number rejected as int");

    // Fail closed on damaged bodies instead of reading garbage.
    static const NO_CLOSE[] = "{\"a\":1";
    TestInt(0, JSN_GetInt(NO_CLOSE, "a", value), "unterminated object fails closed");

    static const BROKEN_STRING[] = "{\"a\":\"oops";
    TestInt(0, JSN_GetString(BROKEN_STRING, "a", text, sizeof text), "unterminated string fails closed");

    static const BROKEN_VALUE[] = "{\"a\":}";
    TestInt(0, JSN_Has(BROKEN_VALUE, "a"), "missing value fails closed");

    static const EMPTY_DOC[] = "";
    TestInt(0, JSN_Has(EMPTY_DOC, "a"), "empty body fails closed");

    static const BAD_INDEX[] = "{\"a\":[1,2]}";
    TestInt(0, JSN_GetInt(BAD_INDEX, "a.-1", value), "negative index rejected");
}

stock TestEscape()
{
    new escaped[96];
    new src[64];

    format(src, sizeof src, "he said \"hi\"\npath\\to");

    JSN_ResetState();
    TestInt(1, JSN_Escape(escaped, sizeof escaped, src), "escape fits");
    Test(strfind(escaped, "\\\"hi\\\"") >= 0, "quotes escaped");
    Test(strfind(escaped, "\\n") >= 0, "newline escaped");
    Test(strfind(escaped, "\\\\to") >= 0, "backslash escaped");

    new doc[160];
    format(doc, sizeof doc, "{\"m\":\"%s\"}", escaped);
    new roundtrip[64];
    TestInt(1, JSN_GetString(doc, "m", roundtrip, sizeof roundtrip), "escaped body is parseable");
    Test(strcmp(roundtrip, src, false) == 0, "escape roundtrip preserves content");

    new control[8];
    control[0] = 1;
    control[1] = 'A';
    control[2] = '\0';
    TestInt(1, JSN_Escape(escaped, sizeof escaped, control), "control char escaped");
    Test(strcmp(escaped, "\\u0001A", false) == 0, "control char becomes \\u0001");

    new tiny[8];
    JSN_ResetState();
    TestInt(0, JSN_Escape(tiny, sizeof tiny, src), "tiny destination truncates");
    TestInt(1, JSN_WasTruncated(), "escape sets truncation flag");
    Test(strlen(tiny) < sizeof tiny, "escaped output stays bounded");
}

stock TestUnicode()
{
    new text[32];

    // U+1F600 encoded as a surrogate pair must become one 4-byte sequence.
    static const EMOJI[] = "{\"e\":\"\\uD83D\\uDE00\"}";
    TestInt(1, JSN_GetString(EMOJI, "e", text, sizeof text), "surrogate pair decoded");
    TestInt(4, strlen(text), "pair becomes four UTF-8 bytes");
    TestInt(240, text[0], "byte 0 of U+1F600");
    TestInt(159, text[1], "byte 1 of U+1F600");
    TestInt(152, text[2], "byte 2 of U+1F600");
    TestInt(128, text[3], "byte 3 of U+1F600");

    // A pair next to plain text keeps both sides intact.
    static const MIXED[] = "{\"e\":\"A\\uD83D\\uDE00B\"}";
    TestInt(1, JSN_GetString(MIXED, "e", text, sizeof text), "pair with surrounding text");
    TestInt(6, strlen(text), "surrounding text preserved");
    Test(text[0] == 'A' && text[5] == 'B', "text on both sides of the pair");

    // Lone or malformed surrogates degrade to '?' instead of eating the string.
    static const LONE_HIGH[] = "{\"e\":\"\\uD83D\"}";
    TestInt(1, JSN_GetString(LONE_HIGH, "e", text, sizeof text), "lone high surrogate still parses");
    TestInt(1, strlen(text), "lone high surrogate is one replacement char");
    Test(text[0] == '?', "lone high surrogate becomes '?'");

    static const LONE_LOW[] = "{\"e\":\"\\uDE00\"}";
    TestInt(1, JSN_GetString(LONE_LOW, "e", text, sizeof text), "lone low surrogate still parses");
    Test(text[0] == '?' && text[1] == '\0', "lone low surrogate becomes '?'");

    static const HIGH_THEN_PLAIN[] = "{\"e\":\"\\uD83D\\u0041\"}";
    TestInt(1, JSN_GetString(HIGH_THEN_PLAIN, "e", text, sizeof text), "high surrogate then plain escape");
    Test(strcmp(text, "?A", false) == 0, "high surrogate replaced, following char kept");

    // A NUL escape would end the Pawn string, so it becomes '?' too.
    static const NUL_ESCAPE[] = "{\"n\":\"a\\u0000b\"}";
    TestInt(1, JSN_GetString(NUL_ESCAPE, "n", text, sizeof text), "NUL escape still parses");
    Test(strcmp(text, "a?b", false) == 0, "NUL escape becomes '?' and keeps the tail");

    // A destination that cannot hold the 4 bytes must fail, not cut mid-sequence.
    new tiny[4];
    JSN_ResetState();
    TestInt(0, JSN_GetString(EMOJI, "e", tiny, sizeof tiny), "4-byte char does not fit in 4 cells");
    TestInt(1, JSN_WasTruncated(), "truncation flag set for 4-byte char");
    TestInt(0, strlen(tiny), "destination left empty and terminated");
    JSN_ResetState();
}

stock TestSchema()
{
    new bad[64];
    new reason;

    // Complete rule set for the sample document.
    static const RULES[] = "ok:bool|count:int|user.id:int|user.name:string|user.balance:number|user.tags:array|user:object";
    TestInt(1, JSN_Validate(SAMPLE, RULES, bad, sizeof bad, reason), "valid document passes schema");
    TestInt(0, reason, "passing schema leaves reason 0");
    Test(bad[0] == '\0', "passing schema leaves invalid empty");

    // `number` accepts an integer; `int` rejects a float.
    TestInt(1, JSN_Validate(SAMPLE, "count:number", bad, sizeof bad, reason), "int satisfies number rule");
    TestInt(0, JSN_Validate(SAMPLE, "user.balance:int", bad, sizeof bad, reason), "float rejected by int rule");
    TestInt(JSN_TYPE_NUMBER, reason, "float mismatch reports its kind");
    Test(strcmp(bad, "user.balance", false) == 0, "float mismatch reports the path");

    // Required vs optional.
    TestInt(0, JSN_Validate(SAMPLE, "user.missing:string", bad, sizeof bad, reason), "missing required field fails");
    TestInt(JSN_TYPE_MISSING, reason, "missing field reports JSN_TYPE_MISSING");
    Test(strcmp(bad, "user.missing", false) == 0, "missing field reported by path");
    TestInt(1, JSN_Validate(SAMPLE, "?user.missing:string", bad, sizeof bad, reason), "optional field may be absent");
    TestInt(0, JSN_Validate(SAMPLE, "?user.name:int", bad, sizeof bad, reason), "optional field is still type-checked");
    TestInt(1, JSN_Validate(SAMPLE, "ok:bool | count:int |", bad, sizeof bad, reason), "spaces and trailing pipe tolerated");

    // Schema mistakes are configuration errors, never silent passes.
    TestInt(0, JSN_Validate(SAMPLE, "ok", bad, sizeof bad, reason), "rule without colon rejected");
    TestInt(JSN_SCHEMA_BAD_RULE, reason, "malformed rule reports JSN_SCHEMA_BAD_RULE");
    Test(strcmp(bad, "@rule", false) == 0, "malformed rule reported as @rule");
    TestInt(0, JSN_Validate(SAMPLE, "ok:boolean", bad, sizeof bad, reason), "unknown type name rejected");
    TestInt(JSN_SCHEMA_BAD_RULE, reason, "unknown type reports bad rule, not a pass");
    TestInt(0, JSN_Validate(SAMPLE, ":int", bad, sizeof bad, reason), "empty path rejected");

    // A body cut off mid-transfer is a document error, not a field error.
    static const CUT[] = "{\"a\":1";
    TestInt(0, JSN_Validate(CUT, "a:int", bad, sizeof bad, reason), "incomplete document fails validation");
    TestInt(JSN_SCHEMA_BAD_DOC, reason, "incomplete document reports JSN_SCHEMA_BAD_DOC");
    Test(strcmp(bad, "@document", false) == 0, "incomplete document reported as @document");

    // Empty rule string requires nothing; null and any behave as documented.
    TestInt(1, JSN_Validate(SAMPLE, "", bad, sizeof bad, reason), "empty rule string passes");
    static const NULL_DOC[] = "{\"n\":null}";
    TestInt(1, JSN_Validate(NULL_DOC, "n:null", bad, sizeof bad, reason), "null matches null rule");
    TestInt(0, JSN_Validate(NULL_DOC, "n:string", bad, sizeof bad, reason), "null rejected by string rule");
    TestInt(JSN_TYPE_NULL, reason, "null mismatch reports JSN_TYPE_NULL");
    TestInt(1, JSN_Validate(SAMPLE, "count:any", bad, sizeof bad, reason), "any accepts a present value");
    TestInt(0, JSN_Validate(SAMPLE, "missing:any", bad, sizeof bad, reason), "any still requires presence");

    // Kind classification used by the rules.
    TestInt(JSN_TYPE_INT, JSN_TypeOf(SAMPLE, "user.id"), "typeof int");
    TestInt(JSN_TYPE_STRING, JSN_TypeOf(SAMPLE, "user.name"), "typeof string");
    TestInt(JSN_TYPE_NUMBER, JSN_TypeOf(SAMPLE, "user.balance"), "typeof number");
    TestInt(JSN_TYPE_BOOL, JSN_TypeOf(SAMPLE, "user.vip"), "typeof bool");
    TestInt(JSN_TYPE_ARRAY, JSN_TypeOf(SAMPLE, "user.tags"), "typeof array");
    TestInt(JSN_TYPE_OBJECT, JSN_TypeOf(SAMPLE, "user"), "typeof object");
    TestInt(JSN_TYPE_MISSING, JSN_TypeOf(SAMPLE, "nope"), "typeof missing");
}

stock TestSchemaExtras()
{
    new bad[64];
    new reason;

    // --- array element types -------------------------------------------------
    TestInt(1, JSN_Validate(SAMPLE, "user.tags:array<string>", bad, sizeof bad, reason), "array<string> passes");
    TestInt(0, JSN_Validate(SAMPLE, "user.tags:array<int>", bad, sizeof bad, reason), "array<int> rejects strings");
    TestInt(JSN_SCHEMA_BAD_ELEMENT, reason, "element mismatch reports JSN_SCHEMA_BAD_ELEMENT");
    Test(strcmp(bad, "user.tags.0", false) == 0, "element mismatch reports the element path");
    TestInt(1, JSN_Validate(SAMPLE, "user.tags:array<any>", bad, sizeof bad, reason), "array<any> accepts any kind");

    static const OBJECTS[] = "{\"list\":[{\"id\":1},{\"id\":2,\"name\":\"two\"}]}";
    TestInt(1, JSN_Validate(OBJECTS, "list:array<object>", bad, sizeof bad, reason), "array<object> passes");
    TestInt(0, JSN_Validate(OBJECTS, "list:array<string>", bad, sizeof bad, reason), "array<string> rejects objects");
    Test(strcmp(bad, "list.0", false) == 0, "first wrong element is reported");

    TestInt(0, JSN_Validate(SAMPLE, "user.tags:array<array<int>>", bad, sizeof bad, reason), "nested element spec rejected");
    TestInt(JSN_SCHEMA_BAD_RULE, reason, "nested element spec is a bad rule");
    TestInt(0, JSN_Validate(SAMPLE, "user.tags:array<bogus>", bad, sizeof bad, reason), "unknown element type rejected");
    TestInt(0, JSN_Validate(SAMPLE, "user.tags:array<int>[0..2]", bad, sizeof bad, reason), "range on array rejected");
    TestInt(0, JSN_Validate(SAMPLE, "user.name:array<string>", bad, sizeof bad, reason), "element spec on non-array fails");
    TestInt(JSN_TYPE_STRING, reason, "non-array element spec reports the actual kind");
    TestInt(1, JSN_Validate(SAMPLE, "?user.missing:array<string>", bad, sizeof bad, reason), "optional array may be absent");

    // --- numeric ranges ------------------------------------------------------
    TestInt(1, JSN_Validate(SAMPLE, "count:int[1..5]", bad, sizeof bad, reason), "value inside range passes");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[5..9]", bad, sizeof bad, reason), "value below range fails");
    TestInt(JSN_SCHEMA_OUT_OF_RANGE, reason, "range failure reports JSN_SCHEMA_OUT_OF_RANGE");
    Test(strcmp(bad, "count", false) == 0, "range failure reports the path");
    TestInt(1, JSN_Validate(SAMPLE, "count:int[3..3]", bad, sizeof bad, reason), "bounds are inclusive");
    TestInt(1, JSN_Validate(SAMPLE, "user.level:int[0..100]", bad, sizeof bad, reason), "range on nested int");
    TestInt(1, JSN_Validate(SAMPLE, "user.balance:number[1000..2000]", bad, sizeof bad, reason), "range on float field");
    TestInt(0, JSN_Validate(SAMPLE, "user.balance:number[0..100]", bad, sizeof bad, reason), "float outside range fails");

    // Type checking runs before the range, and int rules still reject floats.
    TestInt(0, JSN_Validate(SAMPLE, "user.balance:int[0..2000]", bad, sizeof bad, reason), "int rule rejects float before range");
    TestInt(JSN_TYPE_NUMBER, reason, "float reports its kind, not a range error");

    static const NEGATIVE[] = "{\"n\":-15}";
    TestInt(1, JSN_Validate(NEGATIVE, "n:int[-20..-10]", bad, sizeof bad, reason), "negative range passes");
    TestInt(0, JSN_Validate(NEGATIVE, "n:int[-5..5]", bad, sizeof bad, reason), "negative value outside range fails");

    // --- decimal bounds ------------------------------------------------------
    TestInt(1, JSN_Validate(SAMPLE, "user.balance:number[1234.5..1234.5]", bad, sizeof bad, reason), "exact decimal bound is inclusive");
    TestInt(1, JSN_Validate(SAMPLE, "user.balance:number[1234.4..1234.6]", bad, sizeof bad, reason), "value inside decimal range passes");
    TestInt(0, JSN_Validate(SAMPLE, "user.balance:number[1234.6..1240]", bad, sizeof bad, reason), "value outside decimal range fails");
    TestInt(JSN_SCHEMA_OUT_OF_RANGE, reason, "decimal range failure reports JSN_SCHEMA_OUT_OF_RANGE");
    TestInt(1, JSN_Validate(SAMPLE, "user.balance:number[1234.50..1240]", bad, sizeof bad, reason), "trailing zero in bound tolerated");

    // An int field is compared numerically against a decimal bound.
    TestInt(1, JSN_Validate(SAMPLE, "count:int[2.5..3.5]", bad, sizeof bad, reason), "int compared to decimal bounds");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[3.5..9]", bad, sizeof bad, reason), "int below decimal lower bound fails");

    static const NEG_DECIMAL[] = "{\"n\":-15.25}";
    TestInt(1, JSN_Validate(NEG_DECIMAL, "n:number[-15.3..-15.2]", bad, sizeof bad, reason), "negative decimal range passes");
    TestInt(0, JSN_Validate(NEG_DECIMAL, "n:number[-15.2..-15]", bad, sizeof bad, reason), "negative decimal outside range fails");

    // A broken decimal is a schema mistake, not a truncated number.
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1..5.5.5]", bad, sizeof bad, reason), "double decimal point rejected");
    TestInt(JSN_SCHEMA_BAD_RULE, reason, "double decimal point is a bad rule");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1.5..1]", bad, sizeof bad, reason), "reversed decimal bounds rejected");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1..5.]", bad, sizeof bad, reason), "trailing decimal point rejected");

    // Malformed bounds are schema errors, never silent passes.
    TestInt(0, JSN_Validate(SAMPLE, "user.name:string[0..5]", bad, sizeof bad, reason), "range on string rejected");
    TestInt(JSN_SCHEMA_BAD_RULE, reason, "range on string is a bad rule");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[5..1]", bad, sizeof bad, reason), "reversed bounds rejected");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1..]", bad, sizeof bad, reason), "open upper bound rejected");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[..5]", bad, sizeof bad, reason), "open lower bound rejected");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1...5]", bad, sizeof bad, reason), "triple dot rejected");
    TestInt(0, JSN_Validate(SAMPLE, "count:int[1..5", bad, sizeof bad, reason), "unclosed range rejected");
    TestInt(1, JSN_Validate(SAMPLE, "?user.missing:int[0..5]", bad, sizeof bad, reason), "optional range may be absent");
    TestInt(1, JSN_Validate(SAMPLE, "user.tags:array<string>|count:int[1..5]", bad, sizeof bad, reason), "element and range rules combine");
}

public OnGameModeInit()
{
    TestScalars();
    TestStrings();
    TestArrays();
    TestEdgeCases();
    TestEscape();
    TestUnicode();
    TestSchema();
    TestSchemaExtras();

    printf("[JSON] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
