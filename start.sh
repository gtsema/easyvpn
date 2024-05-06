#!/bin/bash

apt update -y && apt upgrade -y

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt install sudo adduser tzdata ssh systemctl iptables ufw -y

###USER
USR=$(tr -dc a-z < /dev/urandom | head -c 5)
PWD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 14)

adduser --disabled-password --ingroup sudo --gecos "" $USR
echo "$USR:$PWD" | chpasswd

echo "$USR:$PWD"

###SSH
SSH_PORT=$(($RANDOM%(65535-1000+1)+1000))

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

###FIREWALL
sed -i "s/IPV6=yes/IPV6=no/" /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT
yes | ufw enable

###DOCKER
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

usermod -aG docker $USR

systemctl restart docker
