#!/bin/bash

echo "init python module"

MAJOR_VERSION=$(uname -r | awk -F '.' '{print $1}')
MINOR_VERSION=$(uname -r | awk -F '.' '{print $2}')

if [ -x "$(command -v zypper)" ]; then
  zypper --non-interactive install python python-xml
elif [ -x "$(command -v dnf)" ]; then
  os_major_version=$(lsb_release -sr | cut -d'.' -f1)

  if [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "9" ]]; then
    dnf -y install python39
  elif [[ "$os_name" == "AlmaLinux" && "$os_major_version" == "8" ]]; then
    dnf -y install python36
  fi

  dnf -y install policycoreutils-python-utils
elif [ -x "$(command -v apt)" ]; then
  # Ubuntu 20.04+ has python-is-python3 package
  if [ $MAJOR_VERSION -ge 5 ] ; then
    apt -y install python-is-python3
  else
    apt -y install python3
  fi

  # install the default python3-setuptools and python3-distutils packages hoping they will match installed python3 version
  apt -y install python3-setuptools python3-distutils
else
  yum -y install python
fi

# install PIP with Python3 if available
if [ -x "$(command -v python3)" ]; then
  curl "https://bootstrap.pypa.io/get-pip.py" | python3
elif [ -x "$(command -v python)" ]; then
  # Python 2.x is legacy; assuming Python 2.7 is available
  curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" | python
else
  echo "Unable to install Python PIP as there is no python or python3 installed"
fi
