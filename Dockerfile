FROM docker.io/library/alpine:3.23.5@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40 AS base

ARG PNPR_VERSION
ENV PNPR_VERSION=${PNPR_VERSION}

FROM base AS prepare

ARG TARGETARCH

WORKDIR /home

RUN case "${TARGETARCH}" in \
      amd64) PNPR_ARCH=x64 ;; \
      arm64) PNPR_ARCH=arm64 ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && wget -O pnpr.tar.gz https://github.com/pnpm/pnpm/releases/download/pnpr%40${PNPR_VERSION}/pnpr-linux-${PNPR_ARCH}-musl.tar.gz \
    && tar xzf pnpr.tar.gz \
    && mv pnpr-linux-${PNPR_ARCH}-musl pnpr

FROM base

COPY --from=prepare /home/pnpr /usr/local/bin/pnpr

EXPOSE 7677

ENTRYPOINT [ "pnpr" ]
CMD [ "--config", "/etc/pnpr/config.yaml", "--storage", "/etc/pnpr/storage", "--cache", "/etc/pnpr/cache", "--listen", "0.0.0.0:7677" ]
