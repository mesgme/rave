.DEFAULT_GOAL := help

REPOS := rave-spec rave-cli ravegraph rave-swamp

.PHONY: help get status build test

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

get: ## Clone all repos into this workspace
	@[ -d rave-spec ]  || git clone git@github.com:mesgme/rave-spec.git
	@[ -d rave-cli ]   || git clone git@github.com:mesgme/rave-cli.git
	@[ -d ravegraph ]  || git clone git@github.com:mesgme/ravegraph.git
	@[ -d rave-swamp ] || git clone git@github.com:mesgme/rave-swamp.git

status: ## Show git status across all repos
	@for repo in $(REPOS); do \
		echo "\n── $$repo ──"; \
		git -C $$repo status --short 2>/dev/null || echo "  (not cloned)"; \
	done

build: ## Build all projects
	@echo "── rave-cli ──" && cd rave-cli && npm run build
	@echo "── ravegraph ──" && cd ravegraph && npm run build

test: ## Run tests across all projects
	@echo "── rave-cli ──" && cd rave-cli && npm test
	@echo "── ravegraph ──" && cd ravegraph && npm test
