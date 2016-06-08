# Stop all running docker containers
docker stop $(docker ps -q)

# Disable docker daemon auto-restart
service monit stop

# Now it is safe to stop docker daemon
service docker stop

# Remove docker garbage left over in system
iptables -t nat -D PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -D POSTROUTING -s $(ip route | grep 'dev docker0' | cut -f1 -d' ') ! -o docker0 -j MASQUERADE
iptables -t nat -D OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -F DOCKER
iptables -t nat -X DOCKER
iptables -D FORWARD -o docker0 -j DOCKER
iptables -D FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i docker0 ! -o docker0 -j ACCEPT
iptables -D FORWARD -i docker0 -o docker0 -j ACCEPT
iptables -F DOCKER
iptables -X DOCKER

# Remove docker interface
ip link set dev docker0 down
brctl delbr docker0
