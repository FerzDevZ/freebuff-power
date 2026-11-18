---
name: systems-rust-tokio-production
description: Production Rust & Low-Latency Async Systems Engineering (2026) — Tokio runtime discipline, Axum/Tonic gRPC services, zero-copy bytes/Serde parsing, structured concurrency & CancellationToken graceful shutdown, thiserror/anyhow error boundaries, tracing + OpenTelemetry spans, clippy::pedantic, and PyO3/WASM native extensions.
---

# Production Rust & Low-Latency Systems Engineering (2026)

## 1. Tokio Async & Concurrency Invariants
1. **NEVER Block an Async Worker Thread:** Never run synchronous file I/O (`std::fs`), CPU-heavy crypto/compression, or `std::sync::Mutex` held across `.await` points inside Tokio tasks. Offload CPU work to `tokio::task::spawn_blocking` or a dedicated **Rayon** pool!
2. **Bounded Channels Only:** Use `tokio::sync::mpsc::channel(capacity)` with explicit backpressure — NEVER `unbounded_channel` in network-facing code (unbounded queues convert slow consumers into OOM crashes).
3. **Structured Shutdown:** Propagate a root `tokio_util::sync::CancellationToken` into every spawned background worker, listen for `SIGINT`/`SIGTERM`, and drain in-flight HTTP/gRPC requests within a strict deadline.

## 2. Error Modeling, Zero-Copy & Observability
- **Library vs Application Errors:** Define exhaustive typed domain errors using **`thiserror`** at module/library boundaries (mapping cleanly to HTTP RFC 7807 / gRPC `Status` codes); reserve `anyhow` for CLI binaries. **Zero `.unwrap()` or `.expect()` in production request paths** — propagate via `?` or match exhaustively!
- **Zero-Copy Performance:** Stream request/response bodies with `bytes::Bytes` and `axum::body::Body`, borrow slices (`&str`, `&[u8]`, `Cow<'a, str>`) instead of unnecessary `.clone()` in hot loops, and pre-allocate collections (`Vec::with_capacity`).
- **Observability & Quality Gate:** Instrument request lifecycles with `#[tracing::instrument(skip_all, fields(...))]` exported to OpenTelemetry; enforce `cargo clippy --all-targets -- -D warnings` + `cargo test` + `cargo audit` in CI.
- **Polyglot Acceleration:** Use **PyO3 + Maturin** to accelerate Python ML/data hot paths by 20x–100x with safe native wheels, or **`wasm-bindgen`** for browser/edge execution.
