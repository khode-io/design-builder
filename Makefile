# Design Builder Flutter - Publishing Commands
# Based on: https://dart.dev/tools/pub/publishing

PACKAGE_PATH = packages/design_builder_flutter
PUBSPEC = $(PACKAGE_PATH)/pubspec.yaml

# Colors for output
BLUE = \033[34m
GREEN = \033[32m
YELLOW = \033[33m
RED = \033[31m
RESET = \033[0m

.PHONY: help version analyze test dry-run publish tag release docs-dev docs-build docs-preview docs-install

## Show this help message
help:
	@echo "$(BLUE)Design Builder Flutter - Publishing Commands$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@grep -E '^##|^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Publishing workflow:$(RESET)"
	@echo "  1. make analyze    - Check code quality"
	@echo "  2. make test       - Run tests"
	@echo "  3. make dry-run    - Test publishing (dry run)"
	@echo "  4. Update version in pubspec.yaml"
	@echo "  5. Update CHANGELOG.md"
	@echo "  6. Commit and push changes"
	@echo "  7. make tag        - Create and push version tag"
	@echo "  8. GitHub Actions will auto-publish to pub.dev"

## Show current package version
version:
	@echo "$(BLUE)Current package version:$(RESET)"
	@grep "^version:" $(PUBSPEC) | sed 's/version: //'

## Format code in the package
format:
	@echo "$(BLUE)Formatting code...$(RESET)"
	@cd $(PACKAGE_PATH) && dart format .
	@echo "$(GREEN)✓ Code formatted$(RESET)"

## Analyze code for issues
analyze:
	@echo "$(BLUE)Analyzing code...$(RESET)"
	@cd $(PACKAGE_PATH) && flutter analyze
	@echo "$(GREEN)✓ Analysis complete$(RESET)"

## Run tests
_test:
	@echo "$(BLUE)Running tests...$(RESET)"
	@cd $(PACKAGE_PATH) && flutter test
	@echo "$(GREEN)✓ Tests complete$(RESET)"

test: _test

## Get dependencies
deps:
	@echo "$(BLUE)Getting dependencies...$(RESET)"
	@cd $(PACKAGE_PATH) && flutter pub get
	@echo "$(GREEN)✓ Dependencies installed$(RESET)"

## Run all checks before publishing (format, analyze, test)
check: format analyze test
	@echo "$(GREEN)✓ All checks passed! Ready to publish.$(RESET)"

## Dry run - test publishing without actually publishing
dry-run: check
	@echo "$(YELLOW)Running dry-run publish...$(RESET)"
	@cd $(PACKAGE_PATH) && dart pub publish --dry-run
	@echo "$(GREEN)✓ Dry-run complete. Check output above for any issues.$(RESET)"

## Publish to pub.dev (manual - requires authentication)
publish: check
	@echo "$(RED)Warning: This will publish directly to pub.dev$(RESET)"
	@echo "$(YELLOW)Consider using 'make tag' to trigger GitHub Actions publishing instead.$(RESET)"
	@read -p "Are you sure you want to publish? (yes/no): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@cd $(PACKAGE_PATH) && dart pub publish

## Create and push a version tag (triggers GitHub Actions release)
tag:
	@echo "$(BLUE)Creating version tag...$(RESET)"
	@VERSION=$$(grep "^version:" $(PUBSPEC) | sed 's/version: //' | xargs) && \
	echo "Creating tag v$$VERSION..." && \
	git tag -a "v$$VERSION" -m "Release v$$VERSION" && \
	git push origin "v$$VERSION" && \
	echo "$(GREEN)✓ Tag v$$VERSION pushed. GitHub Actions will publish to pub.dev.$(RESET)"

## Full release workflow: check, dry-run, and instructions
release: check dry-run
	@echo ""
	@echo "$(GREEN)✓ Package is ready for release!$(RESET)"
	@echo ""
	@echo "$(BLUE)Next steps:$(RESET)"
	@echo "  1. Review the dry-run output above"
	@echo "  2. Make sure CHANGELOG.md is updated"
	@echo "  3. Commit all changes: $(YELLOW)git add . && git commit -m \"Prepare release\"$(RESET)"
	@echo "  4. Push to origin: $(YELLOW)git push origin main$(RESET)"
	@echo "  5. Create tag: $(YELLOW)make tag$(RESET)"
	@echo "  6. GitHub Actions will automatically publish to pub.dev"

# ============================================================================
# Documentation Commands (Starlight/Astro)
# ============================================================================

## Install docs dependencies
docs-install:
	@echo "$(BLUE)Installing docs dependencies...$(RESET)"
	@cd docs && npm install
	@echo "$(GREEN)✓ Docs dependencies installed$(RESET)"

## Run docs in development mode
docs-dev:
	@echo "$(BLUE)Starting docs development server...$(RESET)"
	@cd docs && npm run dev

## Build the docs site
docs-build:
	@echo "$(BLUE)Building docs site...$(RESET)"
	@cd docs && npm run build
	@echo "$(GREEN)✓ Docs build complete$(RESET)"

## Preview the built docs
docs-preview:
	@echo "$(BLUE)Previewing built docs...$(RESET)"
	@cd docs && npm run preview
