FROM docker.io/library/alpine:3.23.5@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40 AS base

ARG PNPR_VERSION
ENV PNPR_VERSION=${PNPR_VERSION}

FROM base AS prepare

WORKDIR /home

RUN wget -O pnpr.tar.gz https://github.com/pnpm/pnpm/releases/download/pnpr%40${PNPR_VERSION}/pnpr-linux-x64-musl.tar.gz
RUN tar xzf pnpr.tar.gz
RUN mv pnpr-linux-x64-musl pnpr

FROM base

COPY --from=prepare /home/pnpr /usr/local/bin/pnpr

EXPOSE 7677

ENTRYPOINT [ "pnpr" ]
CMD [ "--config", "/etc/pnpr/config.yaml", "--storage", "/etc/pnpr/storage", "--cache", "/etc/pnpr/cache", "--listen", "0.0.0.0:7677" ]
