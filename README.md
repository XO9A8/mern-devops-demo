# MERN DevOps Demo

> A simple MERN application with industry-level DevOps setup.

## 🚀 Quick Start

```bash
# Setup
make setup

# Start development
make dev

# Access
# Frontend: http://localhost:5173
# Backend:  http://localhost:5000
# MongoDB:  localhost:27017
```

## 📁 Structure

```
mern-devops-demo/
├── backend/           # Express.js API
├── frontend/          # React + Vite
├── k8s/               # Kubernetes manifests
├── .github/           # CI/CD workflows
└── Makefile           # CLI commands
```

## 🛠 Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start development |
| `make test` | Run tests |
| `make build` | Build images |
| `make k8s-staging` | Deploy to staging |
| `make help` | All commands |

## 📦 DevOps Features

- ✅ Docker (dev/prod Dockerfiles)
- ✅ GitHub Actions CI/CD
- ✅ Kubernetes with Kustomize
- ✅ HPA auto-scaling
- ✅ Structured JSON logging
- ✅ Health checks

## 🔧 Tomorrow's Tasks

1. Initialize git: `git init`
2. Install dependencies: `make setup`
3. Start dev: `make dev`
4. Test the app works
5. Push to GitHub
6. Watch CI/CD run

---

> Ready for DevOps demonstration
