#!/bin/bash

echo "init timezone module"

if ! [ -x "$(command -v jq)" ]; then
  echo "Please install jq and run again"; exit 1;
fi

timezone=$( curl -s https://timezoneapi.io/api/ip/?token=JePGTRzVBbit | jq -r ".|.data|.timezone|.id" )
timezone_file="/usr/share/zoneinfo/${timezone}"

if [ -f $timezone_file ];then
    echo "this host is expected to be in $timezone timezone"

    if [ "/etc/localtime" -ef "$timezone_file" ]; then
        echo "no need to update /etc/localtime"
    else
        echo "will update /etc/localtime"
        mv -fv /etc/localtime /etc/localtime.bak
        ln -s $timezone_file /etc/localtime
    fi
fi
