IMAGE = connectitnet/scp-for-docker

build:
		docker build -t ${IMAGE} .

push: build
		docker push ${IMAGE}