#!/bin/bash

echo "setup access for pmikhail"
echo "curl -s -L https://raw.githubusercontent.com/bluestar/cloud-init/master/modules/init-access-pmikhail.sh | bash"

adduser pmikhail

getent group wheel && usermod -aG wheel pmikhail
getent group sudo && usermod -aG sudo pmikhail

usermod -aG wheel sudo

if [[ ! -e ~pmikhail/.ssh ]]; then
    mkdir ~pmikhail/.ssh
else
    echo "~pmikhail/.ssh already exists"
fi

chmod -v 700 ~pmikhail/.ssh
chown -vR pmikhail:pmikhail  ~pmikhail/.ssh

if [ -f  ~pmikhail/.ssh/authorized_keys ]
then
	echo "~pmikhail/.ssh/authorized_keys is present and it contains:"
	cat ~pmikhail/.ssh/authorized_keys
	echo "will clean it up"
	cat /dev/null >|  ~pmikhail/.ssh/authorized_keys
fi
echo "appending pmikhail@azlondon1 key to ~pmikhail/.ssh/authorized_keys"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuV8obRPQp2AZtFpis86teB5k5MvoAAwFSGLaq6OWbZ0g855427ojRbQaKiRK1kaJrl6JjDSOJ66Cec24NU8NMh1QgPzBYmJnyaGG5DrJFX6/9cM+SzcB9xQTOdHvEMVzYTvFHSjhesqvzkLmkkBLviuwgiESYLmCkZO3XqpC0nmUzUa0YBUjyyVvVS1PeG3qfNOGknLPLgbx1cMg1FL37MyVvqf4DEwdt0Y83ps9bAdocHK/se/O3i9YoGv6Wanp2tZhK1d+ByDLtPLyaThfaMB4ou5V+6PghSi+Cjq8zERWpucWhSd1JKsdIvyhi5MwGoZIr7q+nkHJBYjo+N3H1KFhOSqAxfynzVkU+zQji17wPlnAlKXIxvdSyjY5Z27WN2gEyvcqWiKwVAR+xYP9bABKUkUmP4929OnkB4rITakDLEPaVQiMuFg99t3JtkoIIeCagDYITaN/+DTA4Vl2OGmKTMeDD7kwHqLAnJFV2bvAYwOipv9ZfopETJPhoS3E= Mikhail.Popov@ntb-opequon">~pmikhail/.ssh/authorized_keys
chmod -v 644 ~pmikhail/.ssh/authorized_keys
chown -vR pmikhail:pmikhail  ~pmikhail/.ssh/authorized_keys

if ls ~pmikhail/.ssh/id_* 1> /dev/null 2>&1; then
    echo "list of present keys for the user:"
    for keyfile in ~pmikhail/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq
fi

if [ -f ~pmikhail/.ssh/id_rsa ]
then
	echo "A private RSA key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "bluestar.cloud" -t rsa -b 4096 -f ~pmikhail/.ssh/id_rsa
fi

if [ -f ~pmikhail/.ssh/id_dsa ]
then
	echo "A private DSA key is present, will remove it and an associated public key"
	rm -fv ~pmikhail/.ssh/id_dsa*
fi

if [ -f ~pmikhail/.ssh/id_ed25519 ]
then
	echo "A private Ed25519 key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "bluestar.cloud" -t ed25519 -f ~pmikhail/.ssh/id_ed25519
fi
