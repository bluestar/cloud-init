#!/bin/bash

if [ -x "$(command -v yum)" ]; then
  echo "init yum module"
  yum -y install epel-release
  yum -y check-update
  yum -y update
  yum -y install jq
  yum -y install bind-utils
  yum -y install telnet net-tools htop nload
  yum -y install postfix mailx  
fi