#!/bin/bash

echo "setup access from the control pane"

adduser mikhail

getent group wheel && usermod -aG wheel mikhail
getent group sudo && usermod -aG sudo mikhail

usermod -aG wheel sudo

if [[ ! -e ~mikhail/.ssh ]]; then
    mkdir ~mikhail/.ssh
else
    echo "~mikhail/.ssh already exists"
fi

chmod -v 700 ~mikhail/.ssh
chown -vR mikhail:mikhail  ~mikhail/.ssh

if [ -f  ~mikhail/.ssh/authorized_keys ]
then
	echo "~mikhail/.ssh/authorized_keys is present and it contains:"
	cat ~mikhail/.ssh/authorized_keys
	echo "will clean it up"
	cat /dev/null >|  ~mikhail/.ssh/authorized_keys
fi
#echo "appending mikhail@azlondon1 key to ~mikhail/.ssh/authorized_keys"
#echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaTVQI0jD43nDrYOzDDzbIoA/Qe2TRFA6Eq8MbyqBCo mikhail@azlondon1.bluestar.cloud">>~mikhail/.ssh/authorized_keys
echo "appending mikhail@azlondon3 key to ~mikhail/.ssh/authorized_keys"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3l4P/tbD0SjOEt6l8GmTAb5ZKOiHgs7I9aywVwwA9S mikhail@azlondon3.bluestar.cloud">>~mikhail/.ssh/authorized_keys
echo "appending mikhail@Carminestar-M2 key to ~mikhail/.ssh/authorized_keys"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+lu44XmYowFufA4d+KPtmqQCsTFPBGiEofYZC4FbY0 mikhail@Carminestar-M2">>~mikhail/.ssh/authorized_keys
chmod -v 644 ~mikhail/.ssh/authorized_keys
chown -vR mikhail:mikhail  ~mikhail/.ssh/authorized_keys

if ls ~mikhail/.ssh/id_* 1> /dev/null 2>&1; then
    echo "list of present keys for the user:"
    for keyfile in ~mikhail/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq
fi

if [ -f ~mikhail/.ssh/id_rsa ]
then
	echo "A private RSA key is present, skipping ssh-keygen stage"
else
	sudo -u mikhail ssh-keygen -q -N "bluestar.cloud" -t rsa -b 4096 -f ~mikhail/.ssh/id_rsa
fi

if [ -f ~mikhail/.ssh/id_dsa ]
then
	echo "A private DSA key is present, will remove it and an associated public key"
	rm -fv ~mikhail/.ssh/id_dsa*
fi

if [ -f ~mikhail/.ssh/id_ed25519 ]
then
	echo "A private Ed25519 key is present, skipping ssh-keygen stage"
else
	sudo -u mikhail ssh-keygen -q -N "bluestar.cloud" -t ed25519 -f ~mikhail/.ssh/id_ed25519
fi

AZLONDON="$(dig +short azlondon3.bluestar.cloud | tail -n1)"

if [ -f /etc/hosts.allow ]
then
	echo "hosts.allow is present"

	if ! grep azlondon3  /etc/hosts.allow; then
   		echo "hosts.allow doesn't include azlondon3, will append it"
		sed -i "1 i\sshd : ${AZLONDON} : allow" /etc/hosts.allow
		sed -i '1 i\sshd : azlondon3.bluestar.cloud : allow' /etc/hosts.allow
	fi
fi

systemctl is-active --quiet firewalld
if [ $? -eq 0 ]
then
	echo "firewalld is active, will add a rule to allow SSH from azlondon3"
	firewall-cmd --permanent --zone=trusted --add-source="${AZLONDON}"
	echo "now firewalld has following settings for the trusted zone"
	firewall-cmd --zone=trusted --list-all
fi

if [ -f /etc/sudoers]
then
    if  ! grep mikhail /etc/sudoers; then
		echo "/etc/sudoers found, will add mikhail as NOPASSWD:ALL"
		sed -i '$ a\mikhail ALL=(root) NOPASSWD:ALL' /etc/sudoers
	else
		echo "/etc/sudoers found and it contains a record for mikhail"
	fi
fi