#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: <script> server_addr openvpn_server_name username"
    exit 1
fi

SERVER_ADDR=$1
SERVER_NAME=$2
USERNAME=$3

WORK_DIR=`pwd`
RSA_DIR=$WORK_DIR/easy-rsa
CLIENT_DIR=$WORK_DIR/client_conf

cd $RSA_DIR

echo
echo "###############################"
echo "### Generate client request ###"
echo "###############################"
echo

./easyrsa gen-req $USERNAME nopass

echo
echo "###########################"
echo "### Sign client request ###"
echo "###########################"
echo

./easyrsa sign-req client $USERNAME

echo
echo "##############################"
echo "### Generate client config ###"
echo "##############################"
echo

cd $WORK_DIR
mkdir -p $CLIENT_DIR

TLS=`cat $RSA_DIR/ta.key`
CA=`cat $RSA_DIR/pki/ca.crt`
CRT_LINE=`grep -n BEGIN easy-rsa/pki/issued/$USERNAME.crt | cut -d : -f 1`
CRT=`tail -n +$CRT_LINE easy-rsa/pki/issued/$USERNAME.crt`
KEY=`cat $RSA_DIR/pki/private/$USERNAME.key`

cat >$CLIENT_DIR/$USERNAME.ovpn <<EOL
client
dev tun
proto tcp
remote $SERVER_ADDR 1194
resolv-retry infinite
nobind
persist-key
persist-tun
<ca>
$CA
</ca>
<cert>
$CRT
</cert>
<key>
$KEY
</key>
remote-cert-tls server
key-direction 1
<tls-auth>
$TLS
</tls-auth>
cipher AES-256-CBC
verb 3
EOL

echo
echo "Client config saved to $CLIENT_DIR/$USERNAME.ovpn"
