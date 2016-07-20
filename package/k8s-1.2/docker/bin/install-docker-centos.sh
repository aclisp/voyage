#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

# MUST run on Linux centos kernel 2.6.32-431 or higher
# https://docs.docker.com/v1.7/docker/installation/centos/
KERNEL=$(uname -r)
KERNEL_PATTERN='2\.6\.32-([0-9]+)\..+'
if [[ $KERNEL =~ $KERNEL_PATTERN ]]; then
    KERNEL_MINOR=${BASH_REMATCH[1]}
    if (( $KERNEL_MINOR < 431 )); then
        >&2 echo "Kernel $KERNEL can not run docker!"
        exit 1
    fi
else
    >&2 echo "Kernel $KERNEL can not run docker!"
    exit 1
fi

# Warn if docker is already installed
if rpm -q --quiet docker-io; then
    echo "Docker is already installed. May overwrite existing config."
fi

# Install docker rpms
yum -y update ca-certificates
yum -y install epel-release
yum -y install device-mapper-devel
yum -y remove docker
yum -y install docker-io

# Stop default running docker (if any) cleanly
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash $THIS_DIR/_docker-stop.sh

# Disable docker entry in the system
chkconfig docker off
chkconfig --del docker
mv /etc/sysconfig/docker /etc/sysconfig/docker.bak
mv /etc/sysconfig/docker-network /etc/sysconfig/docker-network.bak
mv /etc/sysconfig/docker-storage /etc/sysconfig/docker-storage.bak
mv /etc/rc.d/init.d/docker /etc/rc.d/init.d/docker.bak

exit 0
