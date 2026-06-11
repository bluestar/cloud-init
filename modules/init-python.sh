#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

echo "init python module"

if [ -x "$(command -v zypper)" ]; then
  zypper --non-interactive install python python-xml
elif [ -x "$(command -v dnf)" ]; then
  # modules run as separate processes, so detect the OS here rather than
  # relying on variables set by init-dnf.sh
  os_name=$(. /etc/os-release && echo "$NAME")
  os_major_version=$(. /etc/os-release && echo "${VERSION_ID%%.*}")

  # AlmaLinux 9+ ships Python 3.9+ as the default python3 package;
  # AlmaLinux 8 only has versioned packages such as python36
  if [[ "$os_name" == "AlmaLinux" && "$os_major_version" -ge 9 ]]; then
    dnf -y install python3
  elif [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "8" ]]; then
    dnf -y install python36
  fi

  dnf -y install python3-pip policycoreutils-python-utils
elif [ -x "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  os_id=$(. /etc/os-release && echo "$ID")
  os_major_version=$(. /etc/os-release && echo "${VERSION_ID%%.*}")

  # python-is-python3 exists on Ubuntu 20.04+ and Debian 11+
  if [[ "$os_id" == "ubuntu" && "$os_major_version" -ge 20 ]] || [[ "$os_id" == "debian" && "$os_major_version" -ge 11 ]]; then
    apt-get -y install python-is-python3
  else
    apt-get -y install python3
  fi

  apt-get -y install python3-setuptools python3-pip
  # python3-distutils is gone from distros shipping Python 3.12+
  if apt-cache show python3-distutils > /dev/null 2>&1; then
    apt-get -y install python3-distutils
  fi
else
  yum -y install python
fi

# install PIP with Python3 if available
# download to a file first: piping curl into python would run the
# interpreter on empty input and hide a failed download
if [ -x "$(command -v python3)" ]; then
  if python3 -m pip --version > /dev/null 2>&1; then
    echo "pip is already available: $(python3 -m pip --version)"
  elif [ -f "$(python3 -c 'import sysconfig; print(sysconfig.get_path("stdlib"))')/EXTERNALLY-MANAGED" ]; then
    # PEP 668: get-pip.py refuses to modify an externally managed system
    # Python (Debian 12+/Ubuntu 23.04+); pip must come from the distro
    echo "system Python is externally managed and distro pip is not installed, skipping get-pip.py"
  elif curl -fsSL --retry 5 -o /var/tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py"; then
    python3 /var/tmp/get-pip.py
    rm -f /var/tmp/get-pip.py
  else
    echo "Failed to download get-pip.py, skipping pip installation"
  fi
elif [ -x "$(command -v python)" ]; then
  # Python 2.x is legacy; assuming Python 2.7 is available
  if curl -fsSL --retry 5 -o /var/tmp/get-pip.py "https://bootstrap.pypa.io/pip/2.7/get-pip.py"; then
    python /var/tmp/get-pip.py
    rm -f /var/tmp/get-pip.py
  else
    echo "Failed to download get-pip.py, skipping pip installation"
  fi
else
  echo "Unable to install Python PIP as there is no python or python3 installed"
fi
