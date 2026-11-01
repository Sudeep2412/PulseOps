# ==============================================================================
# PulseOps ??? Developer & SRE Automation Makefile
# ==============================================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash
VENV := /home/ubuntu/app-venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

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

.PHONY: lint
lint: ## Run code linters and formatting checks (Planned)
	@echo "Running linters..."
	@echo "Linters will be configured in Phase 1."

.PHONY: test
test: ## Run unit and integration tests (Planned)
	@echo "Running test suite..."
	@echo "Test suite will be configured in Phase 1."

.PHONY: docker-build
docker-build: ## Build application Docker image (Planned)
	@echo "Docker build target will be implemented in Phase 1."

.PHONY: docker-up
docker-up: ## Start container services via Docker Compose (Planned)
	@echo "Docker Compose services will be configured in Phase 1."

.PHONY: docker-down
docker-down: ## Stop container services (Planned)
	@echo "Stopping container services..."

.PHONY: clean
clean: ## Clean build artifacts, pycache, and temporary files
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@echo "Clean completed."
