.PHONY: help dev container deploy open down test check-root clean-test setup-test debug-specs run-test-container check-output

help:
	@echo "Available commands:"
	@echo "  make dev              - Run development runtime to edit configurations"
	@echo "  make container        - Build Docker container for deployment"
	@echo "  make deploy           - Run packaged configuration (read-only)"
	@echo "  make open             - Open browser for running containers"
	@echo "  make down             - Shut down containers"
	@echo "  make test             - Run Stage0 template tests in a container"

TEMP_REPO ?= $(HOME)/tmp/testRepo
LOG_LEVEL ?= INFO
IMAGE ?= ghcr.io/agile-learning-institute/stage0_runbook_merge:latest
SERVICE_NAME ?= mongodb

check-root:
	@if [ ! -e ./.stage0_template ]; then \
		echo "Error: This target must be run from the root of the repo. Ensure the repo is an unprocessed Stage0 template repository."; \
		exit 1; \
	fi

clean-test:
	@echo "Cleaning temporary testing folder at $(TEMP_REPO)..."
	@rm -rf "$(TEMP_REPO)"

setup-test: check-root clean-test
	@echo "Setting up temporary testing folder at $(TEMP_REPO)..."
	@mkdir -p "$(TEMP_REPO)"
	@cp -r . "$(TEMP_REPO)"

debug-specs:
	@echo "Debug: Checking specifications structure..."
	@find .stage0_template/test_data -name "*.yaml" | head -10

run-test-container:
	@echo "Running the container..."
	docker run --rm \
		-v "$(TEMP_REPO):/repo" \
		-v "$(PWD)/.stage0_template/test_data:/specifications" \
		-e LOG_LEVEL="$(LOG_LEVEL)" \
		-e SERVICE_NAME="$(SERVICE_NAME)" \
		"$(IMAGE)"

check-output:
	@echo "Checking output..."
	@diff -qr "$(PWD)/.stage0_template/test_expected/" "$(TEMP_REPO)/"
	@echo "Done."

test: setup-test debug-specs run-test-container check-output

dev:
	@echo "Shutting down centralized services..."
	@{{product.organization.developer_cli}} down || true
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
	{{product.organization.developer_cli}} up configurator
	make open

open:
	@echo "Opening browser..."
	open -a 'Google Chrome' 'http://localhost:8181' || google-chrome 'http://localhost:8181' || xdg-open 'http://localhost:8181'

down:
	@echo "Shutting down local containers..."
	@docker compose down || true
	@echo "Shutting down centralized services..."
	@{{product.organization.developer_cli}} down || true
