ip link set dev cbr0 down
brctl delbr cbr0

source /run/flannel/subnet.env
brctl addbr cbr0
ip addr add $FLANNEL_SUBNET dev cbr0
ip link set dev cbr0 up
