#!/bin/bash
apt-get -y install ppp
apt-get -y install python-pip python-dev && pip install paramiko pycrypto ecdsa
cd /home/vagrant && wget https://www.roaringpenguin.com/files/download/rp-pppoe-3.11.tar.gz
tar -xvf rp-pppoe-3.11.tar.gz
cd rp-pppoe-3.11/src
# check if kernel support pppoe module: modprobe -q pppoe; ls /proc/net/pppoe
./configure --enable-plugin=/usr/lib/pppd/2.4.6/rp-pppoe.so
sed -i '67d' config.h
sed -i '67i\#define HAVE_LINUX_KERNEL_PPPOE 1' config.h
make
make install
echo lock > /etc/ppp/options

echo 'logfile /var/log/pppoe.log
auth
debug
mtu 1472
mru 1472
refuse-chap
refuse-eap
refuse-mschap
require-pap
lcp-echo-interval 20
lcp-echo-failure 2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
netmask 255.255.255.0
# comment plugins for no radius
plugin radius.so
plugin radattr.so
nodefaultroute
noipdefault
usepeerdns
nobsdcomp
noccp
novj
noipx' > /etc/ppp/pppoe-server-options

touch /var/log/pppoe.log && chmod 774 /var/log/pppoe.log
cp /usr/lib/pppd/2.4.6/rp-pppoe.so /etc/ppp/plugins/rp-pppoe.so

echo '#!/bin/bash
# Enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
pppoe-server -I eth1 -L 10.33.3.1 -R 10.33.3.20 -k' > /etc/ppp/pppoe-start

echo '#!/bin/bash
# Disable IP Forwarding
echo 0 > /proc/sys/net/ipv4/ip_forward
pkill pppoe-server
pkill pppd
iptables -t nat -F POSTROUTING' > /etc/ppp/pppoe-stop

echo '[Unit]
Description=PPPoE server

[Service]
ExecStart=/bin/bash /etc/ppp/pppoe-start
ExecStop=/bin/bash /etc/ppp/pppoe-stop
Type=forking
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=pppoe-server
User=root
Group=root

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/pppoe-server.service

chmod +x /etc/ppp/pppoe-start
chmod +x /etc/ppp/pppoe-stop
chmod +x /etc/systemd/system/pppoe-server.service
systemctl daemon-reload
