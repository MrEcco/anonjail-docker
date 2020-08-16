IMAGE_NAME=mrecco/anonjail-doh
IMAGE_TAG=0.0.9

build:
	@docker build --compress -f doh/Dockerfile -t $(IMAGE_NAME):$(IMAGE_TAG) .

push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

rmi:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

debug:
	@docker run --rm -it --cap-add NET_ADMIN $(IMAGE_NAME):$(IMAGE_TAG) bash

run:
	@docker run --rm -it --cap-add NET_ADMIN $(IMAGE_NAME):$(IMAGE_TAG)

##################### Testing #####################
test.default: test.google

test.google:
	@docker run --rm -it --cap-add NET_ADMIN --dns 127.0.0.1 $(IMAGE_NAME):$(IMAGE_TAG)

test.cloudflare:
	@docker run --rm -it --cap-add NET_ADMIN --dns 127.0.0.1 -e "DNS_OVER_HTTPS_IP=1.1.1.1" -e "DNS_OVER_HTTPS_DOMAIN=cloudflare-dns.com" $(IMAGE_NAME):$(IMAGE_TAG)
