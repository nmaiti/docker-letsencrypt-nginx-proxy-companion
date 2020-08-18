FROM golang:1.14-alpine AS go-builder

ENV DOCKER_GEN_VERSION=0.7.4

# Install build dependencies for docker-gen
RUN apk add --update \
        curl \
        gcc \
        git \
        make \
        musl-dev

# Build docker-gen
RUN go get github.com/jwilder/docker-gen \
    && cd /go/src/github.com/jwilder/docker-gen \
    && git checkout $DOCKER_GEN_VERSION \
    && make get-deps \
    && make all

FROM alpine:3.11

LABEL maintainer="Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)"

ENV DOCKER_HOST=unix:///var/run/docker.sock \
    PATH=$PATH:/app

# Install packages required by the image
RUN apk add --update \
        bash \
        coreutils \
        curl \
        jq \
        netcat-openbsd \
        openssl \
        socat \
    && rm /var/cache/apk/*

# Install docker-gen from build stage
COPY --from=go-builder /go/src/github.com/jwilder/docker-gen/docker-gen /usr/local/bin/

# Install acme.sh
COPY /install_acme.sh /app/install_acme.sh
# acme.sh commit to install from
# defaults to release 2.8.6
ARG ACME_SH_COMMITISH=9190fdd42c5332f8821ce3f0de91cf0d18fa07d5
RUN chmod +rx /app/install_acme.sh \
    && sync \
    && /app/install_acme.sh "$ACME_SH_COMMITISH" \
    && rm -f /app/install_acme.sh

COPY /app/ /app/

WORKDIR /app

VOLUME ["/etc/acme.sh", "/etc/nginx/certs"]

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
