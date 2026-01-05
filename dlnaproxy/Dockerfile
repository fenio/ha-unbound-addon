ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install required dependencies
RUN apk add --no-cache \
    bash \
    jq \
    curl

# Set dlnaproxy version - using main branch
ARG TARGETARCH

# Download and install dlnaproxy binary from GitHub releases
RUN case "${TARGETARCH}" in \
        "amd64") ARCH="x86_64-unknown-linux-musl" ;; \
        "arm64") ARCH="aarch64-unknown-linux-musl" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/dlnaproxy \
        "https://github.com/fenio/dlnaproxy/releases/latest/download/dlnaproxy-${ARCH}" && \
    chmod +x /usr/local/bin/dlnaproxy

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
