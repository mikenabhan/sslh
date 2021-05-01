AUTHOR=riftbit
NAME=sslh

BUILDER_DATE=$(shell date '+%Y-%m-%dT%T%z')
LABEL_NAME=SSLH Container
LABEL_DESCRIPTION=SSLH - Applicative Protocol Multiplexer (e.g. share SSH and HTTPS on the same port)
LABEL_USAGE=https://ergoz.ru/sslh-zapuskaem-ssh-https-openvpn-telegram-na-odnom-443-porty
LABEL_URL=https://github.com/yrutschle/sslh
LABEL_VCS_URL=https://github.com/yrutschle/sslh
LABEL_VCS_REF=$(shell git ls-remote https://github.com/yrutschle/sslh HEAD | cut -c1-7)
LABEL_VENDOR=Riftbit Studio
LABEL_VERSION=$(shell curl -s https://raw.githubusercontent.com/yrutschle/sslh/master/ChangeLog | head -1 | awk -F ':' '{print $$1}')
LABEL_DOCKER_CMD=docker run --name sslh -d --env SSLH_OPTS='-p0.0.0.0:443 --anyprot192.168.0.1:8443' --net host --privileged --restart always riftbit/sslh
LABEL_DOCKER_PARAMS=SSLH_OPTS=start options to sslh
LABEL_MAINTAINER=Riftbit ErgoZ <github.com/riftbit>


BUILD_LABEL_OPTS=--build-arg BUILD_DATE="$(BUILDER_DATE)" --build-arg LABEL_NAME="$(LABEL_NAME)" --build-arg LABEL_DESCRIPTION="$(LABEL_DESCRIPTION)" --build-arg LABEL_USAGE="$(LABEL_USAGE)" --build-arg LABEL_URL="$(LABEL_URL)" --build-arg LABEL_VCS_URL="$(LABEL_VCS_URL)"  --build-arg LABEL_VCS_REF="$(LABEL_VCS_REF)" --build-arg LABEL_VENDOR="$(LABEL_VENDOR)" --build-arg LABEL_VERSION="$(LABEL_VERSION)" --build-arg LABEL_DOCKER_CMD="$(LABEL_DOCKER_CMD)" --build-arg LABEL_DOCKER_PARAMS="$(LABEL_DOCKER_PARAMS)" --build-arg LABEL_MAINTAINER="$(LABEL_MAINTAINER)"

DB=docker build --no-cache
DT=docker tag
DP=docker push

.PHONY: all build tag release

all: release


build: build-debian build-alpine

build-debian: build-debian-fork build-debian-select

build-alpine: build-alpine-fork build-alpine-select



build-debian-fork:
	$(info === Build SSLH Debian Docker image for "FORK" type ===)
	$(DB) \
	--build-arg SSLH_BUILD_TYPE=fork $(BUILD_LABEL_OPTS) \
	-t $(AUTHOR)/$(NAME):debian-fork-$(LABEL_VCS_REF) \
	-f debian.Dockerfile .

build-debian-select:
	$(info === Build SSLH Debian Docker image for "SELECT" type ===)
	$(DB) \
	--build-arg SSLH_BUILD_TYPE=select $(BUILD_LABEL_OPTS) \
	-t $(AUTHOR)/$(NAME):debian-select-$(LABEL_VCS_REF) \
	-f debian.Dockerfile .

build-alpine-fork:
	$(info === Build SSLH Alpine Linux Docker image for "FORK" type ===)
	$(DB) \
	--build-arg SSLH_BUILD_TYPE=fork $(BUILD_LABEL_OPTS) \
	-t $(AUTHOR)/$(NAME):alpine-fork-$(LABEL_VCS_REF) \
	-f alpine.Dockerfile .

build-alpine-select:
	$(info === Build SSLH Alpine Linux Docker image for "SELECT" type ===)
	$(DB) \
	--build-arg SSLH_BUILD_TYPE=select $(BUILD_LABEL_OPTS) \
	-t $(AUTHOR)/$(NAME):alpine-select-$(LABEL_VCS_REF) \
	-f alpine.Dockerfile .


tag: tag-fork tag-select tag-latest

tag-fork: tag-debian-fork tag-alpine-fork

tag-select: tag-debian-select tag-alpine-select



tag-debian-fork: build-debian-fork
	$(info === $@ ===)
	$(DT) $(AUTHOR)/$(NAME):debian-fork-$(LABEL_VCS_REF) $(AUTHOR)/$(NAME):debian-fork

tag-debian-select: build-debian-select
	$(info === $@ ===)
	$(DT) $(AUTHOR)/$(NAME):debian-select-$(LABEL_VCS_REF) $(AUTHOR)/$(NAME):debian-select

tag-alpine-fork: build-alpine-fork
	$(info === $@ ===)
	$(DT) $(AUTHOR)/$(NAME):alpine-fork-$(LABEL_VCS_REF) $(AUTHOR)/$(NAME):alpine-fork

tag-alpine-select: build-alpine-select
	$(info === $@ ===)
	$(DT) $(AUTHOR)/$(NAME):alpine-select-$(LABEL_VCS_REF) $(AUTHOR)/$(NAME):alpine-select

tag-latest: build-debian-select
	$(info === $@ ===)
	$(DT) $(AUTHOR)/$(NAME):debian-select-$(LABEL_VCS_REF) $(AUTHOR)/$(NAME):latest



release: release-fork release-select release-latest

release-fork: release-debian-fork release-alpine-fork

release-select: release-debian-select release-alpine-select



release-debian-fork: tag-debian-fork
	$(info === $@ ===)
	$(DP) $(AUTHOR)/$(NAME):debian-fork

release-debian-select: tag-debian-select
	$(info === $@ ===)
	$(DP) $(AUTHOR)/$(NAME):debian-select

release-alpine-fork: tag-alpine-fork
	$(info === $@ ===)
	$(DP) $(AUTHOR)/$(NAME):alpine-fork

release-alpine-select: tag-alpine-select
	$(info === $@ ===)
	$(DP) $(AUTHOR)/$(NAME):alpine-select

release-latest: tag-latest
	$(info === $@ ===)
	$(DP) $(AUTHOR)/$(NAME):latest
