#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

# on modern RHEL-family systems yum is a symlink to dnf, so skip this
# module when dnf is available and let init-dnf.sh handle the host
if [ -x "$(command -v dnf)" ]; then
  echo "dnf is available, skipping yum module"
elif [ -x "$(command -v yum)" ]; then
  echo "init yum module"
  yum -y install epel-release
  # check-update exits 100 when updates are available
  yum -y check-update || true
  yum -y update
  yum -y install jq
  yum -y install bind-utils
  yum -y install telnet net-tools htop nload
  yum -y install postfix mailx  
fi