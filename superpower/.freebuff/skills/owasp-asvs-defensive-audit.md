# [Skill: owasp-asvs-defensive-audit]

Perform systematic defensive security audits against the OWASP Application Security Verification Standard (ASVS v4.0).

## Audit Checklist:
1. **V1 Architecture**: Verify trust boundaries, security controls centralized in libraries, and least privilege design.
2. **V2 Authentication**: Enforce bcrypt/argon2id password hashing, credential stuffing rate limits, and multi-factor auth guards.
3. **V3 Session Management**: Ensure session IDs are cryptographically random (>= 128 bits), cookies use `HttpOnly; Secure; SameSite=Strict`.
4. **V4 Access Control**: Enforce authorization checks on every endpoint, preventing IDOR/BOLA by scoping queries to `auth.userId`.
5. **V5 Validation & Sanitization**: Ensure parameterized SQL queries, context-aware HTML escaping, and strict JSON schema validation.
