# ==============================================================================
# PulseOps ??? Developer & SRE Automation Makefile
# ==============================================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash
VENV := /home/ubuntu/app-venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
PYTEST := $(VENV)/bin/pytest
GUNICORN := $(VENV)/bin/gunicorn
APP_DIR := application/backend
DOCKER_IMAGE := pulseops-app:phase2
COMPOSE_FILE := deployment/docker-compose.yml

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: env-check
env-check: ## Validate development tools and environment dependencies
	@echo "Checking system tools..."
	@which docker >/dev/null && echo "  [OK] Docker: $$(docker --version)" || echo "  [FAIL] Docker not found"
	@which terraform >/dev/null && echo "  [OK] Terraform: $$(terraform version -json | jq -r .terraform_version)" || echo "  [FAIL] Terraform not found"
	@which aws >/dev/null && echo "  [OK] AWS CLI: $$(aws --version 2>&1 | cut -d' ' -f1)" || echo "  [FAIL] AWS CLI not found"
	@which git >/dev/null && echo "  [OK] Git: $$(git --version)" || echo "  [FAIL] Git not found"
	@$(PYTHON) --version >/dev/null 2>&1 && echo "  [OK] Python Venv: $$($(PYTHON) --version)" || echo "  [FAIL] Python Venv not found"

.PHONY: git-status
git-status: ## Show repository status and tracked branches
	@git status
	@echo "Remotes:"
	@git remote -v

.PHONY: test
test: ## Run unit and integration tests with coverage
	@echo "Running backend test suite with coverage..."
	@cd $(APP_DIR) && PYTHONPATH=. $(PYTEST) -v --cov=. --cov-report=term-missing

.PHONY: run
run: ## Run backend server locally with Gunicorn (port 8000)
	@echo "Starting PulseOps Core Engine with Gunicorn on http://0.0.0.0:8000..."
	@cd $(APP_DIR) && PYTHONPATH=. $(GUNICORN) --bind 0.0.0.0:8000 wsgi:app --workers 2

.PHONY: docker-build
docker-build: ## Build the hardened production Docker image
	@echo "Building production Docker image: $(DOCKER_IMAGE)..."
	@docker build -t $(DOCKER_IMAGE) -f deployment/Dockerfile .

.PHONY: docker-up
docker-up: ## Start application container via Docker Compose
	@echo "Starting services via Docker Compose..."
	@docker compose -f $(COMPOSE_FILE) up -d

.PHONY: docker-down
docker-down: ## Stop application container services
	@echo "Stopping Docker Compose services..."
	@docker compose -f $(COMPOSE_FILE) down

.PHONY: docker-logs
docker-logs: ## View application container logs
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: clean
clean: ## Clean build artifacts, pycache, and temporary files
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@echo "Clean completed."
