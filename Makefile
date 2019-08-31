IMAGE=workspace-golang
CONTAINER=workspace
USER=user
UID=500
GID=500

build: ## Build docker image
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) -f Dockerfile .

run: ## Run a container
	docker run -ti --name $(CONTAINER) workspace-golang

attach: ## Attach to existing container
	-@docker start $(CONTAINER)
	docker attach $(CONTAINER)

clean: ## Remove existing container
	-docker rm -f $(CONTAINER)

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9/_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
