#!/bin/bash

# download with curl like
#       curl -s -o /var/tmp/cloud-boot.sh https://raw.githubusercontent.com/bluestar/cloud-init/master/test-email.sh
# then execute
#       /var/tmp/test-email.sh
# alternative for the brave
#       curl -s -L https://raw.githubusercontent.com/bluestar/cloud-init/master/test-email.sh | bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit -1
fi

echo "Hello from $(hostname); now is $(date)" | mail -s "Test email from $(hostname)" root

echo "Test email was sent to root mailbox"