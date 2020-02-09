#!/bin/bash

if [ -x "$(command -v zypper)" ]; then
  echo "init zypper module"
  zypper --non-interactive install jq
fi