#!/bin/bash

if [ -x "$(command -v dnf)" ]; then
  echo "init dnf module"
  dnf -y install epel-release
  dnf -y check-update
  dnf -y update
  dnf -y install jq
  echo jq version `jq --version` is installed
  dnf -y install bind-utils
  dnf -y install telnet net-tools htop nload
  dnf -y install postfix mailx  
fi