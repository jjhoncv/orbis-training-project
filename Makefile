
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

start:
	docker run -it --rm -p 1042:1042 --volumes-from workspace -w /home/node --tty=false  jjhoncv/orbis-training-docker:1.0.0 npm start
	#docker run -it --rm -p 1042:1042 -v $(PWD):/app/ -w /app  jjhoncv/orbis-training-docker:1.0.0 npm start

install:
	#docker run -v $(PWD):/app/ -w /app jjhoncv/orbis-training-docker:1.0.0 npm install
	docker run -it --rm --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm install

test:
	@make start

deploy:
	echo deploy!!

release:
	docker run --rm -it --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm run release
	docker cp workspace:/home/node/deploy ./