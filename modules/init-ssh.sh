#!/bin/bash

set -euo pipefail

if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2> /dev/null; then
    echo "WSL detected, refusing to run"
    exit 1
fi

echo "init SSH module"

host_keys_changed=0

echo "list of present keys for the server:"
for keyfile in /etc/ssh/ssh_host*; do ssh-keygen -l -f "${keyfile}"; done | uniq || true

if [ -f /etc/ssh/ssh_host_rsa_key ]
then
	echo "A host RSA key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "" -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key
	host_keys_changed=1
fi

if [ -f /etc/ssh/ssh_host_dsa_key ]
then
	echo "A host DSA key is present, will remove it and an associated public key"
	rm -fv /etc/ssh/ssh_host_dsa*
	host_keys_changed=1
fi

if [ -f /etc/ssh/ssh_host_ecdsa_key ]
then
	echo "A host ECDSA is present, will remove it and an associated public key"
	rm -fv /etc/ssh/ssh_host_ecdsa*
	host_keys_changed=1
fi

if [ -f /etc/ssh/ssh_host_ed25519_key ]
then
	echo "A host Ed25519 key is present, skipping ssh-keygen stage"
else
	ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
	host_keys_changed=1
fi

# sshd only re-reads host keys on reload/restart; reload keeps
# established connections alive. The service is sshd on RHEL-family
# and SUSE, ssh on Debian/Ubuntu.
if [ "$host_keys_changed" -eq 1 ]; then
	for unit in sshd ssh; do
		if systemctl is-active --quiet "$unit" 2> /dev/null; then
			echo "host keys changed, reloading $unit"
			systemctl reload-or-restart "$unit"
			break
		fi
	done
fi

if ls ~/.ssh/id_* 1> /dev/null 2>&1; then
    echo "list of present keys for the user:"
    for keyfile in ~/.ssh/id_*; do ssh-keygen -l -f "${keyfile}"; done | uniq || true
fi

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

# an agent started here would die with the script, so don't try to set
# one up; instead start a throwaway agent to verify the root key loads
if [ -x "$(command -v ssh-agent)" ]; then
    echo "verifying the root Ed25519 key loads into ssh-agent"
    eval "$(ssh-agent -s)" > /dev/null
    if ssh-add ~/.ssh/id_ed25519 2> /dev/null; then
        echo "key verification OK:"
        ssh-add -l
    else
        echo "WARNING: failed to load ~/.ssh/id_ed25519 into ssh-agent"
    fi
    ssh-agent -k > /dev/null
fi