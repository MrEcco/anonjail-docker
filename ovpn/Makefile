IMAGE_NAME=mrecco/anonjail-ovpn
IMAGE_TAG=2.4.9

build:
	@docker build --compress -t $(IMAGE_NAME):$(IMAGE_TAG) .

push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

rmi:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

debug:
	@docker run --rm -it --cap-add NET_ADMIN $(IMAGE_NAME):$(IMAGE_TAG) bash
