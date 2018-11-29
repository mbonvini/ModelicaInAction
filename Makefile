#
# This Makefile contains commands to build the Docker
# image and starting containers.
#
all:	help
.PHONY: all

CONTAINER_NAME=modelicainaction/jmodelica
VERSION=1.0

build-image: ## Creates an image based using the Dockerfile.
	docker build ./docker$(VERSION)/ -t $(CONTAINER_NAME):$(VERSION)
.PHONY: build-image

download-image: ## Downloads the image from Dockerhub
	docker pull $(CONTAINER_NAME):$(VERSION)
.PHONY: download-image

start: ## Starts the container in detached mode and exposes ipython notebook server listening on port 8888.
ifeq ($(VERSION), 1.0)
	$(MAKE) start-ipython
else
	$(MAKE) start-jupyter
endif
.PHONY: start

start-ipython:
	docker run -d -v $(shell pwd)/modelica:/home/docker/modelica \
	-v $(shell pwd)/ipynotebooks:/home/docker/ipynotebooks \
	-p 127.0.0.1:8888:8888 $(CONTAINER_NAME):$(VERSION) \
	sh -c 'ipython notebook --no-browser --matplotlib=inline --ip=0.0.0.0 --port=8888 --notebook-dir=/home/docker/ipynotebooks'
.PHONY: start-ipython

start-jupyter:
	docker run -d -v $(shell pwd)/modelica:/home/docker/modelica \
	-v $(shell pwd)/ipynotebooks:/home/docker/ipynotebooks \
	-p 127.0.0.1:8888:8888 $(CONTAINER_NAME):$(VERSION) \
	sh -c 'jupyter notebook --no-browser --ip=0.0.0.0 --port=8888 --notebook-dir=/home/docker/ipynotebooks'
.PHONY: start-jupyter

start-i: ## Starts the container in interactive mode
	docker run -t -i --rm -v $(shell pwd)/modelica:/home/docker/modelica \
	-v $(shell pwd)/ipynotebooks:/home/docker/ipynotebooks \
	$(CONTAINER_NAME):$(VERSION) /bin/bash
.PHONY: start-i

remove-containers: ## Remove the containers with status = Exited
	docker ps -a | grep "Exited (" | awk '{print $1}' | xargs docker rm
.PHONY: remove-containers

help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done
.PHONY: help
