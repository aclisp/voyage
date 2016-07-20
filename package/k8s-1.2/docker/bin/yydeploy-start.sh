#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

#---------------#
# 进程数量设置  #
#---------------#

count=1

#----------------#
# 初始化日志文件 #
#----------------#

log=$INSTALL_PATH/log/$APP_NAME.log

true > $log

#-------------#
# 进程数检查  #
#-------------#

x=$(pidof $APP_NAME |wc -w)
y=$((count-x))
echo "delta=$y"

#--------------------------#
# 进程数大于 $count 就退出 #
#--------------------------#

if [ $y -le 0 ] ; then
   pidof $APP_NAME | xargs -r ps -lf
   echo "$APP_NAME num ($x) >= $count , no need to start , quit"
   exit 0
fi

#---------------#
# 启动 cgroup   #
#---------------#

if [[ -e /etc/centos-release ]]; then
    service cgconfig status
    if [[ $? != 0 ]]; then
        mountpoint -q /cgroup || mount -t tmpfs cgroup /cgroup
        umount /cgroup/cpu /cgroup/cpuset /cgroup/cpuacct /cgroup/memory /cgroup/devices /cgroup/freezer /cgroup/net_cls /cgroup/blkio
        service cgconfig start
    fi

    DOCKER=/usr/bin/docker
    DOCKER_DAEMON=-d

elif [[ -e /etc/lsb-release ]]; then
    if ! mountpoint -q /sys/fs/cgroup; then
        mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
    fi
    (
        cd /sys/fs/cgroup
        for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
            mkdir -p $sys
            if ! mountpoint -q $sys; then
                if ! mount -n -t cgroup -o $sys cgroup $sys; then
                    rmdir $sys || true
                fi
            fi
        done
    )

    DOCKER=/usr/bin/docker
    DOCKER_DAEMON=-d

else
    >&2 echo "OS should be centos or ubuntu to run cgroup!"
    exit 1
fi

#---------------#
# 启动进程      #
#---------------#

cd $INSTALL_PATH/bin || exit 1

DOCKER_CERT_PATH=/etc/docker
DOCKER_NOWARN_KERNEL_VERSION=1
DOCKER_NOFILE=1000000
ulimit -n 1000000
[[ -e /run/flannel/subnet.env ]] && . /run/flannel/subnet.env
DOCKER_BIP=${FLANNEL_SUBNET:-"127.0.1.1/24"}
DOCKER_MTU=${FLANNEL_MTU:-0}
if [[ $FLANNEL_IPMASQ == "true" ]]; then
    DOCKER_MASQ=false
else
    DOCKER_MASQ=true
fi
DOCKER_OPTS=$(eval echo $(cat ../conf/$APP_NAME-options.conf | tr '\n' ' '))

for ((i=1;i<=$y;i++)); do
     echo "start #$i"
     nohup $DOCKER $DOCKER_DAEMON $DOCKER_OPTS >>$log 2>&1 &
     sleep 2
done

#---------------#
# 二次确认      #
#---------------#

if [ $(pidof $APP_NAME |wc -w) -eq $count ] ; then
     echo "start $APP_NAME ok"
     echo "output last 20 lines of $log"
     tail -n 20 $log
     pidof $APP_NAME |xargs -r ps -lf
     exit 0
else
     echo "start $APP_NAME failed"
     echo "output last 20 lines of $log"
     tail -n 20 $log
     pidof $APP_NAME |xargs -r ps -lf
     exit 1
fi
