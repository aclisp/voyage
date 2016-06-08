unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
kube-apiserver --etcd-servers=http://$MASTER_IP:4001 --service-cluster-ip-range=$SERVICE_CLUSTER_IP_RANGE --bind-address=$MASTER_IP --insecure-bind-address=0.0.0.0
