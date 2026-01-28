.PHONY: help dev container deploy open down test_data

# Docker image configuration
IMAGE_NAME = ghcr.io/agile-crafts-people/mongodb_api:latest
LLM_IMAGE = ghcr.io/agile-learning-institute/stage0_runbook_llm:latest

# API endpoint for schema fetching
API_URL ?= http://localhost:8180

# LLM configuration for test data generation
LLM_PROVIDER ?= ollama
LLM_MODEL ?= gpt-oss:120b
LLM_BASE_URL ?= http://spark-478a.local:11434
LLM_API_KEY ?=
LLM_TEMPERATURE ?= 7
LLM_MAX_TOKENS ?= 8192
LOG_LEVEL ?= INFO

help:
	@echo "Available commands:"
	@echo "  make dev              - Run development runtime to edit configurations"
	@echo "  make container        - Build Docker container for deployment"
	@echo "  make deploy           - Run packaged configuration (read-only)"
	@echo "  make open             - Open browser for running containers"
	@echo "  make down             - Shut down containers"
	@echo "  make test_data        - Generate test data (requires running API, COLLECTION and VERSION environment variables)"
	@echo ""
	@echo "Test data generation:"
	@echo "  make deploy"
	@echo "  make test_data COLLECTION=<name> VERSION=<version>"
	@echo "  Example: make test_data COLLECTION=User VERSION=0.1.0.0"
	@echo ""
	@echo "Environment variables for test_data:"
	@echo "  COLLECTION            - Collection name (required)"
	@echo "  VERSION               - Schema version (required)"
	@echo "  API_URL               - API endpoint (default: http://localhost:8181)"
	@echo "  LLM_PROVIDER          - LLM provider (default: ollama)"
	@echo "  LLM_MODEL             - LLM model (default: qwen3-coder:30b)"
	@echo "  LLM_BASE_URL          - LLM base URL (default: http://spark-478a.local:11434)"
	@echo "  LLM_API_KEY           - LLM API key (optional)"
	@echo "  LLM_TEMPERATURE       - LLM temperature (default: 7)"
	@echo "  LLM_MAX_TOKENS        - Max tokens (default: 8192)"
	@echo "  LOG_LEVEL             - Logging level (default: INFO)"

dev:
	@echo "Shutting down centralized services..."
	@de down || true
	@echo "Starting local development services..."
	@export INPUT_FOLDER=$$(pwd)/configurator && docker compose up -d
	@make open

container:
	@echo "Building Docker container image..."
	docker build -t $(IMAGE_NAME) .
	make deploy

deploy:
	@echo "Deploying packaged configuration..."
	make down
	de up mongodb 
	make open

open:
	@echo "Opening browser..."
	open -a 'Google Chrome' 'http://localhost:8181' || google-chrome 'http://localhost:8181' || xdg-open 'http://localhost:8181'

down:
	@echo "Shutting down local containers..."
	@docker compose down || true
	@echo "Shutting down centralized services..."
	@de down || true

test_data:
	@echo "Generating test data for $(COLLECTION) version $(VERSION)..."
	@if [ -z "$(COLLECTION)" ]; then \
		echo "Error: COLLECTION is required"; \
		echo "Usage: make test_data COLLECTION=<name> VERSION=<version>"; \
		exit 1; \
	fi
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required"; \
		echo "Usage: make test_data COLLECTION=<name> VERSION=<version>"; \
		exit 1; \
	fi
	@echo "Fetching schema from $(API_URL)/api/configurations/json_schema/$(COLLECTION).yaml/$(VERSION)/..."
	@mkdir -p .schemas
	@curl -s -f "$(API_URL)/api/configurations/json_schema/$(COLLECTION).yaml/$(VERSION)/" -o ".schemas/$(COLLECTION).$(VERSION).json" || \
		(echo "Error: Failed to fetch schema. Is the API running at $(API_URL)?"; exit 1)
	@echo "Running LLM task to generate test data..."
	@docker run --rm \
		-v "$$(pwd):/workspace/repo" \
		-v "$$(pwd):/workspace/context" \
		-e "REPO_ROOT=/workspace/repo" \
		-e "TASK_NAME=CreateTestData" \
		-e "COLLECTION=$(COLLECTION)" \
		-e "VERSION=$(VERSION)" \
		-e "LLM_PROVIDER=$(LLM_PROVIDER)" \
		-e "LLM_MODEL=$(LLM_MODEL)" \
		-e "LLM_BASE_URL=$(LLM_BASE_URL)" \
		-e "LLM_API_KEY=$(LLM_API_KEY)" \
		-e "LLM_TEMPERATURE=$(LLM_TEMPERATURE)" \
		-e "LLM_MAX_TOKENS=$(LLM_MAX_TOKENS)" \
		-e "LOG_LEVEL=$(LOG_LEVEL)" \
		$(LLM_IMAGE) > /tmp/llm_output_$(COLLECTION)_$(VERSION).txt
	@echo "Extracting and writing test data..."
	@mkdir -p configurator/test_data
	@sed -n '/---PATCH---/,$$p' /tmp/llm_output_$(COLLECTION)_$(VERSION).txt | \
		grep '^+[^+]' | sed 's/^+//' > configurator/test_data/$(COLLECTION).$(VERSION).json
	@rm -f /tmp/llm_output_$(COLLECTION)_$(VERSION).txt
	@echo "Test data generated successfully at configurator/test_data/$(COLLECTION).$(VERSION).json"
