#!/bin/sh
#
# apt install openssh easy-rsa
#

if [ "$#" -ne 1 ]; then
    echo "Usage: <script> openvpn_server_name"
    exit 1
fi

SERVER=$1

WORK_DIR=`pwd`
RSA_DIR=$WORK_DIR/easy-rsa
SERVER_DIR=$WORK_DIR/server_conf

echo
echo "################################"
echo "### Create easy-rsa work dir ###"
echo "################################"
echo

rm -rf $RSA_DIR
make-cadir $RSA_DIR
cd $RSA_DIR

echo
echo "################"
echo "### Init PKI ###"
echo "################"
echo

./easyrsa init-pki

echo
echo "###############"
echo "### Init CA ###"
echo "###############"
echo

./easyrsa build-ca

echo
echo "###############################"
echo "### Init server key request ###"
echo "###############################"
echo

./easyrsa gen-req $SERVER nopass
./easyrsa gen-dh

echo
echo "###############################"
echo "### Sign server key request ###"
echo "###############################"
echo

./easyrsa sign-req server $SERVER

echo
echo "####################"
echo "### Generate TLS ###"
echo "####################"
echo

openvpn --genkey --secret ta.key

echo
echo "##########################"
echo "### Prepare server dir ###"
echo "##########################"
echo

cd $WORK_DIR

rm -rf $SERVER_DIR
mkdir $SERVER_DIR

cp $RSA_DIR/pki/dh.pem \
        $RSA_DIR/pki/ca.crt \
        $RSA_DIR/pki/issued/$SERVER.crt \
        $RSA_DIR/pki/private/$SERVER.key \
        $RSA_DIR/ta.key \
        $SERVER_DIR

cat >$SERVER_DIR/$SERVER.conf <<EOL
port 1194
proto tcp
dev tun
ca ca.crt
cert $SERVER.crt
key $SERVER.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-CBC
compress lz4-v2
push "compress lz4-v2"
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 3
explicit-exit-notify 1
EOL

echo
echo "1. Copy files from $SERVER_DIR to /etc/openvpn"
echo "2. Run: systemctl start openvpn@$SERVER"
echo "3. Enable IP forwarding:"
echo "   - set 'net.ipv4.ip_forward = 1' in /etc/sysctl.conf"
echo "   - run: sysctl -p"
echo "4. Enable NAT (not persist after reboot):"
echo "   - iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE"
