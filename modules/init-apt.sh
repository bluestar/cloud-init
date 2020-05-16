#!/bin/bash

if [ -x "$(command -v apt)" ]; then
  echo "init apt module"
  apt -y install jq
  apt -y install dnsutils
  apt -y install telnet net-tools htop nload
  apt -y autoremove
fi