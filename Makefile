## This is a self-documented Makefile. For usage information, run `make help`:
##
## For more information, refer to https://www.thapaliya.com/en/writings/well-documented-makefiles/
.DEFAULT_GOAL:=help

# Default Debian image to use for building, can be overridden by passing DEBIAN_IMAGE to make
DEBIAN_IMAGE ?= debian:trixie

# Default NGINX version to build, can be overridden by passing NGINX_VERSION to make
NGINX_VERSION ?= 1.29.4

# Default build modules, can be overridden by passing BUILD_MODULES to make
BUILD_MODULES ?= ndk lua

.PHONY: help

build:  ## Build the Docker image
	docker build --build-arg DEBIAN_IMAGE="$(DEBIAN_IMAGE)" --build-arg NGINX_VERSION="$(NGINX_VERSION)" --build-arg BUILD_MODULES="$(BUILD_MODULES)" -t nginx-extra-module-builder .

run:  ## Run the Docker container
	docker run -v $(PWD)/output:/output nginx-extra-module-builder

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)