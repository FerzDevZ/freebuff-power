---
name: fullstack-saas-2026-blueprint
description: Production Full-Stack Web & SaaS 2026 Architecture — Next.js 15/16 App Router + React 19 Server Components & Server Actions, strict TypeScript + Zod contracts, Drizzle/Prisma + PostgreSQL RLS, Passkeys/OAuth2/BetterAuth session security, idempotent Stripe/Midtrans/Xendit billing webhooks, durable background queues, and 100 Lighthouse Core Web Vitals.
---

# Full-Stack Web & Production SaaS Blueprint (2026)

## 1. End-to-End Clean Architecture
- **UI & Rendering:** React 19 + Next.js App Router (Server Components by default; push `"use client"` strictly to interactive leaf islands; eliminate `useEffect` fetch waterfalls using parallel RSC queries + `<Suspense>` streaming boundaries).
- **Type-Safe API & Validation:** Validate EVERY external boundary (route params, query strings, JSON body, Server Action inputs, webhooks, env vars) with **Zod**; return **RFC 7807 Problem Details** (`type, title, status, detail, instance`) on errors — never leak raw stack traces or SQL errors.
- **Database & Multi-Tenancy:** **PostgreSQL + Drizzle/Prisma** with explicit `tenant_id` / `org_id` indexed on EVERY tenant table, Row-Level Security (RLS) defense-in-depth, cursor pagination (never high-offset `OFFSET 50000`), and zero N+1 queries.

## 2. Production Auth, Billing & Background Jobs
1. **Authentication:** HttpOnly + Secure + `SameSite=Lax/Strict` session cookies (or rotating refresh tokens), OAuth2 PKCE, WebAuthn Passkeys, RBAC checked on EVERY Server Action and API route (never rely solely on UI hiding or middleware!).
2. **Billing & Entitlements (Stripe / Midtrans / Xendit):**
   - Always verify webhook HMAC signature using the **raw request body**.
   - Store `event_id UNIQUE` in `webhook_events` for strict **idempotency** (duplicate retries return `200 OK` without double-granting credits).
   - Never trust client-sent prices or plan IDs without server-side catalog verification.
3. **Async Work Offloading:** Push emails, PDF exports, AI calls, and media processing out of HTTP requests into durable queues (**BullMQ / Redis**, **Trigger.dev**, or **Temporal**) with exponential backoff + Dead-Letter alerting.

## 3. Anti-Slop Visual & Performance Gate
- Follow `DESIGN.md` + OKLCH tokens + Tailwind v4 CSS-first `@theme`, 0 purple-gradient slop, explicit CSS transitions, `< 100KB` initial client JS, LCP `< 1.2s`, INP `< 50ms`, CLS `0.0`.
