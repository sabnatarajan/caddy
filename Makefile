SHELL         = /usr/bin/env bash
.DEFAULT_GOAL = help
PLATFORM      ?= linux/amd64
REPO          = ghcr.io/sabnatarajan
PROJECT       = caddy
VERSIONS      = $(shell cat versions.txt)
MODULE_NAMES  = $(shell cat modules.txt | cut -d':' -f1)
# Cartesian product of VERSIONS and MODULE_NAMES
COMBINED      = $(foreach X,$(VERSIONS),$(foreach Y,$(MODULE_NAMES),$X-$Y))

# Make targets
build_prefix  = build-
build_targets = $(addprefix $(build_prefix),$(COMBINED))

# helper function to parse arguments to Make targets
define parse
	$(eval ARGS=$(@:$1%=%))
	$(eval CADDY_VERSION=$(word 1, $(subst -, , ${ARGS})))
	$(eval CADDY_MODULES=$(word 2, $(subst -, , ${ARGS})))
	$(info Caddy version: ${CADDY_VERSION})
	$(info Caddy modules: ${CADDY_MODULES})
endef

.PHONY: $(build_targets)
$(build_targets): $(build_prefix)%: ## Build Docker image for a specific version
	$(call parse,$(build_prefix),$@)
	@docker buildx build \
		--platform $(PLATFORM) \
		--file Dockerfile \
		--build-arg CADDY_VERSION=${CADDY_VERSION} \
		--target ${CADDY_MODULES} \
		--tag $(REPO)/$(PROJECT):${CADDY_VERSION}-${CADDY_MODULES} \
		.

.PHONY: help
help: ## Display this help
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
