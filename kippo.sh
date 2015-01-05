#!/bin/bash
$USERNAME=$1
$PORT=$2
apt-get install -y python-dev openssl python-openssl python-pyasn1 python-twisted subversion

mkdir /opt/kippo
chown $USERNAME /opt/hp/kippo

svn checkout http://kippo.googlecode.com/svn/trunk/ /opt/kippo
