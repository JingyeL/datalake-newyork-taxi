# NYC Yellow Taxi Data Lake - Makefile
# Provides automation for building, testing, and deploying the data lake infrastructure

.PHONY: help clean install install-dev test lint format build-lambda package deploy-dev deploy-staging deploy-prod terraform-init terraform-plan terraform-apply terraform-destroy

# Default target
help: ## Show this help message
	@echo "NYC Yellow Taxi Data  - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Variables
PYTHON := poetry run python
POETRY := poetry
SRC_DIR := src
TEST_DIR := tests
LAMBDA_DIR := $(SRC_DIR)/
DIST_DIR := dist
INFRA_DIR := infra
ENV ?= dev

# Python Environment Management
install: ## Install production dependencies
	$(POETRY) install --only=main

install-dev: ## Install development dependencies
	$(POETRY) install --with dev

venv: ## Create virtual environment with Poetry
	$(POETRY) install
	@echo "Virtual environment created. Use: poetry shell"

# Code Quality
lint: ## Run all linting tools
	@echo "Running code quality checks..."
	$(POETRY) run isort --check-only $(SRC_DIR) $(TEST_DIR)
	$(POETRY) run black --check $(SRC_DIR) $(TEST_DIR)
	$(POETRY) run flake8 $(SRC_DIR) $(TEST_DIR)
	$(POETRY) run pylint $(SRC_DIR)
	$(POETRY) run mypy $(SRC_DIR) --ignore-missing-imports
	$(POETRY) run bandit -r $(SRC_DIR)
	$(POETRY) run safety check

format: ## Format code with black and isort
	@echo "Formatting code..."
	$(POETRY) run isort $(SRC_DIR) $(TEST_DIR)
	$(POETRY) run black $(SRC_DIR) $(TEST_DIR)

# Testing
test: ## Run tests
	@echo "Running tests..."
	$(POETRY) run pytest --cov=$(SRC_DIR) $(TEST_DIR) --cov-report=term-missing --cov-report=html

test-watch: ## Run tests in watch mode
	@echo "Running tests in watch mode..."
	$(POETRY) run pytest-watch --runner $(POETRY) run pytest

# Lambda Functions
build-lambda: clean-lambda ## Build all Lambda deployment packages
	@echo "Building Lambda deployment packages..."
	mkdir -p $(DIST_DIR)/lambda
	
	# Find all Lambda functions and package them
	@for lambda_func in $$(find $(LAMBDA_DIR) -name "*.py" -exec dirname {} \; | sort | uniq); do \
		if [ -f "$$lambda_func/requirements.txt" ]; then \
			func_name=$$(basename $$lambda_func); \
			echo "Building $$func_name..."; \
			mkdir -p $(DIST_DIR)/lambda/$$func_name; \
			cp -r $$lambda_func/* $(DIST_DIR)/lambda/$$func_name/; \
			cd $(DIST_DIR)/lambda/$$func_name; \
			$(POETRY) export --only=lambda --format=requirements.txt --output=requirements.txt --without-hashes; \
			pip install -r requirements.txt -t . --no-deps; \
			cd - > /dev/null; \
			cd $(DIST_DIR)/lambda && zip -r $$func_name.zip $$func_name/ -x "*.pyc" "*__pycache__*"; \
			rm -rf $$func_name; \
			cd - > /dev/null; \
		else \
			func_name=$$(basename $$lambda_func); \
			echo "Building $$func_name (no requirements.txt, using main deps)..."; \
			mkdir -p $(DIST_DIR)/lambda/$$func_name; \
			cp -r $$lambda_func/* $(DIST_DIR)/lambda/$$func_name/; \
			cd $(DIST_DIR)/lambda/$$func_name; \
			$(POETRY) export --only=main --format=requirements.txt --output=requirements.txt --without-hashes; \
			pip install -r requirements.txt -t . --no-deps; \
			cd - > /dev/null; \
			cd $(DIST_DIR)/lambda && zip -r $$func_name.zip $$func_name/ -x "*.pyc" "*__pycache__*"; \
			rm -rf $$func_name; \
			cd - > /dev/null; \
		fi \
	done

clean-lambda: ## Clean Lambda build artifacts
	@echo "🧹 Cleaning Lambda build artifacts..."
	rm -rf $(DIST_DIR)/lambda

package: build-lambda ## Create deployment package (alias for build-lambda)

# Infrastructure Management
terraform-init: ## Initialize Terraform for an environment
	@echo "Initializing Terraform for $(ENV) environment..."
	cd $(INFRA_DIR)/envs/$(ENV) && terraform init

terraform-plan: terraform-init ## Plan Terraform changes
	terraform-plan: ## Plan Terraform changes for an environment
	@echo "Planning Terraform changes for $(ENV) environment..."
	cd $(INFRA_DIR)/envs/$(ENV) && terraform plan -detailed-exitcode -out=$(ENV).tfplan

terraform-apply: ## Apply Terraform changes
	terraform-apply: ## Apply Terraform changes for an environment
	@echo "Applying Terraform changes for $(ENV) environment..."
	cd $(INFRA_DIR)/envs/$(ENV) && terraform apply $(ENV).tfplan

terraform-destroy: ## Destroy Terraform infrastructure (be careful!)
	@echo "Destroying Terraform infrastructure for $(ENV) environment..."
	@read -p "Are you sure you want to destroy $(ENV) infrastructure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd $(INFRA_DIR)/envs/$(ENV) && terraform destroy; \
	else \
		echo "Destruction cancelled."; \
	fi

terraform-fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	cd $(INFRA_DIR) && terraform fmt -recursive

terraform-validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@for env_dir in $(INFRA_DIR)/envs/*/; do \
		echo "Validating $$(basename $$env_dir)..."; \
		cd $$env_dir && terraform init -backend=false && terraform validate; \
		cd - > /dev/null; \
	done

# Deployment
deploy-dev: build-lambda terraform-plan ## Deploy to development environment
	@echo "Deploying to development environment..."
	$(MAKE) terraform-apply ENV=dev
	$(MAKE) update-lambda-code ENV=dev

deploy-staging: build-lambda ## Deploy to staging environment
	@echo "Deploying to staging environment..."
	$(MAKE) terraform-apply ENV=staging
	$(MAKE) update-lambda-code ENV=staging

deploy-prod: build-lambda ## Deploy to production environment
	@echo "Deploying to production environment..."
	@read -p "Are you sure you want to deploy to PRODUCTION? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) terraform-apply ENV=prod; \
		$(MAKE) update-lambda-code ENV=prod; \
	else \
		echo "Production deployment cancelled."; \
	fi

update-lambda-code: ## Update Lambda function code
	update-lambda-code: ## Update Lambda function code (existing infrastructure)
	@echo "Updating Lambda function code for $(ENV) environment..."
	@if [ -d "$(DIST_DIR)/lambda" ]; then \
		for zip_file in $(DIST_DIR)/lambda/*.zip; do \
			if [ -f "$$zip_file" ]; then \
				function_name=$$(basename $$zip_file .zip); \
				aws_function_name="nycyellowtaxi-datalake-$(ENV)-$$function_name"; \
				echo "Updating function: $$aws_function_name"; \
				aws lambda update-function-code \
					--function-name "$$aws_function_name" \
					--zip-file "fileb://$$zip_file" || echo "Function $$aws_function_name not found"; \
			fi \
		done \
	else \
		echo "No Lambda packages found. Run 'make build-lambda' first."; \
	fi

# Data Operations
ingest-sample-data: ## Ingest sample NYC taxi data
	@echo "Ingesting sample data..."
	$(POETRY) run python scripts/ingest_sample_data.py --env $(ENV)

run-crawler: ## Run Glue crawler to catalog data
	@echo "Running Glue crawler..."

check-pipeline: ## Check pipeline status
	@echo "📊 Checking pipeline status..."
	aws stepfunctions list-executions --state-machine-arn $$(cd $(INFRA_DIR)/envs/$(ENV) && terraform output -raw data_pipeline_state_machine_arn)

# Utilities
clean: clean-lambda ## Clean all build artifacts
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(DIST_DIR)
	rm -rf htmlcov/
	rm -rf .coverage
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	find . -type d -name __pycache__ -delete
	find . -type f -name "*.pyc" -delete

logs: ## View Lambda function logs
	@echo "📋 Viewing Lambda logs for $(ENV) environment..."
	aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/nycyellowtaxi-datalake-$(ENV)"

setup-dev: install-dev ## Setup development environment
	@echo "🛠️ Setting up development environment..."
	pre-commit install
	@echo "✅ Development environment ready!"

# CI/CD Helper Commands
ci-test: install-dev lint test ## Run all CI tests locally

ci-build: clean build-lambda ## Build for CI/CD pipeline

# Documentation
docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	cd $(INFRA_DIR) && terraform-docs markdown table --output-file README.md modules/

# Security
security-scan: ## Run security scans
	@echo "🔒 Running security scans..."
	bandit -r $(SRC_DIR) -f json -o bandit-report.json
	safety check --json --output safety-report.json
	# Terraform security scanning
	cd $(INFRA_DIR) && tfsec .

# Environment Management
create-env-files: ## Create environment-specific variable files
	@echo "📝 Creating environment variable files..."
	@for env in dev staging prod; do \
		if [ ! -f "$(INFRA_DIR)/envs/$$env/terraform.tfvars" ]; then \
			echo "Creating terraform.tfvars for $$env..."; \
			echo "# $$env environment variables" > $(INFRA_DIR)/envs/$$env/terraform.tfvars; \
			echo "aws_region = \"us-east-1\"" >> $(INFRA_DIR)/envs/$$env/terraform.tfvars; \
			echo "environment = \"$$env\"" >> $(INFRA_DIR)/envs/$$env/terraform.tfvars; \
		fi \
	done

# Version and Release
version: ## Show version information
	@echo "NYC Yellow Taxi Data Lake"
	@echo "Python: $$($(POETRY) run python --version)"
	@echo "Terraform: $$(terraform version -json | jq -r .terraform_version)"
	@echo "AWS CLI: $$(aws --version)"

# Quick setup for new developers
quickstart: install install-dev setup-dev terraform-fmt terraform-validate ## Quick setup for new developers
	@echo ""
	@echo "🎉 Quickstart complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Configure AWS credentials: aws configure"
	@echo "2. Initialize Terraform: make terraform-init ENV=dev"
	@echo "3. Plan infrastructure: make terraform-plan ENV=dev"
	@echo "4. Deploy to dev: make deploy-dev"
	@echo ""
