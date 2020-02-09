#!/bin/bash

if [ -x "$(command -v yum)" ]; then
  echo "init yum module"
  yum -y install epel-release
  yum -y install jq
fi