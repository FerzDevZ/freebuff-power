# bin/ — repo tooling

| Script | Purpose |
|---|---|
| `self-test.sh` | The repo gate (28 checks): Pawn fixtures on both targets, TD/YSI/HUD examples, Node tooling, runtime suite, parity matrix. Run with `./bin/self-test.sh`. |
| `ysi-ensure.sh` | Install YSI 5 + amx_assembly via `sampctl get` when missing (`--global` for shared cache, `--no-patch` to skip). Idempotent. |
| `ysi-linux-patch.sh` | Rewrite YSI's backslash includes into `.sdk/ysi`, fetch deps, flatten them, and compile a probe (`--verify`). |
| `samp-detect.js` | Target verdict for a Pawn file (open.mp vs legacy). |
| `samp-audit.sh` | Anti-pattern audit v2. |
| `samp-lint.js` | Security lint. |
| `samp-td-preview.js` | 16:9 HTML render of PlayerTextDraws (fails on 0 parsed elements). |
| `samp-map-upgrade.js` | `CreateObject` → dynamic + `Streamer_UpdateEx`. |
| `samp-heal.sh` | Compile → fix loop. |
| `samp-claim-audit.js` | Native claim audit against the parity matrix. |
| `samp-agent-evals.js` | Decision evals (toolchain or graded answers). |
| `agents-ref-check.js` | Validates every `@agent`, skill and `bin/*` reference in `AGENTS.md`. |

All scripts are invoked from the repo root. `sampctl` and `pawncc` are required for the Pawn gates; missing toolchains skip loudly (never silently pass).
