source ./env.sh
flanneld --iface=$FLANNEL_IFACE --etcd-endpoints=http://$MASTER_IP:4001
