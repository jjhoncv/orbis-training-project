# Create image from name and version
> docker build -t jjhoncv/orbis-training-docker:0.1.0 .
# Docker Run

## Push image dockerhub
> docker push jjhoncv/orbis-training-docker

## Create tag
> docker tag jjhoncv/orbis-training-dockwer jjhoncv/orbis-training-docker:0.2.0 

## Install dependencies node
> docker run -it -v $(pwd):/app/ -w /app jjhoncv/orbis-training-docker:1.0.0 npm install

## node run
> docker run -it -v $(pwd):/app/ -p 3030:3030 -p 35729:35729 -w /app jjhoncv/orbis-training-docker:1.0.0 npm run start

## node run change port
> docker run -it -v $(pwd):/app/ -p 1042:1042 -p 35729:35729 -w /app jjhoncv/orbis-training-docker:1.0.0 npm run start

## node run release
> docker run -it -v $(pwd):/app/ -p 1042:1042 -p 35729:35729 -w /app jjhoncv/orbis-training-docker:1.0.0 npm run release

## Docker Compose
version: '3'
services:
  web:
    working_dir: /app 
    ports:
    - "1042:1042"
    - "35729:35729"
    volumes:
    - .:/app/
    image: jjhoncv/orbis-training-docker:1.0.0
    command: npm run start

## Para conectar un container a una network
1. ip
2. name container
3. name service

## Para crear una Network
Docker network create

## Docker curl service up from docker-compose
> docker run -it --network orbis-training-project_default jjhoncv/orbis-training-docker:1.0.0 curl -X GET http://web:1042

* Por defecto docker-compose crea una red "orbis-training-project_default", en la cual desde docker run te conectas a la red con --network, usas la imagen para este contenedor "jjhoncv/orbis-training-docker:1.0.0" y ejecutas el comando de "curl -X GET http://web:1042", donde "web" seria el nombre del servicio en docker-compose, donde al momento de crear el container asoció este nombre a su IP.

Es por eso que al hacer "curl -X GET http://web:1042", hacer CURL directamente al container.

#### Se tiene q conocer la ip del container:

1. Obtener todos los container levantados:
> docker ps

2. Seleccionar el ID-Container seleccionar commando:
> docker inspect ba34999350d5 

3. Este comando nos dara la ip del container 

> docker run -it --network orbis-training-project_default jjhoncv/orbis-training-docker:1.0.0 curl -X GET http://172.19.0.2:1042

#### Se añade host al container

> docker run -it --add-host my-alias-ip:172.19.0.2 --network orbis-training-project_default jjhoncv/orbis-training-docker:1.0.0 curl -X GET http://my-alias-ip:1042

### Execute bash
> docker run -it -v $(pwd):/app -w /app jjhoncv/orbis-training-docker:1.0.0 sh resources/example.sh

## JENKINS

### Create image jenkins-jjhoncv
> docker build -t jjhoncv/jenkins-deploy:0.1.0 docker/jenkins

### Run container jenkins
> docker run --rm -u root -p 8080:8080 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME":/home jjhoncv/jenkins-deploy:0.1.0

### Create workspace
-v /home/node: Es el volumen que tendra nuestro container, donde estara nuestro proyecto 
--name workspace: Es el nombre del volumen de nuestro container

> if docker rm workspace ; then echo eliminando container workspace ...; fi
	echo "creando container temporal"
	docker create -v /home/node --name workspace node:10.10.0-slim docker/node

Copiamos nuestro proyecto al volumen creado en su carpeta espeficica 
> docker cp ./ workspace:/home/node/ 

### Instalando dependencias
--volumes-from workspace: Asociamos nuestro volumen "workspace" a nuestro container
-w /home/node: Nos ubicamos en el folder de nuestro container que es nuestro proyecto.

> docker run -it --rm --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm install
