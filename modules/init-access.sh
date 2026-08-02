#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

echo "setup access from the control pane"

# useradd/groupadd are non-interactive and exist on both Debian- and
# RHEL-family systems, unlike adduser/addgroup
if getent passwd mikhail > /dev/null; then
    echo "user mikhail already exists"
else
    useradd -m -s /bin/bash mikhail
fi
getent group wheel > /dev/null || groupadd wheel

if getent group wheel > /dev/null; then
    usermod -aG wheel mikhail
fi
if getent group sudo > /dev/null; then
    usermod -aG sudo mikhail
fi

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
echo "appending mikhail@Mik-Snapdragon1 key to ~mikhail/.ssh/authorized_keys"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCm97xp2GLDKMvBr6ohmgWchObBa3mnv9B+E8Vtt5DIzMM7PgPjgCGy6pCaPJ6A7l9k3ACV3lV6fKcJ84sE6GqCY5+tNF+VuzsivE16/cfAiU99ITL+7ljLGi3KnECwLWwR17M5Sig3BqQu1BG6171JDh+LFlD4O4budERA+idfNb/seZpGVH1lpYuAZyf2qbsMvCRcH7enyuclN2vMBlAVM5mkO/dz1himCuVmB2K6pic1K5x8P8pi+rmwAxzdS7uTKkx7ti+jJK//QWEUjjSNN7RW2L0zlTQyXCnYO4IevGCoTuXjzwqfpmSAsOJJ+DzEYuEw9F0aEtm6bacOP7h/uifyY99xbOBaPnnnbeoEBOM6FOzuH+YL+9Rwn92T9LQ5YdxZKHqIfhKqVgMnTKwgdQbq0X0GXHlqsg68rz/Q0T1vHmq+KOtT7+GkFrPJYMcgAEGMWdNSj9ZDS/CBYi5jX2Sr84PDfvvv7oKq26F8fA/lH3f8Z8ISD2p3mDNpoHwKXbQYEU6IARWr58aBJ0MQqxpQkgdngW5/oPE+Zt5jaghLQN/l3TlLR4ya5ysSjNQWLXlcgGSDSL+rlH+0ViTkmK9ypemSHp7KyIM4oL8lt8CtuoblJvkonFvGlFUnxTkx7rY4lk4gJAGjja7dTA8su/UTG01e5JXzNyXxMyThLw== mikhail@Mik-Snapdragon1">>~mikhail/.ssh/authorized_keys
chmod -v 600 ~mikhail/.ssh/authorized_keys
chown -vR mikhail:mikhail  ~mikhail/.ssh/authorized_keys

if ls ~mikhail/.ssh/id_* 1> /dev/null 2>&1; then
    echo "list of present keys for the user:"
    for keyfile in ~mikhail/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq || true
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

OCLONDON="$(dig +short oclondon5.bluestar.cloud | tail -n1)" || OCLONDON=""

if [ -z "$OCLONDON" ]; then
	echo "WARNING: could not resolve oclondon5.bluestar.cloud, IP-based access rules will be skipped"
fi

if [ -f /etc/hosts.allow ]
then
	echo "hosts.allow is present"

	if ! grep -q oclondon5 /etc/hosts.allow; then
   		echo "hosts.allow doesn't include oclondon5, will append it"
		if [ -n "$OCLONDON" ]; then
			sed -i "1 i\sshd : ${OCLONDON} : allow" /etc/hosts.allow
		fi
		sed -i '1 i\sshd : oclondon5.bluestar.cloud : allow' /etc/hosts.allow
	fi
fi

if systemctl is-active --quiet firewalld
then
	if [ -n "$OCLONDON" ]; then
		echo "firewalld is active, will add a rule to allow SSH from oclondon5"
		firewall-cmd --permanent --zone=trusted --add-source="${OCLONDON}"
		echo "now firewalld has following settings for the trusted zone"
		firewall-cmd --zone=trusted --list-all
	else
		echo "firewalld is active but oclondon5 did not resolve, skipping trusted zone rule"
	fi
fi

sudoers_file=/etc/sudoers.d/mikhail

if [ -f "$sudoers_file" ]; then
	echo "$sudoers_file already exists, leaving it unchanged"
elif grep -q '^mikhail' /etc/sudoers 2> /dev/null; then
	# hosts bootstrapped by older versions of this script have the
	# entry directly in /etc/sudoers
	echo "/etc/sudoers already contains a record for mikhail"
elif [ -d /etc/sudoers.d ]; then
	echo "will add mikhail as NOPASSWD:ALL via $sudoers_file"
	echo 'mikhail ALL=(root) NOPASSWD:ALL' > "${sudoers_file}.tmp"
	# never install a sudoers file that visudo rejects: a malformed
	# file disables sudo entirely
	if visudo -cf "${sudoers_file}.tmp"; then
		chmod 0440 "${sudoers_file}.tmp"
		mv "${sudoers_file}.tmp" "$sudoers_file"
	else
		echo "generated sudoers entry failed visudo validation, not installing it"
		rm -f "${sudoers_file}.tmp"
	fi
else
	echo "/etc/sudoers.d not found, skipping sudo configuration for mikhail"
fi
