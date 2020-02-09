#!/bin/bash

echo "init python module"

if [ -x "$(command -v zypper)" ]; then
  zypper --non-interactive install python
elif [ -x "$(command -v dnf)" ]; then
  dnf -y install python
else
  yum -y install python
fi

curl "https://bootstrap.pypa.io/get-pip.py" | python