#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [ -x "$(command -v dnf)" ]; then
  echo "init dnf module"
  dnf -y install epel-release
  # check-update exits 100 when updates are available
  dnf -y check-update || true
  dnf -y update
  dnf -y install jq
  echo "jq version $(jq --version) is installed"
  # Get the operating system name and version
  os_name=$(. /etc/os-release && echo "$NAME")
  os_major_version=$(. /etc/os-release && echo "${VERSION_ID%%.*}")

  dnf -y install bind-utils
  dnf -y install telnet net-tools htop nload

  # AlmaLinux 9+ has s-nail instead of mailx
  if [[ "$os_name" == "AlmaLinux" && "$os_major_version" -ge 9 ]]; then
    dnf -y install postfix s-nail
  elif [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "8" ]]; then
    dnf -y install postfix mailx
  else
    dnf -y install postfix
  fi
else
  echo "dnf not found, skipping dnf module"
  exit 254
fi