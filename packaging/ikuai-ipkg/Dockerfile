FROM debian:bookworm-slim

ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker/bin/linux-amd64/tcstminersystem /usr/local/bin/tcstminersystem

RUN mkdir -p /root/rustminersystem \
    && chmod +x /usr/local/bin/tcstminersystem /usr/local/bin/docker-entrypoint.sh

WORKDIR /root/rustminersystem

VOLUME ["/root/rustminersystem"]

EXPOSE 1800 3333 1314 1900 8001-8008

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
