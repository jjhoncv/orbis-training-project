
include makefiles/deploy-ghpages.mk
include makefiles/jenkins.mk

NETWORK_NAME = my-network
VOLUME = workspace
WORKDIR = /home/node
IMAGE = jjhoncv/orbis-training-docker:1.0.0

define create-network
	$(eval ID_NETWORK := $(shell docker network ls | grep $(NETWORK_NAME) | awk '{print $$1}'))
	@if [ ! $(ID_NETWORK) ]; then docker network create $(NETWORK_NAME); fi
endef

project-workspace:
	if docker rm $(VOLUME) ; then echo eliminando container $(VOLUME) ...; fi
	docker create -v $(WORKDIR) --name $(VOLUME) alpine:3.7
	docker cp ./ $(VOLUME):$(WORKDIR)/
	$(call create-network)

install:
	docker run -it --rm --volumes-from $(VOLUME) -w $(WORKDIR) --tty=false $(IMAGE) npm install
 
start:
	$(eval ID_CONTAINER := $(shell docker ps | grep npm-start | awk '{print $$1}'))	
	@if [ ! -d $(ID_CONTAINER) ]; then docker rm $(ID_CONTAINER) -f; fi
	docker run -it -d --rm --network $(NETWORK_NAME) --name npm-start -p 1042:1042 --volumes-from $(VOLUME) -w $(WORKDIR) --tty=false $(IMAGE) npm start

curl:
	$(eval ID_CONTAINER := $(shell docker ps | grep npm-start | awk '{print $$1}'))
	$(eval IP_CONTAINER := $(shell docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(ID_CONTAINER)))
	docker run -it --rm --network $(NETWORK_NAME) --tty=false $(IMAGE) curl -X GET http://$(IP_CONTAINER):1042

test:
	@make start
	@make curl

release:
	docker run --rm -it --volumes-from $(VOLUME) -w $(WORKDIR) --tty=false $(IMAGE) npm run release
	docker cp $(VOLUME):$(WORKDIR)/deploy ./