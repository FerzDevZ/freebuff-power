---
name: freebuff-master-2026
description: Universal master orchestrator for ALL development domains in freebuff-power/freepi-power — detects request domain (web, mobile, ML/AI, backend, DevOps, SA-MP, UI/UX, database, security, testing), selects the right specialist skill, enforces design→code→compile→verify workflow, and guarantees 0-warning production output. Use when starting any development task, when unsure which skill to use, or when building a full feature spanning multiple domains.
---

# Freebuff-Power / FreePi-Power Universal Master (2026)

## 1. Purpose

This is the **single entry point** for all development. When a user requests anything — "buatkan X", "fix Y", "design Z" — this skill determines:

1. **Domain** — what kind of task is this?
2. **Skill** — which specialist skill(s) to load (JIT, max 3)
3. **Workflow** — what steps must be followed
4. **Gate** — what verification must pass before shipping

## 2. Domain Detection Matrix

| User Request Pattern | Domain | Primary Skill | Secondary Skills |
|---------------------|--------|---------------|-----------------|
| "buatkan web", "landing page", "dashboard", "Next.js", "React", "SaaS" | **Web Frontend** | `react19-nextjs15-modern-craft` | `tailwind-v4-shadcn-system`, `antislop-ui`, `frontend-design` |
| "buatkan backend", "API", "server", "microservice", "FastAPI", "Go", "Node" | **Backend** | `node-typescript-backend` / `python-fastapi-backend` / `golang-microservices` | `api-design`, `database-patterns`, `error-handling` |
| "buatkan mobile", "Flutter", "React Native", "Android", "iOS" | **Mobile** | `crossplatform-mobile-flutter-rn` | `mobile-offline-first-sync-2026`, `flutter-clean-architecture-tdd` |
| "buatkan ML", "machine learning", "PyTorch", "model", "training", "fine-tune" | **ML/AI** | `deep-learning-pytorch-2026` | `mlops-production-pipelines`, `llm-finetuning-lora-qlora-datasets` |
| "buatkan AI agent", "LLM", "RAG", "MCP", "chatbot" | **AI Agent** | `ai-agent-mcp-orchestration-2026` | `rag-llm-integrator`, `llm-evals-observability-2026` |
| "buatkan database", "schema", "migration", "SQL", "PostgreSQL" | **Database** | `postgresql-internals-indexing-master` | `database-migrations`, `erd-data-modeling-expert` |
| "deploy", "Docker", "Kubernetes", "CI/CD", "Terraform" | **DevOps** | `devops-sre-kubernetes-iac` | `docker-container-master`, `github-actions-ci-cd` |
| "security", "audit", "vulnerability", "pentest", "OWASP" | **Security** | `cybersecurity-appsec-redteam-2026` | `owasp-security-auditor`, `security-review` |
| "test", "E2E", "Playwright", "unit test", "coverage" | **Testing** | `e2e-testing` | `tdd-master`, `unit-integration-tdd-master` |
| "UI/UX", "design system", "color", "typography", "accessibility" | **Design** | `ui-ux-design-system-expert` | `antislop-ui`, `accessibility`, `tailwind-v4-shadcn-system` |
| "buatkan SA-MP", "open.mp", "gamemode", "TextDraw", "mapping" | **SA-MP/open.mp** | `samp-master-2026` | (see samp-master-2026 §5 for full skill list) |
| "performance", "optimize", "slow", "lag", "bundle" | **Performance** | `performance-engineer` | `web-performance-core-vitals-pro`, `core-web-vitals-inp-lcp-master` |
| "real-time", "WebSocket", "SSE", "chat", "live" | **Real-time** | `websocket-realtime-architect` | `websocket-engineer`, `redis-data-structures-streams` |
| "data pipeline", "ETL", "Kafka", "Polars", "DuckDB" | **Data Engineering** | `data-lakehouse-polars-iceberg` | `duckdb-embedded-olap-sql`, `clickhouse-io` |

## 3. Universal Workflow (ALL requests)

```
1. DETECT  → Identify domain from user request (§2 table)
2. LOAD    → Load primary skill + 1-2 secondary skills (JIT, max 3)
3. DESIGN  → Plan before code (mockup, schema, architecture)
4. CODE    → Write production code (typed, tested, minimal diff)
5. COMPILE → Run verification (tsc, ruff, cargo, pawncc, etc.)
6. VERIFY  → Domain-specific gate (tests, security, performance)
7. SHIP    → Version control, document, deploy
```

## 4. Universal Rules (ALL skills must enforce)

### Code Quality
- ❌ No stubs/placeholders (`// TODO`, `pass`, `...`)
- ❌ No weak typing (`any`, bare `except:`, force unwrap `!`, `.unwrap()`)
- ❌ No generic names (`data`, `item`, `res`, `temp`, `obj`)
- ❌ No silent failures (empty catch blocks)
- ❌ No authorization/injection gaps (BOLA/IDOR, SQLi, XSS)
- ✅ Domain-specific identifiers (`verifiedOrder`, `activeSession`)
- ✅ Typed errors with RFC 7807 structured responses
- ✅ Parameterized queries only
- ✅ All external boundaries validated (Zod/Pydantic)

### Visual/UI Anti-Slop
- ❌ No cliché violet/indigo gradients
- ❌ No centered-everything layouts
- ❌ No `transition-all` or uniform `hover:scale-105`
- ❌ No emoji as UI icons
- ✅ OKLCH color palettes
- ✅ WCAG 2.2 AA/AAA contrast (≥4.5:1)
- ✅ All 8 interactive states (default, hover, focus, active, disabled, loading, error, empty)

### Compile Gate (per stack)

| Stack | Command | Acceptance |
|-------|---------|------------|
| TypeScript/Node | `npx tsc --noEmit` | 0 errors |
| Next.js | `npm run build` | Clean bundle |
| Python | `ruff check . && mypy . && pytest -q` | All green |
| Go | `go vet ./... && go test -race ./...` | 0 races |
| Rust | `cargo clippy -- -D warnings && cargo test` | 0 warnings |
| Flutter | `flutter analyze && flutter test` | 0 issues |
| SA-MP/open.mp | `pawncc` (both targets) | 0 warnings |
| Docker | `docker build` | Clean image |

## 5. Skill Inventory Summary (637 skills)

### By Domain
| Domain | Skills | Key Skills |
|--------|--------|------------|
| SA-MP/open.mp | 57 | `samp-master-2026`, `samp-textdraw-fivem-modern-design`, `samp-mapping-dynamic-objects-pro` |
| Web Frontend | ~30 | `react19-nextjs15-modern-craft`, `tailwind-v4-shadcn-system`, `frontend-design` |
| Backend | ~25 | `node-typescript-backend`, `python-fastapi-backend`, `golang-microservices` |
| Mobile | ~15 | `crossplatform-mobile-flutter-rn`, `mobile-offline-first-sync-2026` |
| ML/AI | ~20 | `deep-learning-pytorch-2026`, `mlops-production-pipelines`, `ai-agent-mcp-orchestration-2026` |
| Database | ~15 | `postgresql-internals-indexing-master`, `database-migrations`, `erd-data-modeling-expert` |
| DevOps | ~20 | `devops-sre-kubernetes-iac`, `docker-container-master`, `github-actions-ci-cd` |
| Security | ~15 | `cybersecurity-appsec-redteam-2026`, `owasp-security-auditor`, `security-review` |
| Testing | ~15 | `e2e-testing`, `tdd-master`, `unit-integration-tdd-master` |
| Design/UI/UX | ~20 | `ui-ux-design-system-expert`, `antislop-ui`, `accessibility` |
| Data Engineering | ~10 | `data-lakehouse-polars-iceberg`, `duckdb-embedded-olap-sql` |
| Real-time | ~5 | `websocket-realtime-architect`, `websocket-engineer` |
| Performance | ~10 | `performance-engineer`, `web-performance-core-vitals-pro` |

### SA-MP/open.mp (57 skills)
See `samp-master-2026` for full inventory and agent mapping.

## 6. Agent ↔ Skill Mapping (Universal)

### Web/Full-Stack
| Agent | Primary Skills |
|-------|---------------|
| `@fullstack-web-2026-architect` | `react19-nextjs15-modern-craft`, `tailwind-v4-shadcn-system`, `fullstack-saas-2026-blueprint` |
| `@design-director` | `antislop-ui`, `design-system`, `frontend-design` |
| `@shadcn-craftsman` | `shadcn-radix-headless-craft`, `tailwind-v4-shadcn-system` |

### Backend/Distributed
| Agent | Primary Skills |
|-------|---------------|
| `@distributed-systems-architect` | `distributed-systems-scale-2026`, `idempotency-distributed-transactions` |
| `@database-reviewer` | `postgresql-internals-indexing-master`, `database-migrations` |
| `@hono-edge-architect` | `bun-runtime-hyper-fast-apis`, `cloudflare-edge-workers-caching` |

### ML/AI
| Agent | Primary Skills |
|-------|---------------|
| `@ml-ai-architect` | `deep-learning-pytorch-2026`, `mlops-production-pipelines` |
| `@ai-agent-systems-engineer` | `ai-agent-mcp-orchestration-2026`, `llm-evals-observability-2026` |
| `@rag-pipeline-reviewer` | `rag-llm-integrator`, `rag-graph-knowledge-neo4j` |

### SA-MP/open.mp
| Agent | Primary Skills |
|-------|---------------|
| `@samp-creator-2026` | All 57 SA-MP skills |
| `@samp-textdraw-ui-designer` | `samp-textdraw-fivem-modern-design`, `samp-textdraw-ui-craft` |
| `@samp-mapping-mlo-architect` | `samp-mapping-dynamic-objects-pro`, `samp-streamer-plugin`, `samp-colandreas-physics` |

### DevOps/Security
| Agent | Primary Skills |
|-------|---------------|
| `@devops-sre-architect` | `devops-sre-kubernetes-iac`, `docker-container-master` |
| `@cybersecurity-redteam-pro` | `cybersecurity-appsec-redteam-2026`, `owasp-security-auditor` |
| `@security-reviewer` | `security-review`, `security-bounty-hunter` |

## 7. Anti-Slop Rules (Universal)

1. **No raw editor export** — always refactor to modular code
2. **No hardcoded values** — use constants, defines, or data tables
3. **No magic numbers** — name every threshold, timer, distance
4. **No copy-paste from examples** — compose from primitives
5. **No untested code** — every feature must have verification
6. **No unversioned dependencies** — pin all versions
7. **No weak typing** — strict types everywhere
8. **No silent failures** — propagate typed errors

## 8. Gate (ALL requests)

```bash
# 1. Detect domain → load skills
# 2. Design → plan before code
# 3. Code → production quality
# 4. Compile → 0 warnings (stack-specific command)
# 5. Test → domain-specific verification
# 6. Security → OWASP Top 10 check
# 7. Ship → version control + document
```

---

## References

- skills.sh: https://www.skills.sh/ (standard format)
- agentskills.io: https://agentskills.io/specification (spec)
- freebuff-power: SA-MP/open.mp specialist skills
- freepi-power: Universal development skills