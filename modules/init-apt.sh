#!/bin/bash

if [ -x "$(command -v apt)" ]; then
  echo "init apt module"
  apt -y install jq
  apt -y install traceroute lsof telnet net-tools dnsutils nmap wget htop nload
  apt -y autoremove
fi