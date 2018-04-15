#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit -1
fi

mkdir -pv /opt/cloud-init
cd /opt/cloud-init

if [[ $? -ne 0 ]]; then
    echo "Cannot access /opt/cloud-init"
    exit -1
fi

github=https://raw.githubusercontent.com/bluestar/cloud-init/master

mkdir -pv modules/ssh
curl -o modules/ssh/init-ssh.sh "$github/modules/ssh/init-ssh.sh"

bash modules/ssh/init-ssh.sh

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts