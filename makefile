
# Misc
.DEFAULT_GOAL := help
.PHONY        = help build

## —— 🎵 🐳 Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

build: ## Build image with PHP version specified in php=<version> argument, e.g. `make build php=8.4`
	@$(eval php ?=)
	docker build --build-arg PHP_VERSION=$(php) -t sqli/phpqa:php$(php) - < ./Dockerfile

sh: ## Run container with PHP version specified in php=<version> argument, e.g. `make sh php=8.4`
	@$(eval php ?=)
	docker run --init -it --rm --network host -v .:/project -v /tmp/phpqa:/tmp -w /project sqli/phpqa:php$(php) bash