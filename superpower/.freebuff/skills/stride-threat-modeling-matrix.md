# [Skill: stride-threat-modeling-matrix]

Execute STRIDE threat modeling on software architecture and data flow diagrams.

## Threat Analysis Matrix:
| STRIDE Category | Architectural Risk | Defensive Control |
|---|---|---|
| **S**poofing | Forged identity or token | Mutual TLS, asymmetric JWT signatures (RS256), WebAuthn |
| **T**ampering | Modified request payloads | HMAC signatures, TLS 1.3, DB checksums, input validation |
| **R**epudiation | Denied transaction execution | Append-only immutable audit log with cryptographic timestamps |
| **I**nformation Disclosure | Leaked PII or secrets | Envelope encryption at rest, field masking, zero secrets in logs |
| **D**enial of Service | API exhaustion / resource starvation | Token Bucket rate limiting, circuit breakers, bounded buffers |
| **E**levation of Privilege | Unauthorized admin access | Strict RBAC/ABAC authorization checks, least-privilege IAM |
