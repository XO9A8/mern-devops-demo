# ============================================================================
# MERN DevOps Demo - PowerShell Commands (Windows)
# ============================================================================
# Usage: .\run.ps1 <command>
# Example: .\run.ps1 dev
# ============================================================================

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host ""
    Write-Host "MERN DevOps CLI - Available Commands:" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  setup       " -NoNewline -ForegroundColor Yellow
    Write-Host "- Initial project setup (install deps)"
    Write-Host "  dev         " -NoNewline -ForegroundColor Yellow
    Write-Host "- Start development environment"
    Write-Host "  dev-build   " -NoNewline -ForegroundColor Yellow
    Write-Host "- Rebuild and start dev"
    Write-Host "  dev-down    " -NoNewline -ForegroundColor Yellow
    Write-Host "- Stop development"
    Write-Host "  prod        " -NoNewline -ForegroundColor Yellow
    Write-Host "- Start production environment"
    Write-Host "  prod-down   " -NoNewline -ForegroundColor Yellow
    Write-Host "- Stop production"
    Write-Host "  build       " -NoNewline -ForegroundColor Yellow
    Write-Host "- Build Docker images"
    Write-Host "  test        " -NoNewline -ForegroundColor Yellow
    Write-Host "- Run all tests"
    Write-Host "  logs        " -NoNewline -ForegroundColor Yellow
    Write-Host "- View container logs"
    Write-Host "  clean       " -NoNewline -ForegroundColor Yellow
    Write-Host "- Clean up containers"
    Write-Host ""
}

switch ($Command) {
    "help" {
        Show-Help
    }
    "setup" {
        Write-Host "Setting up project..." -ForegroundColor Green
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env.development" -Force
            Write-Host "Created .env.development" -ForegroundColor Green
        }
        Write-Host "Installing backend dependencies..." -ForegroundColor Cyan
        Push-Location backend
        npm install
        Pop-Location
        Write-Host "Installing frontend dependencies..." -ForegroundColor Cyan
        Push-Location frontend
        npm install
        Pop-Location
        Write-Host "Setup complete!" -ForegroundColor Green
    }
    "dev" {
        Write-Host "Starting development environment..." -ForegroundColor Green
        docker-compose -f docker-compose.dev.yml up
    }
    "dev-build" {
        Write-Host "Building and starting development..." -ForegroundColor Green
        docker-compose -f docker-compose.dev.yml up --build
    }
    "dev-down" {
        Write-Host "Stopping development..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml down
    }
    "prod" {
        Write-Host "Starting production environment..." -ForegroundColor Green
        docker-compose -f docker-compose.prod.yml up -d
    }
    "prod-down" {
        Write-Host "Stopping production..." -ForegroundColor Yellow
        docker-compose -f docker-compose.prod.yml down
    }
    "build" {
        Write-Host "Building Docker images..." -ForegroundColor Green
        docker build -t mern-demo-backend:latest -f backend/Dockerfile.prod ./backend
        docker build -t mern-demo-frontend:latest -f frontend/Dockerfile.prod ./frontend
        Write-Host "Build complete!" -ForegroundColor Green
    }
    "test" {
        Write-Host "Running tests..." -ForegroundColor Green
        Push-Location backend
        npm test
        Pop-Location
        Push-Location frontend
        npm test
        Pop-Location
    }
    "lint" {
        Write-Host "Running linters..." -ForegroundColor Green
        Push-Location backend
        npm run lint
        Pop-Location
        Push-Location frontend
        npm run lint
        Pop-Location
    }
    "logs" {
        docker-compose -f docker-compose.dev.yml logs -f
    }
    "logs-backend" {
        docker-compose -f docker-compose.dev.yml logs -f backend
    }
    "clean" {
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml down -v --remove-orphans
        Write-Host "Cleanup complete!" -ForegroundColor Green
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
