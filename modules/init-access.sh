#!/bin/bash

echo "setup access from the control pane"

adduser mikhail
[ $(getent group wheel) ] || addgroup wheel

[ $(getent group wheel) ] && usermod -aG wheel mikhail
[ $(getent group sudo) ] && usermod -aG sudo mikhail

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
echo "appending mikhail@oclondon5 key to ~mikhail/.ssh/authorized_keys"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0ndI9pVcdVnIVX1BGNoO6BUlzOPp4AkXGQ7jEwCAVt mikhail@oclondon5">>~mikhail/.ssh/authorized_keys
echo "appending mikhail@Carminestar-M2 key to ~mikhail/.ssh/authorized_keys"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8C0myMlTz89f1SOdlfM7lcLdb1M0HAPoLh6vsnDmMc mikhail@Carminestar-M2">>~mikhail/.ssh/authorized_keys
echo "appending mikhail@Mikhail-PC key to ~mikhail/.ssh/authorized_keys"
#echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdtj2n96cIk+jnSghluyZvNivo2JQVHpZN+hDUKazA0 mikhail@Mikhail-PC">>~mikhail/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN276PzeQ0Vop7ieSfM+MktazQfrSBmxlrnfDkxUzsqb mikhail@Mikhail-PC">>~mikhail/.ssh/authorized_keys
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

OCLONDON="$(dig +short oclondon5.bluestar.cloud | tail -n1)"

if [ -f /etc/hosts.allow ]
then
	echo "hosts.allow is present"
	
	if ! grep oclondon5  /etc/hosts.allow; then
   		echo "hosts.allow doesn't include oclondon5, will append it"
		sed -i "1 i\sshd : ${OCLONDON} : allow" /etc/hosts.allow
		sed -i '1 i\sshd : oclondon5.bluestar.cloud : allow' /etc/hosts.allow
	fi
fi

systemctl is-active --quiet firewalld
if [ $? -eq 0 ]
then
	echo "firewalld is active, will add a rule to allow SSH from oclondon5"
	firewall-cmd --permanent --zone=trusted --add-source="${OCLONDON}"
	echo "now firewalld has following settings for the trusted zone"
	firewall-cmd --zone=trusted --list-all
fi

if [ -f /etc/sudoers ]
then
    if ! grep mikhail /etc/sudoers; then
		echo "/etc/sudoers found, will add mikhail as NOPASSWD:ALL"
		sed -i '$ a\mikhail ALL=(root) NOPASSWD:ALL' /etc/sudoers
	else
		echo "/etc/sudoers found and it contains a record for mikhail"
	fi
fi
