
include makefiles/deploy-ghpages.mk

image-jenkins-jjhoncv:
	docker build -t jjhoncv/jenkins-deploy:0.1.0 docker/jenkins

build-jenkins:
	docker run --rm -u root -p 8080:8080 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME":/home jjhoncv/jenkins-deploy:0.1.0

create-workspace:
	if docker rm workspace ; then echo eliminando container workspace ...; fi
	echo "creando container temporal de la imagen: workspace ..."
	docker create -v /home/node --name workspace node:10.10.0-slim docker/node
	docker cp ./ workspace:/home/node/

create-network:
	$(eval NETWORK := $(shell docker network ls | grep my-network | awk '{print $$2}'))
	@if [ ! -d "$(NETWORK)" ]; then docker network remove my-network; fi
	docker network create my-network
 
install:
	docker run -it --rm --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm install

start:
	$(eval ID_CONTAINER := $(shell docker ps | grep npm-start | awk '{print $$1}'))	
	@if [ ! -d "$(ID_CONTAINER)" ]; then docker rm $(ID_CONTAINER) -f; fi
	docker run -it -d --rm --network my-network --name npm-start -p 1042:1042 --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm start

curl:
	$(eval ID_CONTAINER := $(shell docker ps | grep npm-start | awk '{print $$1}'))
	$(eval IP_CONTAINER := $(shell docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(ID_CONTAINER)))
	docker run -it --rm --network my-network --tty=false jjhoncv/orbis-training-docker:1.0.0 curl -X GET http://$(IP_CONTAINER):1042
	docker rm $(ID_CONTAINER) -f

test:
	@make start
	@make curl

release:
	docker run --rm -it --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm run release
	docker cp workspace:/home/node/deploy ./