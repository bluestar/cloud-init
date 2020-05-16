#!/bin/bash

if [ -x "$(command -v yum)" ]; then
  echo "init yum module"
  yum -y install epel-release
  yum -y install jq
  yum -y install bind-utils
  yum -y install telnet net-tools htop nload
fi