#!/bin/bash

if [ -f ~/.ssh/id_rsa ]
then
	echo "Private key is present, skipping ssh-keygen stage"
else
    passphrase=$( gpg --gen-random --armor 1 20 )
    echo "$passphrase" > ~/.ssh/.secret
    chmod 0600 > ~/.ssh/.secret
	ssh-keygen -N $passphrase -f ~/.ssh/id_rsa
fi
