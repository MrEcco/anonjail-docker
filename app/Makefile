IMAGE_NAME=mrecco/anonjail-app-basic
IMAGE_TAG=1.0.0

build: build.alpine build.ubuntu build.debian build.centos

build.alpine:
	@docker build -f app/alpine.Dockerfile --compress -t $(IMAGE_NAME):$(IMAGE_TAG)-alpine .

build.ubuntu:
	@docker build -f app/ubuntu.Dockerfile --compress -t $(IMAGE_NAME):$(IMAGE_TAG)-ubuntu .

build.debian:
	@docker build -f app/debian.Dockerfile --compress -t $(IMAGE_NAME):$(IMAGE_TAG)-debian .

build.centos:
	@docker build -f app/centos.Dockerfile --compress -t $(IMAGE_NAME):$(IMAGE_TAG)-centos .

push: push.alpine push.ubuntu push.debian push.centos

push.alpine:
	@echo Pushes is aautomated by dockerhub CI! Dont push manualy, estupido!
	# @docker push $(IMAGE_NAME):$(IMAGE_TAG)-alpine

push.ubuntu:
	@echo Pushes is aautomated by dockerhub CI! Dont push manualy, estupido!
	# @docker push $(IMAGE_NAME):$(IMAGE_TAG)-ubuntu

push.debian:
	@echo Pushes is aautomated by dockerhub CI! Dont push manualy, estupido!
	# @docker push $(IMAGE_NAME):$(IMAGE_TAG)-debian

push.centos:
	@echo Pushes is aautomated by dockerhub CI! Dont push manualy, estupido!
	# @docker push $(IMAGE_NAME):$(IMAGE_TAG)-centos

pull: pull.alpine pull.ubuntu pull.debian pull.centos

pull.alpine:
	@docker pull $(IMAGE_NAME):$(IMAGE_TAG)-alpine

pull.ubuntu:
	@docker pull $(IMAGE_NAME):$(IMAGE_TAG)-ubuntu

pull.debian:
	@docker pull $(IMAGE_NAME):$(IMAGE_TAG)-debian

pull.centos:
	@docker pull $(IMAGE_NAME):$(IMAGE_TAG)-centos

rmi: rmi.alpine rmi.ubuntu rmi.debian rmi.centos

rmi.alpine:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)-alpine

rmi.ubuntu:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)-ubuntu

rmi.debian:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)-debian

rmi.centos:
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG)-centos
