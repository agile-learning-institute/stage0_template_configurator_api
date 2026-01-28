.PHONY: help dev container deploy open down test merge

help:
	@echo "Available commands:"
	@echo "  make dev              - Run development runtime to edit configurations"
	@echo "  make container        - Build Docker container for deployment"
	@echo "  make deploy           - Run packaged configuration (read-only)"
	@echo "  make open             - Open browser for running containers"
	@echo "  make down             - Shut down containers"
## <!-- TEMPLATE_SPECIFIC_START -->
## This section will be removed during template processing
	@echo "  make test             - Run tests using ~/temp folder"
	@echo "  make clean            - Clean up temporary test files"
	@echo "  make merge            - Merge templates and remove template configuration"
## <!-- TEMPLATE_SPECIFIC_END -->

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

## <!-- TEMPLATE_SPECIFIC_START -->
## This section will be removed during template processing
test:
	@TEMP_REPO="$$HOME/tmp/testRepo"; \
	echo "Setting up temporary testing folder at $$TEMP_REPO..."; \
	rm -rf "$$TEMP_REPO"; \
	mkdir -p "$$TEMP_REPO"; \
	cp -r . "$$TEMP_REPO"
	@echo "Debug: Checking specifications structure..."; \
	find .stage0_template/test_data -name "*.yaml" | head -10
	@echo "Running the container..."; \
	LOG_LEVEL="$${LOG_LEVEL:-INFO}"; \
	docker run --rm \
		-v "$$HOME/tmp/testRepo:/repo" \
		-v "$$(pwd)/.stage0_template/test_data:/specifications" \
		-e LOG_LEVEL="$$LOG_LEVEL" \
		-e SERVICE_NAME=mongodb \
		ghcr.io/agile-learning-institute/stage0_runbook_merge:latest
	@echo "Checking output..."; \
	diff -qr "$$(pwd)/.stage0_template/test_expected/" "$$HOME/tmp/testRepo/"
	@echo "Done."

clean:
	@echo "Removing temporary test repo at $$HOME/tmp/testRepo..."; \
	rm -rf "$$HOME/tmp/testRepo"

merge:
	@CONTEXT_PATH="$(firstword $(filter-out $@,$(MAKECMDGOALS)))"; \
	if [ -z "$$CONTEXT_PATH" ]; then \
		echo "Usage: make merge /path/to/specifications"; \
		exit 1; \
	fi; \
	if [ ! -d "$$CONTEXT_PATH" ]; then \
		echo "Error: $$CONTEXT_PATH does not exist or is not a directory"; \
		exit 1; \
	fi; \
	echo "Running merge with specifications from $$CONTEXT_PATH"; \
	LOG_LEVEL="$${LOG_LEVEL:-INFO}"; \
	docker run --rm \
		-v "$$(pwd):/repo" \
		-v "$$CONTEXT_PATH:/specifications" \
		-e LOG_LEVEL="$$LOG_LEVEL" \
		-e SERVICE_NAME=mongodb \
		ghcr.io/agile-learning-institute/stage0_runbook_merge:latest

%:
	@:
## <!-- TEMPLATE_SPECIFIC_END -->
