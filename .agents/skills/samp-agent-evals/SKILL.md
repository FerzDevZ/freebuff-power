---
name: samp-agent-evals
description: Decision evals for SA-MP/open.mp agents — scenario packs that ask one grading question each (target verdict, security rule, severity), a harness that runs the deterministic toolchain or grades captured agent answers, and a pass rate that fails the build below 100%.
---

# SA-MP/open.mp agent decision evals

Agents in this repo are trusted to classify legacy vs open.mp code and to spot
the exploit patterns in `samp-security-lint`. Trust is not evidence. This skill
turns those decisions into scenarios with a right answer, then measures whether
the decision layer (or a captured agent) reaches it.

## Modes

```bash
node bin/samp-agent-evals.js                 # toolchain: run samp-detect + samp-lint
node bin/samp-agent-evals.js --json
node bin/samp-agent-evals.js --template      # prompt skeleton for an agent
node bin/samp-agent-evals.js --answers a.json  # grade captured answers
node bin/samp-agent-evals.js --min=0.9       # allow a lower bar
```

- **toolchain mode** proves the deterministic decision layer still produces the
  expected verdict, error count, and rule set.
- **answers mode** grades `{ "answers": { "<scenario>": { "verdict": "...",
  "errorFindings": 0, "rules": [...] } } }`. Only the keys present in the
  scenario's `meta.json` are compared. This is how a real agent is evaluated: give
  it `--template` (the `ask` field is the prompt), collect its JSON, score it.
- Exit code is `1` when the pass rate is below `--min` (default 1.0).

## Scenario contract

```
scenarios/<id>/
  case.pwn | config.json | server.cfg   # the code under judgement
  meta.json                             # ask + expected decisions
```

```json
{ "ask": "Target file ini apa, dan apakah akan lolos compile di target itu?",
  "verdict": "LEGACY", "errorFindings": 1, "rules": [] }
```

`verdict` is compared against `samp-detect`, `errorFindings` counts only
error-level findings, and `rules` must match the rule-id set from `samp-lint`
exactly (extra or missing rules both fail). Omit a key when that dimension is not
what the scenario tests.

Current pack (14 scenarios): legacy file calling a modern native, open.mp file
using a removed native, `SAMP_COMPAT`, dual-target branches, unguarded mixed
includes, include-less library, format injection, `%s` in `mysql_format`,
unguarded dialog, deprecated pool-size loop, weak RCON, clean modern, clean
legacy, and a shared native that does **not** prove a modern target.

## Adding a scenario

1. Put the smallest file that isolates one decision in `scenarios/<id>/`.
2. Write `meta.json` with the expected verdict/rules — derive them by reading
   `docs/NATIVE-PARITY.md` and `bin/samp-lint.js`, never from memory.
3. Run the harness. A failure is either a wrong expectation (fix the meta) or a
   real toolchain bug (fix the tool). Do not loosen the expectation to pass.
4. `npm test` runs the pack in stage 9, so a regression fails the build.

## Limits

- No LLM call: answers mode grades a file someone must capture. The harness cannot
  make an agent answer, only judge it.
- Scenarios are pinned to the installed stdlib matrix; regenerating
  `bin/data/native-ownership.json` from a different 0.3.7 copy can change verdicts.
- Thirteen of fourteen scenarios are single-decision; none exercise multi-file
  reasoning or runtime behaviour.

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

