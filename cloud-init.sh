#!/bin/bash

echo "Running cloud-init script"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit -1
fi

CLOUDROOT=/opt/cloud-init

mkdir -pv $CLOUDROOT
cd $CLOUDROOT

if [[ $? -ne 0 ]]; then
    echo "Cannot access $CLOUDROOT"
    exit -1
fi

github=https://raw.githubusercontent.com/bluestar/cloud-init/master

mkdir -pv modules

curl -s -o modules/init-ssh.sh "$github/modules/init-ssh.sh"
curl -s -o modules/init-yum.sh "$github/modules/init-yum.sh"
curl -s -o modules/init-timezone.sh "$github/modules/init-timezone.sh"
curl -s -o modules/init-python.sh "$github/modules/init-python.sh"

echo "Executing modules"

bash modules/init-ssh.sh
bash modules/init-yum.sh
bash modules/init-python.sh
bash modules/init-timezone.sh

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts