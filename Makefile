define create_workspace
	if docker rm workspace ; then echo eliminando container workspace ...; fi
	echo "creando container temporal de la imagen: workspace ..."
	docker create -v /home/node --name workspace node:10.10.0-slim docker/node
	docker cp ./ workspace:/home/node/
endef

image:
	docker build -t jjhoncv/jenkins-deploy:0.0.1 docker/jenkins

create-workspace:
	#docker rm workspace
	#docker create -v /home/node --name workspace node:10.10.0-slim docker/node 
	#docker cp ./ workspace:/home/node
	$(call create_workspace)

install:
	#docker run -v $(PWD):/app/ -w /app jjhoncv/orbis-training-docker:1.0.0 npm install
	docker run -it --rm --volumes-from workspace -w /home/node --tty=false jjhoncv/orbis-training-docker:1.0.0 npm install

test:
	echo test

deploy:
	echo deploy!!

release:
	docker run -it -v $(PWD)/:/app/ -w /app --tty=false jjhoncv/orbis-training-docker:1.0.0 npm run release