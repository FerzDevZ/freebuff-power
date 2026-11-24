---
name: samp-http-json-integration
description: Talk to an HTTP API from SA-MP/open.mp safely — async request lifecycle with a per-request token, player-disconnect races, timeouts/retry/backoff, secret handling, and a dependency-free bounded JSON reader/writer with UTF-8 surrogate pairs and light schema validation, compile- and run-verified (197 assertions, including a live HTTP round-trip on open.mp and 0 warnings on both targets).
---

# HTTP + JSON Integration (SA-MP / open.mp)

Two halves, deliberately separated:

| Half | Status | Why |
|---|---|---|
| JSON parse/build | **Tested code** — `resources/samp_json.inc` | Pure logic, no plugin, fully assertable |
| HTTP transport | **Procedure** — you must use the plugin actually installed | Transport APIs differ per plugin and per version; never copy a signature from memory |

## 1. Transport: pick what is really installed

There are three real options, and they are not equivalent:

| Option | Headers / HTTPS | Failure signal | Use when |
|---|---|---|---|
| **open.mp native `HTTP()`** — in core, no plugin | **no headers**, no timeout control | `HTTP()` returns 0, or `responseCode` is an `HTTP_ERROR_*` | public, token-free GET/HEAD |
| **`pawn-requests`** (Southclaws) | headers, HTTPS, methods, big bodies | `OnRequestFailure` callback | any authenticated API — this is the default choice |
| A component (open.mp `components/`) or older plugin | depends on the component | depends | you control the host and need pooling/proxying |

The catch that decides it: **the native has no way to send an `Authorization`
header.** Putting a token in the query string leaks it into logs and proxies, so
an authenticated API must use `pawn-requests` (or a component), not native HTTP.

### 1a. Native `HTTP()` (verified against open.mp 1.6.7.3218)

Signature, read from the installed `omp_http.inc`:

```pawn
native HTTP(index, HTTP_METHOD:method, const url[], const data[], const callback[]);
// methods: HTTP_GET, HTTP_POST, HTTP_HEAD
// errors:  HTTP_ERROR_BAD_HOST / NO_SOCKET / CANT_CONNECT / CANT_WRITE /
//          CONTENT_TOO_BIG / MALFORMED_RESPONSE, plus ordinary HTTP codes
```

`url` is passed **without** `http://`. The callback receives the request index,
the response code, and the body — confirmed by the live fixture in this skill:

```pawn
public OnGameModeInit()
{
    if (!HTTP(0, HTTP_GET, "127.0.0.1:7899/http-fixture.json", "", "OnApiResponse"))
    {
        // refused before the request started (bad host/socket)
    }
    return 1;
}

public OnApiResponse(index, responseCode, const data[])
{
    if (responseCode != 200) return HandleFailure(index, responseCode);
    if (!JSN_DocumentComplete(data)) return HandleFailure(index, 0);
    // ... JSN_Get* / JSN_Validate
    return 1;
}
```

Because there is no header support, also treat `HTTP_ERROR_*` codes as transport
failures, not as payload errors, and implement your own timeout (a timer that
marks the request dead) — the native offers none.

### 1b. `pawn-requests` (authenticated APIs)

Not present in the SA-MP SDK used to verify this skill, so the code below is
documented from the project's own README, not from memory. Install with sampctl:

```bash
sampctl package install Southclaws/pawn-requests
```

```pawn
#include <requests>

new RequestsClient:apiClient;

public OnGameModeInit()
{
    apiClient = RequestsClient("https://api.example.com/", RequestHeaders(
        "Authorization", "Bearer <token-from-config>",
        "Connection", "keep-alive"
    ));
    return 1;
}

RequestJSON(
    apiClient,
    "v1/account",
    HTTP_METHOD_GET,
    "OnAccountResponse",
    JsonObject("player", JsonInt(playerid)),
    .headers = RequestHeaders()
);

public OnAccountResponse(Request:id, E_HTTP_STATUS:status, Node:node)
{
    // node is the parsed JSON; JsonGetString/JsonGetInt/JsonGetBool take a key
    // and return 0 on success, non-zero on error (inverted vs this skill).
    return 1;
}

public OnRequestFailure(Request:id, errorCode, errorMessage[], len)
{
    printf("[http] request %d failed: %d %s", _:id, errorCode, errorMessage);
    return 1;
}
```

Notes that matter in production:

- `Request`/`RequestJSON` return a **`Request:` id that keeps incrementing** — do
  not index an array with it; map it (pawn-map or your own table) to the player
  or action that triggered it.
- Response status is `E_HTTP_STATUS`; helpers like `HTTP_STATUS_CREATED` exist.
- The library ships JSON helpers, but its getters use the opposite convention
  (0 = success). This skill's `JSN_*` API is 1 = success and never allocates, so
  mixing them invites inverted checks — pick one per codebase.
- HTTPS requires the plugin binary and libcurl on the host; verify the server
  actually loaded the plugin (`plugins` section of the log) before blaming code.

**Before writing a single call**, open the installed include and read the real
signature — argument order and enum names change between major versions:

```bash
grep -n "native\|#define" dependencies/requests/requests.inc | head -40
```

## 2. The lifecycle that survives real players

```text
player action ──▶ enqueue request (token) ──▶ callback(token, status, body)
                                              │
                        player still connected? ──no──▶ drop, free token
                                              │
                        status 2xx? ──no──▶ map to user-facing message
                                              │
                        JSN_DocumentComplete ──no──▶ treat as transport failure
                                              │
                        JSN_Get* ──absent──▶ do not apply partial data
                                              │
                                            apply
```

Rules that prevent the common failures:

1. **One token per request, stored server-side** (player id + purpose + nonce).
   Never trust an id echoed in the body.
2. **The player may be gone when the callback runs.** Check `IsPlayerConnected`
   and your token table before touching player state. The slot may already be
   reused by someone else — key on token, not on `playerid` alone.
3. **A 200 is not a success.** Validate the payload; an API error page can arrive
   with 200 and HTML.
4. **Never call HTTP from `OnPlayerUpdate` or a per-tick timer.** One request per
   user action, plus a hard per-player rate limit (e.g. 1 per 3 s, 5 per minute).
5. **Set a timeout** and treat expiry as failure; a hung request that retries
   forever drains the pool.
6. **Retry only idempotent work** on 5xx/timeout, with backoff and a cap. A POST
   that moves money must carry an idempotency key or must not be retried.
7. **Log the outcome** (status + token + duration), never the full body: it can
   contain tokens, emails, or player data.

## 3. Using the JSON reader

```pawn
#include <samp_json>

public OnApiResponse(token, status, const body[])
{
    if (status < 200 || status >= 300) return HandleFailure(token);

    JSN_ResetState();                     // clear the truncation flag

    new accountId;
    if (!JSN_GetInt(body, "data.account_id", accountId))
    {
        // Missing, wrong type, or the body was cut off. Do not fall back to 0:
        // 0 is a valid account id in most schemas.
        return HandleFailure(token);
    }

    new name[32];
    if (!JSN_GetString(body, "data.name", name, sizeof name))
    {
        return HandleFailure(token);
    }
    if (JSN_WasTruncated())
    {
        // The field did not fit our buffer. Store/log deliberately, or widen it.
        printf("[http] name truncated for account %d", accountId);
    }
    return 1;
}
```

Available readers (all return `1` on success, `0` when absent/mistyped):

| Call | Behaviour |
|---|---|
| `JSN_GetString(body, path, dest, size)` | decodes escapes; bounded; sets a truncation flag |
| `JSN_GetInt(body, path, &value)` | rejects `"42"` (quoted) and `1.5` — strict on purpose |
| `JSN_GetFloat(body, path, &Float:value)` | accepts integers too; validates the number shape |
| `JSN_GetBool(body, path, &value)` | accepts only unquoted `true`/`false` |
| `JSN_Has(body, path)` | path exists and points at a value |
| `JSN_CountArray(body, path)` | element count, `0` for empty, `-1` when not an array |
| `JSN_DocumentComplete(body)` | one complete value, nothing trailing |
| `JSN_TypeOf(body, path)` | `JSN_TYPE_*` kind, `JSN_TYPE_MISSING` when absent |
| `JSN_Validate(body, rules, invalid, size, &reason)` | shape check against a rule string (below) |

Path syntax is dotted, with numeric segments for arrays:

```text
"user.id"        → {"user":{"id":42}}
"tags.0"         → {"tags":["admin","dev"]}
"list.1.id"      → {"list":[{"id":1},{"id":2}]}
```

## 4. Why the parser is bounded (the part that keeps servers up)

- Every destination is limited by `size`; a copy that would overflow returns `0`
  and leaves a NUL-terminated string. There is no `strcat` onto an unmeasured
  buffer anywhere in the include.
- **A truncated body fails closed.** `JSN_DocumentComplete` requires exactly one
  complete value, so a response cut off mid-transfer does not yield a prefix
  value. This was found by the fixture: `{"a":1` used to return `1`.
- Strings are decoded without recursion; nesting is skipped with a depth counter,
  so a hostile `[[[[[[...` cannot exhaust the stack.
- **Surrogate pairs are combined.** `\uD83D\uDE00` becomes the 4-byte UTF-8
  sequence `F0 9F 98 80`, and the copy refuses to split it: if the destination
  cannot hold all 4 bytes plus the terminator, it fails with the truncation flag
  rather than writing half a character.
- A lone high surrogate, a lone low surrogate, and `\u0000` decode to `?`; the
  rest of the string survives. (`\u0000` must not reach a Pawn string — it would
  end it.) Mixed content keeps both sides: `A\uD83D\uDE00B` → 6 bytes.

## 5. Light schema validation (optional)

Guessing field-by-field gets old when a response has ten fields. `JSN_Validate`
checks them in one pass. The schema is a **string**, so it can live in config and
be changed without recompiling logic:

```pawn
new bad[96];
new reason;
if (!JSN_Validate(body,
        "ok:bool|user.id:int|user.name:string|user.balance:number|user.tags:array|?user.email:string",
        bad, sizeof bad, reason))
{
    // reason == JSN_TYPE_MISSING  -> required field absent        (bad = path)
    // reason == JSN_TYPE_NUMBER   -> present with the wrong kind  (bad = path)
    // reason == JSN_SCHEMA_BAD_DOC    -> body incomplete          (bad = "@document")
    // reason == JSN_SCHEMA_BAD_RULE   -> schema typo              (bad = "@rule")
    printf("[http] body rejected: %s (reason %d)", bad, reason);
    return 0;
}
```

Grammar:

```text
rules    := rule ('|' rule)*          whitespace and trailing '|' are ignored
rule     := ['?'] path ':' type       '?' = optional (absent is fine, wrong type is not)
path     := same dotted path as the readers   ("user.id", "list.1.id")
type     := base suffix*
base     := any | string | int | number | bool | array | object | null
suffix   := '[' number '..' number ']'    inclusive range, int and number only
          | '<' typeName '>'              array element type, one level
```

```pawn
"user.balance:number[0.5..1.5]"     // decimal bounds, inclusive
"user.level:int[1..100]"            // int compared numerically to the bounds
"count:int[-10..-1]"                // negative bounds
"user.tags:array<string>"           // every element must be a string
"?user.meta:array<object>"          // optional; elements still checked when present
```

Deliberate choices:

- `number` accepts integers; `int` rejects `1.5`. Money as a float is still a bug
  in your schema, not the parser's.
- An **unknown type name is a bad rule, never a pass** — a typo such as
  `id:integer` fails loudly instead of skipping the check.
- `any` still requires presence. It means "present, kind irrelevant".
- Bounds are decimal and inclusive, signs allowed: `number[0.5..1.5]`,
  `int[-10..-1]`. An `int` field is compared numerically against them, so
  `int[2.5..3.5]` accepts `3`. Only one level of element typing exists
  (`array<array<int>>` is a bad rule), and there are no string lengths, patterns,
  or float-precision guarantees.
