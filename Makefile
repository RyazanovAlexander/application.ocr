BUILDDIR ?= build

# git
LASTTAG := $(shell git tag --sort=committerdate | tail -1)

# docker option
DTAG   ?= $(LASTTAG)
DFNAME ?= Dockerfile
DRNAME ?= docker.io/aryazanov

# example
TMPFOLDER ?= ./tmp

# ------------------------------------------------------------------------------
#  init

init:
	sudo apt update
	sudo apt install jq

# ------------------------------------------------------------------------------
#  containers

.PHONY: containers
containers:
	@docker build --build-arg COMMAND_EXECUTOR_VERSION=$(shell jq '."command-executor-tag"' build-meta.jsonc) -t $(DRNAME)/ocr-wget:$(DTAG) -f ./$(BUILDDIR)/Wget/$(DFNAME) .
	@docker build --build-arg COMMAND_EXECUTOR_VERSION=$(shell jq '."command-executor-tag"' build-meta.jsonc) -t $(DRNAME)/ocr-tesseract:$(DTAG) -f ./$(BUILDDIR)/Tesseract/$(DFNAME) .
	@docker build --build-arg COMMAND_EXECUTOR_VERSION=$(shell jq '."command-executor-tag"' build-meta.jsonc) -t $(DRNAME)/ocr-mc:$(DTAG) -f ./$(BUILDDIR)/MinIOClient/$(DFNAME) .
	
	@docker push $(DRNAME)/ocr-wget:$(DTAG)
	@docker push $(DRNAME)/ocr-tesseract:$(DTAG)
	@docker push $(DRNAME)/ocr-mc:$(DTAG)

# ------------------------------------------------------------------------------
#  deploy

.PHONY: deploy
deploy:
	rm -rf $(TMPFOLDER) && mkdir $(TMPFOLDER)
	export PIPELINE_AGENT_VERSION=$(shell jq '."pipeline-agent-tag"' build-meta.jsonc); \
	export COMMAND_EXECUTOR_VERSION=$(shell jq '."command-executor-tag"' build-meta.jsonc); \
	export COMMAND_EXECUTOR_ALPINE_VERSION=$(shell jq '."command-executor-alpine-tag"' build-meta.jsonc); \
	envsubst < ./skaffold.yaml > $(TMPFOLDER)/skaffold.gen
	skaffold dev -f $(TMPFOLDER)/skaffold.gen --port-forward --no-prune=false --cache-artifacts=false

# ------------------------------------------------------------------------------
#  delete

.PHONY: delete
delete:
	skaffold delete
	rm -rf $(TMPFOLDER)

# ------------------------------------------------------------------------------
#  minikube-clear

.PHONY: minikube-clear
minikube-clear:
	minikube image ls | grep pipeline-agent | xargs -I{} minikube image rm {}
	minikube image ls | grep ocr-wget | xargs -I{} minikube image rm {}
	minikube image ls | grep ocr-tesseract | xargs -I{} minikube image rm {}
	minikube image ls | grep ocr-mc | xargs -I{} minikube image rm {}