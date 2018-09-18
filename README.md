# Create image from name and version
docker build -t jjhoncv/orbis-training-docker:0.1.0 .

# Push image dockerhub
docker push jjhoncv/orbis-training-docker

# Create tag
docker tag jjhoncv/orbis-training-docker jjhoncv/orbis-training-docker:0.2.0 
