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

init_rc=0
bash ./cloud-init.sh || init_rc=$?

echo
echo "=== cloud-init execution summary ==="

status_file="$CLOUDROOT/modules.status"
if [ -s "$status_file" ]; then
    while read -r module result; do
        if [ "$result" = "OK" ]; then
            printf '  \033[32m✓\033[0m %s\n' "$module"
        elif [ "$result" = "SKIPPED" ]; then
            printf '  \033[90m○\033[0m %s (skipped)\n' "$module"
        else
            printf '  \033[31m✗\033[0m %s\n' "$module"
        fi
    done < "$status_file"
else
    printf '  \033[31m✗\033[0m no module results recorded: cloud-init.sh failed before executing modules\n'
fi

if [ "$init_rc" -eq 0 ]; then
    printf '\033[32mBootstrap completed successfully\033[0m\n'
else
    printf '\033[31mBootstrap finished with errors (exit code %d)\033[0m\n' "$init_rc"
fi

exit "$init_rc"