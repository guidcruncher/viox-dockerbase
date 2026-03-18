## Variables
IMAGE_NAME := guidcruncher/vioxbase
CONTAINER_NAME := vioxbase
DOCKER_COMPOSE := docker compose
DOCKER_RUN := docker run --rm -v $(PWD):/app -w /app

.PHONY: help build publish

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the base image
	docker buildx build \
        --file ./Dockerfile \
		--tag docker.io/$(IMAGE_NAME):alpine-latest \
		.

publish: ## Publish the base image
	docker buildx build \
		--file ./Dockerfile \
		--tag docker.io/$(IMAGE_NAME):alpine-latest \
		--tag docker.io/$(IMAGE_NAME):alpine-$(ARGS) \
		--push \
		.
