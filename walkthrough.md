# MERN DevOps Demo - Comprehensive Project Walkthrough

**Date:** December 10, 2025
**Status:** Enterprise-Grade CI Ready (Pre-Kubernetes Deployment)

This document provides a detailed technical overview of the MERN Stack DevOps setup. It covers the architectural decisions, implementation details, and the "Enterprise-Grade" standards applied to transform a basic application into a production-ready system.

---

## 1. Project Overview & Architecture

We have built a **Microservices-ready** MERN application containerized with Docker and orchestrated via a robust CI/CD pipeline.

### **Tech Stack**
*   **Frontend**: React (Vite)
*   **Backend**: Node.js (Express)
*   **Database**: MongoDB (Containerized)
*   **DevOps Tooling**: Docker, Docker Compose, GitHub Actions, Trivy, Husky, Commitlint, Semantic Release.

### **Key Architectural Decisions**
1.  **Immutable Infrastructure**: We treat containers as immutable artifacts. Once built and tagged with a SHA, they never change.
2.  **Shift-Left Security**: Security scanning (Trivy) and Linting occur *before* code is even committed (Husky) or built (CI).
3.  **Environment Parity**:
    *   **Dev**: Hot-reloading, local volumes, mapped ports.
    *   **Prod**: Optimized multi-stage builds, Nginx serving frontend, non-root users.

---

## 2. Implementation Details

### A. Docker Strategy (Infrastructure as Code)
We created specific Docker configurations for different lifecycle stages to balance developer experience with production performance.

*   **Development (`Dockerfile.dev`)**:
    *   Uses `nodemon` (backend) and `vite` (frontend) for hot-reloading.
    *   Mounts source code as volumes (`-v ./backend:/app`) so changes define instant feedback.
*   **Production (`Dockerfile.prod`)**:
    *   **Multi-Stage builds**: Reduces image size by discarding build tools (node_modules, source) and keeping only artifacts (dist folder).
    *   **Non-Root User**: Runs as `USER app` instead of `root` to mitigate container breakout attacks.

### B. CI Pipeline (`.github/workflows/ci.yml`)
The Continuous Integration pipeline is the heart of our quality control. It triggers on every push to `main` and `develop`.

**Jobs Breakdown:**
1.  **Test Backend/Frontend**:
    *   Installs dependencies (Optimized with `npm ci --legacy-peer-deps` to resolve React 19 conflicts).
    *   Runs **ESLint** to catch syntax/style errors.
    *   Runs **Unit Tests** (Jest/Vitest) to ensure logic correctness.
2.  **Security Scan (Trivy)**:
    *   Scans the filesystem for "High" and "Critical" Vulnerabilities (CVEs) in dependencies.
    *   Currently configured to *warn* (exit code 0) rather than block, to allow for initial triage.
3.  **Build & Push**:
    *   Builds production Docker images.
    *   **Immutable Tagging**: Tags images with both `latest` and `sha-<commit-hash>` (e.g., `sha-80acec9`). This ensures strict traceability.
    *   **Caching**: Uses GitHub Actions Cache (`type=gha`) to drastically reduce build times by reusing layers from previous runs.

### C. Enterprise Standards (The "Enterprise Upgrade")
We implemented strict standards to match what you would find in a high-compliance banking or fintech environment.

1.  **Dependabot (Automated Patching)**
    *   Configured in `.github/dependabot.yml`.
    *   **Grouping**: Updates are grouped by ecosystem (npm, docker, actions) to prevent "Pull Request Spam".

2.  **Pre-commit Hooks (Husky + Lint-staged)**
    *   **Why**: "Don't break the build."
    *   **Action**: Before a developer can commit, `husky` runs `lint-staged`. If the linter fails, the commit is rejected locally.

3.  **Commit Standardization (Commitlint)**
    *   **Why**: "Readable history."
    *   **Action**: Enforces **Conventional Commits** format.
    *   *Examples*: `feat: add login`, `fix: database connection`, `chore: update deps`.
    *   Invalid messages (e.g., "fixed stuff") are rejected by the `commit-msg` hook.

4.  **Semantic Release (Automated Versioning)**
    *   **Workflow**: `.github/workflows/release.yml`.
    *   **Action**: analyzes commit history to automatically determine the next version number (e.g., `1.0.0` -> `1.1.0` if `feat` exists, -> `1.0.1` if `fix` exists) and creates a GitHub Release.

---

## 3. How to Work with This Project

### **Local Development**
Start the entire stack (Frontend + Backend + Database) in "Dev Mode":
```bash
make dev
# Access Frontend: http://localhost:5173
# Access Backend: http://localhost:5000
```

### **Production Build (Local Test)**
Simulate a production build locally:
```bash
make prod-build
make prod
# Access Frontend (Nginx): http://localhost:80
```

### **Making a Code Change**
1.  Make your edits.
2.  Run `git add .`
3.  Run `git commit -m "feat: description of change"`
    *   *Note*: If you have linting errors, Husky will block you. Fix them!
    *   *Note*: If you use a bad message (e.g., "wip"), Commitlint will block you.
4.  Run `git push origin main`.
    *   Watch the CI pipeline: Test -> Scan -> Build -> Push -> Release.

---

## 4. Troubleshooting & Lessons Learned
During the setup, we encountered and solved several real-world issues:

*   **React 19 vs Testing Library**: Use `npm ci --legacy-peer-deps` to bypass strict peer dependency conflicts in the current ecosystem.
*   **Secrets Management**: Docker Hub authentication requires `DOCKER_USERNAME` (not email) and a **Personal Access Token** (not password) for security.
*   **Process Permissions**: Files created by Docker volumes sometimes belong to `root`. using `make setup` resolves this ownership to the current user.

---

## 5. Future Roadmap (Deployment Phase)
The project is currently "CI Complete". The next phase is **CD (Continuous Deployment)** to Kubernetes.

*   [ ] **Local K8s**: Deploy to Docker Desktop Kubernetes using `kubectl` and `kustomize`.
*   [ ] **ArgoCD**: Implement GitOps to sync the cluster state automatically with the git repo.
*   [ ] **Monitoring**: Install Prometheus and Grafana for observability.
