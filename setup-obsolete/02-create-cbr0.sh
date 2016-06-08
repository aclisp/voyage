ip link set dev cbr0 down
brctl delbr cbr0

while [ ! -f /run/flannel/subnet.env ]; do
	echo "Waiting for flannel..."
	sleep 1
done
source /run/flannel/subnet.env
brctl addbr cbr0
ip addr add $FLANNEL_SUBNET dev cbr0
ip link set dev cbr0 up
