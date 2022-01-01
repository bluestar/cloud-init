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

curl -s --retry 5 -o modules/init-ssh.sh "$github/modules/init-ssh.sh"
curl -s --retry 5 -o modules/init-yum.sh "$github/modules/init-yum.sh"
curl -s --retry 5 -o modules/init-dnf.sh "$github/modules/init-dnf.sh"
curl -s --retry 5 -o modules/init-apt.sh "$github/modules/init-apt.sh"
curl -s --retry 5 -o modules/init-zypper.sh "$github/modules/init-zypper.sh"
curl -s --retry 5 -o modules/init-timezone.sh "$github/modules/init-timezone.sh"
curl -s --retry 5 -o modules/init-python.sh "$github/modules/init-python.sh"
curl -s --retry 5 -o modules/init-access.sh "$github/modules/init-access.sh"
curl -s --retry 5 -o modules/init-postfix.sh "$github/modules/init-postfix.sh"

echo "Executing modules"

bash modules/init-yum.sh
bash modules/init-dnf.sh
bash modules/init-apt.sh
bash modules/init-zypper.sh
bash modules/init-ssh.sh
bash modules/init-python.sh
bash modules/init-timezone.sh
bash modules/init-access.sh
bash modules/init-postfix.sh

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts