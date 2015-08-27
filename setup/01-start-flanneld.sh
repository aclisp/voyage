DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
flanneld --iface=$FLANNEL_IFACE --etcd-endpoints=http://$MASTER_IP:4001
