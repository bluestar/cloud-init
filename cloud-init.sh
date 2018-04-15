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

mkdir -pv modules/ssh
curl -s -o modules/ssh/init-ssh.sh "$github/modules/ssh/init-ssh.sh"
mkdir -pv modules/timezone
curl -s -o modules/timezone/init-timezone.sh "$github/modules/ssh/init-timezone.sh"

echo "Executing modules"

bash modules/ssh/init-ssh.sh
bash modules/timezone/init-timezone.sh

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts