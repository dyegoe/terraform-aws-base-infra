.ONESHELL :

CURRENT_DIR := $(shell pwd)
CURRENT_UID := $(shell id -u)
CONTAINER_IMAGE := "quay.io/terraform-docs/terraform-docs:0.16.0"

# DOCS
.PHONY : gen-docs
gen-docs: ## Generates module documentation using terraform-docs Docker image.
	@echo Generating documentation
	@docker run --rm \
		-v $(CURRENT_DIR):/terraform-docs \
		-u $(CURRENT_UID) \
		-it $(CONTAINER_IMAGE) markdown /terraform-docs

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## List all availables Makefile subcommands for this repository.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help