IMAGE_NAME=mrecco/anonjail-tor
IMAGE_TAG=0.4.3.5

build:
	@docker build --compress -t $(IMAGE_NAME):$(IMAGE_TAG) .

push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

rmi:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

debug:
	@docker run --rm -it $(IMAGE_NAME):$(IMAGE_TAG) bash

##################### Testing #####################
test.default:
	@docker run --rm -it $(IMAGE_NAME):$(IMAGE_TAG)

test.bridges:
	@docker run --rm -it -e TOR_BRIDGE_1="obfs4 0.0.0.0:12345 0123456789ABCDEF0123456789ABCDEF01234567 cert=base64base64base64base64base64base64base64base64base64base64base64base some-option=0 some-another-option=1" -e TOR_BRIDGE_2="obfs4 0.0.0.0:12345 0123456789ABCDEF0123456789ABCDEF01234567 cert=base64base64base64base64base64base64base64base64base64base64base64base some-option=0 some-another-option=1" -e TOR_BRIDGE_3="obfs4 0.0.0.0:12345 0123456789ABCDEF0123456789ABCDEF01234567 cert=base64base64base64base64base64base64base64base64base64base64base64base some-option=0 some-another-option=1" $(IMAGE_NAME):$(IMAGE_TAG)

test.proxy.socks5:
	@docker run --rm -it -e TOR_SOCKS5_PROXY="0.0.0.0:1080" $(IMAGE_NAME):$(IMAGE_TAG)

test.proxy.http:
	@docker run --rm -it -e TOR_HTTP_PROXY="0.0.0.0:3128" $(IMAGE_NAME):$(IMAGE_TAG)

test.proxy.https:
	@docker run --rm -it -e TOR_HTTPS_PROXY="0.0.0.0:3448" $(IMAGE_NAME):$(IMAGE_TAG)
