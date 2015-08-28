service docker stop
sysv-rc-conf docker off
echo manual > /etc/init/docker.override
ip link set dev docker0 down
brctl delbr docker0
iptables -t nat -F

source /run/flannel/subnet.env
docker daemon --bridge=cbr0 --iptables=false --ip-masq=false --mtu=$FLANNEL_MTU --log-level=warn
