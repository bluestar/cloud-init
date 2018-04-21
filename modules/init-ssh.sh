#!/bin/bash

echo "init SSH module"

if ls ~/.ssh/id_* 1> /dev/null 2>&1; then
    echo "list of present keys for the user:"
    for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq
fi

echo "list of present keys for the server:"
#ls -l /etc/ssh/ssh_host*pub
for keyfile in /etc/ssh/ssh_host*; do ssh-keygen -l -f "${keyfile}"; done | uniq

if [ -f ~/.ssh/id_rsa ]
then
	echo "A private RSA key is present, will remove it and an associated public key"
	rm -fv ~/.ssh/id_rsa*
fi

if [ -f ~/.ssh/id_dsa ]
then
	echo "A private DSA key is present, will remove it and an associated public key"
	rm -fv ~/.ssh/id_dsa*
fi

if [ -f ~/.ssh/id_ed25519 ]
then
	echo "A private Ed25519 key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "" -t ed25519 -f ~/.ssh/id_ed25519
fi

if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_ed25519
fi