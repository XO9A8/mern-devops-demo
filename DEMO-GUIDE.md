# DevOps Demo Guide - Tomorrow's Session

> **Date**: 2025-12-10  
> **Project**: `mern-devops-demo`  
> **Reference**: See `mern-devops-roadmap.md` for detailed explanations

---

## 📋 Pre-requisites

- [ ] Docker Desktop running
- [ ] Node.js 20+ (`node --version`)
- [ ] Git installed (`git --version`)
- [ ] GitHub account ready
- [ ] VS Code with Docker extension

---

## ⏱️ Session Timeline

| Time | Part | Focus |
|------|------|-------|
| 0:00 | Setup | Git init, install deps |
| 0:30 | Docker | Dev vs Prod demonstration |
| 1:00 | GitHub | Push, branch protection, CI/CD |
| 1:45 | K8s | Manifests walkthrough |
| 2:00 | Wrap | Summary & Q&A |

---

## 🚀 Part 1: Local Setup

```bash
cd d:\Colab\cuet\plan\mern-devops-demo

# Initialize Git
git init
git add .
git commit -m "chore: initial project setup"

# Install dependencies
make setup

# Start development
make dev
```

**Verify:**
- Frontend: http://localhost:5173 ✅
- Backend: http://localhost:5000/health ✅

---

## 🐳 Part 2: Docker

### Show Dev vs Prod Differences

| Aspect | Development | Production |
|--------|-------------|------------|
| Dockerfile | `Dockerfile.dev` | `Dockerfile.prod` |
| User | root | non-root (app:1001) |
| Hot reload | ✅ nodemon | ❌ node |
| Debugger | ✅ port 9229 | ❌ |
| Multi-stage | ❌ | ✅ |
| Health check | ❌ | ✅ |

### Key Files to Explain
- `backend/Dockerfile.dev` vs `Dockerfile.prod`
- `frontend/nginx.conf` (security headers)
- `backend/.dockerignore` (build optimization)

```bash
# Build production
make build

# Test production mode
make dev-down
make prod
# Access http://localhost (port 80)
```

---

## 🔄 Part 3: GitHub & CI/CD

### Create Repository
1. Go to github.com/new
2. Create `mern-devops-demo`
3. Push code:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/mern-devops-demo.git
   git branch -M main
   git push -u origin main
   ```

### Configure Branch Protection
Settings → Branches → Add rule:
- Branch: `main`
- ✅ Require PR reviews
- ✅ Require status checks

### Test CI Pipeline
```bash
git checkout -b feature/test-ci
echo "# Test" >> README.md
git add . && git commit -m "test: verify CI"
git push origin feature/test-ci
```
→ Create PR → Watch Actions tab

### Key CI Features to Highlight
- Parallel jobs (test-backend, test-frontend)
- Snyk security scanning
- Docker image caching
- Concurrency control

---

## ☸️ Part 4: Kubernetes (Overview)

### Explain Structure
```
k8s/
├── base/                 # Common manifests
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── hpa.yaml          # Auto-scaling
│   ├── pdb.yaml          # Availability
│   └── network-policy.yaml
└── overlays/
    ├── staging/          # Staging config
    └── prod/             # Prod config
```

### Key Concepts
- Deployments with replicas
- HPA: scales 2→10 pods at 70% CPU
- PDB: maintains 50% availability
- Network Policy: frontend→backend→mongo only

---

## 📊 Part 5: Industry Practices Covered

| Practice | Implementation |
|----------|----------------|
| Separate Docker configs | `Dockerfile.dev` / `Dockerfile.prod` |
| Non-root containers | `USER app` in Dockerfile |
| Health checks | `/health` endpoint |
| .dockerignore | `backend/.dockerignore` |
| Dependabot | `.github/dependabot.yml` |
| CODEOWNERS | `.github/CODEOWNERS` |
| PR Template | `.github/pull_request_template.md` |
| Conventional commits | commitlint config |
| Image tagging | `sha`, `branch`, `semver` |
| Security scanning | Snyk in CI |
| Structured logging | Winston JSON |
| HPA / PDB | K8s manifests |
| Network isolation | NetworkPolicy |

---

## 🛠️ Quick Commands

```bash
make help         # All commands
make dev          # Development
make prod         # Production
make build        # Build images
make test         # Run tests
make logs         # View logs
make clean        # Cleanup
make k8s-staging  # Deploy K8s
```

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Port in use | `netstat -ano \| findstr :5000` |
| Docker not starting | Restart Docker Desktop |
| npm errors | `rm -rf node_modules && npm install` |
| MongoDB connection | Check `docker-compose logs mongo` |

---

## 📚 Reference Files

| File | Purpose |
|------|---------|
| `CHECKLIST-COVERAGE.md` | Checklist cross-reference |
| `mern-devops-roadmap.md` | Full DevOps guide (artifact) |
| `devops-checklist.md` | Industry practices reference |

---

> **Ready for tomorrow!** 🚀
