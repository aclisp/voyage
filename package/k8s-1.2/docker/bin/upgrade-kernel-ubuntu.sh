#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

export DEBIAN_FRONTEND=noninteractive
. /etc/lsb-release
# Disable AppArmor framework
invoke-rc.d apparmor kill
invoke-rc.d apparmor stop
/etc/init.d/apparmor teardown
update-rc.d -f apparmor remove
apt-get -y remove apparmor
# Install Docker as instructed by https://docs.docker.com/engine/installation/linux/ubuntulinux/
apt-get -y update
apt-get -y install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/docker.list
apt-get -y update
apt-get -y purge lxc-docker
apt-cache policy docker-engine
apt-cache policy linux-image-generic-lts-trusty
#apt-get -y install linux-image-generic-lts-trusty=3.13.0.86.78
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dpkg -i $THIS_DIR/../data/ubuntu/deb/*.deb
# Reboot when all done
>&2 echo "Reboot to use the new kernel!"

exit 1
