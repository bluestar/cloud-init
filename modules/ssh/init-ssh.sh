#!/bin/bash

echo "init SSH module"
if [ -f ~/.ssh/id_rsa ]
then
	echo "Private key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "" -f ~/.ssh/id_rsa
fi

if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
fi