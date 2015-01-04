#!/bin/bash

##setup a new user
##add rules to sudo for user

NEWUSER=$1
PASS=$2
MANAGER=$3
PORT=$4

useradd $NEWUSER
echo "$NEWUSER:$PASS" | chpasswd

if [ -f "/etc/sudoers.tmp" ]; then
    exit 1
fi
touch /etc/sudoers.tmp
echo "$NEWUSER ALL = NOPASSWD: /sbin/iptables, /usr/sbin/service openvpn *" >> /tmp/sudoers.new
visudo -c -f /tmp/sudoers.new
if [ "$?" -eq "0" ]; then
    cp /tmp/sudoers.new /etc/sudoers
fi
rm /etc/sudoers.tmp

mkdir /opt/hp
mkdir /opt/installers

chown $NEWUSER /opt/hp


apt-get update
apt-get install -y suricata rsyslog

#Get emerging threat rules and install
wget http://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz
tar zxvf emerging.rules.tar.gz
cp -r rules /etc/suricata/
rm emerging.rules.tar.gz
rm -rf rules
modprobe nfnetlink_queue

#change /etc/default/suricata options
sed -i 's/RUN=no/RUN=yes/' /etc/default/suricata
#change listen mode to pcap since we're only using as IDS
sed -i 's/LISTENMODE=nfqueue/LISTENMODE=pcap/' /etc/default/suricata
service suricata start

##configure the management port
iptables -I INPUT -p tcp ! -s $MANAGER --dport $PORT -j DROP
sed -i 's/Port 22/Port $PORT/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
