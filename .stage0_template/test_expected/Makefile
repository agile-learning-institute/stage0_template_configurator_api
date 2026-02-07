.PHONY: help dev container deploy open down

help:
	@echo "Available commands:"
	@echo "  make dev              - Run development runtime to edit configurations"
	@echo "  make container        - Build Docker container for deployment"
	@echo "  make deploy           - Run packaged configuration (read-only)"
	@echo "  make open             - Open browser for running containers"
	@echo "  make down             - Shut down containers"

dev:
	@echo "Shutting down centralized services..."
	@mh down || true
	@echo "Starting local development services..."
	@export INPUT_FOLDER=$$(pwd)/configurator && docker compose up -d
	@make open

container:
	@echo "Building Docker container image..."
	docker build -t ghcr.io/agile-learning-institute/mentorhub_mongodb_api:latest .
	make deploy

deploy:
	@echo "Deploying packaged configuration..."
	make down
	mh up mongodb
	make open

open:
	@echo "Opening browser..."
	open -a 'Google Chrome' 'http://localhost:8386' || google-chrome 'http://localhost:8386' || xdg-open 'http://localhost:8386'

down:
	@echo "Shutting down local containers..."
	@docker compose down || true
	@echo "Shutting down centralized services..."
	@mh down || true
