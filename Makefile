DOCKER_TAG ?= multiarch-test-${USER}

.PHONY: default
default: test

.PHONY:test
test:
	@echo ok

# Build Docker image for host architechture (amd64)
.PHONY: build
build:
	docker build . -t ${DOCKER_TAG}-linux-amd64

# Cross build for arm architechtures
.PHONY: cross-build-arm
cross-build-arm:
	docker build --build-arg REPO=arm32v6 --build-arg ARCH=arm . -t ${DOCKER_TAG}-linux-arm

.PHONY: cross-build-arm
cross-build-arm64:
	docker build --build-arg REPO=arm64v8 --build-arg ARCH=aarch64 . -t ${DOCKER_TAG}-linux-arm64

# Run on host architechture
.PHONY: run
run: build
	docker run ${DOCKER_TAG}-linux-amd64

# Cross run on host architechture
.PHONY: cross-run-arm
cross-run-arm: cross-build-arm
	docker run --rm ${DOCKER_TAG}-linux-arm

.PHONY: cross-run-arm64
cross-run-arm64: cross-build-arm64
	docker run --rm ${DOCKER_TAG}-linux-arm64
