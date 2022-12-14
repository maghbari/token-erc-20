# SPDX-License-Identifier: Apache-2.0

ARG GO_VER=1.17.5
ARG ALPINE_VER=3.14

FROM golang:${GO_VER}-alpine${ALPINE_VER} as build

RUN apk add --no-cache \
	bash \
	binutils-gold \
  dumb-init \
	gcc \
	git \
	make \
	musl-dev

ADD . $GOPATH/src/github.com/maghbari/token-erc-20
WORKDIR $GOPATH/src/github.com/maghbari/token-erc-20

RUN go install ./...

FROM golang:${GO_VER}-alpine${ALPINE_VER}

LABEL org.opencontainers.image.title "ERC 20 Go Contract"
LABEL org.opencontainers.image.description "ERC 20 Go Contract"
LABEL org.opencontainers.image.source "https://github.com/maghbari/token-erc-20"

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build /go/bin/token-erc-20 /usr/bin/token-erc-20

WORKDIR /var/hyperledger/token-erc-20
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "-c", "exec /usr/bin/token-erc-20 -peer.address=$CORE_PEER_ADDRESS"]
