# DLNA Proxy Home Assistant Add-on

This add-on allows you to make a remote DLNA server (e.g., MiniDLNA) discoverable on your local network by broadcasting SSDP alive messages on its behalf.

## Use Case

If you're hosting a media library on a remote server (accessible via VPN or routed directly), `dlna-proxy` will announce that server on your local LAN as if it were physically present on your network.

```
          Network boundary                 +------------------+
                ++          connect back   |                  |
     +----------++-------------------------+       you        |
     |          ||                         |                  |
     |          ||                         +---^--------------+
+----v-----+    ||   +------------+            |
| Remote   |    ||   |            +------------+
| DLNA     <----++---+ dlna-proxy |    broadcast
| Server   | fetch info           |
|          |    ++   |            |
+----------+    ||   +------------+
                ||
                ||
                ++
```

## How it works

`dlna-proxy` operates in two modes:

### Basic mode (SSDP broadcasting only)

In basic mode, `dlna-proxy` periodically fetches the device description from the remote DLNA server and broadcasts SSDP `alive` messages on the local network. This announces the remote server's presence to local DLNA clients. Clients must be able to reach the remote server directly to stream content.

### Proxy mode

When proxy is enabled, `dlna-proxy` also starts a local TCP proxy. This mode is essential when the remote server is not directly reachable from clients (e.g., behind a VPN that only the Home Assistant host can access).

The TCP proxy does more than simple port forwarding - it acts as an **HTTP-aware intercepting proxy** that:

1. **Forwards client requests** to the remote DLNA server unchanged
2. **Intercepts HTTP responses** from the server
3. **Rewrites URLs in response bodies** on the fly, replacing the remote server's address with the local proxy address
4. **Adjusts Content-Length headers** when URL rewriting changes the response size

This URL rewriting is critical because DLNA servers embed their own URLs in XML descriptions, content directories, and other responses. Without rewriting, clients would receive URLs pointing to the unreachable remote server and fail to load content.

## Configuration

### Required Settings

- **description_url**: URL pointing to your remote DLNA server's root XML description
  - Example: `http://192.168.1.100:8200/rootDesc.xml`
  - This is typically the IP/hostname of your DLNA server followed by `/rootDesc.xml`

### Optional Settings

- **broadcast_interval**: How often (in seconds) to broadcast SSDP alive messages (default: 895)
- **proxy_enabled**: Enable TCP proxy for clients that cannot directly reach the remote server
- **proxy_ip**: Local IP address for the TCP proxy (required if proxy is enabled)
- **proxy_port**: Local port for the TCP proxy (default: 8200)
- **interface**: Specific network interface to broadcast on (leave empty for all)
- **wait**: Enable waiting for the remote server to become available at startup
- **wait_interval**: Retry interval in seconds when waiting for server (default: 30)
- **connect_timeout**: HTTP connect timeout in seconds for fetching XML description (default: 2)
- **proxy_timeout**: TCP connect timeout in seconds for proxy connections to origin (default: 10)
- **stream_timeout**: TCP read/write timeout in seconds for active proxy streams (default: 300)
- **verbose**: Logging verbosity level (0=warn, 1=info, 2=debug, 3=trace)

## TCP Proxy Mode

If your DLNA clients cannot directly reach the remote server, enable the TCP proxy:

1. Set `proxy_enabled` to `true`
2. Set `proxy_ip` to the IP address of your Home Assistant machine on the local network
3. Optionally adjust `proxy_port` (default 8200)

The proxy will forward connections from local clients to the remote DLNA server and rewrite URLs on the fly so clients receive addresses they can actually reach.

## Wait for Server Availability

If the remote server might not be available immediately (e.g., VPN not yet connected at boot):

1. Set `wait` to `true`
2. Optionally adjust `wait_interval` (default 30 seconds)

The add-on will retry connecting at the specified interval until the server becomes available.

## Network Requirements

This add-on uses host network mode because SSDP multicast discovery requires access to the local network's multicast channel.

## More Information

For more details about dlna-proxy, see the [GitHub repository](https://github.com/fenio/dlna-proxy).
