#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

# Trap errors and log them
trap 'bashio::log.error "Script failed at line $LINENO with exit code $?"' ERR
set -e

bashio::log.info "Starting DLNA Proxy..."

# Read configuration from Home Assistant
DESCRIPTION_URL=$(bashio::config 'description_url')
BROADCAST_INTERVAL=$(bashio::config 'broadcast_interval')
PROXY_ENABLED=$(bashio::config 'proxy_enabled')
WAIT=$(bashio::config 'wait')
WAIT_INTERVAL=$(bashio::config 'wait_interval')
CONNECT_TIMEOUT=$(bashio::config 'connect_timeout')
PROXY_TIMEOUT=$(bashio::config 'proxy_timeout')
STREAM_TIMEOUT=$(bashio::config 'stream_timeout')
VERBOSE=$(bashio::config 'verbose')

# Validate required configuration
if [ -z "${DESCRIPTION_URL}" ]; then
    bashio::log.error "=========================================="
    bashio::log.error "DESCRIPTION URL NOT CONFIGURED!"
    bashio::log.error "=========================================="
    bashio::log.error "Please set 'description_url' to point to your"
    bashio::log.error "remote DLNA server's root XML description."
    bashio::log.error "Example: http://192.168.1.100:8200/rootDesc.xml"
    bashio::log.error "=========================================="
    exit 1
fi

# Build command arguments
DLNA_PROXY_ARGS=(
    "-u" "${DESCRIPTION_URL}"
    "-d" "${BROADCAST_INTERVAL}"
    "--connect-timeout" "${CONNECT_TIMEOUT}"
)

if [ "${WAIT}" = "true" ]; then
    DLNA_PROXY_ARGS+=("-w" "${WAIT_INTERVAL}")
fi

# Add verbosity flags
for ((i=0; i<VERBOSE; i++)); do
    DLNA_PROXY_ARGS+=("-v")
done

# Configure TCP proxy if enabled
if [ "${PROXY_ENABLED}" = "true" ]; then
    PROXY_IP=$(bashio::config 'proxy_ip')
    PROXY_PORT=$(bashio::config 'proxy_port')
    
    if [ -z "${PROXY_IP}" ]; then
        bashio::log.error "Proxy is enabled but proxy_ip is not set!"
        bashio::log.error "Set proxy_ip to the local IP address where clients can reach this proxy."
        exit 1
    fi
    
    bashio::log.info "TCP proxy enabled at ${PROXY_IP}:${PROXY_PORT}"
    DLNA_PROXY_ARGS+=("-p" "${PROXY_IP}:${PROXY_PORT}")
    DLNA_PROXY_ARGS+=("--proxy-timeout" "${PROXY_TIMEOUT}")
    DLNA_PROXY_ARGS+=("--stream-timeout" "${STREAM_TIMEOUT}")
fi

# Configure network interface if specified
if bashio::config.has_value 'interface'; then
    INTERFACE=$(bashio::config 'interface')
    bashio::log.info "Broadcasting on interface: ${INTERFACE}"
    DLNA_PROXY_ARGS+=("-i" "${INTERFACE}")
fi

bashio::log.info "Starting DLNA Proxy with configuration:"
bashio::log.info "  Description URL: ${DESCRIPTION_URL}"
bashio::log.info "  Broadcast interval: ${BROADCAST_INTERVAL}s"
bashio::log.info "  Wait for availability: ${WAIT}"
bashio::log.info "  Connect timeout: ${CONNECT_TIMEOUT}s"
if [ "${PROXY_ENABLED}" = "true" ]; then
    bashio::log.info "  Proxy timeout: ${PROXY_TIMEOUT}s"
    bashio::log.info "  Stream timeout: ${STREAM_TIMEOUT}s"
fi
bashio::log.info "  Verbosity level: ${VERBOSE}"

# Run dlna-proxy
exec /usr/local/bin/dlna-proxy "${DLNA_PROXY_ARGS[@]}"
