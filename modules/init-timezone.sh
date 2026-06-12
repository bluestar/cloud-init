#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

echo "init timezone module"

if ! [ -x "$(command -v jq)" ]; then
  echo "Please install jq and run again"; exit 1;
fi

# the ipgeolocation.io API key is deliberately not stored in this
# repository: provide it via IPGEOLOCATION_API_KEY or paste it at the
# prompt
api_key="${IPGEOLOCATION_API_KEY:-}"

if [ -z "$api_key" ]; then
    # prompt on /dev/tty: stdin is not the terminal when this script is
    # piped through bash or run by cloud-init.sh
    if printf 'Enter ipgeolocation.io API key (press Enter to skip timezone setup): ' 2> /dev/null > /dev/tty; then
        read -r -t 120 api_key < /dev/tty || api_key=""
        echo > /dev/tty
    fi
fi

if [ -z "$api_key" ]; then
    echo "no ipgeolocation.io API key provided, skipping timezone setup"
    exit 254
fi

timezone=$( curl -fsSL --retry 5 --get --data-urlencode "apiKey=${api_key}" "https://api.ipgeolocation.io/v3/ipgeo" | jq -r ".time_zone.name" ) || timezone=""

if [ -z "$timezone" ] || [ "$timezone" == "null" ]; then
    echo "ERROR: unable to detect timezone, leaving /etc/localtime unchanged"
    exit 1
fi

timezone_file="/usr/share/zoneinfo/${timezone}"

if [ -f "$timezone_file" ];then
    echo "this host is expected to be in $timezone timezone"

    if [ "/etc/localtime" -ef "$timezone_file" ]; then
        echo "no need to update /etc/localtime"
    else
        echo "will update /etc/localtime"
        if [ -e /etc/localtime ]; then
            mv -fv /etc/localtime /etc/localtime.bak
        fi
        ln -s "$timezone_file" /etc/localtime
    fi
else
    echo "ERROR: detected timezone '$timezone' has no zoneinfo file at $timezone_file"
    exit 1
fi
