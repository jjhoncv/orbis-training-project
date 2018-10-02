#!/usr/bin/env bash

create_workspace() {
	if docker rm workspace ; then echo eliminando container workspace ...; fi
	echo "creando container temporal de la imagen: workspace ..."
	docker create -v /home/node --name workspace node:10.10.0-slim docker/node
    docker cp ./ workspace:/home/node/
}