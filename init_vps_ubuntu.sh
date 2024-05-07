#!/bin/bash

apt update -y && apt upgrade -y

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt install sudo adduser tzdata ssh systemctl iptables ufw -y

###USER
USR=$(tr -dc a-z < /dev/urandom | head -c 5)
PWD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 14)

adduser --disabled-password --ingroup sudo --gecos "" $USR
echo "$USR:$PWD" | chpasswd

###SSH
SSH_PORT=$(($RANDOM%(65535-1000+1)+1000))

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

systemctl restart ssh.service

###FIREWALL
sed -i "s/IPV6=yes/IPV6=no/" /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT
yes | ufw enable

echo "$USR:$PWD"
echo "port: $SSH_PORT"
