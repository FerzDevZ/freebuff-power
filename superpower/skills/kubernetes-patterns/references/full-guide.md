          type: Utilization
          averageUtilization: 70    # Scale up when avg CPU > 70%
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

> HPA requires `resources.requests` to be set on all containers — it calculates utilization as `current / request`.

---

## PodDisruptionBudget (PDB)

Prevent too many pods going down during node drains or rolling updates:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: my-namespace
spec:
  minAvailable: 2           # OR use maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

---

## Namespaces and Multi-Tenancy

```bash
# Create namespace with resource quotas
kubectl create namespace my-namespace

# Apply ResourceQuota to limit namespace consumption
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: my-namespace-quota
  namespace: my-namespace
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    pods: "20"
EOF
```

---

## Jobs and CronJobs

```yaml
# One-off Job (DB migration, data processing)
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  namespace: my-namespace
spec:
  backoffLimit: 3          # Retry up to 3 times on failure
  ttlSecondsAfterFinished: 3600   # Auto-delete after 1h
  template:
    spec:
      restartPolicy: OnFailure    # Never for Jobs (not Always)
      containers:
        - name: migrate
          image: ghcr.io/org/my-app:1.0.0
          command: ["python", "manage.py", "migrate"]
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
```

```yaml
# CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-job
  namespace: my-namespace
spec:
  schedule: "0 2 * * *"         # 2am daily
  concurrencyPolicy: Forbid      # Don't run if previous still running
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: cleanup
              image: ghcr.io/org/cleanup:1.0.0
              resources:
                requests:
                  cpu: "50m"
                  memory: "64Mi"
```

---

## kubectl Debugging Cheatsheet

```bash
# --- Pod status and logs ---
kubectl get pods -n my-namespace
kubectl get pods -n my-namespace -o wide          # Show node assignment
kubectl describe pod <pod-name> -n my-namespace   # Events and state details
kubectl logs <pod-name> -n my-namespace           # Current logs
kubectl logs <pod-name> -n my-namespace --previous  # Logs from crashed container
kubectl logs <pod-name> -n my-namespace -c <container>  # Multi-container pod

# --- Execute into a running container ---
kubectl exec -it <pod-name> -n my-namespace -- sh
kubectl exec -it <pod-name> -n my-namespace -- bash

# --- Check resource usage ---
kubectl top pods -n my-namespace
kubectl top nodes

# --- Deployment operations ---
kubectl rollout status deployment/my-app -n my-namespace
kubectl rollout history deployment/my-app -n my-namespace
kubectl rollout undo deployment/my-app -n my-namespace      # Rollback
kubectl rollout undo deployment/my-app --to-revision=2 -n my-namespace

# --- Scale manually ---
kubectl scale deployment my-app --replicas=5 -n my-namespace

# --- Inspect events (cluster-wide issues) ---
kubectl get events -n my-namespace --sort-by='.lastTimestamp'

# --- Port-forward for local debugging ---
kubectl port-forward pod/<pod-name> 8080:8080 -n my-namespace
kubectl port-forward svc/my-app 8080:80 -n my-namespace

# --- Dry-run to validate YAML ---
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server   # Validates against live cluster
```

### Diagnosing Common Errors

```bash
# CrashLoopBackOff: container keeps crashing
kubectl logs <pod-name> --previous -n my-namespace  # Check crash logs
kubectl describe pod <pod-name> -n my-namespace     # Check exit code & OOMKilled

# ImagePullBackOff: can't pull image
kubectl describe pod <pod-name> -n my-namespace     # Check Events section
# Causes: wrong image tag, missing imagePullSecret, private registry

# Pending pod: not scheduled
kubectl describe pod <pod-name> -n my-namespace
# Causes: insufficient resources, no matching node selector, taint/toleration mismatch

# OOMKilled: out of memory
# Increase memory limits, check for memory leaks
kubectl describe pod <pod-name> -n my-namespace | grep -A5 "Last State"
```

---

## Anti-Patterns

```yaml
# BAD: Using :latest tag — non-deterministic deployments
image: myapp:latest

# GOOD: Pin to a specific immutable tag (SHA or semver)
image: ghcr.io/org/myapp:1.4.2
# or
image: ghcr.io/org/myapp@sha256:abc123...

# ---

# BAD: Running as root
securityContext: {}    # Defaults to root

# GOOD: Non-root with explicit UID
securityContext:
  runAsNonRoot: true
  runAsUser: 1001

# ---

# BAD: No resource limits — one pod can starve the entire node
containers:
  - name: app
    image: myapp:1.0.0
    # No resources defined

# GOOD: Always set requests and limits
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"

# ---

# BAD: Storing plaintext secrets in ConfigMaps
apiVersion: v1
kind: ConfigMap
data:
  DB_PASSWORD: "mysecretpassword"   # NEVER — use Secret or external secrets manager

# ---

# BAD: ClusterAdmin for application service accounts
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
roleRef:
  kind: ClusterRole
  name: cluster-admin    # Grants god-mode to your app

# ---

# BAD: minAvailable: 0 in PDB — defeats the purpose
spec:
  minAvailable: 0

# ---

# BAD: restartPolicy: Always in a Job (causes infinite restart loop)
spec:
  restartPolicy: Always   # Use OnFailure or Never for Jobs
```

---

## Best Practices Checklist

### Security
- [ ] Container runs as non-root (`runAsNonRoot: true`, `runAsUser` set)
- [ ] `readOnlyRootFilesystem: true` with `emptyDir` for writable paths
- [ ] `allowPrivilegeEscalation: false`
- [ ] All capabilities dropped (`capabilities.drop: [ALL]`)
- [ ] Dedicated ServiceAccount per app, not `default`
- [ ] `automountServiceAccountToken: false` unless needed
- [ ] RBAC follows least privilege (use `Role`, not `ClusterRole` unless needed)
- [ ] Secrets managed via Sealed Secrets or External Secrets Operator

### Reliability
- [ ] All 3 probe types configured (startup + liveness + readiness)
- [ ] Resource requests AND limits set on every container
- [ ] `minReplicas: 2+` for any production workload
- [ ] PodDisruptionBudget defined for stateful or critical services
- [ ] `RollingUpdate` strategy with `maxUnavailable: 0`
- [ ] HPA configured for variable-load services

### Observability
- [ ] App exposes `/health` (liveness) and `/ready` (readiness) endpoints
- [ ] Structured JSON logging (no PII in logs)
- [ ] Resource labels: `app`, `version`, `environment`

---

## Related Skills

- `docker-patterns` — Multi-stage Dockerfiles and image security
- `deployment-patterns` — CI/CD pipelines, rollback strategy, health check endpoints
- `security-review` — Broader security hardening context
- `git-workflow` — GitOps integration with K8s (ArgoCD / Flux patterns)
