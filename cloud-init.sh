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

# per-module results, read by cloud-boot.sh for the execution summary
status_file="$CLOUDROOT/modules.status"
: > "$status_file"

# run every module even if one fails: aborting early could leave a fresh
# host without SSH access configured.
# modules exit 0 on success, 254 when they have nothing to do on this
# system (e.g. their package manager is absent), anything else on
# failure. 254 is reserved because package managers use low codes for
# their own errors (apt-get and zypper both use the 100 range).
failed=""
for module in $modules; do
    rc=0
    bash "modules/${module}.sh" || rc=$?
    if [ "$rc" -eq 0 ]; then
        echo "${module} OK" >> "$status_file"
    elif [ "$rc" -eq 254 ]; then
        echo "${module} SKIPPED" >> "$status_file"
    else
        echo "ERROR: module ${module}.sh failed"
        failed="$failed ${module}.sh"
        echo "${module} FAIL" >> "$status_file"
    fi
done

if [ -n "$failed" ]; then
    echo "WARNING: the following modules failed:$failed"
    exit 1
fi

#ssh-keyscan -H github.com >> ~/.ssh/known_hosts