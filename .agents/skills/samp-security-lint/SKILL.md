---
name: samp-security-lint
description: Static security lint for SA-MP/open.mp Pawn — flags client text used as a format string, mysql_format %s interpolation, unguarded OnDialogResponse, deprecated pool-size loops, and weak RCON, with a two-way corpus that pins both true positives and false positives and runs in bin/self-test.sh.
---

# SA-MP/open.mp security lint

Advice cannot fail; a lint rule can. This skill ships `bin/samp-lint.js` and a
corpus where every file declares what it must (or must not) trigger, so a rule
that starts flagging safe code breaks the build.

## Rules

| Rule | Severity | Fires on | Fix |
|---|---|---|---|
| `format-injection` | error | `format(buf, size, inputtext/cmdtext/params/text/name, ...)` | `format(buf, size, "%s", value)` |
| `mysql-percent-s` | error | `mysql_format(..., "…%s…")` | `%e` for strings, `%d`/`%f` for numbers |
| `dialog-unguarded` | error | `OnDialogResponse` with no comparison/switch/guard on `dialogid` | compare against the tracked dialog, or use `samp_dialog_guard.inc` |
| `dialog-unguarded` | warning | id checked but `listitem` used with no bounds test | `if (listitem < 0 \|\| listitem >= count) return 1;` |
| `poolsize-loop` | warning | `GetPlayerPoolSize()` / `GetVehiclePoolSize()` as a bound | `MAX_PLAYERS` (or `foreach`); those names are deprecated `stock` shims in open.mp |
| `weak-rcon` | error | `config.json` with an `rcon` block whose password is < 8 chars or a known default, `server.cfg` `rcon_password` likewise | long random password, RCON not public |

A `config.json` **without** an `rcon` block is tooling config, not a server, and
is ignored — that distinction is pinned by the corpus.

## Usage

```bash
node bin/samp-lint.js gamemodes/
node bin/samp-lint.js gamemodes/ --json --fail-on=error
node bin/samp-lint.js .agents/skills --fail-on=error   # corpus excluded by default
node bin/samp-lint.js path/to/config.json
```

Exit code: `1` when `--fail-on=error` (default) finds an error, or
`--fail-on=warning` finds anything. Directories named `corpus` are skipped unless
`--include-corpus` is passed, so the deliberately vulnerable samples never fail a
normal scan.

## Corpus contract

```
corpus/
  expectations.json          # relative path -> exact rule ids expected
  vulnerable/                # each file must trigger exactly its rules
  clean/                     # each file must trigger nothing
```

`bin/samp-lint.test.js` runs every entry, compares the **rule set** (not just a
count), and then scans `.agents/skills` expecting zero error-level findings. When
adding a rule you must add both a vulnerable sample and a clean counterexample;
a rule with only a positive sample is not accepted.

## What this is not

- No dataflow analysis: it does not follow a value from `inputtext` through three
  functions into `format`. Macros are not expanded.
- It only understands the two MySQL call shapes shown above; ORM wrappers and
  custom query builders are invisible to it.
- It cannot see runtime state: a dialog that is validated in one branch and
  handled in another may still be exploitable.
- `weak-rcon` judges only obvious defaults and length, not entropy.

Use `@samp-security-hardener` for threat reasoning and this lint for the
mechanical, repeatable part.

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

