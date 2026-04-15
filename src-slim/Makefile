## Variables
IMAGE_NAME := guidcruncher/pipewire-server
CONTAINER_NAME := pipewire-server
DOCKER_COMPOSE := docker compose
DOCKER_RUN := docker run --rm -v $(PWD):/app -w /app

.PHONY: help build publish

VERSION ?=


help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the base image
	docker buildx build --progress=plain \
        --file ./Dockerfile \
		--tag docker.io/$(IMAGE_NAME):latest \
		.

publish: ## Publish the base image (requires VERSION=x.y.z)
ifeq ($(VERSION),)
	$(error VERSION is required for publish, e.g. make publish VERSION=1.0.0)
endif
	docker buildx build --progress=plain \
		--file ./Dockerfile \
		--tag docker.io/$(IMAGE_NAME):latest \
		--tag docker.io/$(IMAGE_NAME):$(VERSION) \
		--push \
		.
