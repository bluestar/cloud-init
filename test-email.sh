#!/bin/bash

# download with curl like
#       curl -fsSL -o /var/tmp/test-email.sh https://raw.githubusercontent.com/bluestar/cloud-init/main/test-email.sh
# then execute
#       /var/tmp/test-email.sh
# alternative for the brave
#       curl -fsSL https://raw.githubusercontent.com/bluestar/cloud-init/main/test-email.sh | bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

echo "Hello from $(hostname); now is $(date)" | mail -s "Test email from $(hostname)" root

echo "Test email was sent to root mailbox"