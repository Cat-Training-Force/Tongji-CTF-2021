#
# Copyright (c) 2020, Pixels Camp
#


ifneq (,$(wildcard ./.make))
	include .make
	export
endif


#
# To configure SSH access for the deployment host, create a ".make" file
# in the same directory as this Makefile setting these three variables.
#
SSH_USER ?= pixel
SSH_HOST ?= red-october.pixels.camp
SSH_PORT ?= 22

# This can also be set from the ".env" file...
TRIGGER_TEXT ?= Sean Connery
RESPONSE_FILE ?= data/sean_connery.txt
LOG_FILE ?= /dev/stdout


# Must be evaluated on assignment, or trouble will ensue...
DOCKER_LABEL := $(shell date +%Y%m%d-%H%M%S)-$(shell git rev-parse --short HEAD)

SSH_HOST_CMD := ssh -q -l $(SSH_USER) $(SSH_HOST) -p $(SSH_PORT)


all: test build  # ...do not deploy, to avoid accidents.

update-images:
	awk '/^FROM[[:space:]]+/ {print $$2}' Dockerfile | xargs -I{} docker pull {}

clean:
	find . -name '*~' -type f -delete
	find . -name '*.pyc' -type f -delete
	find . -name '__pycache__' -type d -delete
	find . -name '*.egg-info' -type d -delete

build:
	flake8 src
	docker build -t ping-responder:latest -f Dockerfile .

push: build
	docker save ping-responder:latest | gzip | $(SSH_HOST_CMD) -- ' \
		gunzip | docker load; \
		docker tag ping-responder:latest ping-responder:$(DOCKER_LABEL); \
	'

deploy: push
	$(SSH_HOST_CMD) -- ' \
		docker container stop ping-responder >/dev/null 2>&1 || true; \
		docker container rm ping-responder >/dev/null 2>&1 || true; \
		docker run -d --restart=always --init --name=ping-responder \
		              --memory-swap=64m --memory=64m --cpus=0.25 \
					  --mount type=bind,source=/var/log/ping-responder,target=/var/log/ping-responder \
					  --read-only --net=host ping-responder:latest \
					  ./ping-responder.py -i eth0 \
					                      -t "$(TRIGGER_TEXT)" -z \
					                      -f "$(RESPONSE_FILE)" -r \
					                      -l "$(LOG_FILE)"; \
	'

.PHONY: all build deploy update-images clean
