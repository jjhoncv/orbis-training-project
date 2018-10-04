jenkins-build:
	docker build -t jjhoncv/jenkins-deploy:0.1.0 docker/jenkins

jenkins-up:
	docker run --rm -u root -p 8080:8080 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jjhoncv/jenkins-deploy:0.1.0
