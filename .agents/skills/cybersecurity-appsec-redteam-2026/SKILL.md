---
name: cybersecurity-appsec-redteam-2026
description: Offensive & Defensive AppSec, API Security & Threat Modeling (2026) — OWASP Top 10 & API Top 10, BOLA/IDOR elimination, SSRF/SQLi/XSS/Prototype Pollution hardening, JWT/OAuth2 PKCE defense, security headers (CSP/HSTS), supply-chain SBOM & lockfile pinning, and automated SAST/DAST/Secret gates.
---

# Offensive & Defensive AppSec & Threat Modeling (2026)

Think like an adversary BEFORE deploying any endpoint, auth flow, file upload, or third-party integration.

## 1. Highest-Impact Real-World Exploit Classes & Defenses
1. **BOLA / IDOR (API1 — #1 Real-World Breach):** Never fetch by raw `id` alone (`WHERE id = $1`). ALWAYS scope queries to the authenticated principal/tenant (`WHERE id = $1 AND org_id = $2`), verified on the server from the signed session — never trust client-supplied `userId` or `role`.
2. **SSRF (Server-Side Request Forgery):** When fetching user-provided URLs (webhooks, link previews, avatars), resolve DNS first, reject private/loopback/link-local/cloud-metadata CIDRs (`127.0.0.0/8`, `10.0.0.0/8`, `169.254.169.254`, `::1`, `fc00::/7`), disable uncontrolled HTTP redirects, and enforce strict egress allowlists.
3. **Injection (SQLi, Command Injection, SSTI, Path Traversal):**
   - Parameterized queries ONLY (zero string interpolation in SQL).
   - Never pass user strings into `sh -c`, `eval`, or `exec` — pass explicit argument arrays (`execFile`, `subprocess.run([...], shell=False)`).
   - For file paths: `path.resolve(BASE_DIR, safeName)` and assert `resolved.startsWith(BASE_DIR + path.sep)`.
4. **Auth & Session Hardening:**
   - Reject `alg: none` & enforce explicit algorithm allowlists on JWT verification; prefer short-lived tokens (`15m`) + rotating HttpOnly refresh cookies with reuse detection.
   - Use **Argon2id** (or Bcrypt cost >= 12) for passwords and constant-time comparison (`crypto.timingSafeEqual`) for HMACs/API keys.
   - Enforce OAuth2 **PKCE + `state` nonce** + exact redirect URI matching.

## 2. Defense-in-Depth Headers & Supply Chain
- Enforce strict `Content-Security-Policy` (nonce-based, zero `unsafe-inline`/`unsafe-eval`), `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, and strict CORS allowlists (NEVER reflect arbitrary `Origin` with `Access-Control-Allow-Credentials: true`!).
- Lock dependencies (`package-lock.json` / `uv.lock` / `Cargo.lock`), run `semgrep` + `trivy` + secret scanning on every commit, and generate CycloneDX SBOMs on release.
