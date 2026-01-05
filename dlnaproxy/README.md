# DLNA Proxy Home Assistant Add-on

This add-on allows you to make a remote DLNA server (e.g., MiniDLNA) discoverable on your local network by broadcasting SSDP alive messages on its behalf.

## Use Case

If you're hosting a media library on a remote server (accessible via VPN or routed directly), `dlnaproxy` will announce that server on your local LAN as if it were physically present on your network.

```
          Network boundary                 +------------------+
                ++          connect back   |                  |
     +----------++-------------------------+       you        |
     |          ||                         |                  |
     |          ||                         +---^--------------+
+----v-----+    ||   +------------+            |
| Remote   |    ||   |            +------------+
| DLNA     <----++---+ dlnaproxy  |    broadcast
| Server   | fetch info           |
|          |    ++   |            |
+----------+    ||   +------------+
                ||
                ||
                ++
```

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
- **verbose**: Logging verbosity level (0=warn, 1=info, 2=debug, 3=trace)

## TCP Proxy Mode

If your DLNA clients cannot directly reach the remote server, enable the TCP proxy:

1. Set `proxy_enabled` to `true`
2. Set `proxy_ip` to the IP address of your Home Assistant machine on the local network
3. Optionally adjust `proxy_port` (default 8200)

The proxy will forward connections from local clients to the remote DLNA server.

## Network Requirements

This add-on uses host network mode because SSDP multicast discovery requires access to the local network's multicast channel.

## More Information

For more details about dlnaproxy, see the [GitHub repository](https://github.com/fenio/dlnaproxy).
