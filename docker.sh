#!/bin/bash

apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.sh.asc
chmod a+r /etc/apt/keyrings/docker.sh.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.sh.list > /dev/null
apt-get update

apt-get install docker.sh-ce docker.sh-ce-cli containerd.io docker.sh-buildx-plugin docker.sh-compose-plugin -y

usermod -aG docker.sh $USR

systemctl restart docker.sh