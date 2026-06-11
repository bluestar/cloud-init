#!/bin/bash

set -euo pipefail

# this toolkit reconfigures SSH, users, and system services and must not
# run inside WSL development environments
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

echo "Running cloud-init script"

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

mkdir -pv modules

# modules are executed in this order
modules="init-yum init-dnf init-apt init-zypper init-ssh init-python init-timezone init-access init-postfix"

# --fail makes curl error out on HTTP errors instead of saving the
# error page and executing it as a script
for module in $modules; do
    if ! curl -fsSL --retry 5 -o "modules/${module}.sh" "$github/modules/${module}.sh"; then
        echo "Failed to download ${module}.sh from $github"
        exit 1
    fi
done

echo "Executing modules"

# run every module even if one fails: aborting early could leave a fresh
# host without SSH access configured
failed=""
for module in $modules; do
    if ! bash "modules/${module}.sh"; then
        echo "ERROR: module ${module}.sh failed"
        failed="$failed ${module}.sh"
    fi
done

if [ -n "$failed" ]; then
    echo "WARNING: the following modules failed:$failed"
    exit 1
fi

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts