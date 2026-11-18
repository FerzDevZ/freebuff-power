---
name: mobile-offline-first-sync-2026
description: Production Cross-Platform Mobile & Offline-First Sync Engineering (2026) — Flutter 3/Riverpod & React Native New Architecture/Expo, Local-First SQLite/Drift/PowerSync/WatermelonDB sync engines, optimistic UI & conflict resolution, Keychain/Keystore biometric security, 60/120fps list virtualization, deep linking, and Fastlane release pipelines.
---

# Production Mobile & Offline-First Sync Engineering (2026)

Mobile networks drop in elevators, tunnels, and rural 4G. Production mobile apps treat the **local encrypted SQLite database as the single source of truth for UI rendering**, syncing deltas asynchronously in the background.

## 1. Local-First Sync Architecture
```text
[UI Widgets] <--reactive stream--> [Local SQLite (WAL Mode)] <--Mutation Outbox Queue--> [Sync API / PowerSync / ElectricSQL]
```
- **Optimistic UI:** User actions write immediately to local SQLite + append an idempotent mutation entry (`client_op_id UUID`, `entity_id`, `patch_json`, `lamport_ts`) to `sync_outbox` -> UI updates in `< 16ms` with zero spinner!
- **Conflict Resolution:** Choose explicit semantics per entity: Last-Write-Wins (LWW) with Hybrid Logical Clocks for profile settings; field-level merge or CRDTs for collaborative notes; server-authoritative rejection with user reconciliation dialog for financial balances/inventory.
- **Retry & Battery Discipline:** Flush `sync_outbox` on connectivity restore using exponential backoff; never poll aggressively when app is backgrounded.

## 2. Mobile Security, Performance & Release Hygiene
- **Secret Storage:** Store auth tokens strictly in **iOS Keychain / Android Keystore** (`flutter_secure_storage` / `expo-secure-store`), NEVER in plaintext `SharedPreferences` or `AsyncStorage`. Never embed private API keys in mobile bundles (they are trivial to decompile!).
- **60/120 FPS Rendering:**
  - Flutter: `const` constructors, `ListView.builder` / `SliverList`, narrow Riverpod `.select(...)` providers, offload JSON/image parsing via `Isolate.run`.
  - React Native: New Architecture (Fabric/TurboModules), `FlashList`, Reanimated worklets on UI thread, memoized selectors.
- **Zero-Crash Navigation & Releases:** Handle Universal Links / App Links with authenticated redirect preservation, test cold-start + low-memory background kills, automate signing & TestFlight/Play Internal tracks via **Fastlane + GitHub Actions**.
