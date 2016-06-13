#!/bin/bash

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

# Skip if docker is already installed
if rpm -q --quiet docker-io; then
    echo "Docker is already installed."
    exit 0
fi

# Install docker rpms
yum -y update ca-certificates
yum -y install epel-release
yum -y install device-mapper-devel
yum -y remove docker
yum -y install docker-io
cp /etc/sysconfig/docker /etc/sysconfig/docker.bak
cp /etc/init.d/docker /etc/init.d/docker.bak
sed -i "s#\&>> \$logfile#>> \$logfile 2>\&1#" /etc/init.d/docker
sed -i "s#\(killproc -p \$pidfile -d\).*\(\$prog\)#\1 60 \2#" /etc/init.d/docker
grep -q "^mountpoint -q /cgroup || mount -t tmpfs cgroup /cgroup" /etc/init.d/docker || sed -i '/service cgconfig start/i \
mountpoint -q /cgroup || mount -t tmpfs cgroup /cgroup' /etc/init.d/docker

# Tune docker parameters
grep -q "^DOCKER_NOFILE" /etc/sysconfig/docker && sed -i "s/^DOCKER_NOFILE.*/DOCKER_NOFILE=1000000/" /etc/sysconfig/docker || echo "DOCKER_NOFILE=1000000" >> /etc/sysconfig/docker
grep -q "^ulimit -n" /etc/sysconfig/docker && sed -i "s/^ulimit -n.*/ulimit -n 1000000/" /etc/sysconfig/docker || echo "ulimit -n 1000000" >> /etc/sysconfig/docker
grep -q "^source /run/flannel/subnet.env" /etc/sysconfig/docker || sed -i '/^other_args.*/i \
source /run/flannel/subnet.env' /etc/sysconfig/docker
sed -i 's/^other_args.*/other_args="--iptables=true --ip-masq=false --log-level=warn --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --graph=\/data\/docker --insecure-registry=61.160.36.122:8080"/' /etc/sysconfig/docker

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash $THIS_DIR/_docker-stop.sh
service docker start

# Install process monitor
yum -y install monit
chkconfig monit on
service monit start

# Install docker monit script
cat > /tmp/docker << EOF
check process docker with pidfile /var/run/docker.pid every 3 cycles
group docker
start program = "/etc/init.d/docker start"
stop program = "/etc/init.d/docker stop" with timeout 70 seconds
if does not exist then restart
if failed
  unixsocket /var/run/docker.sock
  protocol HTTP request "/version"
then restart
EOF
cp -f /tmp/docker /etc/monit.d/docker
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
