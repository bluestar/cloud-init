#!/bin/bash

if [ -x "$(command -v dnf)" ]; then
  echo "init zypper module"
  zypper --non-interactive install jq
fi