#!/bin/bash
PASS=$1
PORT=$2

apt-get install -y python-dev authbind openssl python-openssl python-pyasn1 python-twisted subversion

#setup authbind
useradd kippo
CHANGEPASS="kippo:$PASS"
echo $CHANGEPASS | chpasswd

touch /etc/authbind/byport/$PORT
chown $USERNAME /etc/authbind/byport/$PORT
chmod 777 /etc/authbind/byport/$PORT

#make directory and set perms
mkdir /opt/hp/kippo
chown kippo /opt/hp/kippo


#download kippo files
svn checkout http://kippo.googlecode.com/svn/trunk/ /opt/hp/kippo
sudo chown -R kippo /opt/hp/kippo
touch /opt/hp/kippo/default.banner

sed -i "s/twistd/authbind --deep twistd/" /opt/hp/kippo/start.sh