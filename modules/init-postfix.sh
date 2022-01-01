#!/bin/bash

if [ -x "$(command -v postfix)" ]; then
    systemctl enable postfix ; sudo systemctl start postfix

    sed -i 's/^#\?root:.*$/root: support@bluestar.cloud/g' /etc/aliases
    echo "updated /etc/aliases, now it has following line:"
    grep root: /etc/aliases
    echo "reloading postfix aliases database"
    newaliases
else
    echo "postfix not found, postfix configuration steps skipped"
fi