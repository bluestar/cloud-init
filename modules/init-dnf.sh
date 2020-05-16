#!/bin/bash

if [ -x "$(command -v dnf)" ]; then
  echo "init dnf module"
  dnf -y install epel-release
  dnf -y install jq
  dnf -y install bind-utils
  dnf -y install telnet net-tools htop nload  
fi