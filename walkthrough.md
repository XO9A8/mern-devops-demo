# MERN DevOps Demo - Comprehensive Project Walkthrough

**Date:** December 10, 2025  
**Status:** ✅ Enterprise-Grade CI/CD + Kubernetes Deployed

This document provides a detailed technical overview of the MERN Stack DevOps setup. It covers the architectural decisions, implementation details, and the "Enterprise-Grade" standards applied.

---

## 1. Project Overview & Architecture

A **Microservices-ready** MERN application containerized with Docker and orchestrated via a robust CI/CD pipeline.

### **Tech Stack**
| Layer | Technology |
|-------|------------|
| Frontend | React (Vite) |
| Backend | Node.js (Express) |
| Database | MongoDB (StatefulSet in K8s) |
| DevOps | Docker, GitHub Actions, Trivy, Husky, Commitlint, Semantic Release |
| Infrastructure | Kubernetes (Kustomize), Network Policies, HPA, PDB |

### **Key Architectural Decisions**
1. **Immutable Infrastructure**: Containers tagged with SHA hashes (`sha-abc123`) never change.
2. **Shift-Left Security**: Trivy scanning + pre-commit hooks catch issues early.
3. **Non-Root Containers**: Both backend AND frontend run as unprivileged users.
4. **Environment Parity**: Dev (hot-reload) vs Prod (optimized builds, Nginx).

---

## 2. Implementation Details

### A. Docker Strategy

| Environment | Features |
|-------------|----------|
| **Development** | Hot-reload with nodemon/vite, volume mounts |
| **Production** | Multi-stage builds, non-root user, health checks |

**Security Features in Prod Dockerfiles:**
- `USER app` (non-root) in both backend AND frontend
- `HEALTHCHECK` commands for container orchestration
- `.dockerignore` to minimize image size

### B. CI Pipeline (`.github/workflows/ci.yml`)

**Smart Change Detection** using `dorny/paths-filter`:
```
changes job → detects what changed → conditionally runs:
  ├─ test-backend (if backend/** changed)
  ├─ test-frontend (if frontend/** changed)
  ├─ security-scan (if any code changed)
  └─ build (only rebuilds changed images)
```

| Job | Purpose | Runs When |
|-----|---------|-----------|
| **changes** | Detect file changes | Always (fast) |
| **test-backend** | ESLint + Jest | `backend/**` changed |
| **test-frontend** | ESLint + Vitest | `frontend/**` changed |
| **security-scan** | Trivy (CRITICAL) | Any code changed |
| **build** | Docker images | Code or Dockerfile changed |

**Enterprise Features:**
- ✅ Dynamic change detection (not static path filters)
- ✅ Per-job skipping (saves CI minutes)
- ✅ Conditional image builds (only rebuild what changed)
- ✅ Concurrency control (cancels duplicate runs)
- ✅ Pinned action versions (no `@master` tags)

### C. CD Pipeline (`.github/workflows/cd.yml`)

| Environment | Trigger | Features |
|-------------|---------|----------|
| **Staging** | Push to `main` | Kustomize overlays, 2 replicas |
| **Production** | Git tag `v*` | 3 replicas, GitHub Release |

**Enterprise Features:**
- ✅ Concurrency control (no parallel deployments)
- ✅ Consistent image tags (`sha-` prefix matches CI)
- ✅ Environment protection rules ready

### D. Semantic Release (`.releaserc.json`)

Automated versioning based on Conventional Commits:

| Commit Type | Release | Changelog Section |
|-------------|---------|-------------------|
| `feat:` | Minor (1.x.0) | 🚀 Features |
| `fix:` | Patch (1.0.x) | 🐛 Bug Fixes |
| `perf:` | Patch | ⚡ Performance |
| `BREAKING CHANGE` | Major (x.0.0) | 💥 Breaking |

### E. Pre-commit Hooks (Husky)

| Hook | Tool | Action |
|------|------|--------|
| `pre-commit` | lint-staged | Runs ESLint on staged files |
| `commit-msg` | commitlint | Validates Conventional Commits |

### F. Kubernetes Deployment (`k8s/`)

**Production-Grade Best Practices Implemented:**

| Category | Resource | Description |
|----------|----------|-------------|
| **Security** | SecurityContext | `runAsNonRoot`, `readOnlyRootFilesystem`, drop all capabilities |
| **Security** | ServiceAccount | Dedicated SA with `automountServiceAccountToken: false` |
| **Security** | RBAC | Minimal Role + RoleBinding |
| **Resources** | ResourceQuota | Namespace limits (CPU: 8, Memory: 8Gi, Pods: 20) |
| **Resources** | LimitRange | Default container limits |
| **Config** | ConfigMap | Non-secret config separated from Secrets |
| **HA** | Pod Anti-Affinity | Spread pods across nodes |
| **HA** | HPA | Auto-scaling (2-10 replicas) |
| **HA** | PDB | minAvailable: 1 |
| **Network** | NetworkPolicies | Least-privilege segmentation |
| **Observability** | Prometheus Annotations | `prometheus.io/scrape: true` |

**Access Services:**
```bash
kubectl port-forward -n staging svc/backend 5000:5000
kubectl port-forward -n staging svc/frontend 8080:80
```

### G. Security Headers (Nginx)

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'...
Referrer-Policy: strict-origin-when-cross-origin
```

---

## 3. How to Work with This Project

### **Local Development (Docker Compose)**
```bash
make dev
# Frontend: http://localhost:5173
# Backend: http://localhost:5000
```

### **Kubernetes Deployment**
```bash
kubectl apply -k k8s/overlays/staging
kubectl get pods -n staging
```

### **Making a Code Change**
```bash
git add .
git commit -m "feat: add new feature"  # Commitlint enforces format
git push origin main                    # CI/CD runs automatically
```

---

## 4. Troubleshooting & Lessons Learned

| Issue | Solution |
|-------|----------|
| React 19 peer deps | `npm ci --legacy-peer-deps` |
| Docker Hub auth | Use username (not email) + Personal Access Token |
| lint-staged on Windows | Use ESLint directly with `--config` flag |
| MongoDB probe timeouts | Use TCP socket probe instead of mongosh command |
| Server tests failing | Added `require.main === module` check |

---

## 5. ArgoCD GitOps

**Installed in cluster with auto-sync:**

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open: https://localhost:8080
# Username: admin
# Password: (run below command)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

| Environment | Auto-Sync | Path |
|-------------|-----------|------|
| Staging | ✅ Yes | `k8s/overlays/staging` |
| Production | ❌ Manual | `k8s/overlays/prod` |

---

## 6. Future Roadmap

| Phase | Status |
|-------|--------|
| **CI/CD Pipelines** | ✅ Complete |
| **Local K8s Deployment** | ✅ Complete |
| **K8s Best Practices** | ✅ Complete |
| **ArgoCD (GitOps)** | ✅ Complete |
| **Monitoring (Prometheus/Grafana)** | ⏳ Planned |
| **E2E Testing** | ⏳ Planned |
| **E2E Testing** | ⏳ Planned |
