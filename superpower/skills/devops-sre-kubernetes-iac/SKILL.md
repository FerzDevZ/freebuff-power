---
name: devops-sre-kubernetes-iac
description: Cloud-Native DevOps, Kubernetes, Terraform/OpenTofu IaC & SRE Engineering (2026) — distroless multi-stage Docker images (<30MB), K8s HPA/PDB/NetworkPolicy/GitOps, OIDC keyless CI/CD pipelines, OpenTelemetry + Prometheus + Grafana RED/USE golden signals, SLO error budgets, and blameless incident runbooks.
---

# Cloud-Native DevOps, Kubernetes, IaC & SRE Engineering (2026)

## 1. Container & CI/CD Hardening
- **Minimal Non-Root Containers:** Multi-stage builds compiling in builder stage and copying ONLY runtime binaries/artifacts into `gcr.io/distroless` or `alpine` with `USER nonroot:nonroot`, read-only root filesystem (`readOnlyRootFilesystem: true`), and pinned base image SHA256 digests (`@sha256:...`).
- **Keyless OIDC CI/CD:** Never store long-lived AWS/GCP static keys in GitHub Secrets. Authenticate GitHub Actions via **OIDC Federation** with least-privilege short-lived tokens; pin third-party Actions to full commit SHAs; run Trivy/Syft SBOM & vulnerability gates before registry push.

## 2. Kubernetes & IaC Production Guardrails
- **Every K8s Workload MUST Declare:**
  - `requests` & `limits` (CPU/memory) + `HorizontalPodAutoscaler`
  - `livenessProbe` (process alive — NEVER check external DB here!), `readinessProbe` (can serve traffic), and `startupProbe`
  - `PodDisruptionBudget` (`minAvailable: 1`) + `topologySpreadConstraints` across AZs
  - Default-deny `NetworkPolicy` allowing only explicit ingress/egress pods
- **Terraform / OpenTofu Hygiene:** Remote encrypted state with locking, strict module boundaries (`network`, `data`, `compute`), `plan` output reviewed in PR before `apply`, zero hardcoded secrets (pull dynamically from Vault/Infisical/AWS Secrets Manager).

## 3. SRE Observability & Incident Discipline
- Instrument **RED** metrics (Rate, Errors, Duration p50/p95/p99) for services and **USE** metrics (Utilization, Saturation, Errors) for infra via **OpenTelemetry** (structured JSON logs correlated with `trace_id`).
- Alert ONLY on **symptom-based SLO burn rates** (paging humans for actionable customer impact, never noisy CPU-spike alert fatigue), backed by tested rollback scripts and blameless post-mortems.
