#!/bin/bash

echo "init python module"

if [ -x "$(command -v zypper)" ]; then
  zypper --non-interactive install python python-xml
elif [ -x "$(command -v dnf)" ]; then
  dnf -y install python36
  dnf -y install policycoreutils-python-utils
elif [ -x "$(command -v apt)" ]; then
  apt -y install python36
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
