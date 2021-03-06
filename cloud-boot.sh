#!/bin/bash

# download with curl like
#       curl -s -o /var/tmp/cloud-boot.sh https://raw.githubusercontent.com/bluestar/cloud-init/master/cloud-boot.sh
# then execute
#       /var/tmp/cloud-boot.sh
# alternative for the brave
#       curl -s -L https://raw.githubusercontent.com/bluestar/cloud-init/master/cloud-boot.sh | bash

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

curl -s -o cloud-init.sh "$github/cloud-init.sh"

bash ./cloud-init.sh