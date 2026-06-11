# cloud-init

Shell scripts for bootstrapping a new Linux host with the baseline tools and
access configuration used by Blue Star London.

This repository is not a replacement for distribution `cloud-init`. It is a
small, opinionated bootstrap toolkit that can be run on a newly provisioned
server to install common packages, prepare SSH access, configure Python and
timezone settings, and enable local mail forwarding.

## What It Does

The main bootstrap flow is:

1. Create `/opt/cloud-init`.
2. Download the latest module scripts from this repository.
3. Run each module as `root`.

The modules currently perform these tasks:

| Module | Purpose |
| --- | --- |
| `modules/init-yum.sh` | Initializes hosts with `yum`: installs EPEL, updates packages, and installs common tools plus postfix/mail packages. |
| `modules/init-dnf.sh` | Initializes hosts with `dnf`: installs EPEL, updates packages, installs common tools, and handles AlmaLinux mail package differences. |
| `modules/init-apt.sh` | Initializes hosts with `apt`: installs common diagnostic and administration tools. |
| `modules/init-zypper.sh` | Initializes hosts with `zypper`: installs `jq`. |
| `modules/init-ssh.sh` | Reviews SSH host keys, creates RSA and Ed25519 host keys when missing, removes DSA/ECDSA host keys, creates a root Ed25519 client key when missing, and starts `ssh-agent` if needed. |
| `modules/init-python.sh` | Installs Python packages appropriate to the detected package manager and installs `pip` from PyPA bootstrap scripts. |
| `modules/init-timezone.sh` | Uses `timezoneapi.io` and `jq` to detect timezone by public IP and points `/etc/localtime` at the matching zoneinfo file. |
| `modules/init-access.sh` | Creates/configures the `mikhail` user, adds SSH authorized keys, creates user SSH keys, updates sudo access, and optionally restricts/allows SSH access from `oclondon5.bluestar.cloud`. |
| `modules/init-postfix.sh` | Enables postfix when available, forwards root mail to `support@bluestar.cloud`, and rebuilds aliases. |

There is also `test-email.sh`, which sends a test email to the local `root`
mailbox using the `mail` command.

## Supported Systems

The scripts are written for Linux distributions that use one of these package
managers:

- `yum`
- `dnf`
- `apt`
- `zypper`

The package modules are guarded by package-manager detection, so modules for
unavailable package managers should simply skip themselves. The access, SSH,
timezone, Python, and postfix modules are more system-wide and should be
reviewed before running on a new distribution.

## Requirements

- Run as `root`.
- `curl` must be available for the bootstrap scripts.
- Internet access is required to download modules, package updates, Python
  bootstrap scripts, and timezone data.
- The package manager configured on the host must be able to install packages
  non-interactively.
- `systemctl` is expected for postfix/firewalld related steps.

## Quick Start

Download and run the boot script:

```bash
curl -s -o /var/tmp/cloud-boot.sh https://raw.githubusercontent.com/bluestar/cloud-init/master/cloud-boot.sh
bash /var/tmp/cloud-boot.sh
```

Or run it directly:

```bash
curl -s -L https://raw.githubusercontent.com/bluestar/cloud-init/master/cloud-boot.sh | bash
```

Both approaches require root privileges. If you are not already root, use
`sudo`:

```bash
curl -s -L https://raw.githubusercontent.com/bluestar/cloud-init/master/cloud-boot.sh | sudo bash
```

## Manual Usage

Clone or copy the repository, then run the main script:

```bash
sudo bash cloud-init.sh
```

To run an individual module:

```bash
sudo bash modules/init-ssh.sh
sudo bash modules/init-access.sh
```

The main script downloads fresh copies of all modules into `/opt/cloud-init`
from the `master` branch before executing them. Local changes in a cloned
checkout are not used by `cloud-boot.sh` unless you run the local module files
directly.

## Important Side Effects

Review these before running the scripts on a production system:

- Package modules perform system package updates.
- `init-ssh.sh` may remove DSA/ECDSA host keys and root RSA/DSA client keys.
- `init-access.sh` clears `~mikhail/.ssh/authorized_keys` before writing the
  repository-defined keys.
- `init-access.sh` appends passwordless sudo access for `mikhail` when no
  existing sudoers entry is found.
- `init-access.sh` can modify `/etc/hosts.allow` and firewalld trusted zone
  sources for `oclondon5.bluestar.cloud`.
- `init-timezone.sh` moves the existing `/etc/localtime` to
  `/etc/localtime.bak` before creating a symlink.
- `init-python.sh` pipes the PyPA `get-pip.py` script into the installed Python
  interpreter.
- `init-postfix.sh` rewrites the `root:` alias in `/etc/aliases` to
  `support@bluestar.cloud`.

Because the scripts are intentionally opinionated, they are best suited for
hosts that are expected to match this operational profile.

## Email Test

After postfix/mail tooling is installed, send a local test email:

```bash
sudo bash test-email.sh
```

The script sends:

- recipient: `root`
- subject: `Test email from <hostname>`
- body: current hostname and date

## Repository Layout

```text
.
|-- cloud-boot.sh        # Minimal downloader that fetches cloud-init.sh
|-- cloud-init.sh        # Main bootstrap script that downloads and runs modules
|-- modules/             # Individual initialization modules
|-- test-email.sh        # Local mail test helper
|-- LICENSE              # MIT license
`-- README.md            # Project documentation
```

## Troubleshooting

- `This script must be run as root`: rerun the command as `root` or through
  `sudo`.
- Package installation fails: check the host package manager repositories and
  network access.
- Timezone is not updated: confirm `jq` is installed, the timezone API is
  reachable, and `/usr/share/zoneinfo/<timezone>` exists.
- Postfix steps are skipped: postfix was not installed or the `postfix` command
  is not available in `PATH`.
- SSH/firewalld access rules are incomplete: confirm DNS resolution for
  `oclondon5.bluestar.cloud` with `dig +short oclondon5.bluestar.cloud`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
