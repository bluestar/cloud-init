#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

if [ -x "$(command -v zypper)" ]; then
  echo "init zypper module"
  zypper --non-interactive install jq
fi