- Named paths only, in the order you write them; the first failure wins.
- A body that is not one complete document fails as `@document` before any field
  is examined.

## 6. Building a request body

Never interpolate player text into JSON with `format` — one `"` in a name breaks
the request, and `\` lets an attacker inject fields.

```pawn
new safe[128];
if (!JSN_Escape(safe, sizeof safe, playerName))
{
    return 0;   // did not fit; do not send a half-escaped name
}

new body[256];
format(body, sizeof body, "{\"action\":\"link\",\"name\":\"%s\"}", safe);
```

`JSN_Escape` escapes `"`, `\`, newline, CR, tab, and every control byte below
0x20 (as `\u00XX`), and returns `0` instead of truncating silently.

## 7. Secrets and configuration

- The API token lives in the server config or environment — **never** in `.pwn`,
  never in a command line, never in a log line.
- Send it in a header, not in the query string: URLs end up in logs and proxies.
- HTTPS only. If the plugin cannot verify TLS, the token is exposed on the wire.
- One token per environment. A test server with production credentials is how
  test data lands in production.

## 8. Verification (real)

```bash
cd .agents/skills/samp-http-json-integration/resources

# open.mp target
pawncc demo_json_omp.pwn -i. -i"$OMP_STDLIB" -d3 -o/tmp/demo_json.ompx

# legacy 0.3.7 stdlib target
pawncc demo_json.pwn -i. -i"$SAMP_STDLIB" -i"$OMP_STDLIB" -d3 -o/tmp/demo_json.legacy.amx

# runtime: gamemodes/json.amx + main_scripts ["json 1"], then read the log
grep '\[JSON\]' log.txt
```

Expected: 0 warnings on both builds, `[JSON] 180 checks, 0 failed`, and for the
live HTTP fixture `[HTTP] 17 checks, 0 failed`. Verified on open.mp 1.6.7.3218;
the legacy build of `demo_http.pwn` is compile-only because 0.3.7 has no HTTP
native. `bin/self-test.sh` compiles both targets (stage 6) and **executes** every
fixture marked `// @runtime-suite` on a real omp-server (stage 7). Fixtures also
marked `// @runtime-needs: http` get a local `python3` HTTP server serving
`resources/http_fixture.json`, with the port handed over in
`scriptfiles/http_port.txt` (Pawn file natives resolve paths inside
`scriptfiles/`). The gate **skips explicitly** when pawncc, the stdlib, the
server binary, its components, or python3 are absent — a skip never counts as a
pass.

## 9. What this skill does not do

- It does not send requests for you: transport is native `HTTP()` (no headers) or
  `pawn-requests` (headers, HTTPS), and both have their own limits.
- Native `HTTP()` has no header support and no timeout — an authenticated call or
  a strict deadline needs a plugin/component.

- No streaming parser, no JSON pointer beyond dotted paths, no JSON
  patch/write into nested structures (you build the body with `format` +
  `JSN_Escape`), and no full JSON Schema (no patterns, string lengths, or
  nested element types).
- No number precision beyond Pawn's `Float` (24-bit mantissa — **never store
  money as a float**; use integer cents).

## Runtime (open.mp)

- **open.mp server**: v1.6.7.3218 (latest stable, Oct 2026)
- **pawncc**: 3.10.10+ (open.mp compiler, `-Z` for warnings-as-errors)
- **Streamer Plugin**: v2.9.6+ (Incognito) for dynamic objects/areas/pickups
- **MySQL Plugin**: R41-4 (BlueG) or `mysql` component (open.mp native)
- **YSI 5.x**: y_commands, y_hooks, y_iterate, y_bit, y_inline, y_timers, y_groups
- **ColAndreas**: v1.5.0+ for collision/raycasting
- **SA-MP Legacy**: 0.3.7-R2 / 0.3.DL (backward compat)

### Compile Check (Gate)
```bash
# open.mp
pawncc -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn

# legacy (0.3.7)
pawncc -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn
```
Zero warnings, zero errors required.

