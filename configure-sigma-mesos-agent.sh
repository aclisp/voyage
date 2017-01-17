#!/bin/bash
set -x  # turn on trace
set -e  # turn on exit immediately

echo "==========================================="
echo "  Install packages ..."
echo "==========================================="

apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
apt-get update
apt-get -y install mesos

echo "==========================================="
echo "  Install packages OK"
echo "  Provisioning ..."
echo "==========================================="

stop zookeeper || true
echo "manual" > /etc/init/zookeeper.override
stop mesos-master || true
echo "manual" > /etc/init/mesos-master.override
echo "/data/mesos" > /etc/mesos-slave/work_dir
echo $(grep ip_isp_list /home/dspeak/yyms/hostinfo.ini | sed 's/^ip_isp_list=//' | awk -F',' '{ for(i = 1; i <= NF; i++) { if ($i ~ /:CTL$/) print $i; } }' | sed 's/:CTL$//' | head -n 1) > /etc/mesos-slave/hostname
cp /etc/mesos-slave/hostname /etc/mesos-slave/ip
mkdir -p /etc/mesos-slave/attributes
echo idc$(grep idc_id /home/dspeak/yyms/hostinfo.ini | sed 's/^idc_id=//' | head -n 1) > /etc/mesos-slave/attributes/idc_id
echo "zk://61.160.36.73:2181,61.160.36.74:2181,61.160.36.75:2181/mesos" > /etc/mesos/zk
start mesos-slave || true

echo "==========================================="
echo "  Provisioning OK"
echo "  Checking ..."
echo "==========================================="

status mesos-slave
sleep 3
cat /proc/$(pidof mesos-slave)/cmdline | tr '\0' '\n'
