#!/bin/bash

echo "init python module"

yum -y install python

curl "https://bootstrap.pypa.io/get-pip.py" | python