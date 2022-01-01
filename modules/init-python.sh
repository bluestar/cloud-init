#!/bin/bash

echo "init python module"

MAJOR_VERSION=$(uname -r | awk -F '.' '{print $1}')
MINOR_VERSION=$(uname -r | awk -F '.' '{print $2}')

if [ -x "$(command -v zypper)" ]; then
  zypper --non-interactive install python python-xml
elif [ -x "$(command -v dnf)" ]; then
  dnf -y install python36
  dnf -y install policycoreutils-python-utils
elif [ -x "$(command -v apt)" ]; then
  # Ubuntu 20.04+ has python-is-python3 package
  if [ $MAJOR_VERSION -ge 5 ] ; then
    apt -y python-is-python3
  else
    apt -y install python3
  fi
else
  yum -y install python
fi

if [ -x "$(command -v python)" ]; then
  curl "https://bootstrap.pypa.io/get-pip.py" | python
elif [ -x "$(command -v python3)" ]; then
  curl "https://bootstrap.pypa.io/get-pip.py" | python3
else
  echo "Unable to install Python PIP as there is no python or python3 installed"
fi
