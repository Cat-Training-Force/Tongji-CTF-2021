#!/bin/bash -eu
#
# Provision Ubuntu VMs (vagrant shell provisioner).
#


readonly PYTHON_VERSION="3.8"
readonly PYTHON_VIRTUALENV="responder-venv"


if [[ "$(id -u)" != "$(id -u vagrant)" ]]; then
    echo "The provisioning script must be run as the \"vagrant\" user!" >&2
    exit 1
fi


echo "provision.sh: Customizing the base system..."

readonly DISTRO_CODENAME="$(lsb_release -cs)"

# Ordered list of Ubuntu releases, first being the latest, for later checks...
readonly DISTRO_CODENAMES=($(curl -sSL https://releases.ubuntu.com/ \
                                 | perl -lne 'print lc("$1 $2") if /href=[^>]+>\s*Ubuntu\s+([0-9.]+)\s+(?:LTS\s+)?\(\s*([a-z]+)\s+/i' \
                                 | sort -rn \
                                 | awk '{print $2}'))

# Getting the above list by parsing some random webpage is brittle and may fail in the future...
if [[ "${#DISTRO_CODENAMES[@]}" -lt 2 ]]; then
    echo "ERROR: Couldn't fetch the list of Ubuntu releases. Provisioning might not complete successfully." >&2
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
    avahi-daemon mlocate rsync lsof iotop htop \
    ntpdate pv tree vim tmux ltrace strace \
    curl apt-transport-https dnsutils zip unzip net-tools

# This is just a matter of preference...
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install netcat-openbsd
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge netcat-traditional

# Minimize the number of running daemons...
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge \
    lxcfs snapd open-iscsi mdadm accountsservice acpid
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove

# This delays boot by *a lot* for no apparent reason...
sudo systemctl -q mask systemd-networkd-wait-online

# We don't want the system to change behind our backs...
sudo systemctl -q is-active unattended-upgrades && sudo systemctl stop unattended-upgrades
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y purge unattended-upgrades

# Set a local timezone (the default for Ubuntu boxes is GMT)...
sudo timedatectl set-timezone "Europe/Lisbon"
echo "VM local timezone: $(timedatectl | awk '/[Tt]ime\s+zone:/ {print $3}')"

sudo systemctl -q enable systemd-timesyncd
sudo systemctl start systemd-timesyncd

# This gives us an easly reachable ".local" name for the VM...
sudo systemctl -q enable avahi-daemon 2>/dev/null
sudo systemctl start avahi-daemon
echo "VM available from the host at: ${HOSTNAME}.local"

# Prevent locale from being forwarded from the host, causing issues...
if sudo grep -q '^AcceptEnv\s.*LC_' /etc/ssh/sshd_config; then
    sudo sed -i 's/^\(AcceptEnv\s.*LC_\)/#\1/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
fi

# Generate the initial "locate" DB...
if sudo test -x /etc/cron.daily/mlocate; then
    sudo /etc/cron.daily/mlocate
fi

# Remove the spurious "you have mail" message on login...
if [[ -s "/var/spool/mail/${USER}" ]]; then
    echo -n > "/var/spool/mail/${USER}"
fi

# If another (file) provisioner made the host user's credentials available
# to us (see the "Vagrantfile" for details), let it use "scp" and stuff...
if [[ -f /tmp/id_rsa.pub ]]; then
    pushd "${HOME}/.ssh" >/dev/null

    if [[ ! -f .authorized_keys.vagrant ]]; then
        cp authorized_keys .authorized_keys.vagrant
    fi

    cat .authorized_keys.vagrant /tmp/id_rsa.pub > authorized_keys
    chmod 0600 authorized_keys
    rm -f /tmp/id_rsa.pub

    popd >/dev/null
fi

# Make "vagrant ssh" sessions more comfortable by tweaking the
# configuration of some system utilities (eg. bash, vim, tmux)...
rsync -r --exclude=.DS_Store "${HOME}/shared/vagrant/skel/" "${HOME}/"

# Disable verbose messages on login...
echo -n > "${HOME}/.hushlogin"


echo "provision.sh: Configuring custom repositories..."

#
# Use packages for the previous Ubuntu release if the current one isn't supported yet.
# Docker upstream takes a while to catch up, as they don't rebuild existing packages.
#
readonly DOCKER_POOL="https://download.docker.com/linux/ubuntu/dists/${DISTRO_CODENAME}/pool/stable/amd64/"

if [ "$DISTRO_CODENAME" = "${DISTRO_CODENAMES[0]}" ] && ! curl -sSL "$DOCKER_POOL" | cat | grep -q "\.deb"; then
    readonly DOCKER_DISTRO_CODENAME="${DISTRO_CODENAMES[1]}"
    echo "No Docker CE packages for '${DISTRO_CODENAME}' release, using '${DOCKER_DISTRO_CODENAME}' instead." >&2
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install bridge-utils
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add -
sudo tee "/etc/apt/sources.list.d/docker-stable.list" >/dev/null <<EOF
deb [arch=amd64] https://download.docker.com/linux/ubuntu ${DOCKER_DISTRO_CODENAME:-$DISTRO_CODENAME} stable
EOF

sudo tee "/etc/apt/preferences.d/docker-pinning" >/dev/null <<EOF
Package: *
Pin: origin "download.docker.com"
Pin-Priority: 1001
EOF


# No packages from the above repositories have been installed,
# but prepare things for that to (maybe) happen further below...
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update


echo "provision.sh: Running project-specific actions..."

sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
    git build-essential \
    nmap


##
## Setup Docker...
##

sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install docker-ce

# Don't require sudo to use docker...
sudo usermod -a -G docker vagrant

sudo systemctl -q enable docker
sudo systemctl restart docker


##
## Setup the Python bits...
##

sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install python3 python3-venv python3-dev

if [[ ! -d "${HOME}/${PYTHON_VIRTUALENV}" ]]; then
    pushd "${HOME}" >/dev/null
    /usr/bin/python${PYTHON_VERSION} -m venv "${PYTHON_VIRTUALENV}"
    popd >/dev/null
fi

# Install dependencies...
source "${HOME}/${PYTHON_VIRTUALENV}/bin/activate"
pip install --upgrade pip setuptools wheel  # ...ensure these are up-to-date.
pip install --upgrade -r "${HOME}/shared/requirements.txt"
deactivate

# Activate the virtualenv on login...
if ! grep -q "${HOME}/${PYTHON_VIRTUALENV}/bin/activate" ~/.bashrc; then
    printf "\n[ -z \"\$VIRTUAL_ENV\" ] && . ${HOME}/${PYTHON_VIRTUALENV}/bin/activate\n" >> "${HOME}/.bashrc"
fi

echo net.ipv4.icmp_echo_ignore_all=1 | sudo tee /etc/sysctl.d/z01-disable_echo_reply.conf >/dev/null
sudo systemctl restart systemd-sysctl

echo "provision.sh: Done!"


# vim: set expandtab ts=4 sw=4:
