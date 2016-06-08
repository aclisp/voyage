DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
mkdir -p /var/lib/etcd
etcd --data-dir=/var/lib/etcd --listen-client-urls=http://$MASTER_IP:4001 --advertise-client-urls=http://$MASTER_IP:4001
