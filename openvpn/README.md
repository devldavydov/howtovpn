# OpenVPN helper scripts

1. Install openvpn and easy-rsa:\
`apt install openvpn easy-rsa`.
2. Use script `init_server.sh` to setup PKI and generate server configuration.\
Supply openvpn server name as script argument.\
Server config in script can be updated from installation example:\
`/usr/share/doc/openvpn/examples/sample-config-files/server.conf`.
4. After script `init_server.sh` finished, copy files from `server_conf` directory to `/etc/openvpn`.
5. Start openvpn service:\
`systemctl start openvpn@YOUR_OPENVPN_SERVER_NAME`.
6. Ensure IP forwarding enabled:\
Set `net.ipv4.ip_forward = 1` in `/etc/sysctl.conf`.\
Run `sysctl -p`.
7. Ensure NAT enabled:\
Run `iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE`.\
Supply actual interface. This setting not persists after reboot, use other tools.
8. Next add clients with script `init_client.sh`.\
Supply script with server address, server name (from 2.) and user name.\
Client config in script can be updated from installation example:\
`/usr/share/doc/openvpn/examples/sample-config-files/client.conf`
10. Copy client config from `client_conf` dir to client device.

### AutoSSH and VPN tunnel

Sometimes it's necessary to pass VPN connection through tunnel:

```
Server 1.1.1.1                               Server 2.2.2.2
--------------                               --------------
TCP:1194 <--------------- SSH -------------> OpenVPN, TCP:1194
```

`Server 2.2.2.2` - start OpenVPN on TCP 1994, enable IP forwarding and NAT.\
`Server 1.1.1.1`:
1. Install autossh: `apt install autossh`.
2. Create systemd service file: `/etc/systemd/system/autossh.service` from `autossh.service` file.\
Place real address of remote server.
3. Ensure that ssh from `Server 1.1.1.1` to `Server 2.2.2.2` authenticated by keys.\
Use `ssh-keygen` and `ssh-copy-id`.
5. Enable service:\
`systemctl daemon-reload`\
`systemctl start autossh.service`
6. Now your OpenVPN client can connect to `Server 1.1.1.1` but this connection will be tunneled to `Server 2.2.2.2`.

### Additional info:
1. [Ubuntu OpenVPN guide](https://ubuntu.com/server/docs/how-to-install-and-use-openvpn)
2. [EasyRSA guide](https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto)
3. [OpenVPN guide](https://openvpn.net/community-resources/how-to/)
4. [IP forwarding](https://linuxconfig.org/how-to-turn-on-off-ip-forwarding-in-linux)
5. [AutoSSH](https://amorev.ru/autossh/)
