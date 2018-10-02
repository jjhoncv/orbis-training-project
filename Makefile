image:
	docker build -t jjhoncv/jenkins-deploy:0.0.1 docker/jenkins

create-workspace:
	#docker rm workspace
	#docker create -v /home/node --name workspace node:10.10.0-slim docker/node 
	#docker cp ./ workspace:/home/node
	./task.sh create_workspace

install:
	#docker run -v $(PWD):/app/ -w /app jjhoncv/orbis-training-docker:1.0.0 npm install
	docker run -it --rm --volumes-from workspace -w /home/node jjhoncv/orbis-training-docker:1.0.0 npm install


release:
	docker run -it -v $(PWD)/:/app/ -w /app jjhoncv/orbis-training-docker:1.0.0 npm run release