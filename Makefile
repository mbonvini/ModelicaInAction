all:	help

build: ## Creates an image based using the Dockerfile.
	docker build ./docker/ -t jmodelica:1.0

run: ## Starts the container and attaches a terminal to it.
	docker run -d -v $(shell pwd)/modelica:/home/docker/modelica \
	-v $(shell pwd)/ipynotebooks:/home/docker/ipynotebooks \
	-p 127.0.0.1:8888:8888 jmodelica:1.0 \
	sh -c 'ipython notebook --no-browser --matplotlib=inline --ip=0.0.0.0 --port=8888 --notebook-dir=/home/docker/ipynotebooks'

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