---
name: distributed-systems-scale-2026
description: High-Scale Distributed Systems & Resilient Microservices Engineering — Transactional Outbox + CDC, Idempotency-Key locks, distributed Token Bucket / Sliding Window rate limiting, Circuit Breakers, Exponential Backoff with Full Jitter, backpressure, graceful shutdown, and zero-downtime Expand-Contract schema migrations.
---

# High-Scale Distributed Systems & Resilience Engineering (2026)

## 1. Fundamental Laws of Distributed Systems
1. **No Dual-Writes Without Outbox:** Never write to PostgreSQL AND publish to Kafka/Redis/Webhook in two separate network calls (crash between them = permanent state divergence!). Write business state + an `outbox_events` row in **one local ACID transaction**, then relay asynchronously via **Debezium CDC** or a polling worker with `SELECT ... FOR UPDATE SKIP LOCKED`.
2. **Every Mutating API Must Be Idempotent:** Require `Idempotency-Key` header on payments, orders, and webhooks. Persist `(key, request_hash, status, response_body)` in Redis/PostgreSQL; return cached response on retry and `409 Conflict` if the same key is reused with a different payload.
3. **Timeouts, Retries & Circuit Breakers:**
   - Set explicit connect + read + total deadline timeouts on EVERY outbound HTTP/gRPC/DB call (unbounded timeouts cause cascading thread-pool exhaustion!).
   - Retry ONLY transient errors (`429`, `502`, `503`, `504`, network reset) using **Exponential Backoff + Full Jitter** (`rand(0, min(cap, base * 2^attempt))`) — never fixed-interval retry storms!
   - Wrap unstable dependencies in a **Circuit Breaker** (Open -> Half-Open probe -> Closed) with clean fallback / degraded mode.

## 2. Traffic Control & Zero-Downtime Operations
- **Distributed Rate Limiting:** Atomic Redis Lua **Token Bucket** or **Sliding Window Log** per API key / user / IP; emit standard `RateLimit-Limit`, `RateLimit-Remaining`, `Retry-After` headers.
- **Backpressure & Graceful Shutdown:** Enforce bounded queue sizes (`reject fast with 503` rather than OOM), handle `SIGTERM` cleanly (stop accepting new connections -> drain in-flight requests within deadline -> flush telemetry & DB pools -> exit 0).
- **Zero-Downtime DB Migrations (Expand -> Migrate -> Contract):** Add nullable column / new table -> dual-write -> backfill in throttled batches -> switch reads -> drop legacy column in a subsequent release. Always create PostgreSQL indexes with `CREATE INDEX CONCURRENTLY`.
