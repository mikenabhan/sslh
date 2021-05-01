#Download base image ubuntu 18.04
FROM alpine:latest as builder

# Update Software repository
RUN apk update && \
    apk upgrade \
    && apk add --upgrade \
       git \
       gcc \
       pcre-dev \
       musl-dev \
       make \
       libconfig-dev \
       pcre \
       pcre-dev \
       libconfig \
       libcap \
       libcap-dev

# Install software
#RUN apt-get install -y apt-utils libwrap0-dev libconfig8-dev libsystemd-dev libpcre3-dev libcap-dev build-essential git

ARG SSLH_BUILD_TYPE=select

RUN git clone https://github.com/yrutschle/sslh.git ./sslh-src \
    && cd ./sslh-src \
	  && sed -i -e 's/USELIBCAP=/USELIBCAP=1/g' Makefile \
    && make sslh-${SSLH_BUILD_TYPE} \
	  && mv ./sslh-${SSLH_BUILD_TYPE} /sslh



# STEP 2 build a small image
# start from debian:stretch-slim
FROM alpine:latest

# Copy our static executable
COPY --from=builder /sslh /sslh
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Update Software repository
RUN apk update && \
    apk upgrade \
    && apk add --upgrade \
       pcre \
       libcap \
       libconfig \
       bash \
    && chmod +x /docker-entrypoint.sh


ARG BUILD_DATE
ARG LABEL_NAME
ARG LABEL_DESCRIPTION
ARG LABEL_USAGE
ARG LABEL_URL
ARG LABEL_VCS_URL
ARG LABEL_VCS_REF
ARG LABEL_VENDOR
ARG LABEL_VERSION
ARG LABEL_DOCKER_CMD
ARG LABEL_DOCKER_PARAMS
ARG LABEL_MAINTAINER

MAINTAINER Riftbit ErgoZ <github.com/riftbit>

LABEL org.label-schema.build-date="${BUILD_DATE}" \
	org.label-schema.name="${LABEL_NAME}" \
	org.label-schema.description="${LABEL_DESCRIPTION}" \
  org.label-schema.usage="${LABEL_USAGE}" \
  org.label-schema.url="${LABEL_URL}" \
	org.label-schema.vcs-url="${LABEL_VCS_URL}" \
	org.label-schema.vcs-ref="${LABEL_VCS_REF}" \
	org.label-schema.vendor="${LABEL_VENDOR}" \
	org.label-schema.version="${LABEL_VERSION}" \
	org.label-schema.schema-version="1.0" \
  org.label-schema.docker.cmd="${LABEL_DOCKER_CMD}" \
  org.label-schema.docker.params="${LABEL_DOCKER_PARAMS}" \
	maintainer="${LABEL_DESCRIPTION}" \
  Description="${LABEL_MAINTAINER}"


#Define the ENV variable
ENV SSLH_OPTS -V


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
