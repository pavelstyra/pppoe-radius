#!/bin/bash
apt-get -y install ppp pppoe pppoeconf

echo '"user2" * "testpass"' > /etc/ppp/pap-secrets
echo 'noipdefault
usepeerdns
defaultroute
hide-password
lcp-echo-interval 20
lcp-echo-failure 3
connect /bin/true
noauth
persist
mtu 1492
noaccomp
default-asyncmap
plugin rp-pppoe.so eth1
user "user2"' > /etc/ppp/peers/myisp
