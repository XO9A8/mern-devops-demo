# ============================================================================
# MERN DevOps Demo - Makefile (Windows Compatible)
# ============================================================================
# Run with: make <command>
# On Windows: Use Git Bash, PowerShell, or WSL
# ============================================================================
.PHONY: help dev prod build test lint clean setup

.DEFAULT_GOAL := help

APP_NAME := mern-demo
REGISTRY := ghcr.io/yourorg

# Detect OS
ifeq ($(OS),Windows_NT)
    SHELL := powershell.exe
    .SHELLFLAGS := -NoProfile -Command
    RM := Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    COPY := Copy-Item
else
    RM := rm -rf
    COPY := cp
endif

help: ## Show this help
	@echo "MERN DevOps CLI - Available Commands:"
	@echo "  dev          - Start development environment"
	@echo "  dev-build    - Rebuild and start dev"
	@echo "  dev-down     - Stop development"
	@echo "  prod         - Start production environment"
	@echo "  prod-down    - Stop production"
	@echo "  build        - Build Docker images"
	@echo "  test         - Run all tests"
	@echo "  lint         - Run linters"
	@echo "  logs         - View logs"
	@echo "  clean        - Clean up containers"
	@echo "  setup        - Initial project setup"

# Development
dev: ## Start development environment
	docker-compose -f docker-compose.dev.yml up

dev-build: ## Rebuild and start dev
	docker-compose -f docker-compose.dev.yml up --build

dev-down: ## Stop development
	docker-compose -f docker-compose.dev.yml down

# Production
prod: ## Start production environment
	docker-compose -f docker-compose.prod.yml up -d

prod-build: ## Rebuild and start prod
	docker-compose -f docker-compose.prod.yml up -d --build

prod-down: ## Stop production
	docker-compose -f docker-compose.prod.yml down

# Staging
staging: ## Start staging environment
	docker-compose -f docker-compose.staging.yml up -d

staging-build: ## Rebuild and start staging
	docker-compose -f docker-compose.staging.yml up -d --build

staging-down: ## Stop staging
	docker-compose -f docker-compose.staging.yml down

# Build
build: ## Build Docker images
	docker build -t $(APP_NAME)-backend:latest -f backend/Dockerfile.prod ./backend
	docker build -t $(APP_NAME)-frontend:latest -f frontend/Dockerfile.prod ./frontend
	docker build -t $(APP_NAME)-backend:staging -f backend/Dockerfile.staging ./backend
	docker build -t $(APP_NAME)-frontend:staging -f frontend/Dockerfile.staging ./frontend

# Testing
test: ## Run all tests
	cd backend; npm test
	cd frontend; npm test

lint: ## Run linters
	cd backend; npm run lint
	cd frontend; npm run lint

# Kubernetes
k8s-staging: ## Deploy to staging
	kubectl apply -k k8s/overlays/staging

k8s-prod: ## Deploy to production
	kubectl apply -k k8s/overlays/prod

# Utilities
logs: ## View logs
	docker-compose -f docker-compose.dev.yml logs -f

logs-backend: ## View backend logs
	docker-compose -f docker-compose.dev.yml logs -f backend

shell-backend: ## Shell into backend
	docker-compose -f docker-compose.dev.yml exec backend sh

shell-mongo: ## MongoDB shell
	docker-compose -f docker-compose.dev.yml exec mongo mongosh

clean: ## Clean up
	docker-compose -f docker-compose.dev.yml down -v --remove-orphans

# Setup (Windows compatible)
setup: ## Initial setup
	$(COPY) .env.example .env.development
	cd backend; npm install
	cd frontend; npm install
	@echo "Setup complete!"
