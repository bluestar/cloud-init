#!/bin/bash

# download with curl like
#       curl -fsSL -o /var/tmp/cloud-boot.sh https://raw.githubusercontent.com/bluestar/cloud-init/main/cloud-boot.sh
# then execute
#       /var/tmp/cloud-boot.sh
# alternative for the brave
#       curl -fsSL https://raw.githubusercontent.com/bluestar/cloud-init/main/cloud-boot.sh | bash

set -euo pipefail

# this toolkit reconfigures SSH, users, and system services and must not
# run inside WSL development environments
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

CLOUDROOT=/opt/cloud-init

mkdir -pv "$CLOUDROOT"

if ! cd "$CLOUDROOT"; then
    echo "Cannot access $CLOUDROOT"
    exit 1
fi

github=https://raw.githubusercontent.com/bluestar/cloud-init/main

# --fail makes curl error out on HTTP errors instead of saving the
# error page and executing it as a script
if ! curl -fsSL --retry 5 -o cloud-init.sh "$github/cloud-init.sh"; then
    echo "Failed to download cloud-init.sh from $github"
    exit 1
fi

bash ./cloud-init.sh