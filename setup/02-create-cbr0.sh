ip link set dev cbr0 down
brctl delbr cbr0

brctl addbr cbr0
ip addr add 127.0.1.1/24 dev cbr0
ip link set dev cbr0 up
