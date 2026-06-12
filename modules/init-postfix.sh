#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [ -x "$(command -v postfix)" ]; then
    systemctl enable postfix
    systemctl start postfix

    sed -i 's/^#\?root:.*$/root: support@bluestar.cloud/g' /etc/aliases
    echo "updated /etc/aliases, now it has following line:"
    grep root: /etc/aliases || echo "(no root: alias line found in /etc/aliases)"
    echo "reloading postfix aliases database"
    newaliases
else
    echo "postfix not found, postfix configuration steps skipped"
    exit 254
fi