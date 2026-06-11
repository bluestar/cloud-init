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

timezone=$( curl -fsSL --retry 5 "https://timezoneapi.io/api/ip/?token=OxpjQBYnaUvo" | jq -r ".|.data|.timezone|.id" ) || timezone=""

if [ -z "$timezone" ] || [ "$timezone" == "null" ]; then
    echo "unable to detect timezone, leaving /etc/localtime unchanged"
    exit 0
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
fi
