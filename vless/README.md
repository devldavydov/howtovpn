# VLESS setup guide

1. Install https://github.com/MHSanaei/3x-ui (set all steps as default):

    `bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)`

    After installer finished, creds and console URL will be typed

2. Open console via creds

3. Setup listen local IP: `Panel settings - Listen IP - 127.0.0.1 - Restart Panel`

4. Connect to server via SSH port forwarding: `ssh -L <port>:127.0.0.1:<port> <user>@<server>`

5. Open browser with URL: `https://127.0.0.1:<port>/<path from installer>`

6. Go to Inbounds, add new:
    - **Protocol**: vless
    - **Listen IP**: your server public IP
    - **Port**: 443
    - **Security**: Reality
    - **Get New Cert**
    - **Client/Flow**: xtls-rprx-vision

7. Will be created one inbound with one client

8. Install app v2RayTun on your device

9. Open client QR code and scan it via app

10. To add new client:
    - Inbound menu - Add client
    - **Flow**: xtls-rprx-vision
    - Add client
    - Steps 8,9 with new device and new QR code

11. To delete x-ui from server use command: `x-ui uninstall`