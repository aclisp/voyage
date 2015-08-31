rm -f /run/flannel/subnet.env
iptables -t nat -F

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
flanneld --iface=$FLANNEL_IFACE --etcd-endpoints=http://$MASTER_IP:4001 -ip-masq=true
