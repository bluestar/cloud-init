#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [ -x "$(command -v apt-get)" ]; then
  echo "init apt module"
  export DEBIAN_FRONTEND=noninteractive

  # fresh images often ship with empty or stale package lists
  apt-get update

  apt-get -y install jq
  apt-get -y install traceroute lsof telnet net-tools dnsutils nmap wget htop nload

  # preseed postfix so its debconf prompts don't block the install;
  # init-postfix.sh sets up the root alias afterwards
  echo "postfix postfix/main_mailer_type select Local only" | debconf-set-selections
  echo "postfix postfix/mailname string $(hostname -f 2> /dev/null || hostname)" | debconf-set-selections
  apt-get -y install postfix mailutils

  apt-get -y autoremove
fi