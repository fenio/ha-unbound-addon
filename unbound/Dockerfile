ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install unbound and dependencies
RUN apk add --no-cache \
    unbound \
    bash \
    jq \
    curl

# Create necessary directories and download root hints
RUN mkdir -p /var/run/unbound /etc/unbound && \
    curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.root && \
    unbound-anchor -a /etc/unbound/root.key || true

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose DNS ports
EXPOSE 53/tcp 53/udp

CMD ["/run.sh"]
