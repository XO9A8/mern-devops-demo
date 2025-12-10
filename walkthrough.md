# MERN DevOps Demo - Comprehensive Project Walkthrough

**Date:** December 10, 2025  
**Status:** Enterprise-Grade CI/CD Complete (Pre-Kubernetes Deployment)

This document provides a detailed technical overview of the MERN Stack DevOps setup. It covers the architectural decisions, implementation details, and the "Enterprise-Grade" standards applied.

---

## 1. Project Overview & Architecture

A **Microservices-ready** MERN application containerized with Docker and orchestrated via a robust CI/CD pipeline.

### **Tech Stack**
| Layer | Technology |
|-------|------------|
| Frontend | React (Vite) |
| Backend | Node.js (Express) |
| Database | MongoDB (Containerized) |
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

| Job | Purpose | Key Features |
|-----|---------|--------------|
| **test-backend** | Quality gate | ESLint + Jest (82% coverage) |
| **test-frontend** | Quality gate | ESLint + Vitest |
| **security-scan** | Vulnerability detection | Trivy (fails on CRITICAL, pinned to v0.28.0) |
| **build** | Docker images | Immutable SHA tags + GHA caching |

**Enterprise Features:**
- ✅ Concurrency control (cancels duplicate runs)
- ✅ Pinned action versions (no `@master` tags)
- ✅ No debug steps that leak secrets

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

**Plugins:** commit-analyzer, release-notes-generator, changelog, git, github

### E. Pre-commit Hooks (Husky)

| Hook | Tool | Action |
|------|------|--------|
| `pre-commit` | lint-staged | Runs ESLint on staged files |
| `commit-msg` | commitlint | Validates Conventional Commits |

### F. Kubernetes Manifests (`k8s/`)

| Resource | Purpose |
|----------|---------|
| `backend-deployment.yaml` | Resource limits, liveness/readiness probes |
| `frontend-deployment.yaml` | Nginx serving, health checks |
| `hpa.yaml` | Auto-scaling (2-10 replicas, 70% CPU) |
| `pdb.yaml` | Pod Disruption Budget (minAvailable: 1) |
| `network-policy.yaml` | Least-privilege network segmentation |
| `secrets.yaml` | K8s Secrets for app config |

### G. Security Headers (Nginx)

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'...
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

---

## 3. How to Work with This Project

### **Local Development**
```bash
make dev
# Frontend: http://localhost:5173
# Backend: http://localhost:5000
```

### **Production Build (Local)**
```bash
make prod-build && make prod
# Frontend (Nginx): http://localhost:80
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
| Volume permissions | `make setup` fixes ownership |
| lint-staged on Windows | Use ESLint directly with `--config` flag |
| Semantic Release npm error | Configured to skip npm publishing |
| Server tests failing | Added `require.main === module` check for test isolation |

---

## 5. Future Roadmap

| Phase | Items |
|-------|-------|
| **Kubernetes** | Deploy to Docker Desktop K8s, ArgoCD GitOps |
| **Monitoring** | Prometheus + Grafana observability stack |
| **E2E Testing** | Cypress or Playwright integration |
