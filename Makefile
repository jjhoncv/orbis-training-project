include makefiles/deploy-ghpages.mk
include makefiles/jenkins.mk

NETWORK_NAME = my-network
CONTAINER_TMP = workspace
WORKDIR = /home/node
IMAGE = jjhoncv/orbis-training-docker:1.0.0

define create-network
	$(eval ID_NETWORK := $(shell docker network ls | grep $(NETWORK_NAME) | awk '{print $$1}'))
	@if [ ! $(ID_NETWORK) ]; then docker network create $(NETWORK_NAME); fi
endef

project-workspace:
	if docker rm $(CONTAINER_TMP) ; then echo eliminando container $(CONTAINER_TMP) ...; fi
	docker create -v $(WORKDIR) --name $(CONTAINER_TMP) alpine:3.7
	docker cp ./ $(CONTAINER_TMP):$(WORKDIR)/
	$(call create-network)

install:
	docker run -it --rm --volumes-from $(CONTAINER_TMP) -w $(WORKDIR) --tty=false $(IMAGE) npm install
 
start:
	$(eval ID_CONTAINER := $(shell docker ps | grep NPM_START | awk '{print $$1}'))	
	@if [ ! -d $(ID_CONTAINER) ]; then docker rm $(ID_CONTAINER) -f; fi
	docker run -it -d --rm --network $(NETWORK_NAME) --name NPM_START -p 1042:1042 --volumes-from $(CONTAINER_TMP) -w $(WORKDIR) --tty=false $(IMAGE) npm start

curl:
	docker run -it --rm --network $(NETWORK_NAME) --tty=false $(IMAGE) curl -X GET http://NPM_START:1042

test:
	@make start
	@make curl

release:
	docker run --rm -it --volumes-from $(CONTAINER_TMP) -w $(WORKDIR) --tty=false $(IMAGE) npm run release
	docker cp $(CONTAINER_TMP):$(WORKDIR)/deploy ./