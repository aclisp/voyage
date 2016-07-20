#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

# MUST run on Linux ubuntu kernel 3.13 or higher
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
KERNEL=$(uname -r)
KERNEL_PATTERN='3\.([0-9]+)\.([0-9]+)-([0-9]+)-generic'
if [[ $KERNEL =~ $KERNEL_PATTERN ]]; then
    KERNEL_MINOR=${BASH_REMATCH[1]}
    if (( $KERNEL_MINOR < 13 )); then
        >&2 echo "Kernel $KERNEL can not run docker!"
        >&2 echo "Run upgrade-kernel-ubuntu.sh first!"
        exit 1
    fi
else
    >&2 echo "Kernel $KERNEL can not run docker!"
    >&2 echo "Run upgrade-kernel-ubuntu.sh first!"
    exit 1
fi

# Warn if docker is already installed
if dpkg -s docker-engine > /dev/null; then
    echo "Docker is already installed. May overwrite existing config."
fi

# Install docker rpms
export DEBIAN_FRONTEND=noninteractive
. /etc/lsb-release
apt-get -y update
apt-get -y install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/docker.list
apt-get -y update
apt-get -y purge lxc-docker
apt-cache policy docker-engine
apt-get -y install docker-engine=1.7.1-0~precise
apt-get -y install bridge-utils

# Stop default running docker (if any) cleanly
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash $THIS_DIR/_docker-stop.sh

# Disable docker entry in the system
update-rc.d -f docker remove
echo manual > /etc/init/docker.override

exit 0
