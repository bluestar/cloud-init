#!/bin/bash

if [ -x "$(command -v dnf)" ]; then
  echo "init dnf module"
  dnf -y install epel-release
  dnf -y check-update
  dnf -y update
  dnf -y install jq
  echo jq version `jq --version` is installed
  dnf -y install lsb_release

  # Get the operating system name and version
  os_name=$(lsb_release -si)
  os_major_version=$(lsb_release -sr | cut -d'.' -f1)

  dnf -y install bind-utils
  dnf -y install telnet net-tools htop nload

  # AlmaLinux 9 has s-nail instead of mailx
  if [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "9" ]]; then
    dnf -y install postfix s-nail 
  elif [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "8" ]]; then
    dnf -y install postfix mailx
  else
    dnf -y install postfix
  fi
fi