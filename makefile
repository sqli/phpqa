VERSION_QA := $(shell cat VERSION_QA)
VERSION_PHP := $(shell cat VERSION_PHP)

# Misc
.DEFAULT_GOAL := help
.PHONY        = help build

## —— 🎵 🐳 Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

build: ## Build image with PHP version specified in VERSION_PHP file
	@$(eval php ?=)
	docker build --build-arg PHP_VERSION=$(VERSION_PHP) -t docdams/phpqa:$(VERSION_QA)-php$(VERSION_PHP) - < ./Dockerfile

sh: ## Run container with PHP version specified in VERSION_PHP file
	@$(eval php ?=)
	docker run --init -it --rm --network host -v .:/project -v /tmp/phpqa:/tmp -w /project docdams/phpqa:$(VERSION_QA)-php$(VERSION_PHP) bash
