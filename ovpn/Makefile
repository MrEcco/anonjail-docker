IMAGE_NAME=mrecco/anonjail-ovpn
IMAGE_TAG=1.0.0

build:
	@docker build --compress -f ovpn/Dockerfile -t $(IMAGE_NAME):$(IMAGE_TAG) .

push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

pull:
	@docker pull $(IMAGE_NAME):$(IMAGE_TAG)

rmi:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

debug:
	@docker run --rm -it --cap-add NET_ADMIN $(IMAGE_NAME):$(IMAGE_TAG) bash
