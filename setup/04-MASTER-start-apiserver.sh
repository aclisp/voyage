unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
kube-apiserver --etcd-servers=http://$MASTER_IP:4001 --service-cluster-ip-range=$SERVICE_CLUSTER_IP_RANGE --bind-address=$MASTER_IP --insecure-bind-address=$MASTER_IP --secure-port=0 --insecure-port=6443
