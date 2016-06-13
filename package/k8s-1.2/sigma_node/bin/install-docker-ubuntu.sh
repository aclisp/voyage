#!/bin/bash

# MUST run on Linux ubuntu kernel 3.13 or higher
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
KERNEL=$(uname -r)
KERNEL_PATTERN='3\.([0-9]+)\.([0-9]+)-([0-9]+)-generic'
if [[ $KERNEL =~ $KERNEL_PATTERN ]]; then
    KERNEL_MINOR=${BASH_REMATCH[1]}
    if (( $KERNEL_MINOR < 13 )); then
        >&2 echo "Kernel $KERNEL can not run docker!"
        >&2 echo "Run upgrade-kernel-ubuntu.sh first!"
        exit 0
    fi
else
    >&2 echo "Kernel $KERNEL can not run docker!"
    >&2 echo "Run upgrade-kernel-ubuntu.sh first!"
    exit 0
fi

# Skip if docker is already installed
if dpkg -s docker-engine > /dev/null; then
    echo "Docker is already installed."
    exit 0
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
apt-get -y install docker-engine=1.10.3-0~precise
apt-get -y install bridge-utils

# Tune docker parameters
DOCKER_CONFIG_FILE=/etc/default/docker
grep -q "^DOCKER_NOFILE" ${DOCKER_CONFIG_FILE} && sed -i "s/^DOCKER_NOFILE.*/DOCKER_NOFILE=1000000/" ${DOCKER_CONFIG_FILE} || echo "DOCKER_NOFILE=1000000" >> ${DOCKER_CONFIG_FILE}
grep -q "^ulimit -n" ${DOCKER_CONFIG_FILE} && sed -i "s/^ulimit -n.*/ulimit -n 1000000/" ${DOCKER_CONFIG_FILE} || echo "ulimit -n 1000000" >> ${DOCKER_CONFIG_FILE}
grep -qE "^[# ]*DOCKER_OPTS=" ${DOCKER_CONFIG_FILE} && sed -i "s/^[# ]*DOCKER_OPTS=/DOCKER_OPTS=/" ${DOCKER_CONFIG_FILE} || echo "DOCKER_OPTS=" >> ${DOCKER_CONFIG_FILE}
grep -q "^\. /run/flannel/subnet\.env" ${DOCKER_CONFIG_FILE} || sed -i '/^DOCKER_OPTS.*/i \
. /run/flannel/subnet.env' ${DOCKER_CONFIG_FILE}
sed -i 's/^DOCKER_OPTS.*/DOCKER_OPTS="--iptables=true --ip-masq=false --log-level=warn --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --graph=\/data\/docker --insecure-registry=61.160.36.122:8080"/'  ${DOCKER_CONFIG_FILE}

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash $THIS_DIR/_docker-stop.sh
service docker start

# Install process monitor
apt-get -y install monit chkconfig
chkconfig monit on
service monit start

# Install docker monit script
cat > /tmp/docker << EOF
check process docker with pidfile /var/run/docker.pid
group docker
start program = "/usr/sbin/service docker start"
stop program = "/usr/sbin/service docker stop" with timeout 70 seconds
if does not exist then restart
if failed
  unixsocket /var/run/docker.sock
  protocol HTTP request "/version"
then restart
EOF
cp -f /tmp/docker /etc/monit/conf.d/docker
service monit reload

# Rotate docker logs
cat > /tmp/docker-container << EOF
/var/lib/docker/containers/*/*.log {
    rotate 5
    nocompress
    nodateext
    missingok
    copytruncate
    size 10M
    notifempty
}

/data/docker/containers/*/*.log {
    rotate 5
    nocompress
    nodateext
    missingok
    copytruncate
    size 10M
    notifempty
}
EOF
cp -f /tmp/docker-container /etc/logrotate.d/docker-container